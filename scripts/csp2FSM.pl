#! /usr/bin/perl

use warnings;
use strict;
use XML::LibXML;

my $FUNC_VAR_Q       = "./Function/ExpressionIdent";
my $CHAN_VAR_Q       = "./Channel/ExpressionIdent";
my $OPER_LEFT_Q      = "./Left/child::node()";
my $OPER_RIGHT_Q     = "./Right/child::node()";
my $IF_COND_Q        = "./Conditionals";
my $IF_THEN_Q        = "./ThenProcess/child::node()";
my $IF_ELSE_Q        = "./ElseProcess/child::node()";
my $REPL_TYPE_Q      = "./ReplType";
my $REPL_EXPR_Q      = "./Expression/child::node()";
my $LET_EXPR_Q       = "./Expression/child::node()";
my $INIT_PROC_P      = "//Process/Processes/ProcDef/Properties/PropertyEntry/text()";
my $INIT_GEN_PROC_P  = "//Process/Processes/GenProcDef/Properties/PropertyEntry/text()";

my $ANON_ID     = "CSP2FSM_ANON";
my $INIT_ID     = "CSP2FSM_INIT";

my $SEQ1_QUAL  = "CSP2FSM_SEQ1";
my $SEQ2_QUAL  = "CSP2FSM_SEQ2";
my $INTER_QUAL = "CSP2FSM_/\\";

my $anonCnt = 0;

my %stateHash;
my @edgeList;
my $initState;
my $fsmID;
my $doc;

sub processProcDef#(procDefNode) => void
{
   my $procDefNode = $_[0];

   my $procName  = $procDefNode->getAttribute("name");
   my $defExprQ  = "./DefiningExpression/child::node()";
   my $exprChild = ($procDefNode->findnodes($defExprQ))[1];

   $stateHash{$procName}{"label"} = $procName;
   $stateHash{$procName}{"type"}  = "defined";

   if(!defined $initState)
   {
      $initState = $procName;
   }

   my @childList = &processProcExpr($exprChild, "=", "");

   &addAllEdges(\@childList, $procName, "", "");
}

sub processProcExpr#(exprNode, lastOp, lastQual) => childList
{
   my $exprNode = $_[0];
   my $lastOp   = $_[1];
   my $lastQual = $_[2];

   my $exprType = $exprNode->getName();

   if($exprType eq "ExpressionOperator")
   {
      my $operName = $exprNode->getAttribute("name");

      if($operName eq "[]")
      {
         return &processExtChoice($exprNode, $lastOp, $lastQual);
      }
      elsif($operName eq "|~|")
      {
         return &processIntChoice($exprNode, $lastOp, $lastQual);
      }
      elsif($operName eq "||")
      {
         return &processParComp($exprNode, $lastOp, $lastQual);
      }
      elsif($operName eq "pseq")
      {
         return &processSeqComp($exprNode, $lastOp, $lastQual);
      }
      elsif($operName eq "|||")
      {
         return &processInterleaveComp($exprNode, $lastOp, $lastQual);
      }
      elsif($operName eq "[||]")
      {
         return &processIFParComp($exprNode, $lastOp, $lastQual, $lastQual);
      }
      elsif($operName eq "/\\")
      {
         return &processInterruptComp($exprNode, $lastOp, $lastQual);
      }
      elsif($operName eq "->")
      {
         return &processPThen($exprNode, $lastOp, $lastQual);
      }
      else
      {
         print "Unsupported operator: $operName\n";
      }
   }
   elsif($exprType eq "ExpressionFunction")
   {
      return &processNamedExpr($exprNode, $lastOp, $lastQual);
   }
   elsif($exprType eq "Variable")
   {
      return &processNamedExpr($exprNode, $lastOp, $lastQual);
   }
   elsif($exprType eq "ConditionalProcess")
   {
      return &processCondProc($exprNode, $lastOp, $lastQual);
   }
   elsif($exprType eq "ReplicatedProcess")
   {
      return &processReplProc($exprNode, $lastOp, $lastQual);
   }
   elsif($exprType eq "LetProc")
   {
      return &processLetProc($exprNode, $lastOp, $lastQual);
   }
   else
   {
      print "Unsupported type: $exprType\n";

      return ();
   }
}
sub processNamedExpr#(exprNode, lastOp, lastQual) => childList
{
   my $exprNode = $_[0];
   my $lastOp   = $_[1];
   my $lastQUal = $_[2];

   my $exprType = $exprNode->getName();

   if($exprType eq "ExpressionFunction")
   {
      my $funcVarN = ($exprNode->findnodes($FUNC_VAR_Q))[0];
      my $funcName = $funcVarN->getAttribute("ident");

      if(!exists $stateHash{$funcName})
      {
         $stateHash{$funcName}{"label"} = $funcName;
         $stateHash{$funcName}{"type"}  = "named";
      }

      return ($funcName);
   }
   elsif($exprType eq "Variable")
   {
      my $varName  = $exprNode->getAttribute("name");

      if(!exists $stateHash{$varName})
      {
         $stateHash{$varName}{"label"} = $varName;
         $stateHash{$varName}{"type"}  = "named";
      }

      return ($varName);
   }
   else
   {
      return ();
   }
}

