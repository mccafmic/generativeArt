// Under GNU v3.0 License
// Made by Estlin (Kassian Houben) for his 5 track EP "Imperative"
// Find it on all major platforms

import ddf.minim.*;
import ddf.minim.analysis.*;
import ddf.minim.effects.*;
import ddf.minim.signals.*;
import ddf.minim.spi.*;
import ddf.minim.ugens.*;

import com.hamoid.*;

VideoExport videoExport;

// Configuration variables
// ------------------------
int canvasWidth = 1080;
int canvasHeight = 1080;

String audioFileName = "idea_34_.mp3"; // Audio file in data folder

boolean export = false; // Either export or real time
boolean generateAudioTxtFile = false; // Will auto generate if export is true and no audio txt file exists

float fps = 30;
float smoothingFactor = 0.25; // FFT audio analysis smoothing factor
// ------------------------

// Global variables

// Export variables
String SEP = "|";
float frameDuration = 1 / fps;
BufferedReader audioReader;
String[] fftFile;
String songName;

// Real time variables
AudioPlayer track;
FFT fft;
Minim minim;  

// General
int bands = 256; // must be multiple of two
float[] spectrum = new float[bands];
float[] sum = new float[bands];


// Graphics
float unit;
int groundLineY;
PVector center;


// Processing 3.0 function for setting size() with variables
void settings() {
  size(canvasWidth, canvasHeight);
  smooth(8);
}


void setup() {
  hint(ENABLE_STROKE_PURE);
  
  if (!export) {
    frameRate(fps);
  }
  
  if (export) {
    // Produce the video as fast as possible
    frameRate(1000);
  }

  // Graphics related variable setting
  unit = height / 100; // Everything else can be based around unit to make it change depending on size 
  strokeWeight(unit / 10.24);
  groundLineY = height * 3/4;
  center = new PVector(width / 2, height * 3/4);
  
  // Set up .mp4 export
  if (export) {
    File tempFile = new File(dataPath(audioFileName + ".txt"));
  
    // Make sure txt file exists
    if (!tempFile.exists() || generateAudioTxtFile) {
      if(!audioToTextFile(audioFileName)) {
        exit();
      }
    }
    
    // Now open the text file we just created for reading
    audioReader = createReader(audioFileName + ".txt");

    // Set up the video exporting
    videoExport = new VideoExport(this);
    videoExport.setFrameRate(fps);
    
    try {
      videoExport.setAudioFileName(audioFileName);
    }
    catch (Exception e){
      println("Could not set video export audio file");
    }
    videoExport.startMovie();
    
  }
  else { // Real time
    minim = new Minim(this);
    track = minim.loadFile(audioFileName, 2048);
    
    track.loop();
    
    fft = new FFT( track.bufferSize(), track.sampleRate() );
    
    fft.linAverages(bands);
    
    // track.cue(60000); // Cue in miliseconds
  }
}


void draw() {

  // If exporting to mp4
  if (export) {
    String line;
    try {
      line = audioReader.readLine(); // Reads txt file line by line
    }
    catch (IOException e) {
      e.printStackTrace();
      line = null;
    }
    if (line == null) {
      // Done reading the file.
      // Close the video file.
      
      if (export) {
        videoExport.endMovie();
      }
      
      exit();
    } else {
      if (export) { // remove first frame from visualizer
        if (frameCount == 1) {
          return;
        }
      }
      
      String[] p = split(line, SEP);
  
      float soundTime = float(p[0]);
      
      //println("Current export time: " + videoExport.getCurrentTime());
      //println("Sound time: " + soundTime);

      while (videoExport.getCurrentTime() < soundTime + frameDuration * 10) {  // frameDuration * delay -- need to experiment
        spectrum = new float[bands];
        
        // Iterate over all our data points (different
        for (int i=1; i<p.length; i += 2) { // Iterate through pairs of L/R
          spectrum[((i + 1) / 2) - 1] = (float(p[i]) + float(p[i + 1])) / 2; // Average of left right and add to spectrum
          
          // Smooth the FFT spectrum data by smoothing factor
          sum[((i + 1) / 2) - 1] += (abs(spectrum[((i + 1) / 2) - 1]) - sum[((i + 1) / 2) - 1]) * smoothingFactor;
        }
        
        // Reset canvas
        fill(0);
        noStroke();
        rect(0, 0, width, height);
        noFill();
        
        drawAll(sum);
      
        if (export) {
          videoExport.saveFrame();
        }
      }
    }
  }
  else { // Real time
    fft.forward( track.mix );
    
    spectrum = new float[bands];
    
    for(int i = 0; i < fft.avgSize(); i++)
    {
      spectrum[i] = fft.getAvg(i) / 2 + fft.getAvg(i) / 2; // Average of left right and add to spectrum
          
      // Smooth the FFT spectrum data by smoothing factor
      sum[i] += (abs(spectrum[i]) - sum[i]) * smoothingFactor;
    }
    
    // Reset canvas
    fill(0);
    noStroke();
    rect(0, 0, width, height);
    noFill();
    
    drawAll(sum);
  }
}


