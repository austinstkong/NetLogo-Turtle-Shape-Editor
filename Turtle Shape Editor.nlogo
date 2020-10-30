__includes ["polygon.nls" "select_multiple.nls"]

extensions [csv table]



globals [
  selected prev current selected_delta
  downTimer upTimer
  lastDownTime lastUpTime
  flagUp flagDown mouseIsDown
  clickCounter doubleClickCounter
  color_lookup
  mode
]

to startup
  setup

end

to setup
  clear-all
  reset-timer
  set selected nobody
  set current nobody
  set prev nobody
  set flagDown mouse-down?
  set flagUp not flagDown
  set mouseIsDown mouse-down?
  set clickCounter 0
  set doubleClickCounter 0

  set color_lookup table:make

  let stepSize 1

  foreach n-values (max-pxcor + 1) [ i -> i ] [ x ->
    foreach n-values (max-pycor + 1) [ i -> i ] [ y ->
      ifelse (x / stepSize) mod 2 = 0 [
        ask patch x y [set pcolor ifelse-value (y / stepSize) mod 2 = 0 [grey - 1] [grey + 2]]
      ] [
        ask patch x y [set pcolor ifelse-value (y / stepSize) mod 2 = 0 [grey + 2] [grey - 1]]
      ]
    ]
  ]
end

to go
  if mode != elementType [
    set mode elementType
    set selected nobody
    set prev nobody
  ]
  ifelse mouse-down? [
    if timer >= upTimer [
      ; Only do these actions once on the click
      if not mouseIsDown [
        set mouseIsDown true
        set lastUpTime timer - downTimer
        ;output-print word "Down " precision lastUpTime 4
      ]
      set downTimer timer
    ]
    ; if the mouse is down then handle selecting and dragging
    run word "draw_" elementType
  ] [
    if timer >= downTimer [
      ; Only do these actions once on release
      if mouseIsDown [
        set mouseIsDown false
        set lastDownTime timer - upTimer
        ;output-print word "Up   "  precision lastDownTime 4
        set clickCounter clickCounter + 1

        ; otherwise, make sure the previous selection is deselected
        set prev selected
        set selected nobody
        ask turtles [set color black]
        if prev != nobody [
          ask prev [set color blue]
          run word "check_" elementType
        ]

        ; Detect a double click
        if lastUpTime < doubleClickDelay [
          set doubleClickCounter doubleClickCounter + 1
          ; clears the last selected turtle
          run word "doubleClick_" elementType
          set prev nobody
        ]
      ]
      set upTimer timer
    ]
    reset-perspective
  ]
  display ; update the display as not using ticks
end

to parse_element [str]
  set str (csv:from-row str " ")
  carefully [
    set color_as_int item 1 str
  ] [
    user-message (word "Invalid color_as_int: " (item 1 str) "\n\n" error-message)
    stop
  ]
  ifelse is-boolean? item 2 str [
    set filled? item 2 str
  ] [
    user-message word "Expected a boolean in position 2: " item 2 str
    stop
  ]
  ifelse is-boolean? item 3 str [
    set marked? item 3 str
  ] [
    user-message word "Expected a boolean in position 3: " item 3 str
    stop
  ]
  (ifelse
    not is-string? first str [
      user-message word "Expected a string in position 0: " item 1 str
      stop
    ] first str = "Polygon" [
      ;s"Polygon ${awtColor.getRGB} $filled $marked $pointsString"
      set str sublist str 4 length str
      if length str mod 2 != 0 [
        user-message word "Expected even number of elements but got:" length str
        stop
      ]
    ] first str = "Rectangle" [
      ;s"Rectangle ${awtColor.getRGB} $filled $marked ${upperLeft.x} ${upperLeft.y} ${lowerRight.x} ${lowerRight.y}"
      set str sublist str 4 length str
      if length str != 4 [
        user-message word "Expected [ULx ULy LRx LR y] but got:" str
        stop
      ]
    ] first str = "Line" [
      ;"Line " + awtColor.getRGB + " " + marked + " " + start.x + " " + start.y + " " + end.x + " " + end.y
      if length str != 4 [
        user-message word "Expected [xo yo x1 y1] but got:" str
        stop
      ]
    ] first str = "Circle" [
      ;"Circle " + awtColor.getRGB + " " + filled + " " + marked + " " + x + " " + y + " " + xDiameter
      if length str != 3 [
        user-message word "Expected [x y dia] but got:" str
        stop
      ]
    ] [
      user-message word "Invalid shape type: " first str
      stop
  ])
  output-print str
end

to parse_shape [str]
   ;   name,
   ;   rotatable,
   ;   editableColorIndex) ++
   ;   elementList.filter(_.shouldSave).map(_.toString)).mkString("\n")
end
@#$#@#$#@
GRAPHICS-WINDOW
0
10
938
949
-1
-1
30.0
1
14
1
1
1
0
0
0
1
0
30
0
30
0
0
1
ticks
30.0

BUTTON
950
10
1014
43
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
1

BUTTON
950
45
1013
78
NIL
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

MONITOR
1125
55
1205
100
NIL
selected
17
1
11

MONITOR
1205
10
1285
55
NIL
mouse-down?
17
1
11

