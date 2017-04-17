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

#include <unistd.h>
#include <string.h>
#include <stdarg.h>
#include <stdlib.h>
#include <stdio.h>
#include <fcntl.h>

#ifdef WIN32
   #include "arch/mingw/a-spec_mingw.h"
#endif

#include "a-translate/a2oztex.h"
#include "a-specc/a-specc_api.h"

#define OZ_XFM_TABLE_SIZE  12
#define OZ_XFM_TAG         "A2TEX_XFM"

#define OZ_DISPLAY_TAG   "display"
#define OZ_NOTE_TAG      "note"

static LinkList  *xfmTable = NULL;

static int  outFile = 0;

static UINT32 tokHash(INT8 *token)
{
   UINT32  hash = 0;
   UINT8   byte = *token;

   while(byte > 0)
   {
      hash  = (hash * 9) ^ byte;
      token = token + 1;
      byte  = *token;
   }

   return hash;
}

static INT8 *normalizeName(INT8 *src)
{
   INT8  *brk = strpbrk(src, "_u0123456789n");
   INT8  *ret = NULL;

   if(brk == NULL)
   {
      return strdup(src);
   }
   else if(brk == src)
   {
      INT8  *post = normalizeName(&(brk[1]));

      if(brk[0] == '_')
      {
         asprintf((char **) &ret, "uu%s", post);
      }
      else if(brk[0] == 'u')
      {
         asprintf((char **) &ret, "uU%s", post);
      }
      else if(brk[0] == 'n')
      {
         asprintf((char **) &ret, "nn%s", post);
      }
      else if(brk[0] == '0')
      {
         asprintf((char **) &ret, "nZero%s", post);
      }
      else if(brk[0] == '1')
      {
         asprintf((char **) &ret, "nOne%s", post);
      }
      else if(brk[0] == '2')
      {
         asprintf((char **) &ret, "nTwo%s", post);
      }
      else if(brk[0] == '3')
      {
         asprintf((char **) &ret, "nThree%s", post);
      }
      else if(brk[0] == '4')
      {
         asprintf((char **) &ret, "nFour%s", post);
      }
      else if(brk[0] == '5')
      {
         asprintf((char **) &ret, "nFive%s", post);
      }
      else if(brk[0] == '6')
      {
         asprintf((char **) &ret, "nSix%s", post);
      }
      else if(brk[0] == '7')
      {
         asprintf((char **) &ret, "nSeven%s", post);
      }
      else if(brk[0] == '8')
      {
         asprintf((char **) &ret, "nEight%s", post);
      }
      else if(brk[0] == '9')
      {
         asprintf((char **) &ret, "nNine%s", post);
      }

      free(post);
   }
   else
   {
      UINT32  preLen = brk - src;
      INT8    *pre   = strndup(src, preLen);
      INT8    *post  = normalizeName(&(brk[1]));

      if(brk[0] == '_')
      {
         asprintf((char **) &ret, "%suu%s", pre, post);
      }
      else if(brk[0] == 'u')
      {
         asprintf((char **) &ret, "%suU%s", pre, post);
      }
      else if(brk[0] == 'n')
      {
         asprintf((char **) &ret, "%snn%s", pre, post);
      }
      else if(brk[0] == '0')
      {
         asprintf((char **) &ret, "%snZero%s", pre, post);
      }
      else if(brk[0] == '1')
      {
         asprintf((char **) &ret, "%snOne%s", pre, post);
      }
      else if(brk[0] == '2')
      {
         asprintf((char **) &ret, "%snTwo%s", pre, post);
      }
      else if(brk[0] == '3')
      {
         asprintf((char **) &ret, "%snThree%s", pre, post);
      }
      else if(brk[0] == '4')
      {
         asprintf((char **) &ret, "%snFour%s", pre, post);
      }
      else if(brk[0] == '5')
      {
         asprintf((char **) &ret, "%snFive%s", pre, post);
      }
      else if(brk[0] == '6')
      {
         asprintf((char **) &ret, "%snSix%s", pre, post);
      }
      else if(brk[0] == '7')
      {
         asprintf((char **) &ret, "%snSeven%s", pre, post);
      }
      else if(brk[0] == '8')
      {
         asprintf((char **) &ret, "%snEight%s", pre, post);
      }
      else if(brk[0] == '9')
      {
         asprintf((char **) &ret, "%snNine%s", pre, post);
      }

      free(pre);
      free(post);
   }

   return ret;
}

