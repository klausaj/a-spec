#fileID<ZChan_al>

begin process Subscribers
where
   Logger =
      logData?data -> Logger;

   Processor =
      processData?data -> Processor;
end

begin axdef CompositeChannel
   func compChannel:
      cross{SUBSCRIBER, DATA} >--> EVENT;
where
   forAll{data: DATA; ? @
      compChannel(logger, data) =
         logData(data);

      compChannel(processor, data) =
         processData(data);
   };
end

begin process Publisher
where
   PublishData(data: DATA) =
      [compChannel].logger.data ->
      [compChannel].processor.data ->
      SKIP;
end
