#fileID<ascii_al>

#import<toolkit.al>

begin axdef ASCIITable
   <Properties>
      LAYER_ID  asciilib;
      A2TEX_XFM  asciiMap "\mathrel{asciiMap}";
   </Properties>

   rel bin4 asciiMap: char <--> int;
where
   forAll{ch: char; x: int; ? @
      (ch asciiMap x) <=> (ch, x) in
         setDisp{
            (`\0`, 0), (` `, 32), (`@`, 64), (````, 96),
            (`#1`, 1), (`!`, 33), (`A`, 65), (`a`, 97),
            (`#2`, 2), (`"`, 34), (`B`, 66), (`b`, 98),
            (`#3`, 3), (`\#`, 35), (`C`, 67), (`c`, 99),
            (`#4`, 4), (`$`, 36), (`D`, 68), (`d`, 100),
            (`#5`, 5), (`%`, 37), (`E`, 69), (`e`, 101),
            (`#6`, 6), (`&`, 38), (`F`, 70), (`f`, 102),
            (`#7`, 7), (`'`, 39), (`G`, 71), (`g`, 103),
            (`#8`, 8), (`(`, 40), (`H`, 72), (`h`, 104),
            (`\t`, 9), (`)`, 41), (`I`, 73), (`i`, 105),
            (`\n`, 10), (`*`, 42), (`J`, 74), (`j`, 106),
            (`#11`, 11), (`+`, 43), (`K`, 75), (`k`, 107),
            (`#12`, 12), (`,`, 44), (`L`, 76), (`l`, 108),
            (`\r`, 13), (`-`, 45), (`M`, 77), (`m`, 109),
            (`#14`, 14), (`.`, 46), (`N`, 78), (`n`, 110),
            (`#15`, 15), (`/`, 47), (`O`, 79), (`o`, 111),
            (`#16`, 16), (`0`, 48), (`P`, 80), (`p`, 112),
            (`#17`, 17), (`1`, 49), (`Q`, 81), (`q`, 113),
            (`#18`, 18), (`2`, 50), (`R`, 82), (`r`, 114),
            (`#19`, 19), (`3`, 51), (`S`, 83), (`s`, 115),
            (`#20`, 20), (`4`, 52), (`T`, 84), (`t`, 116),
            (`#21`, 21), (`5`, 53), (`U`, 85), (`u`, 117),
            (`#22`, 22), (`6`, 54), (`V`, 86), (`v`, 118),
            (`#23`, 23), (`7`, 55), (`W`, 87), (`w`, 119),
            (`#24`, 24), (`8`, 56), (`X`, 88), (`x`, 120),
            (`#25`, 25), (`9`, 57), (`Y`, 89), (`y`, 121),
            (`#26`, 26), (`:`, 58), (`Z`, 90), (`z`, 122),
            (`#27`, 27), (`;`, 59), (`[`, 91), (`{`, 123),
            (`#28`, 28), (`<`, 60), (`\\`, 92), (`|`, 124),
            (`#29`, 29), (`=`, 61), (`]`, 93), (`}`, 125),
            (`#30`, 30), (`>`, 62), (`^`, 94), (`~`, 126),
            (`#31`, 31), (`?`, 63), (`_`, 95)
         };
   };
end

begin axdef DigitMap
   <Properties>
      LAYER_ID  asciilib;
      A2TEX_XFM  decMap "\mathrel{decMap}";
      A2TEX_XFM  hexMap "\mathrel{hexMap}";
   </Properties>

   rel bin4 decMap: char <--> int;
   rel bin4 hexMap: char <--> int;
where
   forAll{ch: char; x: int; ? @
      (ch decMap x) <=> (ch, x) in
         setDisp{
            (`0`, 0), (`1`, 1), (`2`, 2), (`3`, 3), (`4`, 4),
            (`5`, 5), (`6`, 6), (`7`, 7), (`8`, 8), (`9`, 9)
         };
      (ch hexMap x) <=> (ch, x) in
         setDisp{
            (`0`, 0), (`1`, 1), (`2`, 2), (`3`, 3), (`4`, 4),
            (`5`, 5), (`6`, 6), (`7`, 7), (`8`, 8), (`9`, 9),
            (`A`, 0xA), (`B`, 0xB), (`C`, 0xC), (`D`, 0xD), (`E`, 0xE), (`F`, 0xF),
            (`a`, 0xA), (`b`, 0xB), (`c`, 0xC), (`d`, 0xD), (`e`, 0xE), (`f`, 0xF)
         };
   };
end

begin axdef ASCIICast
   <Properties>
      LAYER_ID  asciilib;
      A2TEX_XFM  asciiToBytes "\mathrel{asciiToBytes}";
      A2TEX_XFM  bytesToASCII "\mathrel{bytesToASCII}";
   </Properties>

   oper pre7 asciiToBytes: string ---> BYTE_ARRAY;
   oper pre7 bytesToASCII: BYTE_ARRAY ---> string;
where
   forAll{str: string; ? @
      asciiToBytes str = mu{arr: BYTE_ARRAY; ?
                            size(arr) = size(str);
                            forAll{n: nat1; ? n <= size(str); @
                               str(n) asciiMap arr(n);
                            };
                            @
                            arr};
   };
   forAll{arr: BYTE_ARRAY; ? @
      bytesToASCII arr = mu{str: string; ?
                            size(str) = size(arr);
                            forAll{n: nat1; ? n <= size(arr); @
                               str(n) asciiMap arr(n);
                            };
                            @
                            str};
   };
end

begin axdef IntToString
   <Properties>
      LAYER_ID array_stringF;
   </Properties>

   func intToDecString: int ---> string;
   func intToHexString: int ---> string;
where
   forAll{num: int; ? @
      intToDecString(num) = mu{ch: char; digit: int; next: int; ?
                               digit = num mod 10;
                               next  = num div 10;
                               ch decMap digit;
                               @
                               if(next = 0) then
                                  seqDisp{ch}
                               else
                                  intToDecString(next) cat seqDisp{ch}
                               endif
                            };
      intToHexString(num) = mu{ch: char; digit: int; next: int; ?
                               digit = num mod 16;
                               next  = num div 16;
                               ch hexMap digit;
                               @
                               if(next = 0) then
                                  seqDisp{ch}
                               else
                                  intToHexString(next) cat seqDisp{ch}
                               endif
                            };
   };
end

begin axdef StringToInt
   <Properties>
      LAYER_ID array_stringF;
   </Properties>

   func decStringToInt: string --|> int;
   func hexStringToInt: string --|> int;
where
   forAll{str: string; ? @
      decStringToInt(str) = mu{ch: char; digit: int; ?
                               ch = str(1);
                               ch decMap digit;
                               @
                               if(size(str) = 1) then
                                  digit
                               else
                                  digit * 10 + decStringToInt(tail(str))
                               endif
                            };
      hexStringToInt(str) = mu{ch: char; digit: int; ?
                               ch = str(1);
                               ch decMap digit;
                               @
                               if(size(str) = 1) then
                                  digit
                               else
                                  digit * 16 + hexStringToInt(tail(str))
                               endif
                            };
   };
end

