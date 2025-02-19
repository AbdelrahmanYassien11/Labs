module alu #(parameter INPUT_WIDTH = 5, OUTPUT_WIDTH = 6, A_OP_WIDTH = 2, B_OP_WIDTH = 1, EN_WIDTH = 0 ) (
	input wire rst_n, clk, ALU_en,
	input wire signed 		[INPUT_WIDTH-1:0] A, B,
	input wire 				a_en, b_en,
	input wire 				[A_OP_WIDTH:0] a_op, 
	input wire 				[B_OP_WIDTH:0] b_op,
	output reg 				[OUTPUT_WIDTH-1:0] C
);

	localparam A_OFF_B_OFF = 2'b00, A_ON_B_OFF = 2'b10, A_OFF_B_ON = 2'b01, A_ON_B_ON = 2'b11;

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
						default: $display("enta bt3ml eh ya gd3 enta a_op");
					endcase							
				end
				A_OFF_B_ON: begin
					case(b_op)
						0: C <= ~(A & B);
						1: C <= A + B;
						2: C <= A + B;
						default: $display("enta bt3ml eh ya gd3 enta b_op");
					endcase					
				end
				A_ON_B_ON: begin
					case(b_op)
						0: C <= A ^ B;
						1: C <= ~(A ^ B);
						2: C <= A - 1;
						default: C <= B + 2;
					endcase
				end 
			endcase
		end
		else begin
			C <= C;
		end
	end

endmodule
