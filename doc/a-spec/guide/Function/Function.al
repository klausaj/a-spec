#fileID<Function_al>

#import<toolkit.al>

begin axdef FuncDecl
   func abs_ex: int ---> nat;
where
   forAll{val: int; ? @
      if(val < 0) then
         abs_ex(val) = -val;
      else
         abs_ex(val) = val;
      endif;
   };
end

begin const FuncAppl
   abs_ex(-5) = 5;
   abs_ex(6) = 6;
end
