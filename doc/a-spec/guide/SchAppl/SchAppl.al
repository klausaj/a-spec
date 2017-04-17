#fileID<SchAppl_al>

#import<toolkit.al>

begin schema FruitBasketRecurse
   [delta2] FruitBasket;
where
   exists{f: FRUIT; r: BOOL; ?
      *FruitBasket.fruit(f) > 0;
      @
      {*FruitBasket & schBind{type[?] = f}}
            FruitBasketTake
      {*FruitBasket['] & schBind{rslt[!] = r}};
   };

   if(count['] > 0) then
      {*FruitBasket[']}
            FruitBasketRecurse
      {*FruitBasket['2]};
   else
      {*FruitBasket[']}
            xi
      {*FruitBasket['2]};
   endif;
end
