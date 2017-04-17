#fileID<CondPred_al>

begin axdef CondPred
   x: int;
   y: int;
   z: int;
   eval: int;
where
   if(x > 0) then
      y = x;
   else
      y = -x;
   endif;

   if(x > eval) then
      z = -1;
   elif (x = eval) then
      z = 0;
   else
      z = 1;
   endif;
end
