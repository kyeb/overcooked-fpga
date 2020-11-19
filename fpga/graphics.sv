`timescale 1ns / 1ps

module graphics(
    input clock,
    input reset,
    
    // some global stuff
    input [1:0] local_player_ID,
    input [2:0][7:0] team_name,
    input [1:0] num_players,
    input logic [2:0] game_state, // welcome, game, etc
   
    // overall game
    input [7:0] time_left,
    input [9:0] point_total,
    input [7:0][12:0][3:0] object_grid, time_grid,
    input [3:0] orders, // how many orders are currently on the screen
    input [3:0][4:0] order_times,
    
    // player input
    input [1:0] player_direction,
    input [8:0] player_x,
    input [8:0] player_y,
    input [3:0] player_state,
    
    input [10:0] hcount_in, // horizontal index of current pixel (0..1023)
    input [9:0]  vcount_in, // vertical index of current pixel (0..767)
    input hsync_in,         // XVGA horizontal sync signal (active low)
    input vsync_in,         // XVGA vertical sync signal (active low)
    input blank_in,         // XVGA blanking (1 means output black pixel)
    
    output logic hsync_out,
    output logic vsync_out,
    output logic blank_out,
    output [11:0] pixel_out);              
    
    always_comb begin
        hsync_out = hsync_in;
        vsync_out = vsync_in;
        blank_out = blank_in;
    end

    logic [11:0] player_pixel;
    picture_blob player1 (.pixel_clk_in(clock), .x_in(player_x), .y_in(player_y), .hcount_in(hcount_in), 
        .vcount_in(vcount_in), .pixel_out(player_pixel));

    assign pixel_out = player_pixel;

endmodule

module grid_to_pixel(
    input [2:0] grid_x,
    input [4:0] grid_y,
    output logic [9:0] pixel_x,
    output logic [8:0] pixel_y);
    
    assign pixel_x = 112 + (grid_x << 5);
    assign pixel_y = 112 + (grid_y << 5);
    
endmodule

module picture_blob
    #(parameter WIDTH = 32,     // default picture width
                HEIGHT = 32)    // default picture height
    (input pixel_clk_in,
    input [10:0] x_in,hcount_in,
    input [9:0] y_in,vcount_in,
    output logic [11:0] pixel_out);

    logic [15:0] image_addr;   // num of bits for 256*240 ROM
    logic [7:0] image_bits, red_mapped, green_mapped, blue_mapped;

    // calculate rom address and read the location
    assign image_addr = (hcount_in-x_in) + (vcount_in-y_in) * WIDTH;
    image_rom  rom1(.clka(pixel_clk_in), .addra(image_addr), .douta(image_bits));

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
        pixel_out <= {red_mapped[7:4], red_mapped[7:4], red_mapped[7:4]}; // greyscale
        //pixel_out <= {red_mapped[7:4], 8h'0}; // only red hues
        else pixel_out <= 0;
    end
endmodule
