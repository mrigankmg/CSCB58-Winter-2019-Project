//DOES NOT WORK, DO NOT USE
// I NEED IT FOR LATER STAGE
module bullet(x,y,enable, chary)
input x
input y
input enable
input chary
if(x < (160-16))
begin
	if(enable == 1'b1)
		begin
		// when we figure out how to draw a box, replace the next two lines
		// drawBox(x,y,length =4, height=4, vgaRed(1),vgaBLue(0), vgaGReen(0))
		//also erasing the bullet
		// drawBox(x-4,y,length =4, height = 4 vgaRed(1),vgaBlue(1),VgaGreen(1))
		end
else
begin 
	// drawBox(x-4,y,length =4, height = 4 vgaRed(1),vgaBlue(1),VgaGreen(1))
	if(chary == y)
	// drawBox(160-16,y,length =16,height =16,vgaRed(1),vgaBLue(1), VgaGreen(1)
end
endmodule
