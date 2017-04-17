#fileID<LayerID_al>

#import<toolkit.al>

begin free Fruit
   <Properties>
      LAYER_ID fruit;
   </Properties>

   FRUIT = APPLE | ORANGE |
           PINEAPPLE | BANANA;
end

begin schema FruitBasket
   <Properties>
      LAYER_ID basket;
   </Properties>

   fruit: FRUIT ---> int;
   count: int;
where
   count = fruit(APPLE) +
           fruit(ORANGE) +
           fruit(PINEAPPLE) +
           fruit(BANANA);
end

begin schema FruitBasketInit
   <Properties>
      LAYER_ID init;
   </Properties>

   FruitBasket;
where
   fruit(APPLE) = 4;
   fruit(ORANGE) = 4;
   fruit(PINEAPPLE) = 1;
   fruit(BANANA) = 5;
end
