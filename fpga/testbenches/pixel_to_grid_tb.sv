module pixel_to_grid_tb ();

//inputs
logic [8:0] x_coord;
logic [8:0] y_coord;

// outputs
logic [3:0] x_grid;
logic [3:0] y_grid;

pixel_to_grid uut (.x_coord(x_coord),.y_coord(y_coord),.x_grid(x_grid),.y_grid(y_grid));

    initial begin
    x_coord = 9'd500;
    y_coord = 9'd300;
    
    #20
    
    x_coord = 9'd113;
    y_coord = 9'd304;
    
    #20 
    
    x_coord = 9'd0;
    y_coord = 9'd0;
    
    end
endmodule