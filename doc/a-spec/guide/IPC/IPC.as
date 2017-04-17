#fileID<IPC_as>

<DocumentInfo>
   docID     A_Spec_IPC;
   docVer    00;
   docRev    a;
</DocumentInfo>

begin process IPCDecl
   <Properties>
      LAYER_ID hidden;
   </Properties>

   proc Producer;
   proc Consumer;
   proc Queue;
   proc Application;
   chan lock_prod;
   chan release_prod;
   chan lock_proc;
   chan release_proc;
   chan queue_put;
   chan queue_empty;
   chan queue_avail;
   chan queue_take;
   chan consume;
where
end

#import<csp.al>
#import<IPC/IPC.al>