MONITOR
1285
10
1360
55
NIL
mouse-xcor
1
1
11

MONITOR
1360
10
1435
55
NIL
mouse-ycor
1
1
11

MONITOR
1125
10
1205
55
Under mouse
one-of [turtles-here] of patch mouse-xcor mouse-ycor
17
1
11

MONITOR
1205
55
1285
100
NIL
prev
17
1
11

MONITOR
1610
10
1690
55
NIL
downTimer
2
1
11

MONITOR
1610
55
1690
100
NIL
lastDownTime
2
1
11

MONITOR
1690
10
1770
55
NIL
upTimer
2
1
11

OUTPUT
945
415
1510
905
11

MONITOR
1690
55
1770
100
NIL
lastUpTime
3
1
11

MONITOR
1435
10
1505
55
NIL
clickCounter
17
1
11

MONITOR
1505
10
1610
55
NIL
doubleClickCounter
17
1
11

SLIDER
1435
55
1610
88
doubleClickDelay
doubleClickDelay
0
1
0.17
0.01
1
s
HORIZONTAL

CHOOSER
950
125
1088
170
elementType
elementType
"Polygon" "Line" "Rectangle" "Circle"
0

BUTTON
950
320
1055
353
Export Element
set element_string runresult word \"export_\" elementType
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

INPUTBOX
945
355
1775
415
element_string
NIL
1
0
String

SWITCH
950
215
1053
248
filled?
filled?
0
1
-1000

CHOOSER
950
170
1088
215
color_as_int
color_as_int
-1 -2
1

BUTTON
950
285
1055
318
Draw Element
parse_element element_string
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

INPUTBOX
1095
155
1160
215
col
55.0
1
0
Color

SWITCH
950
250
1053
283
marked?
marked?
1
1
-1000

BUTTON
950
80
1040
113
NIL
select_multiple
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

@#$#@#$#@
# NetLogo Turtle Shape Editor


## WHAT IS IT?

A _slightly_ more advanced tool for editing turtle shapes in NetLogo

## HOW IT WORKS

Just press `Setup` then `Go`!

Chose the shape with the `shapeType` chooser.

Click to create and drag around to edit. Double click to delete verticies.


## HOW TO USE IT

Import the string from a `.nlogo` file and edit it here.

Or create a new shape from scratch and export the string definition back into a `.nlogo` file.

### `.nlogo` file structure

See [here](https://github.com/NetLogo/NetLogo/wiki/File-(.nlogo)-and-Widget-Format) for details about the `.nlogo` file format and turtle shape syntax.

A conforming model file contains __exactly 12__ sections, separated by `@#$#@#$#@` dividers.

The individual sections vary in format.

    Code tab
    @#$#@#$#@
    Interface tab   
    @#$#@#$#@
    Info tab
    @#$#@#$#@
    turtle shapes
    @#$#@#$#@
    NetLogo version
    @#$#@#$#@
    preview commands
    @#$#@#$#@
    System Dynamics Modeler
    @#$#@#$#@
    BehaviorSpace
    @#$#@#$#@
    HubNet client
    @#$#@#$#@
    link shapes
    @#$#@#$#@
    model settings
    @#$#@#$#@
    DeltaTick

#### Turtle shapes

Turtle shapes go here. If empty, netlogo provides with the default shapes. However, once you specify a shape, it includes them all.

    name-of-shape
    rotatable?
    number-of-color (its order in the editor's chooser) that is changable in the shape

Then, any number of component pieces of the shape, in a line-by-line format that's something like:

    shape-type color-as-int some-bools some-numbers

#### Link shapes

Like turtle shapes, but for links.

## THINGS TO NOTICE

No grid snapping unlike the built in editor.

## THINGS TO TRY

(suggested things for the user to try to do (move sliders, switches, etc.) with the model)

## EXTENDING THE MODEL

Symmetry and rotation options

## RELATED MODELS

Built off NetLogo's built in mouse examples

## CREDITS AND REFERENCES

__Author: Austin Kong__

[Find me on GitHub](https://github.com/austinstkong/NetLogo-Turtle-Shape-Editor)

This is free and unencumbered software released into the public domain.

Anyone is free to copy, modify, publish, use, compile, sell, or
distribute this software, either in source code form or as a compiled
binary, for any purpose, commercial or non-commercial, and by any
means.

In jurisdictions that recognize copyright laws, the author or authors
of this software dedicate any and all copyright interest in the
software to the public domain. We make this dedication for the benefit
of the public at large and to the detriment of our heirs and
successors. We intend this dedication to be an overt act of
relinquishment in perpetuity of all present and future rights to this
software under copyright law.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS BE LIABLE FOR ANY CLAIM, DAMAGES OR
OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
OTHER DEALINGS IN THE SOFTWARE.

For more information, please refer to <https://unlicense.org>
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
NetLogo 6.1.1
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

polygon closed
0.0
-0.2 1 1.0 0.0
0.0 1 1.0 0.0
0.2 1 1.0 0.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180

polygon open
0.0
-0.2 1 4.0 4.0
0.0 1 1.0 0.0
0.2 1 4.0 4.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
1
@#$#@#$#@
