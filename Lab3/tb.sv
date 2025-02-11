module tb();


mailbox #(int) mbx1;
mailbox #(int) mbxa;
mailbox #(int) mbxb;
mailbox #(int) mbxc;

int x;


initial begin
	mbx1 = new(1);
	mbxa = mbx1;
	mbxb = mbx1;
	mbxc = mbxb;
	#1ns;
	mbxa.put(3);
	$display("ATLAS1c");
	mbxc.get(x);
	$display("ATLAS2");
	mbxc.get(x);
	$display("ATLAS3");

end

endmodule : tb


