#! /usr/bin/perl

my %tokens=(); 

while(<>) 
{
   if($_ =~ m/(TOK[\w]*)/g) 
   { 
      if(!exists $tokens{$1}) 
      {
         print "$1\n"; 
         $tokens{$1}=1;
      }
   }
}
