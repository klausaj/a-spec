#fileID<ProcAlph_al>

begin process ProcAlph
where
   P1 = e1 -> e2 -> STOP;
   P2 = e3?someInt -> STOP;
   P3 = STOP;
end

begin const EventPredicates
   check !in EVENT;
   EVENT_CHECK = EVENT uni setDisp{check};

   e1 in EVENT;
   e2 in EVENT;
   ran(e3) sub EVENT;

   alph(P1) = setDisp{e1, e2};
   alph(P2) = setComp{x: int; ? @ e3(x)};
   alph(P3) = setDisp{};
end
