`timescale 1ns / 1ps
//inputs: reset, clock, player_type, num_players
        //inputs for each player: left, right, up, down, chop, carry
        
        //output: game state, grid of objects, grid of object times, time left, point total, orders, order times, team_name
        //output for each player:  player_direction, player_location, player_state

module game_logic(input reset,
                  input clock,
                  input [1:0] local_player_ID,
                  input [1:0] num_players,
                  input left, right, up, down, chop, carry,
                  output logic [2:0] game_state,
                  output logic object_grid, //need dimensions
                  output logic time_grid, //need dimensions
                  output logic time_left, //size?
                  output logic point_total, //size?
                  output logic orders, //size?
                  output logic order_times, //size?
                  output logic team_name, //size?
                  output logic [1:0] player_direction,
                  output logic player_loc_x, player_loc_y,
                  output logic player_state );
    
// 0 - Welcome Menu
// Select how many players
// Designate FPGA to be primary/secondary
// Generate team name
// Start game
// 1 - Game Introduction
// Wait 5 seconds so players can view map, players can't move
// Start game
// 2 - Start Game - Timer starts, players can move
// 3 - Pause Game - Timer pauses, all objects freeze
// 4 - Finish Game - Once timer runs out
// Save point total to server
// Display most recent score and top scores      

//modules
    //player_move
    //action
    //time_remaining
    //pixel_to_grid
    //orders_and_points        
                  
endmodule
