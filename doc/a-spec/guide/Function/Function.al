#fileID<Function_al>

#import<toolkit.al>

begin axdef FuncDecl
   func abs: int ---> nat;
where
   forAll{val: int; ? @
      if(val < 0) then
         abs(val) = -val;
      else
         abs(val) = val;
      endif;
   };
end

begin const FuncAppl
   abs(-5) = 5;
   abs(6) = 6;
end
