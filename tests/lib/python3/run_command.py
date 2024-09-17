#!/usr/bin/env python3
import os
import resource
import select
import shutil
import signal
import sys
import time

from typing import Optional
from dataclasses import dataclass

__all__ = [
    "run_command",
    "TIMED_OUT_STATUS",
]

# Returned from `RunCommandResult.status()` when the process has been killed
# due to a time out.
# `exit_status` has 1 byte for a signal number, so
# anything larger than 255 won't cause any conflicts.
TIMED_OUT_STATUS = -256


# `run_command()` result type.
@dataclass
class RunCommandResult:
    exit_status: int
    timed_out: bool = False
    stdout: Optional[bytes] = None
    stderr: Optional[bytes] = None
    utime_s: float = 0.0
    stime_s: float = 0.0
    elapsed_s: float = 0.0
    rss_kb: int = 0

    @property
    def status(self):
        if self.timed_out:
            return TIMED_OUT_STATUS
        else:
            return os.waitstatus_to_exitcode(self.exit_status)

    def __str__(self):
        if self.timed_out:
            result = "TIMEOUT"
        elif os.WIFSIGNALED(self.exit_status):
            try:
                result = signal.Signals(-self.status).name
            except ValueError:
                result = f"SIG({-self.status})"
        else:
            result = f"RC: {self.status}"

        return (result + "; " + f"Usr Time: {self.utime_s:.3f} s; " +
                f"Sys Time: {self.stime_s:.3f} s; " +
                f"Elapsed: {self.elapsed_s:.3f} s; " +
                f"Max RSS: {self.rss_kb} kB")


def _handle_child_process(pid_fd, process_out_fds, timeout):
    """
    Monitors and handles child process FDs for up to `timeout` seconds.

    Data is read from file descriptors passed in iterable `process_out_fds`
    into separate buffer for each FD.
    The function returns a tuple `(timed_out, buffers)` when:
    - `pid_fd` signals readiness to be read. In this case `timed_out=False`.
    - `timeout` seconds passes. Results in `timed_out=True`.
    In both cases `buffers` is a map of data read from FDs passed in
    `process_out_fds` assigned to a corresponding FD.
    """

    end_time = time.perf_counter() + timeout if timeout else None

    # Set of all monitored FDs.
    fds = {pid_fd, *process_out_fds}
    # Mapping of FDs to lists of read data chunks.
    buffers = {fd: [] for fd in process_out_fds}
    timed_out = False

    while fds:
        timeout = end_time - time.perf_counter() if end_time else None
        rl = []
        if timeout is None or timeout > 0:
            # `rl`: FDs with data available for reading. `wl`, `xl`: unused.
            rl, wl, xl = select.select(fds, [], [], timeout)
        # Timeout
        if not rl:
            timed_out = True
            break
        # Read available data from all ready FDs.
        for fd in rl:
            if fd in buffers:
                chunk = os.read(fd, 8 * 1024)
                # Empty buffer means that the child closed the connection.
                if not chunk:
                    # Don't monitor the FD anymore.
                    fds.remove(fd)
                else:
                    # Store the data chunk
                    buffers[fd].append(chunk)
            elif fd == pid_fd:
                # Process terminated. Do not return yet, other FDs in `rl`
                # might still wait to be read from.
                fds.remove(fd)
            else:
                raise RuntimeError("Unexpected FD returned from select().")

    # Merge chunks into byte arrays
    buffers = {k: b"".join(v) for k, v in buffers.items()}
    return timed_out, buffers


def _redirect_stdio(stdout_fd, stderr_fd):
    """
    Redirects stdout and stderr of the current process to specified FDs or to
    `/dev/null` if a FD is None. Stdin is always redirected to `/dev/null`.
    """

    dev_null = os.open(os.devnull, os.O_RDWR)
    # Redirect stdin to /dev/null
    os.dup2(dev_null, sys.stdin.fileno())
    # Redirect stdout and stderr
    os.dup2(stdout_fd if stdout_fd >= 0 else dev_null, sys.stdout.fileno())
    os.dup2(stderr_fd if stderr_fd >= 0 else dev_null, sys.stderr.fileno())
    os.close(dev_null)


def run_command(cmd: list[str],
                capture_stdout=True,
                capture_stderr=True,
                capture_merged_outputs=False,
                timeout=None,
                vmem_limit_kb=None,
                oom_score_adj=0) -> RunCommandResult:
    assert len(cmd) > 0

    cmd_path = shutil.which(cmd[0])
    if not cmd_path:
        raise FileNotFoundError(cmd[0])

    if capture_merged_outputs:
        capture_stdout = True
        capture_stderr = True

    if capture_merged_outputs:
        stdout_r, stdout_w = os.pipe()
        stderr_r, stderr_w = (stdout_r, stdout_w)
    else:
        stdout_r, stdout_w = os.pipe() if capture_stdout else (-1, -1)
        stderr_r, stderr_w = os.pipe() if capture_stderr else (-1, -1)

    pid = os.fork()

    # Child process
    if pid == 0:
        _redirect_stdio(stdout_w, stderr_w)
        if vmem_limit_kb:
            resource.setrlimit(resource.RLIMIT_AS,
                               (vmem_limit_kb * 1024, vmem_limit_kb * 1024))

        if oom_score_adj:
            # Adjust "killability" in case of OOM. Higher => higher chance of being killed.
            try:
                with open("/proc/self/oom_score_adj", "w") as f:
                    f.write(str(oom_score_adj))
            except:
                # Ignore if unsupported or something.
                pass

        # Intentionally ignoring std(out|err)_[rw] FDs. They refer to pipes,
        # which are closed automatically on exec.

        try:
            os.execlp(cmd[0], *cmd)
        except Exception as e:
            import traceback
            traceback.print_exc()
        finally:
            sys.exit(1)

    start_time = time.perf_counter()
    child_out_fds = set()

    pid_fd = os.pidfd_open(pid, 0)

    if capture_stdout:
        os.close(stdout_w)
        child_out_fds.add(stdout_r)
    if capture_stderr and not capture_merged_outputs:
        os.close(stderr_w)
        child_out_fds.add(stderr_r)

    remaining_timeout = timeout - (time.perf_counter() -
                                   start_time) if timeout is not None else None
    timed_out, buffers = _handle_child_process(pid_fd, child_out_fds,
                                               remaining_timeout)

    # At this point the process is either terminated or will be killed below.
    # `_handle_child_process` exits only as a result of a timeout or
    # the process termination.
    time_diff = time.perf_counter() - start_time

    os.close(pid_fd)
    for fd in child_out_fds:
        os.close(fd)

    if timed_out:
        # Kill the child process.
        # TODO(mglb): Send SIGTERM, wait a while, check for termination,
        # and then SIGKILL if still needed.
        os.kill(pid, signal.SIGKILL)

    # Read child_pid (unused), exit status, and rusage of the terminated
    # child process.
    child_pid, status, rusage = os.wait3(0)

    return RunCommandResult(
        exit_status=status,
        timed_out=timed_out,
        stdout=buffers[stdout_r] if capture_stdout else None,
        stderr=buffers[stderr_r] if capture_stderr else None,
        utime_s=rusage.ru_utime,
        stime_s=rusage.ru_stime,
        elapsed_s=time_diff,
        rss_kb=rusage.ru_maxrss)
