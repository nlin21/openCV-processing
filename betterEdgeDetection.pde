///import org.opencv.ximgproc.FastGlobalSmootherFilter;
//import org.opencv.core.Mat;

PImage edgeBlur, edgeAdaptive;

void betterEdgeDetection() {
  PImage gray = opencv.getSnapshot();
  opencv.loadImage(gray);
  opencv.blur(int(brcValue("blurValue")));
  edgeBlur = opencv.getSnapshot();
  edgeBlur.loadPixels();
  byte[] rawData = new byte[width * height];
  for (int i = 0; i < edgeBlur.pixels.length; i++) {
    rawData[i] = (byte)edgeBlur.pixels[i];
  }
  //Mat m = new Mat();
  //m.put(0,0,rawData);
  //Mat dest = new Mat();
  //FastGlobalSmootherFilter.filter(m,dest);
  
  opencv.loadImage(edgeBlur);
  opencv.adaptiveThreshold(int(brcValue("adaptiveBlockSize")), 1);
  edgeAdaptive = opencv.getSnapshot();
  image(edgeAdaptive, 0, 0);
}
