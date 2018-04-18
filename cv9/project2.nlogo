breed [ cameras camera ]

cameras-own [
  view-distance
  angle
  best-patch-xcor
  best-patch-ycor
  best-patch-cover
  best-heading
  budget
  is-placed
]

patches-own [
  for-sale
  price
  winner
  sold
]

globals [
  patches-for-sale
  patches-chosen
  mouse-clicked?
  first-turn
  patch-was-sold
  image-map
]

to setup
  clear-all
  set first-turn true
  set patch-was-sold false
  set image-map false
  setup-map
  setup-patches-for-sale
  setup-cameras
  calculate-best-spots
  place-to-best-patches
end

to setup-map
  if (map-selector = 1) [
    set-patch-size 6
    resize-world 0 84 -84 0
    ask patches [
      set pcolor green + random-float 2
      set for-sale false
      set sold false
      set winner 999
    ]
    ask patches with [ pxcor >= 48 and pxcor <= 72  and pycor >= -24 ] [
      set pcolor gray
    ]
    ask patches with [ pxcor <= 24 and pycor <= -24 and pycor >= -32 ] [
      set pcolor gray
    ]
    ask patches with [ pxcor >= 16 and pxcor <= 24 and pycor <= -32 ] [
      set pcolor gray
    ]
    ask patches with [ pxcor >= 16 and pycor <= -58 and pycor >= -64 ] [
      set pcolor gray
    ]
    output-print "------------------------------"
    output-print "Map generated succesfully."
  ]
  if (map-selector = 2) [
    set-patch-size 6
    resize-world 0 84 -84 0
    ask patches [
      set pcolor green + random-float 2
      set for-sale false
      set sold false
      set winner 999
    ]
    ask patches with [ pycor = 0 - pxcor ] [
      set pcolor gray
      ask neighbors [
        set pcolor gray
        ask neighbors [
          set pcolor gray
          ask neighbors [
            set pcolor gray
          ]
        ]
      ]
    ]
    ask patches with [ pxcor - pycor = 84 ] [
      set pcolor gray
      ask neighbors [
        set pcolor gray
        ask neighbors [
          set pcolor gray
          ask neighbors [
            set pcolor gray
          ]
        ]
      ]
    ]
    ask one-of patches with [ pxcor = 42 and pycor = -42 ] [
      ask patches in-radius 40 [
        set pcolor gray
      ]
      ask patches in-radius 30 [
        set pcolor green + random-float 2
      ]
    ]
    output-print "------------------------------"
    output-print "Map generated succesfully."
  ]
  if (map-selector = "hk" or map-selector = "jbc" or map-selector = "prg1" or map-selector = "prg3") [
    output-print "------------------------------"
    output-print "Creating map from image...please wait..."
    set image-map true
    if (map-selector = "hk") [
      set-patch-size (1 * (100 / resolution))
      resize-world 0 (800 / 100 * resolution) (-658 / 100 * resolution) 0
      import-pcolors "hk3.png"
    ]
    if (map-selector = "jbc") [
      set-patch-size (1 * (100 / resolution))
      resize-world 0 (658 / 100 * resolution) (-658 / 100 * resolution) 0
      import-pcolors "jbc3.png"
    ]
    if (map-selector = "prg1") [
      set-patch-size (1 * (100 / resolution))
      resize-world 0 (658 / 100 * resolution) (-658 / 100 * resolution) 0
      import-pcolors "prg1.png"
    ]
    if (map-selector = "prg3") [
      set-patch-size (1 * (100 / resolution))
      resize-world 0 (658 / 100 * resolution) (-658 / 100 * resolution) 0
      import-pcolors "prg3.png"
    ]
    ask patches with [ (pcolor >= 0 and pcolor < 5) or (pcolor mod 10 = 0) or ((pcolor - 0.1) mod 10 = 0) or ((pcolor - 0.2) mod 10 = 0) or ((pcolor - 0.3) mod 10 = 0) or ((pcolor - 0.4) mod 10 = 0) or ((pcolor - 0.5) mod 10 = 0) or ((pcolor - 0.6) mod 10 = 0) or ((pcolor - 0.7) mod 10 = 0) or ((pcolor - 0.8) mod 10 = 0) or ((pcolor - 0.9) mod 10 = 0)  or (pcolor >= 81 and pcolor <= 83) or (pcolor >= 91 and pcolor <= 94)] [
      set pcolor gray
    ]
    ask patches with [ (pcolor > 96.0 and pcolor < 99.8) ] [
      set pcolor 95.9
    ]
    ask patches with [ (pcolor < 10 and pcolor > 5) or ((pcolor + 0.1) mod 10 = 0) or ((pcolor + 0.2) mod 10 = 0) or ((pcolor + 0.3) mod 10 = 0) or ((pcolor + 0.4) mod 10 = 0) or ((pcolor + 0.5) mod 10 = 0) or ((pcolor + 0.6) mod 10 = 0) or ((pcolor + 0.7) mod 10 = 0) or ((pcolor + 0.8) mod 10 = 0) or ((pcolor + 0.9) mod 10 = 0) ] [
      set pcolor green + random-float 2
      set for-sale false
      set sold false
      set winner 999
    ]
  ]

