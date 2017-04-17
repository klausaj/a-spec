/*******************************************************************************
 *  Copyright (c) 2009, A-Spec Project                                         *
 *  All rights reserved.                                                       *
 *                                                                             *
 *  Redistribution and use in source and binary forms, with or without         *
 *  modification, are permitted provided that the following conditions         *
 *  are met:                                                                   *
 *      - Redistributions of source code must retain the above copyright       *
 *        notice, this list of conditions and the following disclaimer.        *
 *      - Redistributions in binary form must reproduce the above copyright    *
 *        notice, this list of conditions and the following disclaimer in the  *
 *        documentation and/or other materials provided with the distribution. *
 *      - Neither the name of the A-Spec Project nor the names of its          *
 *        contributors may be used to endorse or promote products derived from *
 *        this software without specific prior written permission.             *
 *                                                                             *
 *  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS        *
 *  "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED  *
 *  TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR *
 *  PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR          *
 *  CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,      *
 *  EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,        *
 *  PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR         *
 *  PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF     *
 *  LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING       *
 *  NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS         *
 *  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.               *
 *******************************************************************************/

#include <string.h>
#include <stdarg.h>
#include <stdlib.h>
#include <stdio.h>
#include <fcntl.h>

#ifdef WIN32
   #include "arch/mingw/a-spec_mingw.h"
#endif

#include "a-specc/a-specc_api.h"

static UINT32  astID    = 0;
static FILE    *outFile = NULL;

static TreeType  *tmpTree = NULL;

static UINT32  typeLen   = 0;
static INT8   *typeBuff = NULL;

static void listToDOT(LinkList *nodeList, UINT32 parent, INT8 *edgeLabel);
static UINT32 schemaToDOT(SchemaNode *ast, UINT32 parent);
static UINT32 genSchemaToDOT(GenSchemaNode *ast, UINT32 parent);
static UINT32 axDefToDOT(AxDefNode *ast, UINT32 parent);
static UINT32 genDefToDOT(GenDefNode *ast, UINT32 parent);
static UINT32 constToDOT(ConstraintNode *ast, UINT32 parent);
static UINT32 basicToDOT(BasicDefNode *ast, UINT32 parent);
static UINT32 basicEntryToDOT(BasicEntryNode *ast, UINT32 parent);
static UINT32 typeDefToDOT(TypeDefNode *ast, UINT32 parent);
static UINT32 typeEntryToDOT(TypeEntryNode *ast, UINT32 parent);
static UINT32 freeToDOT(FreeTypeNode *ast, UINT32 parent);
static UINT32 freeEntryToDOT(FreeEntryNode *ast, UINT32 parent);
static UINT32 declToDOT(DeclarationNode *ast, UINT32 parent);
static UINT32 procAliasToDOT(ProcAliasNode *ast, UINT32 parent);
static UINT32 chanAliasToDOT(ChanAliasNode *ast, UINT32 parent);
static UINT32 predToDOT(PredicateNode *ast, UINT32 parent);
static UINT32 exprToDOT(SyntaxTree *ast, UINT32 parent, INT8 *inEdge);
static UINT32 exprOpToDOT(ExprOpNode *ast, UINT32 parent, INT8 *inEdge);
static UINT32 exprFuncToDOT(ExprFuncNode *ast, UINT32 parent, INT8 *inEdge);
static UINT32 variableToDOT(VariableNode *ast, UINT32 parent, INT8 *inEdge);
static UINT32 exprLiteralToDOT(ExprLiteralNode *ast, UINT32 parent, INT8 *inEdge);
static UINT32 exprIdentToDOT(ExprIdentNode *ast, UINT32 parent, INT8 *inEdge);
static UINT32 genIdentToDOT(ExprGenIdentNode *ast, UINT32 parent, INT8 *inEdge);
static UINT32 exprIfToDOT(CondExprNode *ast, UINT32 parent, INT8 *inEdge);
static UINT32 tupleToDOT(TupleNode *ast, UINT32 parent, INT8 *inEdge);
static UINT32 crossToDOT(CrossNode *ast, UINT32 parent, INT8 *inEdge);
static UINT32 bindToDOT(SchemaBindNode *ast, UINT32 parent, INT8 *inEdge);
static UINT32 bindEntryToDOT(BindEntryNode *ast, UINT32 parent, INT8 *inEdge);
static UINT32 selectToDOT(SelectNode *ast, UINT32 parent, INT8 *inEdge);
static UINT32 schTypeToDOT(SchemaTypeNode *ast, UINT32 parent, INT8 *inEdge);
static UINT32 setDispToDOT(SetDispNode *ast, UINT32 parent, INT8 *inEdge);
static UINT32 seqDispToDOT(SeqDispNode *ast, UINT32 parent, INT8 *inEdge);
static UINT32 uptoToDOT(UptoNode *ast, UINT32 parent, INT8 *inEdge);
static UINT32 setCompToDOT(SetCompNode *ast, UINT32 parent, INT8 *inEdge);
static UINT32 lambdaToDOT(LambdaNode *ast, UINT32 parent, INT8 *inEdge);
static UINT32 muToDOT(MuNode *ast, UINT32 parent, INT8 *inEdge);
static UINT32 letExprToDOT(LetExprNode *ast, UINT32 parent, INT8 *inEdge);
static UINT32 predTypeToDOT(SyntaxTree *ast, UINT32 parent);
static UINT32 predOpToDOT(PredOpNode *ast, UINT32 parent);
static UINT32 predRelToDOT(PredRelNode *ast, UINT32 parent);
static UINT32 predFuncToDOT(PredFuncNode *ast, UINT32 parent);
static UINT32 predLiteralToDOT(PredLiteralNode *ast, UINT32 parent);
static UINT32 predQuantToDOT(PredQuantNode *ast, UINT32 parent);
static UINT32 letPredToDOT(LetPredNode *ast, UINT32 parent);
static UINT32 schemaAppToDOT(SchemaAppNode *ast, UINT32 parent);
static UINT32 predIfToDOT(CondPredNode *ast, UINT32 parent);
static UINT32 procToDOT(ProcessNode *ast, UINT32 parent);
static UINT32 procDefToDOT(ProcDefNode *ast, UINT32 parent);
static UINT32 genProcDefToDOT(GenProcDefNode *ast, UINT32 parent);
static UINT32 chanApplToDOT(ChanApplNode *ast, UINT32 parent, INT8 *inEdge);
static UINT32 chanFieldToDOT(ChanFieldNode *ast, UINT32 parent);
static UINT32 replProcToDOT(ReplProcNode *ast, UINT32 parent, INT8 *inEdge);
static UINT32 letProcToDOT(LetProcNode *ast, UINT32 parent, INT8 *inEdge);
static UINT32 procIfToDOT(CondProcNode *ast, UINT32 parent, INT8 *inEdge);

static void appendTypeStr(INT8 *new)
{
   if((strlen(typeBuff) + strlen(new)) >= typeLen)
   {
      INT8  *tmpBuff = typeBuff;

      typeBuff = malloc(1024 + typeLen);
      typeLen  = typeLen + 1024;

      memset(typeBuff, 0, typeLen);

      strcpy(typeBuff, tmpBuff);
   }

   strcat(typeBuff, new);
}

