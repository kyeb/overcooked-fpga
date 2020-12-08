# Overcooked: Food-programmable Gate Array

6.111 Fall 2020 final project

Julia Arnold, Lacthu Vu, and Kye Burchard

See our project on Youtube: https://youtu.be/e6Tfs_nVjrA

## Organization

All the files necessary to run the ESP32 modules are in the `esp32/` directory.
This is compiled using the Arduino IDE with the correct libraries. [This
website](https://randomnerdtutorials.com/installing-the-esp32-board-in-arduino-ide-windows-instructions/)
has a good tutorial for getting the Arduino libraries set up.

The server files are all contained in `server/`. The important file there is
`app.py` - the rest are just scripts to make it easier to push changes to the
server.

Everything Vivado and the FPGAs need is in `fpga/`.

## Vivado setup

This was set up following the instructions on [this Piazza
post](https://piazza.com/class/kdhxf9rp3k96op?cid=298).

When first cloning this repository or to update your Vivado project after
someone else makes changes and you `git pull` them, use the TCL console in
Vivado to `cd` into this project directory, then run `source
generate_vivado.tcl`.

When you start a new file in Vivado you have to create it independently (via touch or just right click) at the same level as vivado_project. Then you go to Vivado, click "Add Sources" on the right, and make sure to unselect the "Copy from source" box so that this file is the one that is updated.

Any time you edit files in the project, change project settings, or do other
things within Vivado that aren't just Verilog changes, you can save them to Git
by using the TCL console to `cd` into the project directory, then running
`write_project_tcl -force generate_vivado.tcl`. This writes the entire Vivado
project, as a script, to the file `generate_vivado.tcl` so other group members
can run it to get the updated project settings.

