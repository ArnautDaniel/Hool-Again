! Copyright (C) 2019 Jack Lucas
! See http://factorcode.org/license.txt for BSD license.
USING: accessors kernel prettyprint.custom prettyprint.backend ;
IN: hool.boids.prettyprinter

SYNTAX: BOID: scan-object scan-object <boid> suffix! ;

M: boid pprint*
    [ \ BOID: [
          dup pos>> pprint*
          speed>> pprint* ] pprint-prefix ] check-recursion ;
