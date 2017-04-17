#fileID<ReplInternal_al>

begin process ReplicatedInternal
where
   Random =
      request_rand ->
      |~|{num: UINT32; ? @
         return_rand!num -> Random
      };
end