static void doTypeStr(TreeType *src)
{
   if(src == NULL)
   {
      return;
   }

   LinkList  *list = NULL;

   switch(src->nodeType)
   {
      case SCHEMA_TYPE:
         list = ((SchemaType *) src)->typeList;

         appendTypeStr("@(");

         while(list != NULL)
         {
            doTypeStr(list->object);

            list = list->next;

            if(list != NULL)
            {
               appendTypeStr(",");
            }
         }

         appendTypeStr(")");
      break;

      case SCHEMA_ENTRY_TYPE:
         appendTypeStr(((SchemaEntry *) src)->entryID);
         appendTypeStr("=(");
         doTypeStr(((SchemaEntry *) src)->entryType);
         appendTypeStr(")");
      break;

      case BASIC_TYPE:
         appendTypeStr("*");
         appendTypeStr(((BasicType *) src)->basicID);
      break;

      case GEN_TYPE:
         appendTypeStr("&");
         appendTypeStr(((GenType *) src)->genID);
      break;

      case SET_TYPE:
         appendTypeStr("$(");
         doTypeStr(((SetType *) src)->setType);
         appendTypeStr(")");
      break;

      case TUPLE_TYPE:
         appendTypeStr("#(");

         list = ((TupleType *) src)->typeList;

         while(list != NULL)
         {
            doTypeStr(list->object);

            list = list->next;

            if(list != NULL)
            {
               appendTypeStr(",");
            }
         }

         appendTypeStr(")");
      break;

      default:
      return;
   }
}

static void getTypeStr(TreeType *src)
{
   if((src == NULL) || (!exportType))
   {
      return;
   }

   memset(typeBuff, 0, typeLen);

   doTypeStr(src);
}

static INT8 *decorToStr(DecorType type, UINT8 count)
{
  INT8  *retStr = malloc(9);

  memset(retStr, 0, 9);

  if(type == DECOR_NULL)
  {
     free(retStr);

     return NULL;
  }
  else if(type == POST_IN)
  {
     strncpy(retStr, "?", 1);

     return retStr;
  }
  else if(type == POST_OUT)
  {
     strncpy(retStr, "!", 1);

     return retStr;
  }
  else if(type == POST_PRI)
  {
     if(count == 0)
     {
        free(retStr);

        return NULL;
     }

     strncpy(retStr, "'", 1);

     if(count > 1)
     {
        sprintf(retStr, "%s%d", retStr, count);
     }

     return retStr;
  }
  else if(type == PRE_DELTA)
  {
     if(count == 0)
     {
        free(retStr);

        return NULL;
     }

     strncpy(retStr, "delta", 5);

     if(count > 1)
     {
        sprintf(retStr, "%s%d", retStr, count);
     }

     return retStr;
  }

  return NULL;
}

static INT8 *dotFix(INT8 *src)
{
   if(src == NULL)
   {
      return NULL;
   }

   INT8  *brk = strpbrk(src, "\"\\");
   INT8  *ret = NULL;

   if(brk == NULL)
   {
      return strdup(src);
   }
   else if(brk == src)
   {
      INT8  *post = dotFix(&(brk[1]));

      if(brk[0] == '"')
      {
         asprintf((char **) &ret, "\\\"%s", post);
      }
      else if(brk[0] == '\\')
      {
         asprintf((char **) &ret, "\\\\%s", post);
      }

      free(post);
   }
   else
   {
      UINT32  preLen = brk - src;
      INT8    *pre   = strndup(src, preLen);
      INT8    *post  = dotFix(&(brk[1]));

      if(brk[0] == '"')
      {
         asprintf((char **) &ret, "%s\\\"%s", pre, post);
      }
      else if(brk[0] == '\\')
      {
         asprintf((char **) &ret, "%s\\\\%s", pre, post);
      }

      free(pre);
      free(post);
   }

   return ret;
}

static UINT32 getASTNum()
{
   astID = astID + 1;

   return astID;
}

static void dotWrite(INT8 *fmt, ...)
{
   va_list  argList;

   va_start(argList, fmt);
   vfprintf(outFile, fmt, argList);
   fprintf(outFile, "\n");
}

static void dotIWrite(INT8 *fmt, ...)
{
   va_list  argList;

   va_start(argList, fmt);
   fprintf(outFile, "   ");
   vfprintf(outFile, fmt, argList);
   fprintf(outFile, "\n");
}

static UINT32 addNode(UINT32 parent, INT8 *nodeLabel, INT8 *edgeLabel)
{
   UINT32  astID    = getASTNum();
   INT8    *dotNode = dotFix(nodeLabel);
   INT8    *dotEdge = dotFix(edgeLabel);

   if(tmpTree == NULL)
   {
      dotIWrite("%d [label=\"%s\"]", astID, dotNode);
   }
   else
   {
      getTypeStr(tmpTree);
      dotIWrite("%d [label=\"%s\\n%s\"]", astID, dotNode, typeBuff);
   }

   dotIWrite("%d -> %d [label=\"%s\"]", parent, astID, dotEdge);

   if(dotNode != NULL)
   {
      free(dotNode);
   }

   if(dotEdge != NULL)
   {
      free(dotEdge);
   }

   tmpTree = NULL;

   return astID;
}

static UINT32 addUnknownNode(UINT32 parent, UINT32 nodeType, INT8 *edgeLabel)
{
   UINT32  astID    = getASTNum();
   INT8    *dotEdge = dotFix(edgeLabel);

   if(tmpTree == NULL)
   {
      dotIWrite("%d [label=\"%d\", shape=hexagon]", astID, nodeType);
   }
   else
   {
      getTypeStr(tmpTree);
      dotIWrite("%d [label=\"%d\\n%s\", shape=hexagon]", astID, nodeType, typeBuff);
   }

   if(edgeLabel == NULL)
   {
      dotIWrite("%d -> %d [label=unknown]", parent, astID);
   }
   else
   {
      dotIWrite("%d -> %d [label=\"%s-unknown\"]", parent, astID, edgeLabel);
   }

   tmpTree = NULL;

   if(dotEdge != NULL)
   {
      free(dotEdge);
   }

   return astID;
}

static UINT32 schemaToDOT(SchemaNode *ast, UINT32 parent)
{
   if(!exportCheck(getLayer(ast->props)))
   {
      return 0;
   }

   tmpTree = ast->treeType;

   UINT32  schID  = addNode(parent, ast->name, "schema");

   if(ast->decls != NULL)
   {
      UINT32  declID = addNode(schID, "Declarations", "");

      listToDOT(ast->decls, declID, NULL);
   }

   if(ast->preds != NULL)
   {
      UINT32  predID = addNode(schID, "Predicates", "");

      listToDOT(ast->preds, predID, NULL);
   }

   return schID;
}

static UINT32 genSchemaToDOT(GenSchemaNode *ast, UINT32 parent)
{
   if(!exportCheck(getLayer(ast->props)))
   {
      return 0;
   }

   tmpTree = ast->treeType;

   UINT32  schID  = addNode(parent, ast->name, "schema");

   LinkList  *syms = ast->syms;

   if(syms != NULL)
   {
      UINT32  genID = addNode(schID, "Generics", "");

      while(syms != NULL)
      {
         addNode(genID, (INT8 *) syms->object, "sym");

         syms = syms->next;
      }
   }

   if(ast->decls != NULL)
   {
      UINT32  declID = addNode(schID, "Declarations", "");

      listToDOT(ast->decls, declID, NULL);
   }

   if(ast->preds != NULL)
   {
      UINT32  predID = addNode(schID, "Predicates", "");

      listToDOT(ast->preds, predID, NULL);
   }

   return schID;
}

static UINT32 constToDOT(ConstraintNode *ast, UINT32 parent)
{
   if(!exportCheck(getLayer(ast->props)))
   {
      return 0;
   }

   tmpTree = ast->treeType;

   UINT32  constID  = addNode(parent, ast->name, "constraint");

   if(ast->preds != NULL)
   {
      UINT32  predID = addNode(constID, "Predicates", "");

      listToDOT(ast->preds, predID, NULL);
   }

   return constID;
}

