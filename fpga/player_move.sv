`timescale 1ns / 1ps

module player_move(input reset,
                   input vsync,
                   input left, right, up, down, chop, carry,
                   input [2:0] game_state,
                   output logic [1:0] player_direction, //0 left 1 right 2 up 3 down 
                   output logic [8:0] player_loc_x,
                   output logic [8:0] player_loc_y);
     
    parameter LEFT = 2'd0;
    parameter RIGHT = 2'd1;
    parameter UP = 2'd2;
    parameter DOWN = 2'd3;
    
    parameter WELCOME = 0;
    parameter START = 1;
    parameter PLAY = 2;
    parameter PAUSE = 3;
    parameter FINISH = 4;
                   
    always_ff @(negedge vsync) begin
        //players move between 144 and 464 pixels x
        //players move between 144 and 304 pixels y
        if (reset) begin
            player_direction <= 2'd3;
            player_loc_x <= 9'd304;
            player_loc_y <= 9'd208;
        end else if (game_state != PLAY) begin
            player_loc_y <= player_loc_y;
            player_loc_x <= player_loc_x;
            //y direction
        end else if(up) begin //up button
            player_direction <= UP;
            if (player_loc_y>148) begin
                player_loc_y <= player_loc_y-4;  //move 4 pixels up
            end
        end else if (down) begin //down button
            player_direction <= DOWN;
            if (player_loc_y<300) begin
                player_loc_y <= player_loc_y+4; //move 4 pixel down
            end
            
            
        //x direction
        end else if (left) begin //left button
            player_direction <= LEFT;
            if (player_loc_x>148) begin
                player_loc_x <= player_loc_x-4; //move 4 pixel left
            end
        end else if (right) begin //right button
            player_direction <= RIGHT;
            if (player_loc_x<460) begin
                player_loc_x <= player_loc_x+4; //move 4 pixel right
            end
        end else begin //else same position
            player_loc_y <= player_loc_y;
            player_loc_x <= player_loc_x;
        end
    
    end             
                   
endmodule