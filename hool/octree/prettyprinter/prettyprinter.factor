! Copyright (C) 2019 Jack Lucas
! See http://factorcode.org/license.txt for BSD license.
USING: accessors kernel prettyprint.custom prettyprint.backend ;
IN: hool.octree.prettyprinter

SYNTAX: OCTOBJ: scan-object scan-object <octree-object> suffix! ;
SYNTAX: OCTREE: scan-object scan-object <cube> <octree> suffix! ;

M: octree-object pprint*
    [ \ OCTOBJ: [
          dup cube>> pprint*
          obj>> pprint* ] pprint-prefix ] check-recursion ;

M: octree pprint* [ \ OCTREE: [
                        dup geometry>> [ loc>> ] [ dim>> ] bi [ pprint* ] bi@
                        objects>> pprint* ] pprint-prefix ] check-recursion ;
