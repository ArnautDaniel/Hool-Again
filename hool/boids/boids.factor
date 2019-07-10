! Copyright (C) 2019 Jack Lucas
! See http://factorcode.org/license.txt for BSD license.
USING: hool.octree assocs kernel combinators accessors locals
math.vectors vectors sequences math combinators.short-circuit arrays fry classes.struct continuations words sequences.generalizations hool.cubes random sequences.deep raylib.ffi ;

IN: hool.boids

TUPLE: boid
    pos speed size ;

: <boid> ( cube speed -- boid )
    30 random boid boa ;

GENERIC: change-direction ( vector-mod object -- ) 
GENERIC: render-object ( object -- )
GENERIC: update-object ( object -- )
GENERIC: reset-direction ( object -- )
GENERIC: reverse-direction ( object -- )
M: boid change-direction 
    swap [ dup speed>> ] dip v
+ >>speed drop  ;

M: boid reset-direction
    { 0 0 0 } >>speed drop ;

M: boid reverse-direction
    { -1 -1 -1 } [ dup speed>> ] dip v* >>speed drop ;


M: boid render-object
    [ pos>> loc>> >RayVector3 ] [ size>> ] bi RAYWHITE draw-sphere ;

M: boid update-object
    dup [ pos>> loc>> ] keep
    speed>> v+ [ pos>> ] dip
    >>loc drop ;
   
M: boid obj>insert
    [ pos>> ] keep swap ;
