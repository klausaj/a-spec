#fileID<ProcDecl_al>

begin process ProcDecl
   proc BasicProc;
   proc ParamProc: cross{int, string};
   chan BasicChan;
   chan ParamChan: int;
where
   BasicProc = BasicChan -> BasicProc;

   ParamProc(x: int, s: string) =
      ParamChan?newX ->
      ParamProc(newX, s);
end
