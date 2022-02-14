PImage thresh, blur, adaptive;

void filterImage(String filter) {
  PImage gray = opencv.getSnapshot();
 
  opencv.threshold(80);
  thresh = opencv.getSnapshot();
  
  opencv.loadImage(gray);
  opencv.blur(12);  
  blur = opencv.getSnapshot();
  
  opencv.loadImage(gray);
  opencv.adaptiveThreshold(591, 1);
  adaptive = opencv.getSnapshot();
  
  if (filter.equals("thresh")) {
    image(thresh, 0, 0);
  } else if (filter.equals("blur")) {
    image(blur, 0, 0);
  } else if (filter.equals("adaptive")) {
    image(adaptive, 0, 0);
  }
}
