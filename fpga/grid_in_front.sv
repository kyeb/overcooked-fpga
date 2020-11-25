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