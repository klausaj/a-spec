#fileID<csp_al>

#import<toolkit.al>

begin process CPSEvents
   <Properties>
      LAYER_ID  csplib;
      A2TEX_XFM  check "\checkmark";
      A2TEX_XFM  tau "\tau";
   </Properties>

   chan check;
   chan tau;
where
end

begin type CSPTypes
   <Properties>
      LAYER_ID  csplib;
      A2TEX_XFM  CHAN "\mathrel{CHAN}";
      A2TEX_XFM  EVENT "\Sigma";
      A2TEX_XFM  EVENT_CHECK "\Sigma^{\checkmark}\!";
   </Properties>

   EVENT_CHECK = CSP_EVENT;
   EVENT = EVENT_CHECK diff setDisp{check};
   CHAN [X] = X >--> EVENT;
   CSP_REF = int;
end

begin axdef CSPAlphabets
   <Properties>
      LAYER_ID  csplib;
      A2TEX_XFM  alph "\alpha";
      A2TEX_XFM  alphcheck "\alpha^{\checkmark}\!";
   </Properties>

   func alph: PROCESS ---> pset EVENT;
   func alphcheck: PROCESS ---> pset EVENT_CHECK;
where
end

begin process CPSProcesses
   <Properties>
      LAYER_ID  csplib;
      A2TEX_XFM  RUN_CHECK "RUN^{\checkmark}\!";
      A2TEX_XFM  ENVx "ENV^{*}\!";
      A2TEX_XFM  ENVa "ENV^{\alpha}\!";
   </Properties>

   proc SKIP;
   proc STOP;
   proc DIVER;
   proc CHAOS: pset EVENT;
   proc RUN: pset EVENT;
   proc RUN_CHECK: pset EVENT;
   proc ENV: PROCESS;
   proc ENVx;
   proc ENVa: pset EVENT;
where
   SKIP = check -> STOP;
   STOP = []{A: pset EVENT; evt: EVENT; ? A = setDisp{}; evt in A; @ [evt] -> STOP};
   CHAOS(A: pset EVENT) = STOP |~| []{evt: EVENT; ? evt in A; @ [evt] -> CHAOS(A)};
   RUN(A: pset EVENT) = []{evt: EVENT; ? evt in A; @ [evt] -> RUN(A)};
   RUN_CHECK(A: pset EVENT) = []{evt: EVENT; ? evt in A; @ [evt] -> RUN(A)} [] SKIP;
   ENV(P: PROCESS) = RUN_CHECK(alph(P));
   ENVx = RUN_CHECK(EVENT);
   ENVa(A: pset EVENT) = RUN_CHECK(A);
   DIVER = DIVER;
end

begin axdef CSPRefInvalid
   <Properties>
      LAYER_ID  csplib;
   </Properties>

   INVALID_REF: CSP_REF;
where
   INVALID_REF = 0;
end


begin process ReferenceModel
   <Properties>
      LAYER_ID  csplib;
   </Properties>

   proc REFERENCE;
   proc REFERENCE_ASSIGN: int;
   chan refID: int;
where
   REFERENCE = REFERENCE_ASSIGN(1);
   REFERENCE_ASSIGN(nextID: int) = refID!nextID -> REFERENCE_ASSIGN(nextID + 1);
end

begin axdef TracesFunction
   func traces: PROCESS >--> pset(seq CSP_EVENT);
where
end
