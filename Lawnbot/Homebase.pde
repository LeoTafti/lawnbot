public final float[] sampleHomebasePoints = {60, 220, 450, 140};
public final color sampleHomebaseColor = color(150, 0, 50);
public final color sampleHomelineColor = color(255, 0, 102);

public class Homebase{
  public Homebase(float x, float y, float lineEndX, float lineEndY, color homebaseColor, color homelineColor){
    this.x = x;
    this.y = y;
    
    this.lineEndX = lineEndX;
    this.lineEndY = lineEndY;
    
    this.homebaseColor = homebaseColor;
    this.homelineColor = homelineColor;
    
    homeline = new Line(x, y, lineEndX, lineEndY);
  }
  
  public Homebase(float x, float y, float lineEndX, float lineEndY){
    this(x, y, lineEndX, lineEndY, sampleHomebaseColor, sampleHomelineColor);
  }
  
  public void draw(){
     beginShape();
     stroke(homelineColor);
     strokeWeight(2);
     line(homeline.x1, homeline.y1, homeline.x2, homeline.y2);
     endShape();
    
     beginShape();
     stroke(homebaseColor);
     fill(homebaseColor);
     rect(x-7, y-15, 14, 30);
     endShape();
  }
  
  private float x, y;
  //TODO : remove if unused
  private float lineEndX, lineEndY;
  //TODO : remove if unused
  private Line homeline;
  
  private color homebaseColor;
  private color homelineColor;
}
