module static_sprites #(parameter WIDTH = 32, HEIGHT = 32)     
    (input pixel_clk_in,
     input [7:0][12:0][3:0] object_grid, 
     input [10:0] x_in,hcount,
     input [9:0] y_in,vcount,
     output logic [11:0] pixel_out);

    // grid object parameters
    localparam G_EMPTY = 0;
    localparam G_ONION_WHOLE = 1;
    localparam G_ONION_CHOPPED = 2;
    localparam G_BOWL_EMPTY = 3;
    localparam G_BOWL_FULL = 4;
    localparam G_POT_EMPTY = 5;
    localparam G_POT_RAW = 6;
    localparam G_POT_COOKED = 7;
    localparam G_POT_FIRE = 8;
    localparam G_FIRE = 9;
    localparam G_EXTINGUISHER = 10;

    logic [11:0] image_addr;   // num of bits for 256*240 ROM
    logic [7:0] object_bits, red_mapped, green_mapped, blue_mapped;
    logic [11:0] onion, chopped_onion, empty_bowl, full_bowl, empty_pot, full_pot, fire_pot, fire, extinguisher;

    // calculate rom address and read the location
    assign image_addr = (hcount-x_in) + (vcount-y_in) * WIDTH;

    // grid logic
    logic [3:0] current_grid_x;
    logic [2:0] current_grid_y;
    logic [3:0] grid_state;

    pixel_to_grid p2g (.pixel_x(x_in), .pixel_y(y_in), .grid_x(current_grid_x), .grid_y(current_grid_y));  

    onion_coe on(.clka(pixel_clk_in), .addra(image_addr), .douta(onion));
    chopped_onion_coe co (.clka(pixel_clk_in), .addra(image_addr), .douta(chopped_onion));
    empty_bowl_coe eb (.clka(pixel_clk_in), .addra(image_addr), .douta(empty_bowl));
    full_bowl_coe fb (.clka(pixel_clk_in), .addra(image_addr), .douta(full_bowl));
    empty_pot_coe ep (.clka(pixel_clk_in), .addra(image_addr), .douta(empty_pot));
    full_pot_coe rp (.clka(pixel_clk_in), .addra(image_addr), .douta(full_pot));
    fire_pot_coe fp (.clka(pixel_clk_in), .addra(image_addr), .douta(fire_pot));
    fire_coe f (.clka(pixel_clk_in), .addra(image_addr), .douta(fire));
    extinguisher_coe e (.clka(pixel_clk_in), .addra(image_addr), .douta(extinguisher));

    always_comb begin

        // update the grid state if we end up on a new square of the grid
        grid_state = object_grid[current_grid_y][current_grid_x];

        case (grid_state)
            G_ONION_WHOLE: object_bits = onion;
            G_ONION_CHOPPED: object_bits = chopped_onion;
            G_BOWL_EMPTY: object_bits = empty_bowl;
            G_BOWL_FULL: object_bits = full_bowl;
            G_POT_EMPTY: object_bits = empty_pot;
            G_POT_RAW: object_bits = full_pot;
            G_POT_COOKED: object_bits = full_pot;
            G_POT_FIRE: object_bits = fire_pot;
            G_FIRE: object_bits = fire;
            G_EXTINGUISHER: object_bits = extinguisher;
            default: object_bits = onion;
        endcase
        
    end
    
    red_coe rcm (.clka(pixel_clk_in), .addra(object_bits), .douta(red_mapped));
    green_coe gcm (.clka(pixel_clk_in), .addra(object_bits), .douta(green_mapped));
    blue_coe bcm (.clka(pixel_clk_in), .addra(object_bits), .douta(blue_mapped));
         
    // note the one clock cycle delay in pixel!
    always_ff @ (posedge pixel_clk_in) begin
        if ((hcount >= x_in && hcount < (x_in+WIDTH)) && (vcount >= y_in && vcount < (y_in+HEIGHT)))
            if (x_in == 496) begin
                pixel_out <= 12'h070;
            end else if (grid_state == G_EMPTY) begin
                pixel_out <= 12'hFFF;
            end else begin
                pixel_out <= {red_mapped[7:4], green_mapped[7:4], blue_mapped[7:4]};
            end
        else begin
            pixel_out <= 12'hFFF;
        end
    end
endmodule