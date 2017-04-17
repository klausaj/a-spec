#fileID<ProcChoice_as>

<DocumentInfo>
   docID     A_Spec_ProcChoice;
   docVer    00;
   docRev    a;
</DocumentInfo>

begin process ProcChoiceDecl
   <Properties>
      LAYER_ID hidden;
   </Properties>

   proc ServerFarm;
   proc Server1;
   proc Server2;
   proc WebServer;
   proc FTPServer;
   chan web_request;
   chan ftp_request;
   chan handle_request;
where
end

#import<csp.al>
#import<ProcChoice/ProcChoice.al>
