#fileID<AnnoTeX_al>

begin schema AnnoTest
   x1: int; @[\note{Leading space}]
   y1: int; @[\note*{No space}]

   x2: int; @[\cnote{red}{Leading space}]
   y2: int; @[\cnote*{red}{No space}]

   x3: int; @[\bnote{red}{black}{Leading space}]
   y3: int; @[\bnote*{red}{black}{No space}]

   x4: int; @[\comment{Right justified}]
   y4: int; @[\bcomment{Bold text}]
where
end
