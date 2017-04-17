#fileID<ProcCond_al>

begin axdef MaxCount
   MAX_COUNT: nat;
where
   MAX_COUNT = 100;
end

begin process ProcCond
where
   Counter(count: nat) =
      increment ->
         if(count = MAX_COUNT) then
            Counter(0)
         else
            Counter(count + 1)
         endif;

   InitCounter = Counter(0);
end
