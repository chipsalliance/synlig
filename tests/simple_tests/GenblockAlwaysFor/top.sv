typedef enum integer { pN = 0, pB = 1, pO = 2, pF = 3 } p_e;
typedef enum logic [6:0] { ALU_N, ALU_B, ALU_H, ALU_BFP } op;
module top #(parameter p_e p = pF) (input op i);
	if (p != pN) begin : gen1
		if (p == pO || p == pF) begin : gen2
			logic  [7:0][2:0] sel_n;
			logic  [3:0][1:0] sel_b;
			logic  [1:0][0:0] sel_h;

			logic [7:0][2:0] sel;

			always_comb begin
				unique case (i)
					ALU_N: begin
						sel = sel_n;
					end

					ALU_B: begin
						for (int b = 0; b < 4; b++) begin
							sel[b*2 +  0] =   {sel_b[b], 1'b0};
							sel[b*2 +  1] =   {sel_b[b], 1'b1};
						end
					end

					ALU_H: begin
						for (int h = 0; h < 2; h++) begin
							sel[h*4 +  0] =   {sel_h[h], 2'b00};
							sel[h*4 +  1] =   {sel_h[h], 2'b01};
							sel[h*4 +  2] =   {sel_h[h], 2'b10};
							sel[h*4 +  3] =   {sel_h[h], 2'b11};
						end
					end

					default: begin
						sel = sel_n;
					end
				endcase
			end
		end
	end
endmodule
