#! /usr/bin/perl

my %pars=();
my %layers=();

while(<>)
{
   if($_ =~ m/(ATeXPAR[\w]*)/g)
   {
      if(!exists $pars{$1})
      {
         print "\\let\\$1\\undefined\n";
         $pars{$1}=1;
      }
   }

   if($_ =~ m/(LAYERID[\w]*)/g)
   {
      if(!exists $layers{$1})
      {
         print "\\def\\$1\{0\}\n";
         $layers{$1}=1;
      }
   }
}
