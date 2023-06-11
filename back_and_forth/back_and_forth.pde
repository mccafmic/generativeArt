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
  float f1= 0.05*frameCount;  
  float f2= 0.05*frameCount;
  for (int i=0; i<n; i++) {
    PVector p= ps[i];
    float theta=noise( 0.03*p.x , 0.03*p.y )*8*PI;  
    PVector a= new PVector(cos(theta), sin(theta) );
    PVector b= new PVector(cos(f1), cos(f2) );
    PVector v= PVector.lerp(a,b,20);
    p.add(v);
    if ( 0.1>random(1.0) ||p.x<0 || p.x>width || p.y<0 || p.y>height)
      ps[i]= new PVector(random(width), random(height)); 
    float mag= v.mag();
    //strokeWeight(1 + 0.6/(0.01+mag));  
    stroke(mag,360,360);
    point(p.x, p.y);
  }
}
