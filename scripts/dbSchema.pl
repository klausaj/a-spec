#! /usr/bin/perl

use warnings;
use strict;
use XML::LibXML;

my $filename = $ARGV[0];

if(!defined($filename))
{
   print "Usage: dbSchema.pl [Input file]\n";

   exit -1;
}

my $parser       = XML::LibXML->new();
my $doc          = $parser->parse_file($filename);
my $directPath   = "//Directive/Commands/Command/text()";
my $deriveQuery  = "normalize-space($directPath\[starts-with(normalize-space(.), 'derive DBSchema')])";
my $dbGroupQuery = "//Directive/Commands/Command/text()[starts-with(normalize-space(.), 'DB_GROUP_ATTR')]";
my $deriveStr    = $doc->findvalue($deriveQuery);
my @dbGroupL     = $doc->findnodes($dbGroupQuery);

if(!defined($deriveStr))
{
   print "DBSchema: Input file doesn't contiain DBSchema directive\n";

   exit -1;
}

my @deriveTok = split(/ /, $deriveStr);

if(@deriveTok < 5)
{
   print "DBSchema: Directive must be of the form: derive DBSchema [Output type] [DB id] [Output file]\n";

   exit -1;
}

my $diagram = $deriveTok[2];
my $dbID    = $deriveTok[3];

if($diagram =~ m/^TikZ$/i)
{
   $diagram = "TikZ";
}
else
{
   print "DBSchema: Diagram type must be TikZ\n";

   exit -1;
}

my %groupHash;

foreach my $dbGroupN (@dbGroupL)
{
   my $dbGroupStr = $dbGroupN->data;
   $dbGroupStr =~ s/\"//g;
   $dbGroupStr =~ s/^\s*DB_GROUP_ATTR\s+//g;
   $dbGroupStr =~ s/^\s+//g;
   $dbGroupStr =~ s/\s+$//g;

   my @dbGroupArr = split(/:/, $dbGroupStr);
   my $groupName  = $dbGroupArr[0];
   my $groupColor = $dbGroupArr[1];
   my $groupLabel = $dbGroupArr[2];
   my $labelPos   = $dbGroupArr[3];
   my %groupInfo;

   %groupInfo = ("name" => $groupName, "label" => $groupLabel, "lpos" => $labelPos,
                 "color" => $groupColor, "tables" => "");
   $groupHash{$groupName} = {%groupInfo};
}

my $outFile = $deriveTok[4];

$outFile =~ s/\"//g;

my $tableProp  = "DB_TABLE $dbID";
my $tableQuery = "//Schema/Properties/PropertyEntry/text()[normalize-space(.)='$tableProp']/../../..";

my @tableList;

my @tables = $doc->findnodes($tableQuery);

if(@tables <= 0)
{
   print "DBSchema: No tables found\n";

   exit -1;
}

