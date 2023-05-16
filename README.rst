SystemVerilog support for Yosys
===============================

This repository puts together all the moving parts needed to get SystemVerilog support enabled in Yosys.

Installation
------------

Before installing the plugin, check that yosys is installed and correctly configured:

.. code-block:: bash
   :name: check-yosys

   yosys -version
   yosys-config --help

The required yosys version is 0.10 or later.
If you don't have yosys, skip to the next section ``Installation from source`` to build yosys from the source or if you are working on Debian-based Linux distributions:

* Ubuntu 22.04 LTS (Jammy Jellyfish) or higher:

.. code-block:: bash
   :name: install-yosys-ubuntu

   apt install -y wget
   wget https://launchpad.net/ubuntu/+source/yosys/0.18-1/+build/24132080/+files/yosys-dev_0.18-1_amd64.deb
   wget https://launchpad.net/ubuntu/+source/yosys/0.18-1/+build/24132080/+files/yosys_0.18-1_amd64.deb
   apt install -y ./yosys_0.18-1_amd64.deb ./yosys-dev_0.18-1_amd64.deb

* Debian Sid or higher:

.. code-block:: bash
   :name: install-yosys-debian

   apt install -y yosys yosys-dev

If you are sure yosys is installed and configured, you should download and unpack the latest version of the plugin:

.. code-block:: bash
   :name: download-plugin

   apt install -y curl jq tar wget
   curl https://api.github.com/repos/antmicro/yosys-systemverilog/releases/latest | jq .assets[1] | grep "browser_download_url" | grep -Eo 'https://[^\"]*' | xargs wget -O - | tar -xz

After downloading the plugin, the next step is to install plugin with superuser privileges:

.. code-block:: bash
   :name: install-plugin

   ./install_plugin.sh

The plugin is now ready for use and you can go to the ``Usage`` section of this documentation for information on how to load the plugin into yosys.

Installation from source
------------------------

Install dependencies
^^^^^^^^^^^^^^^^^^^^

.. code-block:: bash
   :name: dependencies

   apt install -y gcc-9 g++-9 build-essential cmake tclsh ant default-jre swig google-perftools libgoogle-perftools-dev python3 python3-dev python3-pip uuid uuid-dev tcl-dev flex libfl-dev git pkg-config libreadline-dev bison libffi-dev wget
   pip3 install orderedmultidict


Build required binaries
^^^^^^^^^^^^^^^^^^^^^^^

You can build all required binaries using provided ``build_binaries.sh`` script. This script will build Surelog, Yosys and the systemverilog-plugin and place them into ``image`` folder. You need to add this folder into your ``PATH`` variable to make sure you are using correct versions of the binaries.

.. code-block:: bash
   :name: build-binaries

   #Make sure submodules are inited and updated to the latest version
   git submodule update --init --recursive
   ./build_binaries.sh

To use yosys built from a submodule, make sure to either use absolute paths, or update the ``PATH`` variable before use.

.. code-block:: bash
   :name: path-setup

   export PATH=`pwd`/image/bin:$PATH


Usage
-----

Loading systemverilog-plugin into Yosys
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Yosys can now be started by executing the ``yosys`` command.
In order to use the systemverilog plugin in Yosys, you need to first load it inside Yosys. This can be done in Yosys prompt by executing the following commands:

.. code-block:: tcl
   :name: load-plugin

   plugin -i systemverilog
   help read_systemverilog
   help read_uhdm
   exit

After it's loaded, Yosys is extended with 2 additional commands:

* ``read_systemverilog [options] [filenames]`` - reads SystemVerilog files directly in Yosys. It executes Surelog with provided filenames and converts them (in memory) into UHDM file. This UHDM file is converted into Yosys AST. Note: arguments to this command should be exactly the same as for Surelog binary.
* ``read_uhdm  [options] [filename]`` - reads UHDM file generated using Surelog and converts it into Yosys AST (more information about conversion can be found: `here <https://github.com/chipsalliance/UHDM-integration-tests#uhdm-yosys>`_).

Generating UHDM file
^^^^^^^^^^^^^^^^^^^^

UHDM file can be generated directly using Surelog or SystemVerilog files can be converted to UHDM using Yosys ``read_systemverilog`` command. The ``read_systemverilog`` command acts as a wrapper around Surelog binary. It accepts the same arguments as Surelog and executes Surelog beneath it. More information about Surelog usage can be found `in its own README file <https://github.com/chipsalliance/Surelog#usage>`_.

Quick start examples
^^^^^^^^^^^^^^^^^^^^

As a simple example, we run Verilog code synthesis using the plugin.

.. code-block:: bash
   :name: example-verilog

   yosys -p "plugin -i systemverilog" -p "read_systemverilog yosys-f4pga-plugins/systemverilog-plugin/tests/counter/counter.v"

In the second example, we need to first convert SystemVerilog file into UHDM using Surelog and then read it into Yosys.

.. code-block:: bash
   :name: example-uhdm-ver1

   surelog -parse UHDM-integration-tests/tests/onenet/top.sv
   yosys -p "plugin -i systemverilog" -p "read_uhdm slpp_all/surelog.uhdm"

This is equivalent to:

.. code-block:: bash
   :name: example-uhdm-ver2

   yosys -p "plugin -i systemverilog" -p "read_systemverilog UHDM-integration-tests/tests/onenet/top.sv"

