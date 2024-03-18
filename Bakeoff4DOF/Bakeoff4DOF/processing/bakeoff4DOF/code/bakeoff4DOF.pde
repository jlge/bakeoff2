import java.util.ArrayList;
import java.util.Collections;

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
boolean mouseHovered = false;
boolean locked = false;
float xoff = 0.0;
float yoff = 0.0;

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

  drawSizeSlider();
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
    fill(100, 100, 255); // Change fill color when hovered
    stroke(255); // Change outline color when hovered
  } else {
    fill(60, 60, 192, 192);
    stroke(0);
  }

  
  rect(0, 0, logoZ, logoZ);
  popMatrix();

  //===========DRAW EXAMPLE CONTROLS=================
  fill(255);
  scaffoldControlLogic(); //you are going to want to replace this!
  text("Trial " + (trialIndex+1) + " of " +trialCount, width/2, inchToPix(.8f));
  text("Size", width/15, 3*height/10, inchToPix(.4f));
  text("Rotate", 3*width/4, height/8 - 5, inchToPix(.4f));
}

void drawSizeSlider() {
  float sizesliderX = inchToPix(0.8f); // Adjust X position of the slider
  float sizesliderY = height / 3; // Adjust Y position of the slider
  float sizesliderwidth = inchToPix(0.2); // Slider width
  float sizesliderheight = inchToPix(3.5); // Slider height
  float sliderPosition = sizesliderY + map(logoZ, inchToPix(0.25f), inchToPix(3.0f), 0, sizesliderheight);

  // Check if mouse is pressing on the slider
  if (mousePressed && mouseX >= sizesliderX && mouseX <= sizesliderX + sizesliderwidth && mouseY >= sizesliderY && mouseY <= sizesliderY + sizesliderheight) {
    // Calculate slider value based on mouse position
    float newValue = map(constrain(mouseY, sizesliderY, sizesliderY + sizesliderheight), sizesliderY, sizesliderY + sizesliderheight, inchToPix(0.25f), inchToPix(3.0f));
    logoZ = newValue;
  }

  // Draw slider background
  fill(100);
  rect(sizesliderX + sizesliderwidth / 2, sizesliderY + sizesliderheight / 2, sizesliderwidth, sizesliderheight);

  // Draw slider handle
  fill(255);
  rect(sizesliderX + sizesliderwidth / 2, sliderPosition, sizesliderwidth, inchToPix(0.2f));
}

//my example design for control, which is terrible
void scaffoldControlLogic()
{
  float sliderX = width / 2;
  float sliderY = inchToPix(1.2f);
  float sliderWidth = inchToPix(4);
  float sliderHeight = inchToPix(0.3f);
  float sliderPosition = sliderX + map(logoRotation, 0, 360, 0, sliderWidth) + 10;

  // Check if mouse is pressing on the slider
  if (mousePressed && mouseX >= sliderX - 2*sliderWidth/3 - 10 && mouseX <= sliderX + 2*sliderWidth/3 - 10 && mouseY >= sliderY && mouseY <= sliderY + sliderHeight) {
    // Calculate slider value based on mouse position
    float newValue = map(constrain(mouseX, sliderX - 2*sliderWidth/3 - 10, sliderX + 2*sliderWidth/3 - 10), sliderX, sliderX + sliderWidth, 0, 360);
    logoRotation = newValue;
  }

  // Draw slider background
  fill(100);
  rect(sliderX, sliderY, sliderWidth + 100, sliderHeight);

  // Draw slider handle
  fill(255);
  rect(sliderPosition, sliderY, inchToPix(0.2f), sliderHeight);
  
  float sizesliderX = inchToPix(1.2f);
  float sizesliderY = height/3;
  float sizesliderwidth = inchToPix(0.2);
  float sizesliderheight = inchToPix(3.5);

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
  xoff = mouseX-logoX;
  yoff = mouseY-logoY;
}

void mouseDragged(){
  if (locked){
    logoX = mouseX - xoff;
    logoY = mouseY - yoff;
  }
}

void mouseReleased()
{
  locked = false;
  //check to see if user clicked middle of screen within 3 inches, which this code uses as a submit button
  if (dist(width/2, height/2, mouseX, mouseY)<inchToPix(3f) && !mouseHovered)
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
