globals
[
  trafic-light-cout ;; counter to switch trafic lights
  isGreen?          ;; true if is green light on the Trafic Light, alse false
  nowCrossing?      ;; truq if now crrosing
  nowCrossingBottom?
  nowCrossingTop?
]

patches-own[
  meaning        ;;the role of the patch
]

breed[cars car]
breed[houses house]
breed[trees tree]
breed[persons person]

cars-own[
  speed-limit
  speed 
  maxSpeed       ;;
]
persons-own[
  speed
  crossing-part  ;;it divides the crossing to parts
  waiting?       ;;is pedestrian waiting for crossing the road?
]

to setup
  clear-all
  draw-patches ; draw road patches and traffic lights
  place-cars
  place-people
  set nowCrossing? false 
  set nowCrossingTop? false
  set nowCrossingBottom? false
  set isGreen? one-of [true false]
  switch-trafic-lights
  reset-ticks
  
end


to go
  compute-crossings
  move-cars
  move-people
  trafic-light-coutner
  compute-crossings
  
end

to move-cars
  
  ; horni auta
  ask cars with [ycor > 0][
    
    ifelse isGreen?
    [
      ifelse not any? other cars-on patch-ahead 3 and (not nowCrossingTop? or xcor < 1.5)
       [fd speed-up / 200]
       [ ]
    ]
    [ 
        ifelse [meaning] of patch-ahead 3 = "crossing" or any? other cars-on patch-ahead 3
        [fd 0]
        [ 
          ifelse not any? other cars-on patch-ahead 3 or [meaning] of patch-here = "crossing"
          [fd speed-up / 200]
          [ ]          
          ]
      
    ]
  ]
  ; dolni
  ask cars with [ycor < 0][
    
    ifelse isGreen?
    [
      ifelse not any? other cars-on patch-ahead 3 and (not nowCrossingTop? or xcor > -1.5)
       [fd speed-up / 200]
       [ ]
    ]
    [ 
        ifelse [meaning] of patch-ahead 3 = "crossing" or any? other cars-on patch-ahead 3
        [fd 0]
        [ 
          ifelse not any? other cars-on patch-ahead 3 or [meaning] of patch-here = "crossing"
          [fd speed-up / 200]
          [ ]          
          ]
      
    ] 
  ]


  tick
end

to move-people
  ask persons [
    compute-crossings
    if crossing-part >= 1[
      cross-the-street
      stop
    ]
    
    if meaning = "waitpoint" or meaning = "waitpoint2"[
      set crossing-part 1
    ]
    
    face min-one-of patches with [meaning = "waitpoint" or meaning = "waitpoint2"] [distance myself]
   
     walk 
    
    ]
  
end
to compute-crossings

     set nowCrossing? false 
     set nowCrossingTop? false
     set nowCrossingBottom? false
  ask patch 0 0 [

   if any? persons in-radius 4 with [ycor >= 0]
   [
     set nowCrossing? true
     set nowCrossingTop? true
   ]
   if any? persons in-radius 4 with [ycor < 0]
   [
     set nowCrossing? true
     set nowCrossingBottom? true
   ]
  ]
end

to walk
 
    ifelse any? other persons-on patch-ahead 1[ 
      rt random 45
      lt random 45
    ]
    [ fd speed / 200]
  
end

