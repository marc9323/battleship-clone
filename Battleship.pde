import processing.javafx.*;

import processing.sound.*;

import java.util.*;
import java.awt.Rectangle;

final int rows = 10;
final int cols = 10;
final int cell_width = 32;
final int cell_height = 32;
final int player_grid_offset = 128;
//final int computer_grid_offset = (player_grid_offset) + (cell_width * rows);
final int computer_grid_h_offset = (cell_width * rows) + (player_grid_offset * 2);
final int computer_grid_v_offset = 128;

final String letters = "ABCDEFGHIJ";
final String[] numbers = {"1", "2", "3", "4", "5", "6", "7", "8", "9", "10"};

PFont comic_sans;

final int GRID_SIZE = 10;
final int CELL_SIZE = 32;

final Cell[][] player_grid = new Cell[GRID_SIZE][GRID_SIZE];
final Cell[][] computer_grid = new Cell[GRID_SIZE][GRID_SIZE];

// Player/Computer grid position
final int PLAYER_X = 50;
final int PLAYER_Y = 50;
final int COMPUTER_X = PLAYER_X + GRID_SIZE * CELL_SIZE + 100;
final int COMPUTER_Y = 50;

public static int player_ships_remain = 5;
public static int computer_ships_remain = 5;

public static String output = "";
public static ArrayDeque<String> status = new ArrayDeque<String>();

SoundFile sound;

public static enum GAME_STATE {
  LOADING,
    MENU,
    GAME,
    OUTCOME
}

public enum PLAYER {
  HUMAN,
    COMPUTER
}

public enum AI_SKILL {
  RANDOM,
    STRATEGIC,
    SKILLED
}

public enum AI_MODE {
  RANDOM,
    HUNT_AND_TARGET
}

enum Ship_Types {
  BattleShip,
    Carrier,
    Cruiser,
    Destroyer,
    Submarine
}

ArrayList<Ship> player_armada;
ArrayList<Ship> computer_armada;

// resources
PImage menu_background;
PImage game_background;

GAME_STATE game_state;

void setup() {
  size(1024, 768, FX2D);
  smooth(8);
  comic_sans = createFont("Comic Sans MS", 28);
  sound = new SoundFile(this, "sound/explosion_one.mp3");
  menu_background = loadImage("menu_background.jpg");
  game_background = loadImage("game_background.png");

  game_state = GAME_STATE.MENU;

  // show_menu_screen();

  // TODO:  refactor out setup code to call init() function so game can be reset on completion

  // intitialize player/pc grids to grid of Cell
  for (int i = 0; i < GRID_SIZE; i++) {
    for (int j = 0; j < GRID_SIZE; j++) {
      player_grid[i][j] = new Cell();
      computer_grid[i][j] = new Cell();
    }
  }

  // TODO:  may want to refactor a positive 1 offset as array is zero based but Battleship display grids start with 1
  // Alternatively, may simply enumerate the grids starting at zero and ending at 9?

  // EXAMPLE CODE - REMOVE LATER
  //player_grid[2][3].placeShip(new Ship("cruiser", 4));
  //player_grid[2][3].attack();
  //player_grid[0][0].placeShip(new Ship("cruiser", 4));
  //player_grid[0][0].attack();
  //player_grid[1][0].placeShip(new Ship("cruiser", 4));
  //player_grid[2][0].placeShip(new Ship("cruiser", 4));
  //player_grid[3][0].placeShip(new Ship("cruiser", 4));
  //player_grid[1][1].placeShip(new Ship("cruiser", 4));
  //player_grid[0][9].attack();

  player_armada = createFleet();
  computer_armada = createFleet();

  // Random ship placement initially for testing ...
  randomly_place_all_ships(player_grid, player_armada);
  randomly_place_all_ships(computer_grid, computer_armada);
}

void show_menu_screen() {
  background(menu_background);

  fill(255, 255, 255, 50);
  rect(128, 256, 700, 320, 50);
  fill(255, 0, 0);
  textSize(32);
  text("Spacebar to Begin", 156, 360);
  textSize(96);
  fill(255, 0, 0);
  text("B A T T L E S H I P!", 128, 96);
}

// TODO:  refactor, array list is not necessary, plain array will do
ArrayList<Ship> createFleet() {
  ArrayList<Ship> fleet = new ArrayList<Ship>();

  fleet.add(new Ship("Carrier", 5));
  fleet.add(new Ship("Battleship", 4));
  fleet.add(new Ship("Cruiser", 3));
  fleet.add(new Ship("Submarine", 3));
  fleet.add(new Ship("Destroyer", 2));

  return fleet;
}

