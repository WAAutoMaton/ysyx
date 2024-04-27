import "DPI-C" function void ebreak();

module EBreak (
		input enable
		);
	always @* begin
		if (enable)
			ebreak();	
	end
endmodule

