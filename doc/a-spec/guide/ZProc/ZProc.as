#fileID<ZProc_as>

<DocumentInfo>
   docID     A_Spec_ZProc;
   docVer    00;
   docRev    a;
</DocumentInfo>

#import<toolkit.al>
#import<csp.al>

begin basic DataType
   <Properties>
      LAYER_ID hidden;
   </Properties>

   DATA;
end

begin process ZProcDecl
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

#import<ZProc/ZProc.al>
