#fileID<EvtHide_al>

begin process EventHide
where
   P1 = e1 -> e2 -> STOP;
   P2 = P1 phide setDisp{e2};
end

begin const EventPredicates
   alph(P1) = setDisp{e1, e2};
   alph(P2) = setDisp{e1};
end
