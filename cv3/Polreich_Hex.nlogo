extensions [ nw ]
breed [ cells cell ]
undirected-link-breed [ connectionsBlue connectionBlue ]
undirected-link-breed [ connectionsRed connectionRed ]
undirected-link-breed [ connectionsGray connectionGray ]

globals [
  done?
  mouse-was-down?
  stop-sim?
  connectionLeft
  connectionRight
  connectionTop
  connectionBottom
  nextComputerCell
  lastCells
  winner-color
  mouse-clicked?
  free-cells
]

cells-own [
  hex-neighbors
]

links-own [
  link-max-ycor
  link-min-ycor
  weight
]

to setup-nw

end

to setup
  clear-all
  set done? false
  set stop-sim? false
  set lastCells nobody
  setup-nw
  setup-grid
  reset-ticks
end

to setup-grid
  set-default-shape cells "hexRot"
  set-default-shape connectionsBlue "triple"
  set-default-shape connectionsRed "triple"
  set-default-shape connectionsGray "none"
  if (debug) [
    set-default-shape connectionsGray "dots"
  ]
  ask patches
    [ sprout-cells 1
        [ set color gray - 3
          set heading 0
          if pxcor mod 2 = 0
            [ set ycor ycor - 0.5 ] ] ]
  ask cells
    [ ifelse pxcor mod 2 = 0
        [ set hex-neighbors cells-on patches at-points [[0 1] [1 0] [1 -1] [0 -1] [-1 -1] [-1 0]] ]
        [ set hex-neighbors cells-on patches at-points [[0 1] [1 1] [1  0] [0 -1] [-1  0] [-1 1]] ] ]

  let c min-pxcor
  while [ c <= max-pxcor ] [
    let tt max-pycor - (c - min-pxcor) * 0.5
    ask cells with [ pxcor = c and pycor > tt ] [
      die
    ]
    let bt (max-pxcor - c - min-pxcor) * 0.5
    ask cells with [ pxcor = c and pycor <= bt ] [
      die
    ]
    set c c + 1
  ]
  ask cells [
    if (debug) [
      set label who
    ]
    create-connectionsGray-with hex-neighbors with [ color = (gray - 3) ] [ set weight 1 ]
  ]
  set free-cells (count cells with [ color = gray - 3 or color = blue - 3 or color = red - 3 ])
end

to go
  tick
  set free-cells (count cells with [ color = gray - 3 or color = blue - 3 or color = red - 3 ])
  if (first-player = "blue") [
    ifelse (human) [
      mouse-manager
      if (stop-sim?) [ stop ]
      if (done?) [ playRed ]
      if (stop-sim?) [ stop ]
    ] [
      playBlue
      if (stop-sim?) [ stop ]
      playRed
      if (stop-sim?) [ stop ]
    ]
  ]
  if (first-player = "red") [
    ifelse (human) [
      if (count cells with [color = red] = 0) [
        set done? true
      ]
      if (done?) [ playRed ]
      set done? false
      if (stop-sim?) [ stop ]
      mouse-manager
      if (stop-sim?) [ stop ]
    ] [
      playRed
      if (stop-sim?) [ stop ]
      playBlue
      if (stop-sim?) [ stop ]
    ]
  ]

end

to set-connectionsGray [ player-color ]
  if (debug) [
    print "Gray connections reset"
  ]
  ask connectionsGray [ die ]
  ask cells with [ color = (gray - 3) or shade-of? color player-color and not (color = player-color) ] [
    create-connectionsGray-with hex-neighbors with [ color = (gray - 3) or shade-of? color blue or shade-of? color red and not (color = red or color = blue) ] [
      set weight 1
    ]
  ]
  ask cells with [ color = player-color ] [
    create-connectionsGray-with hex-neighbors with [ color = (gray - 3) or shade-of? color blue or shade-of? color red and not (color = red or color = blue)] [
      set weight 0.5
      set color green
    ]
    create-connectionsGray-with hex-neighbors with [ color = player-color ] [
      set weight 0.05
      set color player-color
    ]
  ]
  ask connectionsGray [
    if (debug) [ set label weight ]
  ]
