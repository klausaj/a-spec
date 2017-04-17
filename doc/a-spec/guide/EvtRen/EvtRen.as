#fileID<EvtRen_as>

<DocumentInfo>
   docID     A_Spec_EvtRen;
   docVer    00;
   docRev    a;
</DocumentInfo>

begin process EvtRenDecl
   <Properties>
      LAYER_ID hidden;
   </Properties>

   proc VendingMachine;
   chan insertCoin;
   chan takeCandy;
   chan takeSoda;
where
end

#import<csp.al>
#import<EvtRen/EvtRen.al>
