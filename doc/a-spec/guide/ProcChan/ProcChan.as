#fileID<ProcChan_as>

<DocumentInfo>
   docID     A_Spec_ProcChan;
   docVer    00;
   docRev    a;
</DocumentInfo>

begin free CandyDecl
   <Properties>
      LAYER_ID hidden;
   </Properties>

   CANDY = chocolate | toffee | cookie;
end

begin process ProcChanDecl
   <Properties>
      LAYER_ID hidden;
   </Properties>

   proc NotHungry;
   proc Customer1;
   proc Customer2;
   proc VendingMachine;
   chan insert_coin;
   chan select_candy: CANDY;
   chan take_candy: CANDY;
where
end

#import<csp.al>
#import<ProcChan/ProcChan.al>
