`timescale 1ns / 1ps

module action(input reset,
              input vsync,
              input [1:0] clear_space,
              input [2:0] game_state,
              
              input [1:0] player1_direction, player2_direction, player3_direction, player4_direction,
              input [8:0] player1_x, player2_x, player3_x, player4_x,
              input [8:0] player1_y, player2_y, player3_y, player4_y,
              input [3:0] player1_state, player2_state, player3_state, player4_state,
                         
              output logic [7:0][12:0][3:0] object_grid,
              output logic [3:0][3:0] time_grid); //board1, board2, pots1-2
              
    parameter LEFT = 2'd0;
    parameter RIGHT = 2'd1;
    parameter UP = 2'd2;
    parameter DOWN = 2'd3;
    
    parameter WELCOME = 0;
    parameter START = 1;
    parameter PLAY = 2;
    parameter PAUSE = 3;
    parameter FINISH = 4;
    
    // grid object parameters
    parameter G_EMPTY = 0;
    parameter G_ONION_WHOLE = 1;
    parameter G_ONION_CHOPPED = 2;
    parameter G_BOWL_EMPTY = 3;
    parameter G_BOWL_FULL = 4;
    parameter G_POT_EMPTY = 5;
    parameter G_POT_RAW = 6;
    parameter G_POT_COOKED = 7;
    parameter G_POT_FIRE = 8;
    parameter G_FIRE = 9;
    parameter G_EXTINGUISHER = 10;
    
    // player states
    parameter P_NOTHING = 0;
    parameter P_CHOPPING = 1;
    parameter P_ONION_WHOLE = 2;
    parameter P_ONION_CHOPPED = 3;
    parameter P_POT_EMPTY = 4;
    parameter P_POT_RAW = 5;
    parameter P_POT_COOKED = 6;
    parameter P_BOWL_EMPTY = 7;
    parameter P_BOWL_FULL = 8;
    parameter P_EXT_OFF = 9;
    parameter P_EXT_ON = 10;
    
    //fire state
    parameter F_NONE = 0;
    parameter F_RAW = 1;
    parameter F_COOKED = 2;
    parameter F_FIRE = 3;
    
    logic [3:0] grid1_x, grid2_x, grid3_x, grid4_x;
    logic [2:0] grid1_y, grid2_y, grid3_y, grid4_y;
    logic [3:0] object_in_front1, object_in_front2, object_in_front3, object_in_front4;
    logic [3:0] x1_front, x2_front, x3_front, x4_front;
    logic [2:0] y1_front, y2_front, y3_front, y4_front;
    logic [3:0] old_player1_state, old_player2_state, old_player3_state, old_player4_state;
    
    logic [1:0] fire_state1, fire_state0;                     
    logic [3:0] go, restart;
    logic [1:0] fire_go, fire_restart;
    logic [1:0][3:0] fire_left;
    
    //timers for chopping and cooking length
    time_remaining #(.GIVEN_TIME(3)) b3 (.vsync(vsync), .timer_go(go[3]), .restart(restart[3]), .time_left(time_grid[3]));
    time_remaining #(.GIVEN_TIME(3)) b2 (.vsync(vsync), .timer_go(go[2]), .restart(restart[2]), .time_left(time_grid[2]));
    time_remaining #(.GIVEN_TIME(10)) p1 (.vsync(vsync), .timer_go(go[1]), .restart(restart[1]), .time_left(time_grid[1]));
    time_remaining #(.GIVEN_TIME(10)) p0 (.vsync(vsync), .timer_go(go[0]), .restart(restart[0]), .time_left(time_grid[0]));
    
    //time until pot catches fire
    time_remaining #(.GIVEN_TIME(5)) f1 (.vsync(vsync), .timer_go(fire_go[1]), .restart(fire_restart[1]), .time_left(fire_left[1]));
    time_remaining #(.GIVEN_TIME(5)) f0 (.vsync(vsync), .timer_go(fire_go[0]), .restart(fire_restart[0]), .time_left(fire_left[0]));
    
    //player 1
    pixel_to_grid p2g1 (.pixel_x((player1_x+16)), .pixel_y((player1_y+16)), .grid_x(grid1_x), .grid_y(grid1_y));
    check_in_front cf1 (.grid_x(grid1_x),.grid_y(grid1_y),.player_direction(player1_direction),
                        .object_grid(object_grid),.object(object_in_front1));
    grid_in_front gf1 (.grid_x(grid1_x),.grid_y(grid1_y),.player_direction(player1_direction),
                       .x_front(x1_front),.y_front(y1_front));    
     
    //player 2              
    pixel_to_grid p2g2 (.pixel_x((player2_x+16)), .pixel_y((player2_y+16)), .grid_x(grid2_x), .grid_y(grid2_y));
    check_in_front cf2 (.grid_x(grid2_x),.grid_y(grid2_y),.player_direction(player2_direction),
                        .object_grid(object_grid),.object(object_in_front2));
    grid_in_front gf2 (.grid_x(grid2_x),.grid_y(grid2_y),.player_direction(player2_direction),
                       .x_front(x2_front),.y_front(y2_front));    
                   
    //player 3
    pixel_to_grid p2g3 (.pixel_x((player3_x+16)), .pixel_y((player3_y+16)), .grid_x(grid3_x), .grid_y(grid3_y));
    check_in_front cf3 (.grid_x(grid3_x),.grid_y(grid3_y),.player_direction(player3_direction),
                        .object_grid(object_grid),.object(object_in_front3));
    grid_in_front gf3 (.grid_x(grid3_x),.grid_y(grid3_y),.player_direction(player3_direction),
                       .x_front(x3_front),.y_front(y3_front));    
    
    //player 4
    pixel_to_grid p2g4 (.pixel_x((player4_x+16)), .pixel_y((player4_y+16)), .grid_x(grid4_x), .grid_y(grid4_y));
    check_in_front cf4 (.grid_x(grid4_x),.grid_y(grid4_y),.player_direction(player4_direction),
                        .object_grid(object_grid),.object(object_in_front4));
    grid_in_front gf4 (.grid_x(grid4_x),.grid_y(grid4_y),.player_direction(player4_direction),
                       .x_front(x4_front),.y_front(y4_front));    
    
    always_ff @(negedge vsync) begin
        old_player1_state <= player1_state;
        old_player2_state <= player2_state;
        old_player3_state <= player3_state;
        old_player4_state <= player4_state;
        
        if (clear_space[0]) begin
            object_grid[4][12] <= G_EMPTY;
        end else if (clear_space[1]) begin
            object_grid[3][12] <= G_EMPTY;
        end 
        
        //player 1
        if (reset) begin
            object_grid <= {8{{13{{4'b0}}}}};
            object_grid[2][0] <= G_ONION_WHOLE;
            object_grid[3][0] <= G_ONION_WHOLE;
            object_grid[6][12] <= G_BOWL_EMPTY;
            object_grid[0][8] <= G_POT_EMPTY;
            object_grid[0][10] <= G_POT_EMPTY;
            object_grid[6][0] <= G_EXTINGUISHER;
            go <= 4'b0;
            restart <= 4'b1111;
        end else if (game_state == WELCOME) begin
            object_grid <= {8{{13{{4'b0}}}}};
            object_grid[2][0] <= G_ONION_WHOLE;
            object_grid[3][0] <= G_ONION_WHOLE;
            object_grid[6][12] <= G_BOWL_EMPTY;
            object_grid[0][8] <= G_POT_EMPTY;
            object_grid[0][10] <= G_POT_EMPTY;
            object_grid[6][0] <= G_EXTINGUISHER;
            go <= 4'b0;
            restart <= 4'b1111;
        end else if (game_state != PLAY) begin
            go <= 4'b0;
            fire_go <= 2'b00;
        end else if (player1_state == P_NOTHING) begin
            if ((old_player1_state == P_CHOPPING)&&(x1_front==2)&&(y1_front==7)) begin
                go[3] <= 0;
            end else if ((old_player1_state == P_CHOPPING)&&(x1_front==4)&&(y1_front==7)) begin
                go[2] <= 0;
            end else if (old_player1_state == P_ONION_WHOLE) begin
                object_grid[y1_front][x1_front] <= G_ONION_WHOLE;
            end else if (old_player1_state == P_ONION_CHOPPED) begin
                if (object_in_front1 == G_POT_EMPTY) begin
                    object_grid[y1_front][x1_front] <= G_POT_RAW;
                end else if (object_in_front1 == G_EMPTY) begin
                    object_grid[y1_front][x1_front] <= G_ONION_CHOPPED;
                end
            end else if (old_player1_state == P_POT_EMPTY) begin
                if (object_in_front1 == G_ONION_CHOPPED) begin
                    object_grid[y1_front][x1_front] <= G_POT_RAW;
                end else if (object_in_front1 == G_EMPTY) begin
                    object_grid[y1_front][x1_front] <= G_POT_EMPTY;
                end
            end else if (old_player1_state == P_POT_RAW) begin
                object_grid[y1_front][x1_front] <= G_POT_RAW;
            end else if (old_player1_state == P_POT_COOKED) begin
                object_grid[y1_front][x1_front] <= G_POT_COOKED;
            end else if (old_player1_state == P_BOWL_EMPTY) begin
                object_grid[y1_front][x1_front] <= G_BOWL_EMPTY;
            end else if (old_player1_state == P_BOWL_FULL) begin
                object_grid[y1_front][x1_front] <= G_BOWL_FULL;
            end else if (old_player1_state == P_EXT_OFF) begin
                object_grid[y1_front][x1_front] <= G_EXTINGUISHER;
            end
        end else if (player1_state == P_CHOPPING) begin
            if ((old_player1_state == P_NOTHING)&&(x1_front==2)&&(y1_front==7)) begin
                 go[3] <= 0; restart[3] <= 1; //make sure b1 reset
            //once time runs down and onion was there, turns into chopped
            end else if ((time_grid[3] == 0)&&(object_grid[7][2] == G_ONION_WHOLE)) begin
                object_grid[7][2] <= G_ONION_CHOPPED;
                go[3] <= 0; restart[3] <= 1; //stop and restart timer
            //if time not over, but player still in position, onion there
            end else if ((grid1_x==2)&&(grid1_y==6)&&(player1_direction==DOWN)
                          &&(object_grid[7][2] == G_ONION_WHOLE))begin
                restart[3] <= 0; go[3] <= 1; //start counting down chop time
            end
            //repeat for other board
            if ((old_player1_state == P_NOTHING)&&(x1_front==4)&&(y1_front==7)) begin
                 go[2] <= 0; restart[2] <= 1; //make sure b2 reset
            end else if ((time_grid[2] == 0)&&(object_grid[7][4] == G_ONION_WHOLE)) begin
                object_grid[7][4] <= G_ONION_CHOPPED;
                go[2] <= 0; restart[2] <= 1;
            end else if ((grid1_x==4)&&(grid1_y==6)&&(player1_direction==DOWN)
                          &&(object_grid[7][4] == G_ONION_WHOLE))begin
                restart[2] <= 0; go[2] <= 1;
            end
        end else if ((player1_state == P_ONION_WHOLE)&&(old_player1_state == P_NOTHING)) begin
            if ((x1_front == 0)&&((y1_front == 2)||(y1_front == 3))) begin
                object_grid[y1_front][x1_front] <= G_ONION_WHOLE;
            end else begin
                object_grid[y1_front][x1_front] <= G_EMPTY;
            end
        end else if ((player1_state == P_ONION_CHOPPED)&&(old_player1_state == P_NOTHING)) begin
            object_grid[y1_front][x1_front] <= G_EMPTY;
        end else if (player1_state == P_POT_EMPTY) begin
            if (old_player1_state == P_NOTHING) begin
                object_grid[y1_front][x1_front] <= G_EMPTY;
            end else if (old_player1_state == P_POT_COOKED) begin
                object_grid[y1_front][x1_front] <= G_BOWL_FULL;
            end
        end else if ((player1_state == P_POT_EMPTY)&&(old_player1_state == P_NOTHING)) begin
            object_grid[y1_front][x1_front] <= G_EMPTY;
        end else if (player1_state == P_POT_RAW) begin
            if (old_player1_state == P_NOTHING) begin
                object_grid[y1_front][x1_front] <= G_EMPTY;
            end else if (old_player1_state == P_POT_EMPTY) begin
                object_grid[y1_front][x1_front] <= G_EMPTY;
            end
        end else if ((player1_state == P_POT_COOKED)&&(old_player1_state == P_NOTHING)) begin
            object_grid[y1_front][x1_front] <= G_EMPTY;
        end else if ((player1_state == P_BOWL_EMPTY)&&(old_player1_state == P_NOTHING)) begin
            if ((x1_front == 12)&&(y1_front == 6)) begin
                object_grid[y1_front][x1_front] <= G_BOWL_EMPTY;
            end else begin
                object_grid[y1_front][x1_front] <= G_EMPTY;
            end
        end else if (player1_state == P_BOWL_FULL) begin
            if (old_player1_state == P_NOTHING) begin
                object_grid[y1_front][x1_front] <= G_EMPTY;
            end else if (old_player1_state == P_BOWL_EMPTY) begin
                object_grid[y1_front][x1_front] <= G_POT_EMPTY;
            end
        end else if ((player1_state == P_EXT_OFF)&&(old_player1_state == P_NOTHING)) begin
            object_grid[y1_front][x1_front] <= G_EMPTY;
        end else if ((player1_state == P_EXT_ON)&&(object_grid[y1_front][x1_front] == G_FIRE)) begin
            object_grid[y1_front][x1_front] <= G_POT_EMPTY;
        end
        
        //player 2
        if (reset) begin
        end else if (game_state != PLAY) begin
        end else if (player2_state == P_NOTHING) begin
            if ((old_player2_state == P_CHOPPING)&&(x2_front==2)&&(y2_front==7)) begin
                go[3] <= 0;
            end else if ((old_player2_state == P_CHOPPING)&&(x2_front==4)&&(y2_front==7)) begin
                go[2] <= 0;
            end else if (old_player2_state == P_ONION_WHOLE) begin
                object_grid[y2_front][x2_front] <= G_ONION_WHOLE;
            end else if (old_player2_state == P_ONION_CHOPPED) begin
                if (object_in_front2 == G_POT_EMPTY) begin
                    object_grid[y2_front][x2_front] <= G_POT_RAW;
                end else if (object_in_front2 == G_EMPTY) begin
                    object_grid[y2_front][x2_front] <= G_ONION_CHOPPED;;
                end
            end else if (old_player2_state == P_POT_EMPTY) begin
                if (object_in_front2 == G_ONION_CHOPPED) begin
                    object_grid[y2_front][x2_front] <= G_POT_RAW;
                end else if (object_in_front2 == G_EMPTY) begin
                    object_grid[y2_front][x2_front] <= G_POT_EMPTY;
                end
            end else if (old_player2_state == P_POT_RAW) begin
                object_grid[y2_front][x2_front] <= G_POT_RAW;
            end else if (old_player2_state == P_POT_COOKED) begin
                object_grid[y2_front][x2_front] <= G_POT_COOKED;
            end else if (old_player2_state == P_BOWL_EMPTY) begin
                object_grid[y2_front][x2_front] <= G_BOWL_EMPTY;
            end else if (old_player2_state == P_BOWL_FULL) begin
                object_grid[y2_front][x2_front] <= G_BOWL_FULL;
            end else if (old_player2_state == P_EXT_OFF) begin
                object_grid[y2_front][x2_front] <= G_EXTINGUISHER;
            end
        end else if (player2_state == P_CHOPPING) begin
            if ((old_player2_state == P_NOTHING)&&(x2_front==2)&&(y2_front==7)) begin
                 go[3] <= 0; restart[3] <= 1; //make sure b1 reset
            //once time runs down and onion was there, turns into chopped
            end else if ((time_grid[3] == 0)&&(object_grid[7][2] == G_ONION_WHOLE)) begin
                object_grid[7][2] <= G_ONION_CHOPPED;
                go[3] <= 0; restart[3] <= 1; //stop and restart timer
            //if time not over, but player still in position, onion there
            end else if ((grid2_x==2)&&(grid2_y==6)&&(player2_direction==DOWN)
                          &&(object_grid[7][2] == G_ONION_WHOLE))begin
                restart[3] <= 0; go[3] <= 1; //start counting down chop time
            end
            //repeat for other board
            if ((old_player2_state == P_NOTHING)&&(x2_front==4)&&(y2_front==7)) begin
                 go[2] <= 0; restart[2] <= 1; //make sure b2 reset
            end else if ((time_grid[2] == 0)&&(object_grid[7][4] == G_ONION_WHOLE)) begin
                object_grid[7][4] <= G_ONION_CHOPPED;
                go[2] <= 0; restart[2] <= 1;
            end else if ((grid2_x==4)&&(grid1_y==6)&&(player2_direction==DOWN)
                          &&(object_grid[7][4] == G_ONION_WHOLE))begin
                restart[2] <= 0; go[2] <= 1;
            end
        end else if ((player2_state == P_ONION_WHOLE)&&(old_player2_state == P_NOTHING)) begin
            if ((x2_front == 0)&&((y2_front == 2)||(y2_front == 3))) begin
                object_grid[y2_front][x2_front] <= G_ONION_WHOLE;
            end else begin
                object_grid[y2_front][x2_front] <= G_EMPTY;
            end
        end else if ((player2_state == P_ONION_CHOPPED)&&(old_player2_state == P_NOTHING)) begin
            object_grid[y2_front][x2_front] <= G_EMPTY;
        end else if (player2_state == P_POT_EMPTY) begin
            if (old_player2_state == P_NOTHING) begin
                object_grid[y2_front][x2_front] <= G_EMPTY;
            end else if (old_player2_state == P_POT_COOKED) begin
                object_grid[y2_front][x2_front] <= G_BOWL_FULL;
            end
        end else if ((player2_state == P_POT_EMPTY)&&(old_player2_state == P_NOTHING)) begin
            object_grid[y2_front][x2_front] <= G_EMPTY;
        end else if (player2_state == P_POT_RAW) begin
            if (old_player2_state == P_NOTHING) begin
                object_grid[y2_front][x2_front] <= G_EMPTY;
            end else if (old_player2_state == P_POT_EMPTY) begin
                object_grid[y2_front][x2_front] <= G_EMPTY;
            end
        end else if ((player2_state == P_POT_COOKED)&&(old_player2_state == P_NOTHING)) begin
            object_grid[y2_front][x2_front] <= G_EMPTY;
        end else if ((player2_state == P_BOWL_EMPTY)&&(old_player2_state == P_NOTHING)) begin
            if ((x2_front == 12)&&(y2_front == 6)) begin
                object_grid[y2_front][x2_front] <= G_BOWL_EMPTY;
            end else begin
                object_grid[y2_front][x2_front] <= G_EMPTY;
            end
        end else if (player2_state == P_BOWL_FULL) begin
            if (old_player2_state == P_NOTHING) begin
                object_grid[y2_front][x2_front] <= G_EMPTY;
            end else if (old_player2_state == P_BOWL_EMPTY) begin
                object_grid[y2_front][x2_front] <= G_POT_EMPTY;
            end
        end else if ((player2_state == P_EXT_OFF)&&(old_player2_state == P_NOTHING)) begin
            object_grid[y2_front][x2_front] <= G_EMPTY;
        end else if ((player2_state == P_EXT_ON)&&(object_grid[y2_front][x2_front] == G_FIRE)) begin
            object_grid[y2_front][x2_front] <= G_POT_EMPTY;
        end
        
        //player 3
        if (reset) begin
        end else if (game_state != PLAY) begin
        end else if (player3_state == P_NOTHING) begin
            if ((old_player3_state == P_CHOPPING)&&(x3_front==2)&&(y3_front==7)) begin
                go[3] <= 0;
            end else if ((old_player3_state == P_CHOPPING)&&(x3_front==4)&&(y3_front==7)) begin
                go[2] <= 0;
            end else if (old_player3_state == P_ONION_WHOLE) begin
                object_grid[y3_front][x3_front] <= G_ONION_WHOLE;
            end else if (old_player3_state == P_ONION_CHOPPED) begin
                if (object_in_front3 == G_POT_EMPTY) begin
                    object_grid[y3_front][x3_front] <= G_POT_RAW;
                end else if (object_in_front3 == G_EMPTY) begin
                    object_grid[y3_front][x3_front] <= G_ONION_CHOPPED;;
                end
            end else if (old_player3_state == P_POT_EMPTY) begin
                if (object_in_front3 == G_ONION_CHOPPED) begin
                    object_grid[y3_front][x3_front] <= G_POT_RAW;
                end else if (object_in_front3 == G_EMPTY) begin
                    object_grid[y3_front][x3_front] <= G_POT_EMPTY;
                end
            end else if (old_player3_state == P_POT_RAW) begin
                object_grid[y3_front][x3_front] <= G_POT_RAW;
            end else if (old_player3_state == P_POT_COOKED) begin
                object_grid[y3_front][x3_front] <= G_POT_COOKED;
            end else if (old_player3_state == P_BOWL_EMPTY) begin
                object_grid[y3_front][x3_front] <= G_BOWL_EMPTY;
            end else if (old_player3_state == P_BOWL_FULL) begin
                object_grid[y3_front][x3_front] <= G_BOWL_FULL;
            end else if (old_player3_state == P_EXT_OFF) begin
                object_grid[y3_front][x3_front] <= G_EXTINGUISHER;
            end
        end else if (player3_state == P_CHOPPING) begin
            if ((old_player3_state == P_NOTHING)&&(x3_front==2)&&(y3_front==7)) begin
                 go[3] <= 0; restart[3] <= 1; //make sure b1 reset
            //once time runs down and onion was there, turns into chopped
            end else if ((time_grid[3] == 0)&&(object_grid[7][2] == G_ONION_WHOLE)) begin
                object_grid[7][2] <= G_ONION_CHOPPED;
                go[3] <= 0; restart[3] <= 1; //stop and restart timer
            //if time not over, but player still in position, onion there
            end else if ((grid3_x==2)&&(grid3_y==6)&&(player3_direction==DOWN)
                          &&(object_grid[7][2] == G_ONION_WHOLE))begin
                restart[3] <= 0; go[3] <= 1; //start counting down chop time
            end
            //repeat for other board
            if ((old_player3_state == P_NOTHING)&&(x3_front==4)&&(y3_front==7)) begin
                 go[2] <= 0; restart[2] <= 1; //make sure b2 reset
            end else if ((time_grid[2] == 0)&&(object_grid[7][4] == G_ONION_WHOLE)) begin
                object_grid[7][4] <= G_ONION_CHOPPED;
                go[2] <= 0; restart[2] <= 1;
            end else if ((grid3_x==4)&&(grid3_y==6)&&(player3_direction==DOWN)
                          &&(object_grid[7][4] == G_ONION_WHOLE))begin
                restart[2] <= 0; go[2] <= 1;
            end
        end else if ((player3_state == P_ONION_WHOLE)&&(old_player3_state == P_NOTHING)) begin
            if ((x3_front == 0)&&((y3_front == 2)||(y3_front == 3))) begin
                object_grid[y3_front][x3_front] <= G_ONION_WHOLE;
            end else begin
                object_grid[y3_front][x3_front] <= G_EMPTY;
            end
        end else if ((player3_state == P_ONION_CHOPPED)&&(old_player3_state == P_NOTHING)) begin
            object_grid[y3_front][x3_front] <= G_EMPTY;
        end else if (player3_state == P_POT_EMPTY) begin
            if (old_player3_state == P_NOTHING) begin
                object_grid[y3_front][x3_front] <= G_EMPTY;
            end else if (old_player3_state == P_POT_COOKED) begin
                object_grid[y3_front][x3_front] <= G_BOWL_FULL;
            end
        end else if ((player3_state == P_POT_EMPTY)&&(old_player3_state == P_NOTHING)) begin
            object_grid[y3_front][x3_front] <= G_EMPTY;
        end else if (player3_state == P_POT_RAW) begin
            if (old_player3_state == P_NOTHING) begin
                object_grid[y3_front][x3_front] <= G_EMPTY;
            end else if (old_player3_state == P_POT_EMPTY) begin
                object_grid[y3_front][x3_front] <= G_EMPTY;
            end
        end else if ((player3_state == P_POT_COOKED)&&(old_player3_state == P_NOTHING)) begin
            object_grid[y3_front][x3_front] <= G_EMPTY;
        end else if ((player3_state == P_BOWL_EMPTY)&&(old_player3_state == P_NOTHING)) begin
            if ((x3_front == 12)&&(y3_front == 6)) begin
                object_grid[y3_front][x3_front] <= G_BOWL_EMPTY;
            end else begin
                object_grid[y3_front][x3_front] <= G_EMPTY;
            end
        end else if (player3_state == P_BOWL_FULL) begin
            if (old_player3_state == P_NOTHING) begin
                object_grid[y3_front][x3_front] <= G_EMPTY;
            end else if (old_player3_state == P_BOWL_EMPTY) begin
                object_grid[y3_front][x3_front] <= G_POT_EMPTY;
            end
        end else if ((player3_state == P_EXT_OFF)&&(old_player3_state == P_NOTHING)) begin
            object_grid[y3_front][x3_front] <= G_EMPTY;
        end else if ((player3_state == P_EXT_ON)&&(object_grid[y3_front][x3_front] == G_FIRE)) begin
            object_grid[y3_front][x3_front] <= G_POT_EMPTY;
        end
        
        //player 4
        if (reset) begin
        end else if (game_state != PLAY) begin
        end else if (player4_state == P_NOTHING) begin
            if ((old_player4_state == P_CHOPPING)&&(x4_front==2)&&(y4_front==7)) begin
                go[3] <= 0;
            end else if ((old_player4_state == P_CHOPPING)&&(x4_front==4)&&(y4_front==7)) begin
                go[2] <= 0;
            end else if (old_player4_state == P_ONION_WHOLE) begin
                object_grid[y4_front][x4_front] <= G_ONION_WHOLE;
            end else if (old_player4_state == P_ONION_CHOPPED) begin
                if (object_in_front4 == G_POT_EMPTY) begin
                    object_grid[y4_front][x4_front] <= G_POT_RAW;
                end else if (object_in_front4 == G_EMPTY) begin
                    object_grid[y4_front][x4_front] <= G_ONION_CHOPPED;;
                end
            end else if (old_player4_state == P_POT_EMPTY) begin
                if (object_in_front4 == G_ONION_CHOPPED) begin
                    object_grid[y4_front][x4_front] <= G_POT_RAW;
                end else if (object_in_front4 == G_EMPTY) begin
                    object_grid[y4_front][x4_front] <= G_POT_EMPTY;
                end
            end else if (old_player4_state == P_POT_RAW) begin
                object_grid[y4_front][x4_front] <= G_POT_RAW;
            end else if (old_player4_state == P_POT_COOKED) begin
                object_grid[y4_front][x4_front] <= G_POT_COOKED;
            end else if (old_player4_state == P_BOWL_EMPTY) begin
                object_grid[y4_front][x4_front] <= G_BOWL_EMPTY;
            end else if (old_player4_state == P_BOWL_FULL) begin
                object_grid[y4_front][x4_front] <= G_BOWL_FULL;
            end else if (old_player4_state == P_EXT_OFF) begin
                object_grid[y4_front][x4_front] <= G_EXTINGUISHER;
            end
        end else if (player4_state == P_CHOPPING) begin
            if ((old_player4_state == P_NOTHING)&&(x4_front==2)&&(y4_front==7)) begin
                 go[3] <= 0; restart[3] <= 1; //make sure b1 reset
            //once time runs down and onion was there, turns into chopped
            end else if ((time_grid[3] == 0)&&(object_grid[7][2] == G_ONION_WHOLE)) begin
                object_grid[7][2] <= G_ONION_CHOPPED;
                go[3] <= 0; restart[3] <= 1; //stop and restart timer
            //if time not over, but player still in position, onion there
            end else if ((grid4_x==2)&&(grid4_y==6)&&(player4_direction==DOWN)
                          &&(object_grid[7][2] == G_ONION_WHOLE))begin
                restart[3] <= 0; go[3] <= 1; //start counting down chop time
            end
            //repeat for other board
            if ((old_player4_state == P_NOTHING)&&(x4_front==4)&&(y4_front==7)) begin
                 go[2] <= 0; restart[2] <= 1; //make sure b2 reset
            end else if ((time_grid[2] == 0)&&(object_grid[7][4] == G_ONION_WHOLE)) begin
                object_grid[7][4] <= G_ONION_CHOPPED;
                go[2] <= 0; restart[2] <= 1;
            end else if ((grid4_x==4)&&(grid4_y==6)&&(player4_direction==DOWN)
                          &&(object_grid[7][4] == G_ONION_WHOLE))begin
                restart[2] <= 0; go[2] <= 1;
            end
        end else if ((player4_state == P_ONION_WHOLE)&&(old_player4_state == P_NOTHING)) begin
            if ((x4_front == 0)&&((y4_front == 2)||(y4_front == 3))) begin
                object_grid[y4_front][x4_front] <= G_ONION_WHOLE;
            end else begin
                object_grid[y4_front][x4_front] <= G_EMPTY;
            end
        end else if ((player4_state == P_ONION_CHOPPED)&&(old_player4_state == P_NOTHING)) begin
            object_grid[y4_front][x4_front] <= G_EMPTY;
        end else if (player4_state == P_POT_EMPTY) begin
            if (old_player4_state == P_NOTHING) begin
                object_grid[y4_front][x4_front] <= G_EMPTY;
            end else if (old_player4_state == P_POT_COOKED) begin
                object_grid[y4_front][x4_front] <= G_BOWL_FULL;
            end
        end else if ((player4_state == P_POT_EMPTY)&&(old_player4_state == P_NOTHING)) begin
            object_grid[y4_front][x4_front] <= G_EMPTY;
        end else if (player4_state == P_POT_RAW) begin
            if (old_player4_state == P_NOTHING) begin
                object_grid[y4_front][x4_front] <= G_EMPTY;
            end else if (old_player4_state == P_POT_EMPTY) begin
                object_grid[y4_front][x4_front] <= G_EMPTY;
            end
        end else if ((player4_state == P_POT_COOKED)&&(old_player4_state == P_NOTHING)) begin
            object_grid[y4_front][x4_front] <= G_EMPTY;
        end else if ((player4_state == P_BOWL_EMPTY)&&(old_player4_state == P_NOTHING)) begin
            if ((x4_front == 12)&&(y4_front == 6)) begin
                object_grid[y4_front][x4_front] <= G_BOWL_EMPTY;
            end else begin
                object_grid[y4_front][x4_front] <= G_EMPTY;
            end
        end else if (player4_state == P_BOWL_FULL) begin
            if (old_player4_state == P_NOTHING) begin
                object_grid[y4_front][x4_front] <= G_EMPTY;
            end else if (old_player4_state == P_BOWL_EMPTY) begin
                object_grid[y4_front][x4_front] <= G_POT_EMPTY;
            end
        end else if ((player4_state == P_EXT_OFF)&&(old_player4_state == P_NOTHING)) begin
            object_grid[y4_front][x4_front] <= G_EMPTY;
        end else if ((player4_state == P_EXT_ON)&&(object_grid[y4_front][x4_front] == G_FIRE)) begin
            object_grid[y4_front][x4_front] <= G_POT_EMPTY;
        end
        
        //pot on the left
        if (reset) begin
            fire_state1 <= F_NONE;
            go[1] <= 0; restart[1] <= 1; //restart cook time
            fire_go[1] <= 0; fire_restart[1] <= 1; //restart combustion time
        //if the space becomes empty, or pot is empty, no fire, reset counters
        end else if ((object_grid[0][8] == G_EMPTY)||(object_grid[0][8] == G_POT_EMPTY)) begin
            fire_go[1] <= 0; fire_restart[1] <= 1;
            go[1] <= 0; restart[1] <= 1;
            fire_state1 <= F_NONE;
        // if an uncooked pot is place on stove, start cook timer
        end else if ((fire_state1 == F_NONE)&&(object_grid[0][8] == G_POT_RAW)) begin
            fire_state1 <= F_RAW;
            go[1] <= 0; restart[1] <= 1;
        // count cook timer, pot is cooking
        end else if (fire_state1 == F_RAW) begin
            go[1] <= 1; restart[1] <= 0;
            //if pot is removed, return to begining
            if (object_grid[0][8] == G_EMPTY) begin
                go[1] <= 0; restart[1] <= 1;
                fire_state1 <= F_NONE;
            //if cook time is ended, move to fire danger
            end else if (time_grid[1] == 0) begin ///////////////////
                fire_state1 <= F_COOKED;
                object_grid[0][8] <= G_POT_COOKED;
                fire_go[1] <= 0; fire_restart[1] <= 1;
            end
        //start combustion timer
        end else if (fire_state1 == F_COOKED) begin
            fire_go[1] <= 1; fire_restart[1] <= 0;
            //if pot is removed, restart timer
            if ((object_grid[0][8] == G_EMPTY)||(object_grid[0][8] == G_POT_EMPTY)) begin
                fire_go[1] <= 0; fire_restart[1] <= 1;
                fire_state1 <= F_NONE;
                go[1] <= 0; restart[1] <= 1;
            //combust when timer ends
            end else if (fire_left[1] == 0) begin
                fire_state1 <= F_FIRE;
                object_grid[0][8] <= G_FIRE;
                go[1] <= 0; restart[1] <= 1;
                fire_go[1] <= 0; fire_restart[1] <= 1;
            end
        end else if ((fire_state1 == F_FIRE)&&(object_grid[0][8]!=G_FIRE)) begin
                fire_state1 <= F_NONE;
                go[1] <= 0; restart[1] <= 1;
                fire_go[1] <= 0; fire_restart[1] <= 1;
        end
        
        //pot on the right
        if (reset) begin
            fire_state0 <= F_NONE;
            go[0] <= 0; restart[0] <= 1; //restart cook time
            fire_go[0] <= 0; fire_restart[0] <= 1; //restart combustion time
        //if the space becomes empty, or pot is empty, no fire, reset counters
        end else if ((object_grid[0][10] == G_EMPTY)||(object_grid[0][10] == G_POT_EMPTY)) begin
            fire_go[0] <= 0; fire_restart[0] <= 1;
            go[0] <= 0; restart[0] <= 1;
            fire_state0 <= F_NONE;
        // if an uncooked pot is place on stove, start cook timer
        end else if ((fire_state0 == F_NONE)&&(object_grid[0][10] == G_POT_RAW)) begin
            fire_state0 <= F_RAW;
            go[0] <= 0; restart[0] <= 1;
        // count cook timer, pot is cooking
        end else if (fire_state0 == F_RAW) begin
            go[0] <= 1; restart[0] <= 0;
            //if pot is removed, return to begining
            if (object_grid[0][10] == G_EMPTY) begin
                go[0] <= 0; restart[0] <= 1;
                fire_state0 <= F_NONE;
            //if cook time is ended, move to fire danger
            end else if (time_grid[0] == 0) begin
                fire_state0 <= F_COOKED;
                object_grid[0][10] <= G_POT_COOKED;
                fire_go[0] <= 0; fire_restart[0] <= 1;
            end
        //start combustion timer
        end else if (fire_state0 == F_COOKED) begin
            fire_go[0] <= 1; fire_restart[0] <= 0;
            //if pot is removed, restart timer
            if ((object_grid[0][10] == G_EMPTY)||(object_grid[0][10] == G_POT_EMPTY)) begin
                fire_go[0] <= 0; fire_restart[0] <= 1;
                fire_state0 <= F_NONE;
                go[0] <= 0; restart[0] <= 1;
            //combust when timer ends
            end else if (fire_left[0] == 0) begin
                fire_state0 <= F_FIRE;
                object_grid[0][10] <= G_FIRE;
                go[0] <= 0; restart[0] <= 1;
                fire_go[0] <= 0; fire_restart[0] <= 1;
            end
        end else if ((fire_state0 == F_FIRE)&&(object_grid[0][10]!=G_FIRE)) begin
                fire_state0 <= F_NONE;
                go[0] <= 0; restart[0] <= 1;
                fire_go[0] <= 0; fire_restart[0] <= 1;
        end
        
        
    end

    
endmodule //action