float noiseScale = 0.005;

void setup () {
 size(512,512); 
 background(52, 131, 235);
 generateBackground(color(52, 131, 235), color(235, 153, 52));
 generateMountains(5);
 noLoop();
}

void draw() {
  
}

void generateBackground(color up, color down) {
  strokeWeight(1);
  float hSq = height*height;
  for(int y = 0; y < height; y++) {
    float t = (y*y)/hSq; // customize height of dawn color
    stroke(lerpColor(up,down,t));
    line(0, y, width, y);
  }
}

void generateMountains(int layers) {
  int noiseLayers = 10;
  int xOffset = 5;
  
  for(int i = 0; i <layers; i++) {
   float offset = 0.3+i/(layers+1)/2;
   
   beginShape();
   fill(255 - (i/layers * 255), map(i/layers, 0, 1, 170, 255));
   noStroke();
   vertex(0, height);
   
   for(int x = -1; x <= width; x += xOffset) {
     float y = offset;
     for(int n = 0; n < noiseLayers; n++) {
       y += noise((x+i*width+n*width)*noiseScale) * n/noiseLayers / 4; // turns horizontal lines into mountains
     }
     vertex(x, y*height);
   }
   vertex(width, height);
   endShape();
  }
}
