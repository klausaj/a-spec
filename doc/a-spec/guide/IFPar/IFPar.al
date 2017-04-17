#fileID<IFPar_al>

begin axdef AppIFConst
   appIF: pset EVENT;
where
   appIF = setDisp{system_shutdown};
end

begin process InterfaceParallel
where
   System =
      (Application [| appIF |] Application);

   Application =
      app_process -> Application []
      system_shutdown -> SKIP;
end
