// Part 2 skeleton

module pong
	(
		CLOCK_50,						//	On Board 50 MHz
		// Your inputs and outputs here
        KEY,
        SW,
		  HEX6,
		  HEX4,
		// The ports below are for the VGA output.  Do not change.
		VGA_CLK,   						//	VGA Clock
		VGA_HS,							//	VGA H_SYNC
		VGA_VS,							//	VGA V_SYNC
		VGA_BLANK_N,						//	VGA BLANK
		VGA_SYNC_N,						//	VGA SYNC
		VGA_R,   						//	VGA Red[9:0]
		VGA_G,	 						//	VGA Green[9:0]
		VGA_B//	VGA Blue[9:0]
	);

	input			CLOCK_50;				//	50 MHz
	input   [17:0]   SW;
	input   [3:0]   KEY;
	output [6:0] HEX6;
	output [6:0] HEX4;
	// Declare your inputs and outputs here
	// wires for the game
	wire ballClk;
	wire [1:0] ballMovement;
	wire [3:0] Player1_Score;
	wire [3:0] Player2_Score;
	wire [7:0] ballX;
	wire [7:0] ballY;
	wire [7:0] Player1_Paddle;
	wire [7:0] Player2_Paddle;
	wire  [2:0] clr_A;
	wire  [2:0] clr_B;
	wire  [2:0] clr_C;
	wire  [2:0] clr_temp;
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
	assign resetn = 1'b1;
	wire gameOver,newGame;
	// Create the colour, x, y and writeEn wires that are inputs to the controller.
	wire [2:0] colour;
	wire [7:0] x;
	wire [6:0] y;
	wire writeEn;

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

	// Put your code here. Your code should produce signals x,y,colour and writeEn/plot
	// for the VGA controller, in addition to any other functionality your design may require.

    // Instansiate datapath
	datapath d0(
			.clk(CLOCK_50),
			.resetn(resetn),
			.user_clr(SW[9]),
			.paddle_clr(SW[2:0]),
			.data_in(SW[6:0]),
			.clr_in(SW[9:7]),
			.Player1_Score(Player1_Score),
			.Player2_Score(Player2_Score),
			.ballX(ballX),
			.ballY(ballY),
			.Player1_Paddle(Player1_Paddle),
			.Player2_Paddle(Player2_Paddle),
			.clr_A(clr_A),
			.clr_B(clr_B),
			.clr_C(clr_C),
			.clr_temp(clr_temp),
			.gameOver(gameOver),
			.newGame(newGame),
			.x(x),
			.y(y),
			.clr(colour),
			.display1(HEX6),
			.display2(HEX4)
			);

    // Instansiate FSM control
    // control c0(...);
    control c0(
    		.clk(CLOCK_50),
    		.resetn(SW[17]),
			.gameOver(gameOver),
				.drawEn(writeEn),
				.newGame(newGame));
	// instantiate game collision			
	collision gameCollision(
			.clk(CLOCK_50),
			.ballX(ballX),
			.ballY(ballY),
			.Player1_Paddle(Player1_Paddle),
			.Player2_Paddle(Player2_Paddle),
			.gameOver(gameOver),
			.newGame(newGame),
			.ballMovement(ballMovement),
			.Player1_Score(Player1_Score),
			.Player2_Score(Player2_Score)
		);
	// instantiate animations	
	Animation animate(
			.ballMovement(ballMovement),
			.ballClk(ballClk),
			.clk(CLOCK_50),
			.enable(writeEn),
			.gameOver(gameOver),
			.newGame(newGame),
			.pause(SW[16]),
			.clr_A(clr_A),
			.clr_B(clr_B),
			.clr_C(clr_C),
			.clr_temp(clr_temp),
			.ballX(ballX),
			.ballY(ballY)
		);
	// instantiate paddle movement	
	paddleMovement move(
			.up1(KEY[3]),
			.down1(KEY[2]),
			.up2(KEY[1]),
			.down2(KEY[0]),
			.clk(CLOCK_50),
			.enable(writeEn),
			.newGame(newGame),
			.Player1_Paddle(Player1_Paddle),
			.Player2_Paddle(Player2_Paddle)
		);
	// slow down the clock so the ball isnt moving
	// 50000000 times per second
	ballClock clkBall(
			.clk(CLOCK_50),
			.user_speed(SW[8:6]),
			.newGame(newGame),
			.ballClk(ballClk)
		);
