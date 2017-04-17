#include<stdio.h>

int binaryFind(int *list, int size, int val);

int main(int argsc, char **argsv) {
   int  odds1[]  = {1, 3, 5, 7, 9, 11, 13}; 
   int  evens1[] = {2, 4, 6, 8, 10, 12, 14};
   int  odds2[]  = {1, 3, 5, 7, 9, 11, 13, 15}; 
   int  evens2[] = {2, 4, 6, 8, 10, 12, 14, 16};
   int  loop     = 0;

   for(loop = 0; loop <= 17; loop++) {
      printf("Checking %d . . .\n", loop);

      if(binaryFind(odds1, 7, loop)) {
         printf("\t%d in odds(1..13)\n", loop);
      }
      else {
         printf("\t%d not in odds(1..13)\n", loop);
      }

      if(binaryFind(evens1, 7, loop)) {
         printf("\t%d in evens(2..14)\n", loop);
      }
      else {
         printf("\t%d not in evens(2..14)\n", loop);
      }

      if(binaryFind(odds2, 8, loop)) {
         printf("\t%d in odds(1..15)\n", loop);
      }
      else {
         printf("\t%d not in odds(1..15)\n", loop);
      }

      if(binaryFind(evens2, 8, loop)) {
         printf("\t%d in evens(2..16)\n", loop);
      }
      else {
         printf("\t%d not in evens(2..16)\n", loop);
      }
   }

   return 0;
}
