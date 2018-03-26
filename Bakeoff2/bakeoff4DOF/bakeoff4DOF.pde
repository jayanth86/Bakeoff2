import java.util.ArrayList;
import java.util.Collections;

//these are variables you should probably leave alone
int index = 0;
int trialCount = 8; //this will be set higher for the bakeoff
float border = 0; //have some padding from the sides
int trialIndex = 0; //what trial are we on
int errorCount = 0;  //used to keep track of errors
float errorPenalty = 0.5f; //for every error, add this to mean time
int startTime = 0; // time starts when the first click is captured
int finishTime = 0; //records the time of the final click
boolean userDone = false;
boolean translateLocked = false;
boolean sizeLocked = false;
boolean rotationLocked = false;
final int screenPPI = 72; //what is the DPI of the screen you are using
//you can test this by drawing a 72x72 pixel rectangle in code, and then confirming with a ruler it is 1x1 inch. 

//These variables are for my example design. Your input code should modify/replace these!
float screenTransX = 0;
float screenTransY = 0;
float screenRotation = 0;
float screenZ = 50f;


//mouse info
float prevMouseX;
float prevMouseY;

private class Target
{
  float x = 0;
  float y = 0;
  float rotation = 0;
  float z = 0;
}

ArrayList<Target> targets = new ArrayList<Target>();

float inchesToPixels(float inch)
{
  return inch*screenPPI;
}

void setup() {
  size(800,800); 

  rectMode(CENTER);
  textFont(createFont("Arial", inchesToPixels(.2f))); //sets the font to Arial that is .3" tall
  textAlign(CENTER);

  //don't change this! 
  border = inchesToPixels(.2f); //padding of 0.2 inches

  for (int i=0; i<trialCount; i++) //don't change this! 
  {
    Target t = new Target();
    t.x = random(-width/2+border, width/2-border); //set a random x with some padding
    t.y = random(-height/2+border, height/2-border); //set a random y with some padding
    t.rotation = random(0, 360); //random rotation between 0 and 360
    int j = (int)random(20);
    t.z = ((j%20)+1)*inchesToPixels(.15f); //increasing size from .15 up to 3.0" 
    targets.add(t);
    println("created target with " + t.x + "," + t.y + "," + t.rotation + "," + t.z);
  }

  Collections.shuffle(targets); // randomize the order of the button; don't change this.
  
  prevMouseX = mouseX;
  prevMouseY = mouseY;
}

boolean correct_size(Target t)  {
  return abs(t.z - screenZ)<inchesToPixels(.05f);
}

boolean correct_rotation(Target t)  {
  return calculateDifferenceBetweenAngles(t.rotation,screenRotation)<=5;
}

boolean correct_translation(Target t)  {
  return dist(t.x,t.y,screenTransX,screenTransY)<inchesToPixels(.05f); //has to be within .1";
}

