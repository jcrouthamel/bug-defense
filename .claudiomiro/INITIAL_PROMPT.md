Can we create 10 new maps and use a waypoint system to keep the bugs on the path to the house?  Using a Waypoint System
For manual control or more dynamic behavior, define a series of points (waypoints) and program the enemy to move from one to the next. 
Store Waypoints: Use an array of CGPoint to store the path points.
Move to Next Point: In your game loop (e.g., in the update(_:) method), calculate the direction and move the enemy toward the current target waypoint.
Check Proximity: When the enemy is close enough to the current waypoint, switch the target to the next point in the array.
Loop/End: Determine if the path should loop back to the start or stop at the final waypoint. 