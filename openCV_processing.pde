import gab.opencv.*;
import processing.video.*;
import java.awt.*;

Capture video;
PImage image;
OpenCV opencv;

boolean initialized = false;
boolean useCamera;

Feature featureUsed;

public enum Feature {
  OBJECT_RECOGNITION, // check
    ADJUST_BRIGHTNESS, // check
    IMAGE_FILTER, // check
    FIND_CONTOURS, 
    FIND_EDGES, // check
    FIND_LINES,
    BACKGROUND_SUBTRACTION, // check
    COLOR_CHANNELS,
    NONE
}

void setup() {
  size(800, 800);
  frameRate(60);
  useCamera = false;
  opencv = new OpenCV(this, width, height);
  brcShowMessages(true);
  featureUsed = Feature.NONE;
}

void draw() {
  brc();
  String changed = brcChanged();
  if (changed.equals("init")) {
    //println(brcValue("cameraOn"));
    if (brcValue("cameraOn").equals("true")) {
      video = new Capture(this, Capture.list()[0]);
      video.start();
      video.resize(width, height);

      initialized = true;
      useCamera = true;
    } else if (!brcValue("fileName").equals("")) {
      image = loadImage(brcValue("fileName"));
      image.resize(width, height);

      initialized = true;
    }
  }
  //println(initialized);
  if (!initialized) {
    return;
  }
  println(useCamera);
  if (useCamera) {
    if(video.available()){
      image(video, 0, 0);
      video.read();
    }
  } else {
    image(image, 0, 0);
  }
  // check states
  if (changed.equals("faceRecognition")) {
    featureUsed = Feature.OBJECT_RECOGNITION;
  } else if (changed.equals("adjustBrightness")) {
    featureUsed = Feature.ADJUST_BRIGHTNESS;
  } else if (changed.equals("imageFilter")) {
    featureUsed = Feature.IMAGE_FILTER;
  } else if (changed.equals("findEdges")) {
    featureUsed = Feature.FIND_EDGES;
  } else if (changed.equals("findLines")) {
    featureUsed = Feature.FIND_LINES;
  } else if (changed.equals("backgroundSubtraction")) {
    featureUsed = Feature.BACKGROUND_SUBTRACTION;
  } else if (changed.equals("colorChannels")) {
    featureUsed = Feature.COLOR_CHANNELS;
  }
  // run desired feature

  if (featureUsed == Feature.OBJECT_RECOGNITION) {
    String objectToDetect = brcValue("object");
    //imgDetection(objectToDetect);
  } else if (featureUsed == Feature.ADJUST_BRIGHTNESS) {
    //brightnessAdjust(int(brcValue("brightness")));
  } else if (featureUsed == Feature.IMAGE_FILTER) {
    if (useCamera) {
      opencv.loadImage(video);
    } else {
      opencv.loadImage(image);
    }
    filterImage(brcValue("filter"));
  } else if (featureUsed == Feature.FIND_EDGES) {
    if (useCamera) {
      opencv.loadImage(video);
    } else {
      opencv.loadImage(image);
    }
    findEdges(brcValue("filterType"));
  } else if (featureUsed == Feature.FIND_LINES) {
    //findLines();
  } else if (featureUsed == Feature.BACKGROUND_SUBTRACTION) {
    Movie movie = new Movie(this, "street.mov");
    opencv = new OpenCV(this, 720, 480);
    opencv.startBackgroundSubtraction(5, 3, 0.5);
    movie.loop();
    movie.play();
    backgroundSubtraction();
  } else if (featureUsed == Feature.COLOR_CHANNELS) {
    //colorChannels(brcValue("colorType"));
  }
}