sub addAnonNode#(type) => nodeID
{
   my $type  = $_[0];

   my $newNode = $ANON_ID . $anonCnt;

   $anonCnt = $anonCnt + 1;

   &addNode($newNode, "", $type);

   return $newNode;
}

sub addNode#(id, label, type) => void
{
   my $id    = $_[0];
   my $label = $_[1];
   my $type  = $_[2];

   $stateHash{$id}{"label"} = $label;
   $stateHash{$id}{"type"}  = $type;
}

sub addEdge#(src, dst, evt, type) => void
{
   my $src  = $_[0];
   my $dst  = $_[1];
   my $evt  = $_[2];
   my $type = $_[3];

   my %edgeHash = ("src" => $src, "dst" => $dst, "evt" => $evt, "type" => $type);

   push(@edgeList, {%edgeHash});
}

sub addAllEdges#(dstList, src, evt, type) => void
{
   my @dstList = @{$_[0]};
   my $src     = $_[1];
   my $evt     = $_[2];
   my $type    = $_[3];

   foreach my $dst (@dstList)
   {
      &addEdge($src, $dst, $evt, $type);
   }
}

sub processExtChoice#(procOper, lastOp, lastQual) => childList
{
   my $procOper = $_[0];
   my $lastOp   = $_[1];
   my $lastQual = $_[2];

   my $leftN   = ($procOper->findnodes($OPER_LEFT_Q))[1];
   my $rightN  = ($procOper->findnodes($OPER_RIGHT_Q))[1];
   my $newNode;

   if($lastOp ne "[]")
   {
      $newNode = &addAnonNode("ext");
   }

   my @leftL  = &processProcExpr($leftN, "[]", "");
   my @rightL = &processProcExpr($rightN, "[]", "");

   if(defined $newNode)
   {
      &addAllEdges([@leftL, @rightL], $newNode, "", "");

      return ($newNode);
   }
   else
   {
      return (@leftL, @rightL);
   }
}

sub processIntChoice#(procOper, lastOp, lastQual) => childList
{
   my $procOper = $_[0];
   my $lastOp   = $_[1];
   my $lastQual = $_[2];

   my $leftN   = ($procOper->findnodes($OPER_LEFT_Q))[1];
   my $rightN  = ($procOper->findnodes($OPER_RIGHT_Q))[1];
   my $newNode;

   if($lastOp ne "|~|")
   {
      $newNode = &addAnonNode("unstable");
   }

   my @leftL  = &processProcExpr($leftN, "|~|", "");
   my @rightL = &processProcExpr($rightN, "|~|", "");

   if(defined $newNode)
   {
      &addAllEdges([@leftL, @rightL], $newNode, "tau", "");

      return ($newNode);
   }
   else
   {
      return (@leftL, @rightL);
   }
}

