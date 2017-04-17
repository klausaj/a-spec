#! /usr/bin/perl
use Tie::IxHash;

open FILE, "<", $ARGV[0] or die "Unable to open $ARGV[0]"; 

my $STATE_INIT = 0;
my $STATE_NEW = 1;
my $STATE_OR = 2;

my $lhsLen;
my $state = $STATE_INIT;

tie %rules, "Tie::IxHash";
my @lines = ();

my $ruleName;
my $line;

while(<FILE>)
{
   $_ =~ s/(\/\* )|( \*\/)//g;

   if($_ =~ m/^ *\d* (\w*): (.*)/) #rule start
   {
      $ruleName = $1;
      @lines    = ();

      my $lhs = $1;
      my $rhs = $2;
      
      $lhs =~ s/_/\\_/g;
      $rhs =~ s/_/\\_/g;
      $rhs =~ s/([\w\\]+)/\\bnfelem{$1}/g;
      
      $lhsLen = length($lhs) + 10;
      $line   =  "\\bnfelem{$lhs} & ::= & $rhs";
      $state  = $STATE_NEW;
   }
   elsif($_ =~ m/^ +\d+ +\| (.+)/) #rule continue
   {
      $line = "$line \\bnfor & \\\\\n";

      push(@lines, $line);

      $line = "";

      for(my $i = 0; $i < $lhsLen; $i++)
      {
         $line = "$line ";
      }

      my $rhs = $1;

      $rhs =~ s/_/\\_/g;
      $rhs =~ s/([\w\\]+)/\\bnfelem{$1}/g;

      $line = "$line &     & $rhs";

      $state  = $STATE_OR;
   }
   else #blank line/rule seperator
   {
      if($state != $STATE_INIT)
      {
         $line = "$line & \\\\\n";

         push(@lines, $line);
         $rules{$ruleName} = [@lines];
      }

      $state = $STATE_INIT;
   }
}

if($state != $STATE_INIT)
{
   $line = "$line & \\\\\n";

   push(@lines, $line);
   $rules{$ruleName} = [@lines];
}

foreach my $key (keys %rules)
{
   my @outLines = @{$rules{$key}};

   open OUTFILE, ">", "bnf-auto/$key.bnf";

   my $leadWS = index($outLines[0], "&");

   foreach my $outLine (@outLines)
   {
      my $brk = index($outLine, "\\bnfelem", 77);

      while($brk >= 77)
      {
         my $start = substr($outLine, 0, $brk);
         my $end   = substr($outLine, $brk);

         print OUTFILE "   $start& \\\\\n";

         $outLine = "";

         for(my $idx = 0; $idx < $leadWS; $idx++)
         {
            $outLine = "$outLine ";
         }

         $outLine = "$outLine&     & $end";
         $brk = index($outLine, "\\bnfelem", 77);
      }
      
      print OUTFILE "   $outLine";
   }

   close OUTFILE;
}
