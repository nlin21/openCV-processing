Rectangle[] objects;

void ObjectDetection(String objectToDetect) {
  if (objectToDetect.equals("face")) {
    opencv.loadCascade(OpenCV.CASCADE_FRONTALFACE);
  } else if (objectToDetect.equals("eye")) {
    opencv.loadCascade(OpenCV.CASCADE_EYE);
  } else if (objectToDetect.equals("mouth")) {
    opencv.loadCascade(OpenCV.CASCADE_MOUTH);
  } else if (objectToDetect.equals("nose")) {
    opencv.loadCascade(OpenCV.CASCADE_NOSE);
  } else if (objectToDetect.equals("rightEar")) {
    opencv.loadCascade(OpenCV.CASCADE_RIGHT_EAR);
  }
  
  opencv.loadImage(video);
  image(video,0,0);
  
  objects = opencv.detect();
  
  noFill();
  stroke(0,255,0);
  strokeWeight(3);
  
  for (int i = 0; i < objects.length; i++) {
    rect(objects[i].x, objects[i].y, objects[i].width, objects[i].height);
  }
}
