//inputs: reset, clock, player_type, num_players
        //inputs for each player: left, right, up, down, chop, carry
        
        //output: game state, grid of objects, grid of object times, time left, point total, orders, order times, team_name
        //output for each player:  player_direction, player_location, player_state

module game_logic(input reset,
                  input clock,
                  input frame_update,
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
                  output logic [1:0] player_direction, //up, down, left, right
                  output logic [8:0] player_loc_x,
                  output logic [8:0] player_loc_y,
                  output logic [3:0] player_state);
                  
    parameter START = 5*100_000_000;//5*clock
    logic [3:0] w_state;
    logic [10:0] start_counter;
    logic timer_go;
    
    player_move pm (.clock(clock),.reset(reset),.frame_update(frame_update),.left(left), 
                    .right(right), .up(up), .down(down), .chop(chop), .carry(carry),
                    .player_direction(player_direction), .player_loc_x(player_loc_x),
                    .player_loc_y(player_loc_y),.player_state(player_state));
    
    always_ff @(posedge clock) begin
        if (reset) begin
            game_state <= 0;
            team_name[0]<=8'h41;
            team_name[1]<=8'h41;
            team_name[2]<=8'h41;
            w_state = 0; 
            object_grid <= {{8{{13{{4'h0}}}}}};
            time_grid <= {{8{{13{4'hf}}}}};
            time_left <= 8'd150;
            point_total <= 10'd0;
            orders <= 4'b0;
            order_times <= {{4{5'b11111}}};
            player_direction <= 2'b1;
            player_loc_x <= 9'd304;
            player_loc_y <= 9'd208;
            player_state <= 0;
              
// 0 - Welcome Menu
// Generate team name
// Start game -> press chop to start
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
                game_state <= 3'b1;
                w_state <= 4'd0;
                object_grid <= {{8{{13{{4'h0}}}}}};
            end     

        
// 1 - Game Introduction
// Wait 5 seconds so players can view map, players can't move
// Start game
        end else if (game_state==1) begin
            if (start_counter == START) begin
                game_state <= 2;
                start_counter <= 0;
                
                //initial conditions
                object_grid[2][0] <= 4'b1; //initial onions
                object_grid[3][0] <= 4'b1;
                object_grid[6][12] <= 4'd3;//initial bowl
                time_grid <= {{8{{13{4'hf}}}}};
                time_left <= 8'd150;
                point_total <= 10'd0;
                orders <= 4'b0;
                order_times <= {{4{5'b11111}}};
                player_direction <= 2'b1;
                player_loc_x <= 9'd304;
                player_loc_y <= 9'd208;
                player_state <= 0;
            end else begin
                start_counter <= start_counter+1;
            end
            
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
