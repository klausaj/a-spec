#fileID<InProp_al>

#import<toolkit.al>

begin schema Example
   x: int; #[Declaration property]
   y: int;
where
   y = x + 1 #[Expression property];
   y < 20; #[Predicate property]
end
