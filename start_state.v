module start_state(CLOCK_50,
					x,
					y
					);
// this module draws the boards on the box 

	input CLOCK_50;
	reg [1:0] set;
	output reg[7:0] x;
	output reg[6:0] y;
	
	always @(posedge CLOCK_50)
	begin 
		if(set == 00 ) begin
			x <= 00000000;
			y<= 0110110;
			set <= 01;
		end
		else if(set == 01) begin
			x<= 01110110;
			y<= 0110110;
			set<= 11;
		end
	end
endmodule
