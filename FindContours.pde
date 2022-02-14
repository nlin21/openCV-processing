PImage dst;

ArrayList<Contour> contours;
ArrayList<Contour> polygons;

void findContours(int threshold) {
  opencv.gray();
  opencv.threshold(threshold);
  dst = opencv.getOutput();
  contours = opencv.findContours();
  image(dst, 0, 0);
  noFill();
  strokeWeight(3);
  
  for (Contour contour : contours) {
    stroke(0, 255, 0);
    contour.draw();
    stroke(255, 0, 0);
    beginShape();
    for (PVector point : contour.getPolygonApproximation().getPoints()) {
      vertex(point.x, point.y);
    }
    endShape();
  }
}
