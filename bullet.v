module bullet(
   input clk,
	input fired_by
   input reg x,
	input reg y,
   input	reg curr_x_1,
	input	reg curr_y_1,
	input	reg curr_x_2,
   input	reg curr_y_2,
	output collision
   );

   reg [3:0] current_state, next_state; 
    
   localparam  moving_east = 3'b0,
					moving_west = 3'b1,
					east_wall = 3'b2,
					west_wall = 3'b3,
					collide = 3'b4;
					clear = 3'b5;
    
   // Next state logic aka our state table
   always@(*)
   begin: state_table 
		case (current_state)
			moving_east: 
				if(x == 240) begin 
					next_state = east_wall;
				end
				else if(curr_y_1 + 10 <= y <= curr_y_1) begin
					if(curr_x_1 + 10 <= x <= curr_x_1) begin
						next_state = collision;
					end
				end
				else if(curr_y_2 + 10 <= y <= curr_y_2) begin
					if(curr_x_2 + 10 <= x <= curr_x_2) begin
						next_state = collision;
					end
				end
			east_wall: next_state = moving_west;
			moving_west:
				if(x - 5 == 0) begin 
					next_state = west_wall;
				end
				else if(curr_y_1 + 10 <= y <= curr_y_1) begin
					if(curr_x_1 + 10 <= x <= curr_x_1) begin
						next_state = collision;
					end
				end
				else if(curr_y_2 + 10 <= y <= curr_y_2) begin
					if(curr_x_2 + 10 <= x <= curr_x_2) begin
						next_state = collision;
					end
				end
			east_wall: next_state = moving_east;
			collide: next_state = clear;
            default:
					if(fired_by = 1'b0) begin
						next_state = moving_east;
					end
					else begin
						next_state = moving_west;
					end
        endcase
    end // state_table
	 
	always @(*)
		begin: enable_signals
			collision = 0;
			case (current_state)
				moving_west:begin
				
				end
				moving_east: begin
				
				end
				
				east_wall: begin
				
				end
				
				west_wall: begin
				
				end
				
				collide: begin 
				
				end
				
				clear: begin
				
				end

        endcase
    end // enable_signals
	
   
