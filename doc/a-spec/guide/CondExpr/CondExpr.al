#fileID<CondExpr_al>

begin axdef CondExpr
   x: int;
   y: int;
   z: int;
   eval: int;
where
   y = if(x > 0) then
          x
       else
          -x
       endif;

   z = if(x > eval) then
          -1
       elif (x = eval) then
          0
       else
          1
       endif;
end