static INT8 *texFix(INT8 *src)
{
   INT8  *brk = strpbrk(src, "_$#{}@%& \\");
   INT8  *ret = NULL;

   if(brk == NULL)
   {
      return strdup(src);
   }
   else if(brk == src)
   {
      INT8  *post = texFix(&(brk[1]));

      if(brk[0] == '_')
      {
         asprintf((char **) &ret, "\\_%s", post);
      }
      else if(brk[0] == '$')
      {
         asprintf((char **) &ret, "\\$%s", post);
      }
      else if(brk[0] == '#')
      {
         asprintf((char **) &ret, "\\#%s", post);
      }
      else if(brk[0] == '{')
      {
         asprintf((char **) &ret, "\\{%s", post);
      }
      else if(brk[0] == '@')
      {
         asprintf((char **) &ret, "$@$%s", post);
      }
      else if(brk[0] == '%')
      {
         asprintf((char **) &ret, "\\%%%s", post);
      }
      else if(brk[0] == '&')
      {
         asprintf((char **) &ret, "\\&%s", post);
      }
      else if(brk[0] == ' ')
      {
         asprintf((char **) &ret, "\\ %s", post);
      }
      else if(brk[0] == '\\')
      {
         asprintf((char **) &ret, "\\textbackslash %s", post);
      }

      free(post);
   }
   else
   {
      UINT32  preLen = brk - src;
      INT8    *pre   = strndup(src, preLen);
      INT8    *post  = texFix(&(brk[1]));

      if(brk[0] == '_')
      {
         asprintf((char **) &ret, "%s\\_%s", pre, post);
      }
      else if(brk[0] == '$')
      {
         asprintf((char **) &ret, "%s\\$%s", pre, post);
      }
      else if(brk[0] == '#')
      {
         asprintf((char **) &ret, "%s\\#%s", pre, post);
      }
      else if(brk[0] == '{')
      {
         asprintf((char **) &ret, "%s\\{%s", pre, post);
      }
      else if(brk[0] == '}')
      {
         asprintf((char **) &ret, "%s\\}%s", pre, post);
      }
      else if(brk[0] == '@')
      {
         asprintf((char **) &ret, "%s$@$%s", pre, post);
      }
      else if(brk[0] == '%')
      {
         asprintf((char **) &ret, "%s\\%%%s", pre, post);
      }
      else if(brk[0] == '&')
      {
         asprintf((char **) &ret, "%s\\&%s", pre, post);
      }
      else if(brk[0] == ' ')
      {
         asprintf((char **) &ret, "%s\\ %s", pre, post);
      }
      else if(brk[0] == '\\')
      {
         asprintf((char **) &ret, "%s\\textbackslash %s", pre, post);
      }

      free(pre);
      free(post);
   }

   return ret;
}

static INT8 *charQFix(INT8 *src)
{
   INT8  *brk = strstr(src, "``");
   INT8  *ret = NULL;

   DEBUG("charQFix(%s): Called . . .\n", src);

   if(brk == NULL)
   {
      return strdup(src);
   }
   else if(brk == src)
   {
      INT8  *post = charQFix(&(brk[2]));

      asprintf((char **) &ret, "\\textbackslash `%s", post);

      free(post);
   }
   else
   {
      UINT32  preLen = brk - src;
      INT8    *pre   = strndup(src, preLen);
      INT8    *post  = charQFix(&(brk[2]));

      asprintf((char **) &ret, "%s\\textbackslash `%s", pre, post);

      free(pre);
      free(post);
   }

   return ret;
}

