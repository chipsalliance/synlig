module.exports = async ({github, context, core, glob, io, exec, fetch, require}) => {
  const valid_archive_types = ["tar", "tar.xz", "tar.zstd", "tar.gz"];
  const {INPUT_NAME, INPUT_PATH, INPUT_ARCHIVE_TYPE, INPUT_ARCHIVE_NAME, GITHUB_WORKSPACE} = process.env;

  const clean_name = INPUT_NAME.trim()
  const clean_archive_name = INPUT_ARCHIVE_NAME.trim()
  const clean_archive_type = INPUT_ARCHIVE_TYPE.trim()

  if (!["", ...valid_archive_types].includes(clean_archive_type)) {
    core.setFailed(`Invalid archive-type: ${clean_archive_type}\nExpected one of: "", ${valid_archive_types.join(", ")}`);
    return;
  }
  if (clean_name.includes("/")) {
    core.setFailed(`name shouldn't contain "/": ${clean_name}`);
    return;
  }
  if (clean_archive_name.includes("/")) {
    core.setFailed(`archive-name shouldn't contain "/": ${clean_archive_name}`);
    return;
  }
  if (clean_archive_name === "" && clean_archive_type === "") {
    core.setFailed("At least one of following inputs must be set: archive-name, archive-type");
    return;
  }

  let tmp_dir = "";
  await exec.exec("mktemp",
      ["-d", "-p", GITHUB_WORKSPACE, ".tmp.pack-upload-artifacts-XXXXXXXXXX"],
      {
        listeners: {
          stdout: (data) => { tmp_dir += data.toString(); },
        }
      });
  const g = await glob.create(INPUT_PATH, { followSymbolicLinks: false});
  const files = await g.glob();

  let archive_name = "";
  if (clean_archive_name !== "") {
    if (clean_archive_type !== "" && clean_archive_name.endsWith(`.${clean_archive_type}`)) {
      archive_name = clean_archive_name;
    } else {
      archive_name = `${clean_archive_name}.${clean_archive_type}`;
    }
  } else {
    archive_name = `${clean_name}.${clean_archive_type}`;
  }

  const tar_rc = await exec.exec("tar",
      ["-c", "-a", "-f", `${tmp_dir}/${archive_name}`, "--verbatim-files-from", "--null", "-T", "-"],
      { input: Buffer.from(files.join("\0")) });
  if (tar_rc != 0) {
    core.setFailed(`tar terminated with status ${tar_rc}`);
    return;
  }

  return `${tmp_dir}/${archive_name}`;
}
