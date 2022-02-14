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
    OBJECT_RECOGNITION,
    ADJUST_BRIGHTNESS,
    IMAGE_FILTER,
    FIND_CONTOURS,
    FIND_EDGES,
    FIND_LINES,
    BACKGROUND_SUBTRACTION,
    COLOR_CHANNELS,
    NONE
}

void setup() {
  size(800, 800);
  frameRate(60);
  useCamera = false;
  opencv = new OpenCV(this, width, height);
  
  featureUsed = Feature.NONE;
}

void draw() {
  brc();
  String changed = brcChanged();
  if (changed.equals("init")) {
    if (brcValue("cameraOn").equals("True")) {
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
    image(video, 0, 0);
    video.read();
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
    //findEdges(brcValue("filterType"));
  } else if (featureUsed == Feature.FIND_LINES) {
    //findLines();
  } else if (featureUsed == Feature.BACKGROUND_SUBTRACTION) {
    //backgroundSubtraction();
  } else if (featureUsed == Feature.COLOR_CHANNELS) {
    //colorChannels(brcValue("colorType"));
  }
}
