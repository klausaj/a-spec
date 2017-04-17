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

#include <stdarg.h>
#include <string.h>
#include <stdlib.h>
#include <stdio.h>
#include <fcntl.h>

#ifdef WIN32
   #include "arch/mingw/a-spec_mingw.h"
#endif

#include "a-specc/a-specc_api.h"

DecorType extractDecorType(INT8 *decor)
{
   if(decor == NULL)
   {
      return DECOR_NULL;
   }
   else if(strncmp(decor, "delta", 5) == 0)
   {
      return PRE_DELTA;
   }
   else if(strncmp(decor, "?", 1) == 0)
   {
      return POST_IN;
   }
   else if(strncmp(decor, "!", 1) == 0)
   {
      return POST_OUT;
   }
   else if(strncmp(decor, "'", 1) == 0)
   {
      return POST_PRI;
   }
   else
   {
      return DECOR_NULL;
   }
}

UINT8 extractDecorCount(INT8 *decor)
{
   UINT8  cntIndex;

   if(decor == NULL)
   {
      return 0;
   }
   else if(strncmp(decor, "delta", 5) == 0)
   {
      cntIndex = 5;
   }
   else if(strncmp(decor, "?", 1) == 0)
   {
      /* Instance count invalid for in/out decorations */
      return 0;
   }
   else if(strncmp(decor, "!", 1) == 0)
   {
      /* Instance count invalid for in/out decorations */
      return 0;
   }
   else if(strncmp(decor, "'", 1) == 0)
   {
      cntIndex = 1;
   }
   else
   {
      return 0;
   }

   if(strlen(decor) > cntIndex)
   {
      return atoi(&(decor[cntIndex]));
   }
   else
   {
      /* Single instance of decoration */
      return 1;
   }
}

INT8 *varToString(VariableNode *var)
{
   INT8  *retVal = NULL;

   if((var == NULL) || (var->name == NULL))
   {
      return NULL;
   }

   retVal = malloc(9 + strlen(var->name));

   memset(retVal, 0, 9 + strlen(var->name));

   if(retVal == NULL)
   {
      yyuerror("varToString(): Unable to malloc return string");

      return NULL;
   }

   strncpy(retVal, var->name, strlen(var->name));

   if(var->postDecor == DECOR_NULL)
   {
      DEBUG("varName = %s, postDecor = DECOR_NULL, postCnt = %d\n", var->name, var->postCnt);

      return retVal;
   }
   else if(var->postDecor == POST_PRI)
   {
      DEBUG("varName = %s, postDecor = POST_PRI, postCnt = %d\n", var->name, var->postCnt);

      retVal[strlen(var->name)] = '\'';

      if(var->postCnt > 1)
      {
         sprintf(retVal, "%s%d", retVal, var->postCnt);
      }

      return retVal;
   }
   else if(var->postDecor == POST_IN)
   {
      DEBUG("varName = %s, postDecor = POST_IN, postCnt = %d\n", var->name, var->postCnt);

      retVal[strlen(var->name)] = '?';

      return retVal;
   }
   else if(var->postDecor == POST_OUT)
   {
      DEBUG("varName = %s, postDecor = POST_OUT, postCnt = %d\n", var->name, var->postCnt);

      retVal[strlen(var->name)] = '!';

      return retVal;
   }

   return NULL;
}

ADocNode *createADocNode(DocInfoNode *info, LinkList *paragraphs)
{
   ADocNode  *retVal = malloc(sizeof(ADocNode));

   if(retVal == NULL)
   {
      return NULL;
   }

   retVal->nodeType   = NODE_A_DOC;
   retVal->ozTex      = NULL;
   retVal->treeType   = NULL;
   retVal->specType   = NULL;
   retVal->symStack   = symStack;
   retVal->info       = info;
   retVal->paragraphs = paragraphs;
   
   return retVal;
}

DocInfoNode *createDocInfoNode(LinkList *infoEntries)
{
   DocInfoNode  *retVal = malloc(sizeof(DocInfoNode));

   if(retVal == NULL)
   {
      return NULL;
   }

   retVal->nodeType    = NODE_DOC_INFO;
   retVal->ozTex       = NULL;
   retVal->treeType    = NULL;
   retVal->specType    = NULL;
   retVal->symStack    = symStack;
   retVal->infoEntries = infoEntries;
   
   return retVal;
}

InfoEntryNode *createInfoEntryNode(LinkList *infoList)
{
   InfoEntryNode  *retVal = malloc(sizeof(InfoEntryNode));

   if(retVal == NULL)
   {
      return NULL;
   }

   retVal->nodeType = NODE_INFO_ENTRY;
   retVal->ozTex    = NULL;
   retVal->treeType = NULL;
   retVal->specType = NULL;
   retVal->symStack = symStack;
   retVal->infoList = infoList;

   return retVal;
}

