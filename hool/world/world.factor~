! Copyright (C) 2019 Jack Lucas
! See http://factorcode.org/license.txt for BSD license.
USING: hool.octree assocs kernel combinators accessors locals
math.vectors vectors sequences math combinators.short-circuit arrays fry classes.struct continuations words sequences.generalizations hool.cubes prettyprint.backend prettyprint.custom parser random sequences.deep raylib.ffi alien.enums namespaces hool.boids ;

IN: hool.world

TUPLE: hool-world
    objects
    octree
    camera
    ;

: <ray-vector3> ( x y z -- vector3 )
    Vector3 <struct-boa> ;

: setup-camera ( -- camera )
    1000.0 0.0 0.0  <ray-vector3>
    0.0 0.0 0.0  <ray-vector3>
    0.0 1.0 0.0 <ray-vector3>
    45.0 CAMERA_PERSPECTIVE enum>number
    Camera3D <struct-boa> ;

: <hool-world> ( objects -- world )
    { 0 0 0 } { 64000 64000 64000 } <cube> <octree>
    setup-camera hool-world boa ;

GENERIC: obj>octree ( world -- world )
GENERIC: clear-world ( world -- world )
GENERIC: render-world-objs ( world -- world )
GENERIC: update-world-objs ( world -- world )
GENERIC: update-world ( world -- world )
GENERIC: clear-bounds ( world -- world )
M: hool-world obj>octree
    dup objects>> 
    over octree>> [ [ obj>insert ] dip set-at ] curry
    each ;

M: hool-world clear-world
    dup octree>> clear-assoc ;


: clear-window ( -- )
    RAYWHITE clear-background ;

M: hool-world render-world-objs
    dup [ camera>> ] keep swap
    begin-drawing
    begin-mode-3d
    clear-window
    objects>> [ render-object ] each
    end-drawing
    end-mode-3d ;

M: hool-world update-world-objs
    dup objects>> [ update-object ] each ;

M: hool-world update-world
    clear-world
    obj>octree ;

M: hool-world clear-bounds
    dup [ objects>> ] [ octree>> ]
    bi geometry>> [ swap contains-cube? ] curry
    filter >>objects ;