After loading it into Yosys, you can process it further using regular Yosys commands.

Example for parsing multiple files
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
To parse a multi-file with the ``read_systemverilog`` command, all files have to be listed at once. This can be troublesome for larger designs. To mitigate this issue, the plugin supports a flow that allows users to pass files and link them separately. Files can be loaded one by one using  ``-defer`` flag. When all files have been uploaded, you should call ``read_systemverilog -link`` to elaborate them. The described flow would looks like below:

.. code-block:: tcl
   :name: example-multiple-files

    plugin -i systemverilog
    # Read each file separately
    read_systemverilog -defer yosys-f4pga-plugins/systemverilog-plugin/tests/separate-compilation/separate-compilation.v
    read_systemverilog -defer yosys-f4pga-plugins/systemverilog-plugin/tests/separate-compilation/separate-compilation-buf.sv
    read_systemverilog -defer yosys-f4pga-plugins/systemverilog-plugin/tests/separate-compilation/separate-compilation-pkg.sv
    # Finish reading files, elaborate the design
    read_systemverilog -link
    # Continue Yosys flow...
    exit

The :code:`-defer` flag is experimental.
If you encounter any problems with it, please compare the results with a single `read_systemverilog` command,
check the `open issues <https://github.com/chipsalliance/yosys-f4pga-plugins/issues>`_, and open a new issue if needed.

Testing in CI/Github Actions
----------------------------

Using dedicated branch
^^^^^^^^^^^^^^^^^^^^^^

Create a new branch and point submodules to revisions with your changes. Then pick one of the following methods.

Create a Pull Request
"""""""""""""""""""""

Just that. Create a (WIP) Pull Request using your new branch.

Start a workflow manually (using Github Web UI)
"""""""""""""""""""""""""""""""""""""""""""""""

In Github Web UI, on the repository page:

- Open the "Actions" tab.
- Select "main" on the Actions list on the left.
- At the top of the workflows list click the "Run workflow" button.
- Select your branch in the "Use workflow from" dropdown.
- Click the "Run workflow" button.

Start a workflow manually (using Github CLI)
""""""""""""""""""""""""""""""""""""""""""""

.. code-block:: bash
   :name: gh-cli-start-workflow

   gh workflow run main --ref $YOUR_BRANCH_NAME

Overriding plugins and UHDM-integration-tests submodule revisions
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

This method can be used to test changes limited to `yosys-f4pga-plugins` or `UHDM-integration-tests` submodules.

- Perform steps from "Start a workflow manually (using Github Web UI)" above, but:

  - Select "master" (or any other branch with submodule revisions you would like to use in the CI) in the "Use workflow from" dropdown.
  - In the same pop-up, under "yosys-f4pga-plugins branch or URL", type the name of the branch from https://github.com/antmicro/yosys-f4pga-plugins/, or a Github URL to a revision (in the form `https://github.com/<USER>/<REPO>/tree/<REVISION>`) from any repository. The typed value can skip `https://github.com` prefix (but not the `/`). The passed revision will be checked out in `yosys-f4pga-plugins` submodule.
    "UHDM-integration-tests branch or URL" field works in the same way.

- Alternatively, use Github CLI:

  .. code-block:: bash
     :name: gh-cli-start-workflow-with-plugins-branch

     gh workflow run main --ref master \
             -f plugins_branch=$PLUGINS_BRANCH_NAME_OR_URL \
             -f uhdm_tests_branch=$UHDM_TESTS_BRANCH_NAME_OR_URL

Testing locally
---------------

Formal Verification
^^^^^^^^^^^^^^^^^^^

Formal verification tests are started using ``run_fv_tests.mk``, either as an executable or by using make:

.. code-block::
   :name: run-fv-tests-exec

   ./run_fv_tests.mk [make_args...] \
         TEST_SUITE_DIR:=<test_suite_dir> \
         [TEST_SUITE_NAME:=<test_suite_name>] \
         [target...]

.. code-block::
   :name: run-fv-tests-make

   make -f ./run_fv_tests.mk [make_args] [args...] [target...]

* ``test_suite_dir`` - Path to a tests directory (e.g. ``./yosys/tests``). Required by all targets except ``help``.
* ``test_suite_name`` - When specified, it is used as a name of a directory inside ``./build/`` where results are stored. Otherwise results are stored directly inside ``./build/`` directory.

``yosys`` and ``sv2v`` must be present in one of ``PATH`` directories.
For other dependencies please see ``.github/workflows/formal-verification.yml`` file.

Available Targets
"""""""""""""""""

* ``help`` - Prints help.
* ``list`` - Prints tests available in specified ``test_suite_dir``. Each test from the list is itself a valid target.
* ``test`` - Runs all tests from ``test_suite_dir``.

General & debugging tips
------------------------

#. ``systemverilog-plugin`` needs to be compiled with the same version of the Surelog, that was used to generate UHDM file. When you are updating Surelog version, you also need to recompile yosys-f4pga-plugins.
#. You can print the UHDM tree by adding ``-debug`` flag to ``read_uhdm`` or ``read_systemverilog``. This flag also prints the converted Yosys AST.
#. Order of the files matters. Surelog requires that all definitions need to be already defined when file is parsed (if file ``B`` is defining type used in file ``A``, file ``B`` needs to be parsed before file ``A``).
