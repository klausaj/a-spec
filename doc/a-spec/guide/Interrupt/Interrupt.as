#fileID<Interrupt_as>

<DocumentInfo>
   docID     A_Spec_Interrupt;
   docVer    00;
   docRev    a;
</DocumentInfo>

begin process InterruptDecl
   <Properties>
      LAYER_ID hidden;
   </Properties>

   proc Application;
   proc ApplicationLoop;
   chan business_logic;
   chan exception;
   chan display_error;
where
end

#import<csp.al>
#import<Interrupt/Interrupt.al>
