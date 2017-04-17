#fileID<ProcChan_al>

begin process ProcChan
where
   NotHungry = SKIP;

   Customer1 =
      insert_coin ->
      select_candy.chocolate ->
      take_candy.chocolate ->
      NotHungry;

   Customer2 =
      insert_coin ->
      select_candy.toffee ->
      take_candy.toffee ->
      NotHungry;

   VendingMachine =
      insert_coin ->
      select_candy?type ->
      take_candy!type ->
      VendingMachine;
end