PropertyNode *createPropertyNode(LinkList *propList)
{
   PropertyNode  *retVal = malloc(sizeof(PropertyNode));

   if(retVal == NULL)
   {
      return NULL;
   }

   retVal->nodeType = NODE_PROP_ENTRY;
   retVal->ozTex    = NULL;
   retVal->treeType = NULL;
   retVal->specType = NULL;
   retVal->symStack = symStack;
   retVal->propList = propList;

   return retVal;
}

DirectiveNode *createDirectiveNode(LinkList *props, LinkList *commands)
{
   DirectiveNode  *retVal = malloc(sizeof(DirectiveNode));

   if(retVal == NULL)
   {
      return NULL;
   }

   retVal->nodeType = NODE_DIREC;
   retVal->ozTex    = NULL;
   retVal->treeType = NULL;
   retVal->specType = NULL;
   retVal->symStack = symStack;
   retVal->props    = props;
   retVal->commands = commands;

   return retVal;
}

DescriptionNode *createDescriptionNode(LinkList *props, INT8 *text)
{
   DescriptionNode  *retVal = malloc(sizeof(DescriptionNode));

   if(retVal == NULL)
   {
      return NULL;
   }

   retVal->nodeType = NODE_DESC;
   retVal->ozTex    = NULL;
   retVal->treeType = NULL;
   retVal->specType = NULL;
   retVal->symStack = symStack;
   retVal->props    = props;
   retVal->text     = text;

   return retVal;
}

BasicDefNode *createBasicDefNode(LinkList *props, LinkList *basicList, INT8 *name)
{
   BasicDefNode  *retVal = malloc(sizeof(BasicDefNode));

   if(retVal == NULL)
   {
      return NULL;
   }

   retVal->nodeType = NODE_BASIC;
   retVal->ozTex    = NULL;
   retVal->treeType = NULL;
   retVal->specType = NULL;
   retVal->symStack = symStack;
   retVal->props    = props;
   retVal->entries  = basicList;
   retVal->name     = name;

   return retVal;
}

BasicEntryNode *createBasicEntryNode(LinkList *props, INT8 *typeName)
{
   BasicEntryNode  *retVal = malloc(sizeof(BasicEntryNode));

   if(retVal == NULL)
   {
      return NULL;
   }

   retVal->nodeType = NODE_BASIC_ENTRY;
   retVal->ozTex    = NULL;
   retVal->treeType = NULL;
   retVal->specType = NULL;
   retVal->symStack = symStack;
   retVal->props    = props;
   retVal->name     = typeName;

   return retVal;
}

TypeDefNode *createTypeDefNode(LinkList *props, LinkList *typeList, INT8 *name)
{
   TypeDefNode  *retVal = malloc(sizeof(TypeDefNode));

   if(retVal == NULL)
   {
      return NULL;
   }

   retVal->nodeType = NODE_TYPE_DEF;
   retVal->ozTex    = NULL;
   retVal->treeType = NULL;
   retVal->specType = NULL;
   retVal->symStack = symStack;
   retVal->props    = props;
   retVal->entries  = typeList;
   retVal->name     = name;

   return retVal;
}

TypeEntryNode *createTypeEntryNode(INT8 *typeName, SyntaxTree *defExpr)
{
   TypeEntryNode  *retVal = malloc(sizeof(TypeEntryNode));

   if(retVal == NULL)
   {
      return NULL;
   }

   retVal->nodeType = NODE_TYPE_ENTRY;
   retVal->ozTex    = NULL;
   retVal->treeType = NULL;
   retVal->specType = NULL;
   retVal->symStack = symStack;
   retVal->props    = NULL;
   retVal->name     = typeName;
   retVal->defExpr  = defExpr;
   retVal->preGen   = NULL;
   retVal->postGen  = NULL;

   return retVal;
}

TypeEntryNode *createGenTypeEntryNode(INT8 *typeName, SyntaxTree *defExpr, INT8 *preGen, INT8 *postGen)
{
   TypeEntryNode  *retVal = malloc(sizeof(TypeEntryNode));

   if(retVal == NULL)
   {
      return NULL;
   }

   retVal->nodeType = NODE_TYPE_ENTRY;
   retVal->ozTex    = NULL;
   retVal->treeType = NULL;
   retVal->specType = NULL;
   retVal->symStack = symStack;
   retVal->props    = NULL;
   retVal->name     = typeName;
   retVal->defExpr  = defExpr;
   retVal->preGen   = preGen;
   retVal->postGen  = postGen;

   return retVal;
}

FreeTypeNode *createFreeTypeNode(LinkList *props, LinkList *typeList, INT8 *name)
{
   FreeTypeNode  *retVal = malloc(sizeof(FreeTypeNode));

   if(retVal == NULL)
   {
      return NULL;
   }

   retVal->nodeType = NODE_FREE_TYPE;
   retVal->ozTex    = NULL;
   retVal->treeType = NULL;
   retVal->specType = NULL;
   retVal->symStack = symStack;
   retVal->props    = props;
   retVal->entries  = typeList;
   retVal->name     = name;

   return retVal;
}