sub processParComp#(procOper, lastOp, lastQual) => childList
{
   my $procOper = $_[0];
   my $lastOp   = $_[1];
   my $lastQual = $_[2];

   my $leftN   = ($procOper->findnodes($OPER_LEFT_Q))[1];
   my $rightN  = ($procOper->findnodes($OPER_RIGHT_Q))[1];
   my $newNode;

   if($lastOp ne "||")
   {
      $newNode = &addAnonNode("parComp");
   }

   my @leftL  = &processProcExpr($leftN, "||", "");
   my @rightL = &processProcExpr($rightN, "||", "");

   if(defined $newNode)
   {
      &addAllEdges([@leftL, @rightL], $newNode, "", "");

      return ($newNode);
   }
   else
   {
      return (@leftL, @rightL);
   }
}

sub processSeqComp#(procOper, lastOp, lastQual) => childList
{
   my $procOper = $_[0];
   my $lastOp   = $_[1];
   my $lastQual = $_[2];

   my $leftN   = ($procOper->findnodes($OPER_LEFT_Q))[1];
   my $rightN  = ($procOper->findnodes($OPER_RIGHT_Q))[1];
   my $newNode = &addAnonNode("seqComp");

   my @leftL  = &processProcExpr($leftN, "pseq", "");
   my @rightL = &processProcExpr($rightN, "pseq", "");

   if(defined $newNode)
   {
      &addAllEdges(\@leftL, $newNode, "", $SEQ1_QUAL);
      &addAllEdges(\@rightL, $newNode, "", $SEQ2_QUAL);

      return ($newNode);
   }
   else
   {
      return (@leftL, @rightL);
   }
}

sub processInterleaveComp#(procOper, lastOp, lastQual) => childList
{
   my $procOper = $_[0];
   my $lastOp   = $_[1];
   my $lastQual = $_[2];

   my $leftN   = ($procOper->findnodes($OPER_LEFT_Q))[1];
   my $rightN  = ($procOper->findnodes($OPER_RIGHT_Q))[1];
   my $newNode;

   if($lastOp ne "|||")
   {
      $newNode = &addAnonNode("interPar");
   }

   my @leftL  = &processProcExpr($leftN, "|||", "");
   my @rightL = &processProcExpr($rightN, "|||", "");

   if(defined $newNode)
   {
      &addAllEdges([@leftL, @rightL], $newNode, "", "");

      return ($newNode);
   }
   else
   {
      return (@leftL, @rightL);
   }
}

sub processIFParComp#(procOper, lastOp, lastQual) => childList
{
   my $procOper = $_[0];
   my $lastOp   = $_[1];
   my $lastQual = $_[2];

   my $leftN   = ($procOper->findnodes($OPER_LEFT_Q))[1];
   my $rightN  = ($procOper->findnodes($OPER_RIGHT_Q))[1];
   my $qual    = "";
   my $newNode;

   if(($lastOp ne "[||]") || ($lastQual ne $qual))
   {
      $newNode = &addAnonNode("ifPar");

      $stateHash{$newNode}{"alph"} = $qual;
   }

   my @leftL  = &processProcExpr($leftN, "[||]", $qual);
   my @rightL = &processProcExpr($rightN, "[||]", $qual);

   if(defined $newNode)
   {
      &addAllEdges([@leftL, @rightL], $newNode, "", "");

      return ($newNode);
   }
   else
   {
      return (@leftL, @rightL);
   }
}

