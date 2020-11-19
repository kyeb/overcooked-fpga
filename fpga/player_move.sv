module player_move(input reset,
                   input vsync,
                   input left, right, up, down, chop, carry,
                   output logic [1:0] player_direction, //0 left 1 right 2 up 3 down 
                   output logic [8:0] player_loc_x,
                   output logic [8:0] player_loc_y,
                   output logic [3:0] player_state);
     
    parameter LEFT = 2'd0;
    parameter RIGHT = 2'd1;
    parameter UP = 2'd2;
    parameter DOWN = 2'd3;
                   
    always_ff @(negedge vsync) begin
        //players move between 144 and 464 pixels x
        //players move between 144 and 304 pixels y
        if (reset) begin
            player_direction <= 2'd3;
            player_loc_x <= 9'd304;
            player_loc_y <= 9'd208;
            player_state <= 4'b0;
            //y direction
        end else if(up && (player_loc_y>148)) begin //up button
            player_loc_y <= player_loc_y-4;  //move 4 pixels up
            player_direction <= UP;
        end else if (down && (player_loc_y<300)) begin //down button
            player_loc_y <= player_loc_y+4; //move 4 pixel down
            player_direction <= DOWN;
            
        //x direction
        end else if (left && (player_loc_x>148)) begin //left button
            player_loc_x <= player_loc_x-4; //move 4 pixel left
            player_direction <= LEFT;
        end else if (right && (player_loc_x<460)) begin //right button
            player_loc_x <= player_loc_x+4; //move 4 pixel right
            player_direction <= RIGHT;
        end else begin //else same position
            player_loc_y <= player_loc_y;
            player_loc_x <= player_loc_x;
        end
    
    end             
                   
endmodule