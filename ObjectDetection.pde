String cascade;
boolean cascaded = false;

void ObjectDetection(String objectToDetect) {
  opencv.useColor();
  
  if (useCamera) {
    opencv.loadImage(video);
  } else {
    opencv.loadImage(image);
  }
  
  if (!cascaded) {
    if (objectToDetect.equals("face")) {
      opencv.loadCascade(OpenCV.CASCADE_FRONTALFACE);
      cascade = "face";
    } else if (objectToDetect.equals("eye")) {
      opencv.loadCascade(OpenCV.CASCADE_EYE);
      cascade = "eye";
    } else if (objectToDetect.equals("mouth")) {
      opencv.loadCascade(OpenCV.CASCADE_MOUTH);
      cascade = "mouth";
    } else if (objectToDetect.equals("nose")) {
      opencv.loadCascade(OpenCV.CASCADE_NOSE);
      cascade = "nose";
    } else if (objectToDetect.equals("rightEar")) {
      opencv.loadCascade(OpenCV.CASCADE_RIGHT_EAR);
      cascade = "rightEar";
    }
    cascaded = true;
  } else if (brcValue("object").equals(cascade) == false) {
    cascaded = false;
  }
  
  image(opencv.getOutput(),0,0);
  
  Rectangle[] objects = opencv.detect();
  
  noFill();
  stroke(0,255,0);
  strokeWeight(3);
  
  for (int i = 0; i < objects.length; i++) {
    rect(objects[i].x, objects[i].y, objects[i].width, objects[i].height);
  }
}
