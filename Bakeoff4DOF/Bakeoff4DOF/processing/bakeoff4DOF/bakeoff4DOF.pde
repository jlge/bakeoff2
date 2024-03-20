import java.util.ArrayList;
import java.util.Collections;
import java.lang.Math;

//these are variables you should probably leave alone
int index = 0; //starts at zero-ith trial
float border = 0; //some padding from the sides of window, set later
int trialCount = 12; //this will be set higher for the bakeoff
int trialIndex = 0; //what trial are we on
int errorCount = 0;  //used to keep track of errors
float errorPenalty = 0.5f; //for every error, add this value to mean time
int startTime = 0; // time starts when the first click is captured
int finishTime = 0; //records the time of the final click
boolean userDone = false; //is the user done
boolean mouseHovered = false; // whether the user is hovering over the square
boolean locked = false;
float xoff = 0.0;
float yoff = 0.0;
float arrowLength = 300; // Length of the arrowhead
float arrowWidth = 20; // Width of the arrowhead
boolean sizeHovered = false;
boolean sizeLocked = false;
boolean rotateHovered = false;
boolean rotateLocked = false;
float circleStrokeWeight = 25;

final int screenPPI = 72; //what is the DPI of the screen you are using
//you can test this by drawing a 72x72 pixel rectangle in code, and then confirming with a ruler it is 1x1 inch. 

//These variables are for my example design. Your input code should modify/replace these!
float logoX = 500;
float logoY = 500;
float logoZ = 50f;
float logoRotation = 0;

private class Destination
{
  float x = 0;
  float y = 0;
  float rotation = 0;
  float z = 0;
}

ArrayList<Destination> destinations = new ArrayList<Destination>();

void setup() {
  size(1000, 800);  
  rectMode(CENTER);
  textFont(createFont("Arial", inchToPix(.3f))); //sets the font to Arial that is 0.3" tall
  textAlign(CENTER);
  rectMode(CENTER); //draw rectangles not from upper left, but from the center outwards
  
  //don't change this! 
  border = inchToPix(2f); //padding of 1.0 inches

  for (int i=0; i<trialCount; i++) //don't change this! 
  {
    Destination d = new Destination();
    d.x = random(border, width-border); //set a random x with some padding
    d.y = random(border, height-border); //set a random y with some padding
    d.rotation = random(0, 360); //random rotation between 0 and 360
    int j = (int)random(20);
    d.z = ((j%12)+1)*inchToPix(.25f); //increasing size from .25 up to 3.0" 
    destinations.add(d);
    println("created target with " + d.x + "," + d.y + "," + d.rotation + "," + d.z);
  }

  Collections.shuffle(destinations); // randomize the order of the button; don't change this.
}



