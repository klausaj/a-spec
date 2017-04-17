#fileID<ReplInterleave_as>

<DocumentInfo>
   docID     A_Spec_ReplInterleave;
   docVer    00;
   docRev    a;
</DocumentInfo>

#import<toolkit.al>
#import<csp.al>

begin process ReplInterleaveDecl
   <Properties>
      LAYER_ID hidden;
   </Properties>

   proc System;
   proc Application: nat;
   chan handle_request: nat;
   chan process_request;
where
end

#import<ReplInterleave/ReplInterleave.al>
