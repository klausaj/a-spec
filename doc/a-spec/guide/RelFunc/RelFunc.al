#fileID<RelFunc_al>

#import<toolkit.al>

begin axdef RelFuncDecl
   bool equals: int <--> int;
where
   forAll{op1: int; op2: int; ? @
      equals(op1, op2) <=> op1 = op2;
   };
end

begin const RelFuncAppl
   equals(6, 6);
   !equals(6, 7);
end
