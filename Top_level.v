module Top_level(CLOCK_50,						//	On Board 50 MHz
		// Your inputs and outputs here
        KEY,
        SW,
		// The ports below are for the VGA output.  Do not change.
		VGA_CLK,   						//	VGA Clock
		VGA_HS,							//	VGA H_SYNC
		VGA_VS,							//	VGA V_SYNC
		VGA_BLANK_N,						//	VGA BLANK
		VGA_SYNC_N,						//	VGA SYNC
		VGA_R,   						//	VGA Red[9:0]
		VGA_G,	 						//	VGA Green[9:0]
		VGA_B   						//	VGA Blue[9:0]
	);
input			CLOCK_50;				//	50 MHz
	input   [9:0]   SW;
	input   [3:0]   KEY;

	// Declare your inputs and outputs here
	// Do not change the following outputs
	output			VGA_CLK;   				//	VGA Clock
	output			VGA_HS;					//	VGA H_SYNC
	output			VGA_VS;					//	VGA V_SYNC
	output			VGA_BLANK_N;				//	VGA BLANK
	output			VGA_SYNC_N;				//	VGA SYNC
	output	[9:0]	VGA_R;   				//	VGA Red[9:0]
	output	[9:0]	VGA_G;	 				//	VGA Green[9:0]
	output	[9:0]	VGA_B;   				//	VGA Blue[9:0]
	
	wire resetn;
	assign resetn = KEY[0];
	
	// Create the colour, x, y and writeEn wires that are inputs to the controller.
	wire [1:0] set;
	wire [2:0] colour;
	wire [7:0] x;
	wire [6:0] y;
	wire [7:0] xTemp;
	wire [6:0] ytemp;
	wire writeEn;
	assign colour = 101;
	assign set = SW[1:0];
	// Create an Instance of a VGA controller - there can be only one!
	// Define the number of colours as well as the initial background
	// image file (.MIF) for the controller.
	vga_adapter VGA(
			.resetn(resetn),
			.clock(CLOCK_50),
			.colour(colour),
			.x(x),
			.y(y),
			.plot(writeEn),
			/* Signals for the DAC to drive the monitor. */
			.VGA_R(VGA_R),
			.VGA_G(VGA_G),
			.VGA_B(VGA_B),
			.VGA_HS(VGA_HS),
			.VGA_VS(VGA_VS),
			.VGA_BLANK(VGA_BLANK_N),
			.VGA_SYNC(VGA_SYNC_N),
			.VGA_CLK(VGA_CLK));
		defparam VGA.RESOLUTION = "160x120";
		defparam VGA.MONOCHROME = "FALSE";
		defparam VGA.BITS_PER_COLOUR_CHANNEL = 1;
		defparam VGA.BACKGROUND_IMAGE = "black.mif";
				
	
	
	
	
// need to code that shit
// for now add the modules that you want to call, with a descreption of what they do
// also write what inputs they take and what ouputs they give, similar to what i have down 
// also write your name on top of the module so if we have any questions we know who to ask

// Prakhar
// this module gives back the cordinates for the first state, aka the screen with 2 boxes and nothing else
start_one intial(set, // takes input that basically tell you that we are in this stare, 2bit value can be changed
			CLOCK_50,
			xTemp, // output gives back the wire that has the cordinates for the x value, needs to be plugged into drawbox
			yTemp, // output gives back the wire that has the cordinates for the y value, needs to be plugged into the drawbox
			);

//Prakhar
// This module draws a box, given the cordinates and size, needs to be plugged into a decoder that plugs in to vga adaptor, the box is drawn left to righ, top to bottom( left corner)
draw_box drawer(xTemp, // takes in the x starting cordinate
				yTemp, // takes in the y starting cordinate 
				size, // takes in the size of the square ( if size = 6 then its 6x6)
				x, // returns back the wire that needs to go to vga adapter through decoder
				y, // returns back the wire that needs to go to vga adapter through decoder 
				);
endmodule
// by decoder i mean a huge ass mux, that allows to pick which state are we taking the input from since we can only have only 1 vga adapter