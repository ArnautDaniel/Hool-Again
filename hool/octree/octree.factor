! Copyright (C) 2019 Jack Lucas
! See http://factorcode.org/license.txt for BSD license.
USING: assocs kernel combinators accessors locals
math.vectors vectors sequences math combinators.short-circuit arrays fry classes.struct continuations words sequences.generalizations hool.cubes random sequences.deep ;
IN: hool.octree

! Factor only provides a rectangle from what I can tell

! Abstraction over any object we want to put in the octree
! The only thing we need is a cube describing the dimensions so
! we can tell what object can fit in which octant
! Age is used for the mini-nursery system 
TUPLE: octree-object cube obj { age initial: f } { parent initial: f } ;

: <octree-object> ( obj pos -- obj )
    swap f f octree-object boa ;

GENERIC: obj>insert ( obj -- value cube )
M: octree-object obj>insert
    [ obj>> ] [ cube>> ] bi ;

TUPLE: octree
    { geometry cube }
    { objects initial: { } }
    max-count ! Max count is the number of objects this octant should hold besides
    leaf ! Is this the last node in the tree?
    parent ! Reference to parent node
    children ;


! Default node creation
: <octree> ( cube  -- octree )
    octree new
    swap >>geometry
    { } >>objects
    H{ } clone >>children
    15 >>max-count
    t >>leaf ;

! Relative to upper left point of cube

! Forward facing points
: cube-ul ( cube -- point ) loc>> ;
: cube-ur ( cube -- point )
    [ loc>> ] [ dim>> { .5 0 0 } v* ] bi v+ ;
: cube-ll ( cube -- point )
    [ loc>> ] [ dim>> { 0 .5 0 } v* ] bi v+ ;
: cube-lr ( cube -- point )
    [ loc>> ] [ dim>> { .5 .5 0 } v* ] bi v+ ;

! Midpoint facing points
: cube-bul ( cube -- point )
    [ loc>> ] [ dim>> { 0 0 .5 } v* ] bi v+ ;
: cube-bur ( cube -- point )
    [ loc>> ] [ dim>> { .5 0 .5 } v* ] bi v+ ;
: cube-bll ( cube -- point )
    [ loc>> ] [ dim>> { 0 .5 .5 } v* ] bi v+ ;
: cube-blr ( cube -- point )
    [ loc>> ] [ dim>> { .5 .5 .5 } v* ] bi v+ ;

! Back lower right point is cube-center
: cube-center ( cube -- point )
    cube-blr ;

! Children are stored in alists instead of  doing seperate accessors

: child-or-parent ( node key -- new-node )
    [ dup children>> ] dip of
    dup [ nip ] [ drop ] if  ;

: child ( node key -- new-node )
    [ children>> ] dip of ;

: bof ( bool -- string )
    third [ "b" ] [ "" ] if ; inline
: uod ( bool -- string )
    second [ "u" ] [ "l" ] if ; inline
: rol ( bool -- string )
    first [ "r" ] [ "l" ] if ; inline

! Admittently odd way of doing it
! First we check the point we're looking at against the midpoint vector
! to get a sequence back like { t f t } then using the three other words we
! decide which string value this should be.  We then append all the individual values
! together and ask for that key in the children alist
! Seems slightly better to me than setting up a complicated 6 if chain
: (octant) ( pt node -- octant/f )
    swap [ dup geometry>> cube-center ] dip
    swap [ > ] 2map [ bof ] [ uod ] [ rol ] tri
    append append child ;

! Holdover from quadtree port
! We set our origin to the top left corner instead of the
! exact middle.  
: octant ( pt node -- octant )
    (octant) ;

: descend ( pt node -- pt subnode )
    [ dup ] dip octant ; inline

! Change into higher order version
: each-octant ( node quot -- )
    {
        [ [ children>> "ul" of ] [ call ] bi* ]
        [ [ children>> "ur" of ] [ call ] bi* ]
        [ [ children>> "ll" of ] [ call ] bi* ]
        [ [ children>> "lr" of ] [ call ] bi* ]
        [ [ children>> "bul" of ] [ call ] bi* ]
        [ [ children>>  "bur" of ] [ call ] bi* ]
        [ [ children>> "bll" of ] [ call ] bi* ]
        [ [ children>> "blr" of ] [ call ] bi* ]
    }
    2cleave ; inline

: map-octree ( node quot: ( child-node --  x ) -- array )
    each-octant 8 narray ; inline

<PRIVATE


DEFER: insert
DEFER: node-insert
DEFER: contains-point?
DEFER: add-object

: node>octants ( node -- octant )
    children>> values ;

: child-set ( child tag parent -- )
    children>> set-at ;

: make-cube ( cube-parent cube -- cube )
    swap clone cube-center <cube> ;

! Link to parent node

