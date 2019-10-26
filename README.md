# Lawnbot : Virtual Robot Lawn Mower

### Motivation
Observing a robot lawn mower in a friend's garden, we asked ourselves how it possibly could work : Does it plan its route ? How does it find its way home ? …

I found those to be interesting questions and decided to build a virtual one, to try some of the ideas I had. (plus, how else could I have spent those 5ish days of my summer holidays ??)

### Setup
I imposed the following limitations :

* The robot does not know what the terrain looks like initially. It has to "discover" the boundaries by itself.
* The robot has a "sensor" which tells him whether it overlaps a boundary or not. This is pretty realistic – in reality, it is often necessary to burry some wire in the ground to allow the robot to detect the lawn boundaries.
* The robot knows its position. This is probably not realistic, but it allowed some more interesting route planing. It is not required to "randomly" mow the lawn though.
* A "homebase line" allows the robot to find its way home. This is how it is actually done in the real world, but superfluous if the robot knows its exact position (and the position of the homebase). I ended up not implementing that part, as it wasn't the most interesting part.

### What I learned

I was surprised to discover that randomly bouncing on the lawn boundaries was actually pretty efficient, as it covered the lawn in a reasonable amount of time. This wasn't very interesting though, so I decided to try to implement a cleverer solution. What I wanted to do was to find a simple path which covered the whole lawn, allowing "efficient" mowing of the grass. *Note : I didn't try to minimize the number of "turns", though one may want to with a real robot*

My approach works this way :

1. Detect the boundaries of the lawn.
	* The robot goes around the lawn and "maps" the lawn boundaries using its sensor.
	* Perfectible :
		* Currently only works for convex shaped lawns. 
2. Cover the lawn with tiles.
	* I used the [Ray casting algorithm](https://en.wikipedia.org/wiki/Point_in_polygon#Ray_casting_algorithm) but had trouble correctly handling corners / angles in the boundaries. This is what may fail when changing the lawn boundaries.
3. Transform the tile cover in a graph.
	* Each tile has a vertex in its center and is connected to adjacent tiles 
4. Double the "resolution" of the graph.
	* The idea is basically to have a graph which represents the "contour" of the first graph. This creates a cycle which covers the lawn.
5. Make the robot follow the cycle !

See demo.mov for an demo of the robot working. (/Screenshots show some of the underlying steps).

*Disclaimer : I made this in a few days during my summer holidays, mainly for fun. I know that some of the code I wrote is not the most efficient code ever !*