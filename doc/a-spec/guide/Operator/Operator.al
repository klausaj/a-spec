#fileID<Operator_al>

#import<toolkit.al>

begin axdef OpDecl
   oper bin4 add:cross{int,int} ---> int;
   oper pre6 negate:int ---> int;
   oper post9 squared:int ---> int;
where
   forAll{op1: int; op2: int; ? @
      op1 add op2 = op1 + op2;
   };

   forAll{op: int; ? @
      negate op = -op;
      op squared = op^2;
   };
end

begin const OpAppl
   2 add 8 = 10;
   negate 2 = -2;
   2 squared = 4;
end
