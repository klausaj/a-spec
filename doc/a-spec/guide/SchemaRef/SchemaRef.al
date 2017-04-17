#fileID<SchemaRef_al>

#import<toolkit.al>

begin schema FruitBasketSized
   FruitBasket;
where
   fruit(BANANA) <= 10;
   count < 20;
end

begin const SizeConstraint
   forAll{FruitBasketSized; ? @
      fruit(APPLE) < 20;
      fruit(ORANGE) < 20;
      fruit(PINEAPPLE) < 20;
      fruit(BANANA) < 20;
   };
end
