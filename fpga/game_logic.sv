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
                  
    logic [3:0] w_state;
    
    always_ff @(posedge clock) begin
        if (reset) begin
            game_state <= 0;
            team_name[0]<=8'h41;
            team_name[1]<=8'h41;
            team_name[2]<=8'h41;
            w_state = 0;   
// 0 - Welcome Menu
        end else if (game_state == 0) begin 
            //state 0: letter 1
            if (w_state == 0) begin      
                if (chop == 1) begin
                    w_state <= 4'd11;
                end else if (up == 1) begin //decrease letter
                    w_state <= 4'd1;
                    if (team_name[2] == 8'h41) begin
                        team_name[2] <= 8'h5A;
                    end else begin
                        team_name[2] <= team_name[2]-1;
                    end
                end else if (down == 1) begin //increase letter
                    w_state <= 4'd2;
                    if (team_name[2] == 8'h5A) begin
                        team_name[2] <= 8'h41;
                    end else begin
                        team_name[2] <= team_name[2]+1;
                    end
                end else if (right == 1) begin
                    w_state <= 4'd3;
                end
            //state 1: decrease
            end else if ((w_state == 4'd1)&&(up==0)) begin
                w_state <= 4'd0; 
            //state 2: increase
            end else if ((w_state == 4'd2)&&(down==0)) begin
                w_state <= 4'd0; 
            //state 3: transition 1 forward
            end else if ((w_state == 3)&&(right == 0)) begin
                w_state <= 4'd4;
            //state 12: transition 1 backward
            end else if ((w_state == 4'd12)&&(left == 0)) begin
                w_state <= 0;
            //state 4: letter 2
            end else if (w_state == 4) begin
                if (chop == 1) begin
                    w_state <= 4'd11;
                end else if (up == 1) begin //decrease letter
                    w_state <= 4'd5;
                    if (team_name[1] == 8'h41) begin
                        team_name[1] <= 8'h5A;
                    end else begin
                        team_name[0] <= team_name[1]-1;
                    end
                end else if (down == 1) begin //increase letter
                    w_state <= 4'd6;
                    if (team_name[1] == 8'h5A) begin
                        team_name[1] <= 8'h41;
                    end else begin
                        team_name[1] <= team_name[1]+1;
                    end
                end else if (right == 1) begin
                    w_state <= 4'd7;
                end else if (left == 1) begin
                    w_state <= 4'd12;
                end
            //state 5: decrease
            end else if ((w_state == 4'd5)&&(up==0)) begin
                w_state <= 4'd4;
            //state 6
            end else if ((w_state == 4'd6)&&(down==0)) begin
                w_state <= 4'd4;
            //state 7: transition 2
            end else if (w_state == 7) begin
                if (right == 0) begin
                    w_state <= 4'd8;
                end else if (left == 0) begin
                    w_state <= 4'd4;
                end
            //state 8: third letter
            end else if (w_state == 8) begin
                if (chop == 1) begin
                    w_state <= 4'd11;
                end else if (up == 1) begin //decrease letter
                    w_state <= 4'd9;
                    if (team_name[0] == 8'h41) begin
                        team_name[0] <= 8'h5A;
                    end else begin
                        team_name[0] <= team_name[0]-1;
                    end
                end else if (down == 1) begin //increase letter
                    w_state <= 4'd10;
                    if (team_name[0] == 8'h5A) begin
                        team_name[0] <= 8'h41;
                    end else begin
                        team_name[0] <= team_name[0]+1;
                    end
                end else if (right == 1) begin
                    w_state <= 4'd11;
                end else if (left == 1) begin
                    w_state <= 4'd7;
                end
            //state 9: decrease
            end else if ((w_state == 4'd9)&&(up==0)) begin
                w_state <= 4'd8;
            //state 10: increase
            end else if  ((w_state == 4'd10)&&(down==0)) begin
                w_state <= 4'd8;
            //state 11: going to next state
            end else if ((w_state == 4'd11)&&(chop==0)) begin
                game_state <= 3'b1;
                w_state <= 4'd0;
            end     
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