foreach my $tableNode (@tables)
{
   my $tableName = $tableNode->getAttribute('name');

   my $posQ    = "./Properties/PropertyEntry/text()[starts-with(normalize-space(.), 'TABLE_POS')]";
   my $pkeyQ   = "./Properties/PropertyEntry/text()[starts-with(normalize-space(.), 'PKEY')]";
   my $fkeyQ   = "./Properties/PropertyEntry/text()[starts-with(normalize-space(.), 'FKEY')]";
   my $groupQ  = "./Properties/PropertyEntry/text()[starts-with(normalize-space(.), 'GROUP')]";
   my $dbAttrQ = "./Properties/PropertyEntry/text()[starts-with(normalize-space(.), 'DB_ATTR')]";
   my $nAttrQ  = "./Properties/PropertyEntry/text()[starts-with(normalize-space(.), 'TIKZ_NODE_ATTR')]";

   my $posN    = ($tableNode->findnodes($posQ))[0];
   my $pkeyN   = ($tableNode->findnodes($pkeyQ))[0];
   my @fkeyL   = $tableNode->findnodes($fkeyQ);
   my $groupN  = ($tableNode->findnodes($groupQ))[0];
   my @dbAttrL = $tableNode->findnodes($dbAttrQ);
   my $nAttrN  = ($tableNode->findnodes($nAttrQ))[0];
   my @fieldList;
   my @fkeyList;
   my @tblAttrList;
   my $pos;
   my $pkey;
   my $group;
   my $nAttr;
   my %tblHash;

   if(defined($posN))
   {
      $pos = $posN->findvalue('.');
      $pos =~ s/\"//g;
      $pos =~ s/^\s*TABLE_POS\s+//g;
      $pos =~ s/^\s+//g;
      $pos =~ s/\s+$//g;
   }

   if(defined($pkeyN))
   {
      $pkey = $pkeyN->findvalue('.');
      $pkey =~ s/\"//g;
      $pkey =~ s/^\s*PKEY\s+//g;
      $pkey =~ s/^\s+//g;
      $pkey =~ s/\s+$//g;
   }

   foreach my $fkeyN (@fkeyL)
   {
      my $fkey;

      $fkey = $fkeyN->findvalue('.');
      $fkey =~ s/\"//g;
      $fkey =~ s/^\s*FKEY\s+//g;
      $fkey =~ s/^\s+//g;
      $fkey =~ s/\s+$//g;

      push(@fkeyList, $fkey);
   }

   if(defined($groupN))
   {
      $group = $groupN->findvalue('.');
      $group =~ s/\"//g;
      $group =~ s/^\s*GROUP\s+//g;
      $group =~ s/^\s+//g;
      $group =~ s/\s+$//g;
   }

   if(defined($nAttrN))
   {
      $nAttr = $nAttrN->findvalue('.');
      $nAttr =~ s/\"//g;
      $nAttr =~ s/^\s*TIKZ_NODE_ATTR\s+//g;
      $nAttr =~ s/^\s+//g;
      $nAttr =~ s/\s+$//g;
   }

   foreach my $dbAttrN (@dbAttrL)
   {
      my $dbAttr;

      $dbAttr = $dbAttrN->findvalue('.');
      $dbAttr =~ s/\"//g;
      $dbAttr =~ s/^\s*DB_ATTR\s+//g;
      $dbAttr =~ s/^\s+//g;
      $dbAttr =~ s/\s+$//g;

      push(@tblAttrList, $dbAttr);
   }

   foreach my $field ($tableNode->findnodes('.//Declarations/Declaration'))
   {
      my $nameQ   = "./DeclarationIdentifier/Variable";
      my $exprQ   = "./DeclarationExpression";
      my $dbAttrQ = "./Properties/PropertyEntry/text()[starts-with(normalize-space(.), 'DB_ATTR')]";

      my $nameN    = ($field->findnodes($nameQ))[0];
      my $exprN    = ($field->findnodes($exprQ))[0];
      my $defExprN = ($exprN->childNodes)[1];
      my @dbAttrL  = $field->findnodes($dbAttrQ);

      my $fieldName = $nameN->getAttribute('name');
      my $fieldType;
      my @fieldAttrList;
      my %fieldHash;

      if($defExprN->nodeName eq "ExpressionIdent")
      {
         $fieldType = $defExprN->getAttribute('ident');
      }
      elsif($defExprN->nodeName eq "ExpressionFunction")
      {
         my $funcQ  = "./Function/ExpressionIdent";
         my $paramQ = "./Parameters//ExpressionLiteral";
         my $funcN  = ($defExprN->findnodes($funcQ))[0];
         my @paramL = $defExprN->findnodes($paramQ);

         $fieldType = $funcN->getAttribute('ident');

         if(@paramL > 0)
         {
            my $idx = 0;
            $fieldType = $fieldType . "(";
            foreach my $param (@paramL)
            {
               if($idx > 0)
               {
                  $fieldType = $fieldType . ", ";
               }

               $fieldType = $fieldType . $param->getAttribute('value');
               $idx++;
            }

            $fieldType = $fieldType . ")";
         }
      }
      else
      {
         $fieldType = "UNKNOWN";
      }

      foreach my $dbAttrN (@dbAttrL)
      {
         my $dbAttr;

         $dbAttr = $dbAttrN->findvalue('.');
         $dbAttr =~ s/\"//g;
         $dbAttr =~ s/^\s*DB_ATTR\s+//g;
         $dbAttr =~ s/^\s+//g;
         $dbAttr =~ s/\s+$//g;

         push(@fieldAttrList, $dbAttr);
      }

      %fieldHash = ("name" => $fieldName, "type" => $fieldType, "attrs" => \@fieldAttrList);

      push(@fieldList, {%fieldHash});
   }

   if(exists($groupHash{$group}))
   {
      my $groupList = $groupHash{$group}{"tables"};

      $groupHash{$group}{"tables"} = $groupList . " ($tableName)";
   }

   %tblHash = ("name" => $tableName, "pos" => $pos, "pkey" => $pkey, "fkeys" => \@fkeyList,
               "group" => $group, "attrs" => \@tblAttrList, "fields" => \@fieldList, "tikz" => $nAttr);

   push(@tableList, {%tblHash});
}

