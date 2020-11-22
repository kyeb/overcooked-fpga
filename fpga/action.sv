`timescale 1ns / 1ps

module action(input reset,
              input vsync,
              input [1:0] num_players,
              input left, right, up, down, chop, carry,
              input [2:0] game_state,
              input [1:0] player_direction, //up, down, left, right
              input [8:0] player_loc_x,
              input [8:0] player_loc_y,
              output logic [3:0] player_state,
              output logic [7:0][12:0][3:0] object_grid,
              output logic [7:0][12:0][3:0] time_grid);
              
    parameter LEFT = 2'd0;
    parameter RIGHT = 2'd1;
    parameter UP = 2'd2;
    parameter DOWN = 2'd3;
    
    parameter WELCOME = 0;
    parameter START = 1;
    parameter PLAY = 2;
    parameter PAUSE = 3;
    parameter FINISH = 4;
    
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
    
    // player states
    parameter P_NOTHING = 0;
    parameter P_CHOPPING = 1;
    parameter P_ONION_WHOLE = 2;
    parameter P_ONION_CHOPPED = 3;
    parameter P_POT_EMPTY = 4;
    parameter P_POT_SOUP = 5;
    parameter P_BOWL_EMPTY = 6;
    parameter P_BOWL_FULL = 7;
    parameter P_EXT_OFF = 8;
    parameter P_EXT_ON = 9;
    
    logic [3:0] grid_x;
    logic [2:0] grid_y;
    logic [3:0] object_in_front;
    
    pixel_to_grid p2g (.pixel_x({0,player_loc_x}), .pixel_y(player_loc_y), .grid_x(grid_x), .grid_y(grid_y));
    
    check_in_front (.grid_x(grid_x),.grid_y(grid_y),.player_direction(player_direction),
                    .object_grid(object_grid),.object(object_in_front));
                       
    always_ff @(negedge vsync) begin
        if (reset) begin
            player_state <= P_NOTHING;
            object_grid <= 0;
            object_grid[2][0] <= G_ONION_WHOLE;
            object_grid[3][0] <= G_ONION_WHOLE;
            object_grid[6][12] <= G_BOWL_EMPTY;
            object_grid[0][8] <= G_POT_EMPTY;
            object_grid[0][9] <= G_POT_EMPTY;
            object_grid[0][10] <= G_POT_EMPTY;
            object_grid[0][11] <= G_POT_EMPTY;
            time_grid <= {8{{13{{4'hf}}}}};
        end else if (player_state == P_NOTHING) begin
            if (chop) begin
                player_state <= P_CHOPPING;
            end else if ((object_in_front == G_ONION_WHOLE) && (carry)) begin
                player_state <= P_ONION_WHOLE;
            end
        end else if ((player_state == P_ONION_WHOLE)&&(~carry)) begin
            player_state <=P_NOTHING;
        end
    
    
    end


//player state
//update grid
//cooking time, fire

endmodule