module prim_ram_2p (
	clk_a_i,
	clk_b_i,
	a_req_i,
	a_write_i,
	a_addr_i,
	a_wdata_i,
	a_wmask_i,
	a_rdata_o,
	b_req_i,
	b_write_i,
	b_addr_i,
	b_wdata_i,
	b_wmask_i,
	b_rdata_o
);
	parameter signed [31:0] Width = 32;
	parameter signed [31:0] Depth = 128;
	parameter signed [31:0] DataBitsPerMask = 1;
	parameter _sv2v_width_MemInitFile = 1;
	parameter [_sv2v_width_MemInitFile - 1:0] MemInitFile = "";
	localparam signed [31:0] Aw = $clog2(Depth);
	input clk_a_i;
	input clk_b_i;
	input a_req_i;
	input a_write_i;
	input [Aw - 1:0] a_addr_i;
	input [Width - 1:0] a_wdata_i;
	input wire [Width - 1:0] a_wmask_i;
	output wire [Width - 1:0] a_rdata_o;
	input b_req_i;
	input b_write_i;
	input [Aw - 1:0] b_addr_i;
	input [Width - 1:0] b_wdata_i;
	input wire [Width - 1:0] b_wmask_i;
	output wire [Width - 1:0] b_rdata_o;
	localparam integer prim_pkg_ImplGeneric = 0;
	parameter integer Impl = prim_pkg_ImplGeneric;
	generate
			prim_xilinx_ram_1p #(
				.Width(Width),
				.Depth(Depth)
			) u_impl_xilinx_1(
				.clk_a_i(clk_a_i),
				.a_req_i(a_req_i),
				.a_write_i(a_write_i),
				.a_addr_i(a_addr_i),
				.a_wdata_i(a_wdata_i),
				.a_rdata_o(a_rdata_o)
			);
			prim_xilinx_ram_1p #(
				.Width(Width),
				.Depth(Depth)
			) u_impl_xilinx_2(
				.clk_a_i(clk_b_i),
				.a_req_i(b_req_i),
				.a_write_i(b_write_i),
				.a_addr_i(b_addr_i),
				.a_wdata_i(b_wdata_i),
				.a_rdata_o(b_rdata_o)
			);
	endgenerate
endmodule
