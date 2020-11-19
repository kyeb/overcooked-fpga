module player_blob
    #(parameter WIDTH = 32,     // default picture width
                HEIGHT = 32)    // default picture height
    (input pixel_clk_in,
    input [10:0] x_in,hcount_in,
    input [9:0] y_in,vcount_in,
    input [1:0] player_direction,
    input [3:0] player_state,
    output logic [11:0] pixel_out);

    // player directions
    localparam P_LEFT = 0;
    localparam P_RIGHT = 1;
    localparam P_UP = 2;
    localparam P_DOWN = 3;

    logic [15:0] image_addr;   // num of bits for 256*240 ROM
    logic [7:0] image_bits, red_mapped, green_mapped, blue_mapped;

    logic [7:0] up_bits, down_bits, left_bits, right_bits;
    // calculate rom address and read the location
    assign image_addr = (hcount_in-x_in) + (vcount_in-y_in) * WIDTH;
    up_coe up(.clka(pixel_clk_in), .addra(image_addr), .douta(up_bits));
    down_coe down(.clka(pixel_clk_in), .addra(image_addr), .douta(down_bits));
    left_coe left(.clka(pixel_clk_in), .addra(image_addr), .douta(left_bits));
    right_coe right(.clka(pixel_clk_in), .addra(image_addr), .douta(right_bits));

    always_comb begin
        case (player_direction)
            P_LEFT: image_bits = left_bits;
            P_RIGHT: image_bits = right_bits;
            P_UP: image_bits = up_bits;
            P_DOWN: image_bits = down_bits;
        endcase
    end

    // use color map to create 4 bits R, 4 bits G, 4 bits B
    // since the image is greyscale, just replicate the red pixels
    // and not bother with the other two color maps.
    red_coe rcm (.clka(pixel_clk_in), .addra(image_bits), .douta(red_mapped));
    green_coe gcm (.clka(pixel_clk_in), .addra(image_bits), .douta(green_mapped));
    blue_coe bcm (.clka(pixel_clk_in), .addra(image_bits), .douta(blue_mapped));
     
    // note the one clock cycle delay in pixel!
    always_ff @ (posedge pixel_clk_in) begin
    if ((hcount_in >= x_in && hcount_in < (x_in+WIDTH)) &&
          (vcount_in >= y_in && vcount_in < (y_in+HEIGHT)))
        // use MSB 4 bits
        pixel_out <= {red_mapped[7:4], green_mapped[7:4], green_mapped[7:4]}; // greyscale
        // pixel_out <= {red_mapped[7:4], 8h'0}; // only red hues
        else pixel_out <= 12'hFFF;
    end
endmodule