# Synlig

![Synlig logo](images/synlig-logo.svg)

Synlig is a SystemVerilog synthesis tool that uses [Surelog](https://github.com/chipsalliance/Surelog) as a SystemVerilog 2017 preprocessor, parser and elaborator, with [Yosys](https://github.com/YosysHQ/yosys) as a framework for synthesis.

## Installation

### Download Synlig

You can download Synlig from the GitHub [release page](https://github.com/chipsalliance/synlig/releases).
To download the latest version, use the following script:

```bash
# TODO: update it after initial release
```
Then, install it with superuser privileges:

```bash
# TODO: update it after initial release
```

Synlig is now ready to be used.
Go to the [Usage](#usage) section of this document to learn how to use it.

### Installation from source

Debian Trixie:

#### Install dependencies

<!-- name="dependencies" -->
``` bash
   apt install -y gcc-11 g++-11 build-essential cmake tclsh ant default-jre swig google-perftools libgoogle-perftools-dev python3 python3-dev python3-pip uuid uuid-dev tcl-dev flex libfl-dev git pkg-config libreadline-dev bison libffi-dev wget python3-orderedmultidict
```

#### Build required binaries

You can build all required binaries using the provided `Makefile`.
`make install` will build Surelog, Yosys and Synlig, and place them in the `out` directory.
You need to add `out/bin` to your `PATH` variable to ensure you are using correct versions of the binaries.

<!-- name="build-binaries" -->
``` bash
   git submodule sync
   git submodule update --init --recursive third_party/{surelog,yosys}
   make install -j$(nproc)
```

To use Synlig, make sure to either use absolute paths, or update the `PATH` variable before use.

<!-- name="path-setup" -->
``` bash
   export PATH=`pwd`/out/current/bin:$PATH
```

## Usage

You can now start Synlig by executing the `synlig` command.
To read SystemVerilog files, use:

* `read_systemverilog [options] [filenames]` - reads SystemVerilog files.
* `read_uhdm  [options] [filename]` - allows reading UHDM files - SystemVerilog files already processed by Surelog.
Afterwards, it works similarly to `read_systemverilog`.

### Quick start examples

#### Counter

Consider the following SystemVerilog code:

<!-- name="counter.sv" -->
``` SystemVerilog
module top (
  input clk,
  output [3:0] led
);
  localparam BITS = 4;
  localparam LOG2DELAY = 22;

  wire bufg;
  BUFG bufgctrl (
      .I(clk),
      .O(bufg)
  );
  reg [BITS+LOG2DELAY-1:0] counter = 0;
  always @(posedge bufg) begin
    counter <= counter + 1;
  end
  assign led[3:0] = counter >> LOG2DELAY;
endmodule
```

Running synthesis using Synlig is very simple:

<!-- name="synthesis example" -->
``` tcl
	> read_systemverilog counter.sv
	1. Executing Verilog with UHDM frontend.
	(...)

	> synth_xilinx
	2. Executing SYNTH_XILINX pass.
	(...)

	Number of wires:                 10
	Number of wire bits:            167
	Number of public wires:           4
	Number of public wire bits:      32
	Number of ports:                  2
	Number of port bits:              5
	Number of memories:               0
	Number of memory bits:            0
	Number of processes:              0
	Number of cells:                 40
	  BUFG                            1
	  CARRY4                          7
	  FDRE                           26
	  IBUF                            1
	  INV                             1
	  OBUF                            4
	(...)

	> write_edif counter.edif
	3. Executing Synlig EDIF backend.
```

As a result, we get a `counter.edif` file that can be further processed to generate the bitstream.

#### Parsing multiple files

To parse a multi-file design with the `read_systemverilog` command, all files have to be listed simultaneously.
This can be troublesome for larger designs.
To mitigate this issue, Synlig supports a flow that allows users to pass files and link them separately.
Files can be loaded one by one using the `-defer` flag.
Once all files are uploaded, you should call `read_systemverilog -link` to elaborate them.
The described flow looks like the following:

<!-- name="example-multiple-files" -->
``` tcl
    # Read each file separately
    read_systemverilog -defer tests/separate_compilation/separate_compilation.v
    read_systemverilog -defer tests/separate_compilation/separate_compilation_buf.sv
    read_systemverilog -defer tests/separate_compilation/separate_compilation_pkg.sv
    # Finish reading files, elaborate the design
    read_systemverilog -link
    # Continue Synlig flow...
    exit
```

The `-defer` flag is experimental.
If you encounter any problems with it, please compare the results with a single `read_systemverilog` command, check the [open issues](https://github.com/chipsalliance/synlig/issues), and open a new issue if required.

## Testing locally

### Formal verification

Synlig runs formal verification tests to make sure it provides results comparable with other synthesis tools.
More information about formal verification can be found in this [README](https://github.com/chipsalliance/synlig/tree/main/tests/formal).

#### Prerequisites

All required prerequisites can be installed by running:

<!-- name="install tools" -->
``` bash
   git submodule update --init --recursive --checkout third_party/{sv2v,eqy,sby,yosys}
   make tools -j $(nproc)
```

#### Running formal verification

To start formal verification tests, use the dedicated script:

<!-- name="run-fv-tests-exec" -->
``` bash
   ./tests/scripts/run_formal.sh --name=<test_suite_name> run
```

To gather formal verification results, run:
``` bash
   ./tests/scripts/run_formal.sh --name=<test_suite_name> gather_results
```

#### Available targets

You can see the available `test_suite_name` options by running:

``` bash
   ./tests/scripts/run_formal.sh --help
```

### Design tests

Synlig is also tested by synthesizing several designs:

* [OpenTitan](https://github.com/lowRISC/opentitan),
* [Ibex](https://github.com/lowRISC/ibex),
* [VeeR](https://github.com/chipsalliance/Cores-VeeR-EH1),
* [BlackParrot](https://github.com/black-parrot/black-parrot).

For more details, check `.github/workflows/large-designs.yml` or run:

``` bash
   ./tests/scripts/run_large_designs.sh --help
```

### Parsing tests

Synlig is additionally tested with parsing tests. For more details check `.github/workflows/parsing-tests.yml` or run:

``` bash
   ./tests/scripts/run_parsing.sh --help
```

## General & debugging tips

1. You can print the UHDM tree by adding the `-debug` flag to `read_uhdm` or `read_systemverilog`.
This flag also prints the converted Yosys AST.
1. The order of the files matters.
Surelog requires all definitions to be already defined when a file is parsed (e.g. if file `B` is defining a type used in file `A`, file `B` needs to be parsed before file `A`).

## Embedding Synlig in a larger cmake-based project

1. An alternative build mechanism defined in the CMakeLists.txt file is provided to allow Synlig to be built as part of a larger cmake-based project.
Simply include `add_subsystem(synlig)` in your parent CMake.
See CMakeLists.txt for compilation options (with or without vendored Yosys and Surelog).
1. To test this build system locally, use `make -f cmake-makefile`.

## Plugin mode

Synlig is also available as a Yosys plugin.
Note that almost all tests are made using the Synlig binary instead of the plugin version, and there is no guarantee that the plugin version will be still developed in the future.

### Installation from source

#### Install dependencies

<!-- name="dependencies" -->
``` bash
   apt install -y gcc-11 g++-11 build-essential cmake tclsh ant default-jre swig google-perftools libgoogle-perftools-dev python3 python3-dev python3-pip uuid uuid-dev tcl-dev flex libfl-dev git pkg-config libreadline-dev bison libffi-dev wget python3-orderedmultidict
```

#### Build required binaries

You can build all required binaries using the provided `Makefile`.
`make plugin` will build Surelog, Yosys and Synlig as a plugin, and place them in the `out` directory.
You need to add `out/bin` to your `PATH` variable to ensure you are using correct versions of the binaries.

<!-- name="build-binaries" -->
``` bash
   git submodule update --init --recursive third_party/{surelog,yosys}
   make plugin -j$(nproc)
```

To use Yosys built from a submodule, make sure to either use absolute paths, or update the `PATH` variable before use.

<!-- name="path-setup" -->
``` bash
   export PATH=`pwd`/out/current/bin:$PATH
```
### Loading Synlig as a plugin into Yosys

You can now start Yosys by executing the `yosys` command.
In order to use the SystemVerilog plugin, you first need to load it in Yosys by executing the following command in Yosys prompt: `plugin -i systemverilog`.
