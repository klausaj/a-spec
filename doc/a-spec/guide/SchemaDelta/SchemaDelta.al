#fileID<SchemaDelta_al>

#import<toolkit.al>

begin schema FruitBasketDelta
   [delta] FruitBasket;
where
   fruit(APPLE) = 4;
   fruit(ORANGE) = 4;
   fruit(PINEAPPLE) = 1;
   fruit(BANANA) = 5;
   count = 14;

   fruit['](APPLE) = 3;
   fruit['](ORANGE) = 3;
   fruit['](PINEAPPLE) = 0;
   fruit['](BANANA) = 4;
   count['] = 10;
end
