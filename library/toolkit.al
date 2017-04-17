#fileID<toolkit_al>

begin type EmptySet
   <Properties>
      LAYER_ID  toolkitlib;
      A2TEX_XFM  eset "\textbf{eset}";
   </Properties>

   eset [T1] = mu{s: pset T1; ? s = setDisp{}; @ s};
end

begin type BiRel
   <Properties>
      LAYER_ID  toolkitlib;
      A2TEX_XFM  <--> \rel;
   </Properties>

   [X] <--> [Y] = pset(cross{X, Y});
end

begin gendef[X, Y] Maplet
   <Properties>
      LAYER_ID  toolkitlib;
      A2TEX_XFM  |--> \map;
   </Properties>

   oper bin4 |-->: (cross{X, Y}) <--> (cross{X, Y});
where
   forAll{x: X; y: Y; ? @
      x |--> y = (x, y);
   };
end

begin type ParFun
   <Properties>
      LAYER_ID  toolkitlib;
      A2TEX_XFM  --|> \pfun;
   </Properties>

   [X] --|> [Y] = setComp{f: X <--> Y; ?
                     forAll{x: X; y1: Y; y2: Y; ? @ (((x |--> y1) in f) && ((x |--> y2) in f)) ==> (y1 = y2) };
                     @ f};
end

begin type TotFun
   <Properties>
      LAYER_ID  toolkitlib;
      A2TEX_XFM  ---> \tfun;
   </Properties>

   [X] ---> [Y] = setComp{f: X --|> Y; ? forAll{x: X; ? @ f(x) in Y}; @ f};
end

begin gendef[X] SetRelations
   <Properties>
      LAYER_ID  toolkitlib;
      A2TEX_XFM  subeq \subseteq;
      A2TEX_XFM  sub   \subset;
   </Properties>

   rel bin4 subeq: (pset X) <--> (pset X);
   rel bin4 sub: (pset X) <--> (pset X);
where
   forAll{S: pset X; T: pset X; ? @
      (S subeq T) <=> forAll{x: X; ? @ (x in S) ==> (x in T)};
      (S sub T) <=> ((S subeq T) && (S != T));
   };
end

begin type SetTypes
   <Properties>
      LAYER_ID  toolkitlib;
      A2TEX_XFM  pset1 \psetone;
   </Properties>

   pset1 [X] = setComp{S: pset X; ? S != setDisp{}; @ S};
end

begin gendef[X] SetOperators
   <Properties>
      LAYER_ID  toolkitlib;
      A2TEX_XFM  uni \uni;
      A2TEX_XFM  diff \setminus;
      A2TEX_XFM  inter \inter;
   </Properties>

   oper bin5 uni: cross{pset X, pset X} ---> pset X;
   oper bin5 diff: cross{pset X, pset X} ---> pset X;
   oper bin6 inter: cross{pset X, pset X} ---> pset X;
   oper pre4 choose: (pset1 X) ---> X;
where
   forAll{S: pset X; T: pset X; ? @
      S uni T   = setComp{x: X; ? (x in S) || (x in T); @ x};
      S diff T  = setComp{x: X; ? (x in S) && (x !in T); @ x};
      S inter T = setComp{x: X; ? (x in S) && (x in T); @ x};
   };

   forAll{S: pset1 X; ? @
      exists{x: X; ? x in S; @
         choose S = x;
      };
   };
end

begin gendef[X] GenSetOper
   <Properties>
      LAYER_ID  toolkitlib;
      A2TEX_XFM  guni \duni;
      A2TEX_XFM  ginter \dinter;
   </Properties>

   func guni: (pset pset X) ---> pset X;
   func ginter: (pset pset X) ---> pset X;
where
   forAll{A: pset(pset (X)); ? @
      guni(A)   = setComp{x: X; ? exists{S: A; ? @ x in S} @ x};
      ginter(A) = setComp{x: X; ? forAll{S: A; ? @ x in S} @ x};
   };
end

begin gendef[X, Y] FirstSecond
   <Properties>
      LAYER_ID  toolkitlib;
      A2TEX_XFM  first \first;
      A2TEX_XFM  second \second;
   </Properties>

   func first: cross{X, Y} ---> X;
   func second: cross{X, Y} ---> Y;