to cross-the-street
  if crossing-part = 1[
    face min-one-of patches with [meaning = "waitpoint2" or meaning = "waitpoint"][abs([xcor] of myself - pxcor)]
    set crossing-part 2
  ]
  if crossing-part = 2 [

    if heading > 315 and heading < 45 [set heading 0 ]
    if heading > 45 and heading < 135 [set heading 90]
    if heading > 135 and heading < 225 [set heading 180]
    if heading > 225 and heading < 315 [set heading 270]

     if heading > 180 and heading < 360 [
       set heading one-of [180 0]
    ]
     if heading > 90 and heading < 180 [
       set heading one-of [180 90]
    ]
     
      if heading > 0 and heading < 90 [
       set heading one-of [0 90]
    ] 

  ]

  if meaning = "waitpoint2" and crossing-part = 2 [
    rt 180
    lt 180
    set crossing-part 3
  ] 

  if crossing-part = 3 and meaning = "waitpoint" [
    rt 180
    lt 180
    set crossing-part 0
  ]
  ifelse (meaning = "waitpoint" or meaning = "waitpoint2") and isGreen? [
    fd 0
    set waiting? true
  ]
  [    
    if not any? cars-on patch-ahead 1 [
      ifelse isGreen? [fd speed / 100][fd speed / 200]
      set waiting? false
    ]
   ]
  
end

;; increase speed of cars
to accelerate  ;; turtle procedure
  set speed (speed + (speed-up / 100))
end

;; reduce speed of cars
to decelerate  ;; turtle procedure
  set speed (speed - (slow-down / 100))
end

to place-cars

  loop [ ifelse count cars < num-of-cars
    [
  ;auta jedouci doleva
  ask n-of (num-of-cars / 2) patches with [pcolor = black and meaning = "leftRoad"] [
    if not any? cars-on patch pxcor (pycor + 1) and not any? cars-here
    and not any? patches with [meaning = "crossing" or meaning = "middle" or meaning = "sidewalk"] in-radius 2 [
      if not any? cars in-radius 2 and count cars < num-of-cars [
      sprout-cars 1 [
        set size 3
        set shape "car top"
        set heading 0
        let s random 10
        if s < 7 [set maxSpeed speed-limit - 15 + random 16]
        if s = 7 [set maxSpeed speed-limit - 20 + random 6]
        if s > 7 [set maxSpeed speed-limit + random 16]
        set speed maxSpeed - random 20
        left 90
        
      ]
    ]
    ]
  ]


  ; auta jedouci doprava
  ask n-of (num-of-cars / 2) patches with [pcolor = black and meaning = "rightRoad"] [
    if not any? cars-on patch pxcor (pycor + 1) and not any? cars-here
    and not any? patches with [meaning = "crossing" or meaning = "middle" or meaning = "sidewalk"] in-radius 2 [
      if not any? cars in-radius 2 and count cars < num-of-cars [
      sprout-cars 1 [
        set size 3
        set shape "car top"
        set heading 0
        let s random 10
        if s < 7 [set maxSpeed speed-limit - 15 + random 16]
        if s = 7 [set maxSpeed speed-limit - 20 + random 6]
        if s > 7 [set maxSpeed speed-limit + random 16]
        set speed maxSpeed - random 20
        right 90
        
         ]
      ]
     ]
    ]
   ]
   [stop]]
  
end

to place-people
  while [count persons <= num-of-people] [
    ask one-of patches with [meaning = "sidewalk"] [
      sprout-persons 1 [
        set speed random 7 + 5
        set size 1
        set waiting? false
        ;set walk-time random time-to-crossing
        set shape one-of ["person business" "person construction" "person doctor" 
          "person farmer" "person graduate" "person lumberjack" "person police" "person service" 
          "person soldier"
        ]
      ]
    ]
  ]
end

to set-red
  set isGreen? false
  ask patches with [meaning = "tlLeftRed" OR meaning = "tlRightRed"] [set pcolor red ]
  ask patches with [meaning = "tlLeftYellow" OR meaning = "tlRightYellow"] [set pcolor yellow - 4]
  ask patches with [meaning = "tlLeftGreen" OR meaning = "tlRightGreen"] [set pcolor green - 4]
end
to set-green
  set isGreen? true
  ask patches with [meaning = "tlLeftRed" OR meaning = "tlRightRed"] [set pcolor red - 4]
  ask patches with [meaning = "tlLeftYellow" OR meaning = "tlRightYellow"] [set pcolor yellow - 4]
  ask patches with [meaning = "tlLeftGreen" OR meaning = "tlRightGreen"] [set pcolor green]
