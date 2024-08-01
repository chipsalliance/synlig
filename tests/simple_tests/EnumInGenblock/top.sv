module top();
	if (1) begin : n
		typedef enum logic [1:0] {
			ALBL, ALBH, AHBL, AHBH
		} mult_fsm_e;
		mult_fsm_e mult_state_q, mult_state_d;

		logic [1:0] a, b, c;

		always_comb begin
			unique case (mult_state_q)
			ALBL: begin
				a = 0;
				c = ALBH;
			end
			ALBH: begin
				a = 1;
				c = AHBL;
			end
			AHBL: begin
				a = 2;
				c = AHBH;
			end
			AHBH: begin
				a = 3;
				c = ALBL;
			end
			endcase
		end
	end
endmodule
