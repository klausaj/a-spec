#fileID<ReplExternal_as>

<DocumentInfo>
   docID     A_Spec_ReplExternal;
   docVer    00;
   docRev    a;
</DocumentInfo>

#import<toolkit.al>
#import<csp.al>

begin process ReplExternalDecl
   <Properties>
      LAYER_ID hidden;
   </Properties>

   proc List: seq GEN_DATA;
   chan get: cross{nat, GEN_DATA};
   chan add: GEN_DATA;
where
end

#import<ReplExternal/ReplExternal.al>
