// Part 2 skeleton

module cowboy_gunner
	(
				CLOCK_50,						//	On Board 50 MHz
		// Your inputs and outputs here
        KEY,
		  LEDR,
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
	input   [3:0]   KEY;
	input   [1:0]   SW;
	output [17:0] LEDR;

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
    

	// Create an Instance of a VGA controller - there can be only one!
	// Define the number of colours as well as the initial background
	// image file (.MIF) for the controller.
	vga_adapter VGA(
			.resetn(1'b1),
			.clock(CLOCK_50),
			.colour(colour),
			.x(x),
			.y(y),
			.plot(1'b1),
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

	 reg [5:0] state;
	 reg border_init, player_1_init, player_2_init;
	 reg [7:0] x, y;
	 reg [7:0] p1_x, p1_y, p2_x, p2_y;
	 reg [2:0] colour;
	 reg [17:0] draw_counter;
	 wire frame;

	 assign LEDR[5:0] = state;
	 
	 localparam  RESET_BLACK       = 6'b000000,
                INIT_PLAYER_1     = 6'b000001,
					 INIT_PLAYER_2     = 6'b000010,
                IDLE              = 6'b000011,
					 ERASE_PLAYER_1	 = 6'b000100,
                UPDATE_PLAYER_1   = 6'b000101,
					 DRAW_PLAYER_1	    = 6'b000110,
					 ERASE_PLAYER_2	 = 6'b000111,
                UPDATE_PLAYER_2   = 6'b001000,
					 DRAW_PLAYER_2	    = 6'b001001,
					 DEAD    		    = 6'b001010;

	clock(.clock(CLOCK_50), .clk(frame));
	 //assign LEDR[7] = ((b_y_direction) && (b_y > p_y - 8'd1) && (b_y < p_y + 8'd2) && (b_x >= p_x) && (b_x <= p_x + 8'd8));
	 always@(posedge CLOCK_50)
    begin
			border_init = 1'b0;
			player_1_init = 1'b0;
			player_2_init = 1'b0;
			colour = 3'b000;
			x = 8'b00000000;
			y = 8'b00000000;
			if (SW[0]) state = RESET_BLACK;
        case (state)
		  RESET_BLACK: begin
			if (draw_counter < 17'b10000000000000000) begin
				x = draw_counter[7:0];
				y = draw_counter[16:8];
				draw_counter = draw_counter + 1'b1;
			end
			else begin
				draw_counter= 8'b00000000;
				state = INIT_PLAYER_1;
			end
		  end
    			 INIT_PLAYER_1: begin
					 if (draw_counter < 9'b10000000) begin
					 p1_x = 8'd144;
					 p1_y = 8'd50;
						x = p1_x + draw_counter[7:4];
						y = p1_y + draw_counter[3:0];
						draw_counter = draw_counter + 1'b1;
						colour = 3'b011;
					end
					else begin
						draw_counter= 8'b00000000;
						state = INIT_PLAYER_2;
					end
				 end
				 INIT_PLAYER_2: begin
					 if (draw_counter < 9'b10000000) begin
					 p2_x = 8'd10;
					 p2_y = 8'd50;
						x = p2_x + draw_counter[7:4];
						y = p2_y + draw_counter[3:0];
						draw_counter = draw_counter + 1'b1;
						colour = 3'b111;
					end
					else begin
						draw_counter= 8'b00000000;
						state = IDLE;
					end
				 end
				 IDLE: begin
				 if (frame)
					state = ERASE_PLAYER_1;
				 end
				 ERASE_PLAYER_1: begin
					if (draw_counter < 9'b10000000) begin
						x = p1_x + draw_counter[7:4];
						y = p1_y + draw_counter[3:0];
						draw_counter = draw_counter + 1'b1;
					end
					else begin
						draw_counter= 8'b00000000;
						state = UPDATE_PLAYER_1;
					end
				 end
				 UPDATE_PLAYER_1: begin
						if (~KEY[0] && p1_y < 8'd100) p1_y = p1_y + 1'b1;
						if (~KEY[1] && p1_y > 8'd10) p1_y = p1_y - 1'b1;
						state = DRAW_PLAYER_1;	
				 end
				 DRAW_PLAYER_1: begin
					if (draw_counter < 9'b10000000) begin
						x = p1_x + draw_counter[7:4];
						y = p1_y + draw_counter[3:0];
						draw_counter = draw_counter + 1'b1;
						colour = 3'b011;
					end
					else begin
						draw_counter= 8'b00000000;
						state = ERASE_PLAYER_2;
					end
				 end
				 ERASE_PLAYER_2: begin
					if (draw_counter < 9'b10000000) begin
						x = p2_x + draw_counter[7:4];
						y = p2_y + draw_counter[3:0];
						draw_counter = draw_counter + 1'b1;
					end
					else begin
						draw_counter= 8'b00000000;
						state = UPDATE_PLAYER_2;
					end
				 end
				 UPDATE_PLAYER_2: begin
						if (~KEY[2] && p2_y < 8'd100) p2_y = p2_y + 1'b1;
						if (~KEY[3] && p2_y > 8'd10) p2_y = p2_y - 1'b1;
						state = DRAW_PLAYER_2;	
				 end
				 DRAW_PLAYER_2: begin
					if (draw_counter < 9'b10000000) begin
						x = p2_x + draw_counter[7:4];
						y = p2_y + draw_counter[3:0];
						draw_counter = draw_counter + 1'b1;
						colour = 3'b111;
					end
					else begin
						draw_counter= 8'b00000000;
						state = IDLE;
					end
				 end
				 DEAD: begin
					if (draw_counter < 17'b10000000000000000) begin
						x = draw_counter[7:0];
						y = draw_counter[16:8];
						draw_counter = draw_counter + 1'b1;
						colour = 3'b100;
					end
				end
         endcase
    end
endmodule

module clock(input clock, output clk);
reg [19:0] frame_counter;
reg frame;
	always@(posedge clock)
    begin
        if (frame_counter == 20'b00000000000000000000) begin
		  frame_counter = 20'b11001011011100110100;
		  frame = 1'b1;
		  end
        else begin
			frame_counter = frame_counter - 1'b1;
			frame = 1'b0;
		  end
    end
	 assign clk = frame;
endmodule

