#fileID<ReplIFPar_as>

<DocumentInfo>
   docID     A_Spec_ReplIFPar;
   docVer    00;
   docRev    a;
</DocumentInfo>

#import<toolkit.al>
#import<csp.al>

begin process ReplIFParDecl
   <Properties>
      LAYER_ID hidden;
   </Properties>

   proc System;
   proc Application: nat;

   chan handle_request: nat;
   chan app_process;
   chan system_shutdown;
where
end

#import<ReplIFPar/ReplIFPar.al>