#foreach my $tableEntry (@tableList)
#{
   #my $tblName   = $$tableEntry{"name"};
   #my $tblPos    = $$tableEntry{"pos"};
   #my $tblPKey   = $$tableEntry{"pkey"};
   #my @tblFKeyL  = @{$$tableEntry{"fkeys"}};
   #my $tblGroup  = $$tableEntry{"group"};
   #my @tblAttrL  = @{$$tableEntry{"attrs"}};
   #my @tblFieldL = @{$$tableEntry{"fields"}};
#
   #print "Table: $tblName\n";
   #print "   Pos: $tblPos\n";
   #print "   PKey: $tblPKey\n";
#
   #foreach my $tblFKey (@tblFKeyL)
   #{
      #print "   FKey: $tblFKey\n";
   #}
#
   #print "   Group: $tblGroup\n";
#
   #foreach my $tblAttr (@tblAttrL)
   #{
      #print "   DBAttr: $tblAttr\n";
   #}
#
   #print "   Fields:\n";
   #foreach my $fieldEntry (@tblFieldL)
   #{
      #my $fldName  = $$fieldEntry{"name"};
      #my $fldType  = $$fieldEntry{"type"};
      #my @fldAttrL = @{$$fieldEntry{"attrs"}};
#
      #print "      $fldName: $fldType\n";
#
      #foreach my $fldAttr (@fldAttrL)
      #{
         #print "         DBAttr: $fldAttr\n";
      #}
   #}
#
   #print "\n";
#}

sub fixTexLabel
{
   my $label = $_[0];

   $label =~ s/u/uU/g;
   $label =~ s/_/uu/g;

   return $label;
}

sub fixTexText
{
   my $label = $_[0];

   $label =~ s/_/\$\\_\$/g;
   $label =~ s/\\n/ /g;

   return $label;
}

open(DBFile, ">$outFile") or die("Unable to open $outFile for writing");

my $direcPath = "//Directive/Commands/Command/text()";
my $attrQuery = "normalize-space($direcPath\[starts-with(normalize-space(.), 'TIKZ_PIC_ATTR')])";
my $cmdQuery  = "normalize-space($direcPath\[starts-with(normalize-space(.), 'TIKZ_PIC_CMDS')])";
my $attrStr   = $doc->findvalue($attrQuery);
my $cmdStr    = $doc->findvalue($cmdQuery);

print DBFile "\\begin{tikzpicture}\n";

print DBFile "   [table/.style={rectangle, draw=black, font=\\footnotesize,
                 minimum height=2em, inner sep=.2em, text width=5.5cm, fill=white,
                 rectangle split, rectangle split parts=2}";

if(defined($attrStr) && ($attrStr ne ""))
{
   $attrStr =~ m/"(.*)"/g;

   print DBFile ",\n    $1";
}

print DBFile "]\n";

if(defined($cmdStr) && ($cmdStr ne ""))
{
   $cmdStr =~ m/"(.*)"/g;

   print DBFile "   $1\n";
}