void draw() {
  background(40); //background is dark grey
  fill(200);
  noStroke();
  
  if (mouseX > logoX - logoZ / 2 && mouseX < logoX + logoZ / 2 && mouseY > logoY - logoZ / 2 && mouseY < logoY + logoZ / 2) {
    mouseHovered = true;
  } else {
    mouseHovered = false;
  }
  
  if (inCircle()) {
    sizeHovered = true;
  } else {
    sizeHovered = false;
  }

  if (inLine()) {
    rotateHovered = true;
  } else {
    rotateHovered = false;
  }
  //shouldn't really modify this printout code unless there is a really good reason to
  if (userDone)
  {
    text("User completed " + trialCount + " trials", width/2, inchToPix(.4f));
    text("User had " + errorCount + " error(s)", width/2, inchToPix(.4f)*2);
    text("User took " + (finishTime-startTime)/1000f/trialCount + " sec per destination", width/2, inchToPix(.4f)*3);
    text("User took " + ((finishTime-startTime)/1000f/trialCount+(errorCount*errorPenalty)) + " sec per destination inc. penalty", width/2, inchToPix(.4f)*4);
    return;
  }

  //===========DRAW DESTINATION SQUARES=================
  for (int i=trialIndex; i<trialCount; i++) // reduces over time
  {
    pushMatrix();
    Destination d = destinations.get(i); //get destination trial
    translate(d.x, d.y); //center the drawing coordinates to the center of the destination trial
    rotate(radians(d.rotation)); //rotate around the origin of the destination trial
    noFill();
    strokeWeight(3f);
    if (trialIndex==i)
      stroke(255, 0, 0, 192); //set color to semi translucent
    else
      stroke(128, 128, 128, 128); //set color to semi translucent
    rect(0, 0, d.z, d.z);
    popMatrix();
  }

  //===========DRAW LOGO SQUARE=================
  pushMatrix();
  translate(logoX, logoY); //translate draw center to the center oft he logo square
  rotate(radians(logoRotation)); //rotate using the logo square as the origin
  noStroke();
  fill(60, 60, 192, 192);
  
  if (mouseHovered) {
    //fill(100, 100, 255); // Change fill color when hovered
    stroke(255); // Change outline color when hovered
  } else {
    fill(60, 60, 192, 192);
    stroke(0);
  }
  
  Destination d = destinations.get(trialIndex);  
  boolean closeDist = dist(d.x, d.y, logoX, logoY)<inchToPix(.05f);
  if (closeDist) {
    stroke(0, 255, 0);
  }
  rectMode(CENTER);
  rect(0, 0, logoZ, logoZ);
  drawLines(0, 0, logoZ, logoZ);
  drawCircle();
  popMatrix();

  //===========DRAW EXAMPLE CONTROLS=================
  fill(255);
  scaffoldControlLogic(); //you are going to want to replace this!
  text("Trial " + (trialIndex+1) + " of " +trialCount, width/2, inchToPix(.8f));
}

//my example design for control, which is terrible
void scaffoldControlLogic()
{

}

boolean inCircle() {
    // Calculate distance from mouse to circle center
  float distanceToCenter = dist(mouseX, mouseY, logoX, logoY);
  // Calculate the radius of the circle considering the stroke weight
  //float circleRadius = logoZ / 2 + circleStrokeWeight / 2;
  float radius = (float)Math.sqrt(logoZ * logoZ * 2)/2+12.5;
  
  // Check if the distance is within the circle's border
  if ((distanceToCenter >= (radius - circleStrokeWeight/2)) && (distanceToCenter <= (radius + circleStrokeWeight/2))) {
    return true;
  }
  return false;
}

boolean inLine() {
  float centerX = logoX;
  float centerY = logoY;
  float distanceToCenter = dist(mouseX, mouseY, logoX, logoY);
  
  // Calculate the difference between the mouse position and the center of the rectangle
  float dx = mouseX - centerX;
  float dy = mouseY - centerY;
  
  // Calculate the angle using the arctangent function (atan2)
  float angle = atan2(dy, dx);
  
  // Convert the angle from radians to degrees
  angle = degrees(angle);
  
  // Adjust the angle range from -180 to 180 to 0 to 360
  if (angle < 0) {
    angle += 360;
  }
  logoRotation = logoRotation % 90;

  if ((angle > 45-3+logoRotation && angle < 45+3+logoRotation) || (angle > 135-3+logoRotation && angle < 135+3+logoRotation) || 
  (angle > 225-3+logoRotation && angle < 225+3+logoRotation) || (angle > 315-3+logoRotation && angle < 315+3+logoRotation)) {
    return distanceToCenter < 308;
  } else {
    return false;
  }
}

void mousePressed()
{
  if (startTime == 0) //start time on the instant of the first user click
  {
    startTime = millis();
    println("time started!");
  }
  if (mouseHovered){
    locked = true;
    fill(60, 60, 192, 192);
  } else{
    locked = false;
  }
  
  if (sizeHovered) {
    sizeLocked = true;
  } else {
    sizeLocked = false;
  }
  
  if (rotateHovered) {
    rotateLocked = true;
  } else {
    rotateLocked = false;
  }
  xoff = mouseX-logoX;
  yoff = mouseY-logoY;
}

