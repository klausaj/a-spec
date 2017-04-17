#fileID<Annotation_al>

#import<toolkit.al>

begin schema FruitBasketRecurse
   [delta2] FruitBasket;
where
   exists{f: FRUIT; r: BOOL; ?
      fruit(f) > 0;
      r = TRUE; @[\bcomment{Return $TRUE$}]
      @
      {*FruitBasket & schBind{type[?] = f}}
            FruitBasketTake
      {*FruitBasket['] & schBind{rslt[!] = r}};
   };

   if(count['] > 0) then
      @[\note*{Basket is not empty}]
      {*FruitBasket[']}
            FruitBasketRecurse
      {*FruitBasket['2]};
   else
      @[\note*{Basket is empty}]
      {*FruitBasket[']}
            xi
      {*FruitBasket['2]};
   endif;
end
