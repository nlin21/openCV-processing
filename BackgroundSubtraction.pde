void backgroundSubtraction() {
  try{
    image(video, 0, 0);  
  } catch(Exception NullPointerException) {
    System.out.println("Must enable camera");
    return;
  }
  
  opencv.loadImage(video);  

  opencv.updateBackground();
  
  opencv.dilate();
  opencv.erode();

  noFill();
  stroke(255, 0, 0);
  strokeWeight(3);
  for (Contour contour : opencv.findContours()) {
    contour.draw();
  }
}
