#fileID<Interrupt_al>

begin process InterruptedProc
where
   Application =
      ApplicationLoop /\
      exception -> display_error -> STOP;

   ApplicationLoop =
      business_logic -> ApplicationLoop;
end