FreeEntryNode *createFreeEntryNode(LinkList *props, INT8 *typeName, LinkList *varList)
{
   FreeEntryNode  *retVal = malloc(sizeof(FreeEntryNode));

   if(retVal == NULL)
   {
      return NULL;
   }

   retVal->nodeType = NODE_FREE_ENTRY;
   retVal->ozTex    = NULL;
   retVal->treeType = NULL;
   retVal->specType = NULL;
   retVal->symStack = symStack;
   retVal->props    = props;
   retVal->name     = typeName;
   retVal->freeVars = varList;

   return retVal;
}

AxDefNode *createAxDefNode(LinkList *props, LinkList *decls, LinkList *preds, INT8 *name)
{
   AxDefNode  *retVal = malloc(sizeof(AxDefNode));

   if(retVal == NULL)
   {
      return NULL;
   }

   retVal->nodeType = NODE_AXDEF;
   retVal->ozTex    = NULL;
   retVal->treeType = NULL;
   retVal->specType = NULL;
   retVal->symStack = symStack;
   retVal->props    = props;
   retVal->decls    = decls;
   retVal->preds    = preds;
   retVal->name     = name;

   return retVal;
}

GenDefNode *createGenDefNode(LinkList *props, LinkList *syms, LinkList *decls, LinkList *preds, INT8 *name)
{
   GenDefNode  *retVal = malloc(sizeof(GenDefNode));

   if(retVal == NULL)
   {
      return NULL;
   }

   retVal->nodeType = NODE_GENDEF;
   retVal->ozTex    = NULL;
   retVal->treeType = NULL;
   retVal->specType = NULL;
   retVal->symStack = symStack;
   retVal->props    = props;
   retVal->syms     = syms;
   retVal->decls    = decls;
   retVal->preds    = preds;
   retVal->name     = name;

   return retVal;
}

SchemaNode *createSchemaNode(LinkList *props, LinkList *decls, LinkList *preds, INT8 *name)
{
   SchemaNode  *retVal = malloc(sizeof(SchemaNode));

   if(retVal == NULL)
   {
      return NULL;
   }

   retVal->nodeType = NODE_SCHEMA;
   retVal->ozTex    = NULL;
   retVal->treeType = NULL;
   retVal->specType = NULL;
   retVal->symStack = symStack;
   retVal->props    = props;
   retVal->decls    = decls;
   retVal->preds    = preds;
   retVal->name     = name;

   return retVal;
}

GenSchemaNode *createGenSchemaNode(LinkList *props, LinkList *syms, LinkList *decls, LinkList *preds, INT8 *name)
{
   GenSchemaNode  *retVal = malloc(sizeof(GenSchemaNode));

   if(retVal == NULL)
   {
      return NULL;
   }

   retVal->nodeType = NODE_GEN_SCH;
   retVal->ozTex    = NULL;
   retVal->treeType = NULL;
   retVal->specType = NULL;
   retVal->symStack = symStack;
   retVal->props    = props;
   retVal->syms     = syms;
   retVal->decls    = decls;
   retVal->preds    = preds;
   retVal->name     = name;

   return retVal;
}

ConstraintNode *createConstraintNode(LinkList *props, LinkList *preds, INT8 *name)
{
   ConstraintNode  *retVal = malloc(sizeof(ConstraintNode));

   if(retVal == NULL)
   {
      return NULL;
   }

   retVal->nodeType = NODE_CONST;
   retVal->ozTex    = NULL;
   retVal->treeType = NULL;
   retVal->specType = NULL;
   retVal->symStack = symStack;
   retVal->props    = props;
   retVal->preds    = preds;
   retVal->name     = name;

   return retVal;
}

ProcessNode *createProcessNode(LinkList *props, LinkList *decls, LinkList *procs, INT8 *name)
{
   ProcessNode  *retVal = malloc(sizeof(ProcessNode));

   if(retVal == NULL)
   {
      return NULL;
   }

   retVal->nodeType = NODE_PROCESS;
   retVal->ozTex    = NULL;
   retVal->treeType = NULL;
   retVal->specType = NULL;
   retVal->symStack = symStack;
   retVal->props    = props;
   retVal->decls    = decls;
   retVal->procs    = procs;
   retVal->name     = name;

   return retVal;
}

DeclarationNode *createDeclarationNode(LinkList *props, DeclType declType, void *ident, SyntaxTree *defExpr)
{
   DeclarationNode  *retVal = malloc(sizeof(DeclarationNode));

   if(retVal == NULL)
   {
      return NULL;
   }

   retVal->nodeType = NODE_DECL;
   retVal->ozTex    = NULL;
   retVal->treeType = NULL;
   retVal->specType = NULL;
   retVal->symStack = symStack;
   retVal->props    = props;
   retVal->declType = declType;
   retVal->ident    = ident;
   retVal->defExpr  = defExpr;
   retVal->genSyms  = NULL;

   return retVal;
}

