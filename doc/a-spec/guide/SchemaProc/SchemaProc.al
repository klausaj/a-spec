#fileID<SchemaProc_al>

#import<toolkit.al>

begin schema FruitBasketTake
   FruitBasket;
   FruitBasket['];
   type[?]: FRUIT;
   rslt[!]: BOOL;
where
   if(fruit(type[?]) > 0) then
      fruit['](type[?]) =
            fruit(type[?]) - 1;
      setDisp{type[?]} ndres fruit['] =
         setDisp{type[?]} ndres fruit;

      rslt[!] = TRUE;
   else
      fruit['] = fruit;
      rslt[!] = FALSE;
   endif;
end
