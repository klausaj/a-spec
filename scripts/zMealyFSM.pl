#! /usr/bin/perl

use warnings;
use strict;
use XML::LibXML;

my $filename = $ARGV[0];

if(!defined($filename))
{
   print "Usage: mealyFSM.pl [Input file]\n";

   exit -1;
}

my $parser      = XML::LibXML->new();
my $doc         = $parser->parse_file($filename);
my $derivePath  = "//Directive/Commands/Command/text()";
my $deriveQuery = "normalize-space($derivePath\[starts-with(normalize-space(.), 'derive MealyFSM')])";
my $deriveStr   = $doc->findvalue($deriveQuery);

if(!defined($deriveStr))
{
   print "MealyFSM: Input file doesn't contiain MealyFSM directive\n";

   exit -1;
}

my @deriveTok = split(/ /, $deriveStr);

if(@deriveTok < 5)
{
   print "MealyFSM: Directive must be of the form: derive MealyFSM [Output type] [FSM id] [FSM output file]\n";

   exit -1;
}

my $diagram = $deriveTok[2];
my $fsmID   = $deriveTok[3];

if($diagram =~ m/^DOT$/i)
{
   $diagram = "DOT";
}
elsif($diagram =~ m/^TikZ$/i)
{
   $diagram = "TikZ";
}
else
{
   print "MealyFSM: Diagram type must be one of (DOT, TikZ)\n";

   exit -1;
}

shift(@deriveTok);
shift(@deriveTok);
shift(@deriveTok);
shift(@deriveTok);

my $outFile = join(" ", @deriveTok);

$outFile =~ s/\"//g;

my $stateProp    = "FSM_STATES $fsmID";
my $initProp     = "FSM_INIT $fsmID";
my $eventProp    = "FSM_EVENTS $fsmID";
my $actionProp   = "FSM_ACTION $fsmID";
my $condActProp  = "FSM_CONDACT $fsmID";
my $transProp    = "FSM_TRANSITIONS $fsmID";
my $stateQuery   = "//Properties/PropertyEntry/text()[normalize-space(.)='$stateProp']/../../..";
my $initQuery    = "//Properties/PropertyEntry/text()[normalize-space(.)='$initProp']/../../..";
my $eventQuery   = "//Properties/PropertyEntry/text()[normalize-space(.)='$eventProp']/../../..";
my $actionQuery  = "//Properties/PropertyEntry/text()[normalize-space(.)='$actionProp']/../../..";
my $finStateQ    = ".//Properties/PropertyEntry/text()[normalize-space(.)='FSM_STATEVAR']/../../..";
my $condActQuery = "//Properties/PropertyEntry/text()[normalize-space(.)='$condActProp']/../../..";
my $transQuery   = "//Properties/PropertyEntry/text()[normalize-space(.)='$transProp']/../../..";

my @stateList;
my %eventHash;
my %actionHash;
my %condActHash;
my @transList;

my @states = $doc->findnodes($stateQuery);

if(@states <= 0)
{
   print "MealyFSM: No states found\n";

   exit -1;
}

foreach my $stateNode (@states)
{
   foreach my $var ($stateNode->findnodes('.//Variable'))
   {
      my $labelQ = "./Properties/PropertyEntry/text()[starts-with(normalize-space(.), 'FSM_LABEL')]";
      my $posQ   = "./Properties/PropertyEntry/text()[starts-with(normalize-space(.), 'FSM_POS')]";
      my $attrQ  = "./Properties/PropertyEntry/text()[starts-with(normalize-space(.), 'FSM_NODE_ATTR')]";
      my $name   = $var->findvalue('@name');
      my $labelN = ($var->findnodes($labelQ))[0];
      my $posN   = ($var->findnodes($posQ))[0];
      my $attrN  = ($var->findnodes($attrQ))[0];
      my $label;
      my $pos;
      my $attr;
      my %sHash;

      if(defined($labelN))
      {
         $label = $labelN->findvalue('.');
         $label =~ m/"(.*)"/g;
         $label = $1;
      }
      else
      {
         $label = $name;
      }

      if(defined($posN))
      {
         $pos = $posN->findvalue('.');
         $pos =~ m/"(.*)"/g;
         $pos = $1;
      }

      if(defined($attrN))
      {
         $attr = $attrN->findvalue('.');
         $attr =~ m/"(.*)"/g;
         $attr = $1;
      }

      %sHash = ("name" => $name, "label" => $label, "pos" => $pos, "attr" => $attr);

      push(@stateList, {%sHash});
   }
}

