module main_FPGA_control(input reset,
                         input vsync,
                         input pause,
                         input left, right, up, down, chop, carry,
                         input timer_go,
                         input [7:0] time_left,
   
                         input [1:0] player1_direction, player2_direction, player3_direction, player4_direction,
                         input [8:0] player1_x, player2_x, player3_x, player4_x,
                         input [8:0] player1_y, player2_y, player3_y, player4_y,
                         input [3:0] player1_state, player2_state, player3_state, player4_state,
  
                         output logic [2:0][7:0] team_name,
                         output logic [2:0] game_state, // welcome, game, etc
                         output logic [9:0] point_total,
                         output logic [7:0][12:0][3:0] object_grid, 
                         output logic [3:0][3:0] time_grid,
                         output logic [3:0] orders, // how many orders are currently on the screen
                         output logic [3:0][4:0] order_times);
   
   
    
    parameter WELCOME = 0;
    parameter START = 1;
    parameter PLAY = 2;
    parameter PAUSE = 3;
    parameter FINISH = 4;
    
    parameter START_TIMER = 5*60;//5*vsync
    
    logic [3:0] w_state;
    logic [30:0] start_counter;
    logic [1:0] clear_space;
    logic [1:0][3:0] check_spaces;
    assign check_spaces[1] = object_grid[5][12];
    assign check_spaces[0] = object_grid[4][12];
    
    orders_and_points op (.vsync(vsync),.reset(reset),.check_spaces(check_spaces),
                          .timer_go(timer_go),
                          
                          .clear_space(clear_space), .point_total(point_total),.orders(orders),.order_times(order_times));
    
    action act (.reset(reset),.vsync(vsync), .game_state(game_state), .clear_space(clear_space),
                .player1_direction(player1_direction), .player1_x(player1_x), .player1_y(player1_y), .player1_state(player1_state),
                .player2_direction(player2_direction), .player2_x(player2_x), .player2_y(player2_y), .player2_state(player2_state),
                .player3_direction(player3_direction), .player3_x(player3_x), .player3_y(player3_y), .player3_state(player3_state),
                .player4_direction(player4_direction), .player4_x(player4_x), .player4_y(player4_y), .player4_state(player4_state),
                
                .object_grid(object_grid), .time_grid(time_grid));
    
    always_ff @(negedge vsync) begin
        if (reset) begin
            game_state <= 0;
            team_name[0]<=8'h41;
            team_name[1]<=8'h41;
            team_name[2]<=8'h41;
            w_state = 0; 
            start_counter <= 0;
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
                w_state <= 4'd0;
            end
       
        // 1 - Game Introduction
        // Wait 5 seconds so players can view map, players can't move
        // Start game
        end else if (game_state==START) begin
            if (start_counter == START_TIMER) begin
                game_state <= PLAY;
                start_counter <= 0;
            end else begin
                start_counter <= start_counter+1;
            end
            
        // 2 - Play Game - Timer starts, players can move
        end else if (game_state==PLAY) begin
            if (time_left == 0) begin
                game_state <= FINISH;
            end else if (pause) begin
                game_state <= PAUSE;
            end
        // 3 - Pause Game - Timer pauses, all objects freeze
        end else if (game_state==PAUSE) begin
            if (~pause) begin
                game_state <= PLAY;
            end
        // 4 - Finish Game - Once timer runs out, press any button to restart
        end else if ((game_state==FINISH)&&((left)||(right)||(up)||(down)||(chop))) begin
            game_state <= WELCOME;
        end      
    end      
                  
endmodule