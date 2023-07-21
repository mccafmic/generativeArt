int n=100;
PVector[] ps= new PVector[n];
void setup() {
  size(800, 800);   
  background(0);
  colorMode(RGB);
  for (int i=0; i<n; i++) 
    ps[i] = new PVector(random(width), random(height));
}

void draw() {
  for (int i=0; i<n; i++) {
    PVector p = ps[i];
    stroke(p.mag(),360,360);
    point(p.x,p.y);
  }
}
