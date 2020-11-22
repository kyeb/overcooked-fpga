module check_in_front (input [3:0] grid_x,
                       input [2:0] grid_y,
                       input [1:0] player_direction,
                       input [7:0][12:0][3:0] object_grid,
                       output logic [3:0] object);
                       
    parameter LEFT = 2'd0;
    parameter RIGHT = 2'd1;
    parameter UP = 2'd2;
    parameter DOWN = 2'd3;
      
    always_comb begin
        if (player_direction == LEFT) begin
            object = object_grid[(grid_y)][(grid_x-1)];
        end else if (player_direction == RIGHT) begin
            object = object_grid[(grid_y)][(grid_x+1)];
        end else if (player_direction == UP) begin
            object = object_grid[(grid_y-1)][(grid_x)];
        end else if (player_direction == DOWN) begin
            object = object_grid[(grid_y+1)][(grid_x)];
        end  
    end

endmodule