my $initID   = $stateList[0]{"name"};
my $initNode = ($doc->findnodes($initQuery))[0];

if(defined($initNode))
{
   my $tmpID = $initNode->findvalue("./PredicateType/RelationalOperator[\@name='=']/Right/Variable/\@name");

   if(defined($tmpID))
   {
      $initID = $tmpID;
   }
}

my @events = $doc->findnodes($eventQuery);

if(@events <= 0)
{
   print "MealyFSM: No events found\n";

   exit -1;
}

foreach my $eventNode (@events)
{
   foreach my $var ($eventNode->findnodes('.//Variable'))
   {
      my $labelQ = "./Properties/PropertyEntry/text()[starts-with(normalize-space(.), 'FSM_LABEL')]";
      my $name   = $var->findvalue('@name');
      my $labelN = ($var->findnodes($labelQ))[0];
      my $label;

      if(defined($labelN))
      {
         $label = $labelN->findvalue('.');
         $label =~ m/"(.*)"/g;
         $label = $1;
      }
      else
      {
         $label = $name;
      }

      $eventHash{$name} = $label;
   }
}

my @actions = $doc->findnodes($actionQuery);

if(@actions <= 0)
{
   print "MealyFSM: No actions found\n";

   exit -1;
}

foreach my $actionNode (@actions)
{
   my $finStateP = ($actionNode->findnodes($finStateQ))[0];
   my $labelQ    = "./Properties/PropertyEntry/text()[starts-with(normalize-space(.), 'FSM_LABEL')]";
   my $name      = $actionNode->findvalue('@name');
   my $labelN    = ($actionNode->findnodes($labelQ))[0];
   my $label;

   if(defined($labelN))
   {
      $label = $labelN->findvalue('.');
      $label =~ m/"(.*)"/g;
      $label = $1;
   }
   else
   {
      $label = $name;
   }

   if(defined($finStateP))
   {
      my $finStateV = $finStateP->findvalue("./PredicateType/RelationalOperator[\@name='=']/Right/Variable/\@name");

      $actionHash{$name} = {"target" => $finStateV, "label" => $label};
   }
   else
   {
      $actionHash{$name} = {"target" => undef, "label" => $label};
   }
}

