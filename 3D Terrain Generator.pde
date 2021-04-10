int rows, cols;
int w, h;
int scale = 10;
float MAX_HEIGHT = 0;
float MIN_HEIGHT = 10000;
float heightScale, power, powerCoefficient;
float xOffset = 0; float yOffset = 0; float zOffset = 0;
float planeAngle = PI;
float azimuth = PI/2;

float[][] noiseHeights;
float[][] actualHeights;
color[][][] colors;

Slider heightScaleSlider = new Slider(0, 200, 40, 40, 400);
Slider powerSlider = new Slider(0.0001, 5, 40, 80, 400);
Slider powerCoefficientSlider = new Slider(0, 5, 40, 120, 400);

void setup() {

  size(1000, 1000, P3D);
  //fullScreen(P3D);
  
  w = 1600;
  h = 1200;
  
  rows = h/scale;
  cols = w/scale;
  
  noiseHeights = new float[cols+1][rows+1];
  actualHeights = new float[cols+1][rows+1];
  colors = new color[cols+1][rows+1][2];
  
  for(int y = 0; y < rows+1; y++) {
  
    for(int x = 0; x < cols+1; x++) {
    
      noiseHeights[x][y] = noise(x*(16.0/rows), y*(16.0/cols));
      
    }
    
  }
  
}

