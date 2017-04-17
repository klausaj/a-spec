#fileID<ParComp_al>

begin process ParComp
where
   CP1 = e1 -> CP1;
   CP2 = e1 -> e2 -> CP2;
   P1 = CP1 || CP2;
end