end

to set-yellow
   ask patches with [meaning = "tlLeftRed" OR meaning = "tlRightRed"] [set pcolor red - 4]
   ask patches with [meaning = "tlLeftYellow" OR meaning = "tlRightYellow"] [set pcolor yellow]
   ask patches with [meaning = "tlLeftGreen" OR meaning = "tlRightGreen"] [set pcolor green - 4]
   ask cars [ set speed speed / 2 ]
end
to trafic-light-coutner
  set trafic-light-cout trafic-light-cout + 1
  if (trafic-light-cout mod ((light-switch-period - 5)) = 0)
  [ set-yellow ]
  
  if (trafic-light-cout mod light-switch-period = 0)
  [switch-trafic-lights]
  
end

to switch-trafic-lights
  ifelse isGreen?
  [set-red]
  [set-green]
  
end

to draw-patches
  ask patches [
  set pcolor ifelse-value (abs(pycor) > 5) [green] [black] ]
; chodniky  
  ask patches with [(abs(pycor) >= 5)AND (abs(pycor) <  8) OR ((abs(pxcor) <= 4) and pcolor != black)] [set pcolor grey set meaning "sidewalk"] 

  ; grass area
  ask patches with [abs(pycor) >= 8] [
    set meaning "grass"
    ]
  
; silnice a čáry
  ask patches with [pycor = 0 ] [set pcolor white set meaning "middle"]
  ask patches with [pycor = 0 AND ((pxcor + 3) mod 3 = 0)] [set pcolor black set meaning "road"]

  ask patches with [pycor > 1 AND pycor < 3 ]  [ set meaning "leftRoad" ]  
  ask patches with [pycor < -1 AND pycor > -3] [ set meaning "rightRoad" ]
  
; přechod
  ask patches with [abs(pxcor) <=  2 AND ((pycor = 0) OR (abs(pycor) = 2) OR (abs(pycor) = 4))] [set pcolor white set meaning "crossing"]
;cekaci misto
  ask patches with [pxcor = 0 AND pycor = 5 ] [set meaning "waitpoint"]
  ask patches with [pxcor = 0 AND pycor = -5 ] [set meaning "waitpoint2"]

  ; semafory
 ask patches with [pxcor = 4 AND (pycor = 5)] [
    set pcolor red
    set meaning "tlRightRed"
    ]
  ask patches with [pxcor = -4 AND (pycor = -5)] [
    set pcolor red
    set meaning "tlLeftRed"
    ]
  ask patches with [pxcor = 5 AND (pycor = 5)] [
    set pcolor yellow
    set meaning "tlRightYellow"
    ]
   ask patches with [pxcor = -5 AND (pycor = -5)] [
    set pcolor yellow
    set meaning "tlLeftYellow"
    ]
  ask patches with [pxcor = 6 AND pycor = 5] [
    set pcolor green - 2
    set meaning "tlRightGreen"
    ]
   ask patches with [pxcor = -6 AND (pycor = -5)] [
    set pcolor green - 2
    set meaning "tlLeftGreen"
    ]

  ;par domku
  ask patches with [pcolor = green] [
    if count neighbors with [pcolor = green] = 8 and not any? houses in-radius 4[
      sprout-houses 1 [
        set shape one-of ["house" "house bungalow" "house colonial"]
        set size 4
        stamp
      ]
    ]
  ]
  
  ;par stromu
  ask patches with [pcolor = green  AND not any? trees in-radius 2] [
    if count neighbors with [pcolor = green] = 8 and not any? turtles in-radius 2 [
      if random 100 > 90 [ 
        sprout-trees 1 [
          set shape one-of ["tree" "tree pine"]
          set size 4
          stamp
        ]
      ]
    ]
  ]
  
