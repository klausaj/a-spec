#! /usr/bin/perl

use warnings;
use strict;
use XML::LibXML;

my $NODE_LABEL_KEY   = "FSM_NODE_LABEL";
my $EVT_LABEL_KEY    = "FSM_EVT_LABEL";
my $ACTION_LABEL_KEY = "FSM_ACTION_LABEL";
my $COND_LABEL_KEY   = "FSM_COND_LABEL";
my $NODE_POS_KEY     = "FSM_NODE_POS";
my $NODE_ATTR_KEY    = "FSM_NODE_ATTR";
my $EDGE_ATTR_KEY    = "FSM_EDGE_ATTR";
my $EDGE_HIDE_KEY    = "FSM_EDGE_HIDE";
my $LABEL_ATTR_KEY   = "FSM_LABEL_ATTR";

my $PROPERTIES_P   = "//Properties/PropertyEntry/text()";
my $PROC_DEF_P     = "//Process/Processes/ProcDef";
my $GEN_PROC_DEF_P = "//Process/Processes/GenProcDef";

my $REL_PROP_P  = ".//Properties/PropertyEntry/text()";

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
my $PROC_VAR_Q       = "./DeclarationIdentifier/Variable";
my $PROC_FUNC_Q      = "./DeclarationIdentifier";
my $EVENT_VAR_Q      = "./DeclarationIdentifier/Variable";
my $EVENT_CHAN_Q     = "./DeclarationIdentifier";
my $DEF_EXPR_Q       = "./DefiningExpression/child::node()";
my $NODE_LABEL_Q     = "$REL_PROP_P [starts-with(normalize-space(.), '$NODE_LABEL_KEY')]";
my $EVT_LABEL_Q      = "$REL_PROP_P [starts-with(normalize-space(.), '$EVT_LABEL_KEY')]";
my $ACTION_LABEL_Q   = "$REL_PROP_P [starts-with(normalize-space(.), '$ACTION_LABEL_KEY')]";
my $COND_LABEL_Q     = "$REL_PROP_P [starts-with(normalize-space(.), '$COND_LABEL_KEY')]";
my $EVENT_DECL_Q     = "//Process/Declarations/Declaration[\@type='event']";
my $CHAN_DECL_Q      = "//Process/Declarations/Declaration[\@type='channel']";
my $NODE_POS_Q       = "$REL_PROP_P [starts-with(normalize-space(.), '$NODE_POS_KEY')]";
my $NODE_ATTR_Q      = "$REL_PROP_P [starts-with(normalize-space(.), '$NODE_ATTR_KEY')]";
my $EDGE_ATTR_Q      = "$REL_PROP_P [starts-with(normalize-space(.), '$EDGE_ATTR_KEY')]";
my $EDGE_HIDE_Q      = "$REL_PROP_P [starts-with(normalize-space(.), '$EDGE_HIDE_KEY')]";
my $LABEL_ATTR_Q     = "$REL_PROP_P [starts-with(normalize-space(.), '$LABEL_ATTR_KEY')]";

my $ANON_ID     = "CSP2FSM_ANON";
my $INIT_ID     = "CSP2FSM_INIT";

my $EXIT_QUAL = "FSM_EXIT";

my $STATE_KEY    = "FSM_STATE";
my $ACTION_KEY   = "FSM_ACTION";
my $COND_ACT_KEY = "FSM_CONDACT";
my $INIT_KEY     = "FSM_INIT";

my $anonCnt = 0;

my %nodeHash;
my %eventMap;
my @edgeList;
my $initState;

sub processStateProc#(stateNode) => void
{
   my $stateNode = $_[0];

   my $nodeType = $stateNode->getName();
   my $stateName;
   my $procDef;

   if($nodeType eq "Declaration")
   {
      my  $declType = $stateNode->getAttribute("type");

      if(($declType eq "proc") || ($declType eq "procfunc"))
      {
         $stateName = &getProcessName($stateNode);

         my $procDefQ  = "$PROC_DEF_P/attribute::name[normalize-space(.)='$stateName']/..";

         $procDef = ($stateNode->findnodes($procDefQ))[0];

         if(!defined $procDef)
         {
            my $genProcDefQ  = "$GEN_PROC_DEF_P/attribute::name[normalize-space(.)='$stateName']/..";

            $procDef = ($stateNode->findnodes($genProcDefQ))[0];
         }
      }
      else
      {
         print "Ignoring unknown state declaration type $declType\n";

         return;
      }
   }
   else
   {
      print "Ignoring unknown state declaration $nodeType\n";

      return;
   }

   my $exprChild = ($procDef->findnodes($DEF_EXPR_Q))[1];
   my @childList = &processStateProcExpr($exprChild, "=", "");

   $nodeHash{$stateName}{"tgtList"} = \@childList;
}

