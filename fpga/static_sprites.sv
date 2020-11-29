module static_sprites
    #(parameter WIDTH = 32,        
                HEIGHT = 32,          
                COLOR = 12'hB70)       
    (input [10:0] x_in,hcount_in,
        input [9:0] y_in,vcount_in,
        output logic [11:0] pixel_out);

    logic [11:0] whole_onion, chopped_onion, empty_bowl, full_bowl, empty_pot, raw_pot, cooked_pot, fire_pot, fire, extinguisher;

    always_comb begin

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
    end
endmodule