where
   forAll{x: X; y: Y; ? @
      first(x, y)  = x;
      second(x, y) = y;
   };
end

begin gendef[X, Y] DomRan
   <Properties>
      LAYER_ID  toolkitlib;
      A2TEX_XFM  dom \dom;
      A2TEX_XFM  ran \ran;
   </Properties>

   func dom: (X <--> Y) ---> pset X;
   func ran: (X <--> Y) ---> pset Y;
where
   forAll{R: X <--> Y; ? @
      dom(R) = setComp{x: X; y: Y; ? (x, y) in R; @ x};
      ran(R) = setComp{x: X; y: Y; ? (x, y) in R; @ y};
   };
end

begin type IDRel
   <Properties>
      LAYER_ID  toolkitlib;
      A2TEX_XFM  id \id;
   </Properties>

   id [X] = setComp{x: X; ? @ x |--> x};
end

begin gendef[X, Y, Z] RelComp
   <Properties>
      LAYER_ID  toolkitlib;
      A2TEX_XFM  rcomp \cmp;
      A2TEX_XFM  rrcomp \fcmp;
   </Properties>

   oper bin6 rcomp: cross{X <--> Y, Y <--> Z} ---> (X <--> Z);
   oper bin6 rrcomp: cross{Y <--> Z, X <--> Y} ---> (X <--> Z);
where
   forAll{Q: X <--> Y; R: Y <--> Z; ? @
      Q rcomp R  = setComp{x: X; y: Y; z: Z; ? (x, y) in Q; (y, z) in R; @ x |--> z};
      R rrcomp Q = Q rcomp R;
   };
end

begin gendef[X,Y] DresRres
   <Properties>
      LAYER_ID  toolkitlib;
      A2TEX_XFM  dres \dres;
      A2TEX_XFM  ndres \ndres;
      A2TEX_XFM  rres \rres;
      A2TEX_XFM  nrres \nrres;
   </Properties>

   oper bin6 dres: cross{pset X, X <--> Y} ---> (X <--> Y);
   oper bin6 ndres: cross{pset X, X <--> Y} ---> (X <--> Y);
   oper bin6 rres: cross{X <--> Y, pset Y} ---> (X <--> Y);
   oper bin6 nrres: cross{X <--> Y, pset Y} ---> (X <--> Y);
where
   forAll{S: pset X; R: X <--> Y; ? @
      S dres R  = setComp{x: X; y: Y; ? x in S; (x, y) in R; @ (x, y)};
      S ndres R = setComp{x: X; y: Y; ? x !in S; (x, y) in R; @ (x, y)};
   };
   forAll{R: X <--> Y; T: pset Y; ? @
      R rres T = setComp{x: X; y: Y; ? y in T; (x, y) in R; @ (x, y)};
      R nrres T = setComp{x: X; y: Y; ? y !in T; (x, y) in R; @ (x, y)};
   };
end

begin gendef[X, Y] RelInv
   <Properties>
      LAYER_ID  toolkitlib;
      A2TEX_XFM  inv \inv;
   </Properties>

   func inv: (X <--> Y) ---> (Y <--> X);
where
   forAll{R: X <--> Y; ? @
      inv(R) = setComp{x: X; y: Y; ? (x, y) in R; @ y |--> x};
   };
end

begin gendef[X, Y] RelImg
   <Properties>
      LAYER_ID  toolkitlib;
      A2TEX_XFM  rimg \relimg;
   </Properties>

   oper bin6 rimg: cross{X <--> Y, pset X} ---> pset Y;
where
   forAll{R: X <--> Y; S: pset X; ? @
      R rimg S = setComp{x: X; y: Y; ? (x, y) in R; x in S; @ y};
   };
end

begin gendef[X, Y] Overriding
   <Properties>
      LAYER_ID  toolkitlib;
      A2TEX_XFM  over \fovr;
   </Properties>

   oper bin5 over: cross{X <--> Y, X <--> Y} ---> (X <--> Y);
where
   forAll{Q: X <--> Y; R: X <--> Y; ? @
      (Q over R) = ((dom(R) ndres Q) uni R); };
