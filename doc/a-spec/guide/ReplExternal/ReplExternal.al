#fileID<ReplExternal_al>

begin process ReplicatedExternal
where
   List(data: seq GEN_DATA) =
      []{index: nat; ?
         index < size(data);
         @
         get.index![data(index)] ->
            List(data)
      } []
      add?newData ->
         List(data cat seqDisp{newData});
end