static UINT32 axDefToDOT(AxDefNode *ast, UINT32 parent)
{
   if(!exportCheck(getLayer(ast->props)))
   {
      return 0;
   }

   tmpTree = ast->treeType;

   UINT32  defID  = addNode(parent, ast->name, "axdef");

   if(ast->decls != NULL)
   {
      UINT32  declID = addNode(defID, "Declarations", "");

      listToDOT(ast->decls, declID, NULL);
   }

   if(ast->preds != NULL)
   {
      UINT32  predID = addNode(defID, "Predicates", "");

      listToDOT(ast->preds, predID, NULL);
   }

   return defID;
}

static UINT32 genDefToDOT(GenDefNode *ast, UINT32 parent)
{
   if(!exportCheck(getLayer(ast->props)))
   {
      return 0;
   }

   tmpTree = ast->treeType;

   UINT32  defID  = addNode(parent, ast->name, "gendef");

   LinkList  *syms = ast->syms;

   if(syms != NULL)
   {
      UINT32  genID = addNode(defID, "Generics", "");

      while(syms != NULL)
      {
         addNode(genID, (INT8 *) syms->object, "sym");

         syms = syms->next;
      }
   }

   if(ast->decls != NULL)
   {
      UINT32  declID = addNode(defID, "Declarations", "");

      listToDOT(ast->decls, declID, NULL);
   }

   if(ast->preds != NULL)
   {
      UINT32  predID = addNode(defID, "Predicates", "");

      listToDOT(ast->preds, predID, NULL);
   }

   return defID;
}

static UINT32 basicToDOT(BasicDefNode *ast, UINT32 parent)
{
   if(!exportCheck(getLayer(ast->props)))
   {
      return 0;
   }

   tmpTree = ast->treeType;

   UINT32  defID  = addNode(parent, ast->name, "basic");

   if(ast->entries != NULL)
   {
      UINT32  typeID = addNode(defID, "Types", "");

      listToDOT(ast->entries, typeID, NULL);
   }

   return defID;
}

static UINT32 basicEntryToDOT(BasicEntryNode *ast, UINT32 parent)
{
   tmpTree = ast->treeType;

   UINT32  defID  = addNode(parent, ast->name, "type");

   return defID;
}

static UINT32 typeDefToDOT(TypeDefNode *ast, UINT32 parent)
{
   if(!exportCheck(getLayer(ast->props)))
   {
      return 0;
   }

   tmpTree = ast->treeType;

   UINT32  defID  = addNode(parent, ast->name, "type def");

   if(ast->entries != NULL)
   {
      UINT32  typeID = addNode(defID, "Types", "");

      listToDOT(ast->entries, typeID, NULL);
   }

   return defID;
}

static UINT32 typeEntryToDOT(TypeEntryNode *ast, UINT32 parent)
{
   tmpTree = ast->treeType;

   UINT32  defID  = addNode(parent, ast->name, "type");

   if(ast->preGen != NULL)
   {
      addNode(defID, ast->preGen, "pre gen");
   }

   if(ast->postGen != NULL)
   {
      addNode(defID, ast->postGen, "post gen");
   }

   exprToDOT(ast->defExpr, defID, "def expr");

   return defID;
}

static UINT32 freeToDOT(FreeTypeNode *ast, UINT32 parent)
{
   if(!exportCheck(getLayer(ast->props)))
   {
      return 0;
   }

   tmpTree = ast->treeType;

   UINT32  defID  = addNode(parent, ast->name, "free type");

   if(ast->entries != NULL)
   {
      UINT32  typeID = addNode(defID, "Types", "");

      listToDOT(ast->entries, typeID, NULL);
   }

   return defID;
}

static UINT32 freeEntryToDOT(FreeEntryNode *ast, UINT32 parent)
{
   tmpTree = ast->treeType;

   UINT32  defID  = addNode(parent, ast->name, "type");

   LinkList  *freeVars = ast->freeVars;

   if(freeVars != NULL)
   {
      UINT32  varID = addNode(defID, "Free Vars", "");

      while(freeVars != NULL)
      {
         INT8  *name = varToString((VariableNode *) freeVars->object);

         addNode(varID, name, "var");

         free(name);

         freeVars = freeVars->next;
      }
   }

   return defID;
}

static UINT32 exprOpToDOT(ExprOpNode *ast, UINT32 parent, INT8 *inEdge)
{
   tmpTree = ast->treeType;

   INT8  *edgeLabel = NULL;
   INT8  *defLabel  = "expr op";

   if(inEdge == NULL)
   {
      edgeLabel = strdup(defLabel);
   }
   else
   {
      edgeLabel = malloc(strlen(defLabel) + strlen(inEdge) + 2);

      sprintf(edgeLabel, "%s-%s", inEdge, defLabel);
   }

   UINT32  opID = addNode(parent, ast->opName, edgeLabel);

   exprToDOT(ast->left, opID, "left");

   if(ast->qualifier != NULL)
   {
      exprToDOT(ast->qualifier, opID, "qualifier");
   }

   exprToDOT(ast->right, opID, "right");

   free(edgeLabel);

   return opID;
}

static UINT32 exprFuncToDOT(ExprFuncNode *ast, UINT32 parent, INT8 *inEdge)
{
   tmpTree = ast->treeType;

   INT8  *edgeLabel = NULL;
   INT8  *defLabel  = "expr func";

   if(inEdge == NULL)
   {
      edgeLabel = strdup(defLabel);
   }
   else
   {
      edgeLabel = malloc(strlen(defLabel) + strlen(inEdge) + 2);

      sprintf(edgeLabel, "%s-%s", inEdge, defLabel);
   }

   UINT32  funcID = addNode(parent, "Function", edgeLabel);

   exprToDOT(ast->funcExpr, funcID, "def expr");
   exprToDOT(ast->params, funcID, "param");

   free(edgeLabel);

   return funcID;
}

static UINT32 variableToDOT(VariableNode *ast, UINT32 parent, INT8 *inEdge)
{
   tmpTree = ast->treeType;

   INT8  *edgeLabel = NULL;
   INT8  *defLabel  = "var";

   if(inEdge == NULL)
   {
      edgeLabel = strdup(defLabel);
   }
   else
   {
      edgeLabel = malloc(strlen(defLabel) + strlen(inEdge) + 2);

      sprintf(edgeLabel, "%s-%s", inEdge, defLabel);
   }

   INT8   *varStr   = ast->name;
   INT8   *decorStr = decorToStr(ast->postDecor, ast->postCnt);
   UINT32  varID     = addNode(parent, varStr, edgeLabel);

   if(decorStr != NULL)
   {
      addNode(varID, decorStr, "decor");

      free(decorStr);
   }

   free(varStr);
   free(edgeLabel);

   return varID;
}

static UINT32 exprLiteralToDOT(ExprLiteralNode *ast, UINT32 parent, INT8 *inEdge)
{
   tmpTree = ast->treeType;

   INT8  *edgeLabel = NULL;
   INT8  *defLabel  = "literal";

   if(inEdge == NULL)
   {
      edgeLabel = strdup(defLabel);
   }
   else
   {
      edgeLabel = malloc(strlen(defLabel) + strlen(inEdge) + 2);

      sprintf(edgeLabel, "%s-%s", inEdge, defLabel);
   }

   UINT32  litID = addNode(parent, ast->value, edgeLabel);

   free(edgeLabel);

   return litID;
}

