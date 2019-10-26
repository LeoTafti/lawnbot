import java.util.NoSuchElementException;
import java.util.Queue;

import java.util.LinkedList;

public class GridGraph{
  public GridGraph(int width, int height){
    this.width = width;
    this.height = height;
    nodes = new GridNode[width][height];
  }
  
  public boolean has(int i, int j){
    return isValidIndex(i, j) && nodes[i][j] != null;
  }
  
  public boolean hasRightOf(int i, int j){
    return isValidIndex(i+1, j) && nodes[i+1][j] != null;
  }
  public boolean hasLeftOf(int i, int j){
    return isValidIndex(i-1, j) && nodes[i-1][j] != null;
  }
  public boolean hasUpOf(int i, int j){
    return isValidIndex(i, j-1) && nodes[i][j-1] != null;
  }
  public boolean hasDownOf(int i, int j){
    return isValidIndex(i, j+1) && nodes[i][j+1] != null;
  }
  
  public GridNode get(int i, int j){
    if(isValidIndex(i, j)) return nodes[i][j];
    else throw new IndexOutOfBoundsException();
  }
  
  public GridNode getRightOf(int i, int j){
    if(isValidIndex(i+1, j)) return nodes[i+1][j];
    else throw new IndexOutOfBoundsException();
  }
  public GridNode getLeftOf(int i, int j){
    if(isValidIndex(i-1, j)) return nodes[i-1][j];
    else throw new IndexOutOfBoundsException();
  }
  public GridNode getUpOf(int i, int j){
    if(isValidIndex(i, j-1)) return nodes[i][j-1];
    else throw new IndexOutOfBoundsException();
  }
  public GridNode getDownOf(int i, int j){
    if(isValidIndex(i, j+1)) return nodes[i][j+1];
    else throw new IndexOutOfBoundsException();
  }
  
  protected boolean isValidIndex(int i, int j){
    return i >= 0 && i < this.width && j >= 0 && j < this.height;
  }
  
  public GridGraph spanningTree(int sourceI, int sourceJ){
    if(!has(sourceI, sourceJ)) throw new NoSuchElementException();
    
    HashSet<GridEdge> taken = new HashSet();
    Queue<GridEdge> inReach = new LinkedList();
    
    GridNode sourceNode = get(sourceI, sourceJ);
    addEdges(sourceNode, inReach);
    
    while(!inReach.isEmpty()){
      GridEdge nextEdgeTaken = inReach.remove();
      
      stroke(0, 255, 0);
      strokeWeight(2);
      //nextEdgeTaken.draw();
      
      taken.add(nextEdgeTaken);
      nextEdgeTaken.n2.taken = true;
      addEdges(nextEdgeTaken.n2, inReach);
    }
    
    //Create a graph with same nodes and edges according to taken (copy)
    GridGraph spanningTree = new GridGraph(graph.width, graph.height);
    for(int j = 0; j < this.height; j++){
      for(int i = 0; i < this.width; i++){
        if(graph.has(i, j)){
          GridNode node = graph.get(i, j);
          spanningTree.nodes[i][j] = new GridNode(node.x, node.y, i, j, null, null, null, null);
        }
      }
    }
    
    for(GridEdge edge : taken){
      switch(edge.dir){
        case RIGHT:
          spanningTree.nodes[edge.n1.i][edge.n1.j].right = spanningTree.nodes[edge.n2.i][edge.n2.j];
          spanningTree.nodes[edge.n2.i][edge.n2.j].left = spanningTree.nodes[edge.n1.i][edge.n1.j];
          break;
        case DOWN:
          spanningTree.nodes[edge.n1.i][edge.n1.j].down = spanningTree.nodes[edge.n2.i][edge.n2.j];
          spanningTree.nodes[edge.n2.i][edge.n2.j].up = spanningTree.nodes[edge.n1.i][edge.n1.j];
          break;
        case LEFT:
          spanningTree.nodes[edge.n1.i][edge.n1.j].left = spanningTree.nodes[edge.n2.i][edge.n2.j];
          spanningTree.nodes[edge.n2.i][edge.n2.j].right = spanningTree.nodes[edge.n1.i][edge.n1.j];
          break;
        case UP:
          spanningTree.nodes[edge.n1.i][edge.n1.j].up = spanningTree.nodes[edge.n2.i][edge.n2.j];
          spanningTree.nodes[edge.n2.i][edge.n2.j].down = spanningTree.nodes[edge.n1.i][edge.n1.j];
          break;
      }
    }
    return spanningTree;
  }
  
  private void addEdges(GridNode ofNode, Queue<GridEdge> inReach){
    if(ofNode.left != null && !ofNode.left.taken && !ofNode.left.enqueued){
      inReach.add(new GridEdge(ofNode, ofNode.left, Direction.LEFT));
      ofNode.left.enqueued = true;
    }
    if(ofNode.up != null && !ofNode.up.taken && !ofNode.up.enqueued){
      inReach.add(new GridEdge(ofNode, ofNode.up, Direction.UP));
      ofNode.up.enqueued = true;
    }
    if(ofNode.right != null && !ofNode.right.taken && !ofNode.right.enqueued){
      inReach.add(new GridEdge(ofNode, ofNode.right, Direction.RIGHT));
      ofNode.right.enqueued = true;
    }
    if(ofNode.down != null && !ofNode.down.taken && !ofNode.down.enqueued){
      inReach.add(new GridEdge(ofNode, ofNode.down, Direction.DOWN));
      ofNode.down.enqueued = true;
    }
  }
  
