`timescale 1ns / 1ps

module action(input reset,
              input vsync,
              input [1:0] num_players,
              input left, right, up, down, chop, carry,
              input [2:0] game_state,
              input [1:0] player_direction, //up, down, left, right
              input [8:0] player_loc_x,
              input [8:0] player_loc_y,
              output logic [3:0] player_state,
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
    
    logic [3:0] grid_x;
    logic [2:0] grid_y;
    logic [3:0] object_in_front;
    logic [3:0] x_front;
    logic [2:0] y_front;
    
    pixel_to_grid p2g (.pixel_x({0,(player_loc_x+16)}), .pixel_y((player_loc_y+16)), 
                       .grid_x(grid_x), .grid_y(grid_y));
    
    check_in_front cf (.grid_x(grid_x),.grid_y(grid_y),.player_direction(player_direction),
                    .object_grid(object_grid),.object(object_in_front));
                    
    grid_in_front (.grid_x(grid_x),.grid_y(grid_y),.player_direction(player_direction),
                   .x_front(x_front),.y_front(y_front));               
                    
    logic [5:0] go;
    logic [5:0] restart;
    time_remaining #(.GIVEN_TIME(5)) b1 (.vsync(vsync), .timer_go(go[5]), .restart(restart[5]), .time_left(time_grid[5]));
    time_remaining #(.GIVEN_TIME(5)) b2 (.vsync(vsync), .timer_go(go[4]), .restart(restart[4]), .time_left(time_grid[4]));
    time_remaining #(.GIVEN_TIME(10)) p1 (.vsync(vsync), .timer_go(go[3]), .restart(restart[3]), .time_left(time_grid[3]));
    time_remaining #(.GIVEN_TIME(10)) p2 (.vsync(vsync), .timer_go(go[2]), .restart(restart[2]), .time_left(time_grid[2]));
    time_remaining #(.GIVEN_TIME(10)) p3 (.vsync(vsync), .timer_go(go[1]), .restart(restart[1]), .time_left(time_grid[1]));
    time_remaining #(.GIVEN_TIME(10)) p4 (.vsync(vsync), .timer_go(go[0]), .restart(restart[0]), .time_left(time_grid[0]));
                       
    always_ff @(negedge vsync) begin
        if (reset) begin
            player_state <= P_NOTHING;
            object_grid <= 0;
            object_grid[2][0] <= G_ONION_WHOLE;
            object_grid[3][0] <= G_ONION_WHOLE;
            object_grid[6][12] <= G_BOWL_EMPTY;
            object_grid[0][8] <= G_POT_EMPTY;
            object_grid[0][9] <= G_POT_EMPTY;
            object_grid[0][10] <= G_POT_EMPTY;
            object_grid[0][11] <= G_POT_EMPTY;
            go <= 0;
            restart <= 6'b111_111;
        
        end else if (player_state == P_NOTHING) begin
            if (chop) begin
                player_state <= P_CHOPPING;
                restart[5] <= 1; //make sure b1 reset
                restart[4] <= 1; //make sure b2 reset
            end else if ((object_in_front == G_ONION_WHOLE) && (carry)) begin
                player_state <= P_ONION_WHOLE;
                object_grid[y_front][x_front] <= G_EMPTY;
            end else if ((object_in_front == G_ONION_CHOPPED) && (carry)) begin
                player_state <= P_ONION_CHOPPED;
                object_grid[y_front][x_front] <= G_EMPTY;
            end else if ((object_in_front == G_POT_EMPTY) && (carry)) begin
                player_state <= P_POT_EMPTY;
                object_grid[y_front][x_front] <= G_EMPTY;
            end else if ((object_in_front == G_POT_RAW) && (carry)) begin
                player_state <= P_POT_RAW;
                object_grid[y_front][x_front] <= G_EMPTY;
            end else if ((object_in_front == G_POT_COOKED) && (carry)) begin
                player_state <= P_POT_COOKED;
                object_grid[y_front][x_front] <= G_EMPTY;
            end else if ((object_in_front == G_BOWL_EMPTY) && (carry)) begin
                player_state <= P_BOWL_EMPTY;
                object_grid[y_front][x_front] <= G_EMPTY;
            end else if ((object_in_front == G_BOWL_FULL) && (carry)) begin
                player_state <= P_BOWL_FULL;
                object_grid[y_front][x_front] <= G_EMPTY;
            end else if ((object_in_front == G_EXTINGUISHER) && (carry)) begin
                player_state <= P_EXT_OFF;
                object_grid[y_front][x_front] <= G_EMPTY;
            end
        
        end else if (player_state == P_CHOPPING) begin
            if (~chop) begin
                player_state <= P_NOTHING;
                go[5] <= 0;
                go[4] <= 0;
            end
            //once time runs down and onion was there, turns into chopped
            if ((time_grid[5] == 0)&&(object_grid[7][2] == G_ONION_WHOLE)) begin
                object_grid[7][2] <= G_ONION_CHOPPED;
                go[5] <= 0; //stop timer
                restart[5] <= 1; //restart timer
            //if time not over, player in position, onion there
            end else if ((grid_x==2)&&(grid_y==6)&&(player_direction==DOWN)
                          &&(object_grid[7][2] == G_ONION_WHOLE))begin
                restart[5] <= 0; 
                go[5] <= 1; //start counting down chop time
            end
            //repeat for other board
            if ((time_grid[4] == 0)&&(object_grid[7][4] == G_ONION_WHOLE)) begin
                object_grid[7][4] <= G_ONION_CHOPPED;
                go[4] <= 0;
                restart[4] <= 1;
            end else if ((grid_x==4)&&(grid_y==6)&&(player_direction==DOWN)
                          &&(object_grid[7][4] == G_ONION_WHOLE))begin
                restart[4] <= 0;
                go[4] <= 1;
            end
        
        end else if ((player_state == P_ONION_WHOLE)&&(~carry)&&(object_in_front == G_EMPTY)) begin
                player_state <=P_NOTHING;
                object_grid[y_front][x_front] <= G_ONION_WHOLE;
        
        //if playe ris holding whole onion and drops it, put it in pot or put down
        end else if ((player_state == P_ONION_CHOPPED)&&(~carry)) begin
            if (object_in_front == G_POT_EMPTY) begin
                player_state <=P_NOTHING;
                object_grid[y_front][x_front] <= G_POT_RAW;
            end else if (object_in_front == G_EMPTY) begin
                player_state <=P_NOTHING;
                object_grid[y_front][x_front] <= G_ONION_CHOPPED;;
            end
        
        end else if (player_state == P_POT_EMPTY) begin
            player_state <=P_NOTHING;
            object_grid[y_front][x_front] <= G_POT_EMPTY;
        end else if (player_state == P_POT_RAW) begin
            player_state <=P_NOTHING;
            object_grid[y_front][x_front] <= G_POT_RAW;
        end else if (player_state == P_POT_COOKED) begin
            player_state <=P_NOTHING;
            object_grid[y_front][x_front] <= G_POT_COOKED;
        end else if (player_state == P_BOWL_EMPTY) begin
            player_state <=P_NOTHING;
            object_grid[y_front][x_front] <= G_BOWL_EMPTY;
        end else if (player_state == P_BOWL_FULL) begin
            player_state <=P_NOTHING;
            object_grid[y_front][x_front] <= G_BOWL_FULL;
        end else if (player_state == P_EXT_OFF) begin
            player_state <=P_NOTHING;
            object_grid[y_front][x_front] <= G_EXTINGUISHER;
        end else if (player_state == P_EXT_ON) begin
        
        
        end
    
    
    end


//player state
//update grid
//cooking time, fire

endmodule //action

module grid_in_front (input [3:0] grid_x,
                       input [2:0] grid_y,
                       input [1:0] player_direction,
                       output logic [3:0] x_front,
                       output logic [2:0] y_front);
                       
    parameter LEFT = 2'd0;
    parameter RIGHT = 2'd1;
    parameter UP = 2'd2;
    parameter DOWN = 2'd3;
      
    always_comb begin
        if (player_direction == LEFT) begin
            x_front = grid_x-1;
            y_front = grid_y;
        end else if (player_direction == RIGHT) begin
            x_front = grid_x+1;
            y_front = grid_y;
        end else if (player_direction == UP) begin
            x_front = grid_x;
            y_front = grid_y-1;
        end else if (player_direction == DOWN) begin
            x_front = grid_x;
            y_front = grid_y+1;
        end  
    end

endmodule


