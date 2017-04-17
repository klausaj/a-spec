#! /usr/bin/perl

my %layers=(); 

while(<>) 
{
   if($_ =~ m/(LAYERID[\w]*)/g) 
   { 
      if(!exists $layers{$1}) 
      {
         print "$1\n"; 
         $layers{$1}=1;
      }
   }
}