  public void draw(int tileWidth, int tileHeight){
    for(int j = 0; j < this.height; j++){
      for(int i = 0; i < this.width; i++){
        if(nodes[i][j] != null){
          nodes[i][j].draw(tileWidth, tileHeight);
        }
      }
    }
  }
  
  protected int width, height;
  protected GridNode[][] nodes;
}

class GridNode{
  
  public GridNode(int x, int y, int i, int j, GridNode up, GridNode down, GridNode left, GridNode right){
    this.x = x;
    this.y = y;
    
    this.i = i;
    this.j = j;
    
    this.up = up;
    this.down = down;
    this.left = left;
    this.right = right;
    
    this.taken = false;
    this.enqueued = false;
  }
  
  public String toString(){
    return "Coords : (" + x + ", " + y + ")";
  }
  
  public void draw(int tileWidth, int tileHeight){
    circle(x, y, 6);
    
    if(right != null) line(x, y, x+tileWidth, y);
    if(left != null) line(x, y, x-tileWidth, y);
    if(up != null) line(x, y, x, y-tileHeight);
    if(down != null) line(x, y, x, y+tileHeight);
  }
  
  private GridNode up, down, left, right;
  private int x, y;
  private int i, j;
  private boolean taken;
  private boolean enqueued;
}

private enum Direction{
    RIGHT, DOWN, LEFT, UP
}

class GridEdge{
  public GridEdge(GridNode n1, GridNode n2, Direction dir){
    this.n1 = n1;
    this.n2 = n2;
    this.dir = dir;
  }
  
  public void draw(){
    line(n1.x, n1.y, n2.x, n2.y);
  }
  
  private GridNode n1, n2;
  private Direction dir;
}

public class PathGridGraph extends GridGraph{
  public PathGridGraph(GridGraph spanningTree, int tileWidth, int tileHeight){
    super(spanningTree.width*2, spanningTree.height*2);
    
    //Create a 4 GridNodes for each GridNode in the given GridGraph
    // and connect them appropriately to create a path
    for(int j = 0; j < spanningTree.height; j++){
      for(int i = 0; i < spanningTree.width; i++){
        if(spanningTree.has(i, j)){
          //Create the 4 nodes
          GridNode center = spanningTree.get(i, j);
          int quarterWidth = tileWidth/4;
          int quarterHeight = tileHeight/4;
          
          //Top left
          nodes[2*i][2*j] = new GridNode(center.x - quarterWidth, center.y - quarterHeight, 2*i, 2*j, null, null, null, null);;
          
          //Top right
          nodes[2*i+1][2*j] = new GridNode(center.x + quarterWidth, center.y - quarterHeight, 2*i+1, 2*j, null, null, null, null);
          
          //Bottom left
          nodes[2*i][2*j+1] = new GridNode(center.x - quarterWidth, center.y + quarterHeight, 2*i, 2*j+1, null, null, null, null);
          
          //Bottom right
          nodes[2*i+1][2*j+1] = new GridNode(center.x + quarterWidth, center.y + quarterHeight, 2*i+1, 2*j+1, null, null, null, null);
        }
      }
    }
    
    for(int j = 0; j < spanningTree.height; j++){
      for(int i = 0; i < spanningTree.width; i++){
        if(spanningTree.has(i, j)){
          GridNode center = spanningTree.get(i, j);
          
          GridNode topLeft = nodes[2*i][2*j];
          GridNode topRight = nodes[2*i+1][2*j];
          GridNode bottomLeft = nodes[2*i][2*j+1];
          GridNode bottomRight = nodes[2*i+1][2*j+1];
          
          //RIGHT
          if(center.right != null){
            topRight.right = getRightOf(topRight.i, topRight.j);
            getRightOf(topRight.i, topRight.j).left = topRight;
            
            bottomRight.right = getRightOf(bottomRight.i, bottomRight.j);
            getRightOf(bottomRight.i, bottomRight.j).left = bottomRight;
          }else{
            topRight.down = bottomRight;
            bottomRight.up = topRight;
          }
          
          //LEFT
          if(center.left != null){
            topLeft.left = getLeftOf(topLeft.i, topLeft.j);
            getLeftOf(topLeft.i, topLeft.j).right = topLeft.left;
            
            bottomLeft.left = getLeftOf(bottomLeft.i, bottomLeft.j);
            getLeftOf(bottomLeft.i, bottomLeft.j).right = bottomLeft.left;
          }else{
            topLeft.down = bottomLeft;
            bottomLeft.up = topLeft;
          }
          
          //UP
          if(center.up != null){
            topLeft.up = getUpOf(topLeft.i, topLeft.j);
            getUpOf(topLeft.i, topLeft.j).down = topLeft;
            
            topRight.up = getUpOf(topRight.i, topRight.j);
            getUpOf(topRight.i, topRight.j).down = topRight;
          }else{
            topLeft.right = topRight;
            topRight.left = topLeft;
          }
          
          //DOWN
          if(center.down != null){
            bottomLeft.down = getDownOf(bottomLeft.i, bottomLeft.j);
            getDownOf(bottomLeft.i, bottomLeft.j).up = bottomLeft;
            
            bottomRight.down = getDownOf(bottomRight.i, bottomRight.j);
            getDownOf(bottomRight.i, bottomRight.j).up = bottomRight;
          }else{
            bottomLeft.right = bottomRight;
            bottomRight.left = bottomLeft;
          }
        }
      }
    }
    
  }
  
  public void draw(int tileWidth, int tileHeight){
    super.draw(tileWidth, tileHeight);
  }
}
