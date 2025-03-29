
public class Board {
  private Cell[][] grid;
  
  public Board() {
   grid = new Cell[10][10]; 
   
  // for
  }
}

// Algorithm for simple output status box.  Automated vertical 'scrolling'.
/*
1.  Create an Array or ArrayList for storing individual output messages
1.5  The size of the data structure will be determined by number of output messages that
can fit vertically in the output window
2.  When an event triggers output, add the output to the data structure chosen above
3.  For every draw call, loop over the output data structure and render to output window
4.  When a call to add ouput message to data structure results in exceeding max output messages
then the oldest output message should be deleted (or stored elsewhere).

*/

//void draw() {
//  //switch(game_state) {
//  //  case MENU:
//  //   // background(menu_background);
//  //    show_menu_screen();
//  //    break;
//  //  case GAME:
//  //    break;
//  //  default:
//  //    break;
//  //}
  
//  background(0, 255, 255);

//  textFont(comic_sans);
//  renderPlayerGrid(player_grid, true);
//  renderComputerGrid(computer_grid, true);
  
//  renderOutputWindow();
//  //stroke(8);
//  //rect(128, 496, 128+320+320, 232);
//}
