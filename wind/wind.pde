//https://github.com/whitegreen/GenerativeArt
int n=2000;
PVector[] ps= new PVector[n];
void setup() {
  size(1100, 800);   
  for (int i=0; i<n; i++) 
    ps[i]=  new PVector(random(width), random(height));
  background(0);
  colorMode(RGB);
}
void draw() {
  fill(0, 4);
  noStroke();
  rect(0, 0, width, height);
  stroke(255);
  float f1= 0.1*frameCount;  
  float f2= 0.1*frameCount;   
  for (int i=0; i<n; i++) {
    PVector p= ps[i];
    float theta=noise( 0.03*p.x , 0.03*p.y )*8*PI;  
    PVector a= new PVector(cos(theta), sin(theta) );
    PVector b= new PVector(cos(f1), cos(f2) );
    PVector v= PVector.lerp(a,b,0.4);
    p.add(v);
    if ( 0.00>random(1.0) ||p.x<0 || p.x>width || p.y<0 || p.y>height)
      ps[i]= new PVector(random(width), random(height)); 
    float mag= v.mag();
    stroke(100*mag, 255, 255);
    point(p.x, p.y);
  }
}
