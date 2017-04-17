#fileID<ReplParallel_al>

begin axdef GridConstants
   COMPUTER_COUNT: nat;
where
   COMPUTER_COUNT = 50;
end

begin process ReplicatedParallel
where
   GridComputing =
      ||{cid: nat; ?
         cid < COMPUTER_COUNT;
         @
         Computer(cid)
      };
end
