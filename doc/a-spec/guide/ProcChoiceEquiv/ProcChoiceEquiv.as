#fileID<ProcChoiceEquiv_as>

<DocumentInfo>
   docID     A_Spec_ProcChoiceEquiv;
   docVer    00;
   docRev    a;
</DocumentInfo>

begin process ProcChoiceEquivDecl
   <Properties>
      LAYER_ID hidden;
   </Properties>

   proc ServerFarm;
   proc WebServer;
   proc FTPServer;
   proc Server1;
   proc Server2;
   chan web_request;
   chan ftp_request;
   chan handle_request;
where
end

#import<csp.al>
#import<ProcChoiceEquiv/ProcChoiceEquiv.al>