end

to playRed
  set-connectionsGray red
  ask cells with [ (color = red - 3) or (color = blue - 3) ] [
    set color gray - 3
  ]
  set connectionLeft 0
  set connectionRight 0
  set connectionTop 0
  set connectionBottom 0
  if (redStrategy = "random") [
    ask one-of cells with [ color = gray - 3 ] [
      color-cell-at xcor ycor red
      check-winner red
    ]
  ]
  if (redStrategy = "shortest") [
     ifelse (count cells with [ color = red ] = 0) [
      ask one-of cells with [ color = gray - 3 ] [
        color-cell-at xcor ycor red
      ]
    ] [
      find-shortest-path red
      ask nextComputerCell [
        color-cell-at xcor ycor red
      ]
    ]
  ]
  if (redStrategy = "blocking") [
    ifelse (count cells with [ color = blue ] = 0) [
      ask one-of cells with [ color = gray - 3 ] [
        color-cell-at xcor ycor red
      ]
    ] [
      block-opponent red
    ]
  ]
  set done? false
end


to playBlue
  set-connectionsGray blue
  ask cells with [ (color = blue - 3) or (color = red - 3) ] [
    set color gray - 3
  ]
  set connectionLeft 0
  set connectionRight 0
  set connectionTop 0
  set connectionBottom 0
  if (blueStrategy = "random") [
    ask one-of cells with [ color = gray - 3 ] [
      color-cell-at xcor ycor blue
      check-winner blue
    ]
  ]
  if (blueStrategy = "shortest") [
     ifelse (count cells with [ color = blue ] = 0) [
      ask one-of cells with [ color = gray - 3 ] [
        color-cell-at xcor ycor blue
      ]
    ] [
      find-shortest-path blue
      ask nextComputerCell [
        color-cell-at xcor ycor blue
      ]
    ]
  ]
  if (blueStrategy = "blocking") [
    ifelse (count cells with [ color = red ] = 0) [
      ask one-of cells with [ color = gray - 3 ] [
        color-cell-at xcor ycor blue
      ]
    ] [
      block-opponent blue
    ]
  ]
  set done? false
end

