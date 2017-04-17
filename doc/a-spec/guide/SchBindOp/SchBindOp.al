#fileID<SchBindOp_al>

#import<toolkit.al>

begin const BindOp
   let{fruit =
         setDisp{APPLE |--> 4, ORANGE |--> 4,
            PINEAPPLE |--> 1, BANANA |--> 5};
      count = 14;
      @
      (*FruitBasket).count = 14;
   };
end
