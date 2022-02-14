PImage thresh, blur, adaptive;

void filterImage(String filter) {
  PImage gray = opencv.getSnapshot();

  opencv.threshold(int(brcValue("thresholdValue")));
  thresh = opencv.getSnapshot();

  opencv.loadImage(gray);
  opencv.blur(int(brcValue("blurValue")));
  blur = opencv.getSnapshot();

  opencv.loadImage(gray);
  opencv.adaptiveThreshold(int(brcValue("adaptiveBlockSize")), int(brcValue("adaptiveConstant")));
  adaptive = opencv.getSnapshot();

  if (filter.equals("t")) {
    image(thresh, 0, 0);
  } else if (filter.equals("b")) {
    image(blur, 0, 0);
  } else if (filter.equals("a")) {
    image(adaptive, 0, 0);
  }
}
