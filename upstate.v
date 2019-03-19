module upstate(atTop,
				player,
				moved,
				givey,
					x,
					y);

output reg[1:0] atTop;// IDK IF THIS SHIT IS A REGESTER CAUSE I GOT TO UPDATE THE VALUE BUT IDK How TO DO THAT
input[1:0] player;
input[6:0] givey;
input moved;
output reg[7:0] x;
output reg[6:0] y;

always@(*)
begin
	if(atTop == 00)
	begin
		y <= givey + 1110110;
		if(y == 0000000 )
			atTop <= 11 ;
	
	end
	else
		y <= givey;

	if(player == 11)
	begin
		x <= 01110110;
	end
	else
		x <= 0000000;
end
endmodule 