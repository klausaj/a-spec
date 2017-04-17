#fileID<IntQueue_al>

begin axdef AxDef
   <Properties>
      LAYER_ID hidden;
   </Properties>

   MAX_QUEUE_SIZE: int;
where
end

begin type TypeDef
   <Properties>
      LAYER_ID hidden;
   </Properties>

   QUEUE =
      setComp{s: seq int; ?
         size(s) < MAX_QUEUE_SIZE;
         @
         s
      };
end
