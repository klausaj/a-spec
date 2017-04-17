#fileID<IFPar_as>

<DocumentInfo>
   docID     A_Spec_IFPar;
   docVer    00;
   docRev    a;
</DocumentInfo>

begin process IFParDecl
   <Properties>
      LAYER_ID hidden;
   </Properties>

   proc System;
   proc Application;

   chan app_process;
   chan system_shutdown;
where
end

#import<csp.al>
#import<IFPar/IFPar.al>