static UINT32 exprIdentToDOT(ExprIdentNode *ast, UINT32 parent, INT8 *inEdge)
{
   tmpTree = ast->treeType;

   INT8  *edgeLabel = NULL;
   INT8  *defLabel  = "ident";

   if(inEdge == NULL)
   {
      edgeLabel = strdup(defLabel);
   }
   else
   {
      edgeLabel = malloc(strlen(defLabel) + strlen(inEdge) + 2);

      sprintf(edgeLabel, "%s-%s", inEdge, defLabel);
   }

   UINT32  identID = addNode(parent, ast->ident, edgeLabel);

   if(ast->preSpec != NULL)
   {
      exprToDOT(ast->preSpec, identID, "pre spec");
   }

   if(ast->postSpec != NULL)
   {
      exprToDOT(ast->postSpec, identID, "post spec");
   }

   if(ast->specList != NULL)
   {
      UINT32  specID = addNode(identID, "Specifiers", "");

      listToDOT(ast->specList, specID, "spec expr");
   }

   free(edgeLabel);

   return identID;
}

static UINT32 genIdentToDOT(ExprGenIdentNode *ast, UINT32 parent, INT8 *inEdge)
{
   tmpTree = ast->treeType;

   INT8  *edgeLabel = NULL;
   INT8  *defLabel  = "gen ident";

   if(inEdge == NULL)
   {
      edgeLabel = strdup(defLabel);
   }
   else
   {
      edgeLabel = malloc(strlen(defLabel) + strlen(inEdge) + 2);

      sprintf(edgeLabel, "%s-%s", inEdge, defLabel);
   }

   UINT32  identID = addNode(parent, ast->ident, edgeLabel);

   free(edgeLabel);

   return identID;
}

static UINT32 exprIfToDOT(CondExprNode *ast, UINT32 parent, INT8 *inEdge)
{
   tmpTree = ast->treeType;

   INT8  *edgeLabel = NULL;
   INT8  *defLabel  = "expr cond";

   if(inEdge == NULL)
   {
      edgeLabel = strdup(defLabel);
   }
   else
   {
      edgeLabel = malloc(strlen(defLabel) + strlen(inEdge) + 2);

      sprintf(edgeLabel, "%s-%s", inEdge, defLabel);
   }

   UINT32  ifID = addNode(parent, "if", edgeLabel);

   listToDOT(ast->condList, ifID, "cond");
   exprToDOT(ast->thenExpr, ifID, "then");
   exprToDOT(ast->elseExpr, ifID, "else");

   free(edgeLabel);

   return ifID;
}

static UINT32 tupleToDOT(TupleNode *ast, UINT32 parent, INT8 *inEdge)
{
   tmpTree = ast->treeType;

   INT8  *edgeLabel = NULL;
   INT8  *defLabel  = "tuple";

   if(inEdge == NULL)
   {
      edgeLabel = strdup(defLabel);
   }
   else
   {
      edgeLabel = malloc(strlen(defLabel) + strlen(inEdge) + 2);

      sprintf(edgeLabel, "%s-%s", inEdge, defLabel);
   }

   UINT32  tupleID = addNode(parent, "Tuple", edgeLabel);

   listToDOT(ast->exprList, tupleID, "element");

   free(edgeLabel);

   return tupleID;
}

static UINT32 crossToDOT(CrossNode *ast, UINT32 parent, INT8 *inEdge)
{
   tmpTree = ast->treeType;

   INT8  *edgeLabel = NULL;
   INT8  *defLabel  = "cross";

   if(inEdge == NULL)
   {
      edgeLabel = strdup(defLabel);
   }
   else
   {
      edgeLabel = malloc(strlen(defLabel) + strlen(inEdge) + 2);

      sprintf(edgeLabel, "%s-%s", inEdge, defLabel);
   }

   UINT32  crossID = addNode(parent, "Cross", edgeLabel);

   listToDOT(ast->exprList, crossID, "element");

   free(edgeLabel);

   return crossID;
}

static UINT32 bindToDOT(SchemaBindNode *ast, UINT32 parent, INT8 *inEdge)
{
   tmpTree = ast->treeType;

   INT8  *edgeLabel = NULL;
   INT8  *defLabel  = "binding";

   if(inEdge == NULL)
   {
      edgeLabel = strdup(defLabel);
   }
   else
   {
      edgeLabel = malloc(strlen(defLabel) + strlen(inEdge) + 2);

      sprintf(edgeLabel, "%s-%s", inEdge, defLabel);
   }

   UINT32  bindID = addNode(parent, "Schema Binding", edgeLabel);

   listToDOT(ast->bindList, bindID, NULL);

   free(edgeLabel);

   return bindID;
}

static UINT32 bindEntryToDOT(BindEntryNode *ast, UINT32 parent, INT8 *inEdge)
{
   tmpTree = ast->treeType;

   INT8  *edgeLabel = NULL;
   INT8  *defLabel  = "entry";

   if(inEdge == NULL)
   {
      edgeLabel = strdup(defLabel);
   }
   else
   {
      edgeLabel = malloc(strlen(defLabel) + strlen(inEdge) + 2);

      sprintf(edgeLabel, "%s-%s", inEdge, defLabel);
   }

   UINT32  entryID = addNode(parent, "Binding", edgeLabel);

   variableToDOT(ast->var, entryID, NULL);
   exprToDOT(ast->expr, entryID, "value");

   free(edgeLabel);

   return entryID;
}

static UINT32 selectToDOT(SelectNode *ast, UINT32 parent, INT8 *inEdge)
{
   tmpTree = ast->treeType;

   INT8  *edgeLabel = NULL;
   INT8  *defLabel  = "select";

   if(inEdge == NULL)
   {
      edgeLabel = strdup(defLabel);
   }
   else
   {
      edgeLabel = malloc(strlen(defLabel) + strlen(inEdge) + 2);

      sprintf(edgeLabel, "%s-%s", inEdge, defLabel);
   }

   UINT32  selID = addNode(parent, "Select", edgeLabel);

   exprToDOT(ast->leftExpr, selID, "binding");
   variableToDOT(ast->var, selID, "member");

   free(edgeLabel);

   return selID;
}

static UINT32 schTypeToDOT(SchemaTypeNode *ast, UINT32 parent, INT8 *inEdge)
{
   tmpTree = ast->treeType;

   UINT32  astID      = 0;
   INT8   *postDecor = decorToStr(ast->postDecor, ast->postCnt);
   INT8   *preDecor  = decorToStr(ast->preDecor, ast->preCnt);

   if(ast->refName == NULL)
   {
      INT8  *edgeLabel = NULL;
      INT8  *defLabel  = "type";

      if(inEdge == NULL)
      {
         edgeLabel = strdup(defLabel);
      }
      else
      {
         edgeLabel = malloc(strlen(defLabel) + strlen(inEdge) + 2);

         sprintf(edgeLabel, "%s-%s", inEdge, defLabel);
      }

      astID = addNode(parent, "Schema Type", edgeLabel);

      if(ast->decls != NULL)
      {
         UINT32  declID = addNode(astID, "Declarations", "");

         listToDOT(ast->decls, declID, NULL);
      }

      if(ast->filters != NULL)
      {
         UINT32  filtID = addNode(astID, "Where", "");

         listToDOT(ast->filters, filtID, NULL);
      }

      free(edgeLabel);
   }
   else
   {
      INT8  *edgeLabel = NULL;
      INT8  *defLabel  = "ref";

      if(inEdge == NULL)
      {
         edgeLabel = strdup(defLabel);
      }
      else
      {
         edgeLabel = malloc(strlen(defLabel) + strlen(inEdge) + 2);

         sprintf(edgeLabel, "%s-%s", inEdge, defLabel);
      }

      astID = addNode(parent, ast->refName, edgeLabel);

      free(edgeLabel);
   }

   if(preDecor != NULL)
   {
      addNode(astID, preDecor, "pre");
      free(preDecor);
   }

   if(postDecor != NULL)
   {
      addNode(astID, postDecor, "post");
      free(postDecor);
   }

   return astID;
}

