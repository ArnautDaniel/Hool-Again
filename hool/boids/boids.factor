! Copyright (C) 2019 Jack Lucas
! See http://factorcode.org/license.txt for BSD license.
USING: hool.octree assocs kernel combinators accessors locals
math.vectors vectors sequences math combinators.short-circuit arrays fry classes.struct continuations words sequences.generalizations hool.cubes prettyprint.backend prettyprint.custom parser random sequences.deep raylib.ffi ;

IN: hool.boids

TUPLE: boid
    pos speed ;

: <boid> ( cube speed -- boid )
    boid boa ;

SYNTAX: BOID: scan-object scan-object <boid> suffix! ;

M: boid pprint*
    [ \ BOID: [
          dup pos>> pprint*
          speed>> pprint* ] pprint-prefix ] check-recursion ;

GENERIC: change-direction ( vector-mod object -- ) 
GENERIC: render-object ( object -- )
GENERIC: update-object ( object -- )
GENERIC: reset-direction ( object -- )

M: boid change-direction 
    swap [ dup speed>> ] dip v
+ >>speed drop  ;

M: boid reset-direction
    { 0 0 0 } >>speed drop ;

M: boid render-object
    [ pos>> loc>> >RayVector3 ] [ pos>> dim>> >RayVector3 ] bi BLACK draw-cube-v ;

M: boid update-object
    dup [ pos>> loc>> ] keep
    speed>> v+ [ pos>> ] dip
    >>loc drop ;
   
M: boid obj>insert
    [ pos>> ] keep swap ;