end

begin type ParInj
   <Properties>
      LAYER_ID  toolkitlib;
      A2TEX_XFM  >-|> \pinj;
   </Properties>

   [X] >-|> [Y] = setComp{f: X --|> Y; ?
                     forAll{x1: dom(f); x2: dom(f); ? @ (f(x1) = f(x2)) ==> (x1 = x2)};
                     @ f};
end

begin type TotInj
   <Properties>
      LAYER_ID  toolkitlib;
      A2TEX_XFM  >--> \tinj;
   </Properties>

   [X] >--> [Y] = (X >-|> Y) inter (X ---> Y);
end

begin type ParSur
   <Properties>
      LAYER_ID  toolkitlib;
      A2TEX_XFM  -|>> \psur;
   </Properties>

   [X] -|>> [Y] = setComp{f: X --|> Y; ? ran(f) = Y; @ f};
end

begin type TotSur
   <Properties>
      LAYER_ID  toolkitlib;
      A2TEX_XFM  -->> \tsur;
   </Properties>

   [X] -->> [Y] = (X -|>> Y) inter (X ---> Y);
end

begin type Biject
   <Properties>
      LAYER_ID  toolkitlib;
      A2TEX_XFM  >->> \bij;
   </Properties>

   [X] >->> [Y] = (X -->> Y) inter (X >--> Y);
end

begin type Natural
   <Properties>
      LAYER_ID  toolkitlib;
      A2TEX_XFM  nat \nat;
      A2TEX_XFM  nat1 \natone;
   </Properties>

   nat  = setComp{x: int; ? x >= 0; @ x};
   nat1 = setComp{x: int; ? x >= 1; @ x};
end

begin gendef[X] DisPart
   <Properties>
      LAYER_ID  toolkitlib;
      A2TEX_XFM  disjoint \disjoint;
      A2TEX_XFM  partitions \partitions;
   </Properties>

   bool disjoint: pset(pset X);
   rel bin4 partitions: (pset pset X) <--> (pset X);
where
   forAll{A: pset(pset X); ? @
      disjoint(A) <=> forAll{i: pset X; j: pset X; ?
                         i in A; j in A; i != j; @
                         (i inter j) = setDisp{};};
   };
   forAll{A: pset(pset X); T: pset X; ? @
      (A partitions T) <=> (disjoint(A) && (guni(A) = T));
   };
end

begin type FiniteSets
   <Properties>
      LAYER_ID  toolkitlib;
      A2TEX_XFM  fset \fset;
      A2TEX_XFM  fset1 \fsetone;
   </Properties>

   fset [X1]  = setComp{S: pset X1; ?
                   exists{n: nat; ? @ exists{f: (1..n) ---> S; ? @ ran(f) = S}; };
                   @ S};
   fset1 [X2] = fset X2 diff setDisp{};
end

begin gendef[X] Size
   <Properties>
      LAYER_ID  toolkitlib;
      A2TEX_XFM  size \size;
   </Properties>

   func size: (fset X) ---> nat;
where
   forAll{S: fset X; ? @
      size(S) =
         mu{n: nat; ?
            exists{f: (1..n) >--> S; ? @
               ran(f) = S;
            };
            @
            n
         };
   };
end

begin type FinParFun
   <Properties>
      LAYER_ID  toolkitlib;
      A2TEX_XFM  -||> \ffun;
   </Properties>

   [X] -||> [Y] = setComp{f: X --|> Y; ? dom(f) in fset X; @ f};
end

begin type FinParInj
   <Properties>
      LAYER_ID  toolkitlib;
      A2TEX_XFM  >||> \finj;
   </Properties>

   [X] >||> [Y] = (X -||> Y) inter (X >-|> Y);
end

begin axdef MinMax
   <Properties>
      LAYER_ID  toolkitlib;
      A2TEX_XFM  min \min;
      A2TEX_XFM  max \max;
   </Properties>

   func min: (pset1 int) --|> int;
   func max: (pset1 int) --|> int;
   func abs: int ---> nat;