void draw() {

  background(60); //background is dark grey
  fill(200);
  noStroke();

  //shouldn't really modify this printout code unless there is a really good reason to
  if (userDone)
  {
    text("User completed " + trialCount + " trials", width/2, inchesToPixels(.2f));
    text("User had " + errorCount + " error(s)", width/2, inchesToPixels(.2f)*2);
    text("User took " + (finishTime-startTime)/1000f/trialCount + " sec per target", width/2, inchesToPixels(.2f)*3);
    text("User took " + ((finishTime-startTime)/1000f/trialCount+(errorCount*errorPenalty)) + " sec per target inc. penalty", width/2, inchesToPixels(.2f)*4);
    return;
  }
  
  //===========DRAW TARGET SQUARE=================
  pushMatrix();
  translate(width/2, height/2); //center the drawing coordinates to the center of the screen
  Target t1 = targets.get(trialIndex);
  translate(t1.x, t1.y); //center the drawing coordinates to the center of the screen
  rotate(radians(t1.rotation));
  fill(255, 0, 0); //set color to semi translucent
  rect(0, 0, t1.z, t1.z);
  popMatrix();
  /*if (!correct_translation(t)){
       float cursorCircleSize = (min(20, min(screenZ, t.z) * .3)) / 2;

       pushMatrix();
       fill(255);
       ellipse(width/2 + screenTransX, height/2 + screenTransY, cursorCircleSize, cursorCircleSize); //draw a cirle in cursor square
       fill(0, 255, 0);
       ellipse(width/2 + t.x, height/2 + t.y, cursorCircleSize, cursorCircleSize); //draw a circle in target square
       
       //make a line between them
       stroke(255, 255, 0);
       strokeWeight(cursorCircleSize);
       line(width/2 + screenTransX, height/2 + screenTransY, width/2 + t.x, height/2 + t.y);

       popMatrix();
  }
  else if(!correct_size(t))  {
    fill(255);
    if (!translateLocked)
    {
       textSize(40);
       text("click now!", width/2, height/2);
    }
      
    pushMatrix();
    translate(width/2, height/2); //center the drawing coordinates to the center of the screen
    translate(screenTransX, screenTransY);
    rotate(radians(screenRotation));
    fill(0, 255, 0);
    noFill();
    
    float weight = max(1.5, t.z * .015);
    //print("weight: " + weight); 
    
    strokeWeight(weight);
    stroke(0,255,0);   
    rect(0, 0, t.z, t.z);
    popMatrix();
    
   //print("in size\n");
  }
  else if(!correct_rotation(t))  {
    fill(255);
    //print("in rot\n");
    if (!sizeLocked)
    {
       textSize(40);
       text("click now!", width/2, height/2);
    }
       
    pushMatrix();
    translate(width/2, height/2); //center the drawing coordinates to the center of the screen
    translate(screenTransX, screenTransY);
    rotate(radians(t.rotation));
    fill(0, 255, 0);
    noFill();
    
    float weight = max(1.5, t.z * .015);

    strokeWeight(weight);
    stroke(0,255,0);
    rect(0, 0, t.z, t.z);
    popMatrix();
  }
  
  fill(255);
   if (correct_rotation(t) && correct_size(t) && correct_size(t))
   {
       textSize(40);
       text("Double click now!", width/2, height/2);
   }
   
   if (correct_translation(t) && !mousePressed)
   {
     translateLocked = true;
   }
   if (correct_size(t) && !mousePressed)
   {
     sizeLocked = true;
   }
   if (correct_rotation(t) && !mousePressed)
   {
     rotationLocked = true;
   }

  //===========DRAW CURSOR SQUARE=================
  pushMatrix();
  translate(width/2, height/2); //center the drawing coordinates to the center of the screen
  translate(screenTransX, screenTransY);
  rotate(radians(screenRotation));
  noFill();
  strokeWeight(3f);
  stroke(160);
  rect(0,0, screenZ, screenZ);
  popMatrix();
  */
  if(!translateLocked)  {
    float circleSize = 20;
    pushMatrix();
    translate(width/2, height/2); //center the drawing coordinates to the center of the screen
    Target t = targets.get(trialIndex);
    translate(t.x, t.y); //center the drawing coordinates to the center of the screen
    fill(0, 255, 0); //set color to semi translucent
    ellipse(0,0,circleSize,circleSize);
    popMatrix();
    pushMatrix();
    translate(width/2, height/2); //center the drawing coordinates to the center of the screen
    translate(screenTransX, screenTransY); //center the drawing coordinates to the center of the screen
    fill(0, 255, 0); //set color to semi translucent
    ellipse(0,0,circleSize,circleSize);
    stroke(255, 255, 0);
    strokeWeight(5);
    popMatrix();
    line(width/2 + screenTransX, height/2 + screenTransY, width/2 + t.x, height/2 + t.y);
    if(correct_translation(t))  {
      textSize(40);
      text("click now!", width/2, height/2);
    }  else  {
      //background(60);
    }
    
  }
    //===========DRAW EXAMPLE CONTROLS=================
  fill(255);
  scaffoldControlLogic(); //you are going to want to replace this!
  textSize(15);
  text("Trial " + (trialIndex+1) + " of " +trialCount, width/2, inchesToPixels(.5f));
}

