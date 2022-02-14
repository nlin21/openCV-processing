void AdjustBrightness(int brightness) {
  opencv.useColor();
  
  if (useCamera) {
    opencv.loadImage(video);
  } else {
    opencv.loadImage(image);
  }
    
  opencv.brightness(brightness);
  image(opencv.getOutput(),0,0);  
}