foreach my $condActNode ($doc->findnodes($condActQuery))
{
   my $name    = $condActNode->findvalue('@name');
   my $nLabelQ = "./Properties/PropertyEntry/text()[starts-with(normalize-space(.), 'FSM_LABEL')]";
   my $cLabelQ = "./Properties/PropertyEntry/text()[starts-with(normalize-space(.), 'FSM_COND_LABEL')]";
   my $posQ    = "./Properties/PropertyEntry/text()[starts-with(normalize-space(.), 'FSM_POS')]";
   my $attrQ   = "./Properties/PropertyEntry/text()[starts-with(normalize-space(.), 'FSM_NODE_ATTR')]";
   my $condQ   = ".//Predicates/Predicate/PredicateType/ConditionalPredicate";
   my $thenQ   = "./ThenPredicates/Predicate/PredicateType/SchemaApplication";
   my $elseQ   = "./ElsePredicates/Predicate/PredicateType/SchemaApplication";
   my $tLabelQ = "../../Properties/PropertyEntry/text()[starts-with(normalize-space(.), 'FSM_LABEL')]";
   my $eLabelQ = "../../Properties/PropertyEntry/text()[starts-with(normalize-space(.), 'FSM_LABEL')]";
   my $nLabelN = ($condActNode->findnodes($nLabelQ))[0];
   my $cLabelN = ($condActNode->findnodes($cLabelQ))[0];
   my $posN    = ($condActNode->findnodes($posQ))[0];
   my $attrN   = ($condActNode->findnodes($attrQ))[0];
   my $condP   = ($condActNode->findnodes($condQ))[0];
   my $nLabel;
   my $cLabel;
   my $pos;
   my $attr;

   if(defined($nLabelN))
   {
      $nLabel = $nLabelN->findvalue('.');
   }

   if(defined($cLabelN))
   {
      $cLabel = $cLabelN->findvalue('.');
   }

   if(defined($posN))
   {
      $pos = $posN->findvalue('.');
   }

   if(defined($attrN))
   {
      $attr = $attrN->findvalue('.');
   }

   if(!defined($condP))
   {
      print "Unable to ConditionalPredicate for $name\n";

      exit -1;
   }

   my $thenApp = ($condP->findnodes($thenQ))[0];
   my $elseApp = ($condP->findnodes($elseQ))[0];

   if(!defined($thenApp))
   {
      print "Unable to find SchemaApplication in then branch for $name\n";

      exit -1;
   }

   if(!defined($elseApp))
   {
      print "Unable to find SchemaApplication in else branch for $name\n";

      exit -1;
   }

   my $tLabelN = ($thenApp->findnodes($tLabelQ))[0];
   my $eLabelN = ($elseApp->findnodes($eLabelQ))[0];
   my $tLabel;
   my $eLabel;

   if(defined($tLabelN))
   {
      $tLabel = $tLabelN->findvalue('.');
   }

   if(defined($eLabelN))
   {
      $eLabel = $eLabelN->findvalue('.');
   }

   my $thenAct = $thenApp->findvalue('./Command/SchemaType[1]/@ref');
   my $elseAct = $elseApp->findvalue('./Command/SchemaType[1]/@ref');

   if(defined($nLabel))
   {
      $nLabel =~ m/"(.*)"/g;

      $condActHash{$name}{"nLabel"} = $1;
   }
   else
   {
      $condActHash{$name}{"nLabel"} = undef;
   }

   if(defined($cLabel))
   {
      $cLabel =~ m/"(.*)"/g;

      $condActHash{$name}{"cLabel"} = $1;
   }
   else
   {
      $condActHash{$name}{"cLabel"} = undef;
   }

   if(defined($tLabel))
   {
      $tLabel =~ m/"(.*)"/g;

      $condActHash{$name}{"tLabel"} = $1;
   }
   else
   {
      $condActHash{$name}{"tLabel"} = undef;
   }

   if(defined($eLabel))
   {
      $eLabel =~ m/"(.*)"/g;

      $condActHash{$name}{"eLabel"} = $1;
   }
   else
   {
      $condActHash{$name}{"eLabel"} = undef;
   }

   if(defined($pos))
   {
      $pos =~ m/"(.*)"/g;

      $condActHash{$name}{"pos"} = $1;
   }

   if(defined($attr))
   {
      $attr =~ m/"(.*)"/g;

      $condActHash{$name}{"attr"} = $1;
   }

   if(!defined($thenAct))
   {
      print "Unable to find SchemaApplication name in then branch for $name\n";

      exit -1;
   }

   if(!defined($elseAct))
   {
      print "Unable to find SchemaApplication name in else branch for $name\n";

      exit -1;
   }

   if($thenAct eq "")
   {
      $condActHash{$name}{"then"} = undef;
   }
   else
   {
      $condActHash{$name}{"then"} = $thenAct;
   }

   if($elseAct eq "")
   {
      $condActHash{$name}{"else"} = undef;
   }
   else
   {
      $condActHash{$name}{"else"} = $elseAct;
   }

   my $teAttrQ = "../../Properties/PropertyEntry/text()[starts-with(normalize-space(.), 'FSM_ATTR_EDGE')]";
   my $eeAttrQ = "../../Properties/PropertyEntry/text()[starts-with(normalize-space(.), 'FSM_ATTR_EDGE')]";
   my $tlAttrQ = "../../Properties/PropertyEntry/text()[starts-with(normalize-space(.), 'FSM_ATTR_LABEL')]";
   my $elAttrQ = "../../Properties/PropertyEntry/text()[starts-with(normalize-space(.), 'FSM_ATTR_LABEL')]";
   my $teAttrN = ($thenApp->findnodes($teAttrQ))[0];
   my $eeAttrN = ($elseApp->findnodes($eeAttrQ))[0];
   my $tlAttrN = ($thenApp->findnodes($tlAttrQ))[0];
   my $elAttrN = ($elseApp->findnodes($elAttrQ))[0];
   my $teAttr;
   my $eeAttr;
   my $tlAttr;
   my $elAttr;

   if(defined($teAttrN))
   {
      $teAttr = $teAttrN->findvalue('.');
   }

   if(defined($eeAttrN))
   {
      $eeAttr = $eeAttrN->findvalue('.');
   }

   if(defined($tlAttrN))
   {
      $tlAttr = $tlAttrN->findvalue('.');
   }

   if(defined($elAttrN))
   {
      $elAttr = $elAttrN->findvalue('.');
   }

   if(defined($teAttr))
   {
      $teAttr =~ m/"(.*)"/g;

      $condActHash{$name}{"teAttr"} = $1;
   }

   if(defined($eeAttr))
   {
      $eeAttr =~ m/"(.*)"/g;

      $condActHash{$name}{"eeAttr"} = $1;
   }

   if(defined($tlAttr))
   {
      $tlAttr =~ m/"(.*)"/g;

      $condActHash{$name}{"tlAttr"} = $1;
   }

   if(defined($elAttr))
   {
      $elAttr =~ m/"(.*)"/g;

      $condActHash{$name}{"elAttr"} = $1;
   }
}

