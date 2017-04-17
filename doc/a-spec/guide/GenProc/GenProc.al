#fileID<GenProc_al>

begin process GenMapDef
   proc[X, Y] GenMap: X --|> Y;

   chan[X, Y] mapGet: cross{X, Y};
   chan[X, Y] mapPut: cross{X, Y};
where
   GenMap[X, Y](map: X --|> Y) =
      []{key: X; ? key in dom(map); @
         mapGet{[X, Y]}.key![map(key)] ->
         GenMap{[X, Y]}(map)
      } []
      mapPut{[X, Y]}?key?value ->
         let{map['] =
            map over
               setDisp{key |--> value};
            @
            GenMap{[X, Y]}(map['])
         };
end

begin process TranslateDef
   proc Translate = GenMap{[int, string]};

   chan getText = mapGet{[int, string]};
   chan setText = mapPut{[int, string]};
where
end