static INT8 *quoteFix(INT8 *src)
{
   INT8  *brk = strstr(src, "\"\"");
   INT8  *ret = NULL;

   DEBUG("quoteFix(%s): Called . . .\n", src);

   if((brk == NULL) || (strlen(src) <= 2))
   {
      return strdup(src);
   }
   else if(brk == src)
   {
      INT8  *post = quoteFix(&(brk[2]));

      asprintf((char **) &ret, "\\textbackslash \"%s", post);

      free(post);
   }
   else
   {
      UINT32  preLen = brk - src;
      INT8    *pre   = strndup(src, preLen);
      INT8    *post  = quoteFix(&(brk[2]));

      asprintf((char **) &ret, "%s\\textbackslash \"%s", pre, post);

      free(pre);
      free(post);
   }

   return ret;
}

INT8 *string2oz(INT8 *src)
{
   INT8  *tFixed = texFix(src);
   INT8  *qFixed = quoteFix(tFixed);

   free(tFixed);

   return qFixed;
}

INT8 *char2oz(INT8 *src)
{
   INT8  *tFixed = texFix(src);
   INT8  *qFixed = charQFix(tFixed);

   free(tFixed);

   return qFixed;
}

static INT8 *getName(ParagraphNode *node)
{
   switch(node->nodeType)
   {
      case NODE_BASIC:
         return ((BasicDefNode *) node)->name;
      break;

      case NODE_TYPE_DEF:
         return ((TypeDefNode *) node)->name;
      break;

      case NODE_FREE_TYPE:
         return ((FreeTypeNode *) node)->name;
      break;

      case NODE_AXDEF:
         return ((AxDefNode *) node)->name;
      break;

      case NODE_GENDEF:
         return ((GenDefNode *) node)->name;
      break;

      case NODE_SCHEMA:
         return ((SchemaNode *) node)->name;
      break;

      case NODE_GEN_SCH:
         return ((GenSchemaNode *) node)->name;
      break;

      case NODE_CONST:
         return ((ConstraintNode *) node)->name;
      break;

      case NODE_PROCESS:
         return ((ProcessNode *) node)->name;
      break;
   }

   return NULL;
}

static void strWrite(int file, INT8 *string)
{
   write(file, string, strlen(string));
}

void initA2OzTex(INT8 *outPath)
{
   outFile = open(outPath, O_RDWR | O_CREAT | O_TRUNC, S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH);
}

void initOzXfm()
{
   xfmTable = malloc(OZ_XFM_TABLE_SIZE * sizeof(LinkList));

   memset(xfmTable, 0, OZ_XFM_TABLE_SIZE * sizeof(LinkList));
}

INT8 *atok2oz(AToken *aToken)
{
   return foztex("%s%s", aToken->preFmt, getOzXfm(aToken->token));
}

INT8 *foztex(char *format, ...)
{
   va_list  argList;
   INT8     *retVal = NULL;

   va_start(argList, format);

   vasprintf((char **) &retVal, format, argList);

   return retVal;
}

INT8 *list2oz(LinkList *list, INT8 *sep, INT8 *prefix, INT8 *trail)
{
   if(list == NULL)
   {
      return strdup("");
   }

   SyntaxTree  *synTree = (SyntaxTree *) list->object;
   LinkList    *props   = NULL;
   INT8        *remain  = list2oz(list->next, sep, "", trail);
   INT8        *retVal  = NULL;

   if(synTree->nodeType == NODE_PRED)
   {
      props = ((PredicateNode *) synTree)->props;
   }
   else if(synTree->nodeType == NODE_DECL)
   {
      props = ((DeclarationNode *) synTree)->props;
   }
   else if(synTree->nodeType == NODE_BASIC_ENTRY)
   {
      props = ((BasicEntryNode *) synTree)->props;
   }
   else if(synTree->nodeType == NODE_TYPE_ENTRY)
   {
      props = ((TypeEntryNode *) synTree)->props;
   }
   else if(synTree->nodeType == NODE_FREE_ENTRY)
   {
      props = ((FreeEntryNode *) synTree)->props;
   }

   if(strlen(remain) == 0)
   {
      retVal = foztex("%s%s%s", prefix, synTree->ozTex, trail);

      free(synTree->ozTex);
      free(remain);
   }
   else
   {
      retVal = foztex("%s%s%s%s", prefix, synTree->ozTex, sep, remain);

      free(synTree->ozTex);
      free(remain);
   }

   return retVal;
}