my @transitions = $doc->findnodes($transQuery);

if(@transitions <= 0)
{
   print "MealyFSM: No transition map found\n";

   exit -1;
}

foreach my $transNode (@transitions)
{
   my @maplets = $transNode->findnodes('.//ExpressionOperator[@name="|-->"]');

   if(@maplets <= 0)
   {
      print "MealyFSM: Transition map is empty\n";

      exit -1;
   }

   foreach my $mapList (@maplets)
   {
      my $input  = ($mapList->findnodes(".//Left/Tuple/ExpressionList"))[0];
      my $state  = $input->findvalue('./Variable[1]/@name');
      my $event  = $input->findvalue('./Variable[2]/@name');
      my $action = (($mapList->findnodes(".//Right"))[0])->findvalue('./SchemaType[1]/@ref');
      my $eAttrQ = "./Properties/PropertyEntry/text()[starts-with(normalize-space(.), 'FSM_ATTR_EDGE')]";
      my $lAttrQ = "./Properties/PropertyEntry/text()[starts-with(normalize-space(.), 'FSM_ATTR_LABEL')]";
      my $eAttrN = ($mapList->findnodes($eAttrQ))[0];
      my $lAttrN = ($mapList->findnodes($lAttrQ))[0];
      my $eAttr;
      my $lAttr;

      if(defined($eAttrN))
      {
         $eAttr = $eAttrN->findvalue('.');
      }

      if(defined($eAttr))
      {
         $eAttr =~ m/"(.*)"/g;

         $eAttr = $1;
      }

      if(defined($lAttrN))
      {
         $lAttr = $lAttrN->findvalue('.');
      }

      if(defined($lAttr))
      {
         $lAttr =~ m/"(.*)"/g;

         $lAttr = $1;
      }

      my %tHash  = ("state" => $state, "event" => $event, "action" => $action, "eAttr" => $eAttr, "lAttr" => $lAttr);

      push(@transList, {%tHash});
   }
}

open(FSMFile, ">$outFile") or die("Unable to open $outFile for writing");

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