end

to setup-patches-for-sale
  if (patches-to-sell = "next-to-roads") [
    let is-neighbor false
    ask patches with [ shade-of? green pcolor ] [
      ask neighbors [
        if (pcolor = gray) [
          set is-neighbor true
        ]
      ]
      if (is-neighbor) [
        set for-sale true
      ]
      set is-neighbor false
    ]
    ask patches with [ for-sale = true ] [
      set pcolor blue
      set price random (max-patch-price - min-patch-price) + min-patch-price
    ]
  ]
  if (patches-to-sell = "random") [
    let i 0
    while [ i < number-of-spots ] [
      ask one-of patches with [ pcolor != gray ] [
        if (shade-of? green pcolor) [
          set for-sale true
          set i i + 1
          if (debug) [ output-type "[" output-type pxcor output-type "," output-type pycor output-print "]." ]
        ]
      ]
    ]
    ask patches with [ for-sale = true ] [
      set pcolor blue
      set price random (max-patch-price - min-patch-price) + min-patch-price
    ]
  ]
  if (patches-to-sell = "choose") [
    let break-loop false
    set patches-chosen false
    output-print "------------------------------"
    output-print "Click on patches to mark them for sale."
    while [ (count patches with [ for-sale = true ] < number-of-spots )] [
      mouse-manager
    ]
  ]
  output-print "------------------------------"
  output-type "Marked " output-type (count patches with [ for-sale = true ]) output-print " patches for sale."
end

to setup-cameras
  output-print "------------------------------"
  create-cameras number-of-cameras [
    if (show-cameras = false) [ ht ]
    set shape "camera"
    set view-distance random (max-view-distance - min-view-distance) + min-view-distance
    set angle random (max-view-angle - min-view-angle) + min-view-angle
    set budget random (max-budget - min-budget) + min-budget
    set xcor random 26
    set ycor random -26
    set heading 0
    set size camera-size
    set best-patch-cover 0
    set is-placed false
    ask patches in-cone view-distance angle [
      ;    if (debug) [ set pcolor red ]
    ]
    output-type "Camera #" output-type who output-type " has view distance " output-type view-distance output-type ", view angle " output-type angle output-type "° and budget $" output-type budget output-print "."
  ]
end

to go
  if (first-turn) [
    output-print "Auction starts."
    output-print "------------------------------"
    set first-turn false
  ]
  if (auction-strategy = "buy-best-patch") [
    while [ count cameras with [ is-placed = false ] > 0 ] [
      ask patches with [ for-sale = true and sold = false] [
        auction-best-patch
        ;    check-winner
        if (patch-was-sold) [
          calculate-best-spots
          set patch-was-sold false
        ]
      ]
    ]
    ask cameras [
      set heading best-heading
      ask patches in-cone view-distance angle [
        if (pcolor = gray) [
          set pcolor red
        ]
      ]
    ]
    output-type "------------------------------" output-type "Acution is over" output-print "------------------------------"
    stop
  ]
  if (auction-strategy = "buy-anything") [

  ]
end

