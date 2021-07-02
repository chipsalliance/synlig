module padring (
	clk_pad_i,
	clk_usb_48mhz_pad_i,
	rst_pad_ni,
	clk_o,
	clk_usb_48mhz_o,
	rst_no,
	mio_pad_io,
	dio_pad_io,
	mio_in_o,
	mio_out_i,
	mio_oe_i,
	dio_in_o,
	dio_out_i,
	dio_oe_i,
	mio_attr_i,
	dio_attr_i
);
	localparam signed [31:0] NDioPads = 15;
	localparam signed [31:0] NMioPads = 32;
	localparam signed [31:0] AttrDw = 10;
	localparam [6:0] PADCTRL_REGEN_OFFSET = 7'h00;
	localparam [6:0] PADCTRL_DIO_PADS0_OFFSET = 7'h04;
	localparam [6:0] PADCTRL_DIO_PADS1_OFFSET = 7'h08;
	localparam [6:0] PADCTRL_DIO_PADS2_OFFSET = 7'h0c;
	localparam [6:0] PADCTRL_DIO_PADS3_OFFSET = 7'h10;
	localparam [6:0] PADCTRL_DIO_PADS4_OFFSET = 7'h14;
	localparam [6:0] PADCTRL_MIO_PADS0_OFFSET = 7'h18;
	localparam [6:0] PADCTRL_MIO_PADS1_OFFSET = 7'h1c;
	localparam [6:0] PADCTRL_MIO_PADS2_OFFSET = 7'h20;
	localparam [6:0] PADCTRL_MIO_PADS3_OFFSET = 7'h24;
	localparam [6:0] PADCTRL_MIO_PADS4_OFFSET = 7'h28;
	localparam [6:0] PADCTRL_MIO_PADS5_OFFSET = 7'h2c;
	localparam [6:0] PADCTRL_MIO_PADS6_OFFSET = 7'h30;
	localparam [6:0] PADCTRL_MIO_PADS7_OFFSET = 7'h34;
	localparam [6:0] PADCTRL_MIO_PADS8_OFFSET = 7'h38;
	localparam [6:0] PADCTRL_MIO_PADS9_OFFSET = 7'h3c;
	localparam [6:0] PADCTRL_MIO_PADS10_OFFSET = 7'h40;
	localparam signed [31:0] PADCTRL_REGEN = 0;
	localparam signed [31:0] PADCTRL_DIO_PADS0 = 1;
	localparam signed [31:0] PADCTRL_DIO_PADS1 = 2;
	localparam signed [31:0] PADCTRL_DIO_PADS2 = 3;
	localparam signed [31:0] PADCTRL_DIO_PADS3 = 4;
	localparam signed [31:0] PADCTRL_DIO_PADS4 = 5;
	localparam signed [31:0] PADCTRL_MIO_PADS0 = 6;
	localparam signed [31:0] PADCTRL_MIO_PADS1 = 7;
	localparam signed [31:0] PADCTRL_MIO_PADS2 = 8;
	localparam signed [31:0] PADCTRL_MIO_PADS3 = 9;
	localparam signed [31:0] PADCTRL_MIO_PADS4 = 10;
	localparam signed [31:0] PADCTRL_MIO_PADS5 = 11;
	localparam signed [31:0] PADCTRL_MIO_PADS6 = 12;
	localparam signed [31:0] PADCTRL_MIO_PADS7 = 13;
	localparam signed [31:0] PADCTRL_MIO_PADS8 = 14;
	localparam signed [31:0] PADCTRL_MIO_PADS9 = 15;
	localparam signed [31:0] PADCTRL_MIO_PADS10 = 16;
	localparam [67:0] PADCTRL_PERMIT = {4'b0001, 4'b1111, 4'b1111, 4'b1111, 4'b1111, 4'b1111, 4'b1111, 4'b1111, 4'b1111, 4'b1111, 4'b1111, 4'b1111, 4'b1111, 4'b1111, 4'b1111, 4'b1111, 4'b0111};
	parameter [NMioPads - 1:0] ConnectMioIn = 1'b1;
	parameter [NMioPads - 1:0] ConnectMioOut = 1'b1;
	parameter [NDioPads - 1:0] ConnectDioIn = 1'b1;
	parameter [NDioPads - 1:0] ConnectDioOut = 1'b1;
	parameter [(NMioPads * 2) - 1:0] MioPadVariant = 1'b0;
	parameter [(NDioPads * 2) - 1:0] DioPadVariant = 1'b0;
	input wire clk_pad_i;
	input wire clk_usb_48mhz_pad_i;
	input wire rst_pad_ni;
	output wire clk_o;
	output wire clk_usb_48mhz_o;
	output wire rst_no;
	inout wire [NMioPads - 1:0] mio_pad_io;
	inout wire [NDioPads - 1:0] dio_pad_io;
	output wire [NMioPads - 1:0] mio_in_o;
	input [NMioPads - 1:0] mio_out_i;
	input [NMioPads - 1:0] mio_oe_i;
	output wire [NDioPads - 1:0] dio_in_o;
	input [NDioPads - 1:0] dio_out_i;
	input [NDioPads - 1:0] dio_oe_i;
	input [(NMioPads * AttrDw) - 1:0] mio_attr_i;
	input [(NDioPads * AttrDw) - 1:0] dio_attr_i;
	wire clk;
	wire clk_usb_48mhz;
	wire rst_n;
	assign clk = clk_pad_i;
	assign clk_usb_48mhz = clk_usb_48mhz_pad_i;
	assign rst_n = rst_pad_ni;
	generate
		genvar k;
		for (k = 0; k < NMioPads; k = k + 1) begin : gen_mio_pads
			if (ConnectMioIn[k] && ConnectMioOut[k]) begin : gen_mio_inout
				prim_pad_wrapper #(
					.AttrDw(AttrDw),
					.Variant(MioPadVariant[k * 2+:2])
				) i_mio_pad(
					.inout_io(mio_pad_io[k]),
					.in_o(mio_in_o[k]),
					.ie_i(1'b1),
					.out_i(mio_out_i[k]),
					.oe_i(mio_oe_i[k]),
					.attr_i(mio_attr_i[k * AttrDw+:AttrDw]),
					.warl_o()
				);
			end
			else if (ConnectMioOut[k]) begin : gen_mio_output
				prim_pad_wrapper #(
					.AttrDw(AttrDw),
					.Variant(MioPadVariant[k * 2+:2])
				) i_mio_pad(
					.inout_io(mio_pad_io[k]),
					.in_o(),
					.ie_i(1'b0),
					.out_i(mio_out_i[k]),
					.oe_i(mio_oe_i[k]),
					.attr_i(mio_attr_i[k * AttrDw+:AttrDw]),
					.warl_o()
				);
				assign mio_in_o[k] = 1'b0;
			end
			else if (ConnectMioIn[k]) begin : gen_mio_input
				prim_pad_wrapper #(
					.AttrDw(AttrDw),
					.Variant(MioPadVariant[k * 2+:2])
				) i_mio_pad(
					.inout_io(mio_pad_io[k]),
					.in_o(mio_in_o[k]),
					.ie_i(1'b1),
					.out_i(1'b0),
					.oe_i(1'b0),
					.attr_i(mio_attr_i[k * AttrDw+:AttrDw]),
					.warl_o()
				);
				wire unused_out;
				wire unused_oe;
				assign unused_out = mio_out_i[k];
				assign unused_oe = mio_oe_i[k];
			end
			else begin : gen_mio_tie_off
				/*wire unused_out;
				wire unused_oe;
				wire unused_pad;
				wire [AttrDw - 1:0] unused_attr;*/
				assign mio_pad_io[k] = 1'b0;
				/*assign unused_pad = mio_pad_io[k];
				assign unused_out = mio_out_i[k];
				assign unused_oe = mio_oe_i[k];
				assign unused_attr = mio_attr_i[k * AttrDw+:AttrDw];*/
				assign mio_in_o[k] = 1'b0;
			end
		end
	endgenerate
	generate
		for (k = 0; k < NDioPads; k = k + 1) begin : gen_dio_pads
			if (ConnectDioIn[k] && ConnectDioOut[k]) begin : gen_dio_inout
				prim_pad_wrapper #(
					.AttrDw(AttrDw),
					.Variant(DioPadVariant[k * 2+:2])
				) i_dio_pad(
					.inout_io(dio_pad_io[k]),
					.in_o(dio_in_o[k]),
					.ie_i(1'b1),
					.out_i(dio_out_i[k]),
					.oe_i(dio_oe_i[k]),
					.attr_i(dio_attr_i[k * AttrDw+:AttrDw]),
					.warl_o()
				);
			end
			else if (ConnectDioOut[k]) begin : gen_dio_output
				prim_pad_wrapper #(
					.AttrDw(AttrDw),
					.Variant(DioPadVariant[k * 2+:2])
				) i_dio_pad(
					.inout_io(dio_pad_io[k]),
					.in_o(),
					.ie_i(1'b0),
					.out_i(dio_out_i[k]),
					.oe_i(dio_oe_i[k]),
					.attr_i(dio_attr_i[k * AttrDw+:AttrDw]),
					.warl_o()
				);
				assign dio_in_o[k] = 1'b0;
			end
			else if (ConnectDioIn[k]) begin : gen_dio_input
				prim_pad_wrapper #(
					.AttrDw(AttrDw),
					.Variant(DioPadVariant[k * 2+:2])
				) i_dio_pad(
					.inout_io(dio_pad_io[k]),
					.in_o(dio_in_o[k]),
					.ie_i(1'b1),
					.out_i(1'b0),
					.oe_i(1'b0),
					.attr_i(dio_attr_i[k * AttrDw+:AttrDw]),
					.warl_o()
				);
				wire unused_out;
				wire unused_oe;
				assign unused_out = dio_out_i[k];
				assign unused_oe = dio_oe_i[k];
			end
			else begin : gen_dio_tie_off
				/*wire unused_out;
				wire unused_oe;
				wire unused_pad;
				wire [AttrDw - 1:0] unused_attr;*/
				assign dio_pad_io[k] = 1'b0;
				/*assign unused_pad = dio_pad_io[k];
				assign unused_out = dio_out_i[k];
				assign unused_oe = dio_oe_i[k];
				assign unused_attr = dio_attr_i[k * AttrDw+:AttrDw];*/
				assign dio_in_o[k] = 1'b0;
			end
		end
	endgenerate
endmodule
