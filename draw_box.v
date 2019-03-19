module draw_box(givex, givey, size, x, y);

	input[7:0] givex;
	input[6:0] givey;
	input size;
	integer index;
	integer subI;
	output reg[7:0] x; //if does not work try removing reg
	output reg[6:0] y; //if does not work remove reg
	

	always @(*)
	begin
			x <= givex;
			y <= givey;
		for( index = 0; index < size; index = index + 1)
		begin
			for(subI = 0; subI < size ; subI = subI + 1)
			begin
				x <= x + 00000001;
			end
			y <= givey + 00000001;
			x <= givex;
		end
	end
	
endmodule