void draw() {
  
  heightScale = heightScaleSlider.getValue();
  power = powerSlider.getValue();
  powerCoefficient = powerCoefficientSlider.getValue();
  
  //camera(width/2.0 + xOffset, height/2.0 + yOffset, ((height/2.0) / tan(PI*30.0 / 180.0)) + zOffset, (width/2.0) * sin(planeAngle) + width/2.0 + xOffset, (height/2) * cos(azimuth) + height/2 + yOffset, (width/2.0) * (cos(planeAngle)) * sin(azimuth) + ((height/2.0) / tan(PI*30.0 / 180.0)) + zOffset, 0, 1, 0);
  
  camera(width/2.0 + xOffset, height/2.0 + yOffset, ((height/2.0) / tan(PI*30.0 / 180.0)) + zOffset, (width/2.0) * sin(planeAngle) + width/2.0 + xOffset, (height/2) * tan(azimuth)*signum(sin(azimuth - PI/2)) + height/2 + yOffset, (width/2.0) * (cos(planeAngle)) + ((height/2.0) / tan(PI*30.0 / 180.0)) + zOffset, 0, 1, 0);
  
  //directionalLight(255, 255, 255, 1, 0.8, -0.8);
  pointLight(255, 255, 255, width/2, 100, height);
  ambientLight(50, 50, 50);

  for(int y = 0; y < rows+1; y++) {
  
    for(int x = 0; x < cols+1; x++) {
    
      actualHeights[x][y] = (float)Math.pow(map(noiseHeights[x][y], 0, 1, 0, powerCoefficient), power) * map(noise((x+100)*0.05, (y+100)*0.05), 0, 1, 0, 1.5) * heightScale;
      
      if(actualHeights[x][y] > MAX_HEIGHT) {
      
        MAX_HEIGHT = actualHeights[x][y];
        
      }
      
      if(actualHeights[x][y] < MIN_HEIGHT) {
      
        MIN_HEIGHT = actualHeights[x][y];
        
      }
      
    }
    
  }
  
  background(147, 214, 219);
  stroke(255);
  strokeWeight(0.5);
  noStroke();
  
  translate(width/2, height/2);
  rotateX(PI/2);
  translate(-w/2, -h/2);

  for(int y = 0; y < rows; y++) {
  
    for(int x = 0; x < cols; x++) {
      
      float slope = max(actualHeights[x][y], actualHeights[x+1][y], actualHeights[x][y+1]) - min(actualHeights[x][y], actualHeights[x+1][y], actualHeights[x][y+1]);
      
      if(slope > 5) {
      
        fill(lerpColor(color(145, 99, 25), color(100, 100, 100), map(abs(slope), 5, 15, 0, 1)));
        
      } else {
      
        fill(lerpColor(color(56, 161, 60), color(145, 99, 25), map(abs(slope), 0, 5, 0, 1)));
        
      }
      
      beginShape(TRIANGLE); //right angle in top left
      
      vertex(x*scale, y*scale, actualHeights[x][y]);
      vertex((x+1)*scale, y*scale, actualHeights[x+1][y]);
      vertex(x*scale, (y+1)*scale, actualHeights[x][y+1]);
      
      endShape(TRIANGLE);
      
      slope = max(actualHeights[x+1][y+1], actualHeights[x][y+1], actualHeights[x+1][y]) - min(actualHeights[x+1][y+1], actualHeights[x][y+1], actualHeights[x+1][y]);
      
      if(slope > 5) {
      
        fill(lerpColor(color(145, 99, 25), color(100, 100, 100), map(abs(slope), 5, 15, 0, 1)));
        
      } else {
      
        fill(lerpColor(color(56, 161, 60), color(145, 99, 25), map(abs(slope), 0, 5, 0, 1)));
        
      }
      
      //fill(colors[x][y][1]);
      
      beginShape(TRIANGLE); //right angle in bottom right
      
      vertex((x+1)*scale, (y+1)*scale, actualHeights[x+1][y+1]);
      vertex(x*scale, (y+1)*scale, actualHeights[x][y+1]);
      vertex((x+1)*scale, y*scale, actualHeights[x+1][y]);
      
      endShape(TRIANGLE);
      
    }
    
  }
  
  if(keyPressed) {
    
    if(keyCode == ENTER) {
    
      saveFrame("output/frame at " + hour() + minute() + second() + " on " + day() + month() + year() + ".png");
      println("\"output/frame at " + hour() + minute() + second() + " on " + day() + month() + year() + ".png\" saved!");
      
    }  
    
    if(key == 'w') {
    
      zOffset += 5*cos(planeAngle);
      xOffset += 5*sin(planeAngle);
      
    }
    
    if(key == 's') {
    
      zOffset -= 5*cos(planeAngle);
      xOffset -= 5*sin(planeAngle);
      
    }
    
    if(key == 'a') {
    
      zOffset += 5*cos(planeAngle + PI/2);
      xOffset += 5*sin(planeAngle + PI/2);
      
    }
    
    if(key == 'd') {
    
      zOffset += 5*cos(planeAngle - PI/2);
      xOffset += 5*sin(planeAngle - PI/2);
      
    }
    
    if(key == ' ') {
    
      yOffset -= 5;
      
    }
    
    if(keyCode == SHIFT) {
    
      yOffset += 5;
      
    }
    
    if(keyCode == LEFT) {
    
      planeAngle += PI*0.01;
      
    }
    
    if(keyCode == RIGHT) {
    
      planeAngle -= PI*0.01;
      
    }
    
    if(keyCode == UP) {
    
      azimuth += PI*0.01;
      
    }
    
    if(keyCode == DOWN) {
    
      azimuth -= PI*0.01;
      
    }
    
  }
  
  camera();
  hint(DISABLE_DEPTH_TEST);
  heightScaleSlider.update(); powerSlider.update(); powerCoefficientSlider.update();
  textAlign(LEFT, CENTER);
  textSize(20);
  text("Height Scale", 460, 40);
  text("Power", 460, 80);
  text("Power Coefficient", 460, 120);
  text(azimuth, 800, 100);
  
}

int signum(float f) {
  if (f > 0) return 1;
  if (f < 0) return -1;
  return 0;
} 

class Slider {

  float min, max;
  float pos, value;
  float x, y, sLength;
  
  boolean selected;
  
  Slider(float min, float max, float x, float y, float sLength) {
  
    this.min = min;
    this.max = max; 
    this.x = x;
    this.y = y;
    this.sLength = sLength;
    
    pos = 0;
    
  }
  
  void update() {
    
    fill(g.backgroundColor); noStroke();
    rect(x-15, y-15, sLength+30, 30);
    fill(0); stroke(0); strokeWeight(4);
    line(x, y, x+sLength, y);
  
    if(((mousePressed && abs(mouseY - y) < 10) || (mousePressed && selected)) && mouseX > x && mouseX < x + sLength) {
    
      pos = map(mouseX, x, x + sLength, 0, 1);
      selected = true;
      
      value = map(pos, 0, 1, min, max);
      
      strokeWeight(4);
      stroke(255);
      
    } else {
      
      noStroke();
    
    }
    
    ellipse(map(pos, 0, 1, x, x + sLength), y, 20, 20);
    
    if(!mousePressed) {
    
      selected = false;
      
    }
    
  }
  
  float getValue() {
  
    return value;
    
  }
  
}
