module pixel_to_grid_tb ();

//inputs
logic [9:0] x_coord;
logic [8:0] y_coord;

// outputs
logic [3:0] x_grid;
logic [2:0] y_grid;

pixel_to_grid uut (.pixel_x(x_coord),.pixel_y(y_coord),.grid_x(x_grid),.grid_y(y_grid));

    initial begin
    x_coord = 10'd500;
    y_coord = 9'd300;
    
    #20
    
    x_coord = 10'd113;
    y_coord = 9'd304;
    
    #20 
    
    x_coord = 10'd3;
    y_coord = 9'd3;
    
    end
endmodule