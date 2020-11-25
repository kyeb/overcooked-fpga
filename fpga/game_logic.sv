`timescale 1ns / 1ps

module game_logic(input reset,
                  input vsync,
                  input [2:0] game_state,
                  input [7:0][12:0][3:0] object_grid,
                  input left, right, up, down, chop, carry,
                  output logic [3:0] player_state,
                  output logic [1:0] player_direction, //up, down, left, right
                  output logic [8:0] player_loc_x, player_loc_y);
    
    player_move pm (.reset(reset),.vsync(vsync),
                    .left(left), .right(right), .up(up), .down(down), .chop(chop), .carry(carry), .game_state(game_state),
                    .player_direction(player_direction), .player_loc_x(player_loc_x), .player_loc_y(player_loc_y));
    
    p_state ps (.reset(reset),.vsync(vsync), .object_grid(object_grid), .chop(chop), .carry(carry),
                .player_direction(player_direction), .player_loc_x(player_loc_x), .player_loc_y(player_loc_y),
                .player_state(player_state));
                
endmodule
