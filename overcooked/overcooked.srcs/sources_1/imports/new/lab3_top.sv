`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
//
// Updated 8/10/2019 Lab 3
// Updated 8/12/2018 V2.lab5c
// Create Date: 10/1/2015 V1.0
// Design Name:
// Module Name: labkit
//
//////////////////////////////////////////////////////////////////////////////////

module labkit(
   input clk_100mhz,
   input[15:0] sw,
   input btnc, btnu, btnl, btnr, btnd,
   output logic[3:0] vga_r,
   output logic[3:0] vga_b,
   output logic[3:0] vga_g,
   output logic vga_hs,
   output logic vga_vs,
   output logic led16_b, led16_g, led16_r,
   output logic led17_b, led17_g, led17_r,
   output logic [15:0] led,
   output logic ca, cb, cc, cd, ce, cf, cg, dp,  // segments a-g, dp
   output logic [7:0] an    // Display location 0-7
   );

    // create 65mhz system clock, happens to match 1024 x 768 XVGA timing
    clk_wiz_lab3 clkdivider(.clk_in1(clk_100mhz), .clk_out1(clk_65mhz));
    
    logic [31:0] data;      //  instantiate 7-segment display; display (8) 4-bit hex
    logic [6:0] segments;
    assign {cg, cf, ce, cd, cc, cb, ca} = segments[6:0];
    
    logic game;
    
    hex_timer timer(.clk_in(clk_65mhz), .rst_in(btnc), .game(game), .hex_out(data));
    display_8hex display(.clk_in(clk_65mhz), .data_in(data), .seg_out(segments), .strobe_out(an));
    // assign seg[6:0] = segments;
    assign  dp = 1'b1;  // turn off the period

    assign led = sw;                        // turn leds on
    // assign data = {28'h0123456, sw[3:0]};   // display 0123456 + sw[3:0]
    assign led16_r = btnl;                  // left button -> red led
    assign led16_g = btnc;                  // center button -> green led
    assign led16_b = btnr;                  // right button -> blue led
    assign led17_r = btnl;
    assign led17_g = btnc;
    assign led17_b = btnr;

    logic [10:0] hcount;    // pixel on current line
    logic [9:0] vcount;     // line number
    logic hsync, vsync;
    logic [11:0] pixel;
    logic [11:0] rgb;  

    xvga xvga1(.vclock_in(clk_65mhz),.hcount_out(hcount),.vcount_out(vcount),
          .hsync_out(hsync),.vsync_out(vsync),.blank_out(blank));

    // btnc button is user reset
    logic reset;
    debounce db1(.reset_in(reset),.clock_in(clk_65mhz),.noisy_in(btnc),.clean_out(reset));
   
    // UP and DOWN buttons for pong paddle
    logic up,down;
    debounce db2(.reset_in(reset),.clock_in(clk_65mhz),.noisy_in(btnu),.clean_out(up));
    debounce db3(.reset_in(reset),.clock_in(clk_65mhz),.noisy_in(btnd),.clean_out(down));

    logic phsync,pvsync,pblank;
    pong_game pg(.vclock_in(clk_65mhz),.reset_in(reset),
                .up_in(up),.down_in(down),.pspeed_in(sw[15:12]),
                .hcount_in(hcount),.vcount_in(vcount),
                .hsync_in(hsync),.vsync_in(vsync),.blank_in(blank), .game(game),
                .phsync_out(phsync),.pvsync_out(pvsync),.pblank_out(pblank),.pixel_out(pixel));

    logic border = (hcount==0 | hcount==1023 | vcount==0 | vcount==767 |
                   hcount == 512 | vcount == 384);

    logic b,hs,vs;
    always_ff @(posedge clk_65mhz) begin
      if (sw[1:0] == 2'b01) begin
         // 1 pixel outline of visible area (white)
         hs <= hsync;
         vs <= vsync;
         b <= blank;
         rgb <= {12{border}};
      end else if (sw[1:0] == 2'b10) begin
         // color bars
         hs <= hsync;
         vs <= vsync;
         b <= blank;
         rgb <= {{4{hcount[8]}}, {4{hcount[7]}}, {4{hcount[6]}}} ;
      end else begin
         // default: pong
         hs <= phsync;
         vs <= pvsync;
         b <= pblank;
         rgb <= pixel;
      end
    end

//    assign rgb = sw[0] ? {12{border}} : pixel ; //{{4{hcount[7]}}, {4{hcount[6]}}, {4{hcount[5]}}};

    // the following lines are required for the Nexys4 VGA circuit - do not change
    assign vga_r = ~b ? rgb[11:8]: 0;
    assign vga_g = ~b ? rgb[7:4] : 0;
    assign vga_b = ~b ? rgb[3:0] : 0;

    assign vga_hs = ~hs;
    assign vga_vs = ~vs;

    // ila_0 myila(.clk(clk_65mhz), .probe0(hsync), .probe1(hcount), .probe2(pixel));

endmodule

////////////////////////////////////////////////////////////////////////////////
//
// pong_game: the game itself!
//
////////////////////////////////////////////////////////////////////////////////

module pong_game (
    input vclock_in,        // 65MHz clock
    input reset_in,         // 1 to initialize module
    input up_in,            // 1 when paddle should move up
    input down_in,          // 1 when paddle should move down
    input [3:0] pspeed_in,  // puck speed in pixels/tick 
    input [10:0] hcount_in, // horizontal index of current pixel (0..1023)
    input [9:0] vcount_in, // vertical index of current pixel (0..767)
    input hsync_in,         // XVGA horizontal sync signal (active low)
    input vsync_in,         // XVGA vertical sync signal (active low)
    input blank_in,         // XVGA blanking (1 means output black pixel)
        
    output logic game,
    output logic phsync_out,       // pong game's horizontal sync
    output logic pvsync_out,       // pong game's vertical sync
    output logic pblank_out,       // pong game's blanking
    output logic [11:0] pixel_out  // pong game's pixel  // r=11:8, g=7:4, b=3:0
    );
   
    assign phsync_out = hsync_in;
    assign pvsync_out = vsync_in;
    assign pblank_out = blank_in;

    parameter DS_R = 767; // 1023 - 256
    parameter DS_B = 527; // 767 - 240
    parameter DS_CENTER = 120;
    
    parameter PADDLE_WIDTH = 16;
    parameter PADDLE_HEIGHT = 128;
    
    // paddle
    logic [9:0] paddle_y = 320;
    logic [11:0] paddle_pixel;
    
    blob #(.WIDTH(PADDLE_WIDTH),.HEIGHT(PADDLE_HEIGHT),.COLOR(12'hFF0)) 
        paddle1(.x_in(11'd0),.y_in(paddle_y), .hcount_in(hcount_in),.vcount_in(vcount_in),
             .pixel_out(paddle_pixel));
             
             
    logic [11:0] red_pixel;
    
    blob #(.WIDTH(128), .HEIGHT(128), .COLOR(12'hF00))
        red(.x_in(448), .y_in(320), .hcount_in(hcount_in),.vcount_in(vcount_in),
             .pixel_out(red_pixel));
    
    logic [9:0] ds_y;
    logic [11:0] ds_x;
    logic [11:0] ds_pixel;
    logic [3:0] ds_velocity = pspeed_in;
    logic ds_right;
    logic ds_down;
    
    picture_blob #(.WIDTH(256), .HEIGHT(240)) 
        ds_picture (.pixel_clk_in(vclock_in), .x_in(ds_x), .y_in(ds_y), .hcount_in(hcount_in),.vcount_in(vcount_in),
            .pixel_out(ds_pixel));

    logic [11:0] blended;

    // alpha = 1/2
    alpha_blending red_puck (.image_1(red_pixel), .image_2(ds_pixel), .blended(blended));
    
    always_ff @(negedge vsync_in) begin
    
        if (reset_in) begin // resets signal
            paddle_y <= 320; // center y
            ds_y <= 264; // centers ds
            ds_x <= 384;
            ds_right <= 1;
            ds_down <= 1;
            game <= 1;
        end 
        
        else if (game) begin
            
            // paddle
            if (up_in && paddle_y > 4) begin
                paddle_y <= paddle_y - 4;
            end else if (down_in && paddle_y < 640) begin
                paddle_y <= paddle_y + 4;
            end
            
            // ds up / down
            if (ds_down && ds_y + ds_velocity < DS_B) begin // move down
                ds_y <= ds_y + ds_velocity;
            end else if (~ds_down && ds_y > ds_velocity) begin // move up
                ds_y <= ds_y - ds_velocity;
            end else begin // change vertical dircetion
                ds_down <= ~ds_down;
            end
            
            // ds left / right
            if (ds_right && ds_x + ds_velocity < DS_R) begin // move right
                ds_x <= ds_x + ds_velocity;
            end else if (~ds_right && ds_x > ds_velocity) begin // move left
                ds_x <= ds_x - ds_velocity;
            end else begin // change horizontal direction
                ds_right <= ~ds_right;
            end
            
            // checking bounce on left as lose condition
            if (ds_x <= ds_velocity) begin
                // if paddle isn't touching ball:
                if (ds_y + DS_CENTER < paddle_y || // ball above paddle
                    ds_y + DS_CENTER > paddle_y + PADDLE_HEIGHT) begin // ball below paddle
                    game <= 0; // game over
                end                
            end
             
        end
    end
    
    assign pixel_out = paddle_pixel + blended;
              
endmodule // pong_game

module alpha_blending (
    input [11:0] image_1,
    input [11:0] image_2, 
    
    output logic [11:0] blended 
);
 
    logic [1:0] n = 1;
    logic [1:0] m = 1;
    
    always_comb begin
 
        // RGB(blended) = RGB(puck)* ? + RGB(object) * (1- ?)
        blended[11:8] = ((image_1[11:8] * m) >> n) + (image_2[11:8] >> n);
        blended[7:4] = ((image_1[7:4] * m) >> n) + (image_2[7:4] >> n);
        blended[3:0] = ((image_1[3:0] * m) >> n) + (image_2[3:0] >> n);
        
    end

endmodule

module synchronize #(parameter NSYNC = 3)  // number of sync flops.  must be >= 2
                   (input clk,in,
                    output logic out);

  logic [NSYNC-2:0] sync;

  always_ff @ (posedge clk) begin
    {out,sync} <= {sync[NSYNC-2:0],in};
  end
endmodule

//////////////////////////////////////////////////////////////////////
//
// blob: generate rectangle on screen
//
//////////////////////////////////////////////////////////////////////

module blob
   #(parameter WIDTH = 64,            // default width: 64 pixels
               HEIGHT = 64,           // default height: 64 pixels
               COLOR = 12'hFFF)  // default color: white
   (input [10:0] x_in,hcount_in,
    input [9:0] y_in,vcount_in,
    output logic [11:0] pixel_out);

   always_comb begin
        if ((hcount_in >= x_in && hcount_in < (x_in+WIDTH)) &&
            (vcount_in >= y_in && vcount_in < (y_in+HEIGHT)))
        pixel_out = COLOR;
      else 
        pixel_out = 0;
   end
   
endmodule

////////////////////////////////////////////////////
//
// picture_blob: display a picture
//
//////////////////////////////////////////////////

module picture_blob
   #(parameter WIDTH = 256,     // default picture width
               HEIGHT = 240)    // default picture height
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
   cm_rom rcm (.clka(pixel_clk_in), .addra(image_bits), .douta(red_mapped));
   // cm_rom gcm (.clka(pixel_clk_in), .addra(image_bits), .douta(green_mapped));
   // cm_rom bcm (.clka(pixel_clk_in), .addra(image_bits), .douta(blue_mapped));
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

///////////////////////////////////////////////////////////////////////////////
//
// Pushbutton Debounce Module (video version - 24 bits)  
//
///////////////////////////////////////////////////////////////////////////////

module debounce (input reset_in, clock_in, noisy_in,
                 output logic clean_out);

   logic [19:0] count;
   logic new_input;

   always_ff @(posedge clock_in)
     if (reset_in) begin 
        new_input <= noisy_in; 
        clean_out <= noisy_in; 
        count <= 0; end
     else if (noisy_in != new_input) begin new_input<=noisy_in; count <= 0; end
     else if (count == 1000000) clean_out <= new_input;
     else count <= count+1;

endmodule

//////////////////////////////////////////////////////////////////////////////////
// Update: 8/8/2019 GH 
// Create Date: 10/02/2015 02:05:19 AM
// Module Name: xvga
//
// xvga: Generate VGA display signals (1024 x 768 @ 60Hz)
//
//                              ---- HORIZONTAL -----     ------VERTICAL -----
//                              Active                    Active
//                    Freq      Video   FP  Sync   BP      Video   FP  Sync  BP
//   640x480, 60Hz    25.175    640     16    96   48       480    11   2    31
//   800x600, 60Hz    40.000    800     40   128   88       600     1   4    23
//   1024x768, 60Hz   65.000    1024    24   136  160       768     3   6    29
//   1280x1024, 60Hz  108.00    1280    48   112  248       768     1   3    38
//   1280x720p 60Hz   75.25     1280    72    80  216       720     3   5    30
//   1920x1080 60Hz   148.5     1920    88    44  148      1080     4   5    36
//
// change the clock frequency, front porches, sync's, and back porches to create 
// other screen resolutions
////////////////////////////////////////////////////////////////////////////////

module xvga(input vclock_in,
            output logic [10:0] hcount_out,    // pixel number on current line
            output logic [9:0] vcount_out,     // line number
            output logic vsync_out, hsync_out,
            output logic blank_out);

   parameter DISPLAY_WIDTH  = 1024;      // display width
   parameter DISPLAY_HEIGHT = 768;       // number of lines

   parameter  H_FP = 24;                 // horizontal front porch
   parameter  H_SYNC_PULSE = 136;        // horizontal sync
   parameter  H_BP = 160;                // horizontal back porch

   parameter  V_FP = 3;                  // vertical front porch
   parameter  V_SYNC_PULSE = 6;          // vertical sync 
   parameter  V_BP = 29;                 // vertical back porch

   // horizontal: 1344 pixels total
   // display 1024 pixels per line
   logic hblank,vblank;
   logic hsyncon,hsyncoff,hreset,hblankon;
   assign hblankon = (hcount_out == (DISPLAY_WIDTH -1));    
   assign hsyncon = (hcount_out == (DISPLAY_WIDTH + H_FP - 1));  //1047
   assign hsyncoff = (hcount_out == (DISPLAY_WIDTH + H_FP + H_SYNC_PULSE - 1));  // 1183
   assign hreset = (hcount_out == (DISPLAY_WIDTH + H_FP + H_SYNC_PULSE + H_BP - 1));  //1343

   // vertical: 806 lines total
   // display 768 lines
   logic vsyncon,vsyncoff,vreset,vblankon;
   assign vblankon = hreset & (vcount_out == (DISPLAY_HEIGHT - 1));   // 767 
   assign vsyncon = hreset & (vcount_out == (DISPLAY_HEIGHT + V_FP - 1));  // 771
   assign vsyncoff = hreset & (vcount_out == (DISPLAY_HEIGHT + V_FP + V_SYNC_PULSE - 1));  // 777
   assign vreset = hreset & (vcount_out == (DISPLAY_HEIGHT + V_FP + V_SYNC_PULSE + V_BP - 1)); // 805

   // sync and blanking
   logic next_hblank,next_vblank;
   assign next_hblank = hreset ? 0 : hblankon ? 1 : hblank;
   assign next_vblank = vreset ? 0 : vblankon ? 1 : vblank;
   always_ff @(posedge vclock_in) begin
      hcount_out <= hreset ? 0 : hcount_out + 1;
      hblank <= next_hblank;
      hsync_out <= hsyncon ? 0 : hsyncoff ? 1 : hsync_out;  // active low

      vcount_out <= hreset ? (vreset ? 0 : vcount_out + 1) : vcount_out;
      vblank <= next_vblank;
      vsync_out <= vsyncon ? 0 : vsyncoff ? 1 : vsync_out;  // active low

      blank_out <= next_vblank | (next_hblank & ~hreset);
   end
endmodule