end 
@#$#@#$#@
GRAPHICS-WINDOW
217
10
1286
741
32
21
16.3
1
10
1
1
1
0
1
1
1
-32
32
-21
21
0
0
1
ticks
30.0

BUTTON
110
19
173
52
NIL
go
T
1
T
OBSERVER
NIL
R
NIL
NIL
1

BUTTON
29
18
92
51
NIL
setup
NIL
1
T
OBSERVER
NIL
S
NIL
NIL
1

SLIDER
25
75
197
108
num-of-cars
num-of-cars
1
20
15
1
1
NIL
HORIZONTAL

SLIDER
26
156
198
189
speed-up
speed-up
0
50
41
1
1
NIL
HORIZONTAL

SLIDER
27
198
199
231
slow-down
slow-down
0
50
0
1
1
NIL
HORIZONTAL

SLIDER
25
245
199
278
light-switch-period
light-switch-period
10
1000
300
1
1
NIL
HORIZONTAL

SLIDER
25
116
197
149
num-of-people
num-of-people
0
100
49
1
1
NIL
HORIZONTAL

MONITOR
6
353
111
398
NIL
nowCrossing?
17
1
11

PLOT
7
423
207
573
Waiting persons
NIL
NIL
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot count persons with [waiting?]"

MONITOR
6
301
112
346
NIL
nowCrossingBottom?
17
1
11

MONITOR
124
304
195
349
NIL
nowCrossingTop?
17
1
11

@#$#@#$#@
## WHAT IS IT?

(a general understanding of what the model is trying to show or explain)

## HOW IT WORKS

(what rules the agents use to create the overall behavior of the model)

## HOW TO USE IT

(how to use the model, including a description of each of the items in the Interface tab)

## THINGS TO NOTICE

(suggested things for the user to notice while running the model)

## THINGS TO TRY

(suggested things for the user to try to do (move sliders, switches, etc.) with the model)

## EXTENDING THE MODEL

(suggested things to add or change in the Code tab to make the model more complicated, detailed, accurate, etc.)

## NETLOGO FEATURES

(interesting or unusual features of NetLogo that the model uses, particularly in the Code tab; or where workarounds were needed for missing features)

## RELATED MODELS

(models in the NetLogo Models Library and elsewhere which are of related interest)

## CREDITS AND REFERENCES

