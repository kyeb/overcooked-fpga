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
    
    parameter LEFT_GAP = 10;
    parameter RIGHT_GAP = 10;
    parameter TOP_GAP = 5;
    parameter BOTTOM_GAP = 5;
    parameter IMAGE_WIDTH = 32;
                   
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
            player_direction <= UP; //left, right, above, below
            if ((player_loc_y>138)&&((((player_loc_y+IMAGE_WIDTH-BOTTOM_GAP)<(player_a_y+TOP_GAP+4)) //above
                                    ||((player_loc_y+TOP_GAP)>(player_a_y+IMAGE_WIDTH-BOTTOM_GAP))) //below*
                                    ||((player_loc_x+IMAGE_WIDTH-RIGHT_GAP)<(player_a_x+LEFT_GAP+4)) //left of object
                                    ||((player_loc_x+LEFT_GAP+4)>(player_a_x+IMAGE_WIDTH-RIGHT_GAP))) //right
                                  &&((((player_loc_y+IMAGE_WIDTH-BOTTOM_GAP)<(player_b_y+TOP_GAP+4)) //above
                                    ||((player_loc_y+TOP_GAP)>(player_b_y+IMAGE_WIDTH-BOTTOM_GAP))) //below*
                                    ||((player_loc_x+IMAGE_WIDTH-RIGHT_GAP)<(player_b_x+LEFT_GAP+4)) //left of object
                                    ||((player_loc_x+LEFT_GAP+4)>(player_b_x+IMAGE_WIDTH-RIGHT_GAP))) //right
                                  &&((((player_loc_y+IMAGE_WIDTH-BOTTOM_GAP)<(player_c_y+TOP_GAP+4)) //above
                                    ||((player_loc_y+TOP_GAP)>(player_c_y+IMAGE_WIDTH-BOTTOM_GAP))) //below*
                                    ||((player_loc_x+IMAGE_WIDTH-RIGHT_GAP)<(player_c_x+LEFT_GAP+4)) //left of object
                                    ||((player_loc_x+LEFT_GAP+4)>(player_c_x+IMAGE_WIDTH-RIGHT_GAP))))  begin
                    player_loc_y <= player_loc_y-4;  //move 4 pixels up
            end
        end else if (down) begin //down button
            player_direction <= DOWN; // above, to the right, to the left
            if ((player_loc_y<311)&&((((player_loc_y+IMAGE_WIDTH-BOTTOM_GAP)<(player_a_y+TOP_GAP)) //above*
                                    ||((player_loc_y+TOP_GAP+4)>(player_a_y+IMAGE_WIDTH-BOTTOM_GAP))) //below
                                    ||((player_loc_x+IMAGE_WIDTH-RIGHT_GAP)<(player_a_x+LEFT_GAP+4)) //left of object
                                    ||((player_loc_x+LEFT_GAP+4)>(player_a_x+IMAGE_WIDTH-RIGHT_GAP)))
                                  &&((((player_loc_y+IMAGE_WIDTH-BOTTOM_GAP)<(player_b_y+TOP_GAP)) //above*
                                    ||((player_loc_y+TOP_GAP+4)>(player_b_y+IMAGE_WIDTH-BOTTOM_GAP))) //below
                                    ||((player_loc_x+IMAGE_WIDTH-RIGHT_GAP)<(player_b_x+LEFT_GAP+4)) //left of object
                                    ||((player_loc_x+LEFT_GAP+4)>(player_b_x+IMAGE_WIDTH-RIGHT_GAP)))
                                  &&((((player_loc_y+IMAGE_WIDTH-BOTTOM_GAP)<(player_c_y+TOP_GAP)) //above*
                                    ||((player_loc_y+TOP_GAP+4)>(player_c_y+IMAGE_WIDTH-BOTTOM_GAP))) //below
                                    ||((player_loc_x+IMAGE_WIDTH-RIGHT_GAP)<(player_c_x+LEFT_GAP+4)) //left of object
                                    ||((player_loc_x+LEFT_GAP+4)>(player_c_x+IMAGE_WIDTH-RIGHT_GAP))))   begin //right
                    player_loc_y <= player_loc_y+4; //move 4 pixel down
            end
            
            
        //x direction
        end else if (left) begin //left button
            player_direction <= LEFT; //can pass under, can pass over
            if ((player_loc_x>130)&&((((player_loc_y+IMAGE_WIDTH-BOTTOM_GAP)<(player_a_y+TOP_GAP+4)) //above
                                    ||((player_loc_y+TOP_GAP+4)>(player_a_y+IMAGE_WIDTH-BOTTOM_GAP))) //below
                                    ||((player_loc_x+IMAGE_WIDTH-RIGHT_GAP)<(player_a_x+LEFT_GAP+4)) //left of object
                                    ||((player_loc_x+LEFT_GAP)>(player_a_x+IMAGE_WIDTH-RIGHT_GAP))) //right of object*
                                  &&((((player_loc_y+IMAGE_WIDTH-BOTTOM_GAP)<(player_b_y+TOP_GAP+4)) //above
                                    ||((player_loc_y+TOP_GAP+4)>(player_b_y+IMAGE_WIDTH-BOTTOM_GAP)))  //below
                                    ||((player_loc_x+IMAGE_WIDTH-RIGHT_GAP)<(player_b_x+LEFT_GAP+4)) //left of object
                                    ||((player_loc_x+LEFT_GAP)>(player_b_x+IMAGE_WIDTH-RIGHT_GAP))) //right of object*
                                  &&((((player_loc_y+IMAGE_WIDTH-BOTTOM_GAP)<(player_c_y+TOP_GAP+4)) //above
                                    ||((player_loc_y+TOP_GAP+4)>(player_c_y+IMAGE_WIDTH-BOTTOM_GAP))) //below
                                    ||((player_loc_x+IMAGE_WIDTH-RIGHT_GAP)<(player_c_x+LEFT_GAP+4)) //left of object
                                    ||((player_loc_x+LEFT_GAP)>(player_c_x+IMAGE_WIDTH-RIGHT_GAP))))begin //right of object*
                player_loc_x <= player_loc_x-4; //move 4 pixel left
            end
        end else if (right) begin //right button
            player_direction <= RIGHT; //left, to the right, or can pass under, can pass over
            if ((player_loc_x<466)&&((((player_loc_y+IMAGE_WIDTH-BOTTOM_GAP)<(player_a_y+TOP_GAP+4)) //above
                                    ||((player_loc_y+TOP_GAP+4)>(player_a_y+IMAGE_WIDTH-BOTTOM_GAP))) //below
                                    ||((player_loc_x+IMAGE_WIDTH-RIGHT_GAP)<(player_a_x+LEFT_GAP)) //left of object*
                                    ||((player_loc_x+LEFT_GAP+4)>(player_a_x+IMAGE_WIDTH-RIGHT_GAP)))
                                  &&((((player_loc_y+IMAGE_WIDTH-BOTTOM_GAP)<(player_b_y+TOP_GAP+4)) //above
                                    ||((player_loc_y+TOP_GAP+4)>(player_b_y+IMAGE_WIDTH-BOTTOM_GAP))) //below
                                    ||((player_loc_x+IMAGE_WIDTH-RIGHT_GAP)<(player_b_x+LEFT_GAP)) //left of object*
                                    ||((player_loc_x+LEFT_GAP+4)>(player_b_x+IMAGE_WIDTH-RIGHT_GAP)))
                                  &&((((player_loc_y+IMAGE_WIDTH-BOTTOM_GAP)<(player_c_y+TOP_GAP+4)) //above
                                    ||((player_loc_y+TOP_GAP+4)>(player_c_y+IMAGE_WIDTH-BOTTOM_GAP))) //below
                                    ||((player_loc_x+IMAGE_WIDTH-RIGHT_GAP)<(player_c_x+LEFT_GAP)) //left of object*
                                    ||((player_loc_x+LEFT_GAP+4)>(player_c_x+IMAGE_WIDTH-RIGHT_GAP)))) begin //right of object
                player_loc_x <= player_loc_x+4; //move 4 pixel right
            end
        end else begin //else same position
            player_loc_y <= player_loc_y;
            player_loc_x <= player_loc_x;
        end
    
    end             
                   
endmodule