sub processActionProc#(actionNode) => void
{
   my $actionNode = $_[0];

   my $nodeType = $actionNode->getName();
   my $actionName;
   my $procDef;

   if($nodeType eq "Declaration")
   {
      my  $declType = $actionNode->getAttribute("type");

      if(($declType eq "proc") || ($declType eq "procfunc"))
      {
         $actionName = &getProcessName($actionNode);

         my $procDefQ = "$PROC_DEF_P/attribute::name[normalize-space(.)='$actionName']/..";

         $procDef = ($actionNode->findnodes($procDefQ))[0];

         if(!defined $procDef)
         {
            my $genProcDefQ  = "$GEN_PROC_DEF_P/attribute::name[normalize-space(.)='$actionName']/..";

            $procDef = ($actionNode->findnodes($genProcDefQ))[0];
         }
      }
      else
      {
         print "Ignoring unknown action declaration type $declType\n";

         return;
      }
   }
   else
   {
      print "Ignoring unknown action declaration $nodeType\n";

      return;
   }

   my $exprChild = ($procDef->findnodes($DEF_EXPR_Q))[1];
   my @childList = &processActionProcExpr($exprChild, "=", "");

   $nodeHash{$actionName}{"tgtList"} = \@childList;
}

sub getProcessName#(procNode) => procName
{
   my $procNode = $_[0];

   my $nodeType = $procNode->getName();
   my $stateName;

   if($nodeType eq "Declaration")
   {
      my  $declType = $procNode->getAttribute("type");

      if($declType eq "proc")
      {
         my $varNode = ($procNode->findnodes($PROC_VAR_Q))[0];

         return $varNode->getAttribute("name");
      }
      elsif($declType eq "procfunc")
      {
         my $idNode = ($procNode->findnodes($PROC_FUNC_Q))[0];

         return $idNode->getAttribute("name");
      }
      else
      {
         return undef;
      }
   }
   elsif($nodeType eq "ProcDef")
   {
      return $procNode->getAttribute("name");
   }
   else
   {
      return undef;
   }
}

sub getEventDeclName#(declNode) => eventName
{
   my $declNode = $_[0];

   my $nodeType = $declNode->getName();
   my $stateName;

   if($nodeType eq "Declaration")
   {
      my  $declType = $declNode->getAttribute("type");

      if($declType eq "event")
      {
         my $varNode = ($declNode->findnodes($EVENT_VAR_Q))[0];

         return $varNode->getAttribute("name");
      }
      elsif($declType eq "channel")
      {
         my $idNode = ($declNode->findnodes($EVENT_CHAN_Q))[0];

         return $idNode->getAttribute("name");
      }
      else
      {
         return undef;
      }
   }
   else
   {
      return undef;
   }
}

sub processStateProcExpr#(exprNode, lastOp, lastQual) => childList
{
   my $exprNode = $_[0];
   my $lastOp   = $_[1];
   my $lastQual = $_[2];

   my $exprType = $exprNode->getName();
   my $nextQual;
   my @tgtList;

   if(($lastQual ne $EXIT_QUAL) && (&isExitExpr($exprNode)))
   {
      $nextQual = $EXIT_QUAL;
   }
   else
   {
      $nextQual = $lastQual;
   }

   if($exprType eq "ExpressionOperator")
   {
      my $operName = $exprNode->getAttribute("name");

      if($operName eq "[]")
      {
         @tgtList = &processExtChoice($exprNode, $lastOp, $nextQual);
      }
      elsif($operName eq "->")
      {
         @tgtList = &processStatePThen($exprNode, $lastOp, $nextQual);
      }
      else
      {
         print "Unsupported state operator: $operName\n";
      }
   }
   elsif($exprType eq "ExpressionFunction")
   {
      @tgtList = &processStateNamedExpr($exprNode, $lastOp, $nextQual);
   }
   elsif($exprType eq "Variable")
   {
      @tgtList = &processStateNamedExpr($exprNode, $lastOp, $nextQual);
   }
   elsif($exprType eq "ReplicatedProcess")
   {
      @tgtList = &processStateReplProc($exprNode, $lastOp, $nextQual);
   }
   else
   {
      print "Unsupported state type: $exprType\n";

      @tgtList = ();
   }

   if((@tgtList > 0) && ($nextQual eq $EXIT_QUAL) && ($lastQual ne $nextQual))
   {
      foreach my $tgtHash (@tgtList)
      {
         my $evtLabelN   = ($exprNode->findnodes($EVT_LABEL_Q))[0];
         my $actLabelN   = ($exprNode->findnodes($ACTION_LABEL_Q))[0];
         my $condLabelN  = ($exprNode->findnodes($COND_LABEL_Q))[0];
         my $edgeAttrN   = ($exprNode->findnodes($EDGE_ATTR_Q))[0];
         my $labelAttrN  = ($exprNode->findnodes($LABEL_ATTR_Q))[0];
         my $edgeHideN   = ($exprNode->findnodes($EDGE_HIDE_Q))[0];

         if(defined $edgeHideN)
         {
            $$tgtHash{"hide"} = 1;
         }

         if(defined $evtLabelN)
         {
            my $evtLabel = $evtLabelN->findvalue('.');

            $evtLabel =~ m/$EVT_LABEL_KEY\s*(.*)\s/g;
            $evtLabel = $1;
            $evtLabel =~ s/"//g;

            $$tgtHash{"evt"} = $evtLabel;
         }

         if(defined $actLabelN)
         {
            my $actLabel = $actLabelN->findvalue('.');

            $actLabel =~ m/$ACTION_LABEL_KEY\s*(.*)\s/g;
            $actLabel = $1;
            $actLabel =~ s/"//g;

            $$tgtHash{"action"} = $actLabel;
         }

         if(defined $condLabelN)
         {
            my $condLabel = $condLabelN->findvalue('.');

            $condLabel =~ m/$COND_LABEL_KEY\s*(.*)\s/g;
            $condLabel = $1;
            $condLabel =~ s/"//g;

            $$tgtHash{"cond"} = $condLabel;
         }

         if(defined $edgeAttrN)
         {
            my $edgeAttr = $edgeAttrN->findvalue('.');

            $edgeAttr =~ m/$EDGE_ATTR_KEY\s*(.*)\s/g;
            $edgeAttr = $1;
            $edgeAttr =~ s/"//g;

            $$tgtHash{"eattr"} = $edgeAttr;
         }

         if(defined $labelAttrN)
         {
            my $labelAttr = $labelAttrN->findvalue('.');

            $labelAttr =~ m/$LABEL_ATTR_KEY\s*(.*)\s/g;
            $labelAttr = $1;
            $labelAttr =~ s/"//g;

            $$tgtHash{"lattr"} = $labelAttr;
         }
      }
   }

   return @tgtList;
}

