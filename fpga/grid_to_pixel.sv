module grid_to_pixel(
    input [3:0] grid_x,
    input [2:0] grid_y,
    output logic [9:0] pixel_x,
    output logic [8:0] pixel_y);
    
    assign pixel_x = 112 + (grid_x << 5);
    assign pixel_y = 112 + (grid_y << 5);
    
endmodule