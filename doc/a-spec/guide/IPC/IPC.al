#fileID<IPC_al>

begin process QueueProcess
where
   Queue =
      lock_prod -> queue_put ->
         release_prod -> Queue []
      (lock_proc ->
         (queue_avail ->
            queue_take -> SKIP |~|
         queue_empty -> SKIP) pseq
      release_proc -> Queue);

   Producer =
      lock_prod -> queue_put ->
      release_prod -> Producer;

   Consumer =
      lock_proc ->
         (queue_avail -> queue_take ->
         release_proc -> consume ->
         Consumer []
         queue_empty -> release_proc ->
         Consumer);

   Application =
      Producer || Consumer || Queue;
end
