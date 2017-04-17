#fileID<SchemaMultiDecor_al>

#import<toolkit.al>

begin schema FruitBasketMultiDecor
   [delta2] FruitBasket;
where
   fruit =
      setDisp{APPLE |--> 4, ORANGE |--> 4,
      PINEAPPLE |--> 1, BANANA |--> 5};
   count = 14;

   fruit['] =
      setDisp{APPLE |--> 3, ORANGE |--> 3,
      PINEAPPLE |--> 0, BANANA |--> 4};
   count['] = 10;

   fruit['2] =
      setDisp{APPLE |--> 2, ORANGE |--> 2,
      PINEAPPLE |--> 0, BANANA |--> 3};
   count['2] = 7;
end
