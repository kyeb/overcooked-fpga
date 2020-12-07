module table_counter   
    (input [10:0] x_in_counter, x_in_floor, hcount_in,
    input [9:0] y_in_counter, y_in_floor, vcount_in,
    output logic [11:0] pixel_out);

    parameter COUNTER_WIDTH = 416;
    parameter COUNTER_HEIGHT = 256;
    parameter COUNTER_COLOR = 12'hB70;

    parameter FLOOR_WIDTH = 352;
    parameter FLOOR_HEIGHT = 192;          
    parameter FLOOR_COLOR = 12'h971;

    always_comb begin
        if ((hcount_in >= x_in_floor && hcount_in < (x_in_floor+FLOOR_WIDTH)) && (vcount_in >= y_in_floor && vcount_in < (y_in_floor+FLOOR_HEIGHT)))
            pixel_out = FLOOR_COLOR;
        else if ((hcount_in >= x_in_counter && hcount_in < (x_in_counter+COUNTER_WIDTH)) && (vcount_in >= y_in_counter && vcount_in < (y_in_counter+COUNTER_HEIGHT)))
            pixel_out = COUNTER_COLOR;
        else 
            pixel_out = 0;
    end
endmodule

module tables #(parameter WIDTH = 417, HEIGHT = 257)     
    (input pixel_clk_in,
     input [9:0] hcount_in,
     input [8:0] vcount_in,
     output logic [11:0] pixel_out);
     
    logic [9:0] x_in = 'd112;
    logic [8:0] y_in = 'd112;
    
    logic [16:0] image_addr;   
    logic [7:0] image_bits, red_mapped, green_mapped, blue_mapped;

    // calculate rom address and read the location
    assign image_addr = (hcount_in-x_in) + (vcount_in-y_in) * WIDTH;

    bg_coe bg(.clka(pixel_clk_in), .addra(image_addr), .douta(image_bits));
     
    red_coe rcm (.clka(pixel_clk_in), .addra(image_bits), .douta(red_mapped));
    green_coe gcm (.clka(pixel_clk_in), .addra(image_bits), .douta(green_mapped));
    blue_coe bcm (.clka(pixel_clk_in), .addra(image_bits), .douta(blue_mapped));

    always_ff @ (posedge pixel_clk_in) begin
        if ((hcount_in >= x_in && hcount_in < (x_in+WIDTH)) && (vcount_in >= y_in && vcount_in < (y_in+HEIGHT)))
            pixel_out <= {red_mapped[7:4], green_mapped[7:4], blue_mapped[7:4]};
        else
            pixel_out <= 12'hFFF;
    end
     
endmodule
