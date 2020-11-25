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
              output logic [5:0][3:0] time_grid); //board1, board2, pots1-4
              
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
    
    logic [10:0] fire_counter;
    logic [9:0] pot_counter1;
    logic [9:0] pot_counter2;
    logic [9:0] pot_counter3;
    logic [9:0] pot_counter4;
    logic [1:0] fire_state;
    
    
    pixel_to_grid p2g (.pixel_x((player1_x+16)), .pixel_y((player1_y+16)), 
                       .grid_x(grid1_x), .grid_y(grid1_y));
    
    check_in_front cf (.grid_x(grid1_x),.grid_y(grid1_y),.player_direction(player1_direction),
                    .object_grid(object_grid),.object(object_in_front1));
                    
    grid_in_front gf (.grid_x(grid1_x),.grid_y(grid1_y),.player_direction(player1_direction),
                   .x_front(x1_front),.y_front(y1_front));               
                    
    logic [5:0] go;
    logic [5:0] restart;
    logic [3:0] fire_go;
    logic [3:0] fire_restart;
    logic [3:0][3:0] fire_left;
    
    time_remaining #(.GIVEN_TIME(5)) b1 (.vsync(vsync), .timer_go(go[5]), .restart(restart[5]), .time_left(time_grid[5]));
    time_remaining #(.GIVEN_TIME(5)) b2 (.vsync(vsync), .timer_go(go[4]), .restart(restart[4]), .time_left(time_grid[4]));
    time_remaining #(.GIVEN_TIME(10)) p1 (.vsync(vsync), .timer_go(go[3]), .restart(restart[3]), .time_left(time_grid[3]));
    time_remaining #(.GIVEN_TIME(10)) p2 (.vsync(vsync), .timer_go(go[2]), .restart(restart[2]), .time_left(time_grid[2]));
    time_remaining #(.GIVEN_TIME(10)) p3 (.vsync(vsync), .timer_go(go[1]), .restart(restart[1]), .time_left(time_grid[1]));
    time_remaining #(.GIVEN_TIME(10)) p4 (.vsync(vsync), .timer_go(go[0]), .restart(restart[0]), .time_left(time_grid[0]));
    
    time_remaining #(.GIVEN_TIME(10)) f3 (.vsync(vsync), .timer_go(fire_go[3]), .restart(fire_restart[3]), .time_left(fire_left[3]));
    time_remaining #(.GIVEN_TIME(10)) f2 (.vsync(vsync), .timer_go(fire_go[2]), .restart(fire_restart[2]), .time_left(fire_left[2]));
    time_remaining #(.GIVEN_TIME(10)) f1 (.vsync(vsync), .timer_go(fire_go[1]), .restart(fire_restart[1]), .time_left(fire_left[1]));
    time_remaining #(.GIVEN_TIME(10)) f0 (.vsync(vsync), .timer_go(fire_go[0]), .restart(fire_restart[0]), .time_left(fire_left[0]));
    
    always_ff @(negedge vsync) begin
        old_player1_state <= player1_state;
        old_player2_state <= player2_state;
        old_player3_state <= player3_state;
        old_player4_state <= player4_state;
        
        if (reset) begin
            object_grid <= 0;
            object_grid[2][0] <= G_ONION_WHOLE;
            object_grid[3][0] <= G_ONION_WHOLE;
            object_grid[6][12] <= G_BOWL_EMPTY;
            object_grid[0][8] <= G_POT_EMPTY;
            object_grid[0][9] <= G_POT_EMPTY;
            object_grid[0][10] <= G_POT_EMPTY;
            object_grid[0][11] <= G_POT_EMPTY;
            object_grid[6][0] <= G_EXTINGUISHER;
            go <= 6'b0;
            restart <= 6'b111_111;
        end else if (clear_space[0]) begin
            object_grid[4][12] <= G_EMPTY;
        end else if (clear_space[1]) begin
            object_grid[5][12] <= G_EMPTY;
        end else if (player1_state == P_NOTHING) begin
            if (old_player1_state == P_CHOPPING) begin
                go[5] <= 0; go[4] <= 0;
            end else if (old_player1_state == P_ONION_WHOLE) begin
                object_grid[y1_front][x1_front] <= G_ONION_WHOLE;
            end else if (old_player1_state == P_ONION_CHOPPED) begin
                if (object_in_front1 == G_POT_EMPTY) begin
                    object_grid[y1_front][x1_front] <= G_POT_RAW;
                end else if (object_in_front1 == G_EMPTY) begin
                    object_grid[y1_front][x1_front] <= G_ONION_CHOPPED;;
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
            if (old_player1_state == P_NOTHING) begin
                 go[5] <= 0; restart[5] <= 1; //make sure b1 reset
            //once time runs down and onion was there, turns into chopped
            end else if ((time_grid[5] == 0)&&(object_grid[7][2] == G_ONION_WHOLE)) begin
                object_grid[7][2] <= G_ONION_CHOPPED;
                go[5] <= 0; restart[5] <= 1; //stop and restart timer
            //if time not over, but player still in position, onion there
            end else if ((grid1_x==2)&&(grid1_y==6)&&(player1_direction==DOWN)
                          &&(object_grid[7][2] == G_ONION_WHOLE))begin
                restart[5] <= 0; go[5] <= 1; //start counting down chop time
            end
            //repeat for other board
            if (old_player1_state == P_NOTHING) begin
                 go[4] <= 0; restart[4] <= 1; //make sure b2 reset
            end else if ((time_grid[4] == 0)&&(object_grid[7][4] == G_ONION_WHOLE)) begin
                object_grid[7][4] <= G_ONION_CHOPPED;
                go[4] <= 0; restart[4] <= 1;
            end else if ((grid1_x==4)&&(grid1_y==6)&&(player1_direction==DOWN)
                          &&(object_grid[7][4] == G_ONION_WHOLE))begin
                restart[4] <= 0; go[4] <= 1;
            end
            
        end else if (player1_state == P_ONION_WHOLE) begin
            if (old_player1_state == P_NOTHING) begin
                if ((x1_front == 0)&&((y1_front == 2)||(y1_front == 3))) begin
                    object_grid[y1_front][x1_front] <= G_ONION_WHOLE;
                end else begin
                    object_grid[y1_front][x1_front] <= G_EMPTY;
                end
            end 
        end else if (player1_state == P_ONION_CHOPPED) begin
            if (old_player1_state == P_NOTHING) begin
                object_grid[y1_front][x1_front] <= G_EMPTY;
            end
        end else if (player1_state == P_POT_EMPTY) begin
            if (old_player1_state == P_NOTHING) begin
                object_grid[y1_front][x1_front] <= G_EMPTY;
            end else if (old_player1_state == P_POT_COOKED) begin
                object_grid[y1_front][x1_front] <= G_BOWL_FULL;
            end
        end else if (player1_state == P_POT_EMPTY) begin
            if (old_player1_state == P_NOTHING) begin
                object_grid[y1_front][x1_front] <= G_EMPTY;
            end
        end else if (player1_state == P_POT_RAW) begin
            if (old_player1_state == P_NOTHING) begin
                object_grid[y1_front][x1_front] <= G_EMPTY;
            end else if (old_player1_state == P_POT_EMPTY) begin
                object_grid[y1_front][x1_front] <= G_EMPTY;
            end
        end else if (player1_state == P_POT_COOKED) begin
            if (old_player1_state == P_NOTHING) begin
                object_grid[y1_front][x1_front] <= G_EMPTY;
            end
        end else if (player1_state == P_BOWL_EMPTY) begin
            if (old_player1_state == P_NOTHING) begin
                if ((x1_front == 12)&&(y1_front == 6)) begin
                    object_grid[y1_front][x1_front] <= G_BOWL_EMPTY;
                end else begin
                    object_grid[y1_front][x1_front] <= G_EMPTY;
                end
            end
        end else if (player1_state == P_BOWL_FULL) begin
            if (old_player1_state == P_NOTHING) begin
                object_grid[y1_front][x1_front] <= G_EMPTY;
            end else if (old_player1_state == P_BOWL_EMPTY) begin
                object_grid[y1_front][x1_front] <= G_POT_EMPTY;
            end
        end else if (player1_state == P_EXT_OFF) begin
            if (old_player1_state == P_NOTHING) begin
                object_grid[y1_front][x1_front] <= G_EMPTY;
            end
        end else if (player1_state == P_EXT_ON) begin
            if (object_grid[y1_front][x1_front] == G_FIRE) begin
                object_grid[y1_front][x1_front] <= G_EMPTY;
            end
        end
    end

    
endmodule //action