sub processInterruptComp#(procOper, lastOp, lastQual) => childList
{
   my $procOper = $_[0];
   my $lastOp   = $_[1];
   my $lastQual = $_[2];

   my $leftN   = ($procOper->findnodes($OPER_LEFT_Q))[1];
   my $rightN  = ($procOper->findnodes($OPER_RIGHT_Q))[1];
   my $newNode = &addAnonNode("interrupt");

   my @leftL  = &processProcExpr($leftN, "/\\", "");
   my @rightL = &processProcExpr($rightN, "/\\", "");

   if(defined $newNode)
   {
      &addAllEdges(\@leftL, $newNode, "", "");
      &addAllEdges(\@rightL, $newNode, "", $INTER_QUAL);

      return ($newNode);
   }
   else
   {
      return (@leftL, @rightL);
   }
}

sub processPThen#(procOper, lastOp, lastQual) => childList
{
   my $procOper = $_[0];
   my $lastOp   = $_[1];
   my $lastQual = $_[2];

   my $leftN     = ($procOper->findnodes($OPER_LEFT_Q))[1];
   my $rightN    = ($procOper->findnodes($OPER_RIGHT_Q))[1];
   my $eventName = &getEventName($leftN);
   my $newNode   = &addAnonNode("stable");
   my @rightL    = &processProcExpr($rightN, "->", "");

   if(defined $newNode)
   {
      &addAllEdges(\@rightL, $newNode, $eventName, "");

      return ($newNode);
   }
   else
   {
      return @rightL;
   }
}

sub processCondProc#(condProc, lastOp, lastQual) => childList
{
   my $condProc = $_[0];
   my $lastOp   = $_[1];
   my $lastQual = $_[2];

   my @condN  = $condProc->findnodes($IF_COND_Q);
   my $thenN  = ($condProc->findnodes($IF_THEN_Q))[1];
   my $elseN  = ($condProc->findnodes($IF_ELSE_Q))[1];
   my $newNode;

   if($lastOp ne "condProc")
   {
      $newNode = &addAnonNode("unstable");
   }

   my @thenL;
   my @elseL;

   @thenL  = &processProcExpr($thenN, "condProc", "");

   if($elseN)
   {
      @elseL = &processProcExpr($elseN, "condProc", "");
   }

   if(defined $newNode)
   {
      &addAllEdges(\@thenL, $newNode, "tau", "");

      if($elseN)
      {
         &addAllEdges(\@elseL, $newNode, "tau", "");
      }

      return ($newNode);
   }
   else
   {
      if($elseN)
      {
         return (@thenL, @elseL);
      }
      else
      {
         return @thenL;
      }
   }
}

sub processReplProc#(replProc, lastOp, lastQual) => childList
{
   my $replProc = $_[0];
   my $lastOp   = $_[1];
   my $lastQual = $_[2];

   my $replTypeN = ($replProc->findnodes($REPL_TYPE_Q))[0];
   my $replType  = $replTypeN->getAttribute("type");
   my $replN     = ($replProc->findnodes($REPL_EXPR_Q))[1];

   if($replType eq "Internal")
   {
      return &processIntRepl($replN, $lastOp, $lastQual);
   }
   elsif($replType eq "External")
   {
      return &processExtRepl($replN, $lastOp, $lastQual);
   }
   elsif($replType eq "Parallel")
   {
      return &processParRepl($replN, $lastOp, $lastQual);
   }
   elsif($replType eq "Interleave")
   {
      return &processInterParRepl($replN, $lastOp, $lastQual);
   }
   elsif($replType eq "InterfaceParallel")
   {
      return &processIFParRepl($replN, $lastOp, $lastQual);
   }
   else
   {
      print "Unknown replicate type: $replType\n";

      return ();
   }
}

sub processIntRepl#(replProc, lastOp, lastQual) => childList
{
   my $replProc = $_[0];
   my $lastOp   = $_[1];
   my $lastQual = $_[2];

   my $newNode = &addAnonNode("unstable");

   $stateHash{$newNode}{"repl"} = 1;

   my @replL  = &processProcExpr($replProc, "|~|*", "");

   if(defined $newNode)
   {
      &addAllEdges(\@replL, $newNode, "tau", "");

      return ($newNode);
   }
   else
   {
      return @replL;
   }
}