static UINT32 setDispToDOT(SetDispNode *ast, UINT32 parent, INT8 *inEdge)
{
   tmpTree = ast->treeType;

   INT8  *edgeLabel = NULL;
   INT8  *defLabel  = "set disp";

   if(inEdge == NULL)
   {
      edgeLabel = strdup(defLabel);
   }
   else
   {
      edgeLabel = malloc(strlen(defLabel) + strlen(inEdge) + 2);

      sprintf(edgeLabel, "%s-%s", inEdge, defLabel);
   }

   UINT32  dispID = addNode(parent, "Set Disp", edgeLabel);

   listToDOT(ast->exprList, dispID, "element");

   free(edgeLabel);

   return dispID;
}

static UINT32 seqDispToDOT(SeqDispNode *ast, UINT32 parent, INT8 *inEdge)
{
   tmpTree = ast->treeType;

   INT8  *edgeLabel = NULL;
   INT8  *defLabel  = "seq disp";

   if(inEdge == NULL)
   {
      edgeLabel = strdup(defLabel);
   }
   else
   {
      edgeLabel = malloc(strlen(defLabel) + strlen(inEdge) + 2);

      sprintf(edgeLabel, "%s-%s", inEdge, defLabel);
   }

   UINT32  dispID = addNode(parent, "Seq Disp", edgeLabel);

   listToDOT(ast->exprList, dispID, "element");

   free(edgeLabel);

   return dispID;
}

static UINT32 uptoToDOT(UptoNode *ast, UINT32 parent, INT8 *inEdge)
{
   tmpTree = ast->treeType;

   INT8  *edgeLabel = NULL;
   INT8  *defLabel  = "upto";

   if(inEdge == NULL)
   {
      edgeLabel = strdup(defLabel);
   }
   else
   {
      edgeLabel = malloc(strlen(defLabel) + strlen(inEdge) + 2);

      sprintf(edgeLabel, "%s-%s", inEdge, defLabel);
   }

   UINT32  uptoID = addNode(parent, "Upto", edgeLabel);

   exprToDOT(ast->startExpr, uptoID, "start");
   exprToDOT(ast->endExpr, uptoID, "end");

   free(edgeLabel);

   return uptoID;
}

static UINT32 setCompToDOT(SetCompNode *ast, UINT32 parent, INT8 *inEdge)
{
   tmpTree = ast->treeType;

   INT8  *edgeLabel = NULL;
   INT8  *defLabel  = "set comp";

   if(inEdge == NULL)
   {
      edgeLabel = strdup(defLabel);
   }
   else
   {
      edgeLabel = malloc(strlen(defLabel) + strlen(inEdge) + 2);

      sprintf(edgeLabel, "%s-%s", inEdge, defLabel);
   }

   UINT32  compID = addNode(parent, "Set Comp", edgeLabel);

   if(ast->decls != NULL)
   {
      UINT32  declID = addNode(compID, "Declarations", "");

      listToDOT(ast->decls, declID, NULL);
   }

   if(ast->filters != NULL)
   {
      UINT32  filtID = addNode(compID, "Where", "");

      listToDOT(ast->filters, filtID, NULL);
   }

   UINT32  exprID = addNode(compID, "Expression", "");

   exprToDOT(ast->expr, exprID, NULL);

   free(edgeLabel);

   return compID;
}

static UINT32 lambdaToDOT(LambdaNode *ast, UINT32 parent, INT8 *inEdge)
{
   tmpTree = ast->treeType;

   INT8  *edgeLabel = NULL;
   INT8  *defLabel  = "lambda";

   if(inEdge == NULL)
   {
      edgeLabel = strdup(defLabel);
   }
   else
   {
      edgeLabel = malloc(strlen(defLabel) + strlen(inEdge) + 2);

      sprintf(edgeLabel, "%s-%s", inEdge, defLabel);
   }

   UINT32  lambdaID = addNode(parent, "Lambda", edgeLabel);

   if(ast->decls != NULL)
   {
      UINT32  declID = addNode(lambdaID, "Declarations", "");

      listToDOT(ast->decls, declID, NULL);
   }

   if(ast->filters != NULL)
   {
      UINT32  filtID = addNode(lambdaID, "Where", "");

      listToDOT(ast->filters, filtID, NULL);
   }

   UINT32  exprID = addNode(lambdaID, "Expression", "");

   exprToDOT(ast->expr, exprID, NULL);

   free(edgeLabel);

   return lambdaID;
}

static UINT32 muToDOT(MuNode *ast, UINT32 parent, INT8 *inEdge)
{
   tmpTree = ast->treeType;

   INT8  *edgeLabel = NULL;
   INT8  *defLabel  = "mu";

   if(inEdge == NULL)
   {
      edgeLabel = strdup(defLabel);
   }
   else
   {
      edgeLabel = malloc(strlen(defLabel) + strlen(inEdge) + 2);

      sprintf(edgeLabel, "%s-%s", inEdge, defLabel);
   }

   UINT32  muID = addNode(parent, "Mu", edgeLabel);

   if(ast->decls != NULL)
   {
      UINT32  declID = addNode(muID, "Declarations", "");

      listToDOT(ast->decls, declID, NULL);
   }

   if(ast->filters != NULL)
   {
      UINT32  filtID = addNode(muID, "Where", "");

      listToDOT(ast->filters, filtID, NULL);
   }

   UINT32  exprID = addNode(muID, "Expression", "");

   exprToDOT(ast->expr, exprID, NULL);

   free(edgeLabel);

   return muID;
}

static UINT32 letExprToDOT(LetExprNode *ast, UINT32 parent, INT8 *inEdge)
{
   tmpTree = ast->treeType;

   INT8  *edgeLabel = NULL;
   INT8  *defLabel  = "let";

   if(inEdge == NULL)
   {
      edgeLabel = strdup(defLabel);
   }
   else
   {
      edgeLabel = malloc(strlen(defLabel) + strlen(inEdge) + 2);

      sprintf(edgeLabel, "%s-%s", inEdge, defLabel);
   }

   UINT32  letID = addNode(parent, "let", edgeLabel);

   if(ast->decls != NULL)
   {
      UINT32  declID = addNode(letID, "Declarations", "");

      listToDOT(ast->decls, declID, NULL);
   }

   UINT32  exprID = addNode(letID, "Expression", "");

   exprToDOT(ast->expr, exprID, NULL);

   free(edgeLabel);

   return letID;
}

