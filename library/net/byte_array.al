#fileID<net_byte_array_al>

#import<toolkit.al>

begin axdef ExtractINT
   <Properties>
      LAYER_ID net_arraylib;
   </Properties>

   func netExtractUINT64: cross{BYTE_ARRAY, nat} --|> nat;
   func netExtractUINT56: cross{BYTE_ARRAY, nat} --|> nat;
   func netExtractUINT48: cross{BYTE_ARRAY, nat} --|> nat;
   func netExtractUINT40: cross{BYTE_ARRAY, nat} --|> nat;
   func netExtractUINT32: cross{BYTE_ARRAY, nat} --|> nat;
   func netExtractUINT24: cross{BYTE_ARRAY, nat} --|> nat;
   func netExtractUINT16: cross{BYTE_ARRAY, nat} --|> nat;
   func netExtractUINT8: cross{BYTE_ARRAY, nat} --|> nat;
where
   forAll{arr: BYTE_ARRAY; off: nat; ? size(arr) >= 8 + off; @
      netExtractUINT64(arr, off) = arr(off) * 2^56 + netExtractUINT56(arr, off + 1);
   };

   forAll{arr: BYTE_ARRAY; off: nat; ? size(arr) >= 7 + off; @
      netExtractUINT56(arr, off) = arr(off) * 2^48 + netExtractUINT48(arr, off + 1);
   };

   forAll{arr: BYTE_ARRAY; off: nat; ? size(arr) >= 6 + off; @
      netExtractUINT48(arr, off) = arr(off) * 2^40 + netExtractUINT40(arr, off + 1);
   };

   forAll{arr: BYTE_ARRAY; off: nat; ? size(arr) >= 5 + off; @
      netExtractUINT40(arr, off) = arr(off) * 2^32 + netExtractUINT32(arr, off + 1);
   };

   forAll{arr: BYTE_ARRAY; off: nat; ? size(arr) >= 4 + off; @
      netExtractUINT32(arr, off) = arr(off) * 2^24 + netExtractUINT24(arr, off + 1);
   };

   forAll{arr: BYTE_ARRAY; off: nat; ? size(arr) >= 3 + off; @
      netExtractUINT24(arr, off) = arr(off) * 2^16 + netExtractUINT16(arr, off + 1);
   };

   forAll{arr: BYTE_ARRAY; off: nat; ? size(arr) >= 2 + off; @
      netExtractUINT16(arr, off) = arr(off) * 2^8 + netExtractUINT8(arr, off + 1);
   };

   forAll{arr: BYTE_ARRAY; off: nat; ? size(arr) >= 1 + off; @
      netExtractUINT8(arr, off) = arr(off);
   };
end

begin axdef PackINT
   <Properties>
      LAYER_ID net_arraylib;
   </Properties>

   func netPackUINT64: nat --|> BYTE_ARRAY;
   func netPackUINT56: nat --|> BYTE_ARRAY;
   func netPackUINT48: nat --|> BYTE_ARRAY;
   func netPackUINT40: nat --|> BYTE_ARRAY;
   func netPackUINT32: nat --|> BYTE_ARRAY;
   func netPackUINT24: nat --|> BYTE_ARRAY;
   func netPackUINT16: nat --|> BYTE_ARRAY;
   func netPackUINT8: nat --|> BYTE_ARRAY;
where
   forAll{num: nat; ? num <= 2^64 - 1@
      netPackUINT64(num)  = mu{arr: BYTE_ARRAY; ? netExtractUINT64(arr, 0) = num; @ arr};
   };

   forAll{num: nat; ? num <= 2^56 - 1@
      netPackUINT56(num)  = mu{arr: BYTE_ARRAY; ? netExtractUINT56(arr, 0) = num; @ arr};
   };

   forAll{num: nat; ? num <= 2^48 - 1@
      netPackUINT48(num)  = mu{arr: BYTE_ARRAY; ? netExtractUINT48(arr, 0) = num; @ arr};
   };

   forAll{num: nat; ? num <= 2^40 - 1@
      netPackUINT40(num)  = mu{arr: BYTE_ARRAY; ? netExtractUINT40(arr, 0) = num; @ arr};
   };

   forAll{num: nat; ? num <= 2^32 - 1@
      netPackUINT32(num)  = mu{arr: BYTE_ARRAY; ? netExtractUINT32(arr, 0) = num; @ arr};
   };

   forAll{num: nat; ? num <= 2^24 - 1@
      netPackUINT24(num)  = mu{arr: BYTE_ARRAY; ? netExtractUINT24(arr, 0) = num; @ arr};
   };

   forAll{num: nat; ? num <= 2^16 - 1@
      netPackUINT16(num)  = mu{arr: BYTE_ARRAY; ? netExtractUINT16(arr, 0) = num; @ arr};
   };

   forAll{num: nat; ? num <= 2^8 - 1@
      netPackUINT8(num)  = mu{arr: BYTE_ARRAY; ? netExtractUINT8(arr, 0) = num; @ arr};
   };
end
