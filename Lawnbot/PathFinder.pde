import java.util.Set;

final int tileWidth = 40;
final int tileHeight = 40;

public class PathFinder{
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
  
  public ArrayList<Point> findPath(HashSet<Line> bounds, float homebaseX, float homebaseY){
    GridGraph graph = tileCover(bounds);
    
    //circle(homebaseX, homebaseY, 10);
    
    GridGraph spanningTree = graph.spanningTree(xCoordToIndex(homebaseX), yCoordToIndex(homebaseY));    
    
    //stroke(255, 0, 0);
    //fill(255, 0, 0);
    //spanningTree.draw(tileWidth, tileHeight);
    
    PathGridGraph pgg = new PathGridGraph(spanningTree, tileWidth, tileHeight);
    
    stroke(255, 0, 0);
    fill(255, 0, 0);
    pgg.draw(tileWidth/2, tileHeight/2);
    
    //for(int j = 0; j < pgg.height; j++){
    //  for(int i = 0; i < pgg.width; i++){
    //    println(pgg.get(i, j));
    //  }
    //}
    
    return pgg.pathFromGraph();
  }
  
  //Returns a GridGraph whith one node for each point sat the center of tiles lying inside the bounds
  public GridGraph tileCover(HashSet<Line> bounds){
    GridGraph graph = new GridGraph(WIDTH/tileWidth, HEIGHT/tileHeight); 
    for(int y = tileHeight / 2; y < HEIGHT; y += tileHeight){
      for(int x = tileWidth / 2; x < WIDTH; x += tileWidth){
        boolean onEdge = false;
        int intersections = 0;
        
        //Points which sit on an edge are kept
        for(Line l : bounds){
          if(pointOnLine(l.x1, l.y1, l.x2, l.y2, x, y, 0.5)){
            onEdge = true;
            break;
          }
        }
        
        //For points not on the edge, we count the number of lines crossed going from the point
        //to the extreme right. If odd, the point is IN.
        if(!onEdge){
          HashSet<Line> modifiableBoundsCopy = (HashSet)bounds.clone();
          for(int i = 0; i < WIDTH - x; i++){
            ArrayList<Line> toRemove = new ArrayList();
            for(Line l : modifiableBoundsCopy){
              //Must better handle comming to an angle...
              if(pointOnLine(l.x1, l.y1, l.x2, l.y2, x+i, y, 1.8)){
                if(!isBoundPoint(l.x1, l.y1, l.x2, l.y2, x+i, y, 2)){
                  intersections++;
                  modifiableBoundsCopy.remove(l);
                  break;
                }else{
                  //We do not break s. t. the other line crossing at the intersection is removed too
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
          //strokeWeight(2);
          //rect(x - tileWidth/2, y - tileHeight/2, tileWidth, tileHeight);
          
          //noLoop();
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
    
    return graph;
  }
  
  public boolean isBoundPoint(float x1, float y1, float x2, float y2, float x, float y, float epsilon){
    return (abs(x - x1) < epsilon && abs(y - y1) < epsilon) || (abs(x - x2) < epsilon && abs(y - y2) < epsilon);
  }
  
  private int xCoordToIndex(float x){
    return ((int)x - tileWidth/2) / tileWidth;
  }
  
  private int yCoordToIndex(float y){
    return ((int)y - tileHeight/2) / tileHeight;
  }
}
