#! /usr/bin/perl

open FILE, "<", $ARGV[0] or die "Unable to open $ARGV[0]"; 
open OUTFILE, ">", $ARGV[1] or die "Unable to open $ARGV[1]"; 

print OUTFILE "\\begin{verbatim*}";
while(<FILE>)
{
   #$_ =~ s/_/\\_/g;
   #$_ =~ s/</\$<\$/g;
   #$_ =~ s/>/\$>\$/g;
   #$_ =~ s/{/\\{/g;
   #$_ =~ s/}/\\}/g;
   #$_ =~ s/#/\\#/g;

   print OUTFILE $_;
}
print OUTFILE "\\end{verbatim*}";

close FILE;
close OUTFILE;
