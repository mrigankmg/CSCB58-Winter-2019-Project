module upstate(atTop,
				player,
				moved,
				givey
					x,
					y);

input atTop;// IDK IF THIS SHIT IS A REGESTER CAUSE I GOT TO UPDATE THE VALUE BUT IDK How TO DO THAT
input player;
output reg x;
output reg y;

always@(*moved)
begin
	if(atTop == 2b'00)
	begin
		y <= givey - 10;
		if(y == 0)
		atTop <= 2b'11 
	
	end
	else
		y <= givey;

	if(player == 2b'11)
	begin
		x <= 310;
	end
	else
		x<= 0;
end
endmodule 