to find-shortest-path [player-color]
  let shortestPathTop 0
  let shortestDistanceTop 999
  let shortestPathBottom 0
  let shortestDistanceBottom 999
  let shortestPathLeft 0
  let shortestDistanceLeft 999
  let shortestPathRight 0
  let shortestDistanceRight 999
  let shortestPathVertical 0
  let shortestPathHorizontal 0
  if (debug) [
    print "--------------------------------"
    ask lastCells [
      type "Last Cell ID: " print who
    ]
  ]
  if (player-color = blue or both-ways = true) [
    ask cells with [ shade-of? color red or shade-of? color blue and not (color = red or color = blue)] [
      set color gray - 3
    ]
    let topCells cells with [ (color = (gray - 3) or shade-of? color red or shade-of? color blue) and (ycor + (xcor / 2) = 18.5) ]
    let bottomCells cells with [ (color = (gray - 3) or shade-of? color red or shade-of? color blue) and (ycor + (xcor / 2) = 6.5) ]
    set-context-gray player-color
    ask topCells [
      let pathTop nw:turtles-on-weighted-path-to one-of lastCells with [ color = player-color ] weight
      if (pathTop != false) [
        set pathTop turtle-set pathTop
        let distanceTop count pathTop
        ask pathTop [
          if (color = player-color) [
            set distanceTop distanceTop - 1
          ]
        ]
        if (distanceTop < shortestDistanceTop) [
          set shortestDistanceTop distanceTop
          set shortestPathTop pathTop
        ]
      ]
    ]
    ifelse (shortestPathTop = 0) [
      set shortestDistanceTop 999
    ] [
      ask shortestPathTop [
        if (color != player-color) [
          set color player-color - 3
        ]
      ]
    ]
    ask bottomCells [
      let pathBottom nw:turtles-on-weighted-path-to one-of lastCells with [ color = player-color ] weight
      if (pathBottom != false) [
        set pathBottom turtle-set pathBottom
        let distanceBottom count pathBottom
        ask pathBottom [

          if (color = player-color) [
            set distanceBottom distanceBottom - 1
          ]
        ]
        if (distanceBottom < shortestDistanceBottom) [
          set shortestDistanceBottom distanceBottom
          set shortestPathBottom pathBottom
        ]
      ]
    ]
    ifelse (shortestPathBottom = 0) [
      set shortestDistanceBottom 999
    ] [
      ask shortestPathBottom [
        if (color != player-color) [
          set color player-color - 3
        ]
      ]
    ]
  ]
  if (player-color = red or both-ways = true) [
    ask cells with [ shade-of? color red or shade-of? color blue and not (color = red or color = blue)] [
      set color gray - 3
    ]
    let leftCells cells with [ (color = (gray - 3) or shade-of? color red or shade-of? color blue) and xcor = 0 ]
    let rightCells cells with [ (color = (gray - 3) or shade-of? color red or shade-of? color blue) and xcor = 12 ]
    set-context-gray player-color
    ask leftCells [
      let pathLeft nw:turtles-on-weighted-path-to one-of lastCells with [ color = player-color ] weight
      if (pathLeft != false) [
        set pathLeft turtle-set pathLeft
        let distanceLeft count pathLeft
        ask pathLeft [
          if (color = player-color) [
            set distanceLeft distanceLeft - 1
          ]
        ]
        if (distanceLeft < shortestDistanceLeft) [
          set shortestDistanceLeft distanceLeft
          set shortestPathLeft pathLeft
        ]
      ]
    ]
    ifelse (shortestPathLeft = 0) [
      set shortestDistanceLeft 999
    ] [
      ask shortestPathLeft [
        if (color != player-color) [
          set color player-color - 3
        ]
      ]
    ]
    ask rightCells [
      let pathRight nw:turtles-on-weighted-path-to one-of lastCells with [ color = player-color ] weight
      if (pathRight != false) [
        set pathRight turtle-set pathRight
        let distanceRight count pathRight
        ask pathRight [
          if (color = player-color) [
            set distanceRight distanceRight - 1
          ]
        ]
        if (distanceRight < shortestDistanceRight) [
          set shortestDistanceRight distanceRight
          set shortestPathRight pathRight
        ]
      ]
    ]
    ifelse (shortestPathRight = 0) [
      set shortestDistanceRight 999
    ] [
      ask shortestPathRight [
        if (color != player-color) [
          set color player-color - 3
        ]
      ]
    ]
  ]
  if (both-ways = true) [
    if (debug) [
      set winner-color "red"
      if (player-color = blue) [
        set winner-color "blue"
      ]
      show winner-color
      type "Left: " print shortestDistanceLeft
      type "Right: " print shortestDistanceRight
      type "Top: " print shortestDistanceTop
      type "Bottom: " print shortestDistanceBottom
    ]
    let shortestDistanceHorizontal (shortestDistanceLeft + shortestDistanceRight)
    let shortestDistanceVertical (shortestDistanceTop + shortestDistanceBottom)
    if (debug) [
      type "Horizontal: " print shortestDistanceHorizontal
      type "Vertical: " print shortestDistanceVertical
    ]
    ifelse ((shortestDistanceHorizontal = 999 and (shortestDistanceVertical = 999 or shortestDistanceVertical = 1998)) or (shortestDistanceHorizontal = 1998 and (shortestDistanceVertical = 999 or shortestDistanceVertical = 1998))) [
      set nextComputerCell one-of cells with [ color = (gray - 3) or shade-of? color red or shade-of? color blue and not (color = red or color = blue) ]
    ] [
      if (shortestDistanceHorizontal = shortestDistanceVertical) [
        if (priorityWay = "horizontal") [
          set shortestDistanceHorizontal shortestDistanceHorizontal - 1
        ]
        if (priorityWay = "vertical") [
          set shortestDistanceHorizontal shortestDistanceHorizontal + 1
        ]
        if (priorityWay = "random") [
          set shortestDistanceHorizontal shortestDistanceHorizontal + one-of [ -1 1 ]
        ]
      ]
      if (shortestDistanceHorizontal < shortestDistanceVertical) [
        if ((count shortestPathLeft > 0) and (count shortestPathRight > 0)) [
          set shortestPathHorizontal (turtle-set shortestPathLeft shortestPathRight)
          if (debug) [
            print "Choosing Horizontal"
            ask shortestPathHorizontal [
              type who type " "
            ]
            print ""
          ]
          set nextComputerCell one-of shortestPathHorizontal with [ color = (gray - 3) or shade-of? color red or shade-of? color blue and not (color = red or color = blue) ]
          if (debug) [ type "Next Computer Cell: " type nextComputerCell print "" ]
        ]
      ]
      if (shortestDistanceHorizontal > shortestDistanceVertical) [
        if ((count shortestPathTop > 0) and (count shortestPathBottom > 0)) [
          set shortestPathVertical (turtle-set shortestPathTop shortestPathBottom)
          if (debug) [
            print "Choosing Vertical"
            ask shortestPathVertical [
              type who type " "
            ]
            print ""
          ]
          set nextComputerCell one-of shortestPathVertical with [ color = (gray - 3) or shade-of? color red or shade-of? color blue and not (color = red or color = blue) ]
          if (debug) [ type "Next Computer Cell: " type nextComputerCell print "" ]
        ]
      ]
    ]
  ]
  if (both-ways = false) [
    if (player-color = blue) [
      if (debug) [
        set winner-color "blue"
        show winner-color
        type "Top: " print shortestDistanceTop
        type "Bottom: " print shortestDistanceBottom
      ]
      let shortestDistanceVertical (shortestDistanceTop + shortestDistanceBottom)
      if (debug) [
        type "Vertical: " print shortestDistanceVertical
      ]
      ifelse (shortestDistanceVertical >= 999) [
        set nextComputerCell one-of cells with [ color = (gray - 3) or shade-of? color red or shade-of? color blue and not (color = red or color = blue) ]
      ] [
        set shortestPathVertical (turtle-set shortestPathTop shortestPathBottom)
        set nextComputerCell one-of shortestPathVertical with [ color = (gray - 3) or shade-of? color red or shade-of? color blue and not (color = red or color = blue) ]
        if (debug) [ type "Next Computer Cell: " type nextComputerCell print "" ]
      ]
    ]
    if (player-color = red) [
      if (debug) [
        set winner-color "red"
        show winner-color
        type "Left: " print shortestDistanceLeft
        type "Right: " print shortestDistanceRight
      ]
      let shortestDistanceHorizontal (shortestDistanceLeft + shortestDistanceRight)
      if (debug) [
        type "Horizontal: " print shortestDistanceHorizontal
      ]
      ifelse (shortestDistanceHorizontal >= 999) [
        set nextComputerCell one-of cells with [ color = (gray - 3) or shade-of? color red or shade-of? color blue and not (color = red or color = blue) ]
      ] [
        set shortestPathHorizontal (turtle-set shortestPathLeft shortestPathRight)
        set nextComputerCell one-of shortestPathHorizontal with [ color = (gray - 3) or shade-of? color red or shade-of? color blue and not (color = red or color = blue) ]
        if (debug) [ type "Next Computer Cell: " type nextComputerCell print "" ]
      ]
    ]
  ]
