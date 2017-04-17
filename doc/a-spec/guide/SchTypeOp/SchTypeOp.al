#fileID<SchTypeOp_al>

#import<toolkit.al>

begin schema Schema1
   member1: int;
   member2: int;
where
end

begin schema Schema2
   member3: int;
   member4: int;
where
end

begin schema Schema3
   member1: int;
   member2: int;
   member3: int;
   member4: int;
where
end

begin const TypeOperators
   Schema1 & Schema2 = Schema3;

   Schema3 zhide Schema2 = Schema1;
   Schema1 zhide {member2} =
      schType{member1: int;};
end