endmodule
/*********************************** CONTROL *******************************/
    module control(
    input clk,
    input resetn,
	 input gameOver,
    output reg drawEn,
	 output reg newGame
    );

    reg [5:0] current_state, next_state;

    localparam  S_PLAY      = 5'd1,
					 S_GAME_OVER = 5'd2,
					 S_NEW_GAME  = 5'd3,
					 S_NEW_GAME_WAIT = 5'd4;

    /***************************** STATE TABLE ******************************/
    always@(*)
    begin: state_table
            case (current_state)
                S_PLAY:
					 begin
						if (gameOver) begin
							next_state = S_GAME_OVER;
						end
						else if (resetn) begin
							next_state = S_NEW_GAME;
						end
						else begin
							next_state = S_PLAY;
						end
					 end
					 S_GAME_OVER: next_state = resetn ? S_NEW_GAME : S_GAME_OVER;
					 S_NEW_GAME: next_state = S_NEW_GAME_WAIT;
					 S_NEW_GAME_WAIT: next_state = S_PLAY;
            default:     next_state = S_PLAY;
        endcase
    end // state_table
	/********************** DATAPATH CONTROL SIGNALS ************************/
    // Output logic aka all of our datapath control signals
    always @(*)
    begin: enable_signals
        // By default make all our signals 0
        drawEn = 1'b0;
		  newGame = 1'b0;
        case (current_state)
            S_PLAY: begin
                drawEn = 1'b1;
            end
				S_GAME_OVER: begin
					drawEn = 1'b1;
				end
				S_NEW_GAME: begin
					newGame = 1'b1;
				end
        // default:    // don't need default since we already made sure all of our outputs were assigned a value at the start of the always block
        endcase
    end // enable_signals

    // current_state registers
    always@(posedge clk)
    begin: state_FFs
        if(!resetn)
            current_state <= S_PLAY;
        else
            current_state <= next_state;
    end // state_FFS
endmodule
/******************************** DATAPATH ***********************************/
module datapath(
    input clk,
    input resetn,
	 input user_clr,
	 input [2:0] paddle_clr,
    input [6:0] data_in,
    input [2:0] clr_in,
	 input [3:0] Player1_Score,
	 input [3:0] Player2_Score,
	 input [7:0] ballX,
	 input [7:0] ballY,
	 input [7:0] Player1_Paddle,
	 input [7:0] Player2_Paddle,
	 input [2:0] clr_A,
	 input [2:0] clr_B,
	 input [2:0] clr_C,
	 input [2:0] clr_temp,
	 input gameOver,
	 input newGame,
	 output reg [7:0] x,
	 output reg [6:0] y,
    output reg [2:0] clr,
	 output [6:0] display1,
	 output [6:0] display2
    );
	 reg on;
	 /*********************** INITIALIZE ***************************/
	 initial begin
    	 x <=0;
		 y <= 0;
		 clr <= 3'b000;
		 on <= 1'b1;
	 end
	 // set hexes
	 hex_display p1(Player1_Score,display1);
	 hex_display p2(Player2_Score,display2);
	 // clock cycle
    always@(posedge clk) begin
			// newGame, reset values
			if (newGame) begin
				x <= 0;
				y <= 0;
				clr <= 3'b000;
				on <= 1'b1;
			end
			// increment x
			x <= x+1;
			// if we are too far right
			if (x == 160) begin
				// reset x
				x <= 0;
				// increase y
				y <= y + 1;
				// check if we are too low on the screen
				if (y > 120) begin
					// reset x and y
					x <= 0;
					y <= 0;
				end
			end
			
		/*********************** COLOURING ***************************/
		// See what colour we need to colour this pixel
		// CASE 1: We need to draw Player1_Paddle
		// CASE 2: We need to draw Player2_Paddle
		// CASE 3: We need to draw the Ball
		// CASE 4: We need to draw PONG FONT
		// CASE 5: We need to draw Background
		
		// ball and paddles, as well as line
		if ( (x > 2 && x < 5 && y < Player1_Paddle && y > Player1_Paddle-19) || (x < 157 && x > 154 && y < Player2_Paddle && y > Player2_Paddle-19) || (x > ballX && x < ballX + 4 && y > ballY && y < ballY + 4) || (y == 20 && x < 160) || (x == 77 && y > 20) || (x < 160 && y == 119) 
