# Structure RTF json file
<div>
<img src="./RTF JSON documentation.png" alt="JSON Structure" width="100%" >
</div>

# Ray Pass Functions
## Ellipses
*Positions*: The off-axis distances on the input plane at which the ray pass function was determined
*Intersectionplanedistance*: The distance of the ellipses above the input plane.

For each position the ellipse is defined by its center (x,y) and its radii (x,y)
The ellipses are defined by the center 

<div>
<img src="./raypassellipse.png" alt="Ray pass function JSON ellipse" width="80%" >
</div>

## Circles
The circles are defined by a radius and a sensitivity parameter. See paper Appendix A for details

<div>
<img src="./raypasscircles.png" alt="JSON structure to define circle ray pass" width="40%" >
</div>