PredicateNode *createPredicateNode(LinkList *props, SyntaxTree *predNode)
{
   PredicateNode  *retVal = malloc(sizeof(PredicateNode));

   if(retVal == NULL)
   {
      return NULL;
   }

   retVal->nodeType = NODE_PRED;
   retVal->ozTex    = NULL;
   retVal->treeType = NULL;
   retVal->specType = NULL;
   retVal->symStack = symStack;
   retVal->props    = props;
   retVal->predNode = predNode;

   return retVal;
}

PredOpNode *createPredOpNode(SyntaxTree *left, INT8 *opName, SyntaxTree *right)
{
   PredOpNode  *retVal = malloc(sizeof(PredOpNode));

   if(retVal == NULL)
   {
      return NULL;
   }

   DEBUG("createPredOpNode(): ");
   
   if(left != NULL)
   {
      DEBUG("left = %d, ", left->nodeType);
   }
   
   DEBUG("opName = %s", opName);
   
   if(right != NULL)
   {
      DEBUG(", right = %d\n", right->nodeType);
   }
   else
   {
      DEBUG("\n");
   }

   retVal->nodeType = NODE_PRED_OP;
   retVal->ozTex    = NULL;
   retVal->treeType = NULL;
   retVal->specType = NULL;
   retVal->symStack = symStack;
   retVal->left     = left;
   retVal->opName   = opName;
   retVal->right    = right;

   return retVal;
}

PredRelNode *createPredRelNode(SyntaxTree *left, INT8 *opName, SyntaxTree *right)
{
   PredRelNode  *retVal = malloc(sizeof(PredRelNode));

   if(retVal == NULL)
   {
      return NULL;
   }

   DEBUG("createPredRelNode(): left = %d, opName = %s, right = %d\n", left->nodeType, opName, right->nodeType);

   retVal->nodeType = NODE_PRED_REL;
   retVal->ozTex    = NULL;
   retVal->treeType = NULL;
   retVal->specType = NULL;
   retVal->symStack = symStack;
   retVal->left     = left;
   retVal->opName   = opName;
   retVal->right    = right;

   return retVal;
}

PredFuncNode *createPredFuncNode(INT8 *funcName, SyntaxTree *params)
{
   PredFuncNode  *retVal = malloc(sizeof(PredFuncNode));

   if(retVal == NULL)
   {
      return NULL;
   }

   retVal->nodeType = NODE_PRED_FUNC;
   retVal->ozTex    = NULL;
   retVal->treeType = NULL;
   retVal->specType = NULL;
   retVal->symStack = symStack;
   retVal->funcName = funcName;
   retVal->params   = params;

   return retVal;
}

PredLiteralNode *createPredLiteralNode(INT8 *value)
{
   PredLiteralNode  *retVal = malloc(sizeof(PredLiteralNode));

   if(retVal == NULL)
   {
      return NULL;
   }

   retVal->nodeType = NODE_PRED_LITERAL;
   retVal->ozTex    = NULL;
   retVal->treeType = NULL;
   retVal->specType = NULL;
   retVal->symStack = symStack;
   retVal->value    = value;

   return retVal;
}

PredQuantNode *createPredQuantNode(INT8 *quantName, LinkList *decls, LinkList *filters, LinkList *preds)
{
   PredQuantNode  *retVal = malloc(sizeof(PredQuantNode));

   if(retVal == NULL)
   {
      return NULL;
   }

   retVal->nodeType  = NODE_PRED_QUANT;
   retVal->ozTex     = NULL;
   retVal->treeType  = NULL;
   retVal->specType  = NULL;
   retVal->symStack  = symStack;
   retVal->decls     = decls;
   retVal->filters   = filters;
   retVal->preds     = preds;
   retVal->quantName = quantName;

   return retVal;
}

LetPredNode *createLetPredNode(LinkList *decls, LinkList *preds)
{
   LetPredNode  *retVal = malloc(sizeof(LetPredNode));

   if(retVal == NULL)
   {
      return NULL;
   }

   retVal->nodeType  = NODE_LET_PRED;
   retVal->ozTex     = NULL;
   retVal->treeType  = NULL;
   retVal->specType  = NULL;
   retVal->symStack  = symStack;
   retVal->decls     = decls;
   retVal->preds     = preds;

   return retVal;
}

SchemaAppNode *createSchemaAppNode(SyntaxTree *preCond, SyntaxTree *command, SyntaxTree *postCond, UINT8 strictFlag)
{
   SchemaAppNode  *retVal = malloc(sizeof(SchemaAppNode));

   if(retVal == NULL)
   {
      return NULL;
   }

   retVal->nodeType   = NODE_SCHEMA_APP;
   retVal->ozTex      = NULL;
   retVal->treeType   = NULL;
   retVal->specType   = NULL;
   retVal->symStack   = symStack;
   retVal->preCond    = preCond;
   retVal->command    = command;
   retVal->postCond   = postCond;
   retVal->strictFlag = strictFlag;

   return retVal;
}

