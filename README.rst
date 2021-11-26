yosys-uhdm-plugin-integration
=============================
Repository for testing integration between Yosys, uhdm-plugin and Surelog.

Setup
-----

Install dependencies
^^^^^^^^^^^^^^^^^^^^

.. code-block:: bash

   apt install -y g++-9 build-essential cmake tclsh ant default-jre swig google-perftools libgoogle-perftools-dev python3 python3-dev uuid uuid-dev tcl-dev flex libfl-dev git pkg-config libreadline-dev bison libffi-dev wget


Build required binaries
^^^^^^^^^^^^^^^^^^^^^^^

You can build all required binaries using provided ``build_binaries.sh`` script. This script will build Surelog, Yosys and uhdm-plugin and place them into ``image`` folder. You need to add this folder into your ``PATH`` variable to make sure you are using correct versions of the binaries.

.. code-block:: bash

   #Make sure submodules are inited and updated to the latest version
   git submodule update --init --recursive
   ./build_binaries.sh
   export PATH=`pwd`/image/bin:$PATH


Usage
-----

Loading uhdm-plugin into Yosys
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

In order to use ``uhdm-plugin`` in Yosys, you need to first load it inside Yosys. This can be done by executing ``plugin -i uhdm`` in Yosys prompt. After loading ``uhdm-plugin``, Yosys is extended with 2 additional commands:

* ``read_uhdm  [options] [filename]`` - reads UHDM file generated using Surelog and converts it into Yosys AST (more information about conversion can be found: `here <https://github.com/chipsalliance/UHDM-integration-tests#uhdm-yosys>`_).
* ``read_verilog_with_uhdm [options] [filenames]`` - reads SystemVerilog files directly in Yosys. It executes Surelog with provided filenames and converts them (in memory) into UHDM file. This UHDM file is converted into Yosys AST. Note: arguments to this command should be exactly the same as for Surelog binary.

.. code-block:: bash

   yosys
   plugin -i uhdm
   help read_uhdm
   help read_verilog_with_uhdm

Generating UHDM file
^^^^^^^^^^^^^^^^^^^^

UHDM file can be generated directly using Surelog or SystemVerilog files can be converted to UHDM using Yosys ``read_verilog_with_uhdm`` command. ``read_verilog_with_uhdm`` commands acts as a wrapper around Surelog binary. It accepts the same arguments as Surelog and executes Surelog beneath it. More information about Surelog usage can be found `here <https://github.com/chipsalliance/Surelog#usage>`_.

Quick start example
^^^^^^^^^^^^^^^^^^^

In minimal example we need to first convert SystemVerilog file into UHDM using Surelog and then read it into Yosys.

.. code-block:: bash

   surelog -parse UHDM-integration-tests/tests/onenet/top.sv
   yosys -p "plugin -i uhdm" -p "read_uhdm slpp_all/surelog.uhdm"

This is equivalent to:

.. code-block:: bash

   yosys -p "plugin -i uhdm" -p "read_verilog_with_uhdm -parse UHDM-integration-tests/tests/onenet/top.sv"

After loading it into Yosys, you can process it further using regular Yosys commands.

General & debugging tips
------------------------

#. ``uhdm-plugin`` needs to be compiled with the same version of the Surelog, that were used to generate UHDM file. When you are updating Surelog version, you also need to recompile yosys-symbiflow-plugins.
#. You can print UHDM tree by adding ``-debug`` flag to ``read_uhdm`` or ``read_verilog_with_uhdm``. This flag also prints converted Yosys AST.
#. Order of the files matters. Surelog requires that all definitions need to be already defined when file is parsed (if file ``B`` is defining type used in file ``A``, file ``B`` needs to be parsed before file ``A``).
