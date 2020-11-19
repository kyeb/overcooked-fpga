`timescale 1ns / 1ps

module graphics(
    input reset,
    input clock,
    
    // some global stuff
    input [1:0] local_player_ID,
    input [2:0][7:0] team_name,
    input [1:0] num_players,
    input logic [2:0] game_state, // welcome, game, etc
   
    // overall game
    input [7:0] time_left,
    input [9:0] point_total,
    input [7:0][12:0][3:0] object_grid, time_grid,
    input [3:0] orders, // how many orders are currently on the screen
    input [3:0][4:0] order_times,
    
    // player input
    input [1:0] player_direction,
    input [8:0] player_x,
    input [8:0] player_y,
    input [3:0] player_state,
    
    output pixel);              
    
endmodule
