import java.util.Arrays;
import java.util.LinkedList;
import java.util.Iterator;

public final color sampleMowerColor = color(102, 102, 153);
public final float sampleOrientation = 0.0;

public enum Mode {
  SEARCHING, MOWING
}

public class Mower{
  public Mower(float homebaseX, float homebaseY, float lineEndX, float lineEndY, float orientation, color mowerColor, color homebaseColor, color homelineColor){
    this.mode = Mode.SEARCHING;
    
    hb = new Homebase(homebaseX, homebaseY, lineEndX, lineEndY, homebaseColor, homelineColor);
    
    pf = new PathFinder();
    mowingPath = null;
    nextPointIndex = 0;
    
    bounds = new HashSet();
    
    this.x = homebaseX + 15;
    this.y = homebaseY;
    
    this.orientation = orientation;
    
    this.atObstacleEdge = false;
    this.obstacleIsLeft = false;
    this.obstacles = new ArrayList();
    this.lastObstacle = null;
    
    this.sensor = new Point(x + cos(orientation) * 10, y + sin(orientation) * 10);
    
    this.col = mowerColor;
  }
  
  public Mower(float homebaseX, float homebaseY, float lineEndX, float lineEndY){
    this(homebaseX, homebaseY, lineEndX, lineEndY, sampleOrientation, sampleMowerColor, sampleHomebaseColor, sampleHomelineColor);
  }
  
  public void draw(){
    hb.draw();
      pushMatrix();
        translate(x+10, y);
        rotate(orientation);
        beginShape();
          stroke(col);
          fill(col);
          rect(-15, -13, 30, 26);
        endShape();
      
      //Sensor, to debug
        beginShape();
          stroke(color(255, 0, 0));
          fill(color(255, 0, 0));
          circle(sensor.x - x, sensor.y - y, 2);
        endShape();
      popMatrix();
  }
  
  public void move(){
    //ArrayList<Point> sampleBoundsPoint = new ArrayList();
    //sampleBoundsPoint.add(new Point(295, 339));
    //sampleBoundsPoint.add(new Point(60, 339));
    //sampleBoundsPoint.add(new Point(60, 68));
    //sampleBoundsPoint.add(new Point(227, 41));
    //sampleBoundsPoint.add(new Point(439, 90));
    //sampleBoundsPoint.add(new Point(439, 196));
    
    //HashSet<Line> sampleBounds = new HashSet();
    
    //sampleBounds = new HashSet<Line>();
    //for(int i = 0; i < sampleBoundsPoint.size() - 1; i++){
    //  sampleBounds.add(new Line(sampleBoundsPoint.get(i).x, sampleBoundsPoint.get(i).y, sampleBoundsPoint.get(i+1).x, sampleBoundsPoint.get(i+1).y));
    //}
    //sampleBounds.add(new Line(sampleBoundsPoint.get(sampleBoundsPoint.size() - 1).x, sampleBoundsPoint.get(sampleBoundsPoint.size() - 1).y, sampleBoundsPoint.get(0).x, sampleBoundsPoint.get(0).y)); 
    
    //pf.tileCover(sampleBounds);
    
    if(mode == Mode.SEARCHING){
      forward();
      
      //We search left right left right ... for a free path (avoid going back on its own track)
      if(mower.sensorOverlapping()){
        int i = -1;
        while(mower.sensorOverlapping()){
          i = i * i;
          mower.undoLastMove();
          mower.orientation += PI * i * 0.01;
          mower.forward();
        }
        
        //After going again, if i is positive the robot turned clockwise (right turn)
        //if i is negative the robot turned counterclockwise (left turn)
        
        if(!atObstacleEdge){
          atObstacleEdge = true;
          obstacleIsLeft = i > 0; // i > 0 => turned right => obstacle is on the left
          println("At obstacle edge ? " + atObstacleEdge + ", Obstacle on the left ? " + obstacleIsLeft);
          obstacles.add(new LinkedList<Point>());
        }
        
        lastObstacle = obstacles.get(obstacles.size() - 1);
        
        if(lastObstacle.size() == 0){
          lastObstacle.add(new Point(sensor.x, sensor.y));
        }else{
          Point lastPoint = lastObstacle.getLast();
          if(dist(lastPoint.x, lastPoint.y , sensor.x, sensor.y) > 5){
            lastObstacle.add(new Point(sensor.x, sensor.y));
            println(Arrays.toString(obstacles.toArray()));
          }
        }
      }
      
      if(atObstacleEdge && lastObstacle.size() > 1 && dist(lastObstacle.getFirst().x, lastObstacle.getFirst().y, sensor.x, sensor.y) < 5){
        //Back on our track, whole obstacle has been found
        println("Found !");
        lastObstacle.removeFirst();
        
        //We must now create a mowing path
        
        //Transform points to bound lines
        //bounds = new HashSet();
        Iterator<Point> it = lastObstacle.iterator();
        Point prev = it.next();
        Point first = prev;
        while(it.hasNext()){
          Point next = it.next();
          bounds.add(new Line(prev.x, prev.y, next.x, next.y));
          prev = next;
        }
        bounds.add(new Line(prev.x, prev.y, first.x, first.y));          
        
        mowingPath = pf.findPath(bounds, hb.x, hb.y);
        
        //Find closest point on path
        int closestPointIndex = 0;
        float closestDist = Float.MAX_VALUE;
        for(int i = 0; i < mowingPath.size(); i++){
          float distance = dist(x, y, mowingPath.get(i).x, mowingPath.get(i).y);
          if(distance < closestDist){
            closestDist = distance;
            closestPointIndex = i;
          }
        }
        
        nextPointIndex = closestPointIndex;
        mode = Mode.MOWING;
      }
    }else{ //mode == Mode.MOWING)
      Point nextPoint = mowingPath.get(nextPointIndex);
      if(dist(x, y, nextPoint.x, nextPoint.y) > 1){
        headTo(nextPoint);
      }else{
        nextPointIndex = (nextPointIndex + 1) % mowingPath.size();
      }
      
      forward();
    }
    
  }
  
  private void forward(int distance){
    x += cos(orientation)*distance;
    y += sin(orientation)*distance;
    sensor.x += cos(orientation)*distance;
    sensor.y += sin(orientation)*distance;
    
    if(frameCount % 10 == 0){
      lawn.mowedPoints.add(new Point(sensor.x, sensor.y));
    }
  }
  
  private void forward(){
    forward(1);
  }
  
  private void undoLastMove(int previousDistance){
    forward(-previousDistance);
  }
  
  private void undoLastMove(){
    forward(-1);
  }
  
  private void headTo(Point p){
    orientation = atan2(p.y - y, p.x - x);
  }
  
  public boolean sensorOverlapping(){
    //Note : this feedback would come directly from the sensor and wouldn't need any knowledge
    //On the real lawn boundaries
    
    for(Line l : lawn.bounds){
      if(pf.pointOnLine(l.x1, l.y1, l.x2, l.y2, sensor.x, sensor.y, 10)){
        return true;
      }
    }
    return false;
  }
  
  private Mode mode;
  
  private Homebase hb;
  
  private PathFinder pf;
  private ArrayList<Point> mowingPath;
  private int nextPointIndex;
  
  private float x;
  private float y;
  
  private float orientation; //radians
  private boolean atObstacleEdge;
  private boolean obstacleIsLeft;
  private ArrayList<LinkedList<Point>> obstacles;
  private LinkedList<Point> lastObstacle;
  
  private HashSet<Line> bounds;
  
  private Point sensor;
  
  private color col;
}
