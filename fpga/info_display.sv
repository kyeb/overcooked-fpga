`timescale 1ns / 1ps

module info_display(
    input pixel_clk_in,
    input [9:0] x_in, hcount,
    input [8:0] y_in, vcount,
    input order,
    input [4:0] order_time,
    output logic [11:0] pixel_out);
    
    localparam WIDTH = 32;
    localparam HEIGHT = 32;
    
    logic [11:0] image_addr;   
    logic [7:0] object_bits, red_mapped, green_mapped, blue_mapped;
    logic [11:0] color_in, color_out;
    logic [9:0] bx = x_in + 1;
    logic [8:0] by = y_in + 1;

    blob cd (.color_in(color_in), .width(order_time), .height(3), .x_in(bx), .y_in(by), .hcount_in(hcount), .vcount_in(vcount), .pixel_out(color_out));

    // calculate rom address and read the location
    assign image_addr = (hcount-x_in) + (vcount-y_in) * WIDTH;
    
    full_bowl_coe fb (.clka(pixel_clk_in), .addra(image_addr), .douta(object_bits));
    
    red_coe rcm (.clka(pixel_clk_in), .addra(object_bits), .douta(red_mapped));
    green_coe gcm (.clka(pixel_clk_in), .addra(object_bits), .douta(green_mapped));
    blue_coe bcm (.clka(pixel_clk_in), .addra(object_bits), .douta(blue_mapped));
         
    always_ff @ (posedge pixel_clk_in) begin
    
        if (order_time > 20) begin
            color_in = 12'h070;
        end else if (order_time > 10) begin
            color_in = 12'hFF0;
        end else begin
            color_in = 12'h700;
        end
    
        if ((hcount >= x_in && hcount < (x_in+WIDTH)) && (vcount >= y_in && vcount < (y_in+HEIGHT)))
            if (order) begin
                if (color_out != 12'h700 && color_out != 12'hFF0 && color_out != 12'h070) begin
                    pixel_out <= {red_mapped[7:4], green_mapped[7:4], blue_mapped[7:4]};
                end else begin
                    pixel_out <= color_out;
                end
            end else begin
                pixel_out <= 0;
            end
        else begin
            pixel_out <= 0;
        end
    end
    
endmodule