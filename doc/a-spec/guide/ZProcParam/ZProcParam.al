#fileID<ZProcParam_al>

begin process ZProcParam
where
   Factorial(start: nat1) =
      FactorialImpl(start, start - 1);

   FactorialImpl(val: nat1, next: nat) =
      if(next > 0) then
         FactorialImpl(val * next, next - 1)
      else
         result!val -> SKIP
      endif;
end
