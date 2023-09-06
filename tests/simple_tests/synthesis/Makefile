all:: .cmake .surelog .uhdm .yosys .unisim

clean::
	@true

# ----------------------------------- DFF ----------------------------------
slpp_all/surelog.uhdm: dff.sv
	PATH="$(PWD)/../../image/bin:$$PATH" \
		surelog -parse -sverilog -d coveruhdm $<

top.edif: slpp_all/surelog.uhdm
	$(PWD)/../../yosys/yosys \
		-p 'read_uhdm $<' \
		-p 'synth_xilinx -iopad -family xc7' \
		-p 'write_verilog -nodec -nohex -noattr top.premap.v' \
		-p 'write_edif -pvector bra top.edif'

top.edif.v: top.edif
	./edif2verilog.py # FIXME: hardcoded paths, deps on python3-ply

sim: top.edif.v dff_tb.v
	iverilog -s sim -o $@ $^ \
		unisim/verilog/src/glbl.v \
		unisim/verilog/src/unisims/GND.v \
		unisim/verilog/src/unisims/VCC.v  \
		unisim/verilog/src/unisims/BUFG.v \
		unisim/verilog/src/unisims/FDRE.v \
		unisim/verilog/src/unisims/IBUF.v \
		unisim/verilog/src/unisims/OBUF.v

dump_dff.vcd: sim
	vvp $<

clean::
	rm -f dump_dff.vcd sim top.edif.v top.edif
# ----------------------------------- DFF ----------------------------------

# ---------------------------------- UNISIM --------------------------------
.unisim:
	git clone https://github.com/Xilinx/XilinxUnisimLibrary.git unisim && touch $@
# ---------------------------------- UNISIM --------------------------------

# ---------------------------------- CMAKE ---------------------------------
CMAKE_VERSION = 3.18.1
CMAKE_URL = https://github.com/Kitware/CMake/releases/download/v$(CMAKE_VERSION)/cmake-$(CMAKE_VERSION).tar.gz

cmake-src.tar.gz:
	wget -c -O $@ $(CMAKE_URL) && touch $@

cmake-src/.dir:
	mkdir `dirname $@` && touch $@

cmake-src/.unpack: cmake-src.tar.gz cmake-src/.dir
	tar --strip-component=1 -xf $< -C `dirname $@` && touch $@

cmake-src/.conf: cmake-src/.unpack
	(cd cmake-src && ./bootstrap \
		--prefix=$(PWD)/../../image \
		--parallel=`nproc`) && touch $@

cmake-src/.build: cmake-src/.conf
	(cd cmake-src && make -j`nproc`) && touch $@

cmake-src/.install: cmake-src/.build
	(cd cmake-src && make install) && touch $@

.cmake: cmake-src/.install
# ---------------------------------- CMAKE ---------------------------------

# --------------------------------- SURELOG --------------------------------
$(PWD)/../../third_party/surelog/CMakeLists.txt:
	(cd ../../ && git submodule update --init --recursive Surelog && touch $@)

.surelog: $(PWD)/../../third_party/surelog/CMakeLists.txt .cmake
	PATH="$(PWD)/../../image/bin:$$PATH" make -C ../../third_party/surelog \
		PREFIX=$(PWD)/../../image release install -j`nproc` && touch $@
# --------------------------------- SURELOG --------------------------------

# ---------------------------------- UHDM ----------------------------------
$(PWD)/../../UHDM/CMakeLists.txt:
	(cd ../../ && git submodule update --init --recursive UHDM && touch $@)

.uhdm.patch: $(PWD)/../../UHDM/CMakeLists.txt
	(cd ../../UHDM && git apply < ../UHDM.patch) && touch $@

.uhdm: .uhdm.patch .surelog .cmake
	mkdir -p $(PWD)/../../UHDM/build && \
	(cd $(PWD)/../../UHDM/build && \
		PATH="$(PWD)/../../image/bin:$$PATH" cmake \
		-DCMAKE_INSTALL_PREFIX=$(PWD)/../../image \
		-D_GLIBCXX_DEBUG=1 \
		-DCMAKE_BUILD_TYPE=Release \
		-DCMAKE_CXX_FLAGS='-D_GLIBCXX_USE_CXX11_ABI=1 -DWITH_LIBCXX=Off' \
		../) && \
	$(MAKE) -C $(PWD)/../../UHDM install -j`nproc` && touch $@
# ---------------------------------- UHDM ----------------------------------

# ---------------------------------- YOSYS ---------------------------------
$(PWD)/../../yosys/Makefile:
	(cd ../../ && git submodule update --init --recursive yosys && touch $@)

yosys/yosys:
	$(MAKE) -C $(PWD)/../../yosys -j`nproc`

.yosys: yosys/yosys
	touch $@
# ---------------------------------- YOSYS ---------------------------------