// Get the Y position at position X of ground sine wave
float getGroundY(float groundX) {

  float angle = 1.1 * groundX / unit * 10.24;

  float groundY = sin(radians(angle + frameCount * 2)) * unit * 1.25 + groundLineY - unit * 1.25;

  return groundY;
}


// Does circle contain point
boolean circleContains(PVector position, PVector center, float radius) {
  // If distance between center and point is less than radius, then circle contains
  if (dist(position.x, position.y, center.x, center.y) < radius) {
    return true;
  }
  return false;
}


// Minim based audio FFT to data text file conversion.
boolean audioToTextFile(String fileName) {
  PrintWriter output;

  Minim minim = new Minim(this);
  output = createWriter(dataPath(fileName + ".txt"));
  
  AudioSample track;

  try {
    track = minim.loadSample(fileName, 2048);
  }
  
  catch (Exception e) {
    println("Error: " + e);
    println("Could not get audio file titled: " + fileName);
    return false;
  }

  int fftSize = 1024;
  float sampleRate = track.sampleRate();

  float[] fftSamplesL = new float[fftSize];
  float[] fftSamplesR = new float[fftSize];

  float[] samplesL = track.getChannel(AudioSample.LEFT);
  float[] samplesR = track.getChannel(AudioSample.RIGHT);  

  FFT fftL = new FFT(fftSize, sampleRate);
  FFT fftR = new FFT(fftSize, sampleRate);

  //fftL.logAverages(86, 1);
  //fftR.logAverages(86, 1);
  
  fftL.linAverages(bands);
  fftR.linAverages(bands);
  

  int totalChunks = (samplesL.length / fftSize) + 1;
  int fftSlices = fftL.avgSize();

  for (int ci = 0; ci < totalChunks; ++ci) {
    int chunkStartIndex = ci * fftSize;   
    int chunkSize = min( samplesL.length - chunkStartIndex, fftSize );

    System.arraycopy( samplesL, chunkStartIndex, fftSamplesL, 0, chunkSize);      
    System.arraycopy( samplesR, chunkStartIndex, fftSamplesR, 0, chunkSize);      
    if ( chunkSize < fftSize ) {
      java.util.Arrays.fill( fftSamplesL, chunkSize, fftSamplesL.length - 1, 0.0 );
      java.util.Arrays.fill( fftSamplesR, chunkSize, fftSamplesR.length - 1, 0.0 );
    }

    fftL.forward( fftSamplesL );
    fftR.forward( fftSamplesL );

    // The format of the saved txt file.
    // The file contains many rows. Each row looks like this:
    // T|L|R|L|R|L|R|... etc
    // where T is the time in seconds
    // Then we alternate left and right channel FFT values
    // The first L and R values in each row are low frequencies (bass)
    // and they go towards high frequency as we advance towards
    // the end of the line.
    StringBuilder msg = new StringBuilder(nf(chunkStartIndex/sampleRate, 0, 3).replace(',', '.'));
    for (int i=0; i<fftSlices; ++i) {
      msg.append(SEP + nf(fftL.getAvg(i), 0, 4).replace(',', '.'));
      msg.append(SEP + nf(fftR.getAvg(i), 0, 4).replace(',', '.'));
    }
    output.println(msg.toString());
  }
  track.close();
  output.flush();
  output.close();
  println("Sound analysis done");
  
  return true;
}


void keyPressed() {
  if (key == 'q') {
    if (export) {
      videoExport.endMovie();
    }
    
    exit();
  }
}






int sphereRadius;

float spherePrevX;
float spherePrevY;

int yOffset;

boolean initialStatic = true;
float[] extendingSphereLinesRadius;


// Draw static parts - prevents re-calculation - faster real time render
void drawStatic() {
  
  if (initialStatic) {
    extendingSphereLinesRadius = new float[241];
    
    for (int angle = 0; angle <= 240; angle += 4) {
      extendingSphereLinesRadius[angle] = map(random(1), 0, 1, sphereRadius, sphereRadius * 7);
    }
    
    initialStatic = false;
  }

  // More extending lines
  for (int angle = 0; angle <= 240; angle += 4) {
  
    float x = round(cos(radians(angle + 150)) * sphereRadius + center.x);
    float y = round(sin(radians(angle + 150)) * sphereRadius + groundLineY - yOffset);
    
    float xDestination = x;
    float yDestination = y;

    // Draw lines in small increments to make it easier to work with 
    for (int i = sphereRadius; i <= extendingSphereLinesRadius[angle]; i++) {
      float x2 = cos(radians(angle + 150)) * i + center.x;
      float y2 = sin(radians(angle + 150)) * i + groundLineY - yOffset;
      
      if (y2 <= getGroundY(x2)) { // Make sure it doesnt go into ground
        xDestination = x2;
        yDestination = y2;
      }
    }
    
    stroke(255);
    
    if (y <= getGroundY(x)) {
      line(x, y, xDestination, yDestination);
    }
  }
}