CondPredNode *createCondPredNode(LinkList *condList, LinkList *thenList, LinkList *elseList)
{
   CondPredNode  *retVal = malloc(sizeof(CondPredNode));

   if(retVal == NULL)
   {
      return NULL;
   }

   retVal->nodeType = NODE_PRED_IF;
   retVal->ozTex    = NULL;
   retVal->treeType = NULL;
   retVal->specType = NULL;
   retVal->symStack = symStack;
   retVal->condList = condList;
   retVal->thenList = thenList;
   retVal->elseList = elseList;

   return retVal;
}

ExprOpNode *createExprOpNode(SyntaxTree *left, INT8 *opName, SyntaxTree *right)
{
   ExprOpNode  *retVal = malloc(sizeof(ExprOpNode));

   if(retVal == NULL)
   {
      return NULL;
   }

   retVal->nodeType  = NODE_EXPR_OP;
   retVal->ozTex     = NULL;
   retVal->treeType  = NULL;
   retVal->specType  = NULL;
   retVal->props     = NULL;
   retVal->symStack  = symStack;
   retVal->left      = left;
   retVal->opName    = opName;
   retVal->right     = right;
   retVal->qualifier = NULL;

   return retVal;
}

ExprFuncNode *createExprFuncNode(SyntaxTree *funcExpr, SyntaxTree *params)
{
   ExprFuncNode  *retVal = malloc(sizeof(ExprFuncNode));

   if(retVal == NULL)
   {
      return NULL;
   }

   retVal->nodeType = NODE_EXPR_FUNC;
   retVal->ozTex    = NULL;
   retVal->treeType = NULL;
   retVal->specType = NULL;
   retVal->props    = NULL;
   retVal->symStack = symStack;
   retVal->funcExpr = funcExpr;
   retVal->params   = params;

   return retVal;
}

VariableNode *createVariableNode(INT8 *varName, INT8 *postDecor)
{
   VariableNode  *retVal = malloc(sizeof(VariableNode));

   if(retVal == NULL)
   {
      return NULL;
   }

   DEBUG("createVariableNode(): varName = %s, varDecor = %s\n", varName, postDecor);

   retVal->nodeType  = NODE_VAR;
   retVal->props     = NULL;
   retVal->ozTex     = NULL;
   retVal->treeType  = NULL;
   retVal->specType  = NULL;
   retVal->props     = NULL;
   retVal->symStack  = symStack;
   retVal->name      = varName;
   retVal->postDecor = extractDecorType(postDecor);
   retVal->postCnt   = extractDecorCount(postDecor);

   return retVal;
}

ExprLiteralNode *createExprLiteralNode(INT8 *value)
{
   ExprLiteralNode  *retVal = malloc(sizeof(ExprLiteralNode));

   if(retVal == NULL)
   {
      return NULL;
   }

   retVal->nodeType = NODE_EXPR_LITERAL;
   retVal->ozTex    = NULL;
   retVal->treeType = NULL;
   retVal->specType = NULL;
   retVal->props    = NULL;
   retVal->symStack = symStack;
   retVal->value    = value;

   return retVal;
}

ExprIdentNode *createExprIdentNode(INT8 *ident)
{
   ExprIdentNode  *retVal = malloc(sizeof(ExprIdentNode));

   if(retVal == NULL)
   {
      return NULL;
   }

   retVal->nodeType = NODE_EXPR_IDENT;
   retVal->ozTex    = NULL;
   retVal->treeType = NULL;
   retVal->specType = NULL;
   retVal->props    = NULL;
   retVal->symStack = symStack;
   retVal->ident    = ident;
   retVal->preSpec  = NULL;
   retVal->postSpec = NULL;
   retVal->specList = NULL;

   return retVal;
}

ExprIdentNode *createExprSpecIdentNode(INT8 *ident, SyntaxTree *preExpr, SyntaxTree *postExpr)
{
   ExprIdentNode  *retVal = malloc(sizeof(ExprIdentNode));

   if(retVal == NULL)
   {
      return NULL;
   }

   retVal->nodeType = NODE_EXPR_IDENT;
   retVal->ozTex    = NULL;
   retVal->treeType = NULL;
   retVal->specType = NULL;
   retVal->props    = NULL;
   retVal->symStack = symStack;
   retVal->ident    = ident;
   retVal->preSpec  = preExpr;
   retVal->postSpec = postExpr;
   retVal->specList = NULL;

   return retVal;
}

ExprGenIdentNode *createExprGenIdentNode(INT8 *ident)
{
   ExprGenIdentNode  *retVal = malloc(sizeof(ExprGenIdentNode));

   if(retVal == NULL)
   {
      return NULL;
   }

   retVal->nodeType = NODE_EXPR_GEN_IDENT;
   retVal->ozTex    = NULL;
   retVal->treeType = NULL;
   retVal->specType = NULL;
   retVal->props    = NULL;
   retVal->symStack = symStack;
   retVal->ident    = ident;

   return retVal;
}

