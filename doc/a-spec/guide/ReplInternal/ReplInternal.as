#fileID<ReplInternal_as>

<DocumentInfo>
   docID     A_Spec_ReplInternal;
   docVer    00;
   docRev    a;
</DocumentInfo>

#import<toolkit.al>
#import<csp.al>

begin process ReplInternalDecl
   <Properties>
      LAYER_ID hidden;
   </Properties>

   proc Random;
   chan request_rand;
   chan return_rand: UINT32;
where
end

#import<ReplInternal/ReplInternal.al>
