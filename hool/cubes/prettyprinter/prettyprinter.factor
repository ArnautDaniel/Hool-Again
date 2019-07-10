! Copyright (C) 2019 Jack Lucas
! See http://factorcode.org/license.txt for BSD license.
USING: accessors kernel prettyprint.custom prettyprint.backend ;
IN: hool.cubes.prettyprinter

SYNTAX: CUBE: scan-object scan-object <cube> suffix! ;
M: cube pprint*
    [ \ CUBE: [
          [ loc>> ] [ dim>> ] bi [ pprint* ] bi@
      ] pprint-prefix ] check-recursion ;
