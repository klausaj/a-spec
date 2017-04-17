#fileID<LetExpr_al>

#import<toolkit.al>

begin axdef LetExpr
   func parser: BYTE_ARRAY ---> BYTE_ARRAY;
where
   forAll{arr: BYTE_ARRAY; ? @
      parser(arr) =
         let{len = arr(0); @
            if(len = size(arr)) then
               tail(arr)
            else
               eseq UINT8
            endif
         };
   };
end