where
   forAll{S: pset1 int; ? @
      min(S) = mu{m: S; ? forAll{n: S; ? @ m <= n}; @ m};
      max(S) = mu{m: S; ? forAll{n: S; ? @ m >= n}; @ m};
   };

   forAll{x: int; ? @
      abs(x) = if(x < 0) then -x else x endif;
   };
end

begin type Sequences
   <Properties>
      LAYER_ID  toolkitlib;
      A2TEX_XFM  seq1 \seqone;
      A2TEX_XFM  iseq \iseq;
      A2TEX_XFM  eseq "\ \textbf{eseq}";
   </Properties>

   seq1 [X1] = setComp{f: seq X1; ? size(f) > 0; @ f};
   iseq [X2] = (seq X2) inter (nat >-|> X2);
   eseq [T1] = mu{s: seq T1; ? s = eset cross{nat, T1}; @ s};
end

begin gendef[X] CatRev
   <Properties>
      LAYER_ID  toolkitlib;
      A2TEX_XFM  cat \cat;
      A2TEX_XFM  rev \rev;
   </Properties>

   oper bin5 cat: cross{seq X, seq X} ---> seq X;
   func rev: (seq X) ---> seq X;
where
   forAll{s: seq X; t: seq X; ? @
      s cat t = s uni setComp{n: dom(t); ? @ (n + size(s)) |--> t(n)};
   };
   forAll{s: seq X; ? @
      rev(s) = lambda{n: dom(s); ? @ s(size(s) - (n + 1))};
   };
end

begin gendef[X] SeqDecomp
   <Properties>
      LAYER_ID  toolkitlib;
      A2TEX_XFM  head \head;
      A2TEX_XFM  last \last;
      A2TEX_XFM  tail \tail;
      A2TEX_XFM  front \front;
   </Properties>

   func head: (seq1 X) ---> X;
   func last: (seq1 X) ---> X;
   func tail: (seq1 X) ---> seq X;
   func front: (seq1 X) ---> seq X;
where
   forAll{s: seq1 X; ? @
      head(s)  = s(0);
      last(s)  = s(size(s) - 1);
      tail(s)  = lambda{n: 0..(size(s) - 2); ? @ s(n + 1)};
      front(s) = (0..(size(s) - 2)) dres s;
   };
end

begin gendef[X] DistributedConcatenation
   <Properties>
      LAYER_ID  toolkitlib;
      A2TEX_XFM  dcat \cat\backslash;
   </Properties>

   oper pre4 dcat: (seq seq X) ---> seq X;
where
   forAll{s: seq X; ? @
      dcat(seqDisp{s}) = s;
   };

   forAll{q: seq(seq X); r: seq(seq X); ? @
      if(q = eseq seq X) then
         dcat(q cat r) = dcat r;
      elif(r = eseq seq X) then
         dcat(q cat r) = dcat q;
      else
         dcat(q cat r) = (dcat q) cat (dcat r);
      endif;
   };
end

begin gendef[X] SubSequences
   <Properties>
      LAYER_ID  toolkitlib;
      A2TEX_XFM  prefix \prefix;
      A2TEX_XFM  suffix \suffix;
      A2TEX_XFM  seqin \inseq;
      A2TEX_XFM  seqidx \seqidx;
   </Properties>

   rel bin4 prefix: (seq X) <--> (seq X);
   rel bin4 suffix: (seq X) <--> (seq X);
   rel bin4 seqin: (seq X) <--> (seq X);
   func seqidx: cross{seq X, seq X} --|> nat1;
where
   forAll{s: seq X; t: seq X; ? @
      s prefix t <=> exists{v: seq X; ? @ s cat v = t};
      s suffix t <=> exists{u: seq X; ? @ u cat s = t};
      s seqin t <=> exists{u: seq X; v: seq X; ? @ u cat s cat v = t};
      seqidx(s, t) = mu{u: seq X; v: seq X; ? u cat t cat v = s; @ size(u)};
   };
end

