`timescale 1ns / 1ps

module testtimer( clk, HEX0, HEX1, HEX2, SW, done);
	input clk;
	input [9:6] SW;
	output [6:0] HEX0, HEX1, HEX2;
	output reg done;
	

	reg [3:0] mins = 4'b0000;
	reg [3:0] tens = 4'b0000;
	reg [3:0] ones = 4'b0000;

	hex_decoder H2(.hex_digit(mins), .segments(HEX2));
	hex_decoder H1(.hex_digit(tens), .segments(HEX1));
	hex_decoder H0(.hex_digit(ones), .segments(HEX0));

	reg [25:0] new_clk = 0;

	always @(posedge clk) begin : counter
		if(SW[9] == 1'b0) begin
			mins <= {1'b0, SW[8:6]};
			ones <= 4'b0000;
			tens <= 4'b0000;
		end
		else if(SW[9] == 1'b1) begin
			if(new_clk == 26'd50000000) begin
				if(tens > 4'b0000 && ones == 4'b0000) begin
					tens <= tens - 1'b1;
					ones <= 4'b1001;
				end
				else if(tens == 4'b0000 && ones == 4'b0000 && mins > 4'b0000) begin
					mins <= mins - 1'b1;
					tens <= 4'b0101;
					ones <= 4'b1001;
				end
				else if(tens == 4'b0000 && ones == 4'b0001 && mins == 4'b0000) begin
					ones <= 4'b0000;
					done <= 1'b1;
				end
				else if(tens == 4'b0000 && ones == 4'b0000 && mins == 4'b0000) begin
					ones <= 4'b0000;
				end
				else begin
					ones <= ones - 1'b1;
				end
				new_clk <= 0;
			end
			else begin
				new_clk <= new_clk + 1'b1;
			end
		end
	end
endmodule

module hex_decoder(hex_digit, segments);
	input [3:0] hex_digit;
	output reg [6:0] segments;

	always @(*)
		case (hex_digit)
				4'h0: segments = 7'b100_0000;
				4'h1: segments = 7'b111_1001;
            4'h2: segments = 7'b010_0100;
            4'h3: segments = 7'b011_0000;
            4'h4: segments = 7'b001_1001;
            4'h5: segments = 7'b001_0010;
            4'h6: segments = 7'b000_0010;
            4'h7: segments = 7'b111_1000;
            4'h8: segments = 7'b000_0000;
            4'h9: segments = 7'b001_1000;
            4'hA: segments = 7'b000_1000;
            4'hB: segments = 7'b000_0011;
            4'hC: segments = 7'b100_0110;
            4'hD: segments = 7'b010_0001;
            4'hE: segments = 7'b000_0110;
            4'hF: segments = 7'b000_1110;   
            default: segments = 7'h7f;
		endcase
endmodule
