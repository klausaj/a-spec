#fileID<ProcExpr_as>

<DocumentInfo>
   docID     A_Spec_ProcExpr;
   docVer    00;
   docRev    a;
</DocumentInfo>

begin process ProcExprDecl
   <Properties>
      LAYER_ID hidden;
   </Properties>

   proc NotHungry;
   proc Customer;
   proc VendingMachine;
   chan insert_coin;
   chan take_candy;
where
end

#import<csp.al>
#import<ProcExpr/ProcExpr.al>
