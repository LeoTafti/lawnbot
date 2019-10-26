import java.util.HashSet;

public final color sampleBoundsColor = color(255);
public final color sampleLawnColor = color(0, 204, 0);
public final color sampleMowedColor = color(153, 255, 102);

public Point[] sampleLawnPoints = {new Point(50, 150),
                             new Point(190, 30),
                             new Point(450, 30),
                             new Point(450, 250),
                             new Point(320, 320),
                             new Point(150, 340),
                             new Point(50, 340)};
public class Lawn{
 public Lawn(Point[] boundPoints, color boundsColor, color lawnColor, color mowedColor){
   this.boundPoints = boundPoints;
   this.mowedPoints = new ArrayList<Point>();
   
   //Creating a set of lines, useful to check intersection
   bounds = new HashSet<Line>();
   for(int i = 0; i < boundPoints.length - 1; i++){
     bounds.add(new Line(boundPoints[i].x, boundPoints[i].y, boundPoints[i+1].x, boundPoints[i+1].y));
   }
   bounds.add(new Line(boundPoints[boundPoints.length - 1].x, boundPoints[boundPoints.length - 1].y, boundPoints[0].x, boundPoints[0].y));

   this.boundsColor = boundsColor;
   this.lawnColor = lawnColor;
   this.mowedColor = mowedColor;
 }
 
 public Lawn(Point[] points){
   this(points, sampleBoundsColor, sampleLawnColor, sampleMowedColor);
 }
 
 //public void createRandomLawn(int nbSides){
 //  //TODO : implement
 //}
 
 public void draw(){
   beginShape();
     stroke(boundsColor);
     strokeWeight(5);
     fill(lawnColor);
     for(Point p : boundPoints){
       vertex(p.x, p.y);
     }
     vertex(boundPoints[0].x, boundPoints[0].y);
   endShape();
   
   beginShape();
     stroke(mowedColor);
     strokeWeight(25);
     strokeJoin(ROUND);
     for(Point p : mowedPoints){
       vertex(p.x, p.y); 
     }
   endShape();
   
   beginShape();
     stroke(boundsColor);
     strokeWeight(6);
     noFill();
     for(Point p : boundPoints){
       vertex(p.x, p.y);
     }
     vertex(boundPoints[0].x, boundPoints[0].y);
   endShape();
 }
 
 private Point[] boundPoints;
 private HashSet<Line> bounds;
 private ArrayList<Point> mowedPoints;
 private color boundsColor;
 private color lawnColor;
 private color mowedColor;
}

class Line{
  public Line(float x1, float y1, float x2, float y2){
    this.x1 = x1;
    this.y1 = y1;
    this.x2 = x2;
    this.y2 = y2;
  }
  
  public float x1, y1, x2, y2;
  
  public String toString(){
    return "[" + "(" + (int)x1 + ", " + (int)y1 + ")" + ", " + "(" + (int)x2 + ", " + (int)y2 + ")" + "]";
  }
}

class Point{
  public Point(float x, float y){
    this.x = x;
    this.y = y;
  }
  
  public float x, y;
  
  public String toString(){
    return "(" + (int)x + ", " + (int)y + ")";
  }
}