INT8 *genList2oz(LinkList *list)
{
   if(list == NULL)
   {
      return strdup("");
   }

   INT8  *remain = genList2oz(list->next);
   INT8  *retVal = NULL;

   if(strlen(remain) == 0)
   {
      retVal = foztex("%s", (INT8 *) list->object);

      free(remain);
   }
   else
   {
      retVal = foztex("%s, %s", (INT8 *) list->object, remain);

      free(remain);
   }

   return retVal;
}

UINT8 addOzXfm(INT8 *src, INT8 *tgt)
{
   LinkList  *list;
   LinkList  *remain;
   OzXfm     *ozObj;
   OzXfm     *newXfm = malloc(sizeof(OzXfm));
   UINT32    tokIdx;

   if(src == NULL)
   {
      yyuerror("addOzXfm(): Received NULL source");

      exit(-1);
   }

   if(tgt == NULL)
   {
      yyuerror("addOzXfm(): Received NULL target");

      exit(-1);
   }

   DEBUG("addOzXFM(%s, %s): Called . . .\n", src, tgt);

   if(newXfm == NULL)
   {
      yyuerror("addOzXfm(): Transform malloc");

      exit(-1);
   }

   newXfm->src = strdup(src);
   newXfm->tgt = strdup(tgt);

   tokIdx  = tokHash(src) % OZ_XFM_TABLE_SIZE;
   list    = &(xfmTable[tokIdx]);
   remain  = list;
   ozObj   = (OzXfm *) remain->object;

   while(ozObj != NULL)
   {
      if(strcmp(src, ozObj->src) == 0)
      {
         free(newXfm->src);
         free(newXfm->tgt);
         free(newXfm);

         yyuerror("ATex transform %s already exists", src);

         return 0;
      }
      else if(remain->next == NULL)
      {
         remain->next = createLinkList(NULL);

         if(remain->next == NULL)
         {
            yyuerror("addOzXfm(): List malloc");

            exit(-1);
         }
      }

      remain = remain->next;
      ozObj  = (OzXfm *) remain->object;
   }

   remain->object = newXfm;

   return 1;
}

INT8 *getOzXfm(INT8 *src)
{
   LinkList  *list;
   LinkList  *remain;
   UINT32    tokIdx;
   OzXfm     *ozObj;

   if(src == NULL)
   {
      yyuerror("getOzXfm(): Received NULL source");

      exit(-1);
   }

   tokIdx  = tokHash(src) % OZ_XFM_TABLE_SIZE;
   list    = &(xfmTable[tokIdx]);
   remain  = list;
   ozObj   = (OzXfm *) remain->object;

   while(ozObj != NULL)
   {
      if(strcmp(src, ozObj->src) == 0)
      {
         return ozObj->tgt;
      }
      else if(remain->next == NULL)
      {
         /* End of the list with no match */
         remain = NULL;
         ozObj  = NULL;
      }
      else
      {
         remain = remain->next;
         ozObj  = (OzXfm *) remain->object;
      }
   }

   return src;
}

void extractOzXfm(LinkList *propList)
{
   if((propList == NULL) || (propList->object == NULL) || (strcmp(propList->object, OZ_XFM_TAG) != 0))
   {
      return;
   }

   if((propList->next == NULL) || (propList->next->object == NULL))
   {
      return;
   }

   if((propList->next->next == NULL) || (propList->next->next->object == NULL))
   {
      return;
   }

   INT8  *aSpec = propList->next->object;
   INT8  *ozTex = propList->next->next->object;

   DEBUG("aSpec = %s, ozTex = %s\n", aSpec, ozTex);

   if((ozTex[0] == '"') && (ozTex[strlen(ozTex) - 1] == '"'))
   {
      ozTex[strlen(ozTex) - 1] = '\0';
      ozTex = &(ozTex[1]);
   }

   addOzXfm(aSpec, ozTex);
}