sub drawCondEdge
{
   my $src    = $_[0];
   my $origin = $_[1];

   my $thenAct = $condActHash{$src}{"then"};
   my $tLabel  = $condActHash{$src}{"tLabel"};
   my $elseAct = $condActHash{$src}{"else"};
   my $eLabel  = $condActHash{$src}{"eLabel"};
   my $teAttr  = $condActHash{$src}{"teAttr"};
   my $eeAttr  = $condActHash{$src}{"eeAttr"};
   my $tlAttr  = $condActHash{$src}{"tlAttr"};
   my $elAttr  = $condActHash{$src}{"elAttr"};

   my $thenTgtID;
   my $thenTgtLabel;
   my $elseTgtID;
   my $elseTgtLabel;

   if(exists $actionHash{$thenAct})
   {
      $thenTgtID    = $actionHash{$thenAct}{"target"};
      $thenTgtLabel = $actionHash{$thenAct}{"label"};
   }
   elsif(exists $condActHash{$thenAct})
   {
      &drawCondEdge($thenAct, $origin);

      $thenTgtID    = $condActHash{$thenAct}{"target"};
      $thenTgtLabel = $condActHash{$thenAct}{"label"};
   }
   else
   {
      print "MealyFSM: $src conditional then action $thenAct has not been previously defined\n";

      exit -1;
   }

   if(!defined($thenTgtID))
   {
      $thenTgtID = $origin;
   }

   if(exists $actionHash{$elseAct})
   {
      $elseTgtID    = $actionHash{$elseAct}{"target"};
      $elseTgtLabel = $actionHash{$elseAct}{"label"};
   }
   elsif(exists $condActHash{$elseAct})
   {
      &drawCondEdge($elseAct, $origin);

      $elseTgtID    = $condActHash{$elseAct}{"target"};
      $elseTgtLabel = $condActHash{$elseAct}{"label"};
   }
   else
   {
      print "MealyFSM: $src conditional else action $elseAct has not been previously defined\n";

      exit -1;
   }

   if(!defined($elseTgtID))
   {
      $elseTgtID = $origin;
   }

   if($diagram eq "DOT")
   {
      print FSMFile "   ", $src, " -> ", $thenTgtID,  " [label=\"";

      if(defined($tLabel))
      {
         print FSMFile $tLabel;
      }
      else
      {
         print FSMFile "yes";
      }

      print FSMFile "/\\n", $thenTgtLabel, "\"]\n";
      print FSMFile "   ", $src, " -> ", $elseTgtID,  " [label=\"";

      if(defined($eLabel))
      {
         print FSMFile $eLabel;
      }
      else
      {
         print FSMFile "no";
      }

      print FSMFile "/\\n", $elseTgtLabel, "\"";

      if(defined($teAttr))
      {
         print FSMFile " \"$teAttr\"";
      }

      if(defined($eeAttr))
      {
         print FSMFile " \"$eeAttr\"";
      }

      if(defined($tlAttr))
      {
         print FSMFile " \"$tlAttr\"";
      }

      if(defined($elAttr))
      {
         print FSMFile " \"$elAttr\"";
      }

      print FSMFile "]\n";
   }
   elsif($diagram eq "TikZ")
   {
      print FSMFile "   \\path (", &fixTexLabel($src), ") edge ";

      if(defined($teAttr))
      {
         print FSMFile "[$teAttr] ";
      }

      print FSMFile "node ";

      if(defined($tlAttr))
      {
         print FSMFile "[$tlAttr] ";
      }

      if(defined($tLabel))
      {
         print FSMFile "{", &fixTexText("$tLabel/$thenTgtLabel"), "} ";
      }
      else
      {
         print FSMFile "{", &fixTexText("yes/$thenTgtLabel"), "} ";
      }

      print FSMFile "(", &fixTexLabel($thenTgtID), ");\n";

      print FSMFile "   \\path (", &fixTexLabel($src), ") edge ";

      if(defined($eeAttr))
      {
         print FSMFile "[$eeAttr] ";
      }

      print FSMFile "node ";

      if(defined($elAttr))
      {
         print FSMFile "[$elAttr] ";
      }

      if(defined($eLabel))
      {
         print FSMFile "{", &fixTexText("$eLabel/$elseTgtLabel"), "} ";
      }
      else
      {
         print FSMFile "{", &fixTexText("no/$elseTgtLabel"), "} ";
      }

      print FSMFile "(", &fixTexLabel($elseTgtID), ");\n";
   }
}

if($diagram eq "DOT")
{
   print FSMFile "digraph \"$fsmID\"\n{\n";
}
elsif($diagram eq "TikZ")
{
   my $direcPath = "//Directive/Commands/Command/text()";
   my $attrQuery = "normalize-space($direcPath\[starts-with(normalize-space(.), 'TIKZ_PIC_ATTR')])";
   my $cmdQuery  = "normalize-space($direcPath\[starts-with(normalize-space(.), 'TIKZ_PIC_CMDS')])";
   my $attrStr   = $doc->findvalue($attrQuery);
   my $cmdStr    = $doc->findvalue($cmdQuery);

   print FSMFile "\\begin{tikzpicture}\n";
   print FSMFile "   [cond/.style={state,diamond}";

   if(defined($attrStr))
   {
      $attrStr =~ m/"(.*)"/g;

      print FSMFile ",\n    $1";
   }

   print FSMFile "]\n";

   print FSMFile "   \\tikzstyle{every state}=[ellipse]\n";

   if(defined($cmdStr))
   {
      $cmdStr =~ m/"(.*)"/g;

      print FSMFile "   $1\n";
   }

   print FSMFile "\n";
}

