module action(input reset,
              input vsync,
              input left, right, up, down, chop, carry,
              input [2:0] game_state,
              input [1:0] player_direction, //up, down, left, right
              input [8:0] player_loc_x,
              input [8:0] player_loc_y,
              output logic [3:0] player_state,
              output logic [7:0][12:0][3:0] object_grid);

//This module will receive chop and pick up instruction,
//player location and direction, and the object grid. Using these,
//it will output the player’s state and update the grid accordingly.
//This module will require a lot of math operations and one
//clock cycle.
//For objects, they will be assigned an integer location in the
//grid where players can then interact with them.
//The logic surrounding player and object states will need
//an in-depth FSM to define each action rule. In general, if a
//player wants to pick up or chop an object, the module will
//check their direction when carry or chop is pressed. If there
//is an object in the adjacent grid square, the player’s state will
//be changed to interact with the object and the object will be
//updated in the grid.
//This module will also take care of cooking time. If a raw
//pot is placed on a grid that is a designated stove, the object
//will start cooking. After a designated length of cooking time,
//the food will become done. If left for too long, the object will
//catch fire. Neighboring counter spaces will also catch fire at
//designated time steps.
//The grid will need 15 high x 20 long x 4 pixels = 1.2
//Kbits to store the state at each grid location. This module will
//be tested by introducing different player actions at different
//locations and making sure the states end up where expected.
//There are many nuances to the progression that are expected
//to need ironing.


endmodule