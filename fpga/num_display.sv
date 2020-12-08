module num_display
#(parameter WIDTH = 5, HEIGHT = 7) (
    input pixel_clk_in,
    input [11:0] time_left, point_total,
    input [10:0] x_in, hcount_in,
    input [9:0] y_in, vcount_in,
    output logic [11:0] pixel_out);

    blob sc (.color_in(12'hFF0), .width(32), .height(32), .x_in(50), .hcount_in(hcount), 
        .y_in(415), .vcount_in(vcount), .pixel_out(score_pixel));
      
    blob tl (.color_in(12'h00F), .width(32), .height(32), .x_in(575), .hcount_in(hcount), 
        .y_in(415), .vcount_in(vcount), .pixel_out(time_pixel));
      
      
    logic [8:0] image_addr;
      
endmodule