to auction-best-patch
  let current-price price
  let bid-incr (round (current-price / 10))
  let proposed-price (current-price + bid-incr)
  let test-pxcor pxcor
  let test-pycor pycor
  let patch-winner 999
  let patch-sold false
  output-type "Auctioning patch at [" output-type pxcor output-type "," output-type pycor output-type "]. Current price is $" output-type current-price output-type " and the bid increase is set to $" output-type bid-incr output-print "."
  if (count cameras with [ is-placed = false and test-pxcor = best-patch-xcor and test-pycor = best-patch-ycor and budget >= proposed-price ] = 1) [
    ask cameras with [ is-placed = false and test-pxcor = best-patch-xcor and test-pycor = best-patch-ycor and budget >= proposed-price ] [
      set patch-winner who
      set patch-sold true
    ]
    set winner patch-winner
    set sold patch-sold
    check-winner
  ]
  if (count cameras with [ is-placed = false and test-pxcor = best-patch-xcor and test-pycor = best-patch-ycor and budget >= proposed-price ] = 0) [
    output-type "No offers for patch at [" output-type pxcor output-type "," output-type pycor output-print "]."
  ]
  if (count cameras with [ is-placed = false and test-pxcor = best-patch-xcor and test-pycor = best-patch-ycor and budget >= proposed-price ] > 1) [
    while [ (count cameras with [ is-placed = false and test-pxcor = best-patch-xcor and test-pycor = best-patch-ycor and budget >= proposed-price ]) > 1 ] [
      if (debug) [ output-type "Cameras still interested in this patch: " output-print (count cameras with [ is-placed = false and test-pxcor = best-patch-xcor and test-pycor = best-patch-ycor and budget >= proposed-price ]) ]
      set proposed-price (current-price + bid-incr)
      ask cameras with [ is-placed = false and test-pxcor = best-patch-xcor and test-pycor = best-patch-ycor and budget >= proposed-price ] [
        let camera-id who
        set proposed-price (current-price + bid-incr)
        if (proposed-price <= budget and patch-winner != camera-id) [
          set price proposed-price
          set current-price price
          output-type "Patch at [" output-type test-pxcor output-type "," output-type test-pycor output-type "] - price increased to $" output-type price output-type " by Camera #" output-type camera-id output-print "."
          set patch-winner who
          set patch-sold true
        ]
      ]
    ]
    if (count cameras with [ is-placed = false and test-pxcor = best-patch-xcor and test-pycor = best-patch-ycor and budget >= proposed-price ] = 1) [
      ask cameras with [ is-placed = false and test-pxcor = best-patch-xcor and test-pycor = best-patch-ycor and budget >= proposed-price ] [
        set patch-winner who
        set patch-sold true
      ]
    ]
    set winner patch-winner
    set sold patch-sold
    check-winner
  ]
  if (debug) [ output-type "Winner: " output-type winner output-type " , Sold: " output-print sold ]
end

to check-winner
  if (debug) [ output-print "---------------- Check Winner. ----------------" ]
  if (sold) [
    set patch-was-sold true
    let patch-winner winner
    output-print "------------------------------"
    output-type "Patch at [" output-type pxcor output-type "," output-type pycor output-type "] sold at price $" output-type price output-type " to Camera #" output-type winner output-print "."
    output-print "------------------------------"
    ask one-of cameras with [ who = patch-winner ] [
      set is-placed true
      set best-patch-xcor 0
      set best-patch-ycor 0
    ]
  ]
end

to bid [player-id]
  ;  set current-price current-price + bid-incr
  ;  set current-winner player-id
  ;  output-type "Player #" output-type player-id output-type " bids $" output-type current-price output-print "."
end

to calculate-best-spots
  if (debug or first-turn or image-map) [
    if (first-turn) [ output-print "------------------------------" ]
    output-print "Calculating best positions for cameras.......please wait." if (image-map) [ output-print "This may take some time....please wait...still working..." output-print "------------------------------" ]
  ]
  let test-xcor 0
  let test-ycor 0
  let test-heading 0
  ask patches with [ for-sale = true and sold = false ] [
    if (image-map) [ output-print "Still working..." ]
    set test-xcor pxcor
    set test-ycor pycor
    ask cameras with [ is-placed = false ] [
      if (debug) [ output-type test-xcor output-type ", " output-type test-ycor output-type ", " output-type xcor output-type ", " output-type ycor output-print "" ]
      set best-patch-cover -1
      let i 0
      while [i <= 360] [
        set heading i
        set xcor test-xcor
        set ycor test-ycor
        set test-heading heading
        ask patches in-cone view-distance angle [
          if (shade-of? pcolor gray) [
            set pcolor red
          ]
        ]
        let patch-cover (count patches with [ pcolor = red ])
        if (patch-cover > best-patch-cover) [
          set best-patch-cover patch-cover
          set best-patch-xcor test-xcor
          set best-patch-ycor test-ycor
          set best-heading test-heading
        ]
        ask patches with [ pcolor = red ] [
          set pcolor gray
        ]
        set i i + 10
      ]
    ]
  ]
end

