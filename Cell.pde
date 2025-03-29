
public class Cell {
 private boolean hasShip;
 private boolean isHit;
 private Ship ship; // optional reference to Ship instance
 
 Cell() {
  this.hasShip = false;
  this.isHit = false;
  this.ship = null;
 }
 
 // place a ship into this cell
 public void placeShip(Ship ship) {
  this.ship = ship;
  this.hasShip = true;
 }
 
 public boolean attack() {
  this.isHit = true;
  if(hasShip && ship != null) {
   ship.hit(); // notify ship it's been hit
   return true;
  }
  return false;
 }
 
 // does this cell contain a ship?
 public boolean hasShip() {
  return hasShip; 
 }
 
 // was cell already attacked?
 public boolean isHit() {
  return isHit; 
 }
 
 // get ship in this cell (may be null)
 public Ship getShip() {
  return ship; 
 }
 
 @Override
 public String toString() {
  if(isHit) {
   return hasShip ? "X" : "O"; // X for hit ship, O for a miss 
  }
  return "."; // . for unhit cell, ??? empty like at start??
 }
}