(a reference to the model's URL on the web if it has one, as well as any other necessary credits, citations, and links)
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

bus
false
0
Polygon -1184463 true false 15 206 15 150 15 120 30 105 270 105 285 120 285 135 285 206 270 210 30 210
Rectangle -16777216 true false 36 126 231 159
Line -7500403 true 60 135 60 165
Line -7500403 true 60 120 60 165
Line -7500403 true 90 120 90 165
Line -7500403 true 120 120 120 165
Line -7500403 true 150 120 150 165
Line -7500403 true 180 120 180 165
Line -7500403 true 210 120 210 165
Line -7500403 true 240 135 240 165
Rectangle -16777216 true false 15 174 285 182
Circle -16777216 true false 48 187 42
Rectangle -16777216 true false 240 127 276 205
Circle -16777216 true false 195 187 42
Line -7500403 true 257 120 257 207

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

car top
true
0
Polygon -7500403 true true 151 8 119 10 98 25 86 48 82 225 90 270 105 289 150 294 195 291 210 270 219 225 214 47 201 24 181 11
Polygon -16777216 true false 210 195 195 210 195 135 210 105
Polygon -16777216 true false 105 255 120 270 180 270 195 255 195 225 105 225
Polygon -16777216 true false 90 195 105 210 105 135 90 105
Polygon -1 true false 205 29 180 30 181 11
Line -7500403 false 210 165 195 165
Line -7500403 false 90 165 105 165
Polygon -16777216 true false 121 135 180 134 204 97 182 89 153 85 120 89 98 97
Line -16777216 false 210 90 195 30
Line -16777216 false 90 90 105 30
Polygon -1 true false 95 29 120 30 119 11

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

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
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
false
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

house bungalow
false
0
Rectangle -7500403 true true 210 75 225 255
Rectangle -7500403 true true 90 135 210 255
Rectangle -16777216 true false 165 195 195 255
Line -16777216 false 210 135 210 255
Rectangle -16777216 true false 105 202 135 240
Polygon -7500403 true true 225 150 75 150 150 75
Line -16777216 false 75 150 225 150
Line -16777216 false 195 120 225 150
Polygon -16777216 false false 165 195 150 195 180 165 210 195
Rectangle -16777216 true false 135 105 165 135

house colonial
false
0
Rectangle -7500403 true true 270 75 285 255
Rectangle -7500403 true true 45 135 270 255
Rectangle -16777216 true false 124 195 187 256
Rectangle -16777216 true false 60 195 105 240
Rectangle -16777216 true false 60 150 105 180
Rectangle -16777216 true false 210 150 255 180
Line -16777216 false 270 135 270 255
Polygon -7500403 true true 30 135 285 135 240 90 75 90
Line -16777216 false 30 135 285 135
Line -16777216 false 255 105 285 135
Line -7500403 true 154 195 154 255
Rectangle -16777216 true false 210 195 255 240
Rectangle -16777216 true false 135 150 180 180

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

person business
false
0
Rectangle -1 true false 120 90 180 180
Polygon -13345367 true false 135 90 150 105 135 180 150 195 165 180 150 105 165 90
Polygon -7500403 true true 120 90 105 90 60 195 90 210 116 154 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 183 153 210 210 240 195 195 90 180 90 150 165
Circle -7500403 true true 110 5 80
Rectangle -7500403 true true 127 76 172 91
Line -16777216 false 172 90 161 94
Line -16777216 false 128 90 139 94
Polygon -13345367 true false 195 225 195 300 270 270 270 195
Rectangle -13791810 true false 180 225 195 300
Polygon -14835848 true false 180 226 195 226 270 196 255 196
Polygon -13345367 true false 209 202 209 216 244 202 243 188
Line -16777216 false 180 90 150 165
Line -16777216 false 120 90 150 165

person construction
false
0
Rectangle -7500403 true true 123 76 176 95
Polygon -1 true false 105 90 60 195 90 210 115 162 184 163 210 210 240 195 195 90
Polygon -13345367 true false 180 195 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285
Circle -7500403 true true 110 5 80
Line -16777216 false 148 143 150 196
Rectangle -16777216 true false 116 186 182 198
Circle -1 true false 152 143 9
Circle -1 true false 152 166 9
Rectangle -16777216 true false 179 164 183 186
Polygon -955883 true false 180 90 195 90 195 165 195 195 150 195 150 120 180 90
Polygon -955883 true false 120 90 105 90 105 165 105 195 150 195 150 120 120 90
Rectangle -16777216 true false 135 114 150 120
Rectangle -16777216 true false 135 144 150 150
Rectangle -16777216 true false 135 174 150 180
Polygon -955883 true false 105 42 111 16 128 2 149 0 178 6 190 18 192 28 220 29 216 34 201 39 167 35
Polygon -6459832 true false 54 253 54 238 219 73 227 78
Polygon -16777216 true false 15 285 15 255 30 225 45 225 75 255 75 270 45 285

person doctor
false
0
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Polygon -13345367 true false 135 90 150 105 135 135 150 150 165 135 150 105 165 90
Polygon -7500403 true true 105 90 60 195 90 210 135 105
Polygon -7500403 true true 195 90 240 195 210 210 165 105
Circle -7500403 true true 110 5 80
Rectangle -7500403 true true 127 79 172 94
Polygon -1 true false 105 90 60 195 90 210 114 156 120 195 90 270 210 270 180 195 186 155 210 210 240 195 195 90 165 90 150 150 135 90
Line -16777216 false 150 148 150 270
Line -16777216 false 196 90 151 149
Line -16777216 false 104 90 149 149
Circle -1 true false 180 0 30
Line -16777216 false 180 15 120 15
Line -16777216 false 150 195 165 195
Line -16777216 false 150 240 165 240
Line -16777216 false 150 150 165 150

person farmer
false
0
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Polygon -1 true false 60 195 90 210 114 154 120 195 180 195 187 157 210 210 240 195 195 90 165 90 150 105 150 150 135 90 105 90
Circle -7500403 true true 110 5 80
Rectangle -7500403 true true 127 79 172 94
Polygon -13345367 true false 120 90 120 180 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 180 90 172 89 165 135 135 135 127 90
Polygon -6459832 true false 116 4 113 21 71 33 71 40 109 48 117 34 144 27 180 26 188 36 224 23 222 14 178 16 167 0
Line -16777216 false 225 90 270 90
Line -16777216 false 225 15 225 90
Line -16777216 false 270 15 270 90
Line -16777216 false 247 15 247 90
Rectangle -6459832 true false 240 90 255 300

person graduate
false
0
Circle -16777216 false false 39 183 20
Polygon -1 true false 50 203 85 213 118 227 119 207 89 204 52 185
Circle -7500403 true true 110 5 80
Rectangle -7500403 true true 127 79 172 94
Polygon -8630108 true false 90 19 150 37 210 19 195 4 105 4
Polygon -8630108 true false 120 90 105 90 60 195 90 210 120 165 90 285 105 300 195 300 210 285 180 165 210 210 240 195 195 90
Polygon -1184463 true false 135 90 120 90 150 135 180 90 165 90 150 105
Line -2674135 false 195 90 150 135
Line -2674135 false 105 90 150 135
Polygon -1 true false 135 90 150 105 165 90
Circle -1 true false 104 205 20
Circle -1 true false 41 184 20
Circle -16777216 false false 106 206 18
Line -2674135 false 208 22 208 57

person lumberjack
false
0
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Polygon -2674135 true false 60 196 90 211 114 155 120 196 180 196 187 158 210 211 240 196 195 91 165 91 150 106 150 135 135 91 105 91
Circle -7500403 true true 110 5 80
Rectangle -7500403 true true 127 79 172 94
Polygon -6459832 true false 174 90 181 90 180 195 165 195
Polygon -13345367 true false 180 195 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285
Polygon -6459832 true false 126 90 119 90 120 195 135 195
Rectangle -6459832 true false 45 180 255 195
Polygon -16777216 true false 255 165 255 195 240 225 255 240 285 240 300 225 285 195 285 165
Line -16777216 false 135 165 165 165
Line -16777216 false 135 135 165 135
Line -16777216 false 90 135 120 135
Line -16777216 false 105 120 120 120
Line -16777216 false 180 120 195 120
Line -16777216 false 180 135 210 135
Line -16777216 false 90 150 105 165
Line -16777216 false 225 165 210 180
Line -16777216 false 75 165 90 180
Line -16777216 false 210 150 195 165
Line -16777216 false 180 105 210 180
Line -16777216 false 120 105 90 180
Line -16777216 false 150 135 150 165
Polygon -2674135 true false 100 30 104 44 189 24 185 10 173 10 166 1 138 -1 111 3 109 28

person police
false
0
Polygon -1 true false 124 91 150 165 178 91
Polygon -13345367 true false 134 91 149 106 134 181 149 196 164 181 149 106 164 91
Polygon -13345367 true false 180 195 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285
Polygon -13345367 true false 120 90 105 90 60 195 90 210 116 158 120 195 180 195 184 158 210 210 240 195 195 90 180 90 165 105 150 165 135 105 120 90
Rectangle -7500403 true true 123 76 176 92
Circle -7500403 true true 110 5 80
Polygon -13345367 true false 150 26 110 41 97 29 137 -1 158 6 185 0 201 6 196 23 204 34 180 33
Line -13345367 false 121 90 194 90
Line -16777216 false 148 143 150 196
Rectangle -16777216 true false 116 186 182 198
Rectangle -16777216 true false 109 183 124 227
Rectangle -16777216 true false 176 183 195 205
Circle -1 true false 152 143 9
Circle -1 true false 152 166 9
Polygon -1184463 true false 172 112 191 112 185 133 179 133
Polygon -1184463 true false 175 6 194 6 189 21 180 21
Line -1184463 false 149 24 197 24
Rectangle -16777216 true false 101 177 122 187
Rectangle -16777216 true false 179 164 183 186

person service
false
0
Polygon -7500403 true true 180 195 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285
Polygon -1 true false 120 90 105 90 60 195 90 210 120 150 120 195 180 195 180 150 210 210 240 195 195 90 180 90 165 105 150 165 135 105 120 90
Polygon -1 true false 123 90 149 141 177 90
Rectangle -7500403 true true 123 76 176 92
Circle -7500403 true true 110 5 80
Line -13345367 false 121 90 194 90
Line -16777216 false 148 143 150 196
Rectangle -16777216 true false 116 186 182 198
Circle -1 true false 152 143 9
Circle -1 true false 152 166 9
Rectangle -16777216 true false 179 164 183 186
Polygon -2674135 true false 180 90 195 90 183 160 180 195 150 195 150 135 180 90
Polygon -2674135 true false 120 90 105 90 114 161 120 195 150 195 150 135 120 90
Polygon -2674135 true false 155 91 128 77 128 101
Rectangle -16777216 true false 118 129 141 140
Polygon -2674135 true false 145 91 172 77 172 101

person soldier
false
0
Rectangle -7500403 true true 127 79 172 94
Polygon -10899396 true false 105 90 60 195 90 210 135 105
Polygon -10899396 true false 195 90 240 195 210 210 165 105
Circle -7500403 true true 110 5 80
Polygon -10899396 true false 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Polygon -6459832 true false 120 90 105 90 180 195 180 165
Line -6459832 false 109 105 139 105
Line -6459832 false 122 125 151 117
Line -6459832 false 137 143 159 134
Line -6459832 false 158 179 181 158
Line -6459832 false 146 160 169 146
Rectangle -6459832 true false 120 193 180 201
Polygon -6459832 true false 122 4 107 16 102 39 105 53 148 34 192 27 189 17 172 2 145 0
Polygon -16777216 true false 183 90 240 15 247 22 193 90
Rectangle -6459832 true false 114 187 128 208
Rectangle -6459832 true false 177 187 191 208

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

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

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

tree pine
false
0
Rectangle -6459832 true false 120 225 180 300
Polygon -7500403 true true 150 240 240 270 150 135 60 270
Polygon -7500403 true true 150 75 75 210 150 195 225 210
Polygon -7500403 true true 150 7 90 157 150 142 210 157 150 7

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

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270

@#$#@#$#@
NetLogo 5.0.3
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
<experiments>
  <experiment name="experiment" repetitions="1" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <exitCondition>ticks = 5000</exitCondition>
    <metric>count persons with [waiting?]</metric>
    <enumeratedValueSet variable="num-of-cars">
      <value value="15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="light-switch-period">
      <value value="50"/>
      <value value="100"/>
      <value value="200"/>
      <value value="300"/>
      <value value="400"/>
      <value value="500"/>
      <value value="600"/>
      <value value="700"/>
      <value value="800"/>
      <value value="900"/>
      <value value="1000"/>
      <value value="3000"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="speed-up">
      <value value="41"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-of-people">
      <value value="49"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="slow-down">
      <value value="0"/>
    </enumeratedValueSet>
  </experiment>
</experiments>
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
