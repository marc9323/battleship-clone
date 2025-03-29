
public class Ship {
 private String name;
 private int size;
 private int hits;
 private ArrayList<Cell> cells;
// private PImage ship_image;
 
 public Ship(String name, int size) {
  this.name = name;
  this.size = size;
  this.hits = 0;
  this.cells = new ArrayList<Cell>();
 }
 
 public void addCell(Cell cell) {
   cells.add(cell);
   cell.placeShip(this);
 }
  
 public void hit() {
  ++hits; 
 }
 
 public int getHits() {
  return hits; 
 }
 
 public boolean isSunk() {
   println("Hits:  " + hits);
  return hits >= size;
 }
 
 public String getName() {
  return this.name; 
 }
 
 public int getSize() {
  return this.size; 
 }
 
 public String toString() {
   String shipString = "Type: " + getName() + " Size: " + getSize() + " Hits: " + getHits() + " Sunk: " + isSunk();
   
   return shipString;
 }
 
}
