module Top_level();
// need to code that shit
// for now add the modules that you want to call, with a descreption of what they do
// also write what inputs they take and what ouputs they give, similar to what i have down 
// also write your name on top of the module so if we have any questions we know who to ask

// Prakhar
// this module gives back the cordinates for the first state, aka the screen with 2 boxes and nothing else
start_one intial(set, // takes input that basically tell you that we are in this stare, 2bit value can be changed
			CLOCK_50,
			x, // output gives back the wire that has the cordinates for the x value, needs to be plugged into drawbox
			y, // output gives back the wire that has the cordinates for the y value, needs to be plugged into the drawbox
			);

//Prakhar
// This module draws a box, given the cordinates and size, needs to be plugged into a decoder that plugs in to vga adaptor, the box is drawn left to righ, top to bottom( left corner)
draw_box drawer(givex, // takes in the x starting cordinate
				givey, // takes in the y starting cordinate 
				size, // takes in the size of the square ( if size = 6 then its 6x6)
				x, // returns back the wire that needs to go to vga adapter through decoder
				y, // returns back the wire that needs to go to vga adapter through decoder 
				);
endmodule
// by decoder i mean a huge ass mux, that allows to pick which state are we taking the input from since we can only have only 1 vga adapter