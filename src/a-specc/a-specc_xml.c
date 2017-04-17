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

static UINT32  tmpLen     = 0;
static UINT32  outLen     = 0;
static INT8    *tmpData   = NULL;
static FILE    *outFile   = NULL;

static UINT32  typeLen   = 0;
static INT8    *typeBuff = NULL;

static void listToXML(LinkList *nodeList, UINT16 indent);
static void docInfoToXML(DocInfoNode *ast, UINT16 indent);
static void infoEntryToXML(InfoEntryNode *ast, UINT16 indent);
static void propertyToXML(PropertyNode *ast, UINT16 indent);
static void directiveToXML(DirectiveNode *ast, UINT16 indent);
static void direcCommandsToXML(LinkList *commList, UINT16 indent);
static void descriptionToXML(DescriptionNode *ast, UINT16 indent);
static void schemaToXML(SchemaNode *ast, UINT16 indent);
static void genSchemaToXML(GenSchemaNode *ast, UINT16 indent);
static void axDefToXML(AxDefNode *ast, UINT16 indent);
static void genDefToXML(GenDefNode *ast, UINT16 indent);
static void constToXML(ConstraintNode *ast, UINT16 indent);
static void basicToXML(BasicDefNode *ast, UINT16 indent);
static void basicEntryToXML(BasicEntryNode *ast, UINT16 indent);
static void typeDefToXML(TypeDefNode *ast, UINT16 indent);
static void typeEntryToXML(TypeEntryNode *ast, UINT16 indent);
static void freeToXML(FreeTypeNode *ast, UINT16 indent);
static void freeEntryToXML(FreeEntryNode *ast, UINT16 indent);
static void declToXML(DeclarationNode *ast, UINT16 indent);
static void procAliasToXML(ProcAliasNode *ast, UINT16 indent);
static void chanAliasToXML(ChanAliasNode *ast, UINT16 indent);
static void predToXML(PredicateNode *ast, UINT16 indent);
static void exprToXML(SyntaxTree *ast, UINT16 indent);
static void exprOpToXML(ExprOpNode *ast, UINT16 indent);
static void exprFuncToXML(ExprFuncNode *ast, UINT16 indent);
static void variableToXML(VariableNode *ast, UINT16 indent);
static void exprLiteralToXML(ExprLiteralNode *ast, UINT16 indent);
static void exprIdentToXML(ExprIdentNode *ast, UINT16 indent);
static void genIdentToXML(ExprGenIdentNode *ast, UINT16 indent);
static void exprIfToXML(CondExprNode *ast, UINT16 indent);
static void tupleToXML(TupleNode *ast, UINT16 indent);
static void crossToXML(CrossNode *ast, UINT16 indent);
static void bindToXML(SchemaBindNode *ast, UINT16 indent);
static void bindEntryToXML(BindEntryNode *ast, UINT16 indent);
static void selectToXML(SelectNode *ast, UINT16 indent);
static void schTypeToXML(SchemaTypeNode *ast, UINT16 indent);
static void setDispToXML(SetDispNode *ast, UINT16 indent);
static void seqDispToXML(SeqDispNode *ast, UINT16 indent);
static void uptoToXML(UptoNode *ast, UINT16 indent);
static void setCompToXML(SetCompNode *ast, UINT16 indent);
static void lambdaToXML(LambdaNode *ast, UINT16 indent);
static void muToXML(MuNode *ast, UINT16 indent);
static void letExprToXML(LetExprNode *ast, UINT16 indent);
static void predTypeToXML(SyntaxTree *ast, UINT16 indent);
static void predToXML(PredicateNode *ast, UINT16 indent);
static void predOpToXML(PredOpNode *ast, UINT16 indent);
static void predRelToXML(PredRelNode *ast, UINT16 indent);
static void predFuncToXML(PredFuncNode *ast, UINT16 indent);
static void predLiteralToXML(PredLiteralNode *ast, UINT16 indent);
static void predQuantToXML(PredQuantNode *ast, UINT16 indent);
static void letPredToXML(LetPredNode *ast, UINT16 indent);
static void schemaAppToXML(SchemaAppNode *ast, UINT16 indent);
static void predIfToXML(CondPredNode *ast, UINT16 indent);
static void unknownToXML(SyntaxTree *ast, UINT16 indent);
static void procToXML(ProcessNode *ast, UINT16 indent);
static void procDefToXML(ProcDefNode *ast, UINT16 indent);
static void genProcDefToXML(GenProcDefNode *ast, UINT16 indent);
static void chanApplToXML(ChanApplNode *ast, UINT16 indent);
static void chanFieldToXML(ChanFieldNode *ast, UINT16 indent);
static void replProcToXML(ReplProcNode *ast, UINT16 indent);
static void letProcToXML(LetProcNode *ast, UINT16 indent);
static void procIfToXML(CondProcNode *ast, UINT16 indent);