CondExprNode *createCondExprNode(LinkList *condList, SyntaxTree *thenExpr, SyntaxTree *elseExpr)
{
   CondExprNode  *retVal = malloc(sizeof(CondExprNode));

   if(retVal == NULL)
   {
      return NULL;
   }

   retVal->nodeType = NODE_EXPR_IF;
   retVal->ozTex    = NULL;
   retVal->treeType = NULL;
   retVal->specType = NULL;
   retVal->props    = NULL;
   retVal->symStack = symStack;
   retVal->condList = condList;
   retVal->thenExpr = thenExpr;
   retVal->elseExpr = elseExpr;

   return retVal;
}

TupleNode *createTupleNode(LinkList *exprList)
{
   TupleNode  *retVal = malloc(sizeof(TupleNode));

   if(retVal == NULL)
   {
      return NULL;
   }

   retVal->nodeType = NODE_TUPLE;
   retVal->ozTex    = NULL;
   retVal->treeType = NULL;
   retVal->specType = NULL;
   retVal->props    = NULL;
   retVal->symStack = symStack;
   retVal->exprList = exprList;

   return retVal;
}

CrossNode *createCrossNode(LinkList *exprList)
{
   CrossNode  *retVal = malloc(sizeof(CrossNode));

   if(retVal == NULL)
   {
      return NULL;
   }

   retVal->nodeType = NODE_CROSS;
   retVal->ozTex    = NULL;
   retVal->treeType = NULL;
   retVal->specType = NULL;
   retVal->props    = NULL;
   retVal->symStack = symStack;
   retVal->exprList = exprList;

   return retVal;
}

SchemaBindNode *createSchemaBindNode(LinkList *bindList)
{
   SchemaBindNode  *retVal = malloc(sizeof(SchemaBindNode));

   if(retVal == NULL)
   {
      return NULL;
   }

   retVal->nodeType = NODE_SCH_BIND;
   retVal->ozTex    = NULL;
   retVal->treeType = NULL;
   retVal->specType = NULL;
   retVal->props    = NULL;
   retVal->symStack = symStack;
   retVal->bindList = bindList;
   retVal->hideNode = 0;

   return retVal;
}

BindEntryNode *createBindEntryNode(VariableNode *var, SyntaxTree *bindExpr)
{
   BindEntryNode  *retVal = malloc(sizeof(BindEntryNode));

   if(retVal == NULL)
   {
      return NULL;
   }

   retVal->nodeType  = NODE_BIND_ENTRY;
   retVal->ozTex     = NULL;
   retVal->treeType  = NULL;
   retVal->specType  = NULL;
   retVal->props     = NULL;
   retVal->symStack  = symStack;
   retVal->var       = var;
   retVal->expr      = bindExpr;
   retVal->hideEntry = 0;

   return retVal;
}

SelectNode *createSelectNode(SyntaxTree *leftExpr, VariableNode *var)
{
   SelectNode  *retVal = malloc(sizeof(SelectNode));

   if(retVal == NULL)
   {
      return NULL;
   }

   retVal->nodeType = NODE_SELECT;
   retVal->ozTex    = NULL;
   retVal->treeType = NULL;
   retVal->specType = NULL;
   retVal->props    = NULL;
   retVal->symStack = symStack;
   retVal->leftExpr = leftExpr;
   retVal->var      = var;

   return retVal;
}

SchemaTypeNode *createSchemaTypeNode(LinkList *decls, LinkList *filters, INT8 *preDecor, INT8 *postDecor)
{
   SchemaTypeNode  *retVal = malloc(sizeof(SchemaTypeNode));

   if(retVal == NULL)
   {
      return NULL;
   }

   retVal->nodeType  = NODE_SCH_TYPE;
   retVal->ozTex     = NULL;
   retVal->treeType  = NULL;
   retVal->specType  = NULL;
   retVal->props     = NULL;
   retVal->symStack  = symStack;
   retVal->decls     = decls;
   retVal->filters   = filters;
   retVal->preDecor  = extractDecorType(preDecor);
   retVal->preCnt    = extractDecorCount(preDecor);
   retVal->postDecor = extractDecorType(postDecor);
   retVal->postCnt   = extractDecorCount(postDecor);
   retVal->refName   = NULL;
   retVal->specList  = NULL;

   return retVal;
}

SchemaTypeNode *createSchemaTypeFromRef(INT8 *refName, INT8 *preDecor, INT8 *postDecor)
{
   SchemaTypeNode  *retVal = malloc(sizeof(SchemaTypeNode));

   if(retVal == NULL)
   {
      return NULL;
   }

   retVal->nodeType  = NODE_SCH_TYPE;
   retVal->ozTex     = NULL;
   retVal->treeType  = NULL;
   retVal->specType  = NULL;
   retVal->props     = NULL;
   retVal->symStack  = symStack;
   retVal->decls     = NULL;
   retVal->filters   = NULL;
   retVal->refName   = refName;
   retVal->preDecor  = extractDecorType(preDecor);
   retVal->preCnt    = extractDecorCount(preDecor);
   retVal->postDecor = extractDecorType(postDecor);
   retVal->postCnt   = extractDecorCount(postDecor);
   retVal->specList  = NULL;

   return retVal;
}

