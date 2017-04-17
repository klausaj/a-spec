#fileID<ZParam_al>

begin process Subscribers
where
   Abs =
      input?num ->
         if(num < 0) then
            result![-num] -> Abs
         else
            result!num -> Abs
         endif;
end
