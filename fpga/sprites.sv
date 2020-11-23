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
    move_up_coe move_up(.clka(pixel_clk_in), .addra(image_addr), .douta(move_up_bits));
    move_down_coe move_down(.clka(pixel_clk_in), .addra(image_addr), .douta(move_down_bits));
    move_left_coe move_left(.clka(pixel_clk_in), .addra(image_addr), .douta(move_left_bits));
    move_right_coe move_right(.clka(pixel_clk_in), .addra(image_addr), .douta(move_right_bits));

    // chop coes
    chop_up_coe chop_up(.clka(pixel_clk_in), .addra(image_addr), .douta(chop_up_bits));
    chop_down_coe chop_down(.clka(pixel_clk_in), .addra(image_addr), .douta(chop_down_bits));
    chop_left_coe chop_left(.clka(pixel_clk_in), .addra(image_addr), .douta(chop_left_bits));
    chop_right_coe chop_right(.clka(pixel_clk_in), .addra(image_addr), .douta(chop_right_bits));

    // whole onion coes
    whole_onion_up_coe whole_onion_up(.clka(pixel_clk_in), .addra(image_addr), .douta(whole_onion_up_bits));
    whole_onion_down_coe whole_onion_down(.clka(pixel_clk_in), .addra(image_addr), .douta(whole_onion_down_bits));
    whole_onion_left_coe whole_onion_left(.clka(pixel_clk_in), .addra(image_addr), .douta(whole_onion_left_bits));
    whole_onion_right_coe whole_onion_right(.clka(pixel_clk_in), .addra(image_addr), .douta(whole_onion_right_bits));

    // chopped onion coes
    chopped_onion_up_coe chopped_onion_up(.clka(pixel_clk_in), .addra(image_addr), .douta(chopped_onion_up_bits));
    chopped_onion_down_coe chopped_onion_down(.clka(pixel_clk_in), .addra(image_addr), .douta(chopped_onion_down_bits));
    chopped_onion_left_coe chopped_onion_left(.clka(pixel_clk_in), .addra(image_addr), .douta(chopped_onion_left_bits));
    chopped_onion_right_coe chopped_onion_right(.clka(pixel_clk_in), .addra(image_addr), .douta(chopped_onion_right_bits));

    // empty pot coes
    empty_pot_up_coe empty_pot_up(.clka(pixel_clk_in), .addra(image_addr), .douta(empty_pot_up_bits));
    empty_pot_down_coe empty_pot_down(.clka(pixel_clk_in), .addra(image_addr), .douta(empty_pot_down_bits));
    empty_pot_left_coe empty_pot_left(.clka(pixel_clk_in), .addra(image_addr), .douta(empty_pot_left_bits));
    empty_pot_right_coe empty_pot_right(.clka(pixel_clk_in), .addra(image_addr), .douta(empty_pot_right_bits));

    // soup pot coes
    soup_pot_up_coe soup_pot_up(.clka(pixel_clk_in), .addra(image_addr), .douta(soup_pot_up_bits));
    soup_pot_down_coe soup_pot_down(.clka(pixel_clk_in), .addra(image_addr), .douta(soup_pot_down_bits));
    soup_pot_left_coe soup_pot_left(.clka(pixel_clk_in), .addra(image_addr), .douta(soup_pot_left_bits));
    soup_pot_right_coe soup_pot_right(.clka(pixel_clk_in), .addra(image_addr), .douta(soup_pot_right_bits));

    // empty_bowl coes
    empty_bowl_up_coe empty_bowl_up(.clka(pixel_clk_in), .addra(image_addr), .douta(empty_bowl_up_bits));
    empty_bowl_down_coe empty_bowl_down(.clka(pixel_clk_in), .addra(image_addr), .douta(empty_bowl_down_bits));
    empty_bowl_left_coe empty_bowl_left(.clka(pixel_clk_in), .addra(image_addr), .douta(empty_bowl_left_bits));
    empty_bowl_right_coe empty_bowl_right(.clka(pixel_clk_in), .addra(image_addr), .douta(empty_bowl_right_bits));

    // full_bowl coes
    full_bowl_up_coe full_bowl_up(.clka(pixel_clk_in), .addra(image_addr), .douta(full_bowl_up_bits));
    full_bowl_down_coe full_bowl_down(.clka(pixel_clk_in), .addra(image_addr), .douta(full_bowl_down_bits));
    full_bowl_left_coe full_bowl_left(.clka(pixel_clk_in), .addra(image_addr), .douta(full_bowl_left_bits));
    full_bowl_right_coe full_bowl_right(.clka(pixel_clk_in), .addra(image_addr), .douta(full_bowl_right_bits));

    // extinguisher_off coes
    extinguisher_off_up_coe extinguisher_off_up(.clka(pixel_clk_in), .addra(image_addr), .douta(extinguisher_off_up_bits));
    extinguisher_off_down_coe extinguisher_off_down(.clka(pixel_clk_in), .addra(image_addr), .douta(extinguisher_off_down_bits));
    extinguisher_off_left_coe extinguisher_off_left(.clka(pixel_clk_in), .addra(image_addr), .douta(extinguisher_off_left_bits));
    extinguisher_off_right_coe extinguisher_off_right(.clka(pixel_clk_in), .addra(image_addr), .douta(extinguisher_off_right_bits));

    // extinguisher_on coes
    extinguisher_on_up_coe extinguisher_on_up(.clka(pixel_clk_in), .addra(image_addr), .douta(extinguisher_on_up_bits));
    extinguisher_on_down_coe extinguisher_on_down(.clka(pixel_clk_in), .addra(image_addr), .douta(extinguisher_on_down_bits));
    extinguisher_on_left_coe extinguisher_on_left(.clka(pixel_clk_in), .addra(image_addr), .douta(extinguisher_on_left_bits));
    extinguisher_on_right_coe extinguisher_on_right(.clka(pixel_clk_in), .addra(image_addr), .douta(extinguisher_on_right_bits));

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
                    P_LEFT: image_bits = extinguisher_on_left_bits;
                    P_RIGHT: image_bits = extinguisher_on_right_bits;
                    P_DOWN: image_bits = extinguisher_on_down_bits;
                    P_UP: image_bits = extinguisher_on_up_bits;
                endcase
            end
        endcase
    end

    red_coe rcm (.clka(pixel_clk_in), .addra(image_bits), .douta(red_mapped));
    green_coe gcm (.clka(pixel_clk_in), .addra(image_bits), .douta(green_mapped));
    blue_coe bcm (.clka(pixel_clk_in), .addra(image_bits), .douta(blue_mapped));
     
    // note the one clock cycle delay in pixel!
    always_ff @ (posedge pixel_clk_in) begin
    if ((hcount_in >= x_in && hcount_in < (x_in+WIDTH)) &&
          (vcount_in >= y_in && vcount_in < (y_in+HEIGHT)))
        pixel_out <= {red_mapped[7:4], green_mapped[7:4], green_mapped[7:4]}; 
        else pixel_out <= 0;
    end
endmodule