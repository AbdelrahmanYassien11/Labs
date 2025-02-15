class predictor#(type T = int) extends predictor_base#(T);

	T input_item, predicted_item;

	function new(virtual alu_f v_inf, mailbox #(T) inputMonitor_to_predictor, mailbox #(T) predictor_to_comparator);
		super.new(v_inf, inputMonitor_to_predictor, predictor_to_comparator);
	 	predicted_item = new();
	endfunction 

	task execute();
		forever begin
			input_item = new();
			inputMonitor_to_predictor.get(input_item);
			$display("[PREDICTOR]: RECIEVED_ITEM: %0s",input_item.input2string());
			predict();
			predictor_to_comparator.put(predicted_item);
			$display("[PREDICTOR]: SENT_ITEM: %0s",predicted_item.output2string());
		end
	endtask : execute


	function void predict ();
		bit [1:0] a_b_en = {input_item.a_en, input_item.b_en};
		if(~input_item.rst_n) begin
			predicted_item.C = 0;
		end
		else if(input_item.ALU_en) begin
			case(a_b_en)
				A_OFF_B_OFF: predicted_item.C = predicted_item.C;
				A_ON_B_OFF: begin
					case(input_item.a_op)
						0: predicted_item.C = input_item.A + input_item.B;
						1: predicted_item.C = input_item.A - input_item.B;
						2: predicted_item.C = input_item.A ^ input_item.B;
						3: predicted_item.C = input_item.A & input_item.B;
						4: predicted_item.C = input_item.A & input_item.B;
						5: predicted_item.C = input_item.A | input_item.B;
						6: predicted_item.C = ~(input_item.A ^input_item.B);
						7: $display("[PREDICTOR]: a_op: This case shouldn't be hit");
					endcase // input_item.a_op
				end
				A_OFF_B_ON: begin
					case(input_item.b_op)
						0: predicted_item.C = ~(input_item.A & input_item.B);
						1: predicted_item.C = input_item.A + input_item.B;
						2: predicted_item.C = input_item.A + input_item.B;
						3: $display("[PREDICTOR]: b_op: This case shouldn't be hit");
					endcase // b_op
				end
				A_ON_B_ON: begin
					case(input_item.b_op)
						0: predicted_item.C = input_item.A ^ input_item.B;
						1: predicted_item.C = ~(input_item.A ^ input_item.B);
						2: predicted_item.C = input_item.A - 1;
						3: predicted_item.C = input_item.B + 2;
					endcase // b_op
				end
				default: $display("how did you reach here?");
			endcase // a_b_en
		end

	endfunction : predict

endclass