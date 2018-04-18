; Vacuum Cleaner Robot model
;
; Simulates a vacuum cleaner robot that avoids obstacles but quickly covers all of the environment
; using simple reactive behaviour.
; 
; Modified by Bill Teahan (2009)

breed [robots robot] ; Name of the breed of vacuum cleaner robots

globals
[
  background-colour ; colour of the background except for obstacles
  obstacles-colour  ; colour of the obstacles
  robot-colour      ; colour of the robot
]

to setup
  clear-all
  set-default-shape robots "vacuum cleaner robot" ; sets shapes for each breed
  set background-colour yellow + 2 ; set colour of background light yellow
  set obstacles-colour brown ; set colour of obstacles brown
  set robot-colour gray ; set colour of robot

  ask patches
  [
    set pcolor background-colour ; set colour of background
    if (pxcor >= max-pxcor - boundary-width)
      [ set pcolor brown ]
    if (pxcor <= min-pxcor + boundary-width)
      [ set pcolor brown ]
    if (pycor >= max-pycor - boundary-width)
      [ set pcolor brown ]
    if (pycor <= min-pycor + boundary-width)
      [ set pcolor brown ]
  ]

  ; creates colour, size and random location of single robot 
  create-robots 1
  [
    set size robot-size
    set color robot-colour
    let this-patch one-of patches with [pcolor != obstacles-colour]  ; sets an initial random position within the outside boundary
    set xcor [pxcor] of this-patch
    set ycor [pycor] of this-patch
  ]
end   

to make-move
; This defines how the robot should move.

  if (behaviour = "Look Ahead")
    [ ; This behaviour is from the Look Ahead Example model in the Models Library
      let this-patch patch-ahead radius-length
      ifelse (this-patch != nobody) and ([pcolor] of this-patch = obstacles-colour)
        [ lt random-float 360 ]   ;; We see an obstacle patch in front of us. Turn a random amount.
        [ fd 1 ]                  ;; Otherwise, it is safe to move forward.
    ]
  if (behaviour = "Boid")
    [ ; This implements a boid-like behaviour using the in-cone command (like Craig Reynold's boids)
      rt random-float rate-of-random-turn 
      lt (rate-of-random-turn  / 2)
      ; randomly turns randomly as defined by the random-rate-of-turn variable in the interface
      ; with a tendency to turn to the right
      fd robot-speed  
      avoid-obstacles
    ]
end

to go
; The robot moves around.

  ask robots ; robot instructions
  [ make-move ]

  tick  
end

to make-obstacles
; Creates obstacles in the environment.

 if mouse-down?
 [ ask patches
   [ if ((abs (pxcor - mouse-xcor)) < 1) and ((abs (pycor - mouse-ycor)) < 1)
     [set pcolor obstacles-colour]]
 ]
end

to erase-obstacles
; Removes obtacles in the environment.

 if mouse-down?
 [ ask patches
   [ if ((abs (pxcor - mouse-xcor)) < 1) and ((abs (pycor - mouse-ycor)) < 1)
     [set pcolor background-colour]]
 ]
end
   
to avoid-obstacles
; The robot avoids any obstacles in the environment.

  if (count patches in-cone radius-length radius-angle with [pcolor = obstacles-colour] > 0)
  [ ; there is an obstacle nearby
    ask robot 0 
     [
       bk robot-speed
       lt 90
     ]
  ]
end

to plot-paths
; This instructs the agent to move the pen up if it is down, or vice versa.

  ifelse (pen-mode = "up")
    [ pen-down ]
    [ pen-up ]
end
  
;
; Copyright 2009 by Thomas Christy and William John Teahan.  All rights reserved.
;
; Permission to use, modify or redistribute this model is hereby granted,
; provided that both of the following requirements are followed:
; a) this copyright notice is included.
; b) this model will not be redistributed for profit without permission
;    from William John Teahan.
; Contact William John Teahan for appropriate licenses for redistribution for
; profit.
;
; To refer to this model in publications, please use:
;
; Vacuum Cleaner Robot NetLogo model.
; Artificial Intelligence. Teahan, W. J. (2010). Ventus Publishing Aps.
;
  
@#$#@#$#@
GRAPHICS-WINDOW
295
10
715
451
20
20
10.0
1
10
1
1
1
0
0
0
1
-20
20
-20
20
0
0
1
ticks

BUTTON
12
30
138
63
Setup
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL

BUTTON
138
30
264
63
Go
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL

