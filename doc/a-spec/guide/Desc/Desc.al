#fileID<Desc_al>

#import<toolkit.al>

begin schema FruitBasketRecurse
   [delta2] FruitBasket;
where
   exists{f: FRUIT; r: BOOL; ?
      fruit(f) > 0;
      r = TRUE;
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

<Description>
<Text>
$FruitBasketRecurse$ uses $FruitBasketTake$ to
remove an arbitrary piece of fruit from the
basket.  If the basket is not empty after this
operation, the process schema is recursively
called.  If the basket is empty, no state
change is made and the recursive calling of the
process schema is terminated.
</Text>
</Description>
