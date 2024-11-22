#include "kernel/yosys.h"
#include "libs/sha1/sha1.h"

#ifdef YOSYS_ENABLE_READLINE
#include <readline/history.h>
#include <readline/readline.h>
#endif

#ifdef YOSYS_ENABLE_EDITLINE
#include <editline/readline.h>
#endif

#include <errno.h>
#include <limits.h>
#include <stdio.h>
#include <string.h>
#ifndef __STDC_FORMAT_MACROS
#define __STDC_FORMAT_MACROS
#endif
#include <inttypes.h>

#if defined(__linux__)
#include <sys/resource.h>
#include <sys/types.h>
#include <unistd.h>
#endif

#include "setup.h"

USING_YOSYS_NAMESPACE

char *optarg;
int optind = 1, optcur = 1, optopt = 0;
int getopt(int argc, char **argv, const char *optstring)
{
    if (optind >= argc)
        return -1;

    if (argv[optind][0] != '-' || argv[optind][1] == 0) {
        optopt = 1;
        optarg = argv[optind++];
        return optopt;
    }

    bool takes_arg = false;
    optopt = argv[optind][optcur];

    if (optopt == '-') {
        ++optind;
        return -1;
    }

    for (int i = 0; optstring[i]; i++)
        if (optopt == optstring[i] && optstring[i + 1] == ':')
            takes_arg = true;

    if (!takes_arg) {
        if (argv[optind][++optcur] == 0)
            optind++, optcur = 1;
        return optopt;
    }

    if (argv[optind][++optcur]) {
        optarg = argv[optind++] + optcur;
        optcur = 1;
        return optopt;
    }

    if (++optind >= argc) {
        fprintf(stderr, "%s: option '-%c' expects an argument\n", argv[0], optopt);
        optopt = '?';
        return optopt;
    }

    optarg = argv[optind];
    optind++, optcur = 1;

    return optopt;
}

#if defined(YOSYS_ENABLE_READLINE) || defined(YOSYS_ENABLE_EDITLINE)
int yosys_history_offset = 0;
std::string yosys_history_file;
#endif

void yosys_atexit()
{
#if defined(YOSYS_ENABLE_READLINE) || defined(YOSYS_ENABLE_EDITLINE)
    if (!yosys_history_file.empty()) {
#if defined(YOSYS_ENABLE_READLINE)
        if (yosys_history_offset > 0) {
            history_truncate_file(yosys_history_file.c_str(), 100);
            append_history(where_history() - yosys_history_offset, yosys_history_file.c_str());
        } else
            write_history(yosys_history_file.c_str());
#else
        write_history(yosys_history_file.c_str());
#endif
    }

    clear_history();
#if defined(YOSYS_ENABLE_READLINE)
    HIST_ENTRY **hist_list = history_list();
    if (hist_list != NULL)
        free(hist_list);
#endif
#endif
}

#ifdef YOSYS_ENABLE_TCL
namespace Yosys
{
extern int yosys_tcl_iterp_init(Tcl_Interp *interp);
extern void yosys_tcl_activate_repl();
}; // namespace Yosys