static UINT32 exprToDOT(SyntaxTree *ast, UINT32 parent, INT8 *edgeLabel)
{
   if(ast == NULL)
   {
      return 0;
   }

   switch(ast->nodeType)
   {
      case NODE_EXPR_OP:
         return exprOpToDOT((ExprOpNode *) ast, parent, edgeLabel);
      break;

      case NODE_EXPR_FUNC:
         return exprFuncToDOT((ExprFuncNode *) ast, parent, edgeLabel);
      break;

      case NODE_VAR:
         return variableToDOT((VariableNode *) ast, parent, edgeLabel);
      break;

      case NODE_EXPR_LITERAL:
         return exprLiteralToDOT((ExprLiteralNode *) ast, parent, edgeLabel);
      break;

      case NODE_EXPR_IDENT:
         return exprIdentToDOT((ExprIdentNode *) ast, parent, edgeLabel);
      break;

      case NODE_EXPR_GEN_IDENT:
         return genIdentToDOT((ExprGenIdentNode *) ast, parent, edgeLabel);
      break;

      case NODE_EXPR_IF:
         return exprIfToDOT((CondExprNode *) ast, parent, edgeLabel);
      break;

      case NODE_TUPLE:
         return tupleToDOT((TupleNode *) ast, parent, edgeLabel);
      break;

      case NODE_CROSS:
         return crossToDOT((CrossNode *) ast, parent, edgeLabel);
      break;

      case NODE_SCH_BIND:
         return bindToDOT((SchemaBindNode *) ast, parent, edgeLabel);
      break;

      case NODE_BIND_ENTRY:
         return bindEntryToDOT((BindEntryNode *) ast, parent, edgeLabel);
      break;

      case NODE_SELECT:
         return selectToDOT((SelectNode *) ast, parent, edgeLabel);
      break;

      case NODE_SCH_TYPE:
         return schTypeToDOT((SchemaTypeNode *) ast, parent, edgeLabel);
      break;

      case NODE_SET_DISP:
         return setDispToDOT((SetDispNode *) ast, parent, edgeLabel);
      break;

      case NODE_SEQ_DISP:
         return seqDispToDOT((SeqDispNode *) ast, parent, edgeLabel);
      break;

      case NODE_UPTO:
         return uptoToDOT((UptoNode *) ast, parent, edgeLabel);
      break;

      case NODE_SET_COMP:
         return setCompToDOT((SetCompNode *) ast, parent, edgeLabel);
      break;

      case NODE_LAMBDA:
         return lambdaToDOT((LambdaNode *) ast, parent, edgeLabel);
      break;

      case NODE_MU:
         return muToDOT((MuNode *) ast, parent, edgeLabel);
      break;

      case NODE_LET_EXPR:
         return letExprToDOT((LetExprNode *) ast, parent, edgeLabel);
      break;

      case NODE_PROC_IF:
         return procIfToDOT((CondProcNode *) ast, parent, edgeLabel);
      break;

      case NODE_CHAN_APPL:
         return chanApplToDOT((ChanApplNode *) ast, parent, edgeLabel);
      break;

      case NODE_REPL_PROC:
         return replProcToDOT((ReplProcNode *) ast, parent, edgeLabel);
      break;

      case NODE_LET_PROC:
         return letProcToDOT((LetProcNode *) ast, parent, edgeLabel);
      break;

      default:
         return addUnknownNode(parent, ast->nodeType, edgeLabel);
      break;
   }
}

static UINT32 predOpToDOT(PredOpNode *ast, UINT32 parent)
{
   tmpTree = ast->treeType;

   UINT32  opID = addNode(parent, ast->opName, "pred op");

   predTypeToDOT(ast->left, opID);
   predTypeToDOT(ast->right, opID);

   return opID;
}

static UINT32 predRelToDOT(PredRelNode *ast, UINT32 parent)
{
   tmpTree = ast->treeType;

   UINT32  relID = addNode(parent, ast->opName, "rel op");

   exprToDOT(ast->left, relID, "left");
   exprToDOT(ast->right, relID, "right");

   return relID;
}

static UINT32 predFuncToDOT(PredFuncNode *ast, UINT32 parent)
{
   tmpTree = ast->treeType;

   UINT32  funcID = addNode(parent, ast->funcName, "pred func");

   exprToDOT(ast->params, funcID, NULL);

   return funcID;
}

static UINT32 predLiteralToDOT(PredLiteralNode *ast, UINT32 parent)
{
   tmpTree = ast->treeType;

   UINT32  litID = addNode(parent, ast->value, "literal");

   return litID;
}

static UINT32 predQuantToDOT(PredQuantNode *ast, UINT32 parent)
{
   tmpTree = ast->treeType;

   UINT32  quantID = addNode(parent, ast->quantName, "quantifier");

   if(ast->decls != NULL)
   {
      UINT32  declID = addNode(quantID, "Declarations", "");

      listToDOT(ast->decls, declID, NULL);
   }

   if(ast->filters != NULL)
   {
      UINT32  filtID = addNode(quantID, "Where", "");

      listToDOT(ast->filters, filtID, NULL);
   }

   if(ast->preds != NULL)
   {
      UINT32  predID = addNode(quantID, "Predicate", "");

      listToDOT(ast->preds, predID, NULL);
   }

   return quantID;
}

static UINT32 letPredToDOT(LetPredNode *ast, UINT32 parent)
{
   tmpTree = ast->treeType;

   UINT32  letID = addNode(parent, "let", "let");

   if(ast->decls != NULL)
   {
      UINT32  declID = addNode(letID, "Declarations", "");

      listToDOT(ast->decls, declID, NULL);
   }

   if(ast->preds != NULL)
   {
      UINT32  predID = addNode(letID, "Predicate", "");

      listToDOT(ast->preds, predID, NULL);
   }

   return letID;
}

static UINT32 schemaAppToDOT(SchemaAppNode *ast, UINT32 parent)
{
   tmpTree = ast->treeType;

   UINT32  appID = -1;

   if(ast->strictFlag == 0)
   {
      appID = addNode(parent, "Schema Appl", "schema appl");
   }
   else
   {
      appID = addNode(parent, "Schema Appl(Strict)", "schema appl");
   }

   if(ast->preCond != NULL)
   {
      UINT32  preID = addNode(appID, "PreCond", "");

      exprToDOT(ast->preCond, preID, NULL);
   }

   if(ast->command != NULL)
   {
      UINT32  commID = addNode(appID, "Command", "");

      exprToDOT(ast->command, commID, NULL);
   }

   if(ast->postCond != NULL)
   {
      UINT32  postID = addNode(appID, "PostCond", "");

      exprToDOT(ast->postCond, postID, NULL);
   }

   return appID;
}

static UINT32 predIfToDOT(CondPredNode *ast, UINT32 parent)
{
   tmpTree = ast->treeType;

   UINT32  ifID = addNode(parent, "if", "pred cond");

   listToDOT(ast->condList, ifID, "cond");

   if(ast->thenList != NULL)
   {
      UINT32  thenID = addNode(ifID, "Then", "");

      listToDOT(ast->thenList, thenID, NULL);
   }

   if(ast->elseList != NULL)
   {
      UINT32  elseID = addNode(ifID, "Else", "");

      listToDOT(ast->elseList, elseID, NULL);
   }

   return ifID;
}

static UINT32 predTypeToDOT(SyntaxTree *ast, UINT32 parent)
{
   if(ast == NULL)
   {
      return 0;
   }

   switch(ast->nodeType)
   {
      case NODE_PRED_OP:
         return predOpToDOT((PredOpNode *) ast, parent);
      break;

      case NODE_PRED_REL:
         return predRelToDOT((PredRelNode *) ast, parent);
      break;

      case NODE_PRED_FUNC:
         return predFuncToDOT((PredFuncNode *) ast, parent);
      break;

      case NODE_PRED_LITERAL:
         return predLiteralToDOT((PredLiteralNode *) ast, parent);
      break;

      case NODE_PRED_QUANT:
         return predQuantToDOT((PredQuantNode *) ast, parent);
      break;

      case NODE_LET_PRED:
         return letPredToDOT((LetPredNode *) ast, parent);
      break;

      case NODE_SCHEMA_APP:
         return schemaAppToDOT((SchemaAppNode *) ast, parent);
      break;

      case NODE_PRED_IF:
         return predIfToDOT((CondPredNode *) ast, parent);
      break;

      default:
         return addUnknownNode(parent, ast->nodeType, NULL);
      break;
   }
}

static UINT32 predToDOT(PredicateNode *ast, UINT32 parent)
{
   tmpTree = ast->treeType;

   UINT32  predID = predTypeToDOT(ast->predNode, parent);

   return predID;
}

