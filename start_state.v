module state_one(	set,
					CLOCK_50,
					x,
					y
					);
// this module draws the boards on the box 

input CLOCK_50;
reg set;
output reg x;
output reg y;

always(posedge, negedge);
begin 

if(set == 2b'11)
begin
	x <= 0;
	y<= 256/2 - 10
	set <= 2b'10
end
else if(set == 2b'10)
begin
	x<=256;
	y<=256/2-10;
	set<= 00;
end
endmodule