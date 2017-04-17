#fileID<ProcEnv_al>

begin process QueueProcess
   proc Queue: seq BYTE_ARRAY;
   chan queue_take: BYTE_ARRAY;
   chan queue_put: BYTE_ARRAY;
   chan queue_empty: BOOL;
where
   Queue(list: seq BYTE_ARRAY) =
      queue_put?data ->
         Queue(list cat seqDisp{data}) []

      if(size(list) > 0) then
         queue_empty.FALSE ->
            Queue(list) []
         queue_take.[list(0)] ->
            Queue(tail(list))
      else
         queue_empty.TRUE ->
            Queue(list)
      endif;
end
