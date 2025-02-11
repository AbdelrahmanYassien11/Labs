module alu(
	input rst_n, clk, ALU_en,
	input [INPUT_WIDTH-1:0] A, B,
	input a_en, b_en,
	input [2:0] a_op, 
	input [1:0] b_op,
	output C
);

	wire [1:0] a_b_en;
	assign a_b_en = {a_en, b_en};

	always@(posedge clk or negedge rst_n)begin
		if(~rst_n)begin
			C <= 0;
		end
		else if (ALU_en) begin
			case(a_b_en)
				A_OFF_B_OFF: C <= C;
				A_ON_B_OFF: begin
					case(a_op)
						0: C <= A + B;
						1: C <= A - B;
						2: C <= A ^ B;
						3: C <= A & B;
						4: C <= A & B;
						5: C <= A | B;
						6: C <= ~(A ^ B);
						7: $display("enta bt3ml eh ya gd3 enta a_op");
					endcase							
				end
				A_OFF_B_ON: begin
					case(b_op)
						0: C <= ~(A & B);
						1: C <= A + B;
						2: C <= A + B;
						3: $display("enta bt3ml eh ya gd3 enta b_op");
					endcase					
				end
				A_ON_B_ON: begin
					case(b_op)
						0: C <= A ^ B;
						1: C <= ~(A ^ B);
						2: C <= A - 1;
						3: C <= B + 2;
					endcase
				end 
			endcase
		end
	end

endmodule
//0101 + 0101 = 1010; ~? 0101; nand? ~0101 1010