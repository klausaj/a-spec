#fileID<GenDef_al>

#import<toolkit.al>

begin gendef[X] GenDef
   bool isEmpty: pset X;
   func take: (pset X) --|> X;
where
   forAll{S: pset X; ? @
      isEmpty(S) <=> S = setDisp{};
   };

   forAll{S: pset X; ? !isEmpty(S); @
      exists{x: X; ? x in S; @
         take(S) = x;
      };
   };
end

begin axdef GenDefAppl
   S: pset int;
   x: int;
where
   if(!isEmpty(S)) then
      x = take(S);
   endif;
end
