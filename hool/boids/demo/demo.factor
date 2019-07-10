! Copyright (C) 2019 Jack Lucas
! See http://factorcode.org/license.txt for BSD license.
USING: hool.octree assocs kernel combinators accessors locals
math.vectors vectors sequences math combinators.short-circuit arrays fry classes.struct continuations words sequences.generalizations hool.cubes prettyprint.backend prettyprint.custom parser random sequences.deep raylib.ffi hool.boids alien.enums namespaces hool.world math.ranges ;

IN: hool.boids.demo

: make-window ( -- )
    800 450 "Boids" init-window
    20 set-target-fps ;

: generate-boid ( -- boid )
    { 100 100 100  } [ random ] map
    { 100 100 100  } [ random ] map <cube>
    { { -10.0 10.0 } { -10.0 10.0 } { -10.0 10.0 } } [ [ [a,b] random ] with-datastack first ] map  <boid> ;

<<<<<<< HEAD
: run-world ( world -- world )
    world-update-camera render-world-objs
    update-world-objs generate-boid swap world-add-object
    reset? screenshot? within-bounds ;

: main ( --  )
    make-window { } <hool-world> world-set-camera-mode
    [ run-world window-should-close not ] loop
    close-window drop ;

MAIN: main
=======
: add-boid ( world -- world )
    dup objects>> generate-boid suffix
    >>objects ; 

: main ( -- world )
    make-window
    { 0 0 0 } { 640 640 640 } { } <hool-world>
    [ render-world-objs update-world-objs update-world
      add-boid clear-bounds window-should-close not ] loop
    close-window ;


>>>>>>> b1c7a408ae3ba75681eb95809bac9c259fd79e34
