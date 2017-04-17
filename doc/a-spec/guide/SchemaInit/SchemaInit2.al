#fileID<SchemaInit_al>

#import<toolkit.al>

begin schema FruitBasketInit
   <Properties>
      LAYER_ID hidden;
   </Properties>

   FruitBasket;
where
   fruit(APPLE) = 4;
   fruit(ORANGE) = 4;
   fruit(PINEAPPLE) = 1;
   fruit(BANANA) = 5;
end
