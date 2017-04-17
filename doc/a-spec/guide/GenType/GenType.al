#fileID<GenType_al>

#import<toolkit.al>

begin type GenTypeDef
   LIST [X] = pset X;
   [K] MAP [V] = K --|> V;
end

begin axdef GenDecl
   intList: LIST int;
   intMap: int MAP int;
where
end