void writeA2OzTex(ParagraphNode *node)
{
   if(node == NULL)
   {
      return;
   }

   if(outFile == 0)
   {
      return;
   }

   if(!exportCheck(getLayer(node->props)))
   {
      return;
   }

   INT32  blanks    = -1;
   INT8   *data     = node->ozTex;
   INT8   *layer    = getLayer(node->props);
   INT8   *name     = getName(node);

   if(name != NULL)
   {
      name = normalizeName(name);
   }

   if(layer != NULL)
   {
      layer = normalizeName(layer);
   }

   if(data != NULL)
   {
      INT8  *lPtr = data;

      if(name != NULL)
      {
         strWrite(outFile, "\\ifx\\ATeXPAR");
         strWrite(outFile, name);
         strWrite(outFile, "\\undefined\n");
         strWrite(outFile, "\\newcommand{\\ATeXPAR");
         strWrite(outFile, name);
         strWrite(outFile, "}%\n{%\n");
      }
      else if(layer != NULL)
      {
         strWrite(outFile, "\\ifx\\LAYERID");
         strWrite(outFile, layer);
         strWrite(outFile, "\\ATeXEnabled\n");
      }

      /* Splits data into lines */
      while(strlen(lPtr) > 0)
      {
         if(blanks == 2147483647)
         {
            blanks = -1;
         }

         INT8    *lf   = index(lPtr, '\n');
         UINT32  len   = 0;
         INT8    *line = NULL;

         if(lf != NULL)
         {
            len = lf - lPtr + 1;
            line = malloc(len + 1);
         }
         else
         {
            len  = strlen(lPtr);
            line = malloc(len + 1);
         }

         memset(line, 0, len + 1);
         strncpy(line, lPtr, len);

         /* Handle blank lines */
         if(strspn(line, " \\\r\v\n\x0E") < strlen(line))
         {
            INT32  leadWS  = strspn(line, " ");
            INT8   *curPtr = line;
            UINT8  loop    = 0;

            blanks = 0;

            write(outFile, curPtr, leadWS);

            /* Converts a series of spaces to '\ ' marks for math environments only */
            if((node->nodeType != NODE_DESC) && ((leadWS - aIndent) > 0))
            {
               for(loop = 0; loop < leadWS - aIndent; loop++)
               {
                  strWrite(outFile, "\\ ");

                  /* Add a space for every two provided */
                  if(((loop + 1) % 2) == 0)
                  {
                     strWrite(outFile, "\\ ");
                  }
               }
            }

            curPtr = curPtr + leadWS;

            while(strlen(curPtr) > 0)
            {
               INT8  *brk = strpbrk(curPtr, "_\v\x0E\n");

               if(brk == NULL)
               {
                  strWrite(outFile, curPtr);

                  curPtr = &(curPtr[strlen(curPtr)]);
               }
               else if(brk == line)
               {
                  if(brk[0] == '_')
                  {
                     strWrite(outFile, "\\_");

                     curPtr = &(curPtr[1]);
                  }
                  else if(brk[0] == '\v') /* Do not write \v */
                  {
                     curPtr = &(curPtr[1]);
                     blanks = -1;
                  }
                  else if(brk[0] == '\x0E') /* Do not write 0x0E */
                  {
                     curPtr = &(curPtr[1]);
                     blanks = 1;
                  }
                  else if(brk[0] == '\n')
                  {
                     /* Add \\ to end of each newline without a \v immediately preceding it */
                     if(node->nodeType == NODE_DESC)
                     {
                        strWrite(outFile, "\n");
                     }
                     else
                     {
                        strWrite(outFile, "\\\\\n");
                     }

                     curPtr = &(curPtr[1]);
                  }
               }
               else
               {
                  UINT32  writeLen = brk - curPtr;

                  write(outFile, curPtr, writeLen);

                  if(brk[0] == '_')
                  {
                     if(*(brk - 1) != '\\')
                     {
                        strWrite(outFile, "\\_");
                     }
                     else
                     {
                        strWrite(outFile, "_");
                     }

                     curPtr = &(curPtr[writeLen + 1]);
                  }
                  else if(brk[0] == '\v') /* Do not write \v */
                  {
                     curPtr = &(curPtr[writeLen + 1]);
                     blanks = -1;
                  }
                  else if(brk[0] == '\x0E') /* Do not write 0x0E */
                  {
                     curPtr = &(curPtr[writeLen + 1]);
                     blanks = 1;
                  }
                  else if(brk[0] == '\n')
                  {
                     /* Add \\ to end of each newline without a \v immediately preceding it */
                     if((node->nodeType == NODE_DESC) || (*(brk - 1) == '\v'))
                     {
                        strWrite(outFile, "\n");
                     }
                     else
                     {
                        strWrite(outFile, "\\\\\n");
                     }

                     curPtr = &(curPtr[writeLen + 1]);
                  }
               } // else (us != curPtr)
            } // while(strlen(curPtr) > 0)
         } // if(strspn(line, " \\\r\v\n\x0E") < strlen(line))
         else
         {
            if(node->nodeType != NODE_DESC)
            {
               INT8  *one = rindex(line, 0x0E);
               INT8  *all = rindex(line, '\v');

               if(all > one)
               {
                  blanks = -1;
               }
               else if(one > all)
               {
                  blanks = 1;
               }

               if(blanks == 0)
               {
                  strWrite(outFile, "\\ALSO\n");
               }
               else if(blanks != 0)
               {
                  blanks = blanks - 1;
               }
            }
            else
            {
               strWrite(outFile, line);
            }
         }

         lPtr = lPtr + len;

         free(line);
      } // while(strlen(lPtr) > 0)

      free(data);

      if(name != NULL)
      {
         strWrite(outFile, "}%\n\\fi\n\n");

         if(layer != NULL)
         {
            strWrite(outFile, "\\ifx\\LAYERID");
            strWrite(outFile, layer);
            strWrite(outFile, "\\ATeXEnabled\n");
            strWrite(outFile, "\\ATeXPAR");
            strWrite(outFile, name);
            strWrite(outFile, "\n\\fi\n\n");
         }
         else
         {
            strWrite(outFile, "\\ATeXPAR");
            strWrite(outFile, name);
            strWrite(outFile, "\n\n");
         }
      }
      else if(layer != NULL)
      {
         strWrite(outFile, "\\fi\n\n");
      }
      else
      {
         strWrite(outFile, "\n");
      }
   } // if(data != NULL)
   else if(node->nodeType == NODE_DIREC)
   {
      /* Cannot use getCommand(...) here because there could be multiple display tags in one directive */
      LinkList  *ite = ((DirectiveNode *) node)->commands;

      while(ite != NULL)
      {
         LinkList  *command = (LinkList *) ite->object;

         if((command != NULL) && (sizeLinkList(command) == 2) &&
            (command->object != NULL) && (strcmp(command->object, OZ_DISPLAY_TAG) == 0))
         {
            INT8  *dispName = command->next->object;

            if(dispName != NULL)
            {
               dispName = normalizeName(dispName);

               if(layer != NULL)
               {
                  strWrite(outFile, "\\ifx\\LAYERID");
                  strWrite(outFile, layer);
                  strWrite(outFile, "\\ATeXEnabled\n");
                  strWrite(outFile, "\\ATeXPAR");
                  strWrite(outFile, dispName);
                  strWrite(outFile, "\n\\fi\n\n");
               }
               else
               {
                  strWrite(outFile, "\\ATeXPAR");
                  strWrite(outFile, dispName);
                  strWrite(outFile, "\n\n");
               }

               free(dispName);
            }
         }

         ite = ite->next;
      }
   }

   if(name != NULL)
   {
      free(name);
   }

   if(layer != NULL)
   {
      free(layer);
   }
}

void closeA2OzTex()
{
   if(outFile != 0)
   {
      close(outFile);
   }
}
