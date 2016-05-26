# jason
This is a bare bones evolutionary algorithm simulation I wrote with a friend over a 2 week choir tour a couple years ago. Since then, I've learned a great deal about machine learning and programming in general, and my interest and abilities have matured, but I want this online for posterity, and to contribute to my 'portfolio'. :) Please watch the [demo video](https://drive.google.com/file/d/0BwlfuOXPcIRnb0dwbFhJek8tNkE/view?usp=sharing) to see it in action!

## Tools and License
The simulation is written in Lua, and uses a matrix module written by Micheal Lutz and David Manura. It uses love2d as its 2d graphics engine. To run the simulation, clone or download the repo, and run 'love jason', where 'jason' is the repo directory. For more information, see their [website](https://love2d.org/ "love2d"). It is licensed under the MIT license that can be found in the LICENSE file of this repo.

## Summary
The simulation involves 'jasons' and 'soylent'. 'soylent' is, of course, the food and finite resource over which the 'jasons' are competing, and is naturally represented by vegemite; all credit to Kilen Multop for this cleverness. The behavior of jason is dictated by a simple neural network that takes in the x and y coordinates of the nearest soylent, and returns jasons velocity along the x and y axis. When a jason eats enough food, jason reproduces, and the babies have a slightly mutated version of their parents neural network. The jason spends food to move, and upon reaching 0, jason dies. After running the simulation for 10 or 15 minutes, the jasons go from mindlessly blundering into the the edges of the window, to vigorously chasing and consuming the soylent.

## Portfolio Considerations
If the reader is perusing this as a part of my 'portfolio', I want to bring attention to my clearly demonstrated curiousity! This project marked the beginning of my adventures in machine learning, and was entirely self-motivated. On a more technical note, I want to shine a light on the implementation of Lua 'classes'. Lua does not have proper classes, but its table datatype can be used, with some wizardry, to create them.

### Potential Improvements and Known Shortcomings
I also want to note that the current methods for collision detection and getting the nearest food item to a given jason are a rudimentary O(n^2). If I were to do this again, and the performance was poor enough to outweigh the cost of implementation, I would use fortunes algorithm to sweep across the x axis, updating a voronoi diagram with parabolic arcs on the beach line. I would then pull from an ordered list of jasons (by x value), until one was encountered past the sweep line. I would check each jason to see if it was to the left of the beach line. If it was, I would determine which voronoi cell it belonged to, and then get rid of it. Note that voronoi cells that are not part of the beach line would not be considered in the comparison, as any jasons that would claim that site as its nearest neighbour, would have done so when it was a part of the beach line. In other words, the 'circle event' that would close a voronoi cell would be the last time that cell was considered for the nearest neighbor. This would have a run time of O(s) in the best case, O(s\*j/k) in the average, and O(s\*j) in the worst, though this assumes merely iterating the voronoi cells to check if the jason belongs. We could get it down to O(s\*log(j)) in the worst-ish case by using something akin to quicksort to find jason's cell on the x and y axis.
