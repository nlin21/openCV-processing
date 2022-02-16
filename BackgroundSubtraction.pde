void backgroundSubtraction(int used) {
  if (used == 0) {
    image(video, 0, 0);  
    opencv.loadImage(video);  
  }
  if (used == 1) {
    image(image,0,0);
    opencv.loadImage(image);
  }
  
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
