#fileID<AxDef_as>

<DocumentInfo>
   docID     A_Spec_AxDef;
   docVer    00;
   docRev    a;
</DocumentInfo>

begin free Free
   <Properties>
      LAYER_ID hidden;
   </Properties>

   FRUIT = APPLE | ORANGE |
           PINEAPPLE | BANANA;
end

begin type TypeDef
   <Properties>
      LAYER_ID hidden;
   </Properties>

   BASKET = seq FRUIT;
end

<Directive>
   <Properties>
      A2TEX_XFM  contains "\mathrel{contains}";
      A2TEX_XFM  returnTo "\mathrel{returnTo}";
   </Properties>

   PLACE_HOLDER;
</Directive>

#import<AxDef/AxDef.al>
