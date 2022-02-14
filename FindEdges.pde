PImage canny, scharr, sobel;

void findEdges(String filterType) {
  opencv.findCannyEdges(20, 75);
  canny = opencv.getSnapshot();
  if (useCamera) {
    opencv.loadImage(video);
  } else {
    opencv.loadImage(image);
  }
  opencv.findScharrEdges(OpenCV.HORIZONTAL);
  scharr = opencv.getSnapshot();

  if (useCamera) {
    opencv.loadImage(video);
  } else {
    opencv.loadImage(image);
  }
  opencv.findSobelEdges(1, 0);
  sobel = opencv.getSnapshot();

  if (filterType.equals("canny")) {
    image(canny, 0, 0);
  } else if (filterType.equals("scharr")) {
    image(scharr, 0, 0);
  } else if (filterType.equals("sobel")) {
    image(sobel, 0, 0);
  }
}
