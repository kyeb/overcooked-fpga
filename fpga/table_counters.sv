module table_counter   
    (input [10:0] x_in,hcount_in,
    input [9:0] y_in,vcount_in,
    output logic [11:0] pixel_out);

    parameter COUNTER_WIDTH = 416;
    parameter COUNTER_HEIGHT = 256;
    parameter COUNTER_COLOR = 12'hB70;

    parameter FLOOR_WIDTH = 352;
    parameter FLOOR_HEIGHT = 192;          
    parameter FLOOR_COLOR = 12'h971;

    always_comb begin
        if ((hcount_in >= x_in && hcount_in < (x_in+FLOOR_WIDTH)) && (vcount_in >= y_in && vcount_in < (y_in+FLOOR_HEIGHT)))
            pixel_out = FLOOR_COLOR;
        else if ((hcount_in >= x_in && hcount_in < (x_in+COUNTER_WIDTH)) && (vcount_in >= y_in && vcount_in < (y_in+COUNTER_HEIGHT)))
            pixel_out = COUNTER_COLOR;
        else 
            pixel_out = 0;
    end
endmodule