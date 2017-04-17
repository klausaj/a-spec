#fileID<ZChan_as>

<DocumentInfo>
   docID     A_Spec_ZChan;
   docVer    00;
   docRev    a;
</DocumentInfo>

#import<toolkit.al>
#import<csp.al>

begin free SubscriberType
   SUBSCRIBER = logger | processor;
end

begin basic DataType
   DATA;
end

begin process ZChanDecl
   <Properties>
      LAYER_ID hidden;
   </Properties>

   proc PublishData: DATA;
   proc Logger;
   proc Processor;
   chan logData: DATA;
   chan processData: DATA;
where
end

#import<ZChan/ZChan.al>
