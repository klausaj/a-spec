#fileID<ZProc_al>

begin process Subscribers
where
   Logger =
      logData?data -> Logger;

   Processor =
      processData?data -> Processor;
end

begin process Publisher
where
   PublishData(data: DATA) =
      logData.data ->
      processData.data ->
      SKIP;
end

begin const Assertions
   !exists{evt: EVENT; ? @
      (evt in alph(Logger)) &&
      (evt in alph(Processor));
   };

   check !in alphcheck(Logger);
   check !in alphcheck(Processor);
end
