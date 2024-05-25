import "DPI-C" function void ebreak(input byte code);

module EBreak (
		input enable,
		input [7:0] code
		);
	always @* begin
		if (enable)
			ebreak(code);	
	end
endmodule

