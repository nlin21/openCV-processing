ArrayList<Line> lines;

void findLines(int threshold, int minLength, int maxLineGap){
  opencv.findCannyEdges(20, 75);
  lines = opencv.findLines(threshold, minLength, maxLineGap);
  image(opencv.getOutput(), 0, 0);
  
  strokeWeight(3);
  for (Line line : lines) {
    // lines include angle in radians, measured in double precision
    // so we can select out vertical and horizontal lines
    // They also include "start" and "end" PVectors with the position
    if (line.angle >= radians(0) && line.angle < radians(1)) {
      stroke(0, 255, 0);
      line(line.start.x, line.start.y, line.end.x, line.end.y);
    }

    if (line.angle > radians(89) && line.angle < radians(91)) {
      stroke(255, 0, 0);
      line(line.start.x, line.start.y, line.end.x, line.end.y);
    }
  }
}
