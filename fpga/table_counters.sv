module table_counter   
    (input [10:0] x_in_counter, x_in_floor, hcount_in,
    input [9:0] y_in_counter, y_in_floor, vcount_in,
    output logic [11:0] pixel_out);

    parameter COUNTER_WIDTH = 416;
    parameter COUNTER_HEIGHT = 256;
    parameter COUNTER_COLOR = 12'hB70;

    parameter FLOOR_WIDTH = 352;
    parameter FLOOR_HEIGHT = 192;          
    parameter FLOOR_COLOR = 12'h971;

    always_comb begin
        if ((hcount_in >= x_in_floor && hcount_in < (x_in_floor+FLOOR_WIDTH)) && (vcount_in >= y_in_floor && vcount_in < (y_in_floor+FLOOR_HEIGHT)))
            pixel_out = FLOOR_COLOR;
        else if ((hcount_in >= x_in_counter && hcount_in < (x_in_counter+COUNTER_WIDTH)) && (vcount_in >= y_in_counter && vcount_in < (y_in_counter+COUNTER_HEIGHT)))
            pixel_out = COUNTER_COLOR;
        else 
            pixel_out = 0;
    end
endmodule