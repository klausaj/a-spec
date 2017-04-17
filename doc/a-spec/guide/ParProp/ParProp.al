#fileID<ParProp_al>

#import<toolkit.al>

begin gensch[X] GiftBasket
   <Properties>
      LAYER_ID gift_basket;
   </Properties>

   item: X ---> int;
where
end

<Description>
   <Properties>
      LAYER_ID gift_basket;
   </Properties>

<Text>
A gift basket consits of a mapping from
each type of gift $X$ to an integer
representing the number of that type of
gift present in the basket.
</Text>
</Description>

<Description>
   <Properties>
      LAYER_ID gift_basket_tbd;
   </Properties>

<Text>
Note: A total count function should be
added to count the total number of
gifts of present in the basket.
</Text>
</Description>