// Draws everything
void drawAll(float[] sum) {
  // Center sphere
  sphereRadius = 15 * round(unit);

  spherePrevX = 0;
  spherePrevY = 0;

  yOffset = round(sin(radians(150)) * sphereRadius);

  drawStatic();
  
  // Lines surrounding
  float x = 0;
  float y = 0;
  int surrCount = 1;
  
  boolean direction = false;
  
  while (x < width * 1.5 && x > 0 - width / 2) {

    float surroundingRadius;
    
    float surrRadMin = sphereRadius + sphereRadius * 1/2 * surrCount;
    float surrRadMax = surrRadMin + surrRadMin * 1/8;

    float surrYOffset;
    
    float addon = frameCount * 1.5;
    
    if (direction) {
      addon = addon * 1.5;
    }

    for (float angle = 0; angle <= 240; angle += 1.5) {
      
      surroundingRadius = map(sin(radians(angle * 7 + addon)), -1, 1, surrRadMin, surrRadMax); // Faster rotation through angles, radius oscillates
      
      surrYOffset = sin(radians(150)) * surroundingRadius;

      x = round(cos(radians(angle + 150)) * surroundingRadius + center.x);
      y = round(sin(radians(angle + 150)) * surroundingRadius + getGroundY(x) - surrYOffset);

      noStroke();
      fill(map(surroundingRadius, surrRadMin, surrRadMax, 100, 255));
      circle(x, y, 3 * unit / 10.24);
      noFill();
    }

    direction = !direction;
    
    surrCount += 1;
  }

  // Lines extending from sphere
  float extendingLinesMin = sphereRadius * 1.3;
  float extendingLinesMax = sphereRadius * 3.5; 
  
  float xDestination;
  float yDestination;
  
  for (int angle = 0; angle <= 240; angle++) {

    float extendingSphereLinesRadius = map(noise(angle * 0.3), 0, 1, extendingLinesMin, extendingLinesMax);
        
    // Radius are mapped differently for highs, mids, and lows - alter higher mapping number for different result (eg. 0.8 to 0.2 in the highs)
    if (sum[0] != 0) {
      if (angle >= 0 && angle <= 30) {
        extendingSphereLinesRadius = map(sum[240 - round(map((angle), 0, 30, 0, 80))], 0, 0.8, extendingSphereLinesRadius - extendingSphereLinesRadius / 8, extendingLinesMax * 1.5); // Highs
      }
      
      else if (angle > 30 && angle <= 90) {
        extendingSphereLinesRadius = map(sum[160 - round(map((angle - 30), 0, 60, 0, 80))], 0, 3, extendingSphereLinesRadius - extendingSphereLinesRadius / 8, extendingLinesMax * 1.5); // Mids
      }
      
      else if (angle > 90 && angle <= 120) {
        extendingSphereLinesRadius = map(sum[80 - round(map((angle - 90), 0, 30, 65, 80))], 0, 40, extendingSphereLinesRadius - extendingSphereLinesRadius / 8, extendingLinesMax * 1.5); // Bass
      }
      
      else if (angle > 120 && angle <= 150) {
        extendingSphereLinesRadius = map(sum[0 + round(map((angle - 120), 0, 30, 0, 15))], 0, 40, extendingSphereLinesRadius - extendingSphereLinesRadius / 8, extendingLinesMax * 1.5); // Bass
      }
      
      else if (angle > 150 && angle <= 210) {
        extendingSphereLinesRadius = map(sum[80 + round(map((angle - 150), 0, 60, 0, 80))], 0, 3, extendingSphereLinesRadius - extendingSphereLinesRadius / 8, extendingLinesMax * 1.5); // Mids
      }
      
      else if (angle > 210) {
        extendingSphereLinesRadius = map(sum[160 + round(map((angle - 210), 0, 30, 0, 80))], 0, 0.8, extendingSphereLinesRadius - extendingSphereLinesRadius / 8, extendingLinesMax * 1.5); // Highs
      }
    }
    
    x = round(cos(radians(angle + 150)) * sphereRadius + center.x);
    y = round(sin(radians(angle + 150)) * sphereRadius + groundLineY - yOffset);

    xDestination = x;
    yDestination = y;

    for (int i = sphereRadius; i <= extendingSphereLinesRadius; i++) {
      int x2 = round(cos(radians(angle + 150)) * i + center.x);
      int y2 = round(sin(radians(angle + 150)) * i + groundLineY - yOffset);
      
      if (y2 <= getGroundY(x2)) { // Make sure it doesnt go into ground
        xDestination = x2;
        yDestination = y2;
      }
    }
    
    stroke(map(extendingSphereLinesRadius, extendingLinesMin, extendingLinesMax, 200, 255));
    
    if (y <= getGroundY(x))  {
      line(x, y, xDestination, yDestination);
    }
  }

  // Ground line
  for (int groundX = 0; groundX <= width; groundX++) {

    float groundY = getGroundY(groundX);

    noStroke();
    fill(255);
    circle(groundX, groundY, 1.8 * unit / 10.24);
    noFill();
  }
}
