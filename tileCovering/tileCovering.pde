import java.util.HashSet;

final int tileHeight = 40, tileWidth = 40, WIDTH = 600, HEIGHT = 400;
final int homebaseX = 60;
final int homebaseY = 200;

ArrayList<Point> sampleBoundsPoint;
HashSet<Line> sampleBounds;
GridGraph graph;

void setup(){
  size(500, 400);
  noLoop();
  
  graph = new GridGraph(WIDTH/tileWidth, HEIGHT/tileHeight);
  
  sampleBoundsPoint = new ArrayList();
  //sampleBoundsPoint.add(new Point(434, 200));
  sampleBoundsPoint.add(new Point(227, 41));
  sampleBoundsPoint.add(new Point(439, 90));
  sampleBoundsPoint.add(new Point(439, 196));
  sampleBoundsPoint.add(new Point(295, 339));
  sampleBoundsPoint.add(new Point(60, 339));
  sampleBoundsPoint.add(new Point(60, 68));
  
  
  sampleBounds = new HashSet();
  
  sampleBounds = new HashSet<Line>();
  for(int i = 0; i < sampleBoundsPoint.size() - 1; i++){
    sampleBounds.add(new Line(sampleBoundsPoint.get(i).x, sampleBoundsPoint.get(i).y, sampleBoundsPoint.get(i+1).x, sampleBoundsPoint.get(i+1).y));
  }
  sampleBounds.add(new Line(sampleBoundsPoint.get(sampleBoundsPoint.size() - 1).x, sampleBoundsPoint.get(sampleBoundsPoint.size() - 1).y, sampleBoundsPoint.get(0).x, sampleBoundsPoint.get(0).y));
  
  
}

void draw(){
  background(0, 51, 102);
  
  beginShape();
     stroke(255);
     strokeWeight(5);
     fill(155);
     for(Point p : sampleBoundsPoint){
       vertex(p.x, p.y);
     }
     vertex(sampleBoundsPoint.get(0).x, sampleBoundsPoint.get(0).y);
   endShape();
  
  for(int y = tileHeight / 2; y < HEIGHT; y += tileHeight){
      for(int x = tileWidth / 2; x < WIDTH; x += tileWidth){
        boolean onEdge = false;
        int intersections = 0;
        
        //Points which sit on an edge are kept
        for(Line l : sampleBounds){
          if(pointOnLine(l.x1, l.y1, l.x2, l.y2, x, y, 0.5)){
            onEdge = true;
            break;
          }
        }
        
        //For points not on the edge, we count the number of lines crossed going from the point
        //to the extreme right. If odd, the point is IN.
        if(!onEdge){
          HashSet<Line> modifiableBoundsCopy = (HashSet)sampleBounds.clone();
          for(int i = 0; i < WIDTH - x; i++){
            ArrayList<Line> toRemove = new ArrayList();
            for(Line l : modifiableBoundsCopy){
              //if(x == 30 && y == 70){
              //  println(new Point(x+i, y) + ", " + min_dist(l.x1, l.y1, l.x2, l.y2, x+i, y));
              //}
              
              if(pointOnLine(l.x1, l.y1, l.x2, l.y2, x+i, y, 2)){
                if(!isBoundPoint(l.x1, l.y1, l.x2, l.y2, x+i, y, 2)){
                  intersections++;
                  modifiableBoundsCopy.remove(l);
                  break;
                }else{
                  //We do not break, s. t. the other line crossing at the intersection is removed too
                  toRemove.add(l);
                }
              }
            }
            
            for(Line l : toRemove){
              modifiableBoundsCopy.remove(l);
            }
          }
        }
        
        if(onEdge || intersections % 2 == 1){
          
          //noFill();
          //strokeWeight(3);
          //rect(x - tileWidth/2, y - tileHeight/2, tileWidth, tileHeight);
          
          //Create a node for each tile
          graph.nodes[xCoordToIndex(x)][yCoordToIndex(y)] = new GridNode(x, y, xCoordToIndex(x), yCoordToIndex(y), null, null, null, null);
        }
        
      }
    }
    
    //Link nodes together
    for(int j = 0; j < graph.height; j++){
      for(int i = 0; i < graph.width; i++){
        if(graph.nodes[i][j] != null){
          graph.nodes[i][j].right = graph.getRightOf(i, j);
          graph.nodes[i][j].left = graph.getLeftOf(i, j);
          graph.nodes[i][j].up = graph.getUpOf(i, j);
          graph.nodes[i][j].down = graph.getDownOf(i, j);
        }
      }
    }
    
    GridGraph spanningTree = graph.spanningTree(xCoordToIndex(homebaseX), yCoordToIndex(homebaseY));
    
    //stroke(255, 0, 0);
    //fill(255, 0, 0);
    //spanningTree.draw(tileWidth, tileHeight);
    
    PathGridGraph pgg = new PathGridGraph(spanningTree, tileWidth, tileHeight);
    
    stroke(0, 255, 0);
    fill(0, 255, 0);
    pgg.draw(tileWidth/2, tileHeight/2);
}


class Line{
  public Line(float x1, float y1, float x2, float y2){
    this.x1 = x1;
    this.y1 = y1;
    this.x2 = x2;
    this.y2 = y2;
  }
  
  public float x1, y1, x2, y2;
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


public boolean pointOnLine(float vx, float vy, float wx, float wy, float px, float py, float epsilon){
  return min_dist(vx, vy, wx, wy, px, py) < epsilon;
}

private float min_dist(float vx, float vy, float wx, float wy, float px, float py){
  float l2 = dist(vx, vy, wx, wy);
  l2 = l2 * l2;
  
  if(l2 == 0.0) return dist(px, py, vx, vy);
  
  float pmvx = px - vx;
  float pmvy = py - vy;
  
  float wmvx = wx - vx;
  float wmvy = wy - vy;
  
  float t = max(0, min(1, (pmvx * wmvx + pmvy * wmvy)/l2));
  float projx = vx + t * wmvx;
  float projy = vy + t * wmvy;
  
  return abs(dist(px, py, projx, projy));
}

public boolean isBoundPoint(float x1, float y1, float x2, float y2, float x, float y, float epsilon){
  return (abs(x - x1) < epsilon && abs(y - y1) < epsilon) || (abs(x - x2) < epsilon && abs(y - y2) < epsilon);
}

void mouseClicked() {
  println(mouseX + ", " + mouseY);
}

private int xCoordToIndex(int x){
  return (x - tileWidth/2) / tileWidth;
}

private int yCoordToIndex(int y){
  return (y - tileHeight/2) / tileHeight;
}
