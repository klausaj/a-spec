#fileID<LetPred_al>

#import<toolkit.al>

begin axdef LetPred
   rel bin5 isFactorOf: nat <--> nat;
where
   forAll{num1: nat; num2: nat; ? @
      num1 isFactorOf num2 <=>
         let{remain = num2 mod num1; @
            remain = 0;
         };
   };
end
