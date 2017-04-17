#fileID<Schema_al>

#import<toolkit.al>

begin schema FruitBasket
   <Properties>
      LAYER_ID hidden;
   </Properties>

   fruit: FRUIT ---> int;
   count: int;
where
   count = fruit(APPLE) +
           fruit(ORANGE) +
           fruit(PINEAPPLE) +
           fruit(BANANA);
end
