float noiseScale = 0.003;
int starHeight = 500;
int numStars = 200;
int dawnColorHeight = 2;
Star[] sky = new Star[numStars];

void setup () {
  size(1112, 834);
  generateStars();
}

void draw() {
  generateBackground(color(63, 128, 166), color(228, 133, 189));
  generateMountains(5);
  for (Star star : sky) {
    star.shine();
  }
}

void generateBackground(color up, color down) {
  strokeWeight(1);
  float hSq = height*height;
  for (int y = 0; y < height; y++) {
    float t = (y*y)/hSq*dawnColorHeight; // customize height of dawn color
    stroke(lerpColor(up, down, t));
    line(0, y, width, y);
  }
}

void generateMountains(float layers) {
  int noiseLayers = 9;
  int xOffset = 5;

  for (int i = 0; i <layers; i++) {
    float offset = 0.3+i/(layers+1)/2;

    beginShape();
    fill(255 - (i/layers * 255), map(i/layers, 0, 1, 170, 255));
    noStroke();
    vertex(0, height);

    for (int x = -1; x <= width; x += xOffset) {
      float y = offset;
      for (int n = 0; n < noiseLayers; n++) {
        y += noise((x+i*width+n*width)*noiseScale) * n/noiseLayers / 4; // turns horizontal lines into mountains
      }
      vertex(x, y*height);
    }
    vertex(width, height);
    endShape();
  }
}

void generateStars() {
  for (int i = 0; i < numStars; i++) {
    sky[i] = new Star();
  }
}

class Star {
  float x, y, c, a, dir, sz;

  Star() {
    noStroke();
    this.x = 255;
    this.y = 255;
    this.c = 255;
    this.a = -1;
    this.dir = 0.0;
    this.sz = 0.0;
  }

  void shine() {
    if (this.a < 0) {
      this.x = random(width);
      this.y = random(0, starHeight);
      this.sz = random(4);
      this.dir = random(1, 3);
      this.a = 0;
    }
    fill(this.c, this.a);
    ellipse(this.x, this.y, this.sz, this.sz);
    this.a += this.dir;
    if (this.a > 255) {
      this.a = 255;
      this.dir = random(-3, -1);
    }
  }
}
