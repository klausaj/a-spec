#fileID<AxDef_al>

#import<toolkit.al>

begin axdef AxDefBool
   bool isEmpty: pset BASKET;
   func take: BASKET --|> FRUIT;
where
   forAll{b: BASKET; ? @
      isEmpty(b) <=> b = eseq FRUIT;
   };

   forAll{b: BASKET; ? !isEmpty(b) @
      exists{n: nat; ? n < size(b); @
         take(b) = b(n);
      };
   };
end

begin axdef AxDefOperator
   rel bin4 contains: BASKET <--> FRUIT;
   oper bin4 returnTo:
      cross{FRUIT, BASKET} ---> BASKET;
where
   forAll{b: BASKET; f: FRUIT; ? @
      b contains f <=> f in ran(b);
      f returnTo b = b cat seqDisp{f};
   };
end
