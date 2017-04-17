#fileID<EvtRen_al>

begin axdef RenamingFunc
   func sodaFunc: EVENT --|> EVENT;
where
   sodaFunc =
      setDisp{takeCandy |--> takeSoda};
end

begin process VendingMachineDef
where
   VendingMachine =
      insertCoin -> takeCandy ->
      VendingMachine;
end

begin process SodaMachineDef
   proc SodaMachine =
      VendingMachine pren sodaFunc;
where
end