end

to block-opponent [ player-color ]
  let opponent-color red
  let opponent-neighbors 0
  if (player-color = red) [
    set opponent-color blue
  ]
  if (debug) [ print "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX" type "Opponent color set to: " print opponent-color ]
  set-connectionsGray opponent-color
  find-shortest-path opponent-color
  set-connectionsGray player-color
  if (debug) [ type "Next Computer Cell: " print nextComputerCell print "XXXXXXXXXXXXXXXXXXXXXXXXXXXXX" ]
  ifelse (nextComputerCell != nobody) [
    ask nextComputerCell [
      color-cell-at xcor ycor player-color
    ]
  ] [
    ifelse (count cells with [ color = gray - 3 ] != 0) [
      ask one-of cells with [ color = gray - 3 ] [
        color-cell-at xcor ycor player-color
      ]
    ] [
      check-winner player-color
      check-winner opponent-color
    ]
  ]
  check-winner player-color
  check-winner opponent-color
end

to color-cell-at [cellX cellY player-color]
  ask cells with [ color = red - 3 or color = blue - 3 ] [
    set color gray - 3
  ]
  set-connectionsGray player-color
  let coloredCells count cells with [ color = player-color ]
  if (lastCells != nobody) [
    set lastCells (turtle-set lastCells with [ color != player-color ])
  ]
  if (debug) [ if (lastCells != nobody) [ ask lastCells [ type "LastCells: " type who print "" ] ] ]
  ask one-of cells with [ xcor = cellX and ycor = cellY ] [
    if ( color != red and color != blue ) [
      set color player-color
      let lastCellId who
      let lastComputerCell one-of cells with [ who = lastCellId ]
      set lastCells (turtle-set lastCells lastComputerCell)
      if (player-color = red) [
        nw:set-context (cells with [ color = red ]) connectionsRed
        create-connectionsRed-with hex-neighbors with [ color = red ]
        ask connectionsRed [
          set color red
        ]
      ]
      if (player-color = blue) [
        nw:set-context (cells with [ color = blue ]) connectionsBlue
        create-connectionsBlue-with hex-neighbors with [ color = blue ]
        ask connectionsBlue [
          set color blue
        ]
      ]
      if (debug) [ type "Cell at " type cellX type ", " type cellY print " colored." ]
      if (human) [
        if (coloredCells < (count cells with [ color = player-color ])) [ set done? true ]
      ]
    ]
  ]
  check-winner player-color
