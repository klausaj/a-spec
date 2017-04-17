#fileID<ProcExpr_al>

begin process ProcExpr
where
   NotHungry = SKIP;

   Customer =
      insert_coin -> take_candy ->
      NotHungry;

   VendingMachine =
      insert_coin -> take_candy ->
      VendingMachine;
end
