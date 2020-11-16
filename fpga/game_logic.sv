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
                  output logic [7:0][12:0][3:0] object_grid,
                  output logic [7:0][12:0][3:0] time_grid,
                  output logic [7:0] time_left,
                  output logic [9:0] point_total, 
                  output logic [3:0] orders,
                  output logic [3:0][4:0] order_times,
                  output logic [2:0][7:0] team_name, 
                  output logic [1:0] player_direction,
                  output logic [8:0] player_loc_x,
                  output logic [8:0] player_loc_y,
                  output logic [3:0] player_state );
    
    always_ff @(posedge clock) begin   
// 0 - Welcome Menu
        if (reset) begin
            game_state <= 0;
            team_name[0]<=8'h41;
            team_name[1]<=8'h41;
            team_name[2]<=8'h41;
        end else if (game_state == 0) begin      
// Generate team name
// Start game
        
// 1 - Game Introduction
        end else if (game_state==1) begin
// Wait 5 seconds so players can view map, players can't move
// Start game
// 2 - Start Game - Timer starts, players can move
        end else if (game_state==2) begin
// 3 - Pause Game - Timer pauses, all objects freeze
        end else if (game_state==3) begin
// 4 - Finish Game - Once timer runs out
        end else if (game_state==4) begin
// Save point total to server
// Display most recent score and top scores
        end      
    end
    
//modules
    //player_move
    //action
    //time_remaining
    //pixel_to_grid
    //orders_and_points        
                  
endmodule
