#fileID<Mu_al>

#import<toolkit.al>

begin axdef Mu
   func sum: (seq int) ---> int;
where
   forAll{S: seq int; ? @
      if(S = eseq int) then
         sum(S) = 0;
      else
         sum(S) =
            mu{x: int; S2: seq int; ?
               x = S(1);
               S2 = tail(S);
               @
               x + sum(S2)};
      endif;
   };
end

begin const MuAppl
   sum(seqDisp{2, 4, 6}) = 12;
end
