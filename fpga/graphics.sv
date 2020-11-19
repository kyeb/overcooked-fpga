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
    
    input [10:0] hcount, // horizontal index of current pixel (0..1023)
    input [9:0]  vcount, // vertical index of current pixel (0..767)
    input hsync,         // XVGA horizontal sync signal (active low)
    input vsync,         // XVGA vertical sync signal (active low)
    input blank,         // XVGA blanking (1 means output black pixel)
    
    output logic hsync_out,
    output logic vsync_out,
    output logic blank_out,
    output [11:0] pixel_out);              

    // player states
    parameter P_NOTHING = 0;
    parameter P_CHOPPING = 1;
    parameter P_ONION_WHOLE = 2;
    parameter P_ONION_CHOPPED = 3;
    parameter P_POT_EMPTY = 4;
    parameter P_POT_SOUP = 5;
    parameter P_BOWL_EMPTY = 6;
    parameter P_BOWL_FULL = 7;
    parameter P_EXT_OFF = 8;
    parameter P_EXT_ON = 9;

    // grid object parameters
    parameter G_EMPTY = 0;
    parameter G_ONION_WHOLE = 1;
    parameter G_ONION_CHOPPED = 2;
    parameter G_BOWL_EMPTY = 3;
    parameter G_BOWL_FULL = 4;
    parameter G_POT_EMPTY = 5;
    parameter G_POT_RAW = 6;
    parameter G_POT_COOKED = 7;
    parameter G_POT_FIRE = 8;
    parameter G_FIRE = 9;
    parameter G_EXTINGUISHER = 10;

    // player displays
    logic [11:0] player_pixel;
    picture_blob player1 (.pixel_clk_in(clock), .x_in(player_x), .y_in(player_y), .hcount_in(hcount), 
        .vcount_in(vcount), .pixel_out(player_pixel));

    // grid logic
    logic [2:0] current_grid_x, grid_object_x;
    logic [4:0] current_grid_y, grid_object_y;
    logic [3:0] grid_state;
    pixel_to_grid p2g (.pixel_x(vcount), .pixel_y(vcount), .current_(current_grid_x), .grid_y(current_grid_y));

    // TODO: UPDATE THIS ONCE IMAGES UP
    picture_blob whole_onion (.pixel_clk_in(clock), .x_in(grid_object_x), .y_in(grid_object_y), .hcount_in(hcount), 
        .vcount_in(vcount), .pixel_out(whole_onion));

    picture_blob chopped_onion (.pixel_clk_in(clock), .x_in(grid_object_x), .y_in(grid_object_y), .hcount_in(hcount), 
        .vcount_in(vcount), .pixel_out(chopped_onion));

    picture_blob empty_bowl (.pixel_clk_in(clock), .x_in(grid_object_x), .y_in(grid_object_y), .hcount_in(hcount), 
        .vcount_in(vcount), .pixel_out(empty_bowl));

    picture_blob full_bowl (.pixel_clk_in(clock), .x_in(grid_object_x), .y_in(grid_object_y), .hcount_in(hcount), 
        .vcount_in(vcount), .pixel_out(full_bowl));

    picture_blob empty_pot (.pixel_clk_in(clock), .x_in(grid_object_x), .y_in(grid_object_y), .hcount_in(hcount), 
        .vcount_in(vcount), .pixel_out(empty_pot));

    picture_blob raw_pot (.pixel_clk_in(clock), .x_in(grid_object_x), .y_in(grid_object_y), .hcount_in(hcount), 
        .vcount_in(vcount), .pixel_out(raw_pot));

    picture_blob cooked_pot (.pixel_clk_in(clock), .x_in(grid_object_x), .y_in(grid_object_y), .hcount_in(hcount), 
        .vcount_in(vcount), .pixel_out(cooked_pot));

    picture_blob fire_pot (.pixel_clk_in(clock), .x_in(grid_object_x), .y_in(grid_object_y), .hcount_in(hcount), 
        .vcount_in(vcount), .pixel_out(fire_pot));

    picture_blob fire (.pixel_clk_in(clock), .x_in(grid_object_x), .y_in(grid_object_y), .hcount_in(hcount), 
        .vcount_in(vcount), .pixel_out(fire));

    picture_blob extinguisher (.pixel_clk_in(clock), .x_in(grid_object_x), .y_in(grid_object_y), .hcount_in(hcount), 
        .vcount_in(vcount), .pixel_out(extinguisher));

    // more grid logic
    always_comb begin
        // bounds of game grid
        if (hcount > 111 && hcount < 367) begin
            // update the grid state if we end up on a new square of the grid
            if ((hcount - 112) % 32 == 0 && (vcount - 112) % 32 == 0) begin
                grid_state = object_grid[current_grid_x][current_grid_y];
                grid_object_x = vcount;
                grid_object_y = hcount;
            end 
        end        
    
        case (grid_state)
        
            G_EMPTY: object_pixel = 0;
            G_ONION_WHOLE: object_pixel = whole_onion;
            G_ONION_CHOPPED: object_pixel = chopped_onion;
            G_BOWL_EMPTY: object_pixel = empty_bowl;
            G_BOWL_FULL: object_pixel = full_bowl;
            G_POT_EMPTY: object_pixel = empty_pot;
            G_POT_RAW: object_pixel = raw_pot;
            G_POT_COOKED: object_pixel = cooked_pot;
            G_POT_FIRE: object_pixel = fire_pot;
            G_FIRE: object_pixel = fire;
            G_EXTINGUISHER: object_pixel = extinguisher;
            default: object_pixel = 0;
            
        endcase
    
        hsync_out = hsync;
        vsync_out = vsync;
        blank_out = blank;

    end

    assign pixel_out = player_pixel + object_pixel;

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
    image_rom rom1(.clka(pixel_clk_in), .addra(image_addr), .douta(image_bits));

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
        else pixel_out <= 0;
    end
endmodule
