#fileID<ZProcParam_as>

<DocumentInfo>
   docID     A_Spec_ZProcParam;
   docVer    00;
   docRev    a;
</DocumentInfo>

#import<toolkit.al>
#import<csp.al>

begin process ZProcParamDecl
   <Properties>
      LAYER_ID hidden;
   </Properties>

   proc FactorialImpl: cross{nat1, nat};
   proc Factorial: nat1;
   chan result: int;
where
end

#import<ZProcParam/ZProcParam.al>
