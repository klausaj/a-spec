#fileID<ReplInterleave_al>

begin process ReplicatedInterleaving
where
   Application(uid: nat) =
      handle_request.uid ->
      process_request -> Application(uid);

   System =
      |||{uid: nat; ?
         uid < 100;
         @
         Application(uid)
      };
end
