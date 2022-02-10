import gab.opencv.*;
import processing.video.*;

Capture video;
OpenCV opencv;
PImage canny;

void setup() {
  size(640, 480);
  
  video = new Capture(this, width, height);
  opencv = new OpenCV(this, video);

  video.start();
}

void draw() {
  canny = opencv.getSnapshot();
  opencv.loadImage(video);
  opencv.findCannyEdges(50,75);
  image(canny, 0, 0);
}

void captureEvent(Capture c) {
  c.read();
}