SetDispNode *createSetDispNode(LinkList *exprList)
{
   SetDispNode  *retVal = malloc(sizeof(SetDispNode));

   if(retVal == NULL)
   {
      return NULL;
   }

   retVal->nodeType = NODE_SET_DISP;
   retVal->ozTex    = NULL;
   retVal->treeType = NULL;
   retVal->specType = NULL;
   retVal->props    = NULL;
   retVal->symStack = symStack;
   retVal->exprList = exprList;

   return retVal;
}

SeqDispNode *createSeqDispNode(LinkList *exprList)
{
   SeqDispNode  *retVal = malloc(sizeof(SeqDispNode));

   if(retVal == NULL)
   {
      return NULL;
   }

   retVal->nodeType = NODE_SEQ_DISP;
   retVal->ozTex    = NULL;
   retVal->treeType = NULL;
   retVal->specType = NULL;
   retVal->props    = NULL;
   retVal->symStack = symStack;
   retVal->exprList = exprList;

   return retVal;
}

UptoNode *createUptoNode(SyntaxTree *startExpr, SyntaxTree *endExpr)
{
   UptoNode  *retVal = malloc(sizeof(UptoNode));

   if(retVal == NULL)
   {
      return NULL;
   }

   retVal->nodeType  = NODE_UPTO;
   retVal->ozTex     = NULL;
   retVal->treeType  = NULL;
   retVal->specType  = NULL;
   retVal->props     = NULL;
   retVal->symStack  = symStack;
   retVal->startExpr = startExpr;
   retVal->endExpr   = endExpr;

   return retVal;
}

SetCompNode *createSetCompNode(LinkList *decls, LinkList *filters, SyntaxTree *expr)
{
   SetCompNode  *retVal = malloc(sizeof(SetCompNode));

   if(retVal == NULL)
   {
      return NULL;
   }

   retVal->nodeType = NODE_SET_COMP;
   retVal->ozTex    = NULL;
   retVal->treeType = NULL;
   retVal->specType = NULL;
   retVal->props    = NULL;
   retVal->symStack = symStack;
   retVal->decls    = decls;
   retVal->filters  = filters;
   retVal->expr     = expr;

   return retVal;
}

LambdaNode *createLambdaNode(LinkList *decls, LinkList *filters, SyntaxTree *expr)
{
   LambdaNode  *retVal = malloc(sizeof(LambdaNode));

   if(retVal == NULL)
   {
      return NULL;
   }

   retVal->nodeType = NODE_LAMBDA;
   retVal->ozTex    = NULL;
   retVal->treeType = NULL;
   retVal->specType = NULL;
   retVal->props    = NULL;
   retVal->symStack = symStack;
   retVal->decls    = decls;
   retVal->filters  = filters;
   retVal->expr     = expr;

   return retVal;
}

MuNode *createMuNode(LinkList *decls, LinkList *filters, SyntaxTree *expr)
{
   MuNode  *retVal = malloc(sizeof(MuNode));

   if(retVal == NULL)
   {
      return NULL;
   }

   retVal->nodeType = NODE_MU;
   retVal->ozTex    = NULL;
   retVal->treeType = NULL;
   retVal->specType = NULL;
   retVal->props    = NULL;
   retVal->symStack = symStack;
   retVal->decls    = decls;
   retVal->filters  = filters;
   retVal->expr     = expr;

   return retVal;
}

LetExprNode *createLetExprNode(LinkList *decls, SyntaxTree *expr)
{
   LetExprNode  *retVal = malloc(sizeof(LetExprNode));

   if(retVal == NULL)
   {
      return NULL;
   }

   retVal->nodeType = NODE_LET_EXPR;
   retVal->ozTex    = NULL;
   retVal->treeType = NULL;
   retVal->specType = NULL;
   retVal->props    = NULL;
   retVal->symStack = symStack;
   retVal->decls    = decls;
   retVal->expr     = expr;

   return retVal;
}

ProcDefNode *createProcDefNode(INT8 *procName, LinkList *decls, SyntaxTree *defExpr)
{
   ProcDefNode  *retVal = malloc(sizeof(ProcDefNode));

   if(retVal == NULL)
   {
      return NULL;
   }

   retVal->nodeType = NODE_PROC_DEF;
   retVal->ozTex    = NULL;
   retVal->treeType = NULL;
   retVal->specType = NULL;
   retVal->props    = NULL;
   retVal->symStack = symStack;
   retVal->procName = procName;
   retVal->decls    = decls;
   retVal->defExpr  = defExpr;

   return retVal;
}

