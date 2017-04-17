#fileID<LetProc_as>

<DocumentInfo>
   docID     A_Spec_LetProc;
   docVer    00;
   docRev    a;
</DocumentInfo>

begin process LetProcDecl
   <Properties>
      LAYER_ID hidden;
   </Properties>

   proc LocalDouble;
   proc ReplDouble;

   chan input: int;
   chan result: int;
where
end

#import<csp.al>
#import<LetProc/LetProc.al>
