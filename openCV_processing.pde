import gab.opencv.*;
import processing.video.*;
import java.awt.*;

Capture video;
PImage image;
Movie Movie;
OpenCV opencv;

boolean initialized = false;
boolean backgroundSubtractInit = false;
boolean useCamera;

Feature featureUsed;

public enum Feature {
  OBJECT_RECOGNITION, // check
  ADJUST_BRIGHTNESS, // check
  ADJUST_CONTRAST,
  IMAGE_FILTER, // check
  FIND_CONTOURS, //check
  FIND_EDGES, // check
  FIND_LINES, //check
  BACKGROUND_SUBTRACTION, // doesn't work yet
  COLOR_CHANNELS, //check
  NONE
}

void setup() {
  size(640, 480);
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
  if (!initialized) {
    return;
  }
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
  } else if (changed.equals("adjustContrast")) {
    featureUsed = Feature.ADJUST_CONTRAST;
  } else if (changed.equals("imageFilter")) {
    featureUsed = Feature.IMAGE_FILTER;
  } else if (changed.equals("findEdges")) {
    featureUsed = Feature.FIND_EDGES;
  } else if (changed.equals("findContours")) {
    featureUsed = Feature.FIND_CONTOURS;
  } else if (changed.equals("findLines")) {
    featureUsed = Feature.FIND_LINES;
  } else if (changed.equals("backgroundSubtraction")) {
    featureUsed = Feature.BACKGROUND_SUBTRACTION;
    backgroundSubtractInit = false;
  } else if (changed.equals("colorChannels")) {
    featureUsed = Feature.COLOR_CHANNELS;
  }
  // run desired feature

  if (featureUsed == Feature.OBJECT_RECOGNITION) {
    ObjectDetection(brcValue("object"));
  } else if (featureUsed == Feature.ADJUST_BRIGHTNESS) {
    int brightnessOffset = int(brcValue("brightness"));
    AdjustBrightness(brightnessOffset);
  } else if (featureUsed == Feature.ADJUST_CONTRAST) {
    float contrast = int(brcValue("contrast"))/100.;
    AdjustContrast(contrast);
  } else if (featureUsed == Feature.IMAGE_FILTER) {
    if (useCamera) {
      opencv.loadImage(video);
      opencv.gray();
    } else {
      opencv.loadImage(image);
      opencv.gray();
    }
    filterImage(brcValue("filter"));
  } else if (featureUsed == Feature.FIND_CONTOURS) {
    if (useCamera) {
      opencv.loadImage(video);
    } else {
      opencv.loadImage(image);
    }
    findContours(int(brcValue("contourThreshold")));
  } else if (featureUsed == Feature.FIND_EDGES) {
    if (useCamera) {
      opencv.loadImage(video);
    } else {
      opencv.loadImage(image);
    }
    findEdges(brcValue("filterType"));
  } else if (featureUsed == Feature.FIND_LINES) {
    if (useCamera) {
      opencv.loadImage(video);
    } else {
      opencv.loadImage(image);
    }
    findLines(int(brcValue("findLinesThreshold")), int(brcValue("findLinesMinLength")), int(brcValue("findLinesMaxLineGap")));
  } else if (featureUsed == Feature.BACKGROUND_SUBTRACTION) {
    if (brcValue("imageSource").equals("M")) {
      if (!backgroundSubtractInit) {
        Movie = new Movie(this, brcValue("movie") + ".mov");
        opencv = new OpenCV(this, width,height);
        opencv.startBackgroundSubtraction(5, 3, 0.5);
        Movie.loop();
        Movie.play();
        backgroundSubtractInit = true;
      }
      backgroundSubtraction(1);
    } else if (brcValue("imageSource").equals("C")) {
      if (!backgroundSubtractInit) {
        opencv = new OpenCV(this,width,height);
        opencv.startBackgroundSubtraction(5, 3, 0.5);
        backgroundSubtractInit = true;
      }
      backgroundSubtraction(0);
    } else {
      if (!backgroundSubtractInit) {
        opencv = new OpenCV(this,width,height);
        opencv.startBackgroundSubtraction(5, 3, 0.5);
        backgroundSubtractInit = true;
      }
      backgroundSubtraction(2);
    }
  } else if (featureUsed == Feature.COLOR_CHANNELS) {
    if (useCamera) {
      opencv.loadImage(video);
      colorChannels(video);
    } else {
      opencv.loadImage(image);
      colorChannels(image);
    }
    
  }
}
