#! /usr/bin/perl

my %pars=();

while(<>)
{
   if($_ =~ m/(ATeXPAR[\w]*)/g)
   {
      if(!exists $pars{$1})
      {
         print "$1\n";
         $pars{$1}=1;
      }
   }
}
