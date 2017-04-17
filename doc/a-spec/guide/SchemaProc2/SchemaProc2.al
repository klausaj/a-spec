#fileID<SchemaProc2_al>

#import<toolkit.al>

begin schema FruitBasketExchange
   [delta2] FruitBasket;
   return[?]: FRUIT;
   take[?]: FRUIT;
   rslt[!]: BOOL;
where
   fruit['](return[?]) =
         fruit(return[?]) + 1;
   setDisp{return[?]} ndres fruit['] =
      setDisp{return[?]} ndres fruit;

   if(fruit['](take[?]) > 0) then
      fruit['2](take[?]) =
            fruit['](take[?]) - 1;
      setDisp{take[?]} ndres fruit['2] =
         setDisp{take[?]} ndres fruit['];

      rslt[!] = TRUE;
   else
      fruit['2] = fruit['];
      rslt[!] = FALSE;
   endif;
end
