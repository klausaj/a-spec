#fileID<ProcState_al>

begin process ProcState
where
   Counter(count: nat) =
      increment -> Counter(count + 1);

   InitCounter = Counter(0);
end
