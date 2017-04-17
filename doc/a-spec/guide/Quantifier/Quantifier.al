#fileID<Quantifier_al>

begin const Quantifier
   forAll{x: int; ? x < 30; @
      x * 2 < 60};
   exists{x: int; ? x < 30; @
      x * 2 < 30};
   exists1{x: int; ? x < 30; @
      x * 2 = 4};
end