to place-to-best-patches
  output-print "------------------------------"
  ask cameras [
    set xcor best-patch-xcor
    set ycor best-patch-ycor
    set label best-patch-cover
    set heading best-heading
    output-type "Best patch for camera #" output-type who output-type " is patch at [" output-type best-patch-xcor output-type "," output-type best-patch-ycor output-type "] using heading " output-type best-heading output-type " with cover of " output-type best-patch-cover output-print " patches."
    ask patches in-cone view-distance angle [
      if (pcolor = gray) [
        set pcolor red
      ]
    ]
  ]
  output-print "------------------------------"
  output-print "--> Press 'Auction' button to start. <--"
  output-print "------------------------------"
end

to set-defaults
  set number-of-spots (ceiling (number-of-cameras * 1.5))
  ifelse (map-selector = 1 or map-selector = 2) [
    set camera-size 4
  ] [
    set camera-size (ceiling ((12 * resolution) / 100))
  ]
end

to handle-click
  let mouse-xcor2 (round mouse-xcor)
  let mouse-ycor2 (round mouse-ycor)
  ask one-of patches with [ pxcor = mouse-xcor2 and pycor = mouse-ycor2 ] [
    ifelse (shade-of? green pcolor) [
      set for-sale true
      set pcolor blue
      set price random (max-patch-price - min-patch-price) + min-patch-price
    ] [
      if (pcolor = blue) [
        set pcolor green + random-float 2
      ]
    ]
  ]
end

to mouse-manager
  ifelse mouse-down? [
    if not mouse-clicked? [
      set mouse-clicked? true
      handle-click
    ]
  ] [
    set mouse-clicked? false
  ]
end
@#$#@#$#@
GRAPHICS-WINDOW
210
10
807
608
-1
-1
1.0
1
10
1
1
1
0
0
0
1
0
588
-588
0
0
0
1
ticks
30.0

BUTTON
36
28
176
61
Setup + Calculation
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
22
120
194
153
number-of-cameras
number-of-cameras
1
10
3.0
1
1
NIL
HORIZONTAL

SWITCH
15
766
118
799
debug
debug
1
1
-1000

CHOOSER
23
201
194
246
map-selector
map-selector
1 2 "hk" "jbc" "prg1" "prg3"
1

CHOOSER
25
259
195
304
patches-to-sell
patches-to-sell
"next-to-roads" "random" "choose"
2

BUTTON
1451
159
1557
192
Patches done
set patches-chosen true
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

OUTPUT
1030
10
1643
686
11

SLIDER
25
316
197
349
number-of-spots
number-of-spots
0
100
5.0
1
1
NIL
HORIZONTAL

SLIDER
624
714
796
747
min-view-distance
min-view-distance
0
50
23.0
1
1
NIL
HORIZONTAL

SLIDER
623
754
795
787
max-view-distance
max-view-distance
10
50
45.0
1
1
NIL
HORIZONTAL

SLIDER
805
714
977
747
min-view-angle
min-view-angle
0
360
30.0
10
1
NIL
HORIZONTAL

SLIDER
805
754
977
787
max-view-angle
max-view-angle
10
360
270.0
10
1
NIL
HORIZONTAL

SLIDER
444
714
616
747
min-budget
min-budget
100
10000
1000.0
100
1
NIL
HORIZONTAL

SLIDER
443
755
615
788
max-budget
max-budget
100
10000
5000.0
100
1
NIL
HORIZONTAL

CHOOSER
23
364
197
409
auction-strategy
auction-strategy
"buy-best-patch"
0

SLIDER
266
714
438
747
min-patch-price
min-patch-price
100
10000
200.0
100
1
NIL
HORIZONTAL

SLIDER
265
755
437
788
max-patch-price
max-patch-price
100
10000
500.0
100
1
NIL
HORIZONTAL

SWITCH
15
727
150
760
show-cameras
show-cameras
0
1
-1000

BUTTON
66
73
139
106
Auction
go
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
21
559
193
592
resolution
resolution
0
100
100.0
10
1
NIL
HORIZONTAL

SLIDER
20
161
192
194
camera-size
camera-size
0
20
12.0
1
1
NIL
HORIZONTAL

TEXTBOX
25
529
175
557
Only when map from image is chosen:
11
0.0
1

BUTTON
62
624
140
657
Defaults
set-defaults
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

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

camera
true
0
Polygon -7500403 true true 75 270 225 270 225 120 75 120
Polygon -7500403 true true 135 120 75 45 225 45 165 120

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
NetLogo 6.0.2
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