end

to set-context-gray [player-color]
  if (player-color = red) [
    nw:set-context (cells with [ color = (gray - 3) or shade-of? color red or shade-of? color blue and not (color = blue)]) connectionsGray
  ]
  if (player-color = blue) [
    nw:set-context (cells with [ color = (gray - 3) or shade-of? color red or shade-of? color blue and not (color = red)]) connectionsGray
  ]
end

to set-context-color [player-color]
  if (player-color = red) [
    nw:set-context (cells with [ color = red ]) connectionsRed
  ]
  if (player-color = blue) [
    nw:set-context (cells with [ color = blue ]) connectionsBlue
  ]
end

to check-winner [player-color]
  show count cells with [ color = gray - 3 ]
  set-connectionsGray player-color
  let leftCells cells with [ color = player-color and xcor = 0 ]
  let rightCells cells with [ color = player-color and xcor = 12 ]
  let topCells cells with [ color = player-color and (ycor + (xcor / 2) = 18.5) ]
  let bottomCells cells with [ color = player-color and (ycor + (xcor / 2) = 6.5) ]
  let leftPath 0
  let rightPath 0
  let topPath 0
  let bottomPath 0
  set winner-color "red"
  if (player-color = blue) [
    set winner-color "blue"
  ]
  if (count cells with [ color = player-color ] > 11) [
    if (debug) [
      show winner-color
      show "CHECK WINNER"
    ]
    if (player-color = red or both-ways = true) [
      if (count rightCells > 0 and count leftCells > 0) [
        ifelse (count lastCells with [ color = player-color ] > 0) [
          ask rightCells [
            set-context-color player-color
            set connectionRight nw:path-to one-of lastCells with [ color = player-color ]
            set-context-gray player-color
            set rightPath nw:turtles-on-weighted-path-to one-of lastCells with [ color = player-color ] weight
          ]
          if (debug) [
            show winner-color
            show connectionRight
          ]
          ask leftCells [
            set-context-color player-color
            set connectionLeft nw:path-to one-of lastCells with [ color = player-color ]
            set-context-gray player-color
            set leftPath nw:turtles-on-weighted-path-to one-of lastCells with [ color = player-color ] weight
            if (debug) [
              show winner-color
              show connectionLeft
            ]
          ]
        ] [
          if (debug) [ type "Condition: count lastCells with [ color = player-color ] > 0" print " failed." ]
          set stop-sim? true
        ]
        if (connectionRight != false and connectionLeft != false) [
          type "XXXXXXXXXXXXXXXXXXXXX Winner is " type winner-color print " player XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
          if ((leftPath != 0 and rightPath != 0) and ((length leftPath) > 0 and (length rightPath) > 0)) [
            let winning-path (turtle-set leftPath rightPath)
            ask winning-path [
              set color player-color + 1
            ]
          ]
          set stop-sim? true
        ]
      ]
    ]
    if (player-color = blue or both-ways = true) [
      if (count bottomCells > 0 and count topCells > 0) [
        ifelse (count lastCells with [ color = player-color ] > 0) [
          ask bottomCells [
            set-context-color player-color
            set connectionBottom nw:path-to one-of lastCells with [ color = player-color ]
            set-context-gray player-color
            set bottomPath nw:turtles-on-weighted-path-to one-of lastCells with [ color = player-color ] weight
            if (debug) [
              show winner-color
              show connectionBottom
            ]
          ]
          ask topCells [
            set-context-color player-color
            set connectionTop nw:path-to one-of lastCells with [ color = player-color ]
            set-context-gray player-color
            set topPath nw:turtles-on-weighted-path-to one-of lastCells with [ color = player-color ] weight
            if (debug) [
              show winner-color
              show connectionTop
            ]
          ]
        ] [
          if (debug) [ type "Condition: count lastCells with [ color = player-color ] > 0" print " failed." ]
          set stop-sim? true
        ]
        if (connectionBottom != false and connectionTop != false) [
          type "XXXXXXXXXXXXXXXXXXXXX Winner is " type winner-color print " player XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
          if ((topPath != 0 and bottomPath != 0) and ((length topPath) > 0 and (length bottomPath) > 0)) [
            let winning-path (turtle-set topPath bottomPath)
            ask winning-path [
              set color player-color + 1
            ]
          ]
          set stop-sim? true
        ]
      ]
    ]
  ]