SLIDER
145
218
270
251
robot-speed
robot-speed
0.1
5
0.2
.1
1
NIL
HORIZONTAL

TEXTBOX
150
254
286
297
Robot speed adjusts the step value of each boid per iteration
11
0.0
1

BUTTON
11
129
138
162
Follow Robot
follow robot 0
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL

BUTTON
11
63
138
96
Draw Obstacles
make-obstacles
T
1
T
OBSERVER
NIL
NIL
NIL
NIL

SLIDER
57
377
229
410
radius-angle
radius-angle
0
360
295
5
1
degrees
HORIZONTAL

SLIDER
57
413
229
446
radius-length
radius-length
0
20
1
1
1
length
HORIZONTAL

SLIDER
35
299
246
332
rate-of-random-turn
rate-of-random-turn
0
100
15
1
1
degrees
HORIZONTAL

BUTTON
11
96
138
129
Toggle Plot Paths
plot-paths
NIL
1
T
TURTLE
NIL
NIL
NIL
NIL

SLIDER
57
339
229
372
boundary-width
boundary-width
2
10
2
1
1
NIL
HORIZONTAL

BUTTON
138
96
264
129
Erase Paths
clear-drawing
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL

BUTTON
138
129
264
162
Stop Following Robot
reset-perspective
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL

SLIDER
16
218
141
251
robot-size
robot-size
2
10
6
1
1
NIL
HORIZONTAL

BUTTON
138
63
264
96
Erase Obstacles
erase-obstacles
T
1
T
OBSERVER
NIL
NIL
NIL
NIL

CHOOSER
69
168
207
213
behaviour
behaviour
"Look Ahead" "Boid"
1