static void appendTypeStr(INT8 *new)
{
   if((strlen(typeBuff) + strlen(new)) >= typeLen)
   {
      INT8  *tmpBuff = typeBuff;

      typeBuff = malloc(1024 + typeLen);
      typeLen  = typeLen + 1024;

      memset(typeBuff, 0, typeLen);

      strcpy(typeBuff, tmpBuff);

      free(tmpBuff);
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

static void reallocTmpData(UINT32 addLen)
{
   if((strlen(tmpData) + addLen) >= tmpLen)
   {
      INT8  *tmpBuff = tmpData;

      tmpLen  = strlen(tmpBuff) + addLen + 1024;
      tmpData = malloc(tmpLen);

      memset(tmpData, 0, tmpLen);

      strcpy(tmpData, tmpBuff);

      free(tmpBuff);
   }
}

static INT8 *fixXMLString(INT8 *data)
{
   INT8  *curPtr = data;

   if(strlen(data) >= tmpLen)
   {
      free(tmpData);

      tmpLen  = strlen(data) + 1024;
      tmpData = malloc(tmpLen);

      memset(tmpData, 0, tmpLen);
   }

   memset(tmpData, 0, strlen(tmpData));

   while(strlen(curPtr) > 0)
   {
      INT8  *brk = strpbrk(curPtr, "&<>\"'");

      if(brk == NULL)
      {
         reallocTmpData(strlen(curPtr));
         strncpy(&(tmpData[strlen(tmpData)]), curPtr, strlen(curPtr));

         curPtr = &(curPtr[strlen(curPtr)]);
      }
      else
      {
         UINT32  writeLen = brk - curPtr;

         reallocTmpData(writeLen + 10); /* Adding a bit of extra padding because I don't feel like adding now */

         if(writeLen > 0)
         {
            strncpy(&(tmpData[strlen(tmpData)]), curPtr, writeLen);
         }

         if(brk[0] == '&')
         {
            strncpy(&(tmpData[strlen(tmpData)]), "&amp;", 5);
         }
         else if(brk[0] == '<')
         {
            strncpy(&(tmpData[strlen(tmpData)]), "&lt;", 4);
         }
         else if(brk[0] == '>')
         {
            strncpy(&(tmpData[strlen(tmpData)]), "&gt;", 4);
         }
         else if(brk[0] == '"')
         {
            strncpy(&(tmpData[strlen(tmpData)]), "&quot;", 6);
         }
         else if(brk[0] == '\'')
         {
            strncpy(&(tmpData[strlen(tmpData)]), "&apos;", 6);
         }

         curPtr = &(curPtr[writeLen + 1]);
      } // else (brk != NULL)
   } // while(strlen(curPtr) > 0)

   return tmpData;
}

static INT8 *getTypeStr(TreeType *src)
{
   memset(typeBuff, 0, typeLen);

   if(src != NULL)
   {
      doTypeStr(src);
   }

   return fixXMLString(typeBuff);
}

static INT8 *strListToString(LinkList *strList, INT8 *delim)
{
   if(strList == NULL)
   {
      return NULL;
   }

   INT8  *remain = strListToString(strList->next, delim);
   INT8  *retVal = NULL;

   if((remain != NULL) && (strlen(remain) > 0))
   {
      if(strList->object != NULL)
      {
         asprintf((char **) &retVal, "%s%s%s", (INT8 *) strList->object, delim, remain);
         free(remain);

         return retVal;
      }
      else
      {
         return remain;
      }
   }
   else if(strList->object != NULL)
   {
      return strdup(strList->object);
   }

   return NULL;
}

static void xmlWrite(UINT16 indent, INT8 *fmt, ...)
{
   va_list  argList;
   UINT16   loop;

   va_start(argList, fmt);

   for(loop = 0; loop < indent; loop++)
   {
      fprintf(outFile, " ");
   }

   vfprintf(outFile, fmt, argList);
   fprintf(outFile, "\n");
}

static void xmlWriteExact(INT8 *fmt, ...)
{
   va_list  argList;

   va_start(argList, fmt);

   vfprintf(outFile, fmt, argList);
}

static UINT16 pushIndent(UINT16 indent)
{
   return indent + xmlIndent;
}

static void docInfoToXML(DocInfoNode *ast, UINT16 indent)
{
   xmlWrite(indent, "<DocumentInfo>");

   if(ast->infoEntries != NULL)
   {
      xmlWrite(pushIndent(indent), "<InfoEntries>");
      listToXML(ast->infoEntries, pushIndent(pushIndent(indent)));
      xmlWrite(pushIndent(indent), "</InfoEntries>");
   }
   else
   {
      xmlWrite(pushIndent(indent), "<InfoEntries/>");
   }

   xmlWrite(indent, "</DocumentInfo>");
}

static void infoEntryToXML(InfoEntryNode *ast, UINT16 indent)
{
   xmlWrite(indent, "<InfoEntry>");

   if(ast->infoList != NULL)
   {
      INT8  *infoStr = strListToString(ast->infoList, " ");

      xmlWrite(pushIndent(indent), "%s", fixXMLString(infoStr));

      free(infoStr);
   }

   xmlWrite(indent, "</InfoEntry>");
}

static void propertyToXML(PropertyNode *ast, UINT16 indent)
{
   xmlWrite(indent, "<PropertyEntry>");

   if(ast->propList != NULL)
   {
      INT8  *propStr = strListToString(ast->propList, " ");

      xmlWrite(pushIndent(indent), "%s", fixXMLString(propStr));

      free(propStr);
   }

   xmlWrite(indent, "</PropertyEntry>");
}

static void directiveToXML(DirectiveNode *ast, UINT16 indent)
{
   if(!exportCheck(getLayer(ast->props)))
   {
      return;
   }

   xmlWrite(indent, "<Directive>");

   if(ast->props != NULL)
   {
      xmlWrite(pushIndent(indent), "<Properties>");
      listToXML(ast->props, pushIndent(pushIndent(indent)));
      xmlWrite(pushIndent(indent), "</Properties>");
   }
   else
   {
      xmlWrite(pushIndent(indent), "<Properties/>");
   }

   if(ast->commands != NULL)
   {
      xmlWrite(pushIndent(indent), "<Commands>");
      direcCommandsToXML(ast->commands, pushIndent(pushIndent(indent)));
      xmlWrite(pushIndent(indent), "</Commands>");
   }
   else
   {
      xmlWrite(pushIndent(indent), "<Commands/>");
   }

   xmlWrite(indent, "</Directive>");
}

static void direcCommandsToXML(LinkList *commList, UINT16 indent)
{
   while(commList != NULL)
   {
      if(commList->object != NULL)
      {
         xmlWrite(indent, "<Command>");

         INT8  *commStr = strListToString((LinkList *) commList->object, " ");

         xmlWrite(pushIndent(indent), "%s", fixXMLString(commStr));
         xmlWrite(indent, "</Command>");
         free(commStr);
      }

      commList = commList->next;
   }
}

static void descriptionToXML(DescriptionNode *ast, UINT16 indent)
{
   if(!exportCheck(getLayer(ast->props)))
   {
      return;
   }

   xmlWrite(indent, "<Description>");

   if(ast->props != NULL)
   {
      xmlWrite(pushIndent(indent), "<Properties>");
      listToXML(ast->props, pushIndent(pushIndent(indent)));
      xmlWrite(pushIndent(indent), "</Properties>");
   }
   else
   {
      xmlWrite(pushIndent(indent), "<Properties/>");
   }

   if(ast->text != NULL)
   {
      xmlWrite(pushIndent(indent), "<Text>");
      xmlWriteExact("%s", fixXMLString(ast->text));
      xmlWrite(pushIndent(indent), "</Text>");
   }
   else
   {
      xmlWrite(pushIndent(indent), "<Text/>");
   }

   xmlWrite(indent, "</Description>");
}

static void schemaToXML(SchemaNode *ast, UINT16 indent)
{
   if(!exportCheck(getLayer(ast->props)))
   {
      return;
   }

   xmlWrite(indent, "<Schema name=\"%s\">", fixXMLString(ast->name));

   if(ast->props != NULL)
   {
      xmlWrite(pushIndent(indent), "<Properties>");
      listToXML(ast->props, pushIndent(pushIndent(indent)));
      xmlWrite(pushIndent(indent), "</Properties>");
   }
   else
   {
      xmlWrite(pushIndent(indent), "<Properties/>");
   }

   if(ast->decls != NULL)
   {
      xmlWrite(pushIndent(indent), "<Declarations>");
      listToXML(ast->decls, pushIndent(pushIndent(indent)));
      xmlWrite(pushIndent(indent), "</Declarations>");
   }
   else
   {
      xmlWrite(pushIndent(indent), "<Declarations/>");
   }

   if(ast->preds != NULL)
   {
      xmlWrite(pushIndent(indent), "<Predicates>");
      listToXML(ast->preds, pushIndent(pushIndent(indent)));
      xmlWrite(pushIndent(indent), "</Predicates>");
   }
   else
   {
      xmlWrite(pushIndent(indent), "<Predicates/>");
   }

   xmlWrite(indent, "</Schema>");
}

static void genSchemaToXML(GenSchemaNode *ast, UINT16 indent)
{
   if(!exportCheck(getLayer(ast->props)))
   {
      return;
   }

   INT8  *syms = strListToString(ast->syms, ", ");

   if(syms != NULL)
   {
      INT8  *symFixed = strdup(fixXMLString(syms));

      xmlWrite(indent, "<GenSchema name=\"%s\" syms=\"%s\">", fixXMLString(ast->name), symFixed);

      free(symFixed);
      free(syms);
   }
   else
   {
      xmlWrite(indent, "<GenSchema name=\"%s\" syms=\"\">", fixXMLString(ast->name));
   }

   if(ast->props != NULL)
   {
      xmlWrite(pushIndent(indent), "<Properties>");
      listToXML(ast->props, pushIndent(pushIndent(indent)));
      xmlWrite(pushIndent(indent), "</Properties>");
   }
   else
   {
      xmlWrite(pushIndent(indent), "<Properties/>");
   }

   if(ast->decls != NULL)
   {
      xmlWrite(pushIndent(indent), "<Declarations>");
      listToXML(ast->decls, pushIndent(pushIndent(indent)));
      xmlWrite(pushIndent(indent), "</Declarations>");
   }
   else
   {
      xmlWrite(pushIndent(indent), "<Declarations/>");
   }

   if(ast->preds != NULL)
   {
      xmlWrite(pushIndent(indent), "<Predicates>");
      listToXML(ast->preds, pushIndent(pushIndent(indent)));
      xmlWrite(pushIndent(indent), "</Predicates>");
   }
   else
   {
      xmlWrite(pushIndent(indent), "<Predicates/>");
   }

   xmlWrite(indent, "</GenSchema>");
}

static void constToXML(ConstraintNode *ast, UINT16 indent)
{
   if(!exportCheck(getLayer(ast->props)))
   {
      return;
   }

   xmlWrite(indent, "<Constraint name=\"%s\">", fixXMLString(ast->name));

   if(ast->props != NULL)
   {
      xmlWrite(pushIndent(indent), "<Properties>");
      listToXML(ast->props, pushIndent(pushIndent(indent)));
      xmlWrite(pushIndent(indent), "</Properties>");
   }
   else
   {
      xmlWrite(pushIndent(indent), "<Properties/>");
   }

   if(ast->preds != NULL)
   {
      xmlWrite(pushIndent(indent), "<Predicates>");
      listToXML(ast->preds, pushIndent(pushIndent(indent)));
      xmlWrite(pushIndent(indent), "</Predicates>");
   }
   else
   {
      xmlWrite(pushIndent(indent), "<Predicates/>");
   }

   xmlWrite(indent, "</Constraint>");
}

static void axDefToXML(AxDefNode *ast, UINT16 indent)
{
   if(!exportCheck(getLayer(ast->props)))
   {
      return;
   }

   xmlWrite(indent, "<AxDef name=\"%s\">", fixXMLString(ast->name));

   if(ast->props != NULL)
   {
      xmlWrite(pushIndent(indent), "<Properties>");
      listToXML(ast->props, pushIndent(pushIndent(indent)));
      xmlWrite(pushIndent(indent), "</Properties>");
   }
   else
   {
      xmlWrite(pushIndent(indent), "<Properties/>");
   }

   if(ast->decls != NULL)
   {
      xmlWrite(pushIndent(indent), "<Declarations>");
      listToXML(ast->decls, pushIndent(pushIndent(indent)));
      xmlWrite(pushIndent(indent), "</Declarations>");
   }
   else
   {
      xmlWrite(pushIndent(indent), "<Declarations/>");
   }

   if(ast->preds != NULL)
   {
      xmlWrite(pushIndent(indent), "<Predicates>");
      listToXML(ast->preds, pushIndent(pushIndent(indent)));
      xmlWrite(pushIndent(indent), "</Predicates>");
   }
   else
   {
      xmlWrite(pushIndent(indent), "<Predicates/>");
   }

   xmlWrite(indent, "</AxDef>");
}

static void genDefToXML(GenDefNode *ast, UINT16 indent)
{
   if(!exportCheck(getLayer(ast->props)))
   {
      return;
   }

   INT8  *syms = strListToString(ast->syms, ", ");

   if(syms != NULL)
   {
      INT8  *symFixed = strdup(fixXMLString(syms));

      xmlWrite(indent, "<GenDef name=\"%s\" syms=\"%s\">", ast->name, symFixed);

      free(syms);
      free(symFixed);
   }
   else
   {
      xmlWrite(indent, "<GenDef name=\"%s\" syms=\"\">", ast->name);
   }

   if(ast->props != NULL)
   {
      xmlWrite(pushIndent(indent), "<Properties>");
      listToXML(ast->props, pushIndent(pushIndent(indent)));
      xmlWrite(pushIndent(indent), "</Properties>");
   }
   else
   {
      xmlWrite(pushIndent(indent), "<Properties/>");
   }

   if(ast->decls != NULL)
   {
      xmlWrite(pushIndent(indent), "<Declarations>");
      listToXML(ast->decls, pushIndent(pushIndent(indent)));
      xmlWrite(pushIndent(indent), "</Declarations>");
   }
   else
   {
      xmlWrite(pushIndent(indent), "<Declarations/>");
   }

   if(ast->preds != NULL)
   {
      xmlWrite(pushIndent(indent), "<Predicates>");
      listToXML(ast->preds, pushIndent(pushIndent(indent)));
      xmlWrite(pushIndent(indent), "</Predicates>");
   }
   else
   {
      xmlWrite(pushIndent(indent), "<Predicates/>");
   }

   xmlWrite(indent, "</GenDef>");
}

static void basicToXML(BasicDefNode *ast, UINT16 indent)
{
   if(!exportCheck(getLayer(ast->props)))
   {
      return;
   }

   xmlWrite(indent, "<BasicDef name=\"%s\">", fixXMLString(ast->name));

   if(ast->props != NULL)
   {
      xmlWrite(pushIndent(indent), "<Properties>");
      listToXML(ast->props, pushIndent(pushIndent(indent)));
      xmlWrite(pushIndent(indent), "</Properties>");
   }
   else
   {
      xmlWrite(pushIndent(indent), "<Properties/>");
   }

   if(ast->entries != NULL)
   {
      xmlWrite(pushIndent(indent), "<BasicTypes>");
      listToXML(ast->entries, pushIndent(pushIndent(indent)));
      xmlWrite(pushIndent(indent), "</BasicTypes>");
   }
   else
   {
      xmlWrite(pushIndent(indent), "<BasicTypes/>");
   }

   xmlWrite(indent, "</BasicDef>");
}

static void basicEntryToXML(BasicEntryNode *ast, UINT16 indent)
{
   xmlWrite(indent, "<BasicType name=\"%s\">", fixXMLString(ast->name));

   if(ast->props != NULL)
   {
      xmlWrite(pushIndent(indent), "<Properties>");
      listToXML(ast->props, pushIndent(pushIndent(indent)));
      xmlWrite(pushIndent(indent), "</Properties>");
   }
   else
   {
      xmlWrite(pushIndent(indent), "<Properties/>");
   }

   xmlWrite(pushIndent(indent), "<TypeTree type=\"%s\"/>", getTypeStr(ast->treeType));
   xmlWrite(indent, "</BasicType>");
}

static void typeDefToXML(TypeDefNode *ast, UINT16 indent)
{
   if(!exportCheck(getLayer(ast->props)))
   {
      return;
   }

   xmlWrite(indent, "<TypeDef name=\"%s\">", fixXMLString(ast->name));

   if(ast->props != NULL)
   {
      xmlWrite(pushIndent(indent), "<Properties>");
      listToXML(ast->props, pushIndent(pushIndent(indent)));
      xmlWrite(pushIndent(indent), "</Properties>");
   }
   else
   {
      xmlWrite(pushIndent(indent), "<Properties/>");
   }

   if(ast->entries != NULL)
   {
      xmlWrite(pushIndent(indent), "<DataTypes>");
      listToXML(ast->entries, pushIndent(pushIndent(indent)));
      xmlWrite(pushIndent(indent), "</DataTypes>");
   }
   else
   {
      xmlWrite(pushIndent(indent), "<DataTypes/>");
   }

   xmlWrite(indent, "</TypeDef>");
}

static void typeEntryToXML(TypeEntryNode *ast, UINT16 indent)
{
   xmlWrite(indent, "<DataType name=\"%s\">", fixXMLString(ast->name));

   if(ast->props != NULL)
   {
      xmlWrite(pushIndent(indent), "<Properties>");
      listToXML(ast->props, pushIndent(pushIndent(indent)));
      xmlWrite(pushIndent(indent), "</Properties>");
   }
   else
   {
      xmlWrite(pushIndent(indent), "<Properties/>");
   }

   if(ast->preGen != NULL)
   {
      xmlWrite(pushIndent(indent), "<PreGen sym=\"%s\"/>", fixXMLString(ast->preGen));
   }
   else
   {
      xmlWrite(pushIndent(indent), "<PreGen/>");
   }

   if(ast->postGen != NULL)
   {
      xmlWrite(pushIndent(indent), "<PostGen sym=\"%s\"/>", fixXMLString(ast->postGen));
   }
   else
   {
      xmlWrite(pushIndent(indent), "<PostGen/>");
   }

   if(ast->defExpr != NULL)
   {
      xmlWrite(pushIndent(indent), "<DefiningExpression>");
      exprToXML(ast->defExpr, pushIndent(indent));
      xmlWrite(pushIndent(indent), "</DefiningExpression>");
   }
   else
   {
      xmlWrite(pushIndent(indent), "<DefiningExpression/>");
   }

   xmlWrite(pushIndent(indent), "<TypeTree type=\"%s\"/>", getTypeStr(ast->treeType));
   xmlWrite(indent, "</DataType>");
}

static void freeToXML(FreeTypeNode *ast, UINT16 indent)
{
   if(!exportCheck(getLayer(ast->props)))
   {
      return;
   }

   xmlWrite(indent, "<FreeDef name=\"%s\">", fixXMLString(ast->name));

   if(ast->props != NULL)
   {
      xmlWrite(pushIndent(indent), "<Properties>");
      listToXML(ast->props, pushIndent(pushIndent(indent)));
      xmlWrite(pushIndent(indent), "</Properties>");
   }
   else
   {
      xmlWrite(pushIndent(indent), "<Properties/>");
   }

   if(ast->entries != NULL)
   {
      xmlWrite(pushIndent(indent), "<FreeTypes>");
      listToXML(ast->entries, pushIndent(pushIndent(indent)));
      xmlWrite(pushIndent(indent), "</FreeTypes>");
   }
   else
   {
      xmlWrite(pushIndent(indent), "<FreeTypes/>");
   }

   xmlWrite(indent, "</FreeDef>");
}

static void freeEntryToXML(FreeEntryNode *ast, UINT16 indent)
{
   xmlWrite(indent, "<FreeType name=\"%s\">", fixXMLString(ast->name));

   if(ast->props != NULL)
   {
      xmlWrite(pushIndent(indent), "<Properties>");
      listToXML(ast->props, pushIndent(pushIndent(indent)));
      xmlWrite(pushIndent(indent), "</Properties>");
   }
   else
   {
      xmlWrite(pushIndent(indent), "<Properties/>");
   }

   if(ast->freeVars != NULL)
   {
      xmlWrite(pushIndent(indent), "<FreeVars>");
      listToXML(ast->freeVars, pushIndent(pushIndent(indent)));
      xmlWrite(pushIndent(indent), "</FreeVars>");
   }
   else
   {
      xmlWrite(pushIndent(indent), "<FreeVars/>");
   }

   xmlWrite(pushIndent(indent), "<TypeTree type=\"%s\"/>", getTypeStr(ast->treeType));
   xmlWrite(indent, "</FreeType>");
}

static void exprOpToXML(ExprOpNode *ast, UINT16 indent)
{
   xmlWrite(indent, "<ExpressionOperator name=\"%s\">", fixXMLString(ast->opName));

   if(ast->props != NULL)
   {
      xmlWrite(pushIndent(indent), "<Properties>");
      listToXML(ast->props, pushIndent(pushIndent(indent)));
      xmlWrite(pushIndent(indent), "</Properties>");
   }
   else
   {
      xmlWrite(pushIndent(indent), "<Properties/>");
   }

   if(ast->left != NULL)
   {
      xmlWrite(pushIndent(indent), "<Left>");
      exprToXML(ast->left, pushIndent(pushIndent(indent)));
      xmlWrite(pushIndent(indent), "</Left>");
   }
   else
   {
      xmlWrite(pushIndent(indent), "<Left/>");
   }

   if(ast->qualifier != NULL)
   {
      xmlWrite(pushIndent(indent), "<Qualifier>");
      exprToXML(ast->qualifier, pushIndent(pushIndent(indent)));
      xmlWrite(pushIndent(indent), "</Qualifier>");
   }
   else
   {
      xmlWrite(pushIndent(indent), "<Qualifier/>");
   }

   if(ast->right != NULL)
   {
      xmlWrite(pushIndent(indent), "<Right>");
      exprToXML(ast->right, pushIndent(pushIndent(indent)));
      xmlWrite(pushIndent(indent), "</Right>");
   }
   else
   {
      xmlWrite(pushIndent(indent), "<Right/>");
   }

   xmlWrite(pushIndent(indent), "<TypeTree type=\"%s\"/>", getTypeStr(ast->treeType));
   xmlWrite(indent, "</ExpressionOperator>");
}

static void exprFuncToXML(ExprFuncNode *ast, UINT16 indent)
{
   xmlWrite(indent, "<ExpressionFunction>");

   if(ast->props != NULL)
   {
      xmlWrite(pushIndent(indent), "<Properties>");
      listToXML(ast->props, pushIndent(pushIndent(indent)));
      xmlWrite(pushIndent(indent), "</Properties>");
   }
   else
   {
      xmlWrite(pushIndent(indent), "<Properties/>");
   }

   if(ast->funcExpr != NULL)
   {
      xmlWrite(pushIndent(indent), "<Function>");
      exprToXML(ast->funcExpr, pushIndent(pushIndent(indent)));
      xmlWrite(pushIndent(indent), "</Function>");
   }
   else
   {
      xmlWrite(pushIndent(indent), "<Function/>");
   }

   if(ast->params != NULL)
   {
      xmlWrite(pushIndent(indent), "<Parameters>");
      exprToXML(ast->params, pushIndent(pushIndent(indent)));
      xmlWrite(pushIndent(indent), "</Parameters>");
   }
   else
   {
      xmlWrite(pushIndent(indent), "<Parameters/>");
   }

   xmlWrite(pushIndent(indent), "<TypeTree type=\"%s\"/>", getTypeStr(ast->treeType));
   xmlWrite(indent, "</ExpressionFunction>");
}

static void variableToXML(VariableNode *ast, UINT16 indent)
{
   xmlWrite(indent, "<Variable name=\"%s\">", fixXMLString(ast->name));

   if(ast->props != NULL)
   {
      xmlWrite(pushIndent(indent), "<Properties>");
      listToXML(ast->props, pushIndent(pushIndent(indent)));
      xmlWrite(pushIndent(indent), "</Properties>");
   }
   else
   {
      xmlWrite(pushIndent(indent), "<Properties/>");
   }

   INT8  *decorType = NULL;

   switch(ast->postDecor)
   {
      case POST_PRI:
         decorType = "prime";
      break;

      case POST_IN:
         decorType = "input";
      break;

      case POST_OUT:
         decorType = "output";
      break;

      case DECOR_NULL:
      break;

      case PRE_DELTA:
         decorType = "invalid";
      break;

      default:
         decorType = "unknown";
      break;
   }

   if(decorType != NULL)
   {
      xmlWrite(pushIndent(indent), "<Decoration type=\"%s\" degree=\"%d\"/>", decorType, ast->postCnt);
   }
   else
   {
      xmlWrite(pushIndent(indent), "<Decoration/>");
   }

   xmlWrite(pushIndent(indent), "<TypeTree type=\"%s\"/>", getTypeStr(ast->treeType));
   xmlWrite(indent, "</Variable>");
}

static void exprLiteralToXML(ExprLiteralNode *ast, UINT16 indent)
{
   xmlWrite(indent, "<ExpressionLiteral value=\"%s\">", fixXMLString(ast->value));

   if(ast->props != NULL)
   {
      xmlWrite(pushIndent(indent), "<Properties>");
      listToXML(ast->props, pushIndent(pushIndent(indent)));
      xmlWrite(pushIndent(indent), "</Properties>");
   }
   else
   {
      xmlWrite(pushIndent(indent), "<Properties/>");
   }

   xmlWrite(pushIndent(indent), "<TypeTree type=\"%s\"/>", getTypeStr(ast->treeType));
   xmlWrite(indent, "</ExpressionLiteral>");
}

static void exprIdentToXML(ExprIdentNode *ast, UINT16 indent)
{
   xmlWrite(indent, "<ExpressionIdent ident=\"%s\">", fixXMLString(ast->ident));

   if(ast->props != NULL)
   {
      xmlWrite(pushIndent(indent), "<Properties>");
      listToXML(ast->props, pushIndent(pushIndent(indent)));
      xmlWrite(pushIndent(indent), "</Properties>");
   }
   else
   {
      xmlWrite(pushIndent(indent), "<Properties/>");
   }

   if(ast->preSpec != NULL)
   {
      xmlWrite(pushIndent(indent), "<PreSpecifier>");
      exprToXML(ast->preSpec, pushIndent(pushIndent(indent)));
      xmlWrite(pushIndent(indent), "</PreSpecifier>");
   }
   else
   {
      xmlWrite(pushIndent(indent), "<PreSpecifier/>");
   }

   if(ast->postSpec != NULL)
   {
      xmlWrite(pushIndent(indent), "<PostSpecifier>");
      exprToXML(ast->postSpec, pushIndent(pushIndent(indent)));
      xmlWrite(pushIndent(indent), "</PostSpecifier>");
   }
   else
   {
      xmlWrite(pushIndent(indent), "<PostSpecifier/>");
   }

   if(ast->specList != NULL)
   {
      xmlWrite(pushIndent(indent), "<SpecifierList>");
      listToXML(ast->specList, pushIndent(pushIndent(indent)));
      xmlWrite(pushIndent(indent), "</SpecifierList>");
   }
   else
   {
      xmlWrite(pushIndent(indent), "<SpecifierList/>");
   }

   xmlWrite(pushIndent(indent), "<TypeTree type=\"%s\"/>", getTypeStr(ast->treeType));
   xmlWrite(indent, "</ExpressionIdent>");
}

static void genIdentToXML(ExprGenIdentNode *ast, UINT16 indent)
{
   xmlWrite(indent, "<GenericIdentifier ident=\"%s\">", fixXMLString(ast->ident));

   if(ast->props != NULL)
   {
      xmlWrite(pushIndent(indent), "<Properties>");
      listToXML(ast->props, pushIndent(pushIndent(indent)));
      xmlWrite(pushIndent(indent), "</Properties>");
   }
   else
   {
      xmlWrite(pushIndent(indent), "<Properties/>");
   }

   xmlWrite(pushIndent(indent), "<TypeTree type=\"%s\"/>", getTypeStr(ast->treeType));
   xmlWrite(indent, "</GenericIdentifier>");
}

static void exprIfToXML(CondExprNode *ast, UINT16 indent)
{
   xmlWrite(indent, "<ConditionalExpression>");

   if(ast->props != NULL)
   {
      xmlWrite(pushIndent(indent), "<Properties>");
      listToXML(ast->props, pushIndent(pushIndent(indent)));
      xmlWrite(pushIndent(indent), "</Properties>");
   }
   else
   {
      xmlWrite(pushIndent(indent), "<Properties/>");
   }

   if(ast->condList != NULL)
   {
      xmlWrite(pushIndent(indent), "<Conditionals>");
      listToXML(ast->condList, pushIndent(pushIndent(indent)));
      xmlWrite(pushIndent(indent), "</Conditionals>");
   }
   else
   {
      xmlWrite(pushIndent(indent), "<Conditionals/>");
   }

   if(ast->thenExpr != NULL)
   {
      xmlWrite(pushIndent(indent), "<ThenExpression>");
      exprToXML(ast->thenExpr, pushIndent(pushIndent(indent)));
      xmlWrite(pushIndent(indent), "</ThenExpression>");
   }
   else
   {
      xmlWrite(pushIndent(indent), "<ThenExpression/>");
   }

   if(ast->elseExpr != NULL)
   {
      xmlWrite(pushIndent(indent), "<ElseExpression>");
      exprToXML(ast->elseExpr, pushIndent(pushIndent(indent)));
      xmlWrite(pushIndent(indent), "</ElseExpression>");
   }
   else
   {
      xmlWrite(pushIndent(indent), "<ElseExpression/>");
   }

   xmlWrite(pushIndent(indent), "<TypeTree type=\"%s\"/>", getTypeStr(ast->treeType));
   xmlWrite(indent, "</ConditionalExpression>");
}

static void tupleToXML(TupleNode *ast, UINT16 indent)
{
   xmlWrite(indent, "<Tuple>");

   if(ast->props != NULL)
   {
      xmlWrite(pushIndent(indent), "<Properties>");
      listToXML(ast->props, pushIndent(pushIndent(indent)));
      xmlWrite(pushIndent(indent), "</Properties>");
   }
   else
   {
      xmlWrite(pushIndent(indent), "<Properties/>");
   }

   if(ast->exprList != NULL)
   {
      xmlWrite(pushIndent(indent), "<ExpressionList>");
      listToXML(ast->exprList, pushIndent(pushIndent(indent)));
      xmlWrite(pushIndent(indent), "</ExpressionList>");
   }
   else
   {
      xmlWrite(pushIndent(indent), "<ExpressionList/>");
   }

   xmlWrite(pushIndent(indent), "<TypeTree type=\"%s\"/>", getTypeStr(ast->treeType));
   xmlWrite(indent, "</Tuple>");
}

static void crossToXML(CrossNode *ast, UINT16 indent)
{
   xmlWrite(indent, "<Cross>");

   if(ast->props != NULL)
   {
      xmlWrite(pushIndent(indent), "<Properties>");
      listToXML(ast->props, pushIndent(pushIndent(indent)));
      xmlWrite(pushIndent(indent), "</Properties>");
   }
   else
   {
      xmlWrite(pushIndent(indent), "<Properties/>");
   }

   if(ast->exprList != NULL)
   {
      xmlWrite(pushIndent(indent), "<ExpressionList>");
      listToXML(ast->exprList, pushIndent(pushIndent(indent)));
      xmlWrite(pushIndent(indent), "</ExpressionList>");
   }
   else
   {
      xmlWrite(pushIndent(indent), "<ExpressionList/>");
   }

   xmlWrite(pushIndent(indent), "<TypeTree type=\"%s\"/>", getTypeStr(ast->treeType));
   xmlWrite(indent, "</Cross>");
}

static void bindToXML(SchemaBindNode *ast, UINT16 indent)
{
   xmlWrite(indent, "<SchemaBinding>");

   if(ast->props != NULL)
   {
      xmlWrite(pushIndent(indent), "<Properties>");
      listToXML(ast->props, pushIndent(pushIndent(indent)));
      xmlWrite(pushIndent(indent), "</Properties>");
   }
   else
   {
      xmlWrite(pushIndent(indent), "<Properties/>");
   }

   if(ast->bindList != NULL)
   {
      xmlWrite(pushIndent(indent), "<BindList>");
      listToXML(ast->bindList, pushIndent(pushIndent(indent)));
      xmlWrite(pushIndent(indent), "</BindList>");
   }
   else
   {
      xmlWrite(pushIndent(indent), "<BindList/>");
   }

   xmlWrite(pushIndent(indent), "<TypeTree type=\"%s\"/>", getTypeStr(ast->treeType));
   xmlWrite(indent, "</SchemaBinding>");
}

static void bindEntryToXML(BindEntryNode *ast, UINT16 indent)
{
   xmlWrite(indent, "<BindEntry>");

   if(ast->props != NULL)
   {
      xmlWrite(pushIndent(indent), "<Properties>");
      listToXML(ast->props, pushIndent(pushIndent(indent)));
      xmlWrite(pushIndent(indent), "</Properties>");
   }
   else
   {
      xmlWrite(pushIndent(indent), "<Properties/>");
   }

   if(ast->var != NULL)
   {
      xmlWrite(pushIndent(indent), "<BindVar>");
      variableToXML(ast->var, pushIndent(pushIndent(indent)));
      xmlWrite(pushIndent(indent), "</BindVar>");
   }
   else
   {
      xmlWrite(pushIndent(indent), "<BindVar/>");
   }

   if(ast->expr != NULL)
   {
      xmlWrite(pushIndent(indent), "<BindExpression>");
      exprToXML(ast->expr, pushIndent(pushIndent(indent)));
      xmlWrite(pushIndent(indent), "</BindExpression>");
   }
   else
   {
      xmlWrite(pushIndent(indent), "<BindExpression/>");
   }

   xmlWrite(pushIndent(indent), "<TypeTree type=\"%s\"/>", getTypeStr(ast->treeType));
   xmlWrite(indent, "</BindEntry>");
}

static void selectToXML(SelectNode *ast, UINT16 indent)
{
   xmlWrite(indent, "<Select>");

   if(ast->props != NULL)
   {
      xmlWrite(pushIndent(indent), "<Properties>");
      listToXML(ast->props, pushIndent(pushIndent(indent)));
      xmlWrite(pushIndent(indent), "</Properties>");
   }
   else
   {
      xmlWrite(pushIndent(indent), "<Properties/>");
   }

   if(ast->leftExpr != NULL)
   {
      xmlWrite(pushIndent(indent), "<SchemaExpression>");
      exprToXML(ast->leftExpr, pushIndent(pushIndent(indent)));
      xmlWrite(pushIndent(indent), "</SchemaExpression>");
   }
   else
   {
      xmlWrite(pushIndent(indent), "<SchemaExpression/>");
   }

   if(ast->var != NULL)
   {
      xmlWrite(pushIndent(indent), "<SchemaVar>");
      variableToXML(ast->var, pushIndent(pushIndent(indent)));
      xmlWrite(pushIndent(indent), "</SchemaVar>");
   }
   else
   {
      xmlWrite(pushIndent(indent), "<SchemaVar/>");
   }

   xmlWrite(pushIndent(indent), "<TypeTree type=\"%s\"/>", getTypeStr(ast->treeType));
   xmlWrite(indent, "</Select>");
}

static void schTypeToXML(SchemaTypeNode *ast, UINT16 indent)
{
   INT8  *preDecor  = NULL;
   INT8  *postDecor = NULL;

   if(ast->refName != NULL)
   {
      xmlWrite(indent, "<SchemaType ref=\"%s\">", fixXMLString(ast->refName));
   }
   else
   {
      xmlWrite(indent, "<SchemaType>");
   }

   if(ast->props != NULL)
   {
      xmlWrite(pushIndent(indent), "<Properties>");
      listToXML(ast->props, pushIndent(pushIndent(indent)));
      xmlWrite(pushIndent(indent), "</Properties>");
   }
   else
   {
      xmlWrite(pushIndent(indent), "<Properties/>");
   }

   switch(ast->preDecor)
   {
      case POST_PRI:
      case POST_IN:
      case POST_OUT:
         preDecor = "invalid";
      break;

      case DECOR_NULL:
      break;

      case PRE_DELTA:
         preDecor = "delta";
      break;

      default:
         preDecor = "unknown";
      break;
   }

   switch(ast->postDecor)
   {
      case POST_PRI:
         postDecor = "prime";
      break;

      case POST_IN:
      case POST_OUT:
      case PRE_DELTA:
         postDecor = "invalid";
      break;

      case DECOR_NULL:
      break;

      default:
         postDecor = "unknown";
      break;
   }

   if(ast->specList != NULL)
   {
      xmlWrite(pushIndent(indent), "<GenericSpecifiers>");
      listToXML(ast->specList, pushIndent(pushIndent(indent)));
      xmlWrite(pushIndent(indent), "</GenericSpecifiers>");
   }
   else
   {
      xmlWrite(pushIndent(indent), "<GenericSpecifiers/>");
   }

   if(preDecor != NULL)
   {
      xmlWrite(pushIndent(indent), "<PreDecoration type=\"%s\" degree=\"%d\"/>", preDecor, ast->preCnt);
   }
   else
   {
      xmlWrite(pushIndent(indent), "<PreDecoration/>");
   }

   if(postDecor != NULL)
   {
      xmlWrite(pushIndent(indent), "<PostDecoration type=\"%s\" degree=\"%d\"/>", postDecor, ast->postCnt);
   }
   else
   {
      xmlWrite(pushIndent(indent), "<PostDecoration/>");
   }

   if(ast->decls != NULL)
   {
      xmlWrite(pushIndent(indent), "<Declarations>");
      listToXML(ast->decls, pushIndent(pushIndent(indent)));
      xmlWrite(pushIndent(indent), "</Declarations>");
   }
   else
   {
      xmlWrite(pushIndent(indent), "<Declarations/>");
   }

   if(ast->expDecls != NULL)
   {
      xmlWrite(pushIndent(indent), "<ExpandedDeclarations>");
      listToXML(ast->expDecls, pushIndent(pushIndent(indent)));
      xmlWrite(pushIndent(indent), "</ExpandedDeclarations>");
   }
   else
   {
      xmlWrite(pushIndent(indent), "<ExpandedDeclarations/>");
   }

   if(ast->filters != NULL)
   {
      xmlWrite(pushIndent(indent), "<Predicates>");
      listToXML(ast->filters, pushIndent(pushIndent(indent)));
      xmlWrite(pushIndent(indent), "</Predicates>");
   }
   else
   {
      xmlWrite(pushIndent(indent), "<Predicates/>");
   }

   xmlWrite(pushIndent(indent), "<TypeTree type=\"%s\"/>", getTypeStr(ast->treeType));
   xmlWrite(indent, "</SchemaType>");
}

static void setDispToXML(SetDispNode *ast, UINT16 indent)
{
   xmlWrite(indent, "<SetDisplay>");

   if(ast->props != NULL)
   {
      xmlWrite(pushIndent(indent), "<Properties>");
      listToXML(ast->props, pushIndent(pushIndent(indent)));
      xmlWrite(pushIndent(indent), "</Properties>");
   }
   else
   {
      xmlWrite(pushIndent(indent), "<Properties/>");
   }

   if(ast->exprList != NULL)
   {
      xmlWrite(pushIndent(indent), "<ExpressionList>");
      listToXML(ast->exprList, pushIndent(pushIndent(indent)));
      xmlWrite(pushIndent(indent), "</ExpressionList>");
   }
   else
   {
      xmlWrite(pushIndent(indent), "<ExpressionList/>");
   }

   xmlWrite(pushIndent(indent), "<TypeTree type=\"%s\"/>", getTypeStr(ast->treeType));
   xmlWrite(indent, "</SetDisplay>");
}

static void seqDispToXML(SeqDispNode *ast, UINT16 indent)
{
   xmlWrite(indent, "<SequenceDisplay>");

   if(ast->props != NULL)
   {
      xmlWrite(pushIndent(indent), "<Properties>");
      listToXML(ast->props, pushIndent(pushIndent(indent)));
      xmlWrite(pushIndent(indent), "</Properties>");
   }
   else
   {
      xmlWrite(pushIndent(indent), "<Properties/>");
   }

   if(ast->exprList != NULL)
   {
      xmlWrite(pushIndent(indent), "<ExpressionList>");
      listToXML(ast->exprList, pushIndent(pushIndent(indent)));
      xmlWrite(pushIndent(indent), "</ExpressionList>");
   }
   else
   {
      xmlWrite(pushIndent(indent), "<ExpressionList/>");
   }

   xmlWrite(pushIndent(indent), "<TypeTree type=\"%s\"/>", getTypeStr(ast->treeType));
   xmlWrite(indent, "</SequenceDisplay>");
}

static void uptoToXML(UptoNode *ast, UINT16 indent)
{
   xmlWrite(indent, "<UpTo>");

   if(ast->props != NULL)
   {
      xmlWrite(pushIndent(indent), "<Properties>");
      listToXML(ast->props, pushIndent(pushIndent(indent)));
      xmlWrite(pushIndent(indent), "</Properties>");
   }
   else
   {
      xmlWrite(pushIndent(indent), "<Properties/>");
   }

   if(ast->startExpr != NULL)
   {
      xmlWrite(pushIndent(indent), "<StartExpression>");
      exprToXML(ast->startExpr, pushIndent(pushIndent(indent)));
      xmlWrite(pushIndent(indent), "</StartExpression>");
   }
   else
   {
      xmlWrite(pushIndent(indent), "<StartExpression/>");
   }

   if(ast->endExpr != NULL)
   {
      xmlWrite(pushIndent(indent), "<EndExpression>");
      exprToXML(ast->endExpr, pushIndent(pushIndent(indent)));
      xmlWrite(pushIndent(indent), "</EndExpression>");
   }
   else
   {
      xmlWrite(pushIndent(indent), "<EndExpression/>");
   }

   xmlWrite(pushIndent(indent), "<TypeTree type=\"%s\"/>", getTypeStr(ast->treeType));
   xmlWrite(indent, "</UpTo>");
}

static void setCompToXML(SetCompNode *ast, UINT16 indent)
{
   xmlWrite(indent, "<SetComprehension>");

   if(ast->props != NULL)
   {
      xmlWrite(pushIndent(indent), "<Properties>");
      listToXML(ast->props, pushIndent(pushIndent(indent)));
      xmlWrite(pushIndent(indent), "</Properties>");
   }
   else
   {
      xmlWrite(pushIndent(indent), "<Properties/>");
   }

   if(ast->decls != NULL)
   {
      xmlWrite(pushIndent(indent), "<Declarations>");
      listToXML(ast->decls, pushIndent(pushIndent(indent)));
      xmlWrite(pushIndent(indent), "</Declarations>");
   }
   else
   {
      xmlWrite(pushIndent(indent), "<Declarations/>");
   }

   if(ast->filters != NULL)
   {
      xmlWrite(pushIndent(indent), "<Predicates>");
      listToXML(ast->filters, pushIndent(pushIndent(indent)));
      xmlWrite(pushIndent(indent), "</Predicates>");
   }
   else
   {
      xmlWrite(pushIndent(indent), "<Predicates/>");
   }

   if(ast->expr != NULL)
   {
      xmlWrite(pushIndent(indent), "<Expression>");
      exprToXML(ast->expr, pushIndent(pushIndent(indent)));
      xmlWrite(pushIndent(indent), "</Expression>");
   }
   else
   {
      xmlWrite(pushIndent(indent), "<Expression/>");
   }

   xmlWrite(pushIndent(indent), "<TypeTree type=\"%s\"/>", getTypeStr(ast->treeType));
   xmlWrite(indent, "</SetComprehension>");
}

static void lambdaToXML(LambdaNode *ast, UINT16 indent)
{
   xmlWrite(indent, "<Lambda>");

   if(ast->props != NULL)
   {
      xmlWrite(pushIndent(indent), "<Properties>");
      listToXML(ast->props, pushIndent(pushIndent(indent)));
      xmlWrite(pushIndent(indent), "</Properties>");
   }
   else
   {
      xmlWrite(pushIndent(indent), "<Properties/>");
   }

   if(ast->decls != NULL)
   {
      xmlWrite(pushIndent(indent), "<Declarations>");
      listToXML(ast->decls, pushIndent(pushIndent(indent)));
      xmlWrite(pushIndent(indent), "</Declarations>");
   }
   else
   {
      xmlWrite(pushIndent(indent), "<Declarations/>");
   }

   if(ast->filters != NULL)
   {
      xmlWrite(pushIndent(indent), "<Predicates>");
      listToXML(ast->filters, pushIndent(pushIndent(indent)));
      xmlWrite(pushIndent(indent), "</Predicates>");
   }
   else
   {
      xmlWrite(pushIndent(indent), "<Predicates/>");
   }

   if(ast->expr != NULL)
   {
      xmlWrite(pushIndent(indent), "<Expression>");
      exprToXML(ast->expr, pushIndent(pushIndent(indent)));
      xmlWrite(pushIndent(indent), "</Expression>");
   }
   else
   {
      xmlWrite(pushIndent(indent), "<Expression/>");
   }

   xmlWrite(pushIndent(indent), "<TypeTree type=\"%s\"/>", getTypeStr(ast->treeType));
   xmlWrite(indent, "</Lambda>");
}

static void muToXML(MuNode *ast, UINT16 indent)
{
   xmlWrite(indent, "<Mu>");

   if(ast->props != NULL)
   {
      xmlWrite(pushIndent(indent), "<Properties>");
      listToXML(ast->props, pushIndent(pushIndent(indent)));
      xmlWrite(pushIndent(indent), "</Properties>");
   }
   else
   {
      xmlWrite(pushIndent(indent), "<Properties/>");
   }

   if(ast->decls != NULL)
   {
      xmlWrite(pushIndent(indent), "<Declarations>");
      listToXML(ast->decls, pushIndent(pushIndent(indent)));
      xmlWrite(pushIndent(indent), "</Declarations>");
   }
   else
   {
      xmlWrite(pushIndent(indent), "<Declarations/>");
   }

   if(ast->filters != NULL)
   {
      xmlWrite(pushIndent(indent), "<Predicates>");
      listToXML(ast->filters, pushIndent(pushIndent(indent)));
      xmlWrite(pushIndent(indent), "</Predicates>");
   }
   else
   {
      xmlWrite(pushIndent(indent), "<Predicates/>");
   }

   if(ast->expr != NULL)
   {
      xmlWrite(pushIndent(indent), "<Expression>");
      exprToXML(ast->expr, pushIndent(pushIndent(indent)));
      xmlWrite(pushIndent(indent), "</Expression>");
   }
   else
   {
      xmlWrite(pushIndent(indent), "<Expression/>");
   }

   xmlWrite(pushIndent(indent), "<TypeTree type=\"%s\"/>", getTypeStr(ast->treeType));
   xmlWrite(indent, "</Mu>");
}

static void letExprToXML(LetExprNode *ast, UINT16 indent)
{
   xmlWrite(indent, "<LetExpr>");

   if(ast->props != NULL)
   {
      xmlWrite(pushIndent(indent), "<Properties>");
      listToXML(ast->props, pushIndent(pushIndent(indent)));
      xmlWrite(pushIndent(indent), "</Properties>");
   }
   else
   {
      xmlWrite(pushIndent(indent), "<Properties/>");
   }

   if(ast->decls != NULL)
   {
      xmlWrite(pushIndent(indent), "<Declarations>");
      listToXML(ast->decls, pushIndent(pushIndent(indent)));
      xmlWrite(pushIndent(indent), "</Declarations>");
   }
   else
   {
      xmlWrite(pushIndent(indent), "<Declarations/>");
   }

   if(ast->expr != NULL)
   {
      xmlWrite(pushIndent(indent), "<Expression>");
      exprToXML(ast->expr, pushIndent(pushIndent(indent)));
      xmlWrite(pushIndent(indent), "</Expression>");
   }
   else
   {
      xmlWrite(pushIndent(indent), "<Expression/>");
   }

   xmlWrite(pushIndent(indent), "<TypeTree type=\"%s\"/>", getTypeStr(ast->treeType));
   xmlWrite(indent, "</LetExpr>");
}

static void exprToXML(SyntaxTree *ast, UINT16 indent)
{
   if(ast == NULL)
   {
      return;
   }

   switch(ast->nodeType)
   {
      case NODE_EXPR_OP:
         exprOpToXML((ExprOpNode *) ast, indent);
      break;

      case NODE_EXPR_FUNC:
         exprFuncToXML((ExprFuncNode *) ast, indent);
      break;

      case NODE_VAR:
         variableToXML((VariableNode *) ast, indent);
      break;

      case NODE_EXPR_LITERAL:
         exprLiteralToXML((ExprLiteralNode *) ast, indent);
      break;

      case NODE_EXPR_IDENT:
         exprIdentToXML((ExprIdentNode *) ast, indent);
      break;

      case NODE_EXPR_GEN_IDENT:
         genIdentToXML((ExprGenIdentNode *) ast, indent);
      break;

      case NODE_EXPR_IF:
         exprIfToXML((CondExprNode *) ast, indent);
      break;

      case NODE_TUPLE:
         tupleToXML((TupleNode *) ast, indent);
      break;

      case NODE_CROSS:
         crossToXML((CrossNode *) ast, indent);
      break;

      case NODE_SCH_BIND:
         bindToXML((SchemaBindNode *) ast, indent);
      break;

      case NODE_BIND_ENTRY:
         bindEntryToXML((BindEntryNode *) ast, indent);
      break;

      case NODE_SELECT:
         selectToXML((SelectNode *) ast, indent);
      break;

      case NODE_SCH_TYPE:
         schTypeToXML((SchemaTypeNode *) ast, indent);
      break;

      case NODE_SET_DISP:
         setDispToXML((SetDispNode *) ast, indent);
      break;

      case NODE_SEQ_DISP:
         seqDispToXML((SeqDispNode *) ast, indent);
      break;

      case NODE_UPTO:
         uptoToXML((UptoNode *) ast, indent);
      break;

      case NODE_SET_COMP:
         setCompToXML((SetCompNode *) ast, indent);
      break;

      case NODE_LAMBDA:
         lambdaToXML((LambdaNode *) ast, indent);
      break;

      case NODE_MU:
         muToXML((MuNode *) ast, indent);
      break;

      case NODE_LET_EXPR:
         letExprToXML((LetExprNode *) ast, indent);
      break;

      case NODE_PROC_IF:
         return procIfToXML((CondProcNode *) ast, indent);
      break;

      case NODE_CHAN_APPL:
         return chanApplToXML((ChanApplNode *) ast, indent);
      break;

      case NODE_REPL_PROC:
         return replProcToXML((ReplProcNode *) ast, indent);
      break;

      case NODE_LET_PROC:
         letProcToXML((LetProcNode *) ast, indent);
      break;

      default:
         unknownToXML(ast, indent);
      break;
   }
}

static void predOpToXML(PredOpNode *ast, UINT16 indent)
{
   xmlWrite(indent, "<PredicateOperator name=\"%s\">", fixXMLString(ast->opName));

   if(ast->left != NULL)
   {
      xmlWrite(pushIndent(indent), "<Left>");
      predTypeToXML(ast->left, pushIndent(pushIndent(indent)));
      xmlWrite(pushIndent(indent), "</Left>");
   }
   else
   {
      xmlWrite(pushIndent(indent), "<Left/>");
   }

   if(ast->right != NULL)
   {
      xmlWrite(pushIndent(indent), "<Right>");
      predTypeToXML(ast->right, pushIndent(pushIndent(indent)));
      xmlWrite(pushIndent(indent), "</Right>");
   }
   else
   {
      xmlWrite(pushIndent(indent), "<Right/>");
   }

   xmlWrite(indent, "</PredicateOperator>");
}

static void predRelToXML(PredRelNode *ast, UINT16 indent)
{
   xmlWrite(indent, "<RelationalOperator name=\"%s\">", fixXMLString(ast->opName));

   if(ast->left != NULL)
   {
      xmlWrite(pushIndent(indent), "<Left>");
      exprToXML(ast->left, pushIndent(pushIndent(indent)));
      xmlWrite(pushIndent(indent), "</Left>");
   }
   else
   {
      xmlWrite(pushIndent(indent), "<Left/>");
   }

   if(ast->right != NULL)
   {
      xmlWrite(pushIndent(indent), "<Right>");
      exprToXML(ast->right, pushIndent(pushIndent(indent)));
      xmlWrite(pushIndent(indent), "</Right>");
   }
   else
   {
      xmlWrite(pushIndent(indent), "<Right/>");
   }

   xmlWrite(indent, "</RelationalOperator>");
}

static void predFuncToXML(PredFuncNode *ast, UINT16 indent)
{
   xmlWrite(indent, "<PredicateFunction name=\"%s\">", fixXMLString(ast->funcName));

   if(ast->params != NULL)
   {
      xmlWrite(pushIndent(indent), "<Parameters>");
      exprToXML(ast->params, pushIndent(pushIndent(indent)));
      xmlWrite(pushIndent(indent), "</Parameters>");
   }
   else
   {
      xmlWrite(pushIndent(indent), "<Parameters/>");
   }

   xmlWrite(indent, "</PredicateFunction>");
}

static void predLiteralToXML(PredLiteralNode *ast, UINT16 indent)
{
   xmlWrite(indent, "<PredicateLiteral value=\"%s\"/>", fixXMLString(ast->value));
}

static void predQuantToXML(PredQuantNode *ast, UINT16 indent)
{
   xmlWrite(indent, "<Quantifier type=\"%s\">", fixXMLString(ast->quantName));

   if(ast->decls != NULL)
   {
      xmlWrite(pushIndent(indent), "<Declarations>");
      listToXML(ast->decls, pushIndent(pushIndent(indent)));
      xmlWrite(pushIndent(indent), "</Declarations>");
   }
   else
   {
      xmlWrite(pushIndent(indent), "<Declarations/>");
   }

   if(ast->filters != NULL)
   {
      xmlWrite(pushIndent(indent), "<Filters>");
      listToXML(ast->filters, pushIndent(pushIndent(indent)));
      xmlWrite(pushIndent(indent), "</Filters>");
   }
   else
   {
      xmlWrite(pushIndent(indent), "<Filters/>");
   }

   if(ast->preds != NULL)
   {
      xmlWrite(pushIndent(indent), "<Predicates>");
      listToXML(ast->preds, pushIndent(pushIndent(indent)));
      xmlWrite(pushIndent(indent), "</Predicates>");
   }
   else
   {
      xmlWrite(pushIndent(indent), "<Predicates/>");
   }

   xmlWrite(indent, "</Quantifier>");
}

static void letPredToXML(LetPredNode *ast, UINT16 indent)
{
   xmlWrite(indent, "<LetPred>");

   if(ast->decls != NULL)
   {
      xmlWrite(pushIndent(indent), "<Declarations>");
      listToXML(ast->decls, pushIndent(pushIndent(indent)));
      xmlWrite(pushIndent(indent), "</Declarations>");
   }
   else
   {
      xmlWrite(pushIndent(indent), "<Declarations/>");
   }

   if(ast->preds != NULL)
   {
      xmlWrite(pushIndent(indent), "<Predicates>");
      listToXML(ast->preds, pushIndent(pushIndent(indent)));
      xmlWrite(pushIndent(indent), "</Predicates>");
   }
   else
   {
      xmlWrite(pushIndent(indent), "<Predicates/>");
   }

   xmlWrite(indent, "</LetPred>");
}

static void schemaAppToXML(SchemaAppNode *ast, UINT16 indent)
{
   xmlWrite(indent, "<SchemaApplication>");

   if(ast->preCond != NULL)
   {
      xmlWrite(pushIndent(indent), "<PreCondition>");
      exprToXML(ast->preCond, pushIndent(pushIndent(indent)));
      xmlWrite(pushIndent(indent), "</PreCondition>");
   }
   else
   {
      xmlWrite(pushIndent(indent), "<PreCondition/>");
   }

   if(ast->command != NULL)
   {
      xmlWrite(pushIndent(indent), "<Command>");
      exprToXML(ast->command, pushIndent(pushIndent(indent)));
      xmlWrite(pushIndent(indent), "</Command>");
   }
   else
   {
      xmlWrite(pushIndent(indent), "<Command/>");
   }

   if(ast->postCond != NULL)
   {
      xmlWrite(pushIndent(indent), "<PostCondition>");
      exprToXML(ast->postCond, pushIndent(pushIndent(indent)));
      xmlWrite(pushIndent(indent), "</PostCondition>");
   }
   else
   {
      xmlWrite(pushIndent(indent), "<PostCondition/>");
   }

   xmlWrite(pushIndent(indent), "<StrictFlag>");
   xmlWrite(pushIndent(pushIndent(indent)), "%d", ast->strictFlag);
   xmlWrite(pushIndent(indent), "</StrictFlag>");

   xmlWrite(indent, "</SchemaApplication>");
}

static void predIfToXML(CondPredNode *ast, UINT16 indent)
{
   xmlWrite(indent, "<ConditionalPredicate>");

   if(ast->condList != NULL)
   {
      xmlWrite(pushIndent(indent), "<Conditionals>");
      listToXML(ast->condList, pushIndent(pushIndent(indent)));
      xmlWrite(pushIndent(indent), "</Conditionals>");
   }
   else
   {
      xmlWrite(pushIndent(indent), "<Conditionals/>");
   }

   if(ast->thenList != NULL)
   {
      xmlWrite(pushIndent(indent), "<ThenPredicates>");
      listToXML(ast->thenList, pushIndent(pushIndent(indent)));
      xmlWrite(pushIndent(indent), "</ThenPredicates>");
   }
   else
   {
      xmlWrite(pushIndent(indent), "<ThenPredicates/>");
   }

   if(ast->elseList != NULL)
   {
      xmlWrite(pushIndent(indent), "<ElsePredicates>");
      listToXML(ast->elseList, pushIndent(pushIndent(indent)));
      xmlWrite(pushIndent(indent), "</ElsePredicates>");
   }
   else
   {
      xmlWrite(pushIndent(indent), "<ElseExpression/>");
   }

   xmlWrite(indent, "</ConditionalPredicate>");
}

static void predTypeToXML(SyntaxTree *ast, UINT16 indent)
{
   if(ast == NULL)
   {
      return;
   }

   switch(ast->nodeType)
   {
      case NODE_PRED_OP:
         predOpToXML((PredOpNode *) ast, indent);
      break;

      case NODE_PRED_REL:
         predRelToXML((PredRelNode *) ast, indent);
      break;

      case NODE_PRED_FUNC:
         predFuncToXML((PredFuncNode *) ast, indent);
      break;

      case NODE_PRED_LITERAL:
         predLiteralToXML((PredLiteralNode *) ast, indent);
      break;

      case NODE_PRED_QUANT:
         predQuantToXML((PredQuantNode *) ast, indent);
      break;

      case NODE_LET_PRED:
         letPredToXML((LetPredNode *) ast, indent);
      break;

      case NODE_SCHEMA_APP:
         schemaAppToXML((SchemaAppNode *) ast, indent);
      break;

      case NODE_PRED_IF:
         predIfToXML((CondPredNode *) ast, indent);
      break;

      default:
         unknownToXML(ast, indent);
      break;
   }
}

static void predToXML(PredicateNode *ast, UINT16 indent)
{
   xmlWrite(indent, "<Predicate>");

   if(ast->props != NULL)
   {
      xmlWrite(pushIndent(indent), "<Properties>");
      listToXML(ast->props, pushIndent(pushIndent(indent)));
      xmlWrite(pushIndent(indent), "</Properties>");
   }
   else
   {
      xmlWrite(pushIndent(indent), "<Properties/>");
   }

   if(ast->predNode != NULL)
   {
      xmlWrite(pushIndent(indent), "<PredicateType>");
      predTypeToXML(ast->predNode, pushIndent(pushIndent(indent)));
      xmlWrite(pushIndent(indent), "</PredicateType>");
   }
   else
   {
      xmlWrite(pushIndent(indent), "<PredicateType/>");
   }

   xmlWrite(indent, "</Predicate>");
}

static void procToXML(ProcessNode *ast, UINT16 indent)
{
   if(!exportCheck(getLayer(ast->props)))
   {
      return;
   }

   xmlWrite(indent, "<Process name=\"%s\">", fixXMLString(ast->name));

   if(ast->props != NULL)
   {
      xmlWrite(pushIndent(indent), "<Properties>");
      listToXML(ast->props, pushIndent(pushIndent(indent)));
      xmlWrite(pushIndent(indent), "</Properties>");
   }
   else
   {
      xmlWrite(pushIndent(indent), "<Properties/>");
   }

   if(ast->decls != NULL)
   {
      xmlWrite(pushIndent(indent), "<Declarations>");
      listToXML(ast->decls, pushIndent(pushIndent(indent)));
      xmlWrite(pushIndent(indent), "</Declarations>");
   }
   else
   {
      xmlWrite(pushIndent(indent), "<Declarations/>");
   }

   if(ast->procs != NULL)
   {
      xmlWrite(pushIndent(indent), "<Processes>");
      listToXML(ast->procs, pushIndent(pushIndent(indent)));
      xmlWrite(pushIndent(indent), "</Processes>");
   }
   else
   {
      xmlWrite(pushIndent(indent), "<Processes/>");
   }

   xmlWrite(indent, "</Process>");
}

static void procDefToXML(ProcDefNode *ast, UINT16 indent)
{
   xmlWrite(indent, "<ProcDef name=\"%s\">", fixXMLString(ast->procName));

   if(ast->props != NULL)
   {
      xmlWrite(pushIndent(indent), "<Properties>");
      listToXML(ast->props, pushIndent(pushIndent(indent)));
      xmlWrite(pushIndent(indent), "</Properties>");
   }
   else
   {
      xmlWrite(pushIndent(indent), "<Properties/>");
   }

   if(ast->decls != NULL)
   {
      xmlWrite(pushIndent(indent), "<Declarations>");
      listToXML(ast->decls, pushIndent(pushIndent(indent)));
      xmlWrite(pushIndent(indent), "</Declarations>");
   }
   else
   {
      xmlWrite(pushIndent(indent), "<Declarations/>");
   }

   if(ast->defExpr != NULL)
   {
      xmlWrite(pushIndent(indent), "<DefiningExpression>");
      exprToXML(ast->defExpr, pushIndent(indent));
      xmlWrite(pushIndent(indent), "</DefiningExpression>");
   }
   else
   {
      xmlWrite(pushIndent(indent), "<DefiningExpression/>");
   }

   xmlWrite(pushIndent(indent), "<TypeTree type=\"%s\"/>", getTypeStr(ast->treeType));
   xmlWrite(indent, "</ProcDef>");
}

static void genProcDefToXML(GenProcDefNode *ast, UINT16 indent)
{
   INT8  *syms = strListToString(ast->syms, ", ");

   if(syms != NULL)
   {
      INT8  *symFixed = strdup(fixXMLString(syms));

      xmlWrite(indent, "<GenProcDef name=\"%s\" syms=\"%s\">", fixXMLString(ast->procName), symFixed);

      free(symFixed);
      free(syms);
   }
   else
   {
      xmlWrite(indent, "<GenProcDef name=\"%s\" syms=\"\">", fixXMLString(ast->procName));
   }

   if(ast->props != NULL)
   {
      xmlWrite(pushIndent(indent), "<Properties>");
      listToXML(ast->props, pushIndent(pushIndent(indent)));
      xmlWrite(pushIndent(indent), "</Properties>");
   }
   else
   {
      xmlWrite(pushIndent(indent), "<Properties/>");
   }

   if(ast->decls != NULL)
   {
      xmlWrite(pushIndent(indent), "<Declarations>");
      listToXML(ast->decls, pushIndent(pushIndent(indent)));
      xmlWrite(pushIndent(indent), "</Declarations>");
   }
   else
   {
      xmlWrite(pushIndent(indent), "<Declarations/>");
   }

   if(ast->defExpr != NULL)
   {
      xmlWrite(pushIndent(indent), "<DefiningExpression>");
      exprToXML(ast->defExpr, pushIndent(indent));
      xmlWrite(pushIndent(indent), "</DefiningExpression>");
   }
   else
   {
      xmlWrite(pushIndent(indent), "<DefiningExpression/>");
   }

   xmlWrite(pushIndent(indent), "<TypeTree type=\"%s\"/>", getTypeStr(ast->treeType));
   xmlWrite(indent, "</GenProcDef>");
}

static void chanApplToXML(ChanApplNode *ast, UINT16 indent)
{
   xmlWrite(indent, "<ChannelApplication>");

   if(ast->props != NULL)
   {
      xmlWrite(pushIndent(indent), "<Properties>");
      listToXML(ast->props, pushIndent(pushIndent(indent)));
      xmlWrite(pushIndent(indent), "</Properties>");
   }
   else
   {
      xmlWrite(pushIndent(indent), "<Properties/>");
   }

   if(ast->chanExpr != NULL)
   {
      xmlWrite(pushIndent(indent), "<Channel>");
      exprToXML(ast->chanExpr, pushIndent(pushIndent(indent)));
      xmlWrite(pushIndent(indent), "</Channel>");
   }
   else
   {
      xmlWrite(pushIndent(indent), "<Channel/>");
   }

   if(ast->fields != NULL)
   {
      xmlWrite(pushIndent(indent), "<Fields>");
      listToXML(ast->fields, pushIndent(pushIndent(indent)));
      xmlWrite(pushIndent(indent), "</Fields>");
   }
   else
   {
      xmlWrite(pushIndent(indent), "<Fields/>");
   }

   xmlWrite(pushIndent(indent), "<TypeTree type=\"%s\"/>", getTypeStr(ast->treeType));
   xmlWrite(indent, "</ChannelApplication>");
}

static void chanFieldToXML(ChanFieldNode *ast, UINT16 indent)
{
   xmlWrite(indent, "<ChannelField>");

   if(ast->props != NULL)
   {
      xmlWrite(pushIndent(indent), "<Properties>");
      listToXML(ast->props, pushIndent(pushIndent(indent)));
      xmlWrite(pushIndent(indent), "</Properties>");
   }
   else
   {
      xmlWrite(pushIndent(indent), "<Properties/>");
   }

   if(ast->fieldType == INPUT_FIELD)
   {
      xmlWrite(pushIndent(indent), "<FieldType type=\"Input\"/>");
   }
   else if(ast->fieldType == OUTPUT_FIELD)
   {
      xmlWrite(pushIndent(indent), "<FieldType type=\"Output\"/>");
   }
   else if(ast->fieldType == DOT_FIELD)
   {
      xmlWrite(pushIndent(indent), "<FieldType type=\"Standard\"/>");
   }
   else
   {
      xmlWrite(pushIndent(indent), "<FieldType type=\"Unknown\"/>");
   }

   if(ast->fieldExpr != NULL)
   {
      xmlWrite(pushIndent(indent), "<FieldExpr>");
      exprToXML(ast->fieldExpr, pushIndent(pushIndent(indent)));
      xmlWrite(pushIndent(indent), "</FieldExpr>");
   }
   else
   {
      xmlWrite(pushIndent(indent), "<FieldExpr/>");
   }

   xmlWrite(pushIndent(indent), "<TypeTree type=\"%s\"/>", getTypeStr(ast->treeType));
   xmlWrite(indent, "</ChannelField>");
}

static void replProcToXML(ReplProcNode *ast, UINT16 indent)
{
   xmlWrite(indent, "<ReplicatedProcess>");

   if(ast->props != NULL)
   {
      xmlWrite(pushIndent(indent), "<Properties>");
      listToXML(ast->props, pushIndent(pushIndent(indent)));
      xmlWrite(pushIndent(indent), "</Properties>");
   }
   else
   {
      xmlWrite(pushIndent(indent), "<Properties/>");
   }

   if(ast->replType == INTERNAL)
   {
      xmlWrite(pushIndent(indent), "<ReplType type=\"Internal\"/>");
   }
   else if(ast->replType == EXTERNAL)
   {
      xmlWrite(pushIndent(indent), "<ReplType type=\"External\"/>");
   }
   else if(ast->replType == PARALLEL)
   {
      xmlWrite(pushIndent(indent), "<ReplType type=\"Parallel\"/>");
   }
   else if(ast->replType == INTERLEAVE)
   {
      xmlWrite(pushIndent(indent), "<ReplType type=\"Interleave\"/>");
   }
   else if(ast->replType == IF_PARALLEL)
   {
      xmlWrite(pushIndent(indent), "<ReplType type=\"InterfaceParallel\"/>");
   }
   else
   {
      xmlWrite(pushIndent(indent), "<ReplType type=\"Unknown\"/>");
   }

   if(ast->ifAlph != NULL)
   {
      xmlWrite(pushIndent(indent), "<Interface>");
      exprToXML(ast->ifAlph, pushIndent(pushIndent(indent)));
      xmlWrite(pushIndent(indent), "</Interface>");
   }
   else
   {
      xmlWrite(pushIndent(indent), "<Interface/>");
   }

   if(ast->decls != NULL)
   {
      xmlWrite(pushIndent(indent), "<Declarations>");
      listToXML(ast->decls, pushIndent(pushIndent(indent)));
      xmlWrite(pushIndent(indent), "</Declarations>");
   }
   else
   {
      xmlWrite(pushIndent(indent), "<Declarations/>");
   }

   if(ast->filters != NULL)
   {
      xmlWrite(pushIndent(indent), "<Predicates>");
      listToXML(ast->filters, pushIndent(pushIndent(indent)));
      xmlWrite(pushIndent(indent), "</Predicates>");
   }
   else
   {
      xmlWrite(pushIndent(indent), "<Predicates/>");
   }

   if(ast->expr != NULL)
   {
      xmlWrite(pushIndent(indent), "<Expression>");
      exprToXML(ast->expr, pushIndent(pushIndent(indent)));
      xmlWrite(pushIndent(indent), "</Expression>");
   }
   else
   {
      xmlWrite(pushIndent(indent), "<Expression/>");
   }

   xmlWrite(pushIndent(indent), "<TypeTree type=\"%s\"/>", getTypeStr(ast->treeType));
   xmlWrite(indent, "</ReplicatedProcess>");
}

static void letProcToXML(LetProcNode *ast, UINT16 indent)
{
   xmlWrite(indent, "<LetProc>");

   if(ast->props != NULL)
   {
      xmlWrite(pushIndent(indent), "<Properties>");
      listToXML(ast->props, pushIndent(pushIndent(indent)));
      xmlWrite(pushIndent(indent), "</Properties>");
   }
   else
   {
      xmlWrite(pushIndent(indent), "<Properties/>");
   }

   if(ast->decls != NULL)
   {
      xmlWrite(pushIndent(indent), "<Declarations>");
      listToXML(ast->decls, pushIndent(pushIndent(indent)));
      xmlWrite(pushIndent(indent), "</Declarations>");
   }
   else
   {
      xmlWrite(pushIndent(indent), "<Declarations/>");
   }

   if(ast->expr != NULL)
   {
      xmlWrite(pushIndent(indent), "<Expression>");
      exprToXML(ast->expr, pushIndent(pushIndent(indent)));
      xmlWrite(pushIndent(indent), "</Expression>");
   }
   else
   {
      xmlWrite(pushIndent(indent), "<Expression/>");
   }

   xmlWrite(pushIndent(indent), "<TypeTree type=\"%s\"/>", getTypeStr(ast->treeType));
   xmlWrite(indent, "</LetProc>");
}

static void procIfToXML(CondProcNode *ast, UINT16 indent)
{
   xmlWrite(indent, "<ConditionalProcess>");

   if(ast->props != NULL)
   {
      xmlWrite(pushIndent(indent), "<Properties>");
      listToXML(ast->props, pushIndent(pushIndent(indent)));
      xmlWrite(pushIndent(indent), "</Properties>");
   }
   else
   {
      xmlWrite(pushIndent(indent), "<Properties/>");
   }

   if(ast->condList != NULL)
   {
      xmlWrite(pushIndent(indent), "<Conditionals>");
      listToXML(ast->condList, pushIndent(pushIndent(indent)));
      xmlWrite(pushIndent(indent), "</Conditionals>");
   }
   else
   {
      xmlWrite(pushIndent(indent), "<Conditionals/>");
   }

   if(ast->thenProc != NULL)
   {
      xmlWrite(pushIndent(indent), "<ThenProcess>");
      exprToXML(ast->thenProc, pushIndent(pushIndent(indent)));
      xmlWrite(pushIndent(indent), "</ThenProcess>");
   }
   else
   {
      xmlWrite(pushIndent(indent), "<ThenProcess/>");
   }

   if(ast->elseProc != NULL)
   {
      xmlWrite(pushIndent(indent), "<ElseProcess>");
      exprToXML(ast->elseProc, pushIndent(pushIndent(indent)));
      xmlWrite(pushIndent(indent), "</ElseProcess>");
   }
   else
   {
      xmlWrite(pushIndent(indent), "<ElseProcess/>");
   }

   xmlWrite(pushIndent(indent), "<TypeTree type=\"%s\"/>", getTypeStr(ast->treeType));
   xmlWrite(indent, "</ConditionalProcess>");
}

static void declToXML(DeclarationNode *ast, UINT16 indent)
{
   INT8   *typeStr = NULL;
   INT8   *syms    = NULL;

   if(ast->declType == SCH_REF_DECL)
   {
      typeStr = "schref";
   }
   else if(ast->declType == VAR_DECL)
   {
      typeStr = "var";
   }
   else if(ast->declType == PRED_FUNC_DECL)
   {
      typeStr = "bool";
   }
   else if(ast->declType == EXPR_FUNC_DECL)
   {
      typeStr = "func";
   }
   else if(ast->declType == REL_OP_PRE_DECL)
   {
      typeStr = "prerel";
   }
   else if(ast->declType == REL_OP_POST_DECL)
   {
      typeStr = "postrel";
   }
   else if(ast->declType == REL_OP_IN_DECL)
   {
      typeStr = "binrel";
   }
   else if(ast->declType == EXPR_OP_PRE_DECL)
   {
      typeStr = "preop";
   }
   else if(ast->declType == EXPR_OP_POST_DECL)
   {
      typeStr = "postop";
   }
   else if(ast->declType == EXPR_OP_IN_DECL)
   {
      typeStr = "binop";
   }
   else if(ast->declType == PROC_DECL)
   {
      typeStr = "proc";
   }
   else if(ast->declType == PROC_FUNC_DECL)
   {
      typeStr = "procfunc";
   }
   else if(ast->declType == EVENT_DECL)
   {
      typeStr = "event";
   }
   else if(ast->declType == CHAN_DECL)
   {
      typeStr = "channel";
   }

   if(ast->genSyms != NULL)
   {
      syms = strListToString(ast->genSyms, ", ");
   }

   if(syms != NULL)
   {
      INT8  *symFixed = strdup(fixXMLString(syms));

      xmlWrite(indent, "<Declaration type=\"%s\" syms=\"%s\">", typeStr, symFixed);

      free(symFixed);
      free(syms);
   }
   else
   {
      xmlWrite(indent, "<Declaration type=\"%s\" syms=\"\">", typeStr);
   }

   if(ast->props != NULL)
   {
      xmlWrite(pushIndent(indent), "<Properties>");
      listToXML(ast->props, pushIndent(pushIndent(indent)));
      xmlWrite(pushIndent(indent), "</Properties>");
   }
   else
   {
      xmlWrite(pushIndent(indent), "<Properties/>");
   }

   if((ast->declType == VAR_DECL) || (ast->declType == PROC_DECL) || (ast->declType == EVENT_DECL))
   {
      if(ast->ident != NULL)
      {
         xmlWrite(pushIndent(indent), "<DeclarationIdentifier>");
         variableToXML((VariableNode *) ast->ident, pushIndent(pushIndent(indent)));
         xmlWrite(pushIndent(indent), "</DeclarationIdentifier>");
      }
      else
      {
         xmlWrite(pushIndent(indent), "<DeclarationIdentifier/>");
      }
   }
   else if(ast->declType == SCH_REF_DECL)
   {
      xmlWrite(pushIndent(indent), "<DeclarationIdentifier/>");
   }
   else
   {
      xmlWrite(pushIndent(indent), "<DeclarationIdentifier name=\"%s\"/>", fixXMLString((INT8 *) ast->ident));
   }

   if(ast->defExpr != NULL)
   {
      xmlWrite(pushIndent(indent), "<DeclarationExpression>");
      exprToXML(ast->defExpr, pushIndent(pushIndent(indent)));
      xmlWrite(pushIndent(indent), "</DeclarationExpression>");
   }
   else
   {
      xmlWrite(pushIndent(indent), "<DeclarationExpression/>");
   }

   xmlWrite(pushIndent(indent), "<TypeTree type=\"%s\"/>", getTypeStr(ast->treeType));

   xmlWrite(indent, "</Declaration>");
}

static void procAliasToXML(ProcAliasNode *ast, UINT16 indent)
{
   xmlWrite(indent, "<ProcAlias name=\"%s\">", fixXMLString(ast->name));

   if(ast->props != NULL)
   {
      xmlWrite(pushIndent(indent), "<Properties>");
      listToXML(ast->props, pushIndent(pushIndent(indent)));
      xmlWrite(pushIndent(indent), "</Properties>");
   }
   else
   {
      xmlWrite(pushIndent(indent), "<Properties/>");
   }

   if(ast->defExpr != NULL)
   {
      xmlWrite(pushIndent(indent), "<DefiningExpression>");
      exprToXML(ast->defExpr, pushIndent(indent));
      xmlWrite(pushIndent(indent), "</DefiningExpression>");
   }
   else
   {
      xmlWrite(pushIndent(indent), "<DefiningExpression/>");
   }

   xmlWrite(pushIndent(indent), "<TypeTree type=\"%s\"/>", getTypeStr(ast->treeType));
   xmlWrite(indent, "</ProcAlias>");
}

static void chanAliasToXML(ChanAliasNode *ast, UINT16 indent)
{
   xmlWrite(indent, "<ChanAlias name=\"%s\">", fixXMLString(ast->name));

   if(ast->props != NULL)
   {
      xmlWrite(pushIndent(indent), "<Properties>");
      listToXML(ast->props, pushIndent(pushIndent(indent)));
      xmlWrite(pushIndent(indent), "</Properties>");
   }
   else
   {
      xmlWrite(pushIndent(indent), "<Properties/>");
   }

   if(ast->defExpr != NULL)
   {
      xmlWrite(pushIndent(indent), "<DefiningExpression>");
      exprToXML(ast->defExpr, pushIndent(indent));
      xmlWrite(pushIndent(indent), "</DefiningExpression>");
   }
   else
   {
      xmlWrite(pushIndent(indent), "<DefiningExpression/>");
   }

   xmlWrite(pushIndent(indent), "<TypeTree type=\"%s\"/>", getTypeStr(ast->treeType));
   xmlWrite(indent, "</ChanAlias>");
}

static void listToXML(LinkList *nodeList, UINT16 indent)
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
            case NODE_DOC_INFO:
               docInfoToXML((DocInfoNode *) ast, indent);
            break;

            case NODE_INFO_ENTRY:
               infoEntryToXML((InfoEntryNode *) ast, indent);
            break;

            case NODE_PROP_ENTRY:
               propertyToXML((PropertyNode *) ast, indent);
            break;

            case NODE_DIREC:
               directiveToXML((DirectiveNode *) ast, indent);
            break;

            case NODE_DESC:
               descriptionToXML((DescriptionNode *) ast, indent);
            break;

            case NODE_BASIC:
               basicToXML((BasicDefNode *) ast, indent);
            break;

            case NODE_BASIC_ENTRY:
               basicEntryToXML((BasicEntryNode *) ast, indent);
            break;

            case NODE_TYPE_DEF:
               typeDefToXML((TypeDefNode *) ast, indent);
            break;

            case NODE_TYPE_ENTRY:
               typeEntryToXML((TypeEntryNode *) ast, indent);
            break;

            case NODE_FREE_TYPE:
               freeToXML((FreeTypeNode *) ast, indent);
            break;

            case NODE_FREE_ENTRY:
               freeEntryToXML((FreeEntryNode *) ast, indent);
            break;

            case NODE_AXDEF:
               axDefToXML((AxDefNode *) ast, indent);
            break;

            case NODE_GENDEF:
               genDefToXML((GenDefNode *) ast, indent);
            break;

            case NODE_SCHEMA:
               schemaToXML((SchemaNode *) ast, indent);
            break;

            case NODE_GEN_SCH:
               genSchemaToXML((GenSchemaNode *) ast, indent);
            break;

            case NODE_CONST:
               constToXML((ConstraintNode *) ast, indent);
            break;

            case NODE_PROCESS:
               procToXML((ProcessNode *) ast, indent);
            break;

            case NODE_DECL:
               declToXML((DeclarationNode *) ast, indent);
            break;

            case NODE_PROC_ALIAS:
               procAliasToXML((ProcAliasNode *) ast, indent);
            break;

            case NODE_CHAN_ALIAS:
               chanAliasToXML((ChanAliasNode *) ast, indent);
            break;

            case NODE_PRED:
               predToXML((PredicateNode *) ast, indent);
            break;

            case NODE_PROC_DEF:
               procDefToXML((ProcDefNode *) ast, indent);
            break;

            case NODE_GEN_PROC_DEF:
               genProcDefToXML((GenProcDefNode *) ast, indent);
            break;

            case NODE_CHAN_FIELD:
               chanFieldToXML((ChanFieldNode *) ast, indent);
            break;

            case NODE_PRED_OP:
            case NODE_PRED_REL:
            case NODE_PRED_FUNC:
            case NODE_PRED_LITERAL:
            case NODE_PRED_QUANT:
            case NODE_LET_PRED:
            case NODE_PRED_IF:
               predTypeToXML(ast, indent);
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
               exprToXML(ast, indent);
            break;

            default:
               unknownToXML(ast, indent);
            break;
         }
      }

      current = current->next;
   }
}

