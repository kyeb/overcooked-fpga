module check_in_front_tb();

//inputs
logic [1:0] player_direction;
logic [3:0] grid_x;
logic [2:0] grid_y;
logic [7:0][12:0][3:0] object_grid;

//outputs
logic [3:0] object;

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
    
    parameter LEFT = 2'd0;
    parameter RIGHT = 2'd1;
    parameter UP = 2'd2;
    parameter DOWN = 2'd3;

check_in_front cf (.grid_x(grid_x),.grid_y(grid_y),.player_direction(player_direction),
                   .object_grid(object_grid),.object(object));
            
            
    initial begin
    player_direction = LEFT;
    grid_x = 1;
    grid_y = 2;
    object_grid <= 0;
    object_grid[2][0] <= G_ONION_WHOLE;
    object_grid[3][0] <= G_ONION_WHOLE;
    object_grid[6][12] <= G_BOWL_EMPTY;
    object_grid[0][8] <= G_POT_EMPTY;
    object_grid[0][9] <= G_POT_EMPTY;
    object_grid[0][10] <= G_POT_EMPTY;
    object_grid[0][11] <= G_POT_EMPTY;
    #10
    player_direction = RIGHT;
    #10
    grid_x = 11;
    grid_y = 6;
    player_direction = RIGHT;

end

endmodule
