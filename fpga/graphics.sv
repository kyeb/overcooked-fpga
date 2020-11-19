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
    
    input [10:0] hcount_in, // horizontal index of current pixel (0..1023)
    input [9:0]  vcount_in, // vertical index of current pixel (0..767)
    input hsync_in,         // XVGA horizontal sync signal (active low)
    input vsync_in,         // XVGA vertical sync signal (active low)
    input blank_in,         // XVGA blanking (1 means output black pixel)
    
    output logic hsync_out,
    output logic vsync_out,
    output logic blank_out,
    output [11:0] pixel_out);              
    
    always_comb begin
        hsync_out = hsync_in;
        vsync_out = vsync_in;
        blank_out = blank_in;
    end

endmodule
