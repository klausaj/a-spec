#fileID<ProcState_as>

<DocumentInfo>
   docID     A_Spec_ProcState;
   docVer    00;
   docRev    a;
</DocumentInfo>

#import<toolkit.al>
#import<csp.al>

begin process ProcStateDecl
   <Properties>
      LAYER_ID hidden;
   </Properties>

   proc Counter: nat;
   proc InitCounter;
   chan increment;
where
end

#import<ProcState/ProcState.al>