sub processActionProcExpr#(exprNode, lastOp, lastQual) => childList
{
   my $exprNode = $_[0];
   my $lastOp   = $_[1];
   my $lastQual = $_[2];

   my $exprType = $exprNode->getName();
   my $nextQual;
   my @tgtList;

   if(($lastQual ne $EXIT_QUAL) && (&isExitExpr($exprNode)))
   {
      $nextQual = $EXIT_QUAL;
   }
   else
   {
      $nextQual = $lastQual;
   }

   if($exprType eq "ExpressionOperator")
   {
      my $operName = $exprNode->getAttribute("name");

      if($operName eq "|~|")
      {
         @tgtList = &processIntChoice($exprNode, $lastOp, $nextQual);
      }
      elsif($operName eq "->")
      {
         @tgtList = &processActionPThen($exprNode, $lastOp, $nextQual);
      }
      else
      {
         print "Unsupported operator: $operName\n";
      }
   }
   elsif($exprType eq "ExpressionFunction")
   {
      @tgtList = &processActionNamedExpr($exprNode, $lastOp, $nextQual);
   }
   elsif($exprType eq "Variable")
   {
      @tgtList = &processActionNamedExpr($exprNode, $lastOp, $nextQual);
   }
   elsif($exprType eq "ConditionalProcess")
   {
      @tgtList = &processCondProc($exprNode, $lastOp, $nextQual);
   }
   elsif($exprType eq "ReplicatedProcess")
   {
      @tgtList = &processActionReplProc($exprNode, $lastOp, $nextQual);
   }
   elsif($exprType eq "LetProc")
   {
      return &processActionLetProc($exprNode, $lastOp, $lastQual);
   }
   else
   {
      print "Unsupported type: $exprType\n";

      @tgtList = ();
   }

   if((@tgtList > 0) && ($nextQual eq $EXIT_QUAL) && ($lastQual ne $nextQual))
   {
      foreach my $tgtHash (@tgtList)
      {
         my $evtLabelN   = ($exprNode->findnodes($EVT_LABEL_Q))[0];
         my $actLabelN   = ($exprNode->findnodes($ACTION_LABEL_Q))[0];
         my $condLabelN  = ($exprNode->findnodes($COND_LABEL_Q))[0];
         my $edgeAttrN   = ($exprNode->findnodes($EDGE_ATTR_Q))[0];
         my $labelAttrN  = ($exprNode->findnodes($LABEL_ATTR_Q))[0];
         my $edgeHideN   = ($exprNode->findnodes($EDGE_HIDE_Q))[0];

         if(defined $edgeHideN)
         {
            $$tgtHash{"hide"} = 1;
         }

         if(defined $evtLabelN)
         {
            my $evtLabel = $evtLabelN->findvalue('.');

            $evtLabel =~ m/$EVT_LABEL_KEY\s*(.*)\s/g;
            $evtLabel = $1;
            $evtLabel =~ s/"//g;

            $$tgtHash{"evt"} = $evtLabel;
         }

         if(defined $actLabelN)
         {
            my $actLabel = $actLabelN->findvalue('.');

            $actLabel =~ m/$ACTION_LABEL_KEY\s*(.*)\s/g;
            $actLabel = $1;
            $actLabel =~ s/"//g;

            $$tgtHash{"action"} = $actLabel;
         }

         if(defined $condLabelN)
         {
            my $condLabel = $condLabelN->findvalue('.');

            $condLabel =~ m/$COND_LABEL_KEY\s*(.*)\s/g;
            $condLabel = $1;
            $condLabel =~ s/"//g;

            $$tgtHash{"cond"} = $condLabel;
         }

         if(defined $edgeAttrN)
         {
            my $edgeAttr = $edgeAttrN->findvalue('.');

            $edgeAttr =~ m/$EDGE_ATTR_KEY\s*(.*)\s/g;
            $edgeAttr = $1;
            $edgeAttr =~ s/"//g;

            $$tgtHash{"eattr"} = $edgeAttr;
         }

         if(defined $labelAttrN)
         {
            my $labelAttr = $labelAttrN->findvalue('.');

            $labelAttr =~ m/$LABEL_ATTR_KEY\s*(.*)\s/g;
            $labelAttr = $1;
            $labelAttr =~ s/"//g;

            $$tgtHash{"lattr"} = $labelAttr;
         }
      }
   }

   return @tgtList;
}

