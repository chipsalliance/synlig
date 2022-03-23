yosys-uhdm-plugin-integration
=============================
Repository for testing integration between Yosys, systemverilog-plugin and Surelog.

Setup
-----

Install dependencies
^^^^^^^^^^^^^^^^^^^^

.. code-block:: bash

   apt install -y g++-9 build-essential cmake tclsh ant default-jre swig google-perftools libgoogle-perftools-dev python3 python3-dev uuid uuid-dev tcl-dev flex libfl-dev git pkg-config libreadline-dev bison libffi-dev wget


Build required binaries
^^^^^^^^^^^^^^^^^^^^^^^

You can build all required binaries using provided ``build_binaries.sh`` script. This script will build Surelog, Yosys and the systemverilog-plugin and place them into ``image`` folder. You need to add this folder into your ``PATH`` variable to make sure you are using correct versions of the binaries.

.. code-block:: bash

   #Make sure submodules are inited and updated to the latest version
   git submodule update --init --recursive
   ./build_binaries.sh
   export PATH=`pwd`/image/bin:$PATH


Usage
-----

Loading systemverilog-plugin into Yosys
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

In order to use the systemverilog plugin in Yosys, you need to first load it inside Yosys. This can be done by executing ``plugin -i systemverilog`` in Yosys prompt. After it's loaded, Yosys is extended with 2 additional commands:

* ``read_systemverilog [options] [filenames]`` - reads SystemVerilog files directly in Yosys. It executes Surelog with provided filenames and converts them (in memory) into UHDM file. This UHDM file is converted into Yosys AST. Note: arguments to this command should be exactly the same as for Surelog binary.
* ``read_uhdm  [options] [filename]`` - reads UHDM file generated using Surelog and converts it into Yosys AST (more information about conversion can be found: `here <https://github.com/chipsalliance/UHDM-integration-tests#uhdm-yosys>`_).

.. code-block:: bash

   yosys
   plugin -i systemverilog
   help read_systemverilog
   help read_uhdm

Generating UHDM file
^^^^^^^^^^^^^^^^^^^^

UHDM file can be generated directly using Surelog or SystemVerilog files can be converted to UHDM using Yosys ``read_systemverilog`` command. The ``read_systemverilog`` command acts as a wrapper around Surelog binary. It accepts the same arguments as Surelog and executes Surelog beneath it. More information about Surelog usage can be found `here <https://github.com/chipsalliance/Surelog#usage>`_.

Quick start example
^^^^^^^^^^^^^^^^^^^

In minimal example we need to first convert SystemVerilog file into UHDM using Surelog and then read it into Yosys.

.. code-block:: bash

   surelog -parse UHDM-integration-tests/tests/onenet/top.sv
   yosys -p "plugin -i systemverilog" -p "read_uhdm slpp_all/surelog.uhdm"

This is equivalent to:

.. code-block:: bash

   yosys -p "plugin -i systemverilog" -p "read_systemverilog UHDM-integration-tests/tests/onenet/top.sv"

After loading it into Yosys, you can process it further using regular Yosys commands.

General & debugging tips
------------------------

#. ``systemverilog-plugin`` needs to be compiled with the same version of the Surelog, that was used to generate UHDM file. When you are updating Surelog version, you also need to recompile yosys-f4pga-plugins.
#. You can print the UHDM tree by adding ``-debug`` flag to ``read_uhdm`` or ``read_systemverilog``. This flag also prints the converted Yosys AST.
#. Order of the files matters. Surelog requires that all definitions need to be already defined when file is parsed (if file ``B`` is defining type used in file ``A``, file ``B`` needs to be parsed before file ``A``).
