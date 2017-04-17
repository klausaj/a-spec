#fileID<SearchHLD_as>

<DocumentInfo>
   docID     A_Spec_Search_HLD;
   docVer    00;
   docRev    a;
</DocumentInfo>

#import<toolkit.al>

begin type List
   LIST = seq int;
end

begin axdef Find
   bool find: LIST <--> int;
where
   forAll{list: LIST; value: int; ? @
      find(list, value) <=> (value in ran(list));
   };
end
