`timescale 1ns / 1ps

module game_logic(input reset,
                  input clock,
                  input vsync,
                  input [1:0] local_player_ID,
                  input [1:0] num_players,
                  input left, right, up, down, chop, carry,
                  output logic [2:0] game_state,
                  output logic [2:0][7:0] team_name, 
                  output logic [7:0][12:0][3:0] object_grid,
                  output logic [5:0][3:0] time_grid,
                  output logic [3:0] player_state,
                  output logic [7:0] time_left,
                  output logic [9:0] point_total, 
                  output logic [3:0] orders,
                  output logic [3:0][4:0] order_times,
                  output logic [1:0] player_direction, //up, down, left, right
                  output logic [8:0] player_loc_x,
                  output logic [8:0] player_loc_y);
                  
    parameter WELCOME = 0;
    parameter START = 1;
    parameter PLAY = 2;
    parameter PAUSE = 3;
    parameter FINISH = 4;
    
    parameter START_TIMER = 5*60;//5*clock
    
    logic [3:0] w_state;
    logic [30:0] start_counter;
    logic timer_go;
    logic restart_timer;
    logic [1:0] clear_space;
    logic [1:0][3:0] check_spaces;
    assign check_spaces[1] = object_grid[5][12];
    assign check_spaces[0] = object_grid[4][12];
    
    //modules
    //action
    //pixel_to_grid
    //orders_and_points  
    
    player_move pm (.reset(reset),.vsync(vsync),.left(left), 
                    .right(right), .up(up), .down(down), .chop(chop), .carry(carry), .state(game_state),
                    .player_direction(player_direction), .player_loc_x(player_loc_x),
                    .player_loc_y(player_loc_y));
                    
   time_remaining tr (.vsync(vsync),.timer_go(timer_go),.restart(restart_timer),
                      .time_left(time_left));
    
   orders_and_points op (.vsync(vsync),.reset(reset),.check_spaces(check_spaces),
                         .timer_go(timer_go),.clear_space(clear_space), 
                         .point_total(point_total),.orders(orders),.order_times(order_times));
    
    always_ff @(negedge vsync) begin
        if (reset) begin
            game_state <= 0;
            team_name[0]<=8'h41;
            team_name[1]<=8'h41;
            team_name[2]<=8'h41;
            w_state = 0; 
            restart_timer <= 1;
            timer_go <= 0;
// 0 - Welcome Menu
// Generate team name
// Start game -> press chop to start
        end else if (game_state == WELCOME) begin 
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
                w_state <= 4'd0;
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
            //state 7: transition 2 forward
            end else if (w_state == 7) begin
                if (right == 0) begin
                    w_state <= 4'd8;
                end
            //state 13: transition 2 backward
            end else if ((w_state == 4'd13)&&(left == 0)) begin
                w_state <= 4'd4;
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
                    w_state <= 4'd13;
                end
            //state 9: decrease
            end else if ((w_state == 4'd9)&&(up==0)) begin
                w_state <= 4'd8;
            //state 10: increase
            end else if  ((w_state == 4'd10)&&(down==0)) begin
                w_state <= 4'd8;
            //state 11: going to next state
            end else if ((w_state == 4'd11)&&(chop==0)) begin
                game_state <= START;
                restart_timer <= 1;
                timer_go <= 0;
                w_state <= 4'd0;
            end     

        
// 1 - Game Introduction
// Wait 5 seconds so players can view map, players can't move
// Start game
        end else if (game_state==START) begin
            if (start_counter == START_TIMER) begin
                game_state <= PLAY;
                start_counter <= 0;
                restart_timer <= 0;
                timer_go <= 1;
            end else begin
                start_counter <= start_counter+1;
            end
            
// 2 - Play Game - Timer starts, players can move
        end else if (game_state==PLAY) begin
            timer_go <= 1;
            if (time_left == 0) begin
                game_state <= FINISH;
            end else if (chop&&carry) begin
                game_state <= PAUSE;
            end
// 3 - Pause Game - Timer pauses, all objects freeze
        end else if (game_state==PAUSE) begin
            timer_go <= 0;
            if (chop && ~carry) begin
                game_state <= PLAY;
            end
// 4 - Finish Game - Once timer runs out
        end else if (game_state==FINISH) begin
// Save point total to server
// Display most recent score and top scores
        end      
    end      
                  
endmodule
