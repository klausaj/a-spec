#fileID<IntQueue_al>

begin axdef AxDef
   MAX_QUEUE_SIZE: int;
where
end

begin type TypeDef
   QUEUE =
      setComp{s: seq int; ?
         size(s) < MAX_QUEUE_SIZE;
         @
         s
      };
end
