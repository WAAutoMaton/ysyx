module UART_V(
		input valid,
		input [7:0] wdata
		);
	always @(*) begin
	  if (valid) begin 
		$write("%c",wdata);
	  end
	end
endmodule