static UINT32 declToDOT(DeclarationNode *ast, UINT32 parent)
{
   tmpTree = ast->treeType;

   UINT32  declID   = 0;
   INT8   *declStr = NULL;
   INT8   *typeStr = NULL;

   if(ast->declType == SCH_REF_DECL)
   {
      declStr = "Schema";
      typeStr = "include";
   }
   else if(ast->declType == VAR_DECL)
   {
      typeStr = "var";
   }
   else if(ast->declType == PRED_FUNC_DECL)
   {
      declStr = (INT8 *) ast->ident;
      typeStr = "bool";
   }
   else if(ast->declType == EXPR_FUNC_DECL)
   {
      declStr = (INT8 *) ast->ident;
      typeStr = "func";
   }
   else if(ast->declType == REL_OP_PRE_DECL)
   {
      declStr = (INT8 *) ast->ident;
      typeStr = "rel pre";
   }
   else if(ast->declType == REL_OP_POST_DECL)
   {
      declStr = (INT8 *) ast->ident;
      typeStr = "rel post";
   }
   else if(ast->declType == REL_OP_IN_DECL)
   {
      declStr = (INT8 *) ast->ident;
      typeStr = "rel in";
   }
   else if(ast->declType == EXPR_OP_PRE_DECL)
   {
      declStr = (INT8 *) ast->ident;
      typeStr = "oper pre";
   }
   else if(ast->declType == EXPR_OP_POST_DECL)
   {
      declStr = (INT8 *) ast->ident;
      typeStr = "oper post";
   }
   else if(ast->declType == EXPR_OP_IN_DECL)
   {
      declStr = (INT8 *) ast->ident;
      typeStr = "oper in";
   }
   else if(ast->declType == PROC_DECL)
   {
      typeStr = "process";
   }
   else if(ast->declType == PROC_FUNC_DECL)
   {
      declStr = (INT8 *) ast->ident;
      typeStr = "proc func";
   }
   else if(ast->declType == EVENT_DECL)
   {
      typeStr = "event";
   }
   else if(ast->declType == CHAN_DECL)
   {
      declStr = (INT8 *) ast->ident;
      typeStr = "channel";
   }

   declID = addNode(parent, typeStr, "decl");

   LinkList  *syms = ast->genSyms;

   if(syms != NULL)
   {
      UINT32  genID = addNode(declID, "Generics", "");

      while(syms != NULL)
      {
         addNode(genID, (INT8 *) syms->object, "sym");

         syms = syms->next;
      }
   }

   if((ast->declType == VAR_DECL) || (ast->declType == PROC_DECL) || (ast->declType == EVENT_DECL))
   {
      variableToDOT((VariableNode *) ast->ident, declID, NULL);
   }
   else if(ast->declType != SCH_REF_DECL)
   {
      addNode(declID, declStr, "ident");
   }

   exprToDOT(ast->defExpr, declID, "def expr");

   return declID;
}

static UINT32 procAliasToDOT(ProcAliasNode *ast, UINT32 parent)
{
   tmpTree = ast->treeType;

   UINT32  defID  = addNode(parent, ast->name, "proc alias");

   exprToDOT(ast->defExpr, defID, "def expr");

   return defID;
}

static UINT32 chanAliasToDOT(ChanAliasNode *ast, UINT32 parent)
{
   tmpTree = ast->treeType;

   UINT32  defID  = addNode(parent, ast->name, "chan alias");

   exprToDOT(ast->defExpr, defID, "def expr");

   return defID;
}

static UINT32 procToDOT(ProcessNode *ast, UINT32 parent)
{
   if(!exportCheck(getLayer(ast->props)))
   {
      return 0;
   }

   tmpTree = ast->treeType;

   UINT32  defID  = addNode(parent, ast->name, "process");

   if(ast->decls != NULL)
   {
      UINT32  declID = addNode(defID, "Declarations", "");

      listToDOT(ast->decls, declID, NULL);
   }

   if(ast->procs != NULL)
   {
      UINT32  procID = addNode(defID, "Processes", "");

      listToDOT(ast->procs, procID, NULL);
   }

   return defID;
}

static UINT32 procDefToDOT(ProcDefNode *ast, UINT32 parent)
{
   tmpTree = ast->treeType;

   UINT32  defID  = addNode(parent, ast->procName, "process");

   if(ast->decls != NULL)
   {
      UINT32  declID = addNode(defID, "Declarations", "");

      listToDOT(ast->decls, declID, NULL);
   }

   exprToDOT(ast->defExpr, defID, "def expr");

   return defID;
}

static UINT32 genProcDefToDOT(GenProcDefNode *ast, UINT32 parent)
{
   tmpTree = ast->treeType;

   UINT32  defID  = addNode(parent, ast->procName, "genproc");

   LinkList  *syms = ast->syms;

   if(syms != NULL)
   {
      UINT32  genID = addNode(defID, "Generics", "");

      while(syms != NULL)
      {
         addNode(genID, (INT8 *) syms->object, "sym");

         syms = syms->next;
      }
   }

   if(ast->decls != NULL)
   {
      UINT32  declID = addNode(defID, "Declarations", "");

      listToDOT(ast->decls, declID, NULL);
   }

   exprToDOT(ast->defExpr, defID, "def expr");

   return defID;
}

static UINT32 chanApplToDOT(ChanApplNode *ast, UINT32 parent, INT8 *inEdge)
{
   tmpTree = ast->treeType;

   INT8  *edgeLabel = NULL;
   INT8  *defLabel  = "chan appl";

   if(inEdge == NULL)
   {
      edgeLabel = strdup(defLabel);
   }
   else
   {
      edgeLabel = malloc(strlen(defLabel) + strlen(inEdge) + 2);

      sprintf(edgeLabel, "%s-%s", inEdge, defLabel);
   }

   UINT32  chanID = addNode(parent, "Channel", edgeLabel);

   exprToDOT(ast->chanExpr, chanID, "def expr");

   if(ast->fields != NULL)
   {
      UINT32  fieldID = addNode(chanID, "Fields", "");

      listToDOT(ast->fields, fieldID, NULL);
   }

   free(edgeLabel);

   return chanID;
}

static UINT32 chanFieldToDOT(ChanFieldNode *ast, UINT32 parent)
{
   tmpTree = ast->treeType;

   UINT32  fieldID  = 0;

   if(ast->fieldType == INPUT_FIELD)
   {
      fieldID = exprToDOT(ast->fieldExpr, parent, "input");
   }
   else if(ast->fieldType == OUTPUT_FIELD)
   {
      fieldID = exprToDOT(ast->fieldExpr, parent, "output");
   }
   else if(ast->fieldType == DOT_FIELD)
   {
      fieldID = exprToDOT(ast->fieldExpr, parent, "standard");
   }
   else
   {
      fieldID = exprToDOT(ast->fieldExpr, parent, "unknown");
   }

   return fieldID;
}

