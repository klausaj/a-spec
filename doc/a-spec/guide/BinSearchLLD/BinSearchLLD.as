#fileID<BinSearchLLD_as>

<DocumentInfo>
   docID     A_Spec_Binary_Search_LLD;
   docVer    00;
   docRev    a;
</DocumentInfo>

#import<toolkit.al>

begin type SortedList
   SORTED_LIST =
      setComp{s: seq int; ?
         forAll{x: nat; ?
            x < (size(s) - 1);
            @
            s(x) <= s(x + 1);
         }
         @
         s
      };
end

begin axdef BinaryFind
   bool binaryFind: SORTED_LIST <--> int;
where
   forAll{list: SORTED_LIST; val: int; ? @
      binaryFind(list, val) <=>
         if(size(list) > 1) then
            exists{guess: nat1; ? guess = size(list) div 2; @
               if(list(guess) < val) then
                  binaryFind(((guess + 1)..size(list)) seqext list, val);
               elif(list(guess) > val) then
                  binaryFind((1..(guess - 1)) seqext list, val);
               else
                  true;
               endif;
            };
         elif(size(list) = 1) then
            list(1) = val;
         else
            false;
         endif;
   };
end