void draw() {
  switch(game_state) {
  case MENU:
    // background(menu_background);
    show_menu_screen();
    break;
  case GAME:
    // background(0, 255, 255);
    background(game_background);
    textFont(comic_sans);
    renderPlayerGrid(player_grid, true);
    renderComputerGrid(computer_grid, true);

    renderOutputWindow();
    break;
  case OUTCOME:
    println("OUTCOME: " + "... " + "is VICTORIOUS!");
    break;
  case LOADING:
    println("LOADING GRAPHICS, LOADING FONTS, LOADING DATA, CALCULATING...");
    break;
  default:
    break;
  }
}

void renderOutputWindow() {
  stroke(8);
  rect(128, 496, 128+320+320, 232, 25);

  fill(255, 0, 0);
  text(output, 132, 524);
}

// TODO:  Only need a single drawGrid() call with offsets and boolean passed as parameters
// Leave well enough alone for now - fix later

void renderPlayerGrid(Cell[][] grid, boolean revealShips) {
  for (int i = 0; i < rows; ++i) {
    for (int j = 0; j < cols; ++j) {
      stroke(0);
      fill(128);
      rect(i * cell_width + player_grid_offset, j * cell_height + player_grid_offset, cell_width, cell_height);

      // reveal ships true:  show player ships
      if (revealShips && grid[i][j].hasShip()) {
        fill(100);
        rect(i * cell_width + player_grid_offset + 5, j * cell_height + player_grid_offset + 5, cell_width - 10, cell_width - 10);
      }

      // Graphically indicate hits and misses
      if (grid[i][j].isHit()) {
        fill(grid[i][j].hasShip() ? color(255, 0, 0) : color(0, 0, 255));
        ellipse(player_grid_offset + i * cell_width + cell_width / 2, player_grid_offset + j * cell_height + cell_height / 2, 20, 20);
      }
    }
  }

  // labels
  fill(0);
  for (int i = 0; i < cols; ++i) {
    text(letters.charAt(i), player_grid_offset - 32, (i * cell_height) + player_grid_offset + 24);
  }

  for (int i = 0; i < rows; ++i) {
    text(numbers[i], (i * cell_width) + player_grid_offset + 8, player_grid_offset - 8);
  }
}

void renderComputerGrid(Cell[][] grid, boolean revealShips) {
  for (int i = 0; i < rows; ++i) {
    for (int j = 0; j < cols; ++j) {
      stroke(0);
      fill(128);
      rect(i * cell_width + computer_grid_h_offset, j * cell_height + computer_grid_v_offset, cell_width, cell_height);

      // graphically indicate hits and misses
      if (grid[i][j].isHit()) {
        fill(grid[i][j].hasShip() ? color(255, 0, 0) : color(0, 0, 255));
        ellipse(computer_grid_h_offset + i * cell_width + cell_width / 2, computer_grid_v_offset + j * cell_height + cell_height / 2, 20, 20);
      }
    }
  }

  // labels
  fill(0);
  for (int i = 0; i < cols; ++i) {
    text(letters.charAt(i), computer_grid_h_offset - 32, (i * cell_height) + computer_grid_v_offset + 24);
  }

  for (int i = 0; i < rows; ++i) {
    text(numbers[i], (i * cell_width) +  computer_grid_h_offset + 8, computer_grid_v_offset - 8);
  }
}
//void renderComputerGrid(Cell[][] grid, boolean revealShips) {
//  int xOffset = COMPUTER_X;
//  int yOffset = COMPUTER_Y;

//  for (int row = 0; row < GRID_SIZE; row++) {
//    for (int col = 0; col < GRID_SIZE; col++) {
//      Cell cell = grid[row][col];

//      // Draw cell background
//      stroke(0);
//      fill(200);
//      rect(xOffset + col * CELL_SIZE, yOffset + row * CELL_SIZE, CELL_SIZE, CELL_SIZE);

//      // Draw ships if revealShips is true
//      if (revealShips && cell.hasShip()) {
//        fill(100);
//        rect(xOffset + col * CELL_SIZE + 5, yOffset + row * CELL_SIZE + 5, CELL_SIZE - 10, CELL_SIZE - 10);
//      }

//      // Indicate hits and misses
//      if (cell.isHit()) {
//        if (cell.hasShip()) fill(255, 0, 0);  // red = hit
//        else fill(0, 0, 255);                 // blue = miss
//        ellipse(xOffset + col * CELL_SIZE + CELL_SIZE / 2,
//                yOffset + row * CELL_SIZE + CELL_SIZE / 2,
//                15, 15);
//      }
//    }
//  }
//}


