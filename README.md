# Synlig

![Synlig logo](images/synlig-logo.svg)

Synlig is a SystemVerilog and [UHDM](https://github.com/chipsalliance/UHDM) front end plugin for [Yosys](https://github.com/YosysHQ/yosys). 
It uses [Surelog](https://github.com/chipsalliance/Surelog), a SystemVerilog 2017 preprocessor, parser and elaborator.

## Installation

Before installing the plugin, check that Yosys is installed and correctly configured:

<!-- name="check-yosys" -->
``` bash
   yosys -version
   yosys-config --help
```

The required Yosys version is 0.33 or later.
If you don't have Yosys, skip to the [Installation from source](#installation-from-source) section to build Yosys from the source or follow the steps below for Debian-based Linux distributions.
Note that the yosys package is currently only available in Debian Sid.

<!-- name="install-yosys-debian" -->
``` bash
   apt install -y yosys yosys-dev
```

When you are sure Yosys is installed and configured, download and unpack the latest version of the plugin:

<!-- name="download-plugin" -->
``` bash
   apt install -y curl jq tar wget
   curl https://api.github.com/repos/chipsalliance/synlig/releases/latest | jq -r '.assets | .[] | select(.name | startswith("synlig-plugin-debian")) | .browser_download_url' | xargs wget -O - | tar -xz
```

Then, install the plugin with superuser privileges:

<!-- name="install-plugin" -->
``` bash
   ./install_plugin.sh
```
The plugin is now ready to be used. and you can go to the [Usage](#usage) section of this document for instructions on how to load the plugin into Yosys.

## Installation from source

* Debian Trixie:

### Install dependencies

<!-- name="dependencies" -->
``` bash
   apt install -y gcc-11 g++-11 build-essential cmake tclsh ant default-jre swig google-perftools libgoogle-perftools-dev python3 python3-dev python3-pip uuid uuid-dev tcl-dev flex libfl-dev git pkg-config libreadline-dev bison libffi-dev wget python3-orderedmultidict
```

### Build required binaries

You can build all required binaries using the provided `Makefile`.
`make install` will build Surelog, Yosys and Synlig, and place them in the `out` directory.
You need to add `out/bin` to your `PATH` variable to ensure you are using correct versions of the binaries.

<!-- name="build-binaries" -->
``` bash
   git submodule sync
   git submodule update --init --recursive third_party/{surelog,yosys}
   make install
```

To use Yosys built from a submodule, make sure to either use absolute paths, or update the `PATH` variable before use.

<!-- name="path-setup" -->
``` bash
   export PATH=`pwd`/out/current/bin:$PATH
```

## Usage

### Loading Synlig into Yosys

You can now start Yosys by executing the `yosys` command.
In order to use the SystemVerilog plugin, you first need to load it in Yosys. To do so, execute the following commands in Yosys prompt:

<!-- name="load-plugin" -->
``` tcl
   plugin -i systemverilog
   help read_systemverilog
   help read_uhdm
   exit
```

Now Yosys is extended with 2 additional commands:

* `read_systemverilog [options] [filenames]` - reads SystemVerilog files directly in Yosys. 
It executes Surelog with provided filenames and converts them (in memory) into an UHDM file. 
This UHDM file is converted into a Yosys AST. 
Note: arguments to this command should be exactly the same as for Surelog binary.
* `read_uhdm  [options] [filename]` - reads a UHDM file generated using Surelog and converts it into a Yosys AST.

### Generating a UHDM file

You can either generate a UHDM file directly using Surelog or convert SystemVerilog files to UHDM using the Yosys `read_systemverilog` command, where the command acts as a wrapper around a Surelog binary. 
It accepts the same arguments as Surelog and executes Surelog underneath. 
You can find more information about Surelog usage in [its README](https://github.com/chipsalliance/Surelog#usage).

### Quick start examples

As a simple example, we run Verilog code synthesis using the plugin:

<!-- name="example-verilog" -->
``` bash
   yosys -p "plugin -i systemverilog" -p "read_systemverilog tests/simple_tests/onenet/top.sv"
```

In the second example, we first need to convert the SystemVerilog file into UHDM using Surelog and then read it into Yosys.

<!-- name="example-uhdm-ver1" -->
``` bash
   surelog -parse tests/simple_tests/onenet/top.sv
   yosys -p "plugin -i systemverilog" -p "read_uhdm slpp_all/surelog.uhdm"
```

This is equivalent to:

<!-- name="example-uhdm-ver2" -->
``` bash
   yosys -p "plugin -i systemverilog" -p "read_systemverilog tests/simple_tests/onenet/top.sv"
```

After loading it into Yosys, you can process it further using regular Yosys commands.

### Example for parsing multiple files

To parse a multi-file with the `read_systemverilog` command, all files have to be listed at once. 
his can be troublesome for larger designs. 
To mitigate this issue, the plugin supports a flow that allows users to pass files and link them separately. 
Files can be loaded one by one using the `-defer` flag. 
Once all files are uploaded, you should call `read_systemverilog -link` to elaborate them. 
The described flow looks like so:

<!-- name="example-multiple-files" -->
``` tcl
    plugin -i systemverilog
    # Read each file separately
    read_systemverilog -defer tests/separate_compilation/separate_compilation.v
    read_systemverilog -defer tests/separate_compilation/separate_compilation_buf.sv
    read_systemverilog -defer tests/separate_compilation/separate_compilation_pkg.sv
    # Finish reading files, elaborate the design
    read_systemverilog -link
    # Continue Yosys flow...
    exit
```

The `-defer` flag is experimental.
If you encounter any problems with it, please compare the results with a single `read_systemverilog` command, check the [open issues](https://github.com/chipsalliance/synlig/issues), and open a new issue if needed.

## Testing locally

### Formal Verification

#### Prerequisites

Formal Verification uses `sv2v` tool and tests from its repository, which is available as a submodule.
To download the sv2v submodule run:

<!-- name="sv2v-update" -->
``` bash
   git submodule update --init --recursive --checkout third_party/sv2v
```

To build sv2v and copy it to `out/current/bin` (where it is expected to be by the test script) run:

<!-- name="sv2v-build" -->
``` bash
wget -qO- https://get.haskellstack.org/ | sh -s - -f -d $PWD/out/current/bin
make -j$(nproc) -C $PWD/third_party/sv2v
cp ./third_party/sv2v/bin/sv2v ./out/current/bin
```

#### Testing

To start formal verification tests, use `run_fv_tests.mk`, either as an executable or by using make:

<!-- name="run-fv-tests-exec" -->
``` bash
   ./run_fv_tests.mk [make_args...] \
         TEST_SUITE_DIR:=<test_suite_dir> \
         [TEST_SUITE_NAME:=<test_suite_name>] \
         [target...]
```

<!-- name="run-fv-tests-make" -->
``` bash
   make -f ./run_fv_tests.mk [make_args] [args...] [target...]
```

* `test_suite_dir` - path to a tests directory (e.g. `./yosys/tests`). Required by all targets except `help`.
* `test_suite_name` - when specified, it is used as a name of a directory inside `./build/` where results are stored. Otherwise results are stored directly inside the `./build/` directory.

`yosys` and `sv2v` must be present in one of `PATH` directories.
For other dependencies, please see the `.github/workflows/formal-verification.yml` file.

#### Available Targets

* ``help`` - Prints help.
* ``list`` - Prints tests available in specified ``test_suite_dir``. Each test from the list is itself a valid target.
* ``test`` - Runs all tests from ``test_suite_dir``.

## General & debugging tips

1. `synlig` needs to be compiled with the same version of Surelog that was used to generate the UHDM file. 
When you are updating the Surelog version, you also need to recompile the plugin.
1. You can print the UHDM tree by adding `-debug` flag to `read_uhdm` or `read_systemverilog`. 
This flag also prints the converted Yosys AST.
1. The order of the files matters. Surelog requires that all definitions be already defined when a file is parsed (e.g. if file `B` is defining a type used in file `A`, file `B` needs to be parsed before file `A`).


## Embedding Synlig in a larger cmake-based project

1. An alternative build mechanism defined in the CMakeLists.txt file is provided to allow Synlig to be built part of a larger cmake-based project
Simply add_subsystem(synlig) in your parent CMake. See CMakeLists.txt for compilation options (With or without vendored Yosys and Surelog).
1. To test locally this build system: make -f cmake-makefile


