#fileID<LetProc_al>

begin process LetProc
where
   LocalDouble =
      input?num ->
      let{output = num * 2; @
         result!output -> LocalDouble
      };

   ReplDouble =
      input?num ->
      |~|{output: int; ?
         output = num * 2;
         @
         result!output -> ReplDouble
      };
end
