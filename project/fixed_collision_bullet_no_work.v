// Part 2 skeleton

module cowboy_gunner
	(
				CLOCK_50,						//	On Board 50 MHz
		// Your inputs and outputs here
        KEY,
		  SW,
		  PS2_KBCLK,
		  PS2_KBDAT,
		  LEDR,
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
	input   [17:0]   SW;
	input PS2_KBCLK;
	input PS2_KBDAT;
	output [17:0] LEDR;
	wire [6:0] ASCII_value;
   wire [7:0] kb_scan_code;
	wire kb_sc_ready, kb_letter_case;
	wire resetn;
  	assign resetn = SW[4];

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
			/* Signals for the DAC to drive module cowboy_gunner
the monitor. */
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

		keyboard kd
			(
					.clk(CLOCK_50),
					.reset(~resetn),
					.ps2d(PS2_KBDAT),
					.ps2c(PS2_KBCLK),
					.scan_code(kb_scan_code),
					.scan_code_ready(kb_sc_ready),
					.letter_case_out(kb_letter_case)
			);

	key2ascii SC2A
			(
					.ascii_code(ASCII_value),
					.scan_code(kb_scan_code),
					.letter_case(kb_letter_case)
			);

	 reg [5:0] state;
	 reg border_init, player_1_init, player_2_init, p1_fired, p2_fired;
	 reg [7:0] x, y;
	 reg [7:0] p1_t_x, p1_t_y, p1_g_x, p1_g_y, p2_t_x, p2_t_y, p2_g_x, p2_g_y, pb1_x, pb1_y, pb2_x, pb2_y;
	 reg [2:0] colour;
	 reg score_a ;
	 reg score_b ;
	 reg [17:0] draw_counter;
	 wire frame;

	 localparam  RESET_BLACK       = 7'b0000000,
                INIT_PLAYER_1_TANK     =7'b0000001,
					 INIT_PLAYER_1_GUN     = 7'b0000010,
					 INIT_PLAYER_1_BULLET     = 7'b0000011,
					 INIT_PLAYER_2_TANK     = 7'b0000100,
		 		 	 INIT_PLAYER_2_GUN     = 7'b0000101,
					 INIT_PLAYER_2_BULLET     = 7'b0000110,
                IDLE              = 7'b0000111,
					 ERASE_PLAYER_1_TANK	 = 7'b0001000,
					 ERASE_PLAYER_1_GUN	 = 7'b0001001,
					 ERASE_PLAYER_1_BULLET	 = 7'b0001010,
                UPDATE_PLAYER_1   = 7'b0001011,
					 DRAW_PLAYER_1_TANK	    = 7'b0001100,
					 DRAW_PLAYER_1_GUN	    = 7'b0001101,
					 DRAW_PLAYER_1_BULLET	    = 7'b0001110,
					 ERASE_PLAYER_2_TANK	 = 7'b0001111,
					 ERASE_PLAYER_2_GUN	= 7'b0010000,
					 ERASE_PLAYER_2_BULLET	 = 7'b0010001,
                UPDATE_PLAYER_2   = 7'b0010010,
					 DRAW_PLAYER_2_TANK	 = 7'b0010011,
					 DRAW_PLAYER_2_GUN	 = 7'b0010100,
					 DRAW_PLAYER_2_BULLET	    = 7'b0010101,
					 DEAD    		    = 7'b0010110;

	clock(.clock(CLOCK_50), .clk(frame));
	 always@(posedge CLOCK_50)
    begin
			border_init = 1'b0;
			player_1_init = 1'b0;
			player_2_init = 1'b0;
//			p1_fired = 1'b0;
//			p2_fired = 1'b0;
			colour = 3'b000;
			x = 8'b00000000;
			y = 8'b00000000;
			if (SW[0]) state = RESET_BLACK;
        case (state)
		  RESET_BLACK: begin
		  	p1_fired = 1'b0;
			p2_fired = 1'b0;
			score_a = 2'b00;
			score_b = 2'b00;
			if (draw_counter < 17'b10000000000000000) begin
				x = draw_counter[7:0];
				y = draw_counter[16:8];
				draw_counter = draw_counter + 1'b1;
			end
			else begin
				draw_counter= 8'b00000000;
				state = INIT_PLAYER_1_TANK;
			end
		  end
    			 INIT_PLAYER_1_TANK: begin
					if (draw_counter < 9'b10000000) begin
						p1_t_x = 8'd144;
						p1_t_y = 8'd50;
						x = p1_t_x + draw_counter[7:4];
						y = p1_t_y + draw_counter[3:0];
						draw_counter = draw_counter + 1'b1;
						colour = 3'b011;
					end
					else begin
						draw_counter= 8'b00000000;
						state = INIT_PLAYER_1_GUN;
					end
				 end
				 INIT_PLAYER_1_GUN: begin
				 if (draw_counter < 5'b1000) begin
					p1_g_x = 8'd140;
					p1_g_y = 8'd53;
					x = p1_g_x + draw_counter[1:0];
					y = p1_g_y + draw_counter[3:2];
					draw_counter = draw_counter + 1'b1;
					colour = 3'b011;
				end
				else begin
					draw_counter= 8'b00000000;
					state = INIT_PLAYER_1_BULLET;
				end
			 end
			 INIT_PLAYER_1_BULLET: begin
				 if (draw_counter < 6'b10000) begin
					pb1_x = 8'd140;
					pb1_y = 8'd53;
					x = pb1_x + draw_counter[2:0];
					y = pb1_y + draw_counter[4:3];
					draw_counter = draw_counter + 1'b1;
					colour = 3'b011;
				end
				else begin
					draw_counter= 8'b00000000;
					state = INIT_PLAYER_2_TANK;
				end
			 end
				 INIT_PLAYER_2_TANK: begin
					 if (draw_counter < 9'b10000000) begin
					 p2_t_x = 8'd8;
					 p2_t_y = 8'd50;
						x = p2_t_x + draw_counter[7:4];
						y = p2_t_y + draw_counter[3:0];
						draw_counter = draw_counter + 1'b1;
						colour = 3'b001;
					end
					else begin
						draw_counter= 8'b00000000;
						state = INIT_PLAYER_2_GUN;
					end
				 end
				 INIT_PLAYER_2_GUN: begin
				if (draw_counter < 6'b10000) begin
					p2_g_x = 8'd12;
					p2_g_y = 8'd53;
					x = p2_g_x + draw_counter[2:0];
					y = p2_g_y + draw_counter[4:3];
					draw_counter = draw_counter + 1'b1;
					colour = 3'b001;
				end
				else begin
					draw_counter= 8'b00000000;
					state = INIT_PLAYER_2_BULLET;
				end
			 end
			 INIT_PLAYER_2_BULLET: begin
				if (draw_counter < 5'b1000) begin
					pb2_x = 8'd15;
					pb2_y = 8'd53;
					x = pb2_x + draw_counter[1:0];
					y = pb2_y + draw_counter[3:2];
					draw_counter = draw_counter + 1'b1;
					colour = 3'b011;
				end
				else begin
					draw_counter= 8'b00000000;
					state = IDLE;
				end
			 end
				 IDLE: begin
				 if (frame)
					state = ERASE_PLAYER_1_TANK;
				 end
				 ERASE_PLAYER_1_TANK: begin
					if (draw_counter < 9'b10000000) begin
						x = p1_t_x + draw_counter[7:4];
						y = p1_t_y + draw_counter[3:0];
						draw_counter = draw_counter + 1'b1;
					end
					else begin
						draw_counter= 8'b00000000;
						state = ERASE_PLAYER_1_GUN;
					end
				 end
				 ERASE_PLAYER_1_GUN: begin
				if (draw_counter < 6'b10000) begin
					x = p1_g_x + draw_counter[2:0];
					y = p1_g_y + draw_counter[4:3];
					draw_counter = draw_counter + 1'b1;
				end
				else begin
					draw_counter= 8'b00000000;
					state = ERASE_PLAYER_1_BULLET;
				end
			 end
			 ERASE_PLAYER_1_BULLET: begin
				if (draw_counter < 5'b1000) begin
					x = pb1_x + draw_counter[1:0];
					y = pb1_y + draw_counter[3:2];
					draw_counter = draw_counter + 1'b1;
				end
				else begin
					draw_counter= 8'b00000000;
					state = UPDATE_PLAYER_1;
				end
			 end
				 UPDATE_PLAYER_1: begin
						if (ASCII_value == 8'h13 && p1_t_y < 8'd100) begin
							p1_t_y = p1_t_y + 1'b1;
							p1_g_y = p1_g_y + 1'b1;
							if(p1_fired == 1'b0) begin
								pb1_y=pb1_y + 1'b1;
							end
						end
						if (ASCII_value == 8'h11 && p1_t_y > 8'd10) begin
							p1_t_y = p1_t_y - 1'b1;
							p1_g_y = p1_g_y - 1'b1;
							if(p1_fired == 1'b0) begin
								pb1_y=pb1_y - 1'b1;
							end
						end
						if (ASCII_value == 8'h12 && p1_t_x > 8'd123) begin
							p1_t_x = p1_t_x - 1'b1;
							p1_g_x = p1_g_x - 1'b1;
							if(p1_fired == 1'b0) begin
								pb1_x=pb1_x - 1'b1;
							end
						end
						if (ASCII_value == 8'h14 && p1_t_x < 8'd144) begin
							p1_t_x = p1_t_x + 1'b1;
							p1_g_x = p1_g_x + 1'b1;
							if(p1_fired == 1'b0) begin
								pb1_x=pb1_x + 1'b1;
							end
						end
						if (SW[15] && p1_fired == 1'b0) begin
							p1_fired = 1'b1;
						end
						if (p1_fired == 1'b1 && pb1_x > 8'd0) begin
							pb1_x = pb1_x - 1'b1;
						end
						else if (p1_fired == 1'b1 && pb1_x == 8'd0) begin
							pb1_x = p1_g_x;
							pb1_y = p1_g_y;
							p1_fired = 1'b0;
						end
						if(p1_fired == 1'b1 && pb1_x > p2_t_x + 6'b100000) begin
							if ((pb1_y - 2'b10) > p2_t_y && (pb1_y < p2_t_y + 6'b10000) )begin
								score_a <= score_a + 2'b01;
								p1_fired = 1'b0;
								//pb1_x = 8'd00;
								//pb1_y = 8'd00;
								draw_counter= 8'b00000000;
								if(score_a == 2'b11) state = RESET_BLACK;
								else state = INIT_PLAYER_1_TANK;
							end
							else state = DRAW_PLAYER_1_TANK;
						end
						else state = DRAW_PLAYER_1_TANK;
				 end
				 DRAW_PLAYER_1_TANK: begin
					if (draw_counter < 9'b10000000) begin
						x = p1_t_x + draw_counter[7:4];
						y = p1_t_y + draw_counter[3:0];
						draw_counter = draw_counter + 1'b1;
						colour = 3'b011;
					end
					else begin
						draw_counter= 8'b00000000;
						state = DRAW_PLAYER_1_GUN;
					end
				 end
				 DRAW_PLAYER_1_GUN: begin
					if (draw_counter < 6'b10000) begin
						x = p1_g_x + draw_counter[2:0];
						y = p1_g_y + draw_counter[4:3];
						draw_counter = draw_counter + 1'b1;
						colour = 3'b011;
					end
					else begin
						draw_counter= 8'b00000000;
						state = DRAW_PLAYER_1_BULLET;
					end
				 end
				 DRAW_PLAYER_1_BULLET: begin
				 if (draw_counter < 5'b1000) begin
					x = pb1_x + draw_counter[1:0];
					y = pb1_y + draw_counter[3:2];
					draw_counter = draw_counter + 1'b1;
					colour = 3'b011;
				end
				else begin
					draw_counter= 8'b00000000;
					state = ERASE_PLAYER_2_TANK;
				end
			 end
				 ERASE_PLAYER_2_TANK: begin
					if (draw_counter < 9'b10000000) begin
						x = p2_t_x + draw_counter[7:4];
						y = p2_t_y + draw_counter[3:0];
						draw_counter = draw_counter + 1'b1;
					end
					else begin
						draw_counter= 8'b00000000;
						state = ERASE_PLAYER_2_GUN;
					end
				 end
				 ERASE_PLAYER_2_GUN: begin
				 if (draw_counter < 6'b10000) begin
					x = p2_g_x + draw_counter[2:0];
					y = p2_g_y + draw_counter[4:3];
					draw_counter = draw_counter + 1'b1;
				end
				else begin
					draw_counter= 8'b00000000;
					state = ERASE_PLAYER_2_BULLET;
				end
			 end
			 ERASE_PLAYER_2_BULLET: begin
				 if (draw_counter < 5'b1000) begin
					x = pb2_x + draw_counter[1:0];
					y = pb2_y + draw_counter[3:2];
					draw_counter = draw_counter + 1'b1;
				end
				else begin
					draw_counter= 8'b00000000;
					state = UPDATE_PLAYER_2;
				end
			 end
				 UPDATE_PLAYER_2: begin
						if (ASCII_value  == 8'h73 && p2_t_y < 8'd100) begin
							p2_t_y = p2_t_y + 1'b1;
							p2_g_y = p2_g_y + 1'b1;
							if(p2_fired == 1'b0) begin
								pb2_y=pb2_y + 1'b1;
							end
						end
						if (ASCII_value ==8'h77 && p2_t_y > 8'd10) begin
							p2_t_y = p2_t_y - 1'b1;
							p2_g_y = p2_g_y - 1'b1;
							if(p2_fired == 1'b0) begin
								pb2_y=pb2_y - 1'b1;
							end
						end
						if (ASCII_value ==8'h64 && p2_t_x < 8'd30) begin
							p2_t_x = p2_t_x + 1'b1;
							p2_g_x = p2_g_x + 1'b1;
							if(p2_fired == 1'b0) begin
								pb2_x=pb2_x + 1'b1;
							end
						end
						if (ASCII_value==8'h61 && p2_t_x > 8'd8) begin
							p2_t_x = p2_t_x - 1'b1;
							p2_g_x = p2_g_x - 1'b1;
							if(p2_fired == 1'b0) begin
								pb2_x=pb2_x - 1'b1;
							end
						end
						if (SW[17] && p2_fired == 1'b0) begin
							p2_fired = 1'b1;
						end
						if (p2_fired == 1'b1 && pb2_x < 8'd150) begin
							pb2_x=pb2_x + 1'b1;
						end
						else if (p2_fired == 1'b1 && pb2_x == 8'd150) begin
							pb2_x = p2_g_x + 2'd3;
							pb2_y = p2_g_y;
							p2_fired = 1'b0;
						end
						if(p2_fired == 1'b1 && pb2_x + 2'b11 > p1_t_x ) begin
							if ((pb2_y - 2'b10) > p1_t_y && (pb2_y < p1_t_y + 6'b10000) ) begin
								score_b <= score_b + 2'b01;
								p2_fired = 1'b0;
								//pb2_x = 8'd00;
								//pb2_y = 8'd00;
								draw_counter= 8'b00000000;
								if(score_b == 2'b11) state = RESET_BLACK;
								else state = INIT_PLAYER_2_TANK;//+ 
							end
							else state = DRAW_PLAYER_2_TANK;
						end
						else begin
							state = DRAW_PLAYER_2_TANK;
						end
				 end
				 DRAW_PLAYER_2_TANK: begin
					if (draw_counter < 9'b10000000) begin
						x = p2_t_x + draw_counter[7:4];
						y = p2_t_y + draw_counter[3:0];
						draw_counter = draw_counter + 1'b1;
						colour = 3'b001;
					end
					else begin
						draw_counter= 8'b00000000;
						state = DRAW_PLAYER_2_GUN;
					end
				 end
				 DRAW_PLAYER_2_GUN: begin
					if (draw_counter < 6'b10000) begin
						x = p2_g_x + draw_counter[2:0];
						y = p2_g_y + draw_counter[4:3];
						draw_counter = draw_counter + 1'b1;
						colour = 3'b001;
					end
					else begin
						draw_counter= 8'b00000000;
						state = DRAW_PLAYER_2_BULLET;
					end
				 end
				 DRAW_PLAYER_2_BULLET: begin
				 if (draw_counter < 5'b1000) begin
				 
					x = pb2_x + draw_counter[1:0];
					y = pb2_y + draw_counter[3:2];
					draw_counter = draw_counter + 1'b1;
					colour = 3'b001;
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
						draw_counter = draw_counter + 1'b1
;
						colour = 3'b100;
					end
				end
         endcase
    end
endmodule

module bullet(input clock, input fire);

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
