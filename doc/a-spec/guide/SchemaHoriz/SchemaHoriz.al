#fileID<SchemaHoriz_al>

#import<toolkit.al>

begin type SchemaHoriz
   FruitBasket =
      schType{
         fruit: FRUIT ---> int;
         count: int;
         ?
         count =
            fruit(APPLE) +
            fruit(ORANGE) +
            fruit(PINEAPPLE) +
            fruit(BANANA);
      };
end
