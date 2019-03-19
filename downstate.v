module downstate(atBottom, player, moved, givey, x, y);

output reg[1:0] atBottom;// IDK IF THIS SHIT IS A REGESTER CAUSE I GOT TO UPDATE THE VALUE BUT IDK How TO DO THAT
input[1:0] player;
input moved;
input[6:0] givey;
output reg[7:0] x;
output reg[6:0] y;

// if moved changed, has to toggle between 0 and 1 assigned at top module
always@(*)
begin
// if we are at thg bottom ;=of the screen, we cant move down
	if(atBottom == 00)
	// we are not, so move further down
		y <= givey + 0001010;
		if(y == 0110110) 
			atBottom <= 11;
	// we are at the bottom, dont move down, retain the value
	else
		y <= givey;

	// if player 1 then x value to left, else x value to the right
	if(player == 11)
		x <= 01110110;
	else
		x<= 00000000;
end
endmodule 