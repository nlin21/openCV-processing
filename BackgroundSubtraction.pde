Movie m;

void backgroundSubtraction(int used) {
  if (used == 0) {
    image(video, 0, 0);  
    opencv.loadImage(video);  
  }
  if (used == 1) {
    image(Movie,0,0);
    opencv.loadImage(Movie);
    m = Movie;
  }
  if (used == 2) {
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

void movieEvent(Movie m) {
  if (m == null) {
    return;
  }
  m.read();
}
