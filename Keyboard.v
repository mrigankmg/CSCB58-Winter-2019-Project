`timescale 1ns / 1ps
module Keyboard(
	input CLK,
   input PS2_CLK,
   input PS2_DATA,
	output reg scan_err, // if there is an error in the input, this turns to 1
	output reg [10:0] scan_code,//this stores the 11 received bits
	output reg [3:0]count,//counts the number of bits recieved
	output reg full_packet,//this goes to 1 once 11 bits have been recieved
	output reg [7:0]codeword, //stores the data portion of the input
   output reg [7:0] LEDR	//For testing
   );

	wire [7:0] up = 8'h75;
	wire [7:0] down = 8'h72;
	wire [7:0] left = 8'h6B;
	wire [7:0] right = 8'h74;
	wire [7:0] l = 8'h4B;
	wire [7:0] w = 8'h1D;
	wire [7:0] a = 8'h1C;
	wire [7:0] s = 8'h1B;
	wire [7:0] d = 8'h23;
	wire [7:0] c = 8'h21;
	reg read;				//this is 1 if more bits are left to be read 
	reg [11:0] count_reading;		//this is for seeing the amount of time since the last codeword
	reg prev_state;			//used to check the previous state of the keyboard clock signal to see if it has changed
	reg new_clk = 0;			//This is a new clock 250 times slower then the old one 
	reg [7:0]downcntr = 0;		//This is used to get the new clock

	//Set initial values
	initial begin
		prev_state = 1;		
		scan_err = 0;		
		scan_code = 0;
		count = 0;			
		codeword = 0;
		read = 0;
		count_reading = 0;
	end

	always @(posedge CLK) begin	 //The new clock is created
		if (downcntr < 249) begin			
			downcntr <= downcntr + 1;
			new_clk <= 0;
		end
		else begin
			downcntr <= 0;
			new_clk <= 1;
		end
	end
	
	always @(posedge CLK) begin	
		if (new_clk) begin
			if (read)				//if there are more bits to be read
				count_reading <= count_reading + 1;	//the time since the last codeword increases
			else 						//if there are no more bits then reset the variable
				count_reading <= 0;
		end
	end


	always @(posedge CLK) begin		
	if (new_clk) begin						//If the new_clk is ready
		if (PS2_CLK != prev_state) begin			//if there is new input
			if (!PS2_CLK) begin				//and if the keyboard clock is at falling edge
				read <= 1;				//begin reading for new bits
				scan_err <= 0;				//no errors so far
				scan_code[10:0] <= {PS2_DATA, scan_code[10:1]};	//add up the data received by shifting bits and adding one new bit
				count <= count + 1;			//
			end
		end
		else if (count == 11) begin				//if it already received 11 bits
			count <= 0;
			read <= 0;					//no more bits needed
			full_packet <= 1;					//change the value of full_packet
			//calculate scan_err using parity bit
			if (!scan_code[10] || scan_code[0] || !(scan_code[1]^scan_code[2]^scan_code[3]^scan_code[4]
				^scan_code[5]^scan_code[6]^scan_code[7]^scan_code[8]
				^scan_code[9]))
				scan_err <= 1;
			else 
				scan_err <= 0;
		end	
		else  begin						//if it yet not received full pack of 11 bits
			full_packet <= 0;					//this varibale remains 0
			if (count < 11 && count_reading >= 4000) begin	//and if after a while no bits recieved then reset number recieved and wait for a new
				count <= 0;				//packet
				read <= 0;		
			end
		end
	prev_state <= PS2_CLK;					//record the previous state of the keyboard clock
	end
	end


	always @(posedge CLK) begin
		if (new_clk) begin					//if the new clock is true
			if (full_packet) begin				//and if a full packet of 11 bits was received
				if (scan_err) begin			//BUT if there was an error
					codeword <= 8'd0;		//then reset the codeword register
				end
				else begin
					codeword <= scan_code[8:1];	//else keep the needed bits and assign them to codeword
				end			
			end					
			else codeword <= 8'd0;				//not a full packet received, thus reset codeword
		end
		else codeword <= 8'd0;					//no clock trigger, no data
	end

	//For testing the 4 arrow keys
	always @(posedge CLK) begin
		if (codeword == up)				
			LEDR[0] <= 1;				
		else if (codeword == left)			
			LEDR[1] <= 1;	
		else if (codeword == down)			
			LEDR[2] <= 1;
		else if (codeword == right)			
			LEDR[3] <= 1;

	end

endmodule