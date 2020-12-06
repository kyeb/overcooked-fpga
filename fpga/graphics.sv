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
    input [7:0][12:0][3:0] object_grid, 
    input [5:0][3:0] time_grid,
    input [3:0] orders, // how many orders are currently on the screen
    input [3:0][4:0] order_times,
        
    // player input
    input [1:0] player1_direction,
    input [8:0] player1_x,
    input [8:0] player1_y,
    input [3:0] player1_state,
        
    input [1:0] player2_direction,
    input [8:0] player2_x,
    input [8:0] player2_y,
    input [3:0] player2_state,

    input [1:0] player3_direction,
    input [8:0] player3_x,
    input [8:0] player3_y,
    input [3:0] player3_state,

    input [1:0] player4_direction,
    input [8:0] player4_x,
    input [8:0] player4_y,
    input [3:0] player4_state,

    input [10:0] hcount, // horizontal index of current pixel 
    input [9:0]  vcount, // vertical index of current pixel
    input hsync,         // XVGA horizontal sync signal (active low)
    input vsync,         // XVGA vertical sync signal (active low)
    input blank,         // XVGA blanking (1 means output black pixel)
        
    output logic hsync_out,
    output logic vsync_out,
    output logic blank_out,
    output logic [11:0] pixel_out);              

    // player displays
    logic [11:0] player_pixel, player1_pixel, player2_pixel, player3_pixel, player4_pixel;
    player_blob player1 (.pixel_clk_in(clock), .vsync(vsync), .x_in(player1_x), .y_in(player1_y), .hcount_in(hcount), 
        .vcount_in(vcount), .player_direction(player1_direction), .player_state(player1_state), .pixel_out(player1_pixel));

    player_blob player2 (.pixel_clk_in(clock), .vsync(vsync), .x_in(player2_x), .y_in(player2_y), .hcount_in(hcount), 
        .vcount_in(vcount), .player_direction(player2_direction), .player_state(player2_state), .pixel_out(player2_pixel));

    player_blob player3 (.pixel_clk_in(clock), .vsync(vsync), .x_in(player3_x), .y_in(player3_y), .hcount_in(hcount), 
        .vcount_in(vcount), .player_direction(player3_direction), .player_state(player3_state), .pixel_out(player3_pixel));

    player_blob player4 (.pixel_clk_in(clock), .vsync(vsync), .x_in(player4_x), .y_in(player4_y), .hcount_in(hcount), 
        .vcount_in(vcount), .player_direction(player4_direction), .player_state(player4_state), .pixel_out(player4_pixel));

    // table counters
    logic [11:0] floor_pixel;
    table_counter tables (.x_in_counter('d112), .x_in_floor('d144), .hcount_in(hcount), 
        .y_in_counter('d112), .y_in_floor('d144), .vcount_in(vcount),  
        .pixel_out(floor_pixel));