@#$#@#$#@
WHAT IS IT?
-----------
This model simulates a vacuum cleaner robot whose task is to clean the floor of a room. The user can draw obstacles in the environment in order to better represent a real life environment. The model implements two basic reactive behaviours for the robot - one using a simple look ahead mechanism that reacts to any obstacles directly ahead; the other implements a boid (see Craig Reynold's work) that employs a basic obstacle avoidance steering behaviour.

This model is an extension of the Obstacle Avoidance 2 model, and part of the Information from that model has been duplicated here.

HOW IT WORKS
------------
The robot turtle agent simply wanders around randomly in the environment avoiding the obstacles. The look ahead behaviour is implemented using NetLogo's patch-ahead command to check to see if there are any obstacles directly ahead, and if there are, it will turn a random amount. The boid behaviour is implemented using NetLogo's in-cone command that implements a turtle with a cone of vision.

WHAT IS ITS PURPOSE?
--------------------
The purpose of the model is to show that you do not need to have a complicated method for covering the entire space of an environment. Simple reactive methods based on random walking with basic sensing will suffice.

INTERFACE
---------
The model's Interface buttons are defined as follows:

- Setup: This sets up the environment with an outside border. One turtle agent (the robot) is created and placed at a random location.

- Go: The robot starts wandering around the environment avoiding obstacles.

- Draw Obstacles: The user can draw further obstacles in the environment. These are coloured brown.

- Erase Obstacles: The user can erase obstacles in the environment, including the border.

- Toggle Plot Paths: This instructs the robot turtle agent when wandering to put its pen down if it is up, or put it up if it is already down. If the pen is down, this will show the paths the robot takes while wandering around.

- Erase Paths: This will erase any paths that have been drawn in the environment.

- Follow Robot: This allows the perspective of the visualisation to be altered so that it is centred on the robot.

- Stop Following Robot: This will reset the perspective of the visualisation so that it is directly above the origin of the environment looking straight down.

The model's Interface chooser and sliders are defined as follows:

- behaviour: This sets the behaviour of the robot. There are two values:
"Look Ahead": The robot will look directly ahead to see if there is an obstacle at distance defined by the radius-length slider and turn a random amount if there is.
"Boid": The robot uses a basic cone of vision sense as defined by the radius-angle and radius-length sliders to determine if there are any obstacles ahead, and turns a random amount as defined by the rate-of-random-turn slider, with a tendency to turn to the right.

- robot-size: This sets the size of the robot.

- robot-speed: This controls the speed of the boid i.e. how much it moves forward each tick.

- rate-of-random-turn: This controls how much the wandering robot boid turns each time tick. The robot has a tendency to head in a right turning direction as the rate of random turn to the right (as specified by the slider) is twice that of the rate of random turn to the left.

- boundary-width: This sets the width of the outside boundary at the beginning when the Setup button is pressed. The boundary is drawn with the same colour as the obstacles (brown), therefore the robot will avoid this area as well (usually, but sometimes it can become stuck as mentioned below).

- radius-angle: This defines the radius angle of the boid's vision cone.

- radius-length: This defines the radius length of the boid's vision cone if the behaviour is set to "Boid" or the amount the robot looks ahead if the behaviour is set to "Look Ahead".

HOW TO USE IT
-------------
Press the Setup button first, then press Go. To see where the boid wanders, press Toggle Plot Paths. These paths can be erased using the Erase Paths button.

You can draw extra obstacles by pressing the Draw Obstacles button and then holding down the mouse at the point where you want the obstacles to be drawn. These can also be erased using the Erase Obstacles if you have made a mistake. You can change the frame of reference so that the visualisation is centred around where the boid currently is situated by pressing the Follow Robot button. To reset the perspective, press the Stop Following Robot button.

THINGS TO NOTICE
----------------

Setting the behaviour to "Boid" and the robot-speed to 0.1, rate-of-random-turn to 40, radius-angle to 300, radius-length to 1, and pressing the Toggle Plot Paths button, followed by moving the speed slider (just below the Information tab in the Interface) from "normal speed" to "faster" will result in the robot boid rapidly covering the entire environment while reliably avoiding the obstacles.

Increasing the radius-length value (while keeping the other variables the same) will change how much of the space the robot covers. Instead of covering most of the environment, if the behaviour is set to "Boid", the robot will cover a space that is away from the obstacles as determined by the slider. (Note that the border is also considered an obstacle). If the behaviour is set to "Look Ahead", and the radius-length value is greater than 1, and the paths are being drawn, then this will result in gaps at the four corners of the environment if there are no obstacles inside the environment. (You will need to make the simulation go faster using the speed slider to see this more quickly). Note that if you set the radius-length slider to a higher value for the "Look Ahead" behaviour, it will often get stuck on the outside boundary depending on the width of the boundary. (Why is this?)

THINGS TO TRY
-------------
Try adjusting the robot's speed, radius angle and radius length to see how this affects the robot's behaviour. Also try changing the Interface Settings to see if this has any affect.

Try adding obstacles to see how this affects the robot's ability to cover the entire environment. For example, add obstacles in the form of a maze. Try to create "black spots" where the robot never visits. Alternatively, try to trap the robot into a small area, or try to get it stuck.

EXTENDING THE MODEL
-------------------
Try adding further behaviours to the model. Observe a real vacuum cleaner robot working, and try to recreate its behaviour in this model.

The model could be extended to add gradual acceleration and deceleration.  This would enhance the simulation of the robot.

NETLOGO FEATURES
----------------
The code uses the patch-ahead and in-cone commands to simulate the robot vision sense.

RELATED MODELS
--------------
See the following models: Obstacle Avoidance 1, Obstacle Avoidance 2.

CREDITS AND REFERENCES
----------------------
This model was created by William John Teahan. Part of the code was based on the Look Ahead Example model in NetLogo's Models Library.

To refer to this model in publications, please use:

Vacuum Cleaner Robot NetLogo model.
Teahan, W. J. (2010). Artificial Intelligence. Ventus Publishing Aps.

@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

directional circle
true
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Line -1 false 150 0 150 150

dot
false
0
Circle -7500403 true true 90 90 120

face happy
true
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
true
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

vacuum cleaner robot
true
0
Circle -1 true false 15 15 270
Circle -16777216 false false 15 15 270
Circle -7500403 true true 75 75 150
Circle -16777216 false false 75 75 150
Circle -7500403 true true 60 60 30
Circle -7500403 true true 135 30 30
Circle -7500403 true true 210 60 30
Circle -7500403 true true 240 135 30
Circle -7500403 true true 210 210 30
Circle -7500403 true true 135 240 30
Circle -7500403 true true 60 210 30
Circle -7500403 true true 30 135 30
Circle -16777216 false false 30 135 30
Circle -16777216 false false 60 210 30
Circle -16777216 false false 135 240 30
Circle -16777216 false false 210 210 30
Circle -16777216 false false 240 135 30
Circle -16777216 false false 210 60 30
Circle -16777216 false false 135 30 30
Circle -16777216 false false 60 60 30

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270

@#$#@#$#@
NetLogo 4.1
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180

@#$#@#$#@
0
@#$#@#$#@