! Change into higher order version
:: add-subnodes ( node -- node )
    node geometry>>
    {
        [ dup cube-ul make-cube  <octree>  "ul"  node child-set ]
        [ dup cube-ur make-cube  <octree>  "ur"  node child-set ]
        [ dup cube-ll make-cube  <octree>  "ll"  node child-set ]
        [ dup cube-lr make-cube  <octree>  "lr"  node child-set ]
        [ dup cube-bul make-cube <octree>  "bul"  node child-set ]
        [ dup cube-bll make-cube <octree>  "bll"  node child-set ]
        [ dup cube-bur make-cube <octree>  "bur"  node child-set ]
        [ dup cube-blr make-cube <octree>  "blr"  node child-set ]
    } cleave
    node f >>leaf ;
    
: leaf-add-object ( value point leaf -- )
    [ <octree-object> ] dip add-object ;

: parent-to-object ( parent object -- )
    swap >>parent drop ;

! TODO implement short-circuit version
:: distribute-object ( object nodes  -- object/f )
    nodes
    [ dup geometry>> object cube>> contains-cube?
      [ dup object parent-to-object
        object swap add-object f ] [ drop t ] if ]
    map
    f swap member?
    [ f ] [ object ] if ;

:: redistribute-objects ( parent children objects -- )
    objects [ age>> not ] filter
    ! Filter out any age t
    children [ distribute-object ] curry
    map sift
    ! Check if the objects can fit in the proper children
    ! based on location and size
    [ t >>age ] map parent swap >>objects drop ;
! Mark the leftovers as age t

: node-cube-compare ( cube node -- bool )
    geometry>> swap contains-cube? ; inline

: leaf-trace ( cube node -- objects? )
    2dup node-cube-compare ! Does object fit inside this leaf?
    [ nip objects>> ] [ 2drop { } ] if ;

DEFER: trace-tree 
: node-children-trace ( node cube -- objects? )
    [ children>> values ] dip
    [ trace-tree ] curry
    map flatten ;

: node-trace ( cube node -- objects? )
    2dup node-cube-compare ! Does object fit inside this node?
    [ swap [ node-children-trace ] curry [ objects>> ] swap
      bi append ]
    [ 2drop { } ] if ;

! Trace a tree for all nodes holding a cube
: trace-tree ( node cube -- nodelst )
    swap dup leaf>> [ leaf-trace ] [ node-trace ] if ;

: split-leaf ( value point leaf -- )
    add-subnodes
    dup [ leaf-add-object ] dip dup
    [ children>> values ] [ objects>> ] bi
    redistribute-objects ;
  
! If we've reached max objects we need to subdivide
: leaf-full? ( leaf -- ? )
    dup objects>> length
    swap max-count>> > ;

: add-object ( object leaf -- )
    dup [ objects>> swap suffix ] dip
    swap >>objects drop ;

: leaf-insert ( value point leaf -- )
    dup leaf-full? not
    [ leaf-add-object ]
    [ split-leaf ] if ;

: insert-at-node ( value point node -- )
    leaf-add-object ;

: children-cubes ( node -- lst )
    children>> values [ geometry>> ] map ;

: children-contains? ( cube node -- lst/empty )
    swap [ [ geometry>> ] dip contains-cube? ] curry filter ;

: node-insert ( value cube node -- )
    2dup children>> values children-contains?
    dup empty?
    [ drop insert-at-node ] [ nip first insert ] if ;
    
: insert ( value cube tree -- )
    dup leaf>> [ leaf-insert ] [ node-insert ] if ;

: (?leaf) ( octant -- pair/f )
    dup geometry>> loc>> [ swap objects>> 2array ]
    [ drop f ] if* ;

: ?leaf ( octant -- pair/f )
    [ (?leaf) ] map sift dup length {
        { 1 [ first ] }
        { 0 [ drop { f f } ] }
        [ 2drop f ]
    } case ;

: remove-subnodes ( node -- leaf )
    { } >>children
    t >>leaf  ;


PRIVATE>

INSTANCE: octree assoc
M: octree set-at ( value key assoc -- ) insert ;

M: octree clear-assoc ( assoc -- )
    t >>leaf
    { } >>objects
    H{ } clone >>children
    drop ;

! Utilities for testing ---------------------------------
: octree-cube ( num -- octree )
    3 swap <repetition> { 0 0 0 } swap
    <cube> <octree> ;

: items ( -- items )
    { "pizza" "matzo" "olive" "grapes" "peanuts" "mochi" "mocha" } ;

: locs ( -- locs )
    { 64000 64000 64000 } [ random ] map ;

: dim ( -- dim )
    { 500 500 500 } [ random ] map ;

: random-test-item ( -- value cube )
    items random locs dim <cube> ;

: add-random-item ( octree item cube -- )
    pick insert drop ;

: random-item-gen ( n octree -- )
    [ random-test-item add-random-item ] curry times ;