boolean try_to_place_ship(Cell[][] grid, Ship ship, int row, int col, boolean horizontal) {
  int gridSize = grid.length; // 10

  // is placement possible here?
  if (horizontal) {
    if (col + ship.getSize() > gridSize)
      return false;
    for (int i = col; i < col + ship.getSize(); i++) {
      if (grid[row][i].hasShip()) return false;
    }
    // horizontal placement
    for (int i = col; i < col + ship.getSize(); i++) {
      ship.addCell(grid[row][i]); // ship knows what cells it occupies
    }
  } else {
    if (row + ship.getSize() > gridSize) return false;
    for (int i = row; i < row + ship.getSize(); i++) {
      if (grid[i][col].hasShip()) return false;
    }
    // so place it vertically ...
    for (int i = row; i < row + ship.getSize(); i++) {
      ship.addCell(grid[i][col]);
    }
  }

  return true;
}

void randomly_place_all_ships(Cell[][] grid, ArrayList<Ship> fleet) {
  for (Ship ship : fleet) {

    boolean placed = false;

    while (!placed) {
      int row = (int) random(grid.length);
      int col = (int) random(grid[0].length);
      boolean horizontal = random(1) < 0.5; // 50% chance

      placed = try_to_place_ship(grid, ship, row, col, horizontal);
    }
  }
}

void keyPressed() {
  if (game_state == GAME_STATE.MENU && key == ' ') {
    game_state = GAME_STATE.GAME;
  }
}

void mousePressed() {
  // determine clicked cell on computer grid
  int col = (mouseY - computer_grid_v_offset) / cell_height;
  int row = (mouseX - computer_grid_h_offset) / cell_width;

  // within computer grid?
  if (col >= 0 && col < GRID_SIZE && row >= 0 && row < GRID_SIZE) {
    Cell targetCell = computer_grid[row][col];
    // targetCell.attack();  1

    // ignore previously attacked cells
    if (!targetCell.isHit()) {
      boolean hit = targetCell.attack();
      println(hit ? "HIT" : "MISS");
      if (hit) sound.play();
      output = output.concat(hit ? "HIT\n" : "MISS\n");
      status.add(hit ? "HIT!\n" : "MISS\n");

      // was ship sunk?
      if (hit && targetCell.getShip().isSunk()) {
        computer_ships_remain--;
        println("You sunk computers " + targetCell.getShip().getName() + "!");
        println("Computer Ships Remaining: " + computer_ships_remain);
        if (computer_ships_remain <= 0) {
          print("PLAYER VICTORY!");
        }
      }

      // switch to computer turn
      // TODO: refactor so each correct guess on either players part
      // earns a further turn
      computerTurn();
    }
  }
}

void computerTurn() {
  ArrayList<Cell> potentialTargets = new ArrayList<Cell>();
  int[] up = {0, -1};
  int[] down = {0, 1};
  int[] right = {1, 0};
  int[] left = {-1, 0};

  boolean validAttack = false;

  while (!validAttack) {
    int row = (int)random(GRID_SIZE);
    int col = (int)random(GRID_SIZE);

    Cell targetCell = player_grid[row][col];

    if (!targetCell.isHit()) {
      boolean hit = targetCell.attack();
      println("Computer Attacks: [" + row + " , " + col + "]: " + (hit ? "Hit!" : "Miss!"));

      if (hit && targetCell.getShip().isSunk()) {
        println("Computer sunk your: " + targetCell.getShip().getName() + "!");
        player_ships_remain--;
        if (player_ships_remain <= 0) {
          println("DEFEAT! COMPUTER REIGNS VICTORIOUS!");
        }
      //} else { // gotta hit, now zoom into hunt/target mode, adjacent cells
      //  if (row + 1 > 10 || row + 1 <= 0 || row <= 0 || row > 10 || row  - 1 <= 0 || row -1 > 10 || col > 10 || col + 1 > 10 || col <= 0 || col - 1 <= 0 || col - 1 > 10) {
      //    continue;
      //  } else {
      //    potentialTargets.add(player_grid[row + 1][col]);
      //    potentialTargets.add(player_grid[row][col + 1]);
      //    potentialTargets.add(player_grid[row - 1][col]);
      //    potentialTargets.add(player_grid[row][col - 1]);
      //  }
      }

      validAttack = true;
    }
  }
}

// https://www.geeksforgeeks.org/play-battleships-game-with-ai/
