import gab.opencv.*;
import processing.video.*;

OpenCV opencv;
Capture video;

void setup() {
  size(640, 480);
  
  video = new Capture(this, width, height);
  opencv = new OpenCV(this, video);
  
  video.start();
}

void draw() {
  opencv.loadImage(video);
  opencv.useColor();
  opencv.brightness(100);
  image(opencv.getSnapshot(),0,0);
}

void captureEvent(Capture c) {
  c.read();
}
