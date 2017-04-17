#include<stdlib.h>

int binaryFind(int *list, int size, int val) {
   int  *nextRegion = NULL;
   int  nextSize    = 0;
   int  guess       = size / 2;

   if(size > 1) {
      if(list[guess] < val) {
         if((guess + 1) < size) {
            nextRegion = &(list[guess + 1]);
            nextSize   = size - guess - 1;
         }

         return binaryFind(nextRegion, nextSize, val);
      }
      else if(list[guess] > val) {
         if(guess > 0) {
            nextRegion = &(list[0]);
            nextSize   = guess;
         }

         return binaryFind(nextRegion, nextSize, val);
      }
      else {
         return 1;
      }
   }
   else if(size == 1) {
      return list[0] == val;
   }
   else {
      return 0;
   }
}