// Drawing arrows pointing radially outwards from the center of the rectangle
void drawLines(float x, float y, float w, float h) {
  Destination d = destinations.get(trialIndex);  
  boolean closeRotation = calculateDifferenceBetweenAngles(d.rotation, logoRotation)<=5;
  if (closeRotation) {
    stroke(0,255,0);
  } else if (rotateHovered || rotateLocked) {
    stroke(255);
  } else {
    stroke(0);
  }
  
  strokeWeight(9);
  // Calculate the center of the rectangle
  float centerX = x;
  float centerY = y;

  // Calculate the angles for each arrow
  float[] angles = {QUARTER_PI, -QUARTER_PI, -3 * QUARTER_PI, 3 * QUARTER_PI}; // Angles in radians

  // Draw arrows for all four directions
  for (int i = 0; i < 4; i++) {
    float endX = centerX + cos(angles[i]) * arrowLength;
    float endY = centerY + sin(angles[i]) * arrowLength;

    // Draw arrow shaft
    line(centerX, centerY, endX, endY);

  }
}

void drawCircle() {
  noFill();
  Destination d = destinations.get(trialIndex);  
  boolean closeZ = abs(d.z - logoZ)<inchToPix(.1f);
  if (closeZ) {
    stroke(0,255,0);
  } else if (inCircle() || sizeLocked) {
    stroke(255);
  } else {
    stroke(0);
  }
  
  strokeWeight(circleStrokeWeight);
  float hypotenuse = (float)Math.sqrt(logoZ * logoZ * 2);
  circle(0,0,hypotenuse+25);
}

void mouseReleased()
{
  //check to see if user clicked middle of screen within 3 inches, which this code uses as a submit button
  locked = false;
  if (dist(width/2, height/2, mouseX, mouseY)<inchToPix(3f) && (!mouseHovered && !sizeLocked && !rotateLocked))
  {
    if (userDone==false && !checkForSuccess())
      errorCount++;

    trialIndex++; //and move on to next trial

    if (trialIndex==trialCount && userDone==false)
    {
      userDone = true;
      finishTime = millis();
    }
  }
  sizeLocked = false;
  rotateLocked = false;
}

void mouseDragged(){
  if (locked){
    logoX = mouseX - xoff;
    logoY = mouseY - yoff;
  } else if (sizeLocked) {
    float distanceToCenter =constrain(dist(mouseX, mouseY, logoX, logoY), .01, inchToPix(4f));
    logoZ = distanceToCenter;
  } else if (rotateLocked) {
    float centerX = logoX;
    float centerY = logoY;
    float distanceToCenter = dist(mouseX, mouseY, logoX, logoY);
    
    // Calculate the difference between the mouse position and the center of the rectangle
    float dx = mouseX - centerX;
    float dy = mouseY - centerY;
    
    // Calculate the angle using the arctangent function (atan2)
    float angle = atan2(dy, dx);
    
    // Convert the angle from radians to degrees
    angle = degrees(angle+90);
    logoRotation = angle;
  }
}

//probably shouldn't modify this, but email me if you want to for some good reason.
public boolean checkForSuccess()
{
  Destination d = destinations.get(trialIndex);	
  boolean closeDist = dist(d.x, d.y, logoX, logoY)<inchToPix(.05f); //has to be within +-0.05"
  boolean closeRotation = calculateDifferenceBetweenAngles(d.rotation, logoRotation)<=5;
  boolean closeZ = abs(d.z - logoZ)<inchToPix(.1f); //has to be within +-0.1"	

  println("Close Enough Distance: " + closeDist + " (logo X/Y = " + d.x + "/" + d.y + ", destination X/Y = " + logoX + "/" + logoY +")");
  println("Close Enough Rotation: " + closeRotation + " (rot dist="+calculateDifferenceBetweenAngles(d.rotation, logoRotation)+")");
  println("Close Enough Z: " +  closeZ + " (logo Z = " + d.z + ", destination Z = " + logoZ +")");
  println("Close enough all: " + (closeDist && closeRotation && closeZ));

  return closeDist && closeRotation && closeZ;
}

//utility function I include to calc diference between two angles
double calculateDifferenceBetweenAngles(float a1, float a2)
{
  double diff=abs(a1-a2);
  diff%=90;
  if (diff>45)
    return 90-diff;
  else
    return diff;
}

//utility function to convert inches into pixels based on screen PPI
float inchToPix(float inch)
{
  return inch*screenPPI;
}
