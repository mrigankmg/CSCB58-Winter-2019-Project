module draw_box(givex, givey, size, x, y);

	input givex;
	input givey;
	input size;
	output reg x; //if does not work try removing reg
	output reg y; //if does not work remove reg

	assign x <= givex;
	assign y <= givey;
	always*()
	begin
		for( index = 0; index < size; index = index + 1)
		begin
			for(subI = 0; subI < size ; subI = subI + 1)
			begin
				x <= x + 1;
			end
			y <= givey + 1;
			x <= givex;
		end
	end
endmodule