module table_counter   
    (input [10:0] x_in_counter, x_in_floor, hcount_in,
    input [9:0] y_in_counter, y_in_floor, vcount_in,
    output logic [11:0] pixel_out);

    // object graphics
    logic [11:0] object_pixel;
    logic [7:0][12:0] grid_pixels [11:0];

    logic [3:0] grid_x;
    logic [2:0] grid_y;
    
    pixel_to_grid p2g (.pixel_x(hcount), .pixel_y(vcount), .grid_x(grid_x), .grid_y(grid_y));  

    static_sprites s00 (.object_grid(object_grid), .x_in(112), .hcount(hcount), .y_in(112), .vcount(vcount), .pixel_out(grid_pixels[0][0]));
    static_sprites s01 (.object_grid(object_grid), .x_in(144), .hcount(hcount), .y_in(112), .vcount(vcount), .pixel_out(grid_pixels[0][1]));
    static_sprites s02 (.object_grid(object_grid), .x_in(176), .hcount(hcount), .y_in(112), .vcount(vcount), .pixel_out(grid_pixels[0][2]));
    static_sprites s03 (.object_grid(object_grid), .x_in(208), .hcount(hcount), .y_in(112), .vcount(vcount), .pixel_out(grid_pixels[0][3]));
    static_sprites s04 (.object_grid(object_grid), .x_in(240), .hcount(hcount), .y_in(112), .vcount(vcount), .pixel_out(grid_pixels[0][4]));
    static_sprites s05 (.object_grid(object_grid), .x_in(272), .hcount(hcount), .y_in(112), .vcount(vcount), .pixel_out(grid_pixels[0][5]));
    static_sprites s06 (.object_grid(object_grid), .x_in(304), .hcount(hcount), .y_in(112), .vcount(vcount), .pixel_out(grid_pixels[0][6]));
    static_sprites s07 (.object_grid(object_grid), .x_in(336), .hcount(hcount), .y_in(112), .vcount(vcount), .pixel_out(grid_pixels[0][7]));
    static_sprites s08 (.object_grid(object_grid), .x_in(368), .hcount(hcount), .y_in(112), .vcount(vcount), .pixel_out(grid_pixels[0][8]));
    static_sprites s09 (.object_grid(object_grid), .x_in(400), .hcount(hcount), .y_in(112), .vcount(vcount), .pixel_out(grid_pixels[0][9]));
    static_sprites s010 (.object_grid(object_grid), .x_in(432), .hcount(hcount), .y_in(112), .vcount(vcount), .pixel_out(grid_pixels[0][10]));
    static_sprites s011 (.object_grid(object_grid), .x_in(464), .hcount(hcount), .y_in(112), .vcount(vcount), .pixel_out(grid_pixels[0][11]));
    static_sprites s012 (.object_grid(object_grid), .x_in(496), .hcount(hcount), .y_in(112), .vcount(vcount), .pixel_out(grid_pixels[0][12]));
    
    static_sprites s10 (.object_grid(object_grid), .x_in(112), .hcount(hcount), .y_in(112), .vcount(vcount), .pixel_out(grid_pixels[1][0]));
    static_sprites s20 (.object_grid(object_grid), .x_in(112), .hcount(hcount), .y_in(144), .vcount(vcount), .pixel_out(grid_pixels[2][0]));
    static_sprites s30 (.object_grid(object_grid), .x_in(112), .hcount(hcount), .y_in(176), .vcount(vcount), .pixel_out(grid_pixels[3][0]));
    static_sprites s40 (.object_grid(object_grid), .x_in(112), .hcount(hcount), .y_in(208), .vcount(vcount), .pixel_out(grid_pixels[4][0]));
    static_sprites s50 (.object_grid(object_grid), .x_in(112), .hcount(hcount), .y_in(240), .vcount(vcount), .pixel_out(grid_pixels[5][0]));
    static_sprites s60 (.object_grid(object_grid), .x_in(112), .hcount(hcount), .y_in(272), .vcount(vcount), .pixel_out(grid_pixels[6][0]));

    static_sprites s112 (.object_grid(object_grid), .x_in(496), .hcount(hcount), .y_in(112), .vcount(vcount), .pixel_out(grid_pixels[1][12]));
    static_sprites s212 (.object_grid(object_grid), .x_in(496), .hcount(hcount), .y_in(144), .vcount(vcount), .pixel_out(grid_pixels[2][12]));
    static_sprites s312 (.object_grid(object_grid), .x_in(496), .hcount(hcount), .y_in(176), .vcount(vcount), .pixel_out(grid_pixels[3][12]));
    static_sprites s412 (.object_grid(object_grid), .x_in(496), .hcount(hcount), .y_in(208), .vcount(vcount), .pixel_out(grid_pixels[4][12]));
    static_sprites s512 (.object_grid(object_grid), .x_in(496), .hcount(hcount), .y_in(240), .vcount(vcount), .pixel_out(grid_pixels[5][12]));
    static_sprites s612 (.object_grid(object_grid), .x_in(496), .hcount(hcount), .y_in(272), .vcount(vcount), .pixel_out(grid_pixels[6][12]));
    
    static_sprites s70 (.object_grid(object_grid), .x_in(112), .hcount(hcount), .y_in(336), .vcount(vcount), .pixel_out(grid_pixels[7][0]));
    static_sprites s71 (.object_grid(object_grid), .x_in(144), .hcount(hcount), .y_in(336), .vcount(vcount), .pixel_out(grid_pixels[7][1]));
    static_sprites s72 (.object_grid(object_grid), .x_in(176), .hcount(hcount), .y_in(336), .vcount(vcount), .pixel_out(grid_pixels[7][2]));
    static_sprites s73 (.object_grid(object_grid), .x_in(208), .hcount(hcount), .y_in(336), .vcount(vcount), .pixel_out(grid_pixels[7][3]));
    static_sprites s74 (.object_grid(object_grid), .x_in(240), .hcount(hcount), .y_in(336), .vcount(vcount), .pixel_out(grid_pixels[7][4]));
    static_sprites s75 (.object_grid(object_grid), .x_in(272), .hcount(hcount), .y_in(336), .vcount(vcount), .pixel_out(grid_pixels[7][5]));
    static_sprites s76 (.object_grid(object_grid), .x_in(304), .hcount(hcount), .y_in(336), .vcount(vcount), .pixel_out(grid_pixels[7][6]));
    static_sprites s77 (.object_grid(object_grid), .x_in(336), .hcount(hcount), .y_in(336), .vcount(vcount), .pixel_out(grid_pixels[7][7]));
    static_sprites s78 (.object_grid(object_grid), .x_in(368), .hcount(hcount), .y_in(336), .vcount(vcount), .pixel_out(grid_pixels[7][8]));
    static_sprites s79 (.object_grid(object_grid), .x_in(400), .hcount(hcount), .y_in(336), .vcount(vcount), .pixel_out(grid_pixels[7][9]));
    static_sprites s710 (.object_grid(object_grid), .x_in(432), .hcount(hcount), .y_in(336), .vcount(vcount), .pixel_out(grid_pixels[7][10]));
    static_sprites s711 (.object_grid(object_grid), .x_in(464), .hcount(hcount), .y_in(336), .vcount(vcount), .pixel_out(grid_pixels[7][11]));
    static_sprites s712 (.object_grid(object_grid), .x_in(496), .hcount(hcount), .y_in(336), .vcount(vcount), .pixel_out(grid_pixels[7][12]));
    
    // more grid logic
    always_comb begin
        // bounds of game grid
        if (hcount > 111 && hcount < 518) begin
            // update the grid state if we end up on a new square of the grid
            if (grid_x == 0 || grid_x == 12 || grid_y == 0 || grid_y == 7) begin
                object_pixel = grid_pixels[grid_y][grid_x];
            end
        end 
        
        case (num_players)
            0: player_pixel = player1_pixel;
            1: player_pixel = player1_pixel == 12'hFFF ? player2_pixel : player1_pixel;
            2: player_pixel = player1_pixel == 12'hFFF && player2_pixel == 12'hFFF ? player3_pixel :
                              player1_pixel == 12'hFFF && player3_pixel == 12'hFFF ? player2_pixel :
                              player1_pixel;
            3: player_pixel = player1_pixel == 12'hFFF && player2_pixel == 12'hFFF && player3_pixel == 12'hFFF ? player4_pixel :
                              player1_pixel == 12'hFFF && player2_pixel == 12'hFFF && player4_pixel == 12'hFFF ? player3_pixel :
                              player1_pixel == 12'hFFF && player3_pixel == 12'hFFF && player4_pixel == 12'hFFF ? player2_pixel :
                              player1_pixel;
        endcase
        
        hsync_out = hsync;
        vsync_out = vsync;
        blank_out = blank;
//        if (player_pixel == 12'hFFF && object_pixel == 12'hFFF) begin
//            pixel_out = floor_pixel;
//        end else 
        if (player_pixel != 12'hFFF) begin
            pixel_out = player_pixel; 
        end else begin
            pixel_out = object_pixel;
        end
    end
    
endmodule
