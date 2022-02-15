void AdjustContrast(float contrast) {
  opencv.useColor();
  
  if (useCamera) {
    opencv.loadImage(video);
  } else {
    opencv.loadImage(image);
  }
    
  opencv.contrast(contrast);
  image(opencv.getOutput(),0,0);  
}
