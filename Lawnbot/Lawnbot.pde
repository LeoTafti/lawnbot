final int WIDTH = 500, HEIGHT = 400;

Lawn lawn;
Mower mower;

void setup(){
  size(500, 400);
  lawn = new Lawn(sampleLawnPoints);
  
  mower = new Mower(sampleHomebasePoints[0],
                              sampleHomebasePoints[1],
                              sampleHomebasePoints[2],
                              sampleHomebasePoints[3]);
}

void draw(){
  //if(frameCount % 2 == 0){
  //  background(0, 51, 102);
  //  lawn.draw();
  //  mower.draw();
  //  mower.move();
  //}
  
  background(0, 51, 102);
  lawn.draw();
  mower.draw();
  mower.move();
}

void mouseClicked() {
  println(mouseX + ", " + mouseY);
}