sub processExtRepl#(replProc, lastOp, lastQual) => childList
{
   my $replProc = $_[0];
   my $lastOp   = $_[1];
   my $lastQual = $_[2];

   my $newNode = &addAnonNode("ext");

   $stateHash{$newNode}{"repl"} = 1;

   my @replL = &processProcExpr($replProc, "[]*", "");

   if(defined $newNode)
   {
      &addAllEdges(\@replL, $newNode, "", "");

      return ($newNode);
   }
   else
   {
      return @replL;
   }
}

sub processParRepl#(replProc, lastOp, lastQual) => childList
{
   my $replProc = $_[0];
   my $lastOp   = $_[1];
   my $lastQual = $_[2];

   my $newNode = &addAnonNode("parComp");

   $stateHash{$newNode}{"repl"} = 1;

   my @replL = &processProcExpr($replProc, "||*", "");

   if(defined $newNode)
   {
      &addAllEdges(\@replL, $newNode, "", "");

      return ($newNode);
   }
   else
   {
      return @replL;
   }
}

sub processInterParRepl#(replProc, lastOp, lastQual) => childList
{
   my $replProc = $_[0];
   my $lastOp   = $_[1];
   my $lastQual = $_[2];

   my $newNode = &addAnonNode("interPar");

   $stateHash{$newNode}{"repl"} = 1;

   my @replL = &processProcExpr($replProc, "|||*", "");

   if(defined $newNode)
   {
      &addAllEdges(\@replL, $newNode, "", "");

      return ($newNode);
   }
   else
   {
      return @replL;
   }
}

sub processIFParRepl#(replProc, lastOp, lastQual) => childList
{
   my $replProc = $_[0];
   my $lastOp   = $_[1];
   my $lastQual = $_[2];

   my $newNode = &addAnonNode("ifPar");
   my $qual    = "";

   $stateHash{$newNode}{"repl"} = 1;
   $stateHash{$newNode}{"alph"} = $qual;

   my @replL = &processProcExpr($replProc, "[||]*", $qual);

   if(defined $newNode)
   {
      &addAllEdges(\@replL, $newNode, "", "");

      return ($newNode);
   }
   else
   {
      return @replL;
   }
}

sub processLetProc#(letProc, lastOp, lastQual) => childList
{
   my $letProc  = $_[0];
   my $lastOp   = $_[1];
   my $lastQual = $_[2];

   my $exprN   = ($letProc->findnodes($LET_EXPR_Q))[1];
   my $newNode = &addAnonNode("local");

   my @letL  = &processProcExpr($exprN, "let", "");

   if(defined $newNode)
   {
      &addAllEdges(\@letL, $newNode, "tau", "");

      return ($newNode);
   }
   else
   {
      return @letL;
   }
}

sub getEventName#(evt)
{
   my $evt = $_[0];

   my $evtType  = $evt->getName();

   if($evtType eq "Variable")
   {
      return $evt->getAttribute("name");
   }
   elsif($evtType eq "ChannelApplication")
   {
      my $chanVar = ($evt->findnodes($CHAN_VAR_Q))[0];

      return $chanVar->getAttribute("ident");
   }
   else
   {
      return undef;
   }
}

sub isInternalOp#(procExpr)
{
   my $procExpr = $_[0];

   my $exprType = $procExpr->getName();

   if($exprType eq "ExpressionOperator")
   {
      my $operName = $procExpr->getAttribute("name");

      if($operName eq "|~|")
      {
         return 1;
      }
   }
   elsif($exprType eq "ReplicatedProcess")
   {
      my $replTypeN = ($procExpr->findnodes($REPL_TYPE_Q))[0];
      my $replType  = $replTypeN->getAttribute("type");

      if($replType eq "Internal")
      {
         return 1;
      }
   }

   return 0;
}

sub isCondProc#(procExpr)
{
   my $procExpr = $_[0];

   my $exprType = $procExpr->getName();

   if($exprType eq "ConditionalProcess")
   {
      return 1;
   }

   return 0;
}

