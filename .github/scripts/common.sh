function enable_vivado() {
    set -e
    echo
    echo "======================================="
    echo "Creating Vivado Symbolic Link"
    echo "---------------------------------------"
    ln -s /mnt/aux/Xilinx /opt/Xilinx
    ls /opt/Xilinx/Vivado
    source /opt/Xilinx/Vivado/$1/settings64.sh
    # close stdin in case vivado -version fails
    vivado -version <&-
    echo "Vivado exit code: $?"
}
