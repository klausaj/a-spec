#fileID<SchBind_al>

#import<toolkit.al>

begin axdef FruitBasketBind
   someBasket: FruitBasket;
where
   someBasket.fruit(APPLE) = 4;
   someBasket.fruit(ORANGE) = 4;
   someBasket.fruit(PINEAPPLE) = 1;
   someBasket.fruit(BANANA) = 5;

   someBasket.count = 14;
end
