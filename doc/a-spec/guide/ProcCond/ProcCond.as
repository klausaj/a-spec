#fileID<ProcCond_as>

<DocumentInfo>
   docID     A_Spec_ProcCond;
   docVer    00;
   docRev    a;
</DocumentInfo>

#import<toolkit.al>
#import<csp.al>

begin process ProcCondDecl
   <Properties>
      LAYER_ID hidden;
   </Properties>

   proc Counter: nat;
   proc InitCounter;
   chan increment;
where
end

#import<ProcCond/ProcCond.al>
