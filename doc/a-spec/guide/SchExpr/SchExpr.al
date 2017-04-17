#fileID<SchProcAppl_al>

#import<toolkit.al>

begin schema FruitBasketTake
   [delta] FruitBasket;
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

begin schema FruitBasketRecurse
   [delta2] FruitBasket;
where
   exists{cmd: FruitBasketTake; r: BOOL; ?
      zpre(cmd zhide{type[?]}) =
         *FruitBasket;

      exists{f: FRUIT; ? fruit(f) > 0; @
         cmd.type[?] = f;
      };
      @
      *FruitBasket['] =
         zpost(cmd zhide{rslt[!]});
      cmd.rslt[!] = r;
   };

   if(count['] > 0) then
      exists{r: FruitBasketRecurse; ?
         zpre(r) = zunp(*FruitBasket[']);
         @
         *FruitBasket['2] = zpost(r);
      };
   else
      zunp(*FruitBasket['2]) =
         zunp(*FruitBasket[']);
   endif;
end