#endif
namespace Synlig
{

const char *create_prompt(RTLIL::Design *design, int recursion_counter)
{
    static char buffer[100];
    std::string str = "\n";
    if (recursion_counter > 1)
        str += stringf("(%d) ", recursion_counter);
    str += "synlig";
    if (!design->selected_active_module.empty())
        str += stringf(" [%s]", RTLIL::unescape_id(design->selected_active_module).c_str());
    if (!design->selection_stack.empty() && !design->selection_stack.back().full_selection) {
        if (design->selected_active_module.empty())
            str += "*";
        else if (design->selection_stack.back().selected_modules.size() != 1 || design->selection_stack.back().selected_members.size() != 0 ||
                 design->selection_stack.back().selected_modules.count(design->selected_active_module) == 0)
            str += "*";
    }
    snprintf(buffer, 100, "%s> ", str.c_str());
    return buffer;
}

static char *readline_cmd_generator(const char *text, int state)
{
    static std::map<std::string, Pass *>::iterator it;
    static int len;

    if (!state) {
        it = pass_register.begin();
        len = strlen(text);
    }

    for (; it != pass_register.end(); it++) {
        if (it->first.compare(0, len, text) == 0)
            return strdup((it++)->first.c_str());
    }
    return NULL;
}

static char *readline_obj_generator(const char *text, int state)
{
    static std::vector<char *> obj_names;
    static size_t idx;

    if (!state) {
        idx = 0;
        obj_names.clear();

        RTLIL::Design *design = yosys_get_design();
        int len = strlen(text);

        if (design->selected_active_module.empty()) {
            for (auto mod : design->modules())
                if (RTLIL::unescape_id(mod->name).compare(0, len, text) == 0)
                    obj_names.push_back(strdup(log_id(mod->name)));
        } else if (design->module(design->selected_active_module) != nullptr) {
            RTLIL::Module *module = design->module(design->selected_active_module);

            for (auto w : module->wires())
                if (RTLIL::unescape_id(w->name).compare(0, len, text) == 0)
                    obj_names.push_back(strdup(log_id(w->name)));

            for (auto &it : module->memories)
                if (RTLIL::unescape_id(it.first).compare(0, len, text) == 0)
                    obj_names.push_back(strdup(log_id(it.first)));

            for (auto cell : module->cells())
                if (RTLIL::unescape_id(cell->name).compare(0, len, text) == 0)
                    obj_names.push_back(strdup(log_id(cell->name)));

            for (auto &it : module->processes)
                if (RTLIL::unescape_id(it.first).compare(0, len, text) == 0)
                    obj_names.push_back(strdup(log_id(it.first)));
        }

        std::sort(obj_names.begin(), obj_names.end());
    }

    if (idx < obj_names.size())
        return strdup(obj_names[idx++]);

    idx = 0;
    obj_names.clear();
    return NULL;
}
static char **readline_completion(const char *text, int start, int)
{
    if (start == 0)
        return rl_completion_matches(text, readline_cmd_generator);
    if (strncmp(rl_line_buffer, "read_", 5) && strncmp(rl_line_buffer, "write_", 6))
        return rl_completion_matches(text, readline_obj_generator);
    return NULL;
}

void shell(RTLIL::Design *design)
{
    static int recursion_counter = 0;

    recursion_counter++;
    log_cmd_error_throw = true;

#if defined(YOSYS_ENABLE_READLINE) || defined(YOSYS_ENABLE_EDITLINE)
    rl_readline_name = (char *)"synlig";
    rl_attempted_completion_function = readline_completion;
    rl_basic_word_break_characters = (char *)" \t\n";
#endif

    char *command = NULL;
#if defined(YOSYS_ENABLE_READLINE) || defined(YOSYS_ENABLE_EDITLINE)
    while ((command = readline(create_prompt(design, recursion_counter))) != NULL) {
#else
    char command_buffer[4096];
    while (1) {
        fputs(create_prompt(design, recursion_counter), stdout);
        fflush(stdout);
        if ((command = fgets(command_buffer, 4096, stdin)) == NULL)
            break;
#endif
        if (command[strspn(command, " \t\r\n")] == 0) {
#if defined(YOSYS_ENABLE_READLINE) || defined(YOSYS_ENABLE_EDITLINE)
            free(command);
#endif
            continue;
        }
#if defined(YOSYS_ENABLE_READLINE) || defined(YOSYS_ENABLE_EDITLINE)
        add_history(command);
#endif

        char *p = command + strspn(command, " \t\r\n");
        if (!strncmp(p, "exit", 4)) {
            p += 4;
            p += strspn(p, " \t\r\n");
            if (*p == 0)
                break;
        }

        try {
            log_assert(design->selection_stack.size() == 1);
            Pass::call(design, command);
        } catch (log_cmd_error_exception) {
            while (design->selection_stack.size() > 1)
                design->selection_stack.pop_back();
            log_reset_stack();
        }
        design->check();
#if defined(YOSYS_ENABLE_READLINE) || defined(YOSYS_ENABLE_EDITLINE)
        if (command)
            free(command);
#endif
    }
    if (command == NULL)
        printf("exit\n");
#if defined(YOSYS_ENABLE_READLINE) || defined(YOSYS_ENABLE_EDITLINE)
    else
        free(command);
#endif
    recursion_counter--;
    log_cmd_error_throw = false;
}
std::vector<std::string> format_help_msg(std::string text, int max_len)
{
    std::vector<std::string> lines;
    std::string current_token = "", current_line = "";
    for (char c : text + " ") {
        if (c == ' ') {
            if (current_token == "")
                continue;
            if (current_line.size() + current_token.size() + 1 <= max_len) {
                if (current_line != "")
                    current_line += " ";
                current_line += current_token;
                current_token = "";
            } else {
                if (current_line != "")
                    lines.push_back(current_line);
                current_line = current_token;
                current_token = "";
            }
        } else {
            current_token += c;
        }
    }
    if (current_line != "")
        lines.push_back(current_line);
    return lines;
}
template <typename reg_type> std::string get_list_from_register(std::map<std::string, reg_type> reg)
{
    string result = "";
    for (auto reg_item : reg) {
        if (reg_item != (*reg.begin()))
            result += ", ";
        result += reg_item.first;
    }
    return result;
}
}; // namespace Synlig
int main(int argc, char **argv)
{
    std::string frontend_command = "auto";
    std::string backend_command = "auto";
    std::vector<std::string> vlog_defines;
    std::vector<std::string> passes_commands;
    std::vector<std::string> frontend_files;
    std::vector<std::string> plugin_filenames;
    std::string output_filename = "";
    std::string scriptfile = "";
    std::string depsfile = "";
    std::string topmodule = "";
    std::string perffile = "";
    bool scriptfile_tcl = false;
    bool print_banner = true;
    bool print_stats = true;
    bool call_abort = false;
    bool timing_details = false;
    bool run_shell = true;
    bool run_tcl_shell = false;
    bool mode_v = false;
    bool mode_q = false;

    if (argc == 2 && (!strcmp(argv[1], "-h") || !strcmp(argv[1], "-help") || !strcmp(argv[1], "--help"))) {
        printf("\n");
        printf("Usage: %s [options] [<infile> [..]]\n", argv[0]);
        printf("\n");
        printf("    -Q\n");
        printf("        suppress printing of banner (copyright, disclaimer, version)\n");
        printf("\n");
        printf("    -T\n");
        printf("        suppress printing of footer (log hash, version, timing statistics)\n");
        printf("\n");
        printf("    -q\n");
        printf("        quiet operation. only write warnings and error messages to console\n");
        printf("        use this option twice to also quiet warning messages\n");
        printf("\n");
        printf("    -v <level>\n");
        printf("        print log headers up to level <level> to the console. (this\n");
        printf("        implies -q for everything except the 'End of script.' message.)\n");
        printf("\n");
        printf("    -t\n");
        printf("        annotate all log messages with a time stamp\n");
        printf("\n");
        printf("    -d\n");
        printf("        print more detailed timing stats at exit\n");
        printf("\n");
        printf("    -l logfile\n");
        printf("        write log messages to the specified file\n");
        printf("\n");
        printf("    -L logfile\n");
        printf("        like -l but open log file in line buffered mode\n");
        printf("\n");
        printf("    -o outfile\n");
        printf("        write the design to the specified file on exit\n");
        printf("\n");
        printf("    -b backend\n");
        printf("        use this backend for the output file specified on the command line\n");
        Pass::init_register();
        std::string backend_text = "list of available backends: " + Synlig::get_list_from_register<Backend *>(backend_register);
        for (auto line : Synlig::format_help_msg(backend_text, 70))
            printf("        %s\n", line.c_str());
        printf("\n");
        printf("    -f frontend\n");
        printf("        use the specified frontend for the input files on the command line\n");
        std::string frontend_text = "list of available frontends: " + Synlig::get_list_from_register<Frontend *>(frontend_register);
        for (auto line : Synlig::format_help_msg(frontend_text, 70))
            printf("        %s\n", line.c_str());
        printf("\n");
        printf("    -H\n");
        printf("        print the command list\n");
        printf("\n");
        printf("    -h command\n");
        printf("        print the help message for the specified command\n");
        printf("\n");
        printf("    -s scriptfile\n");
        printf("        execute the commands in the script file\n");
#ifdef YOSYS_ENABLE_TCL
        printf("\n");
        printf("    -c tcl_scriptfile\n");
        printf("        execute the commands in the tcl script file (see 'help tcl' for details)\n");
        printf("\n");
        printf("    -C\n");
        printf("        enters TCL interatcive shell mode\n");
#endif
        printf("\n");
        printf("    -p command\n");
        printf("        execute the commands (to chain commands, separate them with semicolon + whitespace: 'cmd1; cmd2')\n");
        printf("\n");
        printf("    -m module_file\n");
        printf("        load the specified module (aka plugin)\n");
        printf("\n");
        printf("    -X\n");
        printf("        enable tracing of core data structure changes. for debugging\n");
        printf("\n");
        printf("    -M\n");
        printf("        will slightly randomize allocated pointer addresses. for debugging\n");
        printf("\n");
        printf("    -A\n");
        printf("        will call abort() at the end of the script. for debugging\n");
        printf("\n");
        printf("    -r <module_name>\n");
        printf("        elaborate command line arguments using the specified top module\n");
        printf("\n");
        printf("    -D <macro>[=<value>]\n");
        printf("        set the specified Verilog define (via \"read -define\")\n");
        printf("\n");
        printf("    -P <header_id>[:<filename>]\n");
        printf("        dump the design when printing the specified log header to a file.\n");
        printf("        yosys_dump_<header_id>.il is used as filename if none is specified.\n");
        printf("        Use 'ALL' as <header_id> to dump at every header.\n");
        printf("\n");
        printf("    -W regex\n");
        printf("        print a warning for all log messages matching the regex.\n");
        printf("\n");
        printf("    -w regex\n");
        printf("        if a warning message matches the regex, it is printed as regular\n");
        printf("        message instead.\n");
        printf("\n");
        printf("    -e regex\n");
        printf("        if a warning message matches the regex, it is printed as error\n");
        printf("        message instead and the tool terminates with a nonzero return code.\n");
        printf("\n");
        printf("    -E <depsfile>\n");
        printf("        write a Makefile dependencies file with in- and output file names\n");
        printf("\n");
        printf("    -x <feature>\n");
        printf("        do not print warnings for the specified experimental feature\n");
        printf("\n");
        printf("    -g\n");
        printf("        globally enable debug log messages\n");
        printf("\n");
        printf("    -V\n");
        printf("        print version information and exit\n");
        printf("\n");
        printf("The option -S is a shortcut for calling the \"synth\" command, a default\n");
        printf("script for transforming the Verilog input to a gate-level netlist. For example:\n");
        printf("\n");
        printf("    %s -o output.blif -S input.v\n", argv[0]);
        printf("\n");
        printf("For more complex synthesis jobs it is recommended to use the read_* and write_*\n");
        printf("commands in a script file instead of specifying input and output files on the\n");
        printf("command line.\n");
        printf("\n");
        printf("When no commands, script files or input files are specified on the command\n");
        printf("line, %s automatically enters the interactive command mode. Use the 'help'\n", argv[0]);
        printf("command to get information on the individual commands.\n");
        printf("\n");
        exit(0);
    }

    if (argc == 2 && (!strcmp(argv[1], "-V") || !strcmp(argv[1], "-version") || !strcmp(argv[1], "--version"))) {
        printf("%s\n", yosys_version_str);
        exit(0);
    }

    int opt;
    while ((opt = getopt(argc, argv, "MXAQTVCSgm:f:Hh:b:o:p:l:L:qv:tds:c:W:w:e:r:D:P:E:x:B:")) != -1) {
        switch (opt) {
        case 'M':
            memhasher_on();
            break;
        case 'X':
            yosys_xtrace++;
            break;
        case 'A':
            call_abort = true;
            break;
        case 'Q':
            print_banner = false;
            break;
        case 'T':
            print_stats = false;
            break;
        case 'V':
            printf("%s\n", yosys_version_str);
            exit(0);
        case 'S':
            passes_commands.push_back("synth");
            run_shell = false;
            break;
        case 'g':
            log_force_debug++;
            break;
        case 'm':
            plugin_filenames.push_back(optarg);
            break;
        case 'f':
            frontend_command = optarg;
            break;
        case 'H':
            passes_commands.push_back("help");
            run_shell = false;
            break;
        case 'h':
            passes_commands.push_back(stringf("help %s", optarg));
            run_shell = false;
            break;
        case 'b':
            backend_command = optarg;
            run_shell = false;
            break;
        case 'p':
            passes_commands.push_back(optarg);
            run_shell = false;
            break;
        case 'o':
            output_filename = optarg;
            run_shell = false;
            break;
        case 'l':
        case 'L':
            log_files.push_back(fopen(optarg, "wt"));
            if (log_files.back() == NULL) {
                fprintf(stderr, "Can't open log file `%s' for writing!\n", optarg);
                exit(1);
            }
            if (opt == 'L')
                setvbuf(log_files.back(), NULL, _IOLBF, 0);
            break;
        case 'q':
            mode_q = true;
            if (log_errfile == stderr)
                log_quiet_warnings = true;
            log_errfile = stderr;
            break;
        case 'v':
            mode_v = true;
            log_errfile = stderr;
            log_verbose_level = atoi(optarg);
            break;
        case 't':
            log_time = true;
            break;
        case 'd':
            timing_details = true;
            break;
        case 's':
            scriptfile = optarg;
            scriptfile_tcl = false;
            run_shell = false;
            break;
        case 'c':
            scriptfile = optarg;
            scriptfile_tcl = true;
            run_shell = false;
            break;
        case 'W':
            log_warn_regexes.push_back(YS_REGEX_COMPILE(optarg));
            break;
        case 'w':
            log_nowarn_regexes.push_back(YS_REGEX_COMPILE(optarg));
            break;
        case 'e':
            log_werror_regexes.push_back(YS_REGEX_COMPILE(optarg));
            break;
        case 'r':
            topmodule = optarg;
            break;
        case 'D':
            vlog_defines.push_back(optarg);
            break;
        case 'P': {
            auto args = split_tokens(optarg, ":");
            if (!args.empty() && args[0] == "ALL") {
                if (GetSize(args) != 1) {
                    fprintf(stderr, "Invalid number of tokens in -D ALL.\n");
                    exit(1);
                }
                log_hdump_all = true;
            } else {
                if (!args.empty() && !args[0].empty() && args[0].back() == '.')
                    args[0].pop_back();
                if (GetSize(args) == 1)
                    args.push_back("yosys_dump_" + args[0] + ".il");
                if (GetSize(args) != 2) {
                    fprintf(stderr, "Invalid number of tokens in -D.\n");
                    exit(1);
                }
                log_hdump[args[0]].insert(args[1]);
            }
        } break;
        case 'E':
            depsfile = optarg;
            break;
        case 'x':
            log_experimentals_ignored.insert(optarg);
            break;
        case 'B':
            perffile = optarg;
            break;
        case 'C':
            run_tcl_shell = true;
            break;
        case '\001':
            frontend_files.push_back(optarg);
            break;
        default:
            fprintf(stderr, "Run '%s -h' for help.\n", argv[0]);
            exit(1);
        }
    }

    if (log_errfile == NULL) {
        log_files.push_back(stdout);
        log_error_stderr = true;
    }

#if defined(YOSYS_ENABLE_READLINE)
    std::string state_dir;
    if (getenv("XDG_STATE_HOME") == NULL || getenv("XDG_STATE_HOME")[0] == '\0') {
        if (getenv("HOME") != NULL) {
            state_dir = stringf("%s/.local/state", getenv("HOME"));
        } else {
            log_debug("$HOME is empty. No history file will be created.\n");
        }
    } else {
        state_dir = stringf("%s", getenv("XDG_STATE_HOME"));
    }

    if (!state_dir.empty()) {
        std::string yosys_dir = state_dir + "/yosys";
        create_directory(yosys_dir);

        yosys_history_file = yosys_dir + "/history";
        read_history(yosys_history_file.c_str());
        yosys_history_offset = where_history();
    }
#endif

    if (print_stats)
        log_hasher = new SHA1;

#if defined(__linux__)
    // set stack size to >= 128 MB
    {
        struct rlimit rl;
        const rlim_t stack_size = 128L * 1024L * 1024L;
        if (getrlimit(RLIMIT_STACK, &rl) == 0 && rl.rlim_cur < stack_size) {
            rl.rlim_cur = stack_size;
            setrlimit(RLIMIT_STACK, &rl);
        }
    }
#endif

    Synlig::synlig_setup();
    log_error_atexit = yosys_atexit;

    for (auto &fn : plugin_filenames)
        load_plugin(fn, {});

    log_suppressed();

    if (!vlog_defines.empty()) {
        std::string vdef_cmd = "read -define";
        for (auto vdef : vlog_defines)
            vdef_cmd += " " + vdef;
        run_pass(vdef_cmd);
    }

    if (scriptfile.empty() || !scriptfile_tcl) {
        // Without a TCL script, arguments following '--' are also treated as frontend files
        for (int i = optind; i < argc; ++i)
            frontend_files.push_back(argv[i]);
    }

    if (frontend_files.size() != 0 && frontend_register.count(frontend_command) == 0 && frontend_command != "auto") {
        std::string frontend_text = "list of available frontends: " + Synlig::get_list_from_register<Frontend *>(frontend_register);
        for (auto line : Synlig::format_help_msg(frontend_text, 80))
            printf("%s\n", line.c_str());
        printf("\n");
        log_error(("No such frontend: " + frontend_command + "\n").c_str());
    }

    for (auto it = frontend_files.begin(); it != frontend_files.end(); ++it) {

        if (run_frontend((*it).c_str(), frontend_command))
            run_shell = false;
    }

    if (!topmodule.empty())
        run_pass("hierarchy -top " + topmodule);
    if (!scriptfile.empty()) {
        if (scriptfile_tcl) {
#ifdef YOSYS_ENABLE_TCL
            int tcl_argc = argc - optind;
            std::vector<Tcl_Obj *> script_args;
            Tcl_Interp *interp = yosys_get_tcl_interp();
            for (int i = optind; i < argc; ++i)
                script_args.push_back(Tcl_NewStringObj(argv[i], strlen(argv[i])));

            Tcl_ObjSetVar2(interp, Tcl_NewStringObj("argc", 4), NULL, Tcl_NewIntObj(tcl_argc), 0);
            Tcl_ObjSetVar2(interp, Tcl_NewStringObj("argv", 4), NULL, Tcl_NewListObj(tcl_argc, script_args.data()), 0);
            Tcl_ObjSetVar2(interp, Tcl_NewStringObj("argv0", 5), NULL, Tcl_NewStringObj(scriptfile.c_str(), scriptfile.length()), 0);

            if (Tcl_EvalFile(interp, scriptfile.c_str()) != TCL_OK)
                log_error("TCL interpreter returned an error: %s\n", Tcl_GetStringResult(yosys_get_tcl_interp()));
#else
            log_error("Can't exectue TCL script: this version of yosys is not built with TCL support enabled.\n");
#endif
        } else
            run_frontend(scriptfile, "script");
    }

    for (auto it = passes_commands.begin(); it != passes_commands.end(); it++)
        run_pass(*it);

    if (run_tcl_shell) {
#ifdef YOSYS_ENABLE_TCL
        yosys_tcl_activate_repl();
        Tcl_Main(argc, argv, yosys_tcl_iterp_init);
#else
        log_error("Can't exectue TCL shell: this version of yosys is not built with TCL support enabled.\n");
#endif
    } else {
        if (run_shell) {
            Synlig::shell(yosys_design);
        } else {
            if (backend_register.count(backend_command) == 0 && backend_command != "auto") {
                std::string backend_text = "list of available backends: " + Synlig::get_list_from_register<Backend *>(backend_register);
                for (auto line : Synlig::format_help_msg(backend_text, 80))
                    printf("%s\n", line.c_str());
                printf("\n");
                log_error(("No such backend: " + backend_command + "\n").c_str());
            }
            run_backend(output_filename, backend_command);
        }
    }

    yosys_design->check();
    for (auto it : saved_designs)
        it.second->check();
    for (auto it : pushed_designs)
        it->check();

    if (!depsfile.empty()) {
        FILE *f = fopen(depsfile.c_str(), "wt");
        if (f == nullptr)
            log_error("Can't open dependencies file for writing: %s\n", strerror(errno));
        bool first = true;
        for (auto fn : yosys_output_files) {
            fprintf(f, "%s%s", first ? "" : " ", escape_filename_spaces(fn).c_str());
            first = false;
        }
        fprintf(f, ":");
        for (auto fn : yosys_input_files) {
            if (yosys_output_files.count(fn) == 0)
                fprintf(f, " %s", escape_filename_spaces(fn).c_str());
        }
        fprintf(f, "\n");
    }

    if (log_expect_no_warnings && log_warnings_count_noexpect)
        log_error("Unexpected warnings found: %d unique messages, %d total, %d expected\n", GetSize(log_warnings), log_warnings_count,
                  log_warnings_count - log_warnings_count_noexpect);

    if (print_stats) {
        std::string hash = log_hasher->final().substr(0, 10);
        delete log_hasher;
        log_hasher = nullptr;

        log_time = false;
        yosys_xtrace = 0;
        log_spacer();

        if (mode_v && !mode_q)
            log_files.push_back(stderr);

        if (log_warnings_count)
            log("Warnings: %d unique messages, %d total\n", GetSize(log_warnings), log_warnings_count);

        if (!log_experimentals.empty())
            log("Warnings: %d experimental features used (not excluded with -x).\n", GetSize(log_experimentals));

        std::string meminfo;
        std::string stats_divider = ", ";

        struct rusage ru_buffer;
        getrusage(RUSAGE_SELF, &ru_buffer);
        if (yosys_design->scratchpad_get_bool("print_stats.include_children")) {
            struct rusage ru_buffer_children;
            getrusage(RUSAGE_CHILDREN, &ru_buffer_children);
            ru_buffer.ru_utime.tv_sec += ru_buffer_children.ru_utime.tv_sec;
            ru_buffer.ru_utime.tv_usec += ru_buffer_children.ru_utime.tv_usec;
            ru_buffer.ru_stime.tv_sec += ru_buffer_children.ru_stime.tv_sec;
            ru_buffer.ru_stime.tv_usec += ru_buffer_children.ru_stime.tv_usec;
#if defined(__linux__)
            ru_buffer.ru_maxrss = std::max(ru_buffer.ru_maxrss, ru_buffer_children.ru_maxrss);
#endif
        }
#if defined(__linux__)
        meminfo = stringf(", MEM: %.2f MB peak", ru_buffer.ru_maxrss / 1024.0);
#endif
        log("End of script. Logfile hash: %s%sCPU: user %.2fs system %.2fs%s\n", hash.c_str(), stats_divider.c_str(),
            ru_buffer.ru_utime.tv_sec + 1e-6 * ru_buffer.ru_utime.tv_usec, ru_buffer.ru_stime.tv_sec + 1e-6 * ru_buffer.ru_stime.tv_usec,
            meminfo.c_str());

        int64_t total_ns = 0;
        std::set<tuple<int64_t, int, std::string>> timedat;

        for (auto &it : pass_register)
            if (it.second->call_counter) {
                total_ns += it.second->runtime_ns + 1;
                timedat.insert(make_tuple(it.second->runtime_ns + 1, it.second->call_counter, it.first));
            }

        if (timing_details) {
            log("Time spent:\n");
            for (auto it = timedat.rbegin(); it != timedat.rend(); it++) {
                log("%5d%% %5d calls %8.3f sec %s\n", int(100 * std::get<0>(*it) / total_ns), std::get<1>(*it), std::get<0>(*it) / 1000000000.0,
                    std::get<2>(*it).c_str());
            }
        } else {
            int out_count = 0;
            log("Time spent:");
            for (auto it = timedat.rbegin(); it != timedat.rend() && out_count < 4; it++, out_count++) {
                if (out_count >= 2 && (std::get<0>(*it) < 1000000000 || int(100 * std::get<0>(*it) / total_ns) < 20)) {
                    log(", ...");
                    break;
                }
                log("%s %d%% %dx %s (%d sec)", out_count ? "," : "", int(100 * std::get<0>(*it) / total_ns), std::get<1>(*it),
                    std::get<2>(*it).c_str(), int(std::get<0>(*it) / 1000000000));
            }
            log("%s\n", out_count ? "" : " no commands executed");
        }
        if (!perffile.empty()) {
            FILE *f = fopen(perffile.c_str(), "wt");
            if (f == nullptr)
                log_error("Can't open performance log file for writing: %s\n", strerror(errno));

            fprintf(f, "{\n");
            fprintf(f, "  \"generator\": \"%s\",\n", yosys_version_str);
            fprintf(f, "  \"total_ns\": %" PRIu64 ",\n", total_ns);
            fprintf(f, "  \"passes\": {");

            bool first = true;
            for (auto it = timedat.rbegin(); it != timedat.rend(); it++) {
                if (!first)
                    fprintf(f, ",");
                fprintf(f, "\n    \"%s\": {\n", std::get<2>(*it).c_str());
                fprintf(f, "      \"runtime_ns\": %" PRIu64 ",\n", std::get<0>(*it));
                fprintf(f, "      \"num_calls\": %u\n", std::get<1>(*it));
                fprintf(f, "    }");
                first = false;
            }
            fprintf(f, "\n  }\n}\n");
        }
    }

#if defined(YOSYS_ENABLE_COVER) && (defined(__linux__))
    if (getenv("YOSYS_COVER_DIR") || getenv("YOSYS_COVER_FILE")) {
        string filename;
        FILE *f;

        if (getenv("YOSYS_COVER_DIR")) {
            filename = stringf("%s/yosys_cover_%d_XXXXXX.txt", getenv("YOSYS_COVER_DIR"), getpid());
            filename = make_temp_file(filename);
        } else {
            filename = getenv("YOSYS_COVER_FILE");
        }

        f = fopen(filename.c_str(), "a+");

        if (f == NULL)
            log_error("Can't create coverage file `%s'.\n", filename.c_str());

        log("<writing coverage file \"%s\">\n", filename.c_str());

        for (auto &it : get_coverage_data())
            fprintf(f, "%-60s %10d %s\n", it.second.first.c_str(), it.second.second, it.first.c_str());

        fclose(f);
    }
#endif

    log_check_expected();

    yosys_atexit();

    memhasher_off();
    if (call_abort)
        abort();

    log_flush();

    yosys_shutdown();

    return 0;
}
