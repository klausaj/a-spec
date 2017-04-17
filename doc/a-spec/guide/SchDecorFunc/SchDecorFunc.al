#fileID<SchDecorFunc_al>

#import<toolkit.al>

begin schema DecorExample
   member: int;
   member[']: int;
   input[?]: int;
   output[!]: int;
where
end

begin const DecorFunctions
   zpre(DecorExample) =
      schType{member: int; input[?]: int;};

   zpost(DecorExample) =
      schType{member[']: int;
         output[!]: int;};

   exists{exBind: zpost(DecorExample); ? @
      zunp(exBind) =
         schBind{member = 5, output[!] = 20};
   };
end