foreach my $tableEntry (@tableList)
{
   my $tblName   = $$tableEntry{"name"};
   my $tblPos    = $$tableEntry{"pos"};
   my $tblPKey   = $$tableEntry{"pkey"};
   my @tblFKeyL  = @{$$tableEntry{"fkeys"}};
   my $tblGroup  = $$tableEntry{"group"};
   my @tblAttrL  = @{$$tableEntry{"attrs"}};
   my @tblFieldL = @{$$tableEntry{"fields"}};
   my $tblTikZ   = $$tableEntry{"tikz"};
   my @pKeys     = split(/ /, $tblPKey);
   my %isPKey;
   my %isFKey;

   for(@pKeys)
   {
      $isPKey{$_} = 1;
   }

   for my $fKeyStr (@tblFKeyL)
   {
      my $fKey = (split(/:/, $fKeyStr))[0];

      $isFKey{$fKey}  = 1;
   }

   if(defined($tblTikZ))
   {
      print DBFile "   \\node[table, $tblTikZ] (", &fixTexLabel($tblName), ")\n";
   }
   else
   {
      print DBFile "   \\node[table] (", &fixTexLabel($tblName), ")\n";
   }


   if(defined($tblPos))
   {
      print DBFile "      at ($tblPos)\n";
   }

   print DBFile "      {\\textbf{", &fixTexText($tblName), "}\n";
   print DBFile "      \\nodepart{second}\n";

   my  $fieldNum = 0;

   foreach my $fieldEntry (@tblFieldL)
   {
      my $fldName  = $$fieldEntry{"name"};
      my $fldType  = $$fieldEntry{"type"};

      if($fieldNum > 0)
      {
         print DBFile "\\\\\n";
      }

      $fieldNum++;

      my $label;

      if($isPKey{$fldName} && $isFKey{$fldName})
      {
         $label = "\\pfkey";
      }
      elsif($isPKey{$fldName})
      {
         $label = "\\pkey";
      }
      elsif($isFKey{$fldName})
      {
         $label = "\\fkey";
      }
      else
      {
         $label = "\\field";
      }

      print DBFile "            $label ", &fixTexText($fldName), ": ", &fixTexText($fldType);
   }

   print DBFile "};\n";
}

foreach my $tableEntry (@tableList)
{
   my $tblName   = $$tableEntry{"name"};
   my @tblFKeyL  = @{$$tableEntry{"fkeys"}};
   my @tblFieldL = @{$$tableEntry{"fields"}};

   for my $fKeyStr (@tblFKeyL)
   {
      my @fKeyArr  = split(/ /, $fKeyStr);
      my $relStr   = $fKeyArr[0];
      my $degStr   = $fKeyArr[1];
      my @relArr   = split(/:/, $relStr);
      my @degArr   = split(/:/, $degStr);
      my $fKey     = $relArr[0];
      my $fTblStr  = $relArr[1];
      my $lDeg     = $degArr[0];
      my $fDeg     = $degArr[1];
      my $fTable   = (split(/\(/, $fTblStr))[0];
      my $eAttr;
      my $lHead;
      my $fHead;

      if(@fKeyArr >= 3)
      {
         $fKeyStr =~ m/TIKZ_EDGE_ATTR\((.*)\)/;
         $eAttr = $1;
      }

      if($lDeg eq "1")
      {
         $lHead = "o";
      }
      else
      {
         $lHead = "open diamond";
      }

      if($fDeg eq "1")
      {
         $fHead = "o";
      }
      else
      {
         $fHead = "open diamond";
      }

      if(defined($eAttr))
      {
         print DBFile "   \\path [$lHead-$fHead, $eAttr] (", &fixTexLabel($tblName), ") edge\n";
      }
      else
      {
         print DBFile "   \\path [$lHead-$fHead] (", &fixTexLabel($tblName), ") edge\n";
      }

      print DBFile "          (", &fixTexLabel($fTable), ");\n";
   }
}

print DBFile "   \\begin{pgfonlayer}{background}\n";
foreach my $groupEntry (keys %groupHash)
{
   my $groupList  = $groupHash{$groupEntry}{"tables"};
   my $groupColor = $groupHash{$groupEntry}{"color"};
   my $groupLabel = $groupHash{$groupEntry}{"label"};
   my $labelPos   = $groupHash{$groupEntry}{"lpos"};

   print DBFile "      \\node[fill=$groupColor, fit=$groupList, label=$labelPos:{\\footnotesize $groupLabel}] {};\n";
}
print DBFile "   \\end{pgfonlayer}\n";

print DBFile "\\end{tikzpicture}\n";