void unknownToXML(SyntaxTree *ast, UINT16 indent)
{
   xmlWrite(indent, "<UnknownNode type=\"%d\"/>", ast->nodeType);
}

void aDocToXML(ADocNode *ast, INT8 *outPath)
{
   UINT16  indent = 0;

   DEBUG("outPath = %s\n", outPath);

   outFile = fopen(outPath, "w+");

   if(outFile == NULL)
   {
      yyferror("Unable to open %s for XML export", outPath);
   }

   typeBuff = malloc(1024);
   tmpData  = malloc(1024);
   typeLen  = 1024;
   outLen   = 1024;
   tmpLen   = 1024;

   memset(typeBuff, 0, typeLen);
   memset(tmpData, 0, tmpLen);

   xmlWrite(indent, "<ASpecDocument>");

   if(ast->paragraphs != NULL)
   {
      xmlWrite(pushIndent(indent), "<Paragraphs>");
      listToXML(ast->paragraphs, pushIndent(pushIndent(indent)));
      xmlWrite(pushIndent(indent), "</Paragraphs>");
   }
   else
   {
      xmlWrite(pushIndent(indent), "<Paragraphs/>");
   }

   xmlWrite(indent, "</ASpecDocument>");

   fclose(outFile);
   free(tmpData);
   free(typeBuff);
}
