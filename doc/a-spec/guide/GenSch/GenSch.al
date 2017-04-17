#fileID<GenSch_al>

#import<toolkit.al>

begin free Free
   FRUIT = APPLE | ORANGE |
           PINEAPPLE | BANANA;
   CHEESE = CHEDDAR | SWISS |
            AMERICAN | COLBY;
end

begin gensch[X] GiftBasket
   item: X ---> int;
where
end

begin axdef GenSchAppl
   cheese: GiftBasket{[CHEESE]};
   fruit: GiftBasket{[FRUIT]};
where
end