end

to handle-click
  let mouse-ycor2 mouse-ycor
  if (round mouse-xcor mod 2 = 0) [
    set mouse-ycor2 mouse-ycor2 + 0.5
  ]
  let clickedPatch one-of [ cells-at 0 0 ] of patch mouse-xcor mouse-ycor2
  if (clickedPatch != nobody)[
    ask  clickedPatch [
      let selected-cells cells-here
      if (count selected-cells > 0) [
        ask one-of selected-cells [
          color-cell-at xcor ycor blue
        ]
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
139
11
537
620
-1
-1
30.0
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
12
0
19
0
0
1
ticks
30.0

BUTTON
30
35
108
68
♻ Setup ♻
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

BUTTON
28
523
111
556
Go 1 turn
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

BUTTON
30
93
109
126
★ GO ★
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
19
568
123
601
Skip turn (human)
set done? true
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

CHOOSER
558
13
696
58
redStrategy
redStrategy
"random" "shortest" "blocking"
2

SWITCH
557
283
660
316
debug
debug
1
1
-1000

CHOOSER
558
135
696
180
first-player
first-player
"red" "blue"
0

CHOOSER
559
76
697
121
blueStrategy
blueStrategy
"random" "shortest" "blocking"
1

SWITCH
558
332
661
365
human
human
1
1
-1000

CHOOSER
977
71
1115
116
priorityWay
priorityWay
"random" "horizontal" "vertical"
0

TEXTBOX
677
286
827
312
On - turns on debug mode\nOff - turns off debug mode
10
0.0
1

TEXTBOX
679
336
872
392
On - blue player is controlled by human\nOff - both players are controlled by PC
10
0.0
1

TEXTBOX
709
22
925
74
random - choose random empty cell every turn\nshortest - choose shortest path every turn
10
0.0
1

TEXTBOX
706
81
928
133
random - choose random empty cell every turn\nshortest - choose shortest path every turn
10
0.0
1

TEXTBOX
711
146
861
172
blue - blue player starts\nred - red player starts
10
0.0
1

TEXTBOX
1134
69
1415
147
In case of the same length of vertical and horizontal path:\nrandom - choose random one of them\nhorizontal - choose horizontal\nvertical - choose vertical
10
0.0
1

SWITCH
977
27
1115
60
both-ways
both-ways
1
1
-1000

TEXTBOX
1134
26
1382
78
on - both can connect either ways\noff - blue has to connect vertically, red horizontally
10
0.0
1

MONITOR
12
461
122
506
Free cells
free-cells
0
1
11

TEXTBOX
3
13
153
31
______________________
11
0.0
1

TEXTBOX
3
24
18
136
█\n█\n█\n█\n█\n█\n█\n█
11
0.0
1

TEXTBOX
128
24
143
136
█\n█\n█\n█\n█\n█\n█\n█
11
0.0
1

TEXTBOX
3
68
171
105
______________________
11
0.0
1

TEXTBOX
4
123
154
141
______________________
11
0.0
1

TEXTBOX
550
562
716
618
See the \"Info\" tab for more information about the interface, configuration and strategies
11
0.0
1

@#$#@#$#@
# Hex game

## WHAT IS IT?

Simple game of Hex.

## HOW IT WORKS

Every player chooses one cell to color and they switch turns. First player to connect two sides of the board wins.
_The winner is shown in the output of the **Command Center**_

## HOW TO USE IT

1) Set configuration
2) Press Setup
3) Press GO