//my example design for control, which is terrible
void scaffoldControlLogic()
{
  /*//upper left corner, rotate counterclockwise
  text("CCW", inchesToPixels(.2f), inchesToPixels(.2f));
  if (mousePressed && dist(0, 0, mouseX, mouseY)<inchesToPixels(.5f))
    screenRotation--;

  //upper right corner, rotate clockwise
  text("CW", width-inchesToPixels(.2f), inchesToPixels(.2f));
  if (mousePressed && dist(width, 0, mouseX, mouseY)<inchesToPixels(.5f))
    screenRotation++;

  //lower left corner, decrease Z
  text("-", inchesToPixels(.2f), height-inchesToPixels(.2f));
  if (mousePressed && dist(0, height, mouseX, mouseY)<inchesToPixels(.5f))
    screenZ-=inchesToPixels(.02f);

  //lower right corner, increase Z
  text("+", width-inchesToPixels(.2f), height-inchesToPixels(.2f));
  if (mousePressed && dist(width, height, mouseX, mouseY)<inchesToPixels(.5f))
    screenZ+=inchesToPixels(.02f);*/
  /*if(!translateLocked)  {
    screenTransX = mouseX - width/2;
    screenTransY = mouseY - height/2;
  }*/
  //left middle, move left
  /*text("left", inchesToPixels(.2f), height/2);
  if (mousePressed && dist(0, height/2, mouseX, mouseY)<inchesToPixels(.5f))
    screenTransX-=inchesToPixels(.02f);

  text("right", width-inchesToPixels(.2f), height/2);
  if (mousePressed && dist(width, height/2, mouseX, mouseY)<inchesToPixels(.5f))
    screenTransX+=inchesToPixels(.02f);
  
  text("up", width/2, inchesToPixels(.2f));
  if (mousePressed && dist(width/2, 0, mouseX, mouseY)<inchesToPixels(.5f))
    screenTransY-=inchesToPixels(.02f);
  
  text("down", width/2, height-inchesToPixels(.2f));
  if (mousePressed && dist(width/2, height, mouseX, mouseY)<inchesToPixels(.5f))
    screenTransY+=inchesToPixels(.02f);*/
}


void mousePressed()
{
    if (startTime == 0) //start time on the instant of the first user click
    {
      startTime = millis();
      println("time started!");
    }
}

void mouseMoved()
{
    /*
    if (!translateLocked)
      return;
    float scale = 2;
    float buffer = .15;
    
    if(!sizeLocked)
    {
       Target t = targets.get(trialIndex); 
      //print("target (" + t.x + ", " + t.y + ") mouseX (" + mouseX + ", " + mouseY + ")\n");
      screenZ = max((dist(mouseX - width/2, mouseY - height/2, t.x, t.y)) * scale, 0);
    }
    else
    {
    
    if (prevMouseX - mouseX < -buffer)
    {
      //if(!sizeLocked)
      //    screenZ=max(screenZ - inchesToPixels(.02f) * scale, 0);
      //else
      if(!rotationLocked)
        screenRotation-= 1 * scale;
    }
    else if (prevMouseX - mouseX > buffer)
    {
      //if(!sizeLocked)
      //    screenZ+=inchesToPixels(.02f) * scale;
      //else
      if(!rotationLocked)
        screenRotation+= 1 * scale;
    }
    if (prevMouseY - mouseY < -buffer)
    {
      //if(!sizeLocked)
      //    screenZ=max(screenZ - inchesToPixels(.02f) * scale, 0);
      //else*
      if(!rotationLocked)
        screenRotation-= 1 * scale;
    }
    else if (prevMouseY - mouseY > buffer)
    {
      //if(!sizeLocked)
      //    screenZ+=inchesToPixels(.02f) * scale;
      //else 
      if(!rotationLocked)
        screenRotation+= 1 * scale;
    }
    }
    
    */
  if(!translateLocked)
  {
    screenTransX = mouseX - width/2;
    screenTransY = mouseY - height/2;
    return;
  }
  prevMouseX = mouseX;
  prevMouseY = mouseY;
}

