#fileID<RelOp_al>

#import<toolkit.al>

begin axdef RelOpDecl
   rel bin5 factorOf: int <--> int;
   rel pre3 isNegative: pset int;
   rel post4 prime: pset int;
where
   forAll{op1: int; op2: int; ? @
      op1 factorOf op2 <=> op2 mod op1 = 0;
   };

   forAll{num: int; ? @
      isNegative num <=> num < 0;
   };

   forAll{op: nat; ? op >= 2; @
      op prime <=>
         !exists{f1: nat; f2: nat; ?
            f1 >= 2; f2 >= 2; @
            f1 * f2 = op;
         };
   };
end

begin const RelOpAppl
   3 factorOf 6;
   isNegative -5;
   3 prime;
end
