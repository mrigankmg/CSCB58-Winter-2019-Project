module downstate(atBottom,
				player,
				moved,
				givey
					x,
					y);

input atTop;// IDK IF THIS SHIT IS A REGESTER CAUSE I GOT TO UPDATE THE VALUE BUT IDK How TO DO THAT
input player;
output reg[7:0] x;
output reg[7:0] y;

// if moved changed, has to toggle between 0 and 1 assigned at top module
always@(*moved)
begin
// if we are at thg bottom of the screen, we cant move down
	if(atBottom == 2b'00)
	begin
	// we are not, so move further down
		y <= givey + 10;
		if(y == 230)
		atBottom <= 2b'11 
	
	end
	// we are at the bottom, dont move down, retain the value
	else
		y <= givey;

	// if player 1 then x value to left, else x value to the right
	if(player == 2b'11)
	begin
		x <= 310;
	end
	else
		x<= 0;
end
endmodule 