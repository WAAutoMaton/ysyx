module Print (
		input enable,
		input [31:0] data
		);
	always @* begin
		if (enable)
			$display("Print: %h", data);
	end
endmodule