sub isNamedExpr#(procExpr)
{
   my $procExpr = $_[0];

   my $exprType = $procExpr->getName();

   if($exprType eq "ExpressionFunction")
   {
      return 1;
   }
   elsif($exprType eq "Variable")
   {
      return 1;
   }

   return 0;
}

sub getExprName#(procExpr)
{
   my $procExpr = $_[0];

   my $exprType = $procExpr->getName();

   if($exprType eq "ExpressionFunction")
   {
      my $funcVarN = ($procExpr->findnodes($FUNC_VAR_Q))[0];
      my $funcName = $funcVarN->getAttribute("ident");

      return $funcName;
   }
   elsif($exprType eq "Variable")
   {
      my $varName = $procExpr->getAttribute("name");

      return $varName;
   }
   else
   {
      return undef;
   }
}

sub initToDOT
{
   my $initProcQ = "$INIT_PROC_P\[normalize-space(.)='FSM_INIT $fsmID']/../../..";
   my $initProcN = ($doc->findnodes($initProcQ))[0];

   if($initProcN)
   {
      $initState = $initProcN->getAttribute("name");
   }

   print FSMFile "   $INIT_ID [style=invis]\n";
}

sub stateToDOT#(stateName)
{
   my $stateName = $_[0];

   my $stateLabel = $stateHash{$stateName}{"label"};
   my $stateType  = $stateHash{$stateName}{"type"};

   if($stateName eq $initState)
   {
      print FSMFile "   $INIT_ID -> $stateName [label=\"Init\"]\n";
   }

   if($stateType eq "unstable")
   {
      print FSMFile "   $stateName [label=\"$stateLabel\" shape=diamond]\n";
   }
   elsif($stateType eq "ext")
   {
      print FSMFile "   $stateName [label=\"$stateLabel\" shape=box height=.3 width=.3]\n";
   }
   elsif($stateType eq "stable")
   {
      print FSMFile "   $stateName [label=\"$stateLabel\" shape=ellipse]\n";
   }
   elsif($stateType eq "named")
   {
      print FSMFile "   $stateName [label=\"$stateLabel\" shape=invhouse]\n";
   }
   elsif($stateType eq "defined")
   {
      print FSMFile "   $stateName [label=\"$stateLabel\" shape=octagon]\n";
   }
   elsif($stateType eq "parComp")
   {
      print FSMFile "   $stateName [label=\"||\" shape=parallelogram height=.2 width=.35]\n";
   }
   elsif($stateType eq "interPar")
   {
      print FSMFile "   $stateName [label=\"|||\" shape=parallelogram height=.2 width=.35]\n";
   }
   elsif($stateType eq "ifPar")
   {
      my $alph  = $stateHash{$stateName}{"alph"};

      print FSMFile "   $stateName [label=\"[|$alph|]\" shape=parallelogram height=.2 width=.35]\n";
   }
   elsif($stateType eq "local")
   {
      print FSMFile "   $stateName [label=\"$stateLabel\" shape=Mdiamond]\n";
   }
   elsif($stateType eq "seqComp")
   {
      print FSMFile "   $stateName [label=\"$stateLabel\" shape=Mcircle height=.3 width=.3]\n";
   }
   elsif($stateType eq "interrupt")
   {
      print FSMFile "   $stateName [label=\"$stateLabel\" shape=triangle height=.3 width=.3]\n";
   }
   else
   {
      print FSMFile "   $stateName [label=\"$stateLabel\" shape=doubleoctagon]\n";
   }
}