GenProcDefNode *createGenProcDefNode(INT8 *procName, LinkList *decls, SyntaxTree *defExpr, LinkList *genSyms)
{
   GenProcDefNode  *retVal = malloc(sizeof(GenProcDefNode));

   if(retVal == NULL)
   {
      return NULL;
   }

   retVal->nodeType = NODE_GEN_PROC_DEF;
   retVal->ozTex    = NULL;
   retVal->treeType = NULL;
   retVal->specType = NULL;
   retVal->props    = NULL;
   retVal->symStack = symStack;
   retVal->procName = procName;
   retVal->decls    = decls;
   retVal->defExpr  = defExpr;
   retVal->syms     = genSyms;

   return retVal;
}

ProcAliasNode *createProcAliasNode(INT8 *procName, SyntaxTree *defExpr)
{
   ProcAliasNode  *retVal = malloc(sizeof(ProcAliasNode));

   if(retVal == NULL)
   {
      return NULL;
   }

   retVal->nodeType = NODE_PROC_ALIAS;
   retVal->ozTex    = NULL;
   retVal->treeType = NULL;
   retVal->specType = NULL;
   retVal->symStack = symStack;
   retVal->props    = NULL;
   retVal->name     = procName;
   retVal->defExpr  = defExpr;

   return retVal;
}

ChanAliasNode *createChanAliasNode(INT8 *chanName, SyntaxTree *defExpr)
{
   ChanAliasNode  *retVal = malloc(sizeof(ChanAliasNode));

   if(retVal == NULL)
   {
      return NULL;
   }

   retVal->nodeType = NODE_CHAN_ALIAS;
   retVal->ozTex    = NULL;
   retVal->treeType = NULL;
   retVal->specType = NULL;
   retVal->symStack = symStack;
   retVal->props    = NULL;
   retVal->name     = chanName;
   retVal->defExpr  = defExpr;

   return retVal;
}

CondProcNode *createCondProcNode(LinkList *condList, SyntaxTree *thenProc, SyntaxTree *elseProc)
{
   CondProcNode  *retVal = malloc(sizeof(CondProcNode));

   if(retVal == NULL)
   {
      return NULL;
   }

   retVal->nodeType = NODE_PROC_IF;
   retVal->ozTex    = NULL;
   retVal->treeType = NULL;
   retVal->specType = NULL;
   retVal->props    = NULL;
   retVal->symStack = symStack;
   retVal->condList = condList;
   retVal->thenProc = thenProc;
   retVal->elseProc = elseProc;

   return retVal;
}

ChanFieldNode *createChanFieldNode(UINT16 fieldType, SyntaxTree *fieldExpr)
{
   ChanFieldNode  *retVal = malloc(sizeof(ChanFieldNode));

   if(retVal == NULL)
   {
      return NULL;
   }

   retVal->nodeType  = NODE_CHAN_FIELD;
   retVal->ozTex     = NULL;
   retVal->treeType  = NULL;
   retVal->specType  = NULL;
   retVal->props     = NULL;
   retVal->symStack  = symStack;
   retVal->fieldType = fieldType;
   retVal->fieldExpr = fieldExpr;

   return retVal;
}

ChanApplNode *createChanApplNode(SyntaxTree *chanExpr, LinkList *fields)
{
   ChanApplNode  *retVal = malloc(sizeof(ChanApplNode));

   if(retVal == NULL)
   {
      return NULL;
   }

   retVal->nodeType  = NODE_CHAN_APPL;
   retVal->ozTex     = NULL;
   retVal->treeType  = NULL;
   retVal->specType  = NULL;
   retVal->props     = NULL;
   retVal->symStack  = symStack;
   retVal->chanExpr  = chanExpr;
   retVal->fields    = fields;

   return retVal;
}

ReplProcNode *createReplProcNode(UINT16 replType, LinkList *decls, LinkList *filters, SyntaxTree *expr)
{
   ReplProcNode  *retVal = malloc(sizeof(ReplProcNode));

   if(retVal == NULL)
   {
      return NULL;
   }

   retVal->nodeType  = NODE_REPL_PROC;
   retVal->ozTex     = NULL;
   retVal->treeType  = NULL;
   retVal->specType  = NULL;
   retVal->props     = NULL;
   retVal->symStack  = symStack;
   retVal->decls     = decls;
   retVal->filters   = filters;
   retVal->expr      = expr;
   retVal->replType  = replType;
   retVal->ifAlph    = NULL;

   return retVal;
}

LetProcNode *createLetProcNode(LinkList *decls, SyntaxTree *expr)
{
   LetProcNode  *retVal = malloc(sizeof(LetProcNode));

   if(retVal == NULL)
   {
      return NULL;
   }

   retVal->nodeType = NODE_LET_PROC;
   retVal->ozTex    = NULL;
   retVal->treeType = NULL;
   retVal->specType = NULL;
   retVal->props    = NULL;
   retVal->symStack = symStack;
   retVal->decls    = decls;
   retVal->expr     = expr;

   return retVal;
}