foreach my $node (@stateList)
{
   my $name  = $$node{"name"};
   my $label = $$node{"label"};
   my $pos   = $$node{"pos"};
   my $attr  = $$node{"attr"};

   if($diagram eq "DOT")
   {
      print FSMFile "   $name [label=\"$label\"";

      if($name eq $initID)
      {
         print FSMFile " shape=doubleoctagon";
      }

      if(defined($pos))
      {
         print FSMFile " pos=\"$pos\"";
      }

      if(defined($attr))
      {
         print FSMFile " \"$attr\"";
      }

      print FSMFile "]\n";
   }
   elsif($diagram eq "TikZ")
   {
      print FSMFile "   \\node[";

      if($name eq $initID)
      {
         print FSMFile "initial,";
      }

      print FSMFile "state";

      if(defined($attr))
      {
         print FSMFile ",$attr";
      }

      print FSMFile "] (", &fixTexLabel($name), ")";

      if(defined($pos))
      {
         print FSMFile " at ($pos)";
      }

      print FSMFile " {", &fixTexText($label), "};\n";
   }
}

if($diagram eq "TikZ")
{
   print FSMFile "\n";
}

foreach my $node (keys %condActHash)
{
   my $cLabel = $condActHash{$node}{"cLabel"};
   my $pos    = $condActHash{$node}{"pos"};
   my $attr   = $condActHash{$node}{"attr"};

   if($diagram eq "DOT")
   {
      print FSMFile "   $node [label=\"";

      if(defined($cLabel))
      {
         print FSMFile $cLabel;
      }
      else
      {
         print FSMFile $node;
      }

      print FSMFile "\"";

      if(defined($pos))
      {
         print FSMFile " pos=\"$pos\"";
      }

      if(defined($attr))
      {
         print FSMFile " \"$attr\"";
      }

      print FSMFile " shape=diamond]\n";
   }
   elsif($diagram eq "TikZ")
   {
      print FSMFile "   \\node[";

      print FSMFile "cond";

      if(defined($attr))
      {
         print FSMFile ",$attr";
      }

      print FSMFile "] (", &fixTexLabel($node), ")";

      if(defined($pos))
      {
         print FSMFile " at ($pos)";
      }

      print FSMFile " {";
      if(defined($cLabel))
      {
         print FSMFile &fixTexText($cLabel);
      }
      else
      {
         print FSMFile &fixTexText($node);
      }
      print FSMFile "};\n";
   }
}

if($diagram eq "TikZ")
{
   print FSMFile "\n";
}

foreach my $edge (@transList)
{
   my $state    = $$edge{"state"};
   my $event    = $$edge{"event"};
   my $action   = $$edge{"action"};
   my $eAttr    = $$edge{"eAttr"};
   my $lAttr    = $$edge{"lAttr"};
   my $evtLabel = $eventHash{$event};
   my $tgtLabel;
   my $tgtID;

   if(!defined($evtLabel))
   {
      print "MealyFSM: Event $event has not been previously defined\n";

      exit -1;
   }

   if(exists $actionHash{$action})
   {
      $tgtID    = $actionHash{$action}{"target"};
      $tgtLabel = $actionHash{$action}{"label"};
   }
   elsif(exists $condActHash{$action})
   {
      &drawCondEdge($action, $state);

      $tgtID    = $action;
      $tgtLabel = $condActHash{$action}{"nLabel"};
   }
   else
   {
      print "MealyFSM: Action $action has not been previously defined\n";

      exit -1;
   }

   if(!defined($tgtID))
   {
      $tgtID = $state;
   }

   if($diagram eq "DOT")
   {
      print FSMFile "   ", $state, " -> ", $tgtID, " [label=\"", $evtLabel, "/\\n", $tgtLabel, "\"";

      if(defined($eAttr))
      {
         print FSMFile " \"$eAttr\"";
      }

      if(defined($lAttr))
      {
         print FSMFile " \"$lAttr\"";
      }

      print FSMFile "]\n";
   }
   elsif($diagram eq "TikZ")
   {
      print FSMFile "   \\path (", &fixTexLabel($state), ") edge ";

      if(defined($eAttr))
      {
         print FSMFile "[$eAttr] ";
      }

      print FSMFile "node ";

      if(defined($lAttr))
      {
         print FSMFile "[$lAttr] ";
      }

      print FSMFile "{", &fixTexText("$evtLabel/$tgtLabel"), "} (", &fixTexLabel($tgtID), ");\n";
   }
}

if($diagram eq "DOT")
{
   print FSMFile "}\n";
}
elsif($diagram eq "TikZ")
{
   print FSMFile "\\end{tikzpicture}\n";
}