- If the human player is enabled, you can choose cells to color by simply clicking on it.

## STRATEGIES

### random
Randomly chooses empty cell every turn and color it. It's very dummy and simple algorithm which looses against all other strategies.

### shortest
- Every turn, calculates the shortest path to victory and colors one of the cells in the path. 

- This algorithm uses weighted links where link between the cells with the same color is 0.05, between colored cell and empty cell the weight is 0.5 and between empty cells the weight is 1. 

- This settings causes that the algorithm priorities the cells which are already colored.

- The reason why the "cheapest" link is 0.05 and not exact 0 is, to be able to find the shortest path if more paths are available. If the link weight would be 0, all paths weight would be also 0 and the algorithm wouldn't be able to find out which is the shortest.
_(**See image** where there are two winning paths, but only the shortest is highlighted)_

![Multiple paths](http://polreich.cz/uhk/TH/Netlogo/multiple-paths.png)

### blocking
- This algoritm uses the previous one to calculate the oponnents shortest path and then colors one of his cells. This behaviour causes that this strategy will win in approximetly **98% battles** against shortest "strategy".

- Based on an personal research, this algorithm was able to defeat about **85% human** in the first try and **50% people** gave up trying after several lost games.

- The best way to defeat this strategy is to have two options for last winning move. If you only have one option to enclose the path, this algorithm will always win. 
_(**See image** - green cells are two options to finish the path)_

![How to win](http://polreich.cz/uhk/TH/Netlogo/how-to-win.png)

## INTERFACE

_There you can see explanation of all interface parts. There's also brief summary of the function next to all switches and buttons._

### blueStrategy and redStrategy choosers
You can choose strategies for both Red and Blue cells with "redStrategy" and "blueStrategy" choosers.

### human switch
You can turn on human player with "human" switch. **Human player is always blue.**

### both-ways switch
If you set "both-ways" switch to on, you can connect both vertically and horizontally. If turned off, blue players connects **vertically** and red player **horizontally**.

### first-player chooser
Sets first player.

### priorityWay switch
**If "both-ways" switch is on** and both vertical and horizontal paths are the same length, you can set priority way to go.
This switch has has no effect if the "both-ways" switch is off.

### debug switch
Turns on debug mode.

### Go 1 turn button
You can use this button instead of GO button, to play only onw turn and not the whole simulation.

### Skip turn (human) button
If the human player is on, you can press this button to skip your turn.




_Made in 2018 by Martin Polreich._
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

hex
false
0
Polygon -7500403 true true 0 150 75 30 225 30 300 150 225 270 75 270

hexrot
true
0
Polygon -7500403 true true 0 150 75 30 225 30 300 150 225 270 75 270

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
<experiments>
  <experiment name="experiment" repetitions="1000" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="5000"/>
    <metric>winner-color</metric>
  </experiment>
  <experiment name="bothBlocking-bothWaysOff-firstRed" repetitions="200" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="1000"/>
    <metric>winner-color</metric>
    <enumeratedValueSet variable="blueStrategy">
      <value value="&quot;blocking&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="priorityWay">
      <value value="&quot;random&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="debug">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="both-ways">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="human">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="first-player">
      <value value="&quot;red&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="redStrategy">
      <value value="&quot;blocking&quot;"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="bothBlocking-bothWaysOff-firstBlue" repetitions="200" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="1000"/>
    <metric>winner-color</metric>
    <enumeratedValueSet variable="blueStrategy">
      <value value="&quot;blocking&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="priorityWay">
      <value value="&quot;random&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="debug">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="both-ways">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="human">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="first-player">
      <value value="&quot;blue&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="redStrategy">
      <value value="&quot;blocking&quot;"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="bothShortest-bothWaysOff-firstRed" repetitions="200" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="300"/>
    <metric>winner-color</metric>
    <enumeratedValueSet variable="blueStrategy">
      <value value="&quot;shortest&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="priorityWay">
      <value value="&quot;random&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="debug">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="both-ways">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="human">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="first-player">
      <value value="&quot;red&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="redStrategy">
      <value value="&quot;shortest&quot;"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="bothShortest-bothWaysOff-firstBlue" repetitions="200" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="300"/>
    <metric>winner-color</metric>
    <enumeratedValueSet variable="blueStrategy">
      <value value="&quot;shortest&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="priorityWay">
      <value value="&quot;random&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="debug">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="both-ways">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="human">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="first-player">
      <value value="&quot;blue&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="redStrategy">
      <value value="&quot;shortest&quot;"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="blueShortest-redBlocking-bothWaysOff-firstRed" repetitions="200" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="200"/>
    <metric>winner-color</metric>
    <enumeratedValueSet variable="blueStrategy">
      <value value="&quot;shortest&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="debug">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="priorityWay">
      <value value="&quot;random&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="both-ways">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="human">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="first-player">
      <value value="&quot;red&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="redStrategy">
      <value value="&quot;blocking&quot;"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="blueShortest-redBlocking-bothWaysOff-firstBlue" repetitions="200" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="200"/>
    <metric>winner-color</metric>
    <enumeratedValueSet variable="blueStrategy">
      <value value="&quot;shortest&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="debug">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="priorityWay">
      <value value="&quot;random&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="both-ways">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="human">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="first-player">
      <value value="&quot;blue&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="redStrategy">
      <value value="&quot;blocking&quot;"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="blueBlocking-redShortest-bothWaysOff-firstRed" repetitions="200" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="200"/>
    <metric>winner-color</metric>
    <enumeratedValueSet variable="blueStrategy">
      <value value="&quot;blocking&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="debug">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="priorityWay">
      <value value="&quot;random&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="both-ways">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="human">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="first-player">
      <value value="&quot;red&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="redStrategy">
      <value value="&quot;shortest&quot;"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="blueBlocking-redShortest-bothWaysOff-firstBlue" repetitions="200" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="200"/>
    <metric>winner-color</metric>
    <enumeratedValueSet variable="blueStrategy">
      <value value="&quot;blocking&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="debug">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="priorityWay">
      <value value="&quot;random&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="both-ways">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="human">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="first-player">
      <value value="&quot;blue&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="redStrategy">
      <value value="&quot;shortest&quot;"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="bothRandom-bothWaysOn-firstRed" repetitions="200" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="100"/>
    <metric>winner-color</metric>
    <enumeratedValueSet variable="blueStrategy">
      <value value="&quot;random&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="priorityWay">
      <value value="&quot;random&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="debug">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="both-ways">
      <value value="true"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="human">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="first-player">
      <value value="&quot;red&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="redStrategy">
      <value value="&quot;random&quot;"/>
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

dots
0.0
-0.2 0 0.0 1.0
0.0 1 2.0 2.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180

none
0.0
-0.2 0 0.0 1.0
0.0 0 0.0 1.0
0.2 0 0.0 1.0
link direction
true
0

square
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
false
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
Rectangle -7500403 true true 0 0 330 315

triple
0.0
-0.2 1 1.0 0.0
0.0 1 1.0 0.0
0.2 1 1.0 0.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
0
@#$#@#$#@