void mouseDragged()
{  
  //if (!sizeLocked)
  //{
  //center of cursor square is screenTransX screenTransY
  float scale = abs(dist(mouseX - width/2,mouseY - height/2,screenTransX,screenTransY));
  screenZ=max(scale, 0);
  //print("in drag. center: (" + screenTransX + ", " + screenTransY + ")");
  //print(" mouse: (" + (mouseX - width/2) + ", " + (mouseY - height/2) + ")\n");
  //return;
  //}
  
  //corner 
  float x = screenTransX - screenZ/2;
  float y = screenTransY + screenZ/2;
 
  PVector mouse = new PVector(mouseX  - width/2 - screenTransX, mouseY - height/2 - screenTransY);
  PVector corner = new PVector(x, y);
  PVector center = new PVector(screenTransX, screenTransY);

  //print(" corner: (" + x + ", " + y + ")\n");
  //float angle = PVector.angleBetween(mouse, corner);//angle(mouse, corner);
  float angle = angle(center, mouse);
  print("center: (" + center.x + ", " + center.y + ")\n");
  print("mouse: (" + mouse.x + ", " + mouse.y + ")\n");
  print(" angle: " + degrees(angle) + "\n");
  screenRotation = degrees(angle);
}

void mouseReleased()
{
  //if (!(rotationLocked && translateLocked && sizeLocked))
    //return;
  //check to see if user clicked middle of screen within 3 inches
     //print("in here");
    if(!translateLocked)  {
      translateLocked = true;
      //print("changed translateLocked\n");
    } else if(!sizeLocked)  {
      sizeLocked = true;
      //print("changed sizeLocked\n");
    //} else if(!rotationLocked)  {
      //rotationLocked = true;
    //}  else  {
      //if (dist(width/2, height/2, mouseX, mouseY)<inchesToPixels(3f))
      //{
        if (userDone==false && !checkForSuccess())
          errorCount++;
    
        //and move on to next trial
        trialIndex++;
        translateLocked = false;
        sizeLocked = false;
        rotationLocked = false;
        
        if (trialIndex==trialCount && userDone==false)
        {
          userDone = true;
          finishTime = millis();
        }
      }
      //}
    //}
}

//probably shouldn't modify this, but email me if you want to for some good reason.
public boolean checkForSuccess()
{
	Target t = targets.get(trialIndex);	
	boolean closeDist = dist(t.x,t.y,screenTransX,screenTransY)<inchesToPixels(.05f); //has to be within .1"
  boolean closeRotation = calculateDifferenceBetweenAngles(t.rotation,screenRotation)<=5;
	boolean closeZ = abs(t.z - screenZ)<inchesToPixels(.05f); //has to be within .1"	
	
  println("Close Enough Distance: " + closeDist + " (cursor X/Y = " + t.x + "/" + t.y + ", target X/Y = " + screenTransX + "/" + screenTransY +")");
  println("Close Enough Rotation: " + closeRotation + " (rot dist="+calculateDifferenceBetweenAngles(t.rotation,screenRotation)+")");
 	println("Close Enough Z: " +  closeZ + " (cursor Z = " + t.z + ", target Z = " + screenZ +")");
	
	return closeDist && closeRotation && closeZ;	
}

//utility function I include
double calculateDifferenceBetweenAngles(float a1, float a2)
  {
     double diff=abs(a1-a2);
      diff%=90;
      if (diff>45)
        return 90-diff;
      else
        return diff;
 }
 
float angle(PVector v1, PVector v2) {
  float a = atan2(v2.y, v2.x) - atan2(v1.y, v1.x);
  //if (a < 0) a += TWO_PI;
  return a;
}