sub edgeToDOT#($edgeHash)
{
   my $edgeHash = $_[0];

   my $src       = $$edgeHash{"src"};
   my $evt       = $$edgeHash{"evt"};
   my $dst       = $$edgeHash{"dst"};
   my $srcType   = $stateHash{$src}{"type"};
   my $dstType   = $stateHash{$dst}{"type"};
   my $edgeType  = $$edgeHash{"type"};
   my $arrowHead = "normal";
   my $arrowTail = "none";
   my $lineStyle = "solid";

   if($edgeType eq $INTER_QUAL)
   {
      $arrowTail = "odiamond";
   }
   elsif($edgeType eq $SEQ1_QUAL)
   {
      $arrowTail = "tee"
   }
   elsif($edgeType eq $SEQ2_QUAL)
   {
      $arrowTail = "teetee"
   }

   if($srcType eq "unstable")
   {
      $evt = "tau";
   }

   if($evt eq "")
   {
      $lineStyle = "dashed";
      $arrowHead = "onormal";
   }

   if($stateHash{$dst}{"repl"})
   {
      $arrowHead  = "crow";
   }

   print FSMFile "   ", $src, " -> ", $dst, " [label=\"", $evt, "\" style=$lineStyle ";
   print FSMFile "dir=both arrowtail=$arrowTail arrowhead=$arrowHead]\n";
}

sub doDOT
{
   print FSMFile "digraph \"$fsmID\"\n{\n";

   &initToDOT();

   foreach my $state (keys %stateHash)
   {
      &stateToDOT($state);
   }

   foreach my $edgeHash (@edgeList)
   {
      &edgeToDOT($edgeHash);
   }

   print FSMFile "}\n";
}

my $filename = $ARGV[0];

if(!defined($filename))
{
   print "Usage: csp2FSM.pl [Input file]\n";

   exit -1;
}

my $parser = XML::LibXML->new();

$doc = $parser->parse_file($filename);

my $derivePath  = "//Directive/Commands/Command/text()";
my $deriveQuery = "$derivePath\[starts-with(normalize-space(.), 'derive csp2FSM')]/..";
my @deriveList  = $doc->findnodes($deriveQuery);

for my $deriveNode (@deriveList)
{
   my $deriveStr   = $deriveNode->findvalue("normalize-space(.)");

   if(!defined($deriveStr))
   {
      print "csp2FSM: Input file doesn't contiain csp2FSM directive\n";

      exit -1;
   }

   my @deriveTok = split(/ /, $deriveStr);

   if(@deriveTok < 5)
   {
      print "csp2FSM: Directive must be of the form: derive csp2FSM [strict | greedy] [FSM id] [FSM output file]\n";

      exit -1;
   }

   my $diagram = $deriveTok[2];

   $fsmID = $deriveTok[3];

   if($diagram =~ m/^strict$/i)
   {
      $diagram = "strict";
   }
   elsif($diagram =~ m/^greedy$/i)
   {
      $diagram = "greedy";
   }
   else
   {
      print "csp2FSM: Diagram type must be one of (strict, greedy)\n";

      exit -1;
   }

   shift(@deriveTok);
   shift(@deriveTok);
   shift(@deriveTok);
   shift(@deriveTok);

   my $outFile = join(" ", @deriveTok);

   $outFile =~ s/\"//g;

   my $defQuery    = "//Process/Processes/ProcDef";
   my $genDefQuery = "//Process/Processes/GenProcDef";

   if($diagram eq "strict")
   {
      my $idProp   = "FSM_ID $fsmID";
      my $idQuery  = "/Properties/PropertyEntry/text()[normalize-space(.)='$idProp']/../../..";

      $defQuery    = $defQuery . $idQuery;
      $genDefQuery = $genDefQuery . $idQuery;
   }

   my @procDefs    = $doc->findnodes($defQuery);
   my @genProcDefs = $doc->findnodes($genDefQuery);

   $anonCnt   = 0;
   %stateHash = ();
   @edgeList  = ();
   $initState = ();

   foreach my $procDefN (@procDefs)
   {
      &processProcDef($procDefN);
   }

   foreach my $procDefN (@genProcDefs)
   {
      &processProcDef($procDefN);
   }

   open(FSMFile, ">$outFile") or die("Unable to open $outFile for writing");

   &doDOT();
}
