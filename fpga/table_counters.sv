module tables #(parameter WIDTH = 437, HEIGHT = 277)     
    (input pixel_clk_in,
     input [9:0] hcount_in,
     input [8:0] vcount_in,
     output logic [11:0] pixel_out);
     
    logic [9:0] x_in = 'd101;
    logic [8:0] y_in = 'd101;
    
    logic [16:0] image_addr;   
    logic [7:0] image_bits, red_mapped, green_mapped, blue_mapped;
    logic [11:0] last_pixel;

    // calculate rom address and read the location
    assign image_addr = (hcount_in-x_in) + (vcount_in-y_in) * WIDTH;
     
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
