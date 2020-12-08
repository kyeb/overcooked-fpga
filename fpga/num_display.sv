module num_display
#(parameter WIDTH = 5, HEIGHT = 7) (
    input pixel_clk_in,
    input [11:0] time_left, point_total,
    input [10:0] hcount,
    input [9:0] vcount,
    output logic [11:0] pixel_out);
  
    logic [11:0] score_pixel, time_pixel;
    logic [8:0] t2_image_addr, t1_image_addr, t0_image_addr, p2_image_addr, p1_image_addr, p0_image_addr, image_addr; 
    logic [7:0] image_bits, red_mapped, green_mapped, blue_mapped;
    // calculate rom address and read the location
    
    logic [10:0] t2_x = 57;
    logic [10:0] t1_x = 63;
    logic [10:0] t0_x = 69;

    logic [10:0] p2_x = 582;
    logic [10:0] p1_x = 588;
    logic [10:0] p0_x = 564;

    logic [9:0] y = 427;

    assign t2_image_addr = ((hcount-t2_x) + (vcount-y) * WIDTH) + time_left[11:8] * 35;
    assign t1_image_addr = ((hcount-t1_x) + (vcount-y) * WIDTH) + time_left[7:4] * 35;
    assign t0_image_addr = ((hcount-t0_x) + (vcount-y) * WIDTH) + time_left[3:0] * 35; 
    assign p2_image_addr = ((hcount-p2_x) + (vcount-y) * WIDTH) + point_total[11:8] * 35;
    assign p1_image_addr = ((hcount-p1_x) + (vcount-y) * WIDTH) + point_total[7:4] * 35;
    assign p0_image_addr = ((hcount-p0_x) + (vcount-y) * WIDTH) + point_total[3:0] * 35;
     
    blob sc (.color_in(12'hFF0), .width(32), .height(32), .x_in(50), .hcount_in(hcount), 
        .y_in(415), .vcount_in(vcount), .pixel_out(score_pixel));
      
    blob tl (.color_in(12'h00F), .width(32), .height(32), .x_in(575), .hcount_in(hcount), 
        .y_in(415), .vcount_in(vcount), .pixel_out(time_pixel));
    
    always_comb begin
        if (t2_x <= hcount && hcount < t1_x) 
            image_addr = t2_image_addr;
        else if (t1_x <= hcount && hcount < t0_x) 
            image_addr = t1_image_addr;
        else if (t0_x <= hcount && hcount < t0_x + 5) 
            image_addr = t0_image_addr;
        else if (p2_x <= hcount && hcount < p1_x) 
            image_addr = p2_image_addr;
        else if (p1_x <= hcount && hcount < p0_x) 
            image_addr = p1_image_addr;
        else if (p0_x <= hcount && hcount < p0_x + 5)
            image_addr = p0_image_addr;                
    end

    nums_coe bg (.clka(pixel_clk_in), .addra(image_addr), .douta(image_bits));
     
    red_coe rcm (.clka(pixel_clk_in), .addra(image_bits), .douta(red_mapped));
    green_coe gcm (.clka(pixel_clk_in), .addra(image_bits), .douta(green_mapped));
    blue_coe bcm (.clka(pixel_clk_in), .addra(image_bits), .douta(blue_mapped));

    always_ff @ (posedge pixel_clk_in) begin
        if ((hcount_in >= x_in && hcount_in < (x_in+WIDTH)) && (vcount_in >= y_in && vcount_in < (y_in+HEIGHT)))
            pixel_out <= {red_mapped[7:4], green_mapped[7:4], blue_mapped[7:4]};
        else
            pixel_out <= 12'h000;
    end
      
endmodule