sub processStateNamedExpr#(exprNode, lastOp, lastQual) => childList
{
   my $exprNode = $_[0];
   my $lastOp   = $_[1];
   my $lastQUal = $_[2];

   my $exprType = $exprNode->getName();

   if($exprType eq "ExpressionFunction")
   {
      my $funcVarN = ($exprNode->findnodes($FUNC_VAR_Q))[0];
      my $funcName = $funcVarN->getAttribute("ident");

      if(exists $nodeHash{$funcName})
      {
         my %transHash;

         $transHash{"evt"} = "";
         $transHash{"tgt"} = $funcName;

         return {%transHash};
      }
      else
      {
         return ();
      }
   }
   elsif($exprType eq "Variable")
   {
      my $varName  = $exprNode->getAttribute("name");
      my %transHash;

      if(exists $nodeHash{$varName})
      {
         my %transHash;

         $transHash{"evt"} = "";
         $transHash{"tgt"} = $varName;

         return {%transHash};
      }
      else
      {
         return ();
      }
   }
   else
   {
      return ();
   }
}

sub processActionNamedExpr#(exprNode, lastOp, lastQual) => childList
{
   my $exprNode = $_[0];
   my $lastOp   = $_[1];
   my $lastQUal = $_[2];

   my $exprType = $exprNode->getName();

   if($exprType eq "ExpressionFunction")
   {
      my $funcVarN = ($exprNode->findnodes($FUNC_VAR_Q))[0];
      my $funcName = $funcVarN->getAttribute("ident");
      my %transHash;

      $transHash{"evt"} = "";
      $transHash{"tgt"} = $funcName;

      return {%transHash};
   }
   elsif($exprType eq "Variable")
   {
      my $varName  = $exprNode->getAttribute("name");
      my %transHash;

      $transHash{"evt"} = "";
      $transHash{"tgt"} = $varName;

      return {%transHash};
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

   #$stateHash{$id}{"label"} = $label;
   #$stateHash{$id}{"type"}  = $type;
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

sub addAllEdges#(dstList, src, type) => void
{
   my @dstList = @{$_[0]};
   my $src     = $_[1];
   my $type    = $_[2];

   foreach my $dst (@dstList)
   {
      my $evt = $$dst{"evt"};
      my $tgt = $$dst{"tgt"};

      &addEdge($src, $tgt, $evt, $type);
   }
}

sub processExtChoice#(procOper, lastOp, lastQual) => childList
{
   my $procOper = $_[0];
   my $lastOp   = $_[1];
   my $lastQual = $_[2];

   my $leftN   = ($procOper->findnodes($OPER_LEFT_Q))[1];
   my $rightN  = ($procOper->findnodes($OPER_RIGHT_Q))[1];
   my @leftL   = &processStateProcExpr($leftN, "[]", "");
   my @rightL  = &processStateProcExpr($rightN, "[]", "");

   return (@leftL, @rightL);
}

sub processIntChoice#(procOper, lastOp, lastQual) => childList
{
   my $procOper = $_[0];
   my $lastOp   = $_[1];
   my $lastQual = $_[2];

   my $leftN   = ($procOper->findnodes($OPER_LEFT_Q))[1];
   my $rightN  = ($procOper->findnodes($OPER_RIGHT_Q))[1];
   my @leftL   = &processActionProcExpr($leftN, "|~|", "");
   my @rightL  = &processActionProcExpr($rightN, "|~|", "");

   return (@leftL, @rightL);
}

sub processStatePThen#(procOper, lastOp, lastQual) => childList
{
   my $procOper = $_[0];
   my $lastOp   = $_[1];
   my $lastQual = $_[2];

   my $leftN     = ($procOper->findnodes($OPER_LEFT_Q))[1];
   my $rightN    = ($procOper->findnodes($OPER_RIGHT_Q))[1];

   if(&isNamedExpr($rightN))
   {
      my $rightName = &getExprName($rightN);
      my $eventName = &getEventName($leftN);
      my $eventLabel;
      my %eventHash;

      if(defined $eventMap{$eventName})
      {
         $eventLabel = $eventMap{$eventName};
      }
      else
      {
         $eventLabel = $eventName;
      }

      $eventHash{"evt"} = $eventLabel;
      $eventHash{"tgt"} = $rightName;

      return {%eventHash};
   }
   else
   {
      print "State transitions must be of the form event -> state\n";

      return ();
   }
}

sub processActionPThen#(procOper, lastOp, lastQual) => childList
{
   my $procOper = $_[0];
   my $lastOp   = $_[1];
   my $lastQual = $_[2];

   my $leftN     = ($procOper->findnodes($OPER_LEFT_Q))[1];
   my $rightN    = ($procOper->findnodes($OPER_RIGHT_Q))[1];
   my @rightL    = &processActionProcExpr($rightN, "->", "");

   return @rightL;
}

sub processCondProc#(condProc, lastOp, lastQual) => childList
{
   my $condProc = $_[0];
   my $lastOp   = $_[1];
   my $lastQual = $_[2];

   my @condN  = $condProc->findnodes($IF_COND_Q);
   my $thenN  = ($condProc->findnodes($IF_THEN_Q))[1];
   my $elseN  = ($condProc->findnodes($IF_ELSE_Q))[1];
   my @thenL;
   my @elseL;

   @thenL  = &processActionProcExpr($thenN, "condProc", "");

   if($elseN)
   {
      @elseL = &processActionProcExpr($elseN, "condProc", "");
   }

   if($elseN)
   {
      return (@thenL, @elseL);
   }
   else
   {
      return @thenL;
   }
}

sub processStateReplProc#(replProc, lastOp, lastQual) => childList
{
   my $replProc = $_[0];
   my $lastOp   = $_[1];
   my $lastQual = $_[2];

   my $replTypeN = ($replProc->findnodes($REPL_TYPE_Q))[0];
   my $replType  = $replTypeN->getAttribute("type");
   my $replN     = ($replProc->findnodes($REPL_EXPR_Q))[1];

   if($replType eq "External")
   {
      return &processExtRepl($replN, $lastOp, $lastQual);
   }
   else
   {
      print "Unknown state replicate type: $replType\n";

      return ();
   }
}

sub processActionReplProc#(replProc, lastOp, lastQual) => childList
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
   else
   {
      print "Unknown action replicate type: $replType\n";

      return ();
   }
}

sub processActionLetProc#(letProc, lastOp, lastQual) => childList
{
   my $letProc  = $_[0];
   my $lastOp   = $_[1];
   my $lastQual = $_[2];

   my $exprN   = ($letProc->findnodes($LET_EXPR_Q))[1];

   return &processActionProcExpr($exprN, "let", "");
}

sub processIntRepl#(replProc, lastOp, lastQual) => childList
{
   my $replProc = $_[0];
   my $lastOp   = $_[1];
   my $lastQual = $_[2];

   return &processActionProcExpr($replProc, "|~|*", "");
}

sub processExtRepl#(replProc, lastOp, lastQual) => childList
{
   my $replProc = $_[0];
   my $lastOp   = $_[1];
   my $lastQual = $_[2];

   return &processStateProcExpr($replProc, "[]*", "");
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

sub isExitExpr#(procExpr)
{
   my $procExpr = $_[0];

   my $exprType = $procExpr->getName();

   if($exprType eq "ConditionalProcess")
   {
      return 0;
   }
   elsif($exprType eq "ExpressionOperator")
   {
      my $operName = $procExpr->getAttribute("name");

      if($operName eq "->")
      {
         my $rightN = ($procExpr->findnodes($OPER_RIGHT_Q))[1];

         return &isExitExpr($rightN);
      }
      else
      {
         return 0;
      }
   }
   elsif($exprType eq "ReplicatedProcess")
   {
      my $replN = ($procExpr->findnodes($REPL_EXPR_Q))[1];

      return &isExitExpr($replN);
   }
   elsif(&isNamedExpr($procExpr))
   {
      return 1;
   }
   else
   {
      return 0;
   }
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

my $filename = $ARGV[0];

if(!defined($filename))
{
   print "Usage: csp2FSM.pl [Input file]\n";

   exit -1;
}

my $parser      = XML::LibXML->new();
my $doc         = $parser->parse_file($filename);
my $derivePath  = "//Directive/Commands/Command/text()";
my $deriveQuery = "normalize-space($derivePath\[starts-with(normalize-space(.), 'derive cspMealyFSM')])";
my $deriveStr   = $doc->findvalue($deriveQuery);

if(!defined($deriveStr))
{
   print "csp2FSM: Input file doesn't contiain csp2FSM directive\n";

   exit -1;
}

my @deriveTok = split(/ /, $deriveStr);

if(@deriveTok < 5)
{
   print "csp2FSM: Directive must be of the form: derive csp2FSM [Output type] [FSM id] [FSM output file]\n";

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
   print "csp2FSM: Diagram type must be one of (DOT, TikZ)\n";

   exit -1;
}

shift(@deriveTok);
shift(@deriveTok);
shift(@deriveTok);
shift(@deriveTok);

my $outFile = join(" ", @deriveTok);

$outFile =~ s/\"//g;

my $stateProp    = "$STATE_KEY $fsmID";
my $actionProp   = "$ACTION_KEY $fsmID";
my $condActProp  = "$COND_ACT_KEY $fsmID";
my $initProp     = "$INIT_KEY $fsmID";
my $stateQuery   = "$PROPERTIES_P [normalize-space(.)='$stateProp']/../../..";
my $actionQuery  = "$PROPERTIES_P [normalize-space(.)='$actionProp']/../../..";
my $condActQuery = "$PROPERTIES_P [normalize-space(.)='$condActProp']/../../..";
my $initQuery    = "$PROPERTIES_P [normalize-space(.)='$initProp']/../../..";
my @stateList    = $doc->findnodes($stateQuery);
my @actionList   = $doc->findnodes($actionQuery);
my @condActList  = $doc->findnodes($condActQuery);
my @eventList    = ($doc->findnodes($EVENT_DECL_Q), $doc->findnodes($CHAN_DECL_Q));
my $initN        = ($doc->findnodes($initQuery))[0];

foreach my $eventN (@eventList)
{
   my $evtName = &getEventDeclName($eventN);

   my $evtLabelN   = ($eventN->findnodes($EVT_LABEL_Q))[0];

   if(defined $evtLabelN)
   {
      my $evtLabel = $evtLabelN->findvalue('.');

      $evtLabel =~ m/$EVT_LABEL_KEY\s*(.*)\s/g;
      $evtLabel = $1;
      $evtLabel =~ s/"//g;

      $eventMap{$evtName} = $evtLabel;
   }
}

foreach my $stateN (@stateList)
{
   my $procName = &getProcessName($stateN);

   if(defined $procName)
   {
      my $nodeLabelN  = ($stateN->findnodes($NODE_LABEL_Q))[0];
      my $nodeAttrN   = ($stateN->findnodes($NODE_ATTR_Q))[0];
      my $nodePosN    = ($stateN->findnodes($NODE_POS_Q))[0];

      if(defined $nodeLabelN)
      {
         my $nodeLabel = $nodeLabelN->findvalue('.');

         $nodeLabel =~ m/$NODE_LABEL_KEY\s*(.*)\s/g;
         $nodeLabel = $1;
         $nodeLabel =~ s/"//g;

         $nodeHash{$procName}{"label"} = $nodeLabel;
      }
      else
      {
         $nodeHash{$procName}{"label"} = $procName;
      }

      if(defined $nodeAttrN)
      {
         my $nodeAttr = $nodeAttrN->findvalue('.');

         $nodeAttr =~ m/$NODE_ATTR_KEY\s*(.*)\s/g;
         $nodeAttr = $1;
         $nodeAttr =~ s/"//g;

         $nodeHash{$procName}{"attr"} = $nodeAttr;
      }

      if(defined $nodePosN)
      {
         my $nodePos = $nodePosN->findvalue('.');

         $nodePos =~ m/$NODE_POS_KEY\s*(.*)\s/g;
         $nodePos = $1;
         $nodePos =~ s/"//g;

         $nodeHash{$procName}{"pos"} = $nodePos;
      }

      $nodeHash{$procName}{"type"}  = $STATE_KEY;
   }
}

foreach my $actionN (@actionList)
{
   my $procName = &getProcessName($actionN);

   if(defined $procName)
   {
      my $actLabelN   = ($actionN->findnodes($ACTION_LABEL_Q))[0];

      if(defined $actLabelN)
      {
         my $actLabel = $actLabelN->findvalue('.');

         $actLabel =~ m/$ACTION_LABEL_KEY\s*(.*)\s/g;
         $actLabel = $1;
         $actLabel =~ s/"//g;

         $nodeHash{$procName}{"label"} = $actLabel;
      }
      else
      {
         $nodeHash{$procName}{"label"} = $procName;
      }

      $nodeHash{$procName}{"type"}  = $ACTION_KEY;
   }
}

foreach my $condActN (@condActList)
{
   my $procName = &getProcessName($condActN);

   if(defined $procName)
   {
      my $nodeLabelN  = ($condActN->findnodes($NODE_LABEL_Q))[0];
      my $nodeAttrN   = ($condActN->findnodes($NODE_ATTR_Q))[0];
      my $nodePosN    = ($condActN->findnodes($NODE_POS_Q))[0];

      if(defined $nodeLabelN)
      {
         my $nodeLabel = $nodeLabelN->findvalue('.');

         $nodeLabel =~ m/$NODE_LABEL_KEY\s*(.*)\s/g;
         $nodeLabel = $1;
         $nodeLabel =~ s/"//g;

         $nodeHash{$procName}{"label"} = $nodeLabel;
      }
      else
      {
         $nodeHash{$procName}{"label"} = $procName;
      }

      if(defined $nodeAttrN)
      {
         my $nodeAttr = $nodeAttrN->findvalue('.');

         $nodeAttr =~ m/$NODE_ATTR_KEY\s*(.*)\s/g;
         $nodeAttr = $1;
         $nodeAttr =~ s/"//g;

         $nodeHash{$procName}{"attr"} = $nodeAttr;
      }

      if(defined $nodePosN)
      {
         my $nodePos = $nodePosN->findvalue('.');

         $nodePos =~ m/$NODE_POS_KEY\s*(.*)\s/g;
         $nodePos = $1;
         $nodePos =~ s/"//g;

         $nodeHash{$procName}{"pos"} = $nodePos;
      }

      $nodeHash{$procName}{"type"}  = $COND_ACT_KEY;
   }
}

foreach my $stateN (@stateList)
{
   &processStateProc($stateN);
}

foreach my $actionN (@actionList)
{
   &processActionProc($actionN);
}

foreach my $condActN (@condActList)
{
   &processActionProc($condActN);
}

open(FSMFile, ">$outFile") or die("Unable to open $outFile for writing");

sub initToDOT
{
   if($initN)
   {
      $initState = &getProcessName($initN);
   }

   print FSMFile "   $INIT_ID [style=invis]\n";
}

sub nodeToDOT#(nodeName)
{
   my $nodeName = $_[0];

   my $nodeLabel = $nodeHash{$nodeName}{"label"};
   my $nodeType  = $nodeHash{$nodeName}{"type"};
   my $nodeAttr  = $nodeHash{$nodeName}{"attr"};
   my @tgtList   = @{$nodeHash{$nodeName}{"tgtList"}};

   if($nodeName eq $initState)
   {
      print FSMFile "   $INIT_ID -> $nodeName [label=\"Init\"]\n";
   }

   if(($nodeType eq $STATE_KEY) || ($nodeType eq $COND_ACT_KEY))
   {
      if($nodeType eq $STATE_KEY)
      {
         print FSMFile "   $nodeName [label=\"$nodeLabel\" shape=ellipse";
      }
      elsif($nodeType eq $COND_ACT_KEY)
      {
         print FSMFile "   $nodeName [label=\"$nodeLabel\" shape=diamond";
      }

      if(defined $nodeAttr && ($nodeAttr ne ""))
      {
         print FSMFile " $nodeAttr]\n";
      }
      else
      {
         print FSMFile "]\n";
      }
   }
}

sub edgesToDOT#($srcNode)
{
   my $srcNode = $_[0];

   my $nodeType = $nodeHash{$srcNode}{"type"};
   my @tgtList  = @{$nodeHash{$srcNode}{"tgtList"}};

   if($nodeType eq $ACTION_KEY)
   {
      return;
   }

   foreach my $transHash (@tgtList)
   {
      my $tgt = $$transHash{"tgt"};

      if(!defined $$transHash{"hide"} && defined $tgt && exists $nodeHash{$tgt})
      {
         my $tgtLabel   = $nodeHash{$tgt}{"label"};
         my $tgtType    = $nodeHash{$tgt}{"type"};
         my @tgtTgtList = @{$nodeHash{$tgt}{"tgtList"}};
         my $finalTgt;
         my $action;
         my $evt;

         if($nodeType eq $COND_ACT_KEY)
         {
            if(defined $$transHash{"cond"})
            {
               $evt = $$transHash{"cond"};
            }
            elsif(defined $$transHash{"evt"})
            {
               $evt = $$transHash{"evt"};
            }
            else
            {
               $evt = "";
            }

            if(defined $$transHash{"action"})
            {
               $action = $$transHash{"action"};
            }
            else
            {
               if($tgtType eq $ACTION_KEY)
               {
                  $action = $tgtLabel;
               }
               else
               {
                  $action = "";
               }
            }
         }
         else
         {
            if(defined $$transHash{"evt"})
            {
               $evt = $$transHash{"evt"};
            }
            else
            {
               $evt = "";
            }

            if(defined $$transHash{"action"})
            {
               $action = $$transHash{"action"};
            }
            else
            {
               if($tgtType eq $ACTION_KEY)
               {
                  $action = $tgtLabel;
               }
               else
               {
                  $action = "";
               }
            }
         }

         if($tgtType eq $ACTION_KEY)
         {
            my $tgtTgt = $tgtTgtList[0];

            $finalTgt = $$tgtTgt{"tgt"};
         }
         else
         {
            $finalTgt = $tgt;
         }

         if((defined $evt) && ($evt ne ""))
         {
            if((defined $action) && ($action ne ""))
            {
               print FSMFile "   ", $srcNode, " -> ", $finalTgt, " [label=\"", $evt, "/", $action, "\"";
            }
            else
            {
               print FSMFile "   ", $srcNode, " -> ", $finalTgt, " [label=\"", $evt, "\"";
            }
         }
         else
         {
            if((defined $action) && ($action ne ""))
            {
               print FSMFile "   ", $srcNode, " -> ", $finalTgt, " [label=\"", $action, "\"";
            }
            else
            {
               print FSMFile "   ", $srcNode, " -> ", $finalTgt, " [label=\"\"";
            }
         }

         my $edgeAttr = $$transHash{"eattr"};

         if((defined $edgeAttr) && ($edgeAttr ne ""))
         {
            print FSMFile " $edgeAttr]\n";
         }
         else
         {
            print FSMFile "]\n";
         }
      }
   }
}

sub doDOT
{
   print FSMFile "digraph \"$fsmID\"\n{\n";

   &initToDOT();

   foreach my $node (keys %nodeHash)
   {
      &nodeToDOT($node);
   }

   foreach my $node (keys %nodeHash)
   {
      &edgesToDOT($node);
   }

   print FSMFile "}\n";
}

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

sub initToTikZ
{
   if($initN)
   {
      $initState = &getProcessName($initN);
   }
}

sub nodeToTikZ#(nodeName)
{
   my $nodeName = $_[0];

   my $nodeLabel = $nodeHash{$nodeName}{"label"};
   my $nodeType  = $nodeHash{$nodeName}{"type"};
   my $nodeAttr  = $nodeHash{$nodeName}{"attr"};
   my $nodePos   = $nodeHash{$nodeName}{"pos"};
   my @tgtList   = @{$nodeHash{$nodeName}{"tgtList"}};

   if(($nodeType eq $STATE_KEY) || ($nodeType eq $COND_ACT_KEY))
   {
      if($nodeType eq $STATE_KEY)
      {
         print FSMFile "   \\node[";

         if($nodeName eq $initState)
         {
            print FSMFile "initial,";
         }

         print FSMFile "state";

         if(defined($nodeAttr))
         {
            print FSMFile ",$nodeAttr";
         }

         print FSMFile "] (", &fixTexLabel($nodeName), ")";

         if(defined($nodePos))
         {
            print FSMFile " at ($nodePos)";
         }

         print FSMFile " {", &fixTexText($nodeLabel), "};\n";
      }
      elsif($nodeType eq $COND_ACT_KEY)
      {
         print FSMFile "   \\node[cond";

         if(defined($nodeAttr))
         {
            print FSMFile ",$nodeAttr";
         }

         print FSMFile "] (", &fixTexLabel($nodeName), ")";

         if(defined($nodePos))
         {
            print FSMFile " at ($nodePos)";
         }

         print FSMFile " {";
         if(defined($nodeLabel))
         {
            print FSMFile &fixTexText($nodeLabel);
         }
         else
         {
            print FSMFile &fixTexText($nodeName);
         }
         print FSMFile "};\n";
      }
   }
}

sub edgesToTikZ#($srcNode)
{
   my $srcNode = $_[0];

   my $nodeType = $nodeHash{$srcNode}{"type"};
   my @tgtList  = @{$nodeHash{$srcNode}{"tgtList"}};

   if($nodeType eq $ACTION_KEY)
   {
      return;
   }

   foreach my $transHash (@tgtList)
   {
      my $tgt = $$transHash{"tgt"};

      if(defined $tgt && exists $nodeHash{$tgt})
      {
         my $tgtLabel   = $nodeHash{$tgt}{"label"};
         my $tgtType    = $nodeHash{$tgt}{"type"};
         my @tgtTgtList = @{$nodeHash{$tgt}{"tgtList"}};
         my $finalTgt;
         my $action;
         my $evt;

         if($nodeType eq $COND_ACT_KEY)
         {
            if(defined $$transHash{"cond"})
            {
               $evt = $$transHash{"cond"};
            }
            elsif(defined $$transHash{"evt"})
            {
               $evt = $$transHash{"evt"};
            }
            else
            {
               $evt = "";
            }

            if(defined $$transHash{"action"})
            {
               $action = $$transHash{"action"};
            }
            else
            {
               if($tgtType eq $ACTION_KEY)
               {
                  $action = $tgtLabel;
               }
               else
               {
                  $action = "";
               }
            }
         }
         else
         {
            if(defined $$transHash{"evt"})
            {
               $evt = $$transHash{"evt"};
            }
            else
            {
               $evt = "";
            }

            if(defined $$transHash{"action"})
            {
               $action = $$transHash{"action"};
            }
            else
            {
               if($tgtType eq $ACTION_KEY)
               {
                  $action = $tgtLabel;
               }
               else
               {
                  $action = "";
               }
            }
         }

         if($tgtType eq $ACTION_KEY)
         {
            my $tgtTgt = $tgtTgtList[0];

            $finalTgt = $$tgtTgt{"tgt"};
         }
         else
         {
            $finalTgt = $tgt;
         }

         my $edgeAttr  = $$transHash{"eattr"};
         my $labelAttr = $$transHash{"lattr"};
         my $edgeLabel;

         if((defined $evt) && ($evt ne ""))
         {
            if((defined $action) && ($action ne ""))
            {
               $edgeLabel = $evt . "/" . $action;
            }
            else
            {
               $edgeLabel = $evt;
            }
         }
         else
         {
            if((defined $action) && ($action ne ""))
            {
               $edgeLabel = $action;
            }
            else
            {
               $edgeLabel = "";
            }
         }

         print FSMFile "   \\path (", &fixTexLabel($srcNode), ") edge ";

         if(defined($edgeAttr))
         {
            print FSMFile "[$edgeAttr] ";
         }

         print FSMFile "node ";

         if(defined($labelAttr))
         {
            print FSMFile "[$labelAttr] ";
         }

         print FSMFile "{", &fixTexText("$edgeLabel"), "} (", &fixTexLabel($finalTgt), ");\n";
      }
   }
}

sub doTikZ
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

   &initToTikZ();

   foreach my $node (keys %nodeHash)
   {
      &nodeToTikZ($node);
   }

   foreach my $node (keys %nodeHash)
   {
      &edgesToTikZ($node);
   }

   print FSMFile "\\end{tikzpicture}\n";
}

if($diagram eq "DOT")
{
   &doDOT();
}
elsif($diagram eq "TikZ")
{
   &doTikZ();
}