static UINT32 replProcToDOT(ReplProcNode *ast, UINT32 parent, INT8 *inEdge)
{
   tmpTree = ast->treeType;

   INT8  *edgeLabel = NULL;
   INT8  *defLabel  = "replicated";
   INT8  *replLabel = NULL;

   if(ast->replType == INTERNAL)
   {
     replLabel = "Internal";
   }
   else if(ast->replType == EXTERNAL)
   {
     replLabel = "External";
   }
   else if(ast->replType == PARALLEL)
   {
     replLabel = "Parallel";
   }
   else if(ast->replType == INTERLEAVE)
   {
     replLabel = "Interleave";
   }
   else if(ast->replType == IF_PARALLEL)
   {
     replLabel = "IF Parallel";
   }
   else
   {
     replLabel = "Unknown";
   }

   if(inEdge == NULL)
   {
      edgeLabel = strdup(defLabel);
   }
   else
   {
      edgeLabel = malloc(strlen(defLabel) + strlen(inEdge) + 2);

      sprintf(edgeLabel, "%s-%s", inEdge, defLabel);
   }

   UINT32  replID = addNode(parent, replLabel, edgeLabel);

   if(ast->ifAlph != NULL)
   {
      UINT32  ifID = addNode(replID, "Interface", "");

      exprToDOT(ast->ifAlph, ifID, NULL);
   }

   if(ast->decls != NULL)
   {
      UINT32  declID = addNode(replID, "Declarations", "");

      listToDOT(ast->decls, declID, NULL);
   }

   if(ast->filters != NULL)
   {
      UINT32  filtID = addNode(replID, "Where", "");

      listToDOT(ast->filters, filtID, NULL);
   }

   UINT32  exprID = addNode(replID, "Expression", "");

   exprToDOT(ast->expr, exprID, NULL);

   free(edgeLabel);

   return replID;
}

static UINT32 letProcToDOT(LetProcNode *ast, UINT32 parent, INT8 *inEdge)
{
   tmpTree = ast->treeType;

   INT8  *edgeLabel = NULL;
   INT8  *defLabel  = "let";

   if(inEdge == NULL)
   {
      edgeLabel = strdup(defLabel);
   }
   else
   {
      edgeLabel = malloc(strlen(defLabel) + strlen(inEdge) + 2);

      sprintf(edgeLabel, "%s-%s", inEdge, defLabel);
   }

   UINT32  letID = addNode(parent, "let", edgeLabel);

   if(ast->decls != NULL)
   {
      UINT32  declID = addNode(letID, "Declarations", "");

      listToDOT(ast->decls, declID, NULL);
   }

   UINT32  exprID = addNode(letID, "Expression", "");

   exprToDOT(ast->expr, exprID, NULL);

   free(edgeLabel);

   return letID;
}

static UINT32 procIfToDOT(CondProcNode *ast, UINT32 parent, INT8 *inEdge)
{
   tmpTree = ast->treeType;

   INT8  *edgeLabel = NULL;
   INT8  *defLabel  = "proc cond";

   if(inEdge == NULL)
   {
      edgeLabel = strdup(defLabel);
   }
   else
   {
      edgeLabel = malloc(strlen(defLabel) + strlen(inEdge) + 2);

      sprintf(edgeLabel, "%s-%s", inEdge, defLabel);
   }

   UINT32  ifID = addNode(parent, "if", edgeLabel);

   listToDOT(ast->condList, ifID, "cond");
   exprToDOT(ast->thenProc, ifID, "then");
   exprToDOT(ast->elseProc, ifID, "else");

   free(edgeLabel);

   return ifID;
}

static void listToDOT(LinkList *nodeList, UINT32 parent, INT8 *edgeLabel)
{
   SyntaxTree  *ast     = NULL;
   LinkList    *current = nodeList;

   while(current != NULL)
   {
      if(current->object != NULL)
      {
         ast = (SyntaxTree *) current->object;

         DEBUG("ast->nodeType = %d\n", ast->nodeType);

         switch(ast->nodeType)
         {
            case NODE_DIREC:
            case NODE_DESC:
            case NODE_DOC_INFO:
               /* Not part of DOT for AST */
            break;

            case NODE_BASIC:
               basicToDOT((BasicDefNode *) ast, parent);
            break;

            case NODE_BASIC_ENTRY:
               basicEntryToDOT((BasicEntryNode *) ast, parent);
            break;

            case NODE_TYPE_DEF:
               typeDefToDOT((TypeDefNode *) ast, parent);
            break;

            case NODE_TYPE_ENTRY:
               typeEntryToDOT((TypeEntryNode *) ast, parent);
            break;

            case NODE_FREE_TYPE:
               freeToDOT((FreeTypeNode *) ast, parent);
            break;

            case NODE_FREE_ENTRY:
               freeEntryToDOT((FreeEntryNode *) ast, parent);
            break;

            case NODE_AXDEF:
               axDefToDOT((AxDefNode *) ast, parent);
            break;

            case NODE_PROCESS:
               procToDOT((ProcessNode *) ast, parent);
            break;

            case NODE_GENDEF:
               genDefToDOT((GenDefNode *) ast, parent);
            break;

            case NODE_SCHEMA:
               schemaToDOT((SchemaNode *) ast, parent);
            break;

            case NODE_GEN_SCH:
               genSchemaToDOT((GenSchemaNode *) ast, parent);
            break;

            case NODE_CONST:
               constToDOT((ConstraintNode *) ast, parent);
            break;

            case NODE_DECL:
               declToDOT((DeclarationNode *) ast, parent);
            break;

            case NODE_PROC_ALIAS:
               procAliasToDOT((ProcAliasNode *) ast, parent);
            break;

            case NODE_CHAN_ALIAS:
               chanAliasToDOT((ChanAliasNode *) ast, parent);
            break;

            case NODE_PRED:
               predToDOT((PredicateNode *) ast, parent);
            break;

            case NODE_PROC_DEF:
               procDefToDOT((ProcDefNode *) ast, parent);
            break;

            case NODE_GEN_PROC_DEF:
               genProcDefToDOT((GenProcDefNode *) ast, parent);
            break;

            case NODE_CHAN_FIELD:
               chanFieldToDOT((ChanFieldNode *) ast, parent);
            break;

            case NODE_PRED_OP:
            case NODE_PRED_REL:
            case NODE_PRED_FUNC:
            case NODE_PRED_LITERAL:
            case NODE_PRED_QUANT:
            case NODE_LET_PRED:
            case NODE_PRED_IF:
               predTypeToDOT(ast, parent);
            break;

            case NODE_EXPR_OP:
            case NODE_EXPR_FUNC:
            case NODE_VAR:
            case NODE_EXPR_LITERAL:
            case NODE_EXPR_IDENT:
            case NODE_EXPR_GEN_IDENT:
            case NODE_EXPR_IF:
            case NODE_TUPLE:
            case NODE_CROSS:
            case NODE_SCH_BIND:
            case NODE_BIND_ENTRY:
            case NODE_SELECT:
            case NODE_SCH_TYPE:
            case NODE_SET_DISP:
            case NODE_SEQ_DISP:
            case NODE_UPTO:
            case NODE_SET_COMP:
            case NODE_LAMBDA:
            case NODE_MU:
            case NODE_LET_EXPR:
            case NODE_PROC_IF:
            case NODE_CHAN_APPL:
            case NODE_REPL_PROC:
               exprToDOT(ast, parent, edgeLabel);
            break;

            default:
               addUnknownNode(parent, ast->nodeType, edgeLabel);
            break;
         }
      }

      current = current->next;
   }
}

void aDocToDOT(ADocNode *ast, INT8 *outPath)
{
   tmpTree = ast->treeType;

   DEBUG("outPath = %s\n", outPath);

   outFile = fopen(outPath, "w+");

   if(typeBuff == NULL)
   {
      typeBuff = malloc(1024);
      typeLen  = 1024;

      memset(typeBuff, 0, 1024);
   }

   INT8  *dotPath = dotFix(outPath);

   dotWrite("digraph \"%s\"", dotPath);
   dotWrite("{");
   dotIWrite("0 [label=Document]");
   listToDOT(ast->paragraphs, 0, NULL);
   dotWrite("}");

   DEBUG("aDoc->nodeType = %d\n", ast->nodeType);

   if(dotPath != NULL)
   {
      free(dotPath);
   }

   fclose(outFile);

   outFile = NULL;
}
