module welcome
   #(parameter WIDTH = 246,     // default picture width
               HEIGHT = 44)    // default picture height
   (input pixel_clk_in,
    input [10:0] hcount_in,
    input [9:0] vcount_in,
    output logic [11:0] pixel_out);

    logic [15:0] image_addr;   // num of bits for 256*240 ROM
    logic [7:0] image_bits, red_mapped, green_mapped, blue_mapped;

    logic [10:0] x_in = 197;
    logic [9:0] y_in = 109;

    // calculate rom address and read the location
    assign image_addr = (hcount_in-x_in) + (vcount_in-y_in) * WIDTH;
    logo_coe (.clka(pixel_clk_in), .addra(image_addr), .douta(image_bits));

    logo_rcm rcm (.clka(pixel_clk_in), .addra(image_bits), .douta(red_mapped));
    logo_gcm gcm (.clka(pixel_clk_in), .addra(image_bits), .douta(green_mapped));
    logo_bcm bcm (.clka(pixel_clk_in), .addra(image_bits), .douta(blue_mapped));

   always_ff @ (posedge pixel_clk_in) begin
     if ((hcount_in >= x_in && hcount_in < (x_in+WIDTH)) && (vcount_in >= y_in && vcount_in < (y_in+HEIGHT)))
        pixel_out <= {red_mapped[7:4], blue_mapped[7:4], green_mapped[7:4]}; 
        else pixel_out <= 0;
   end
endmodule