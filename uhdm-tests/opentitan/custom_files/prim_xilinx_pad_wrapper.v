module prim_xilinx_pad_wrapper (
	inout_io,
	in_o,
	ie_i,
	out_i,
	oe_i,
	attr_i,
	warl_o
);
	parameter signed [31:0] Variant = 0;
	parameter signed [31:0] AttrDw = 10;
	parameter [0:0] WarlOnly = 0;
	inout wire inout_io;
	output wire in_o;
	input ie_i;
	input out_i;
	input oe_i;
	input [AttrDw - 1:0] attr_i;
	output wire [AttrDw - 1:0] warl_o;
	function automatic [AttrDw - 1:0] sv2v_cast_B2A68;
		input reg [AttrDw - 1:0] inp;
		sv2v_cast_B2A68 = inp;
	endfunction
	assign warl_o = sv2v_cast_B2A68(2'h3);
	generate
		if (WarlOnly) begin : gen_warl
			assign inout_io = 1'bz;
			assign in_o = 1'b0;
			wire [AttrDw - 1:0] unused_attr;
			wire unused_ie;
			wire unused_oe;
			wire unused_out;
			wire unused_inout;
			assign unused_ie = ie_i;
			assign unused_oe = oe_i;
			assign unused_out = out_i;
			assign unused_attr = attr_i;
			assign unused_inout = inout_io;
		end
		else begin : gen_pad
			wire od;
			wire inv;
			assign {od, inv} = attr_i[1:0];
			if (AttrDw > 9) begin : gen_unused_attr
				wire [AttrDw - 10:0] unused_attr;
				assign unused_attr = attr_i[AttrDw - 1:9];
			end
			wire in;
			assign in_o = inv ^ in;
			wire oe_n;
			wire out;
			assign out = out_i ^ inv;
			assign oe_n = ~oe_i | (out & od);
			IOBUF i_iobuf(
				.T(oe_n),
				.I(out),
				.O(in),
				.IO(inout_io)
			);
		end
	endgenerate
endmodule