begin gendef[X] GenSeqDecomp
   <Properties>
      LAYER_ID  toolkitlib;
      A2TEX_XFM  seqext \ires;
      A2TEX_XFM  seqfilt \sres;
      A2TEX_XFM  squash \squash;
      A2TEX_XFM  split \split;
      A2TEX_XFM  join \join;
      A2TEX_XFM  trim \trim;
   </Properties>

   oper bin6 seqext: cross{pset nat1, seq X} ---> seq X;
   oper bin6 seqfilt: cross{seq X, pset X} ---> seq X;
   func squash: (nat1 -||> X) ---> seq X;
   func split: cross{seq X, seq X} ---> seq seq X;
   func join: cross{seq seq X, seq X} ---> seq X;
   func trim: cross{seq X, seq X} ---> seq X;
   func insert: cross{seq X, seq X, int} --|> seq X;
where
   forAll{U: pset nat; s: seq X; ? @
      U seqext s = squash(U dres s);
   };

   forAll{s: seq X; V: pset X; ? @
      s seqfilt V = squash(s rres V);
   };

   forAll{f: nat1 -||> X; ? @
      squash(f) = mu{t: (0..(size(f) - 1)) ---> dom(f); ? forAll{n: dom(f); ? @ t(n) < t(n + 1)}; @ t} rcomp f;
   };

   forAll{s: seq X; tok: seq X; ? @
      if(tok seqin s) then
         split(s, tok) = mu{u: seq X; v: seq X; ? u cat tok cat v = s; @ seqDisp{u} cat split(v, tok)};
      else
         split(s, tok) = seqDisp{s};
      endif;
   };

   forAll{list: seq seq X; tok: seq X; ? @
      if(size(list) > 0) then
         join(list, tok) = list(0) cat tok cat join(tail(list), tok);
      else
         join(list, tok) = eseq X;
      endif;
   };

   forAll{s: seq X; tok: seq X; ? @
      if(tok prefix s) then
         trim(s, tok) = mu{u: seq X; ? tok cat u = s; @ trim(u, tok)};
      elif(tok suffix s) then
         trim(s, tok) = mu{u: seq X; ? u cat tok = s; @ trim(u, tok)};
      else
         trim(s, tok) = s;
      endif;
   };

   forAll{s: seq X; new: seq X; off: nat; ?
      off <= size(s);
      @
      insert(s, new, off) =
         mu{pre: seq X; suff: seq X; ?
            if(off > 0) then
               pre = (0..off) seqext s;
            else
               pre = eseq X;
            endif;

            if(off < size(s)) then
               suff = (off..(size(s) - 1)) seqext s;
            else
               suff = eseq X;
            endif;
            @
            pre cat new cat suff
         };
   };

end

begin type IntegerTypes
   <Properties>
      LAYER_ID toolkitlib;
   </Properties>

   UINT64 = setComp{x: nat; ? x < 2^64 @ x };
   UINT32 = setComp{x: nat; ? x < 2^32 @ x };
   UINT16 = setComp{x: nat; ? x < 2^16 @ x };
   UINT8  = setComp{x: nat; ? x < 2^8 @ x };
   INT64  = setComp{x: int; ? x >= -2^63; x < 2^63; @ x };
   INT32  = setComp{x: int; ? x >= -2^31; x < 2^31; @ x };
   INT16  = setComp{x: int; ? x >= -2^15; x < 2^15; @ x };
   INT8   = setComp{x: int; ? x >= -2^7; x < 2^7; @ x };
end

begin type ArrayType
   <Properties>
      LAYER_ID toolkitlib;
   </Properties>

   BYTE_ARRAY = seq UINT8;
end

begin type GenType
   <Properties>
      LAYER_ID  toolkitlib;
   </Properties>

   GEN_DATA = BYTE_ARRAY;
end

begin axdef GenCast
   <Properties>
      LAYER_ID  toolkitlib;
   </Properties>

   int2Gen: int >--> GEN_DATA;
   gen2Int: GEN_DATA >--> int;

   string2Gen: string >--> GEN_DATA;
   gen2String: GEN_DATA >--> string;
where
end

begin free Boolean
   <Properties>
      LAYER_ID  toolkitlib;
   </Properties>

   BOOL = TRUE | FALSE;
end

begin axdef Assert
   <Properties>
      LAYER_ID  toolkitlib;
   </Properties>

   bool assert: pset BOOL;
where
   assert(TRUE) <=> true;
   assert(FALSE) <=> false;
end
