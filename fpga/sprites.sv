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

    localparam P_NOTHING = 0;
    localparam P_CHOPPING = 1;
    localparam P_ONION_WHOLE = 2;
    localparam P_ONION_CHOPPED = 3;
    localparam P_POT_EMPTY = 4;
    localparam P_POT_SOUP = 5;
    localparam P_BOWL_EMPTY = 6;
    localparam P_BOWL_FULL = 7;
    localparam P_EXT_OFF = 8;
    localparam P_EXT_ON = 9;


    logic [15:0] image_addr;   // num of bits for 256*240 ROM
    logic [7:0] image_bits, red_mapped, green_mapped, blue_mapped;

    logic [7:0] up_bits, down_bits, left_bits, right_bits;
    // calculate rom address and read the location
    assign image_addr = (hcount_in-x_in) + (vcount_in-y_in) * WIDTH;

    // move coes
    up_coe up(.clka(pixel_clk_in), .addra(image_addr), .douta(move_up_bits));
    down_coe down(.clka(pixel_clk_in), .addra(image_addr), .douta(move_down_bits));
    left_coe left(.clka(pixel_clk_in), .addra(image_addr), .douta(move_left_bits));
    right_coe right(.clka(pixel_clk_in), .addra(image_addr), .douta(move_right_bits));

    // chop coes
    up_coe up(.clka(pixel_clk_in), .addra(image_addr), .douta(chop_up_bits));
    down_coe down(.clka(pixel_clk_in), .addra(image_addr), .douta(chop_down_bits));
    left_coe left(.clka(pixel_clk_in), .addra(image_addr), .douta(chop_left_bits));
    right_coe right(.clka(pixel_clk_in), .addra(image_addr), .douta(chop_right_bits));

    // whole onion coes
    up_coe up(.clka(pixel_clk_in), .addra(image_addr), .douta(whole_onion_up_bits));
    down_coe down(.clka(pixel_clk_in), .addra(image_addr), .douta(whole_onion_down_bits));
    left_coe left(.clka(pixel_clk_in), .addra(image_addr), .douta(whole_onion_left_bits));
    right_coe right(.clka(pixel_clk_in), .addra(image_addr), .douta(whole_onion_right_bits));

    // chopped onion coes
    up_coe up(.clka(pixel_clk_in), .addra(image_addr), .douta(chopped_onion_up_bits));
    down_coe down(.clka(pixel_clk_in), .addra(image_addr), .douta(chopped_onion_down_bits));
    left_coe left(.clka(pixel_clk_in), .addra(image_addr), .douta(chopped_onion_left_bits));
    right_coe right(.clka(pixel_clk_in), .addra(image_addr), .douta(chopped_onion_right_bits));

    // empty pot coes
    up_coe up(.clka(pixel_clk_in), .addra(image_addr), .douta(empty_pot_up_bits));
    down_coe down(.clka(pixel_clk_in), .addra(image_addr), .douta(empty_pot_down_bits));
    left_coe left(.clka(pixel_clk_in), .addra(image_addr), .douta(empty_pot_left_bits));
    right_coe right(.clka(pixel_clk_in), .addra(image_addr), .douta(empty_pot_right_bits));

    // soup pot coes
    up_coe up(.clka(pixel_clk_in), .addra(image_addr), .douta(soup_pot_up_bits));
    down_coe down(.clka(pixel_clk_in), .addra(image_addr), .douta(soup_pot_down_bits));
    left_coe left(.clka(pixel_clk_in), .addra(image_addr), .douta(soup_pot_left_bits));
    right_coe right(.clka(pixel_clk_in), .addra(image_addr), .douta(soup_pot_right_bits));

    // empty_bowl coes
    up_coe up(.clka(pixel_clk_in), .addra(image_addr), .douta(empty_bowl_up_bits));
    down_coe down(.clka(pixel_clk_in), .addra(image_addr), .douta(empty_bowl_down_bits));
    left_coe left(.clka(pixel_clk_in), .addra(image_addr), .douta(empty_bowl_left_bits));
    right_coe right(.clka(pixel_clk_in), .addra(image_addr), .douta(empty_bowl_right_bits));

    // full_bowl coes
    up_coe up(.clka(pixel_clk_in), .addra(image_addr), .douta(full_bowl_up_bits));
    down_coe down(.clka(pixel_clk_in), .addra(image_addr), .douta(full_bowl_down_bits));
    left_coe left(.clka(pixel_clk_in), .addra(image_addr), .douta(full_bowl_left_bits));
    right_coe right(.clka(pixel_clk_in), .addra(image_addr), .douta(full_bowl_right_bits));

    // extinguisher_off coes
    up_coe up(.clka(pixel_clk_in), .addra(image_addr), .douta(extinguisher_off_up_bits));
    down_coe down(.clka(pixel_clk_in), .addra(image_addr), .douta(extinguisher_off_down_bits));
    left_coe left(.clka(pixel_clk_in), .addra(image_addr), .douta(extinguisher_off_left_bits));
    right_coe right(.clka(pixel_clk_in), .addra(image_addr), .douta(extinguisher_off_right_bits));

    // extinguisher_on coes
    up_coe up(.clka(pixel_clk_in), .addra(image_addr), .douta(extinguisher_on_up_bits));
    down_coe down(.clka(pixel_clk_in), .addra(image_addr), .douta(extinguisher_on_down_bits));
    left_coe left(.clka(pixel_clk_in), .addra(image_addr), .douta(extinguisher_on_left_bits));
    right_coe right(.clka(pixel_clk_in), .addra(image_addr), .douta(extinguisher_on_right_bits));

    always_comb begin
        case (player_state)
            P_NOTHING: begin
                case (player_direction)
                    P_LEFT: image_bits = move_left_bits;
                    P_RIGHT: image_bits = move_right_bits;
                    P_DOWN: image_bits = move_down_bits;
                    P_UP: image_bits = move_up_bits;
                endcase
            end
            P_CHOPPING: begin
                case (player_direction)
                    P_LEFT: image_bits = chop_left_bits;
                    P_RIGHT: image_bits = chop_right_bits;
                    P_DOWN: image_bits = chop_down_bits;
                    P_UP: image_bits = chop_up_bits;
                endcase
            end
            P_ONION_WHOLE: begin
                case (player_direction)
                    P_LEFT: image_bits = whole_onion_left_bits;
                    P_RIGHT: image_bits = whole_onion_right_bits;
                    P_DOWN: image_bits = whole_onion_down_bits;
                    P_UP: image_bits = whole_onion_up_bits;
                endcase
            end
            P_ONION_CHOPPED: begin
                case (player_direction)
                    P_LEFT: image_bits = chopped_onion_left_bits;
                    P_RIGHT: image_bits = chopped_onion_right_bits;
                    P_DOWN: image_bits = chopped_onion_down_bits;
                    P_UP: image_bits = chopped_onion_up_bits;
                endcase
            end
            P_POT_EMPTY: begin
                case (player_direction)
                    P_LEFT: image_bits = empty_pot_left_bits;
                    P_RIGHT: image_bits = empty_pot_right_bits;
                    P_DOWN: image_bits = empty_pot_down_bits;
                    P_UP: image_bits = empty_pot_up_bits;
                endcase 
            end
            P_POT_SOUP: begin
                case (player_direction)
                    P_LEFT: image_bits = soup_pot_left_bits;
                    P_RIGHT: image_bits = soup_pot_right_bits;
                    P_DOWN: image_bits = soup_pot_down_bits;
                    P_UP: image_bits = soup_pot_up_bits;
                endcase
            end
            P_BOWL_EMPTY: begin
                case (player_direction)
                    P_LEFT: image_bits = empty_bowl_left_bits;
                    P_RIGHT: image_bits = empty_bowl_right_bits;
                    P_DOWN: image_bits = empty_bowl_down_bits;
                    P_UP: image_bits = empty_bowl_up_bits;
                endcase
            end
            P_BOWL_FULL: begin
                case (player_direction)
                    P_LEFT: image_bits = full_bowl_left_bits;
                    P_RIGHT: image_bits = full_bowl_right_bits;
                    P_DOWN: image_bits = full_bowl_down_bits;
                    P_UP: image_bits = full_bowl_up_bits;
                endcase
            end
            P_EXT_OFF: begin
                case (player_direction)
                    P_LEFT: image_bits = extinguisher_off_left_bits;
                    P_RIGHT: image_bits = extinguisher_off_right_bits;
                    P_DOWN: image_bits = extinguisher_off_down_bits;
                    P_UP: image_bits = extinguisher_off_up_bits;
                endcase
            end
            P_EXT_ON: begin
                case (player_direction)
                    P_LEFT: image_bits = extinguisher_left_bits;
                    P_RIGHT: image_bits = extinguisher_right_bits;
                    P_DOWN: image_bits = extinguisher_down_bits;
                    P_UP: image_bits = extinguisher_up_bits;
                endcase
            end
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