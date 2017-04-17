#fileID<SetComp_al>

begin type SetComp
   UINT32 = setComp{x: int; ?
               x > 0 && x < 2^32; @ x};
end
