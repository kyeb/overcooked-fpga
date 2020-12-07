module pixel_to_grid(
    input [9:0] pixel_x,
    input [8:0] pixel_y,
    output logic [3:0] grid_x,
    output logic [2:0] grid_y);
    
    assign grid_x = (pixel_x - 112) >> 5;
    assign grid_y = (pixel_y - 112) >> 5;

endmodule