`timescale 1ns / 1ps

module p_state(input reset,
              input vsync,
              input chop, carry,
              input [7:0][12:0][3:0] object_grid,
              input [1:0] player_direction, //up, down, left, right
              input [8:0] player_loc_x,
              input [8:0] player_loc_y,
              output logic [3:0] player_state);
              
    parameter LEFT = 2'd0;
    parameter RIGHT = 2'd1;
    parameter UP = 2'd2;
    parameter DOWN = 2'd3;
    
    // player states
    parameter P_NOTHING = 0;
    parameter P_CHOPPING = 1;
    parameter P_ONION_WHOLE = 2;
    parameter P_ONION_CHOPPED = 3;
    parameter P_POT_EMPTY = 4;
    parameter P_POT_RAW = 5;
    parameter P_POT_COOKED = 6;
    parameter P_BOWL_EMPTY = 7;
    parameter P_BOWL_FULL = 8;
    parameter P_EXT_OFF = 9;
    parameter P_EXT_ON = 10;
    
     // grid object parameters
    parameter G_EMPTY = 0;
    parameter G_ONION_WHOLE = 1;
    parameter G_ONION_CHOPPED = 2;
    parameter G_BOWL_EMPTY = 3;
    parameter G_BOWL_FULL = 4;
    parameter G_POT_EMPTY = 5;
    parameter G_POT_RAW = 6;
    parameter G_POT_COOKED = 7;
    parameter G_POT_FIRE = 8;
    parameter G_FIRE = 9;
    parameter G_EXTINGUISHER = 10;
    
    logic [3:0] grid_x;
    logic [2:0] grid_y;
    logic [3:0] object_in_front;
    logic [3:0] x_front;
    logic [2:0] y_front;
    
    
    pixel_to_grid p2g (.pixel_x((player_loc_x+16)), .pixel_y((player_loc_y+16)), 
                       .grid_x(grid_x), .grid_y(grid_y));
    
    check_in_front cf (.grid_x(grid_x),.grid_y(grid_y),.player_direction(player_direction),
                    .object_grid(object_grid),.object(object_in_front));
                    
    grid_in_front gf (.grid_x(grid_x),.grid_y(grid_y),.player_direction(player_direction),
                   .x_front(x_front),.y_front(y_front));               
                    
                       
    always_ff @(negedge vsync) begin
        if (reset) begin
            player_state <= P_NOTHING;
        end else if (player_state == P_NOTHING) begin
            if (chop) begin
                player_state <= P_CHOPPING;
            end else if ((object_in_front == G_ONION_WHOLE) && (carry)) begin
                player_state <= P_ONION_WHOLE;
            end else if ((object_in_front == G_ONION_CHOPPED) && (carry)) begin
                player_state <= P_ONION_CHOPPED;
            end else if ((object_in_front == G_POT_EMPTY) && (carry)) begin
                player_state <= P_POT_EMPTY;
            end else if ((object_in_front == G_POT_RAW) && (carry)) begin
                player_state <= P_POT_RAW;
            end else if ((object_in_front == G_POT_COOKED) && (carry)) begin
                player_state <= P_POT_COOKED;
            end else if ((object_in_front == G_BOWL_EMPTY) && (carry)) begin
                player_state <= P_BOWL_EMPTY;
            end else if ((object_in_front == G_BOWL_FULL) && (carry)) begin
                player_state <= P_BOWL_FULL;
            end else if ((object_in_front == G_EXTINGUISHER) && (carry)) begin
                player_state <= P_EXT_OFF;
            end
        
        end else if ((player_state == P_CHOPPING)&&(~chop)) begin
            player_state <= P_NOTHING;
        end else if ((player_state == P_ONION_WHOLE)&&(~carry)&&(object_in_front == G_EMPTY)) begin
            player_state <=P_NOTHING;
        end else if ((player_state == P_ONION_CHOPPED)&&(~carry)) begin
            player_state <=P_NOTHING;
        end else if ((player_state == P_POT_EMPTY)&&(~carry)) begin
            player_state <=P_NOTHING;
        end else if ((player_state == P_POT_EMPTY)&&(chop)&&(object_in_front == G_ONION_CHOPPED)) begin
            player_state <= P_POT_RAW;
        end else if ((player_state == P_POT_RAW)&&(~carry)&&(object_in_front == G_EMPTY)) begin
            player_state <=P_NOTHING;
        end else if (player_state == P_POT_COOKED) begin
            if ((object_in_front == G_BOWL_EMPTY)&&(chop)) begin
                player_state <=P_POT_EMPTY;
            end else if (object_in_front == G_EMPTY) begin
                player_state <=P_NOTHING;
            end
        end else if (player_state == P_BOWL_EMPTY) begin
            if ((~carry)&&(object_in_front == G_EMPTY)) begin
                player_state <=P_NOTHING;
            end else if ((chop)&&(object_in_front == G_POT_COOKED)) begin
                player_state <=P_BOWL_FULL;
            end
        end else if ((player_state == P_BOWL_FULL)&&(~carry)&&(object_in_front == G_EMPTY)) begin
            player_state <=P_NOTHING;
        end else if ((player_state == P_EXT_OFF)&&(~carry)&&(object_in_front == G_EMPTY)) begin
            player_state <=P_NOTHING; 
        end else if ((player_state == P_EXT_OFF)&&(chop)) begin
            player_state <= P_EXT_ON;
        end else if ((player_state == P_EXT_ON)&&(~chop)) begin
            player_state <= P_EXT_OFF;
        end
       
    end

    
endmodule //action