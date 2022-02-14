PImage src, r, g, b, h, s, v;
int imgH, imgW;

void colorChannels(PImage src){
  r = opencv.getSnapshot(opencv.getR());
  g = opencv.getSnapshot(opencv.getG());
  b = opencv.getSnapshot(opencv.getB());  
  imgH = src.height/3;
  imgW = src.width/3;
  opencv.useColor(HSB);
  h = opencv.getSnapshot(opencv.getH());
  s = opencv.getSnapshot(opencv.getS());  
  v = opencv.getSnapshot(opencv.getV());
  
  background(0);
  noTint();
  image(src, imgW,0, imgW, imgH);
  
  tint(255,0,0);
  image(r, 0, imgH, imgW, imgH);
  
  tint(0,255,0);
  image(g, imgW, imgH, imgW, imgH);
  
  tint(0,0,255);
  image(b, 2*imgW, imgH, imgW, imgH);
  
  noTint();
  image(h, 0, 2*imgH, imgW, imgH);
  image(s, imgW, 2*imgH, imgW, imgH);
  image(v, 2*imgW, 2*imgH, imgW, imgH);
}
