`timescale 1ns / 1ps

module game_logic(input reset,
                  input vsync,
                  input [2:0] game_state,
                  input [7:0][12:0][3:0] object_grid,
                  input [1:0] num_players,
                  input [1:0] local_player_ID,
                  input left, right, up, down, chop, carry,
                  input [8:0] player_a_x, player_b_x, player_c_x,
                  input [8:0] player_a_y, player_b_y, player_c_y,
                  output logic [3:0] player_state,
                  output logic [1:0] player_direction, //up, down, left, right
                  output logic [8:0] player_loc_x, player_loc_y);
    
    player_move pm (.reset(reset),.vsync(vsync),.num_players(num_players), .local_player_ID(local_player_ID),
                    .left(left), .right(right), .up(up), .down(down), .chop(chop), .carry(carry), .game_state(game_state),
                    .player_a_x(player_a_x), .player_a_y(player_a_y), .player_b_x(player_b_x), .player_b_y(player_b_y), 
                    .player_c_x(player_c_x), .player_c_y(player_c_y), 
                    
                    .player_direction(player_direction), .player_loc_x(player_loc_x), .player_loc_y(player_loc_y));
    
    p_state ps (.reset(reset),.vsync(vsync), .object_grid(object_grid), .chop(chop), .carry(carry),
                .player_direction(player_direction), .player_loc_x(player_loc_x), .player_loc_y(player_loc_y),
               
                .player_state(player_state));
                
endmodule
