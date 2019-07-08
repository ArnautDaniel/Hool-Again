! Copyright (C) 2019 Jack Lucas
! See http://factorcode.org/license.txt for BSD license.
USING: hool.octree assocs kernel combinators accessors locals
math.vectors vectors sequences math combinators.short-circuit arrays fry classes.struct continuations words sequences.generalizations hool.cubes prettyprint.backend prettyprint.custom parser random sequences.deep raylib.ffi hool.boids alien.enums namespaces hool.world ;

IN: hool.boids.demo

: make-window ( -- )
    800 450 "Boids" init-window
    60 set-target-fps ;

: generate-boid ( -- boid )
    { 10 10 10  } [ random ] map
    { 20 20 20  } [ random ] map <cube>
    { 1 1 1 } <boid> ;

: add-boid ( world -- world )
    dup objects>> generate-boid suffix
    >>objects ; 

: main ( -- world )
    make-window
    { 0 0 0 } { 640 640 640 } { } <hool-world>
    [ render-world-objs update-world-objs update-world
      add-boid clear-bounds window-should-close not ] loop
    close-window ;


