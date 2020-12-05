`timescale 1ns / 1ps

module player_move(input reset,
                   input vsync,
                   input left, right, up, down, chop, carry,
                   input [2:0] game_state,
                   input [1:0] num_players,
                   input [1:0] local_player_ID,
                   input [8:0] player_a_x, player_b_x, player_c_x,
                   input [8:0] player_a_y, player_b_y, player_c_y,
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
        if ((reset)||(game_state==WELCOME)) begin
            player_direction <= 2'd3;
            if (num_players == 2'b0) begin
                player_loc_x <= 9'd304;
                player_loc_y <= 9'd208;
            end else if (num_players == 2'b01) begin
                if (local_player_ID == 2'b0) begin
                    player_loc_x <= 9'd208;
                    player_loc_y <= 9'd208;
                end else if (local_player_ID == 2'b01) begin
                    player_loc_x <= 9'd400;
                    player_loc_y <= 9'd208;
                end
            end else if (num_players == 2'b10) begin
                if (local_player_ID == 2'b0) begin
                    player_loc_x <= 9'd304;
                    player_loc_y <= 9'd176;
                end else if (local_player_ID == 2'b01) begin
                    player_loc_x <= 9'd208;
                    player_loc_y <= 9'd272;
                end else if (local_player_ID == 2'b10) begin
                    player_loc_x <= 9'd400;
                    player_loc_y <= 9'd272;
                end
            end else if (num_players == 2'b11) begin
                if (local_player_ID == 2'b0) begin
                    player_loc_x <= 9'd208;
                    player_loc_y <= 9'd176;
                end else if (local_player_ID == 2'b01) begin
                    player_loc_x <= 9'd400;
                    player_loc_y <= 9'd176;
                end else if (local_player_ID == 2'b10) begin
                    player_loc_x <= 9'd208;
                    player_loc_y <= 9'd272;
                end else if (local_player_ID == 2'b11) begin
                    player_loc_x <= 9'd400;
                    player_loc_y <= 9'd272;
                end
            end
        end else if ((game_state != PLAY)||chop) begin
            player_loc_y <= player_loc_y;
            player_loc_x <= player_loc_x;
            
        
        //y direction
        end else if (up) begin //up button
            player_direction <= UP;
            if ((player_loc_y>138)&&((player_loc_y>(player_a_y+16))||(player_loc_x>(player_a_x+16))||(player_a_x>(player_loc_x+16)))
                                  &&((player_loc_y>(player_b_y+16))||(player_loc_x>(player_b_x+16))||(player_b_x>(player_loc_x+16)))
                                  &&((player_loc_y>(player_c_y+16))||(player_loc_x>(player_c_x+16))||(player_c_x>(player_loc_x+16)))) begin
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