#fileID<ReplIFPar_al>

begin axdef ApplicationInterface
   appIF: pset EVENT;
where
   appIF = setDisp{system_shutdown};
end

begin process ReplicatedIFParallel
where
   Application(uid: nat) =
      handle_request.uid -> app_process ->
         Application(uid) []
      system_shutdown -> SKIP;

   System =
      [| appIF |]{uid: nat; ?
         uid < 100;
         @
         Application(uid)
      };
end
