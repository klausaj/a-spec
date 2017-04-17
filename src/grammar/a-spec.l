%{
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

#ifdef WIN32
   #include "arch/mingw/a-spec_mingw.h"
#endif

#include "a-specc/a-specc_types.h"
#include "a-specc/a-specc_api.h"
#include "grammar/a-spec.tab.h"

struct InputStack_t
{
   struct InputStack_t  *prev;
   YY_BUFFER_STATE      bs;
   UINT32               lineNum;
   INT8                *fileName;
   FILE                 *file;
};

typedef struct InputStack_t  InputStack;

static InputStack  *curIS;
static Symbol      *tmpSym;
static int         symType;
static int         killLF = 0;

#define YY_USER_ACTION \
   prevLen   = curLen; \
   curLen    = yyleng; \
   acceptLen = acceptLen + yyleng;

UINT8 newFile(INT8 *filePath)
{
   InputStack  *is   = malloc(sizeof(InputStack));
   FILE        *file = fopen(filePath, "r");

   DEBUG("newFile(%s): Called . . .\n", filePath);

   if(file == NULL)
   {
      free(is);

      return 0;
   }

   if(is == NULL)
   {
      yyerror("Unable to malloc InputStack");

      exit(-1);
   }

   if(curIS)
   {
      curIS->lineNum = yylineno;
   }

   is->fileName = strdup(filePath);
   is->file     = file;
   is->prev     = curIS;
   is->bs       = yy_create_buffer(file, YY_BUF_SIZE);

   curFile = is->fileName;

   yy_switch_to_buffer(is->bs);

   curIS    = is;
   yylineno = 1;

   DEBUG("newFile(): returning . . .\n");

   return 1;
}

UINT8 popFile()
{
   InputStack  *is     = curIS;
   InputStack  *prevIS = NULL;

   if(is == NULL)
   {
      curIS    = NULL;
      curFile  = NULL;
      yylineno = 0;

      return 0;
   }

   fclose(is->file);
   yy_delete_buffer(is->bs);
   free(is->fileName);

   prevIS = is->prev;
   free(is);

   if(prevIS == NULL)
   {
      curIS    = NULL;
      curFile  = NULL;
      yylineno = 0;

      return 0;
   }

   yy_switch_to_buffer(prevIS->bs);

   curIS    = prevIS;
   yylineno = curIS->lineNum;
   curFile  = curIS->fileName;

   return 1;
}
%}

%option noyywrap nodefault yylineno

%x TEXT
%x IFILE
%x FIRST
%x FILEID
%x SKIP
%s DEFAULT

NUMERIC      [0-9]
NUMERIC2     [2-9]
ALPHA        [a-zA-Z]
ESC_CHAR     [\\]
TAG_TERM     [\/]
TAG_START    [<]
TAG_END      [>]
APOSTROPHE   [']
PIPE         [\|]
AT           [@]
COMMA        [\,]
PERIOD       [\.]
EXCLAIM      [!]
TILDE        [~]
QUEST        [\?]
COLON        [:]
SEMI_COLON   [;]
UNDERSCORE   [_]
OPAREN       [(]
CPAREN       [)]
OSQUARE      [\[]
CSQUARE      [\]]
OCURLY       [\{]
CCURLY       [\}]
EQUALS       [=]
LF           [\n]
CR           [\r]
SPACE        [ ]
POUND        [#]
TAB          [\t]
QUOTE        [\"]
EOL          {LF}|{CR}
WS           {SPACE}|{TAB}
SYMBOL       \-|{EQUALS}|`|{TILDE}|{EXCLAIM}|{AT}|#|$|%|\^|&|\*|{OPAREN}|{CPAREN}|{UNDERSCORE}|\+|{OSQUARE}|{OCURLY}|{CSQUARE}|{CCURLY}|{ESC_CHAR}|{PIPE}|{SEMI_COLON}|{COLON}|{APOSTROPHE}|\"|{TAG_START}|\.|{TAG_END}|{TAG_TERM}|{QUEST}|{COMMA}
STR_SYMBOL   \-|{EQUALS}|`|{TILDE}|{EXCLAIM}|{AT}|#|$|%|\^|&|\*|{OPAREN}|{CPAREN}|{UNDERSCORE}|\+|{OSQUARE}|{OCURLY}|{CSQUARE}|{CCURLY}|{ESC_CHAR}|{PIPE}|{SEMI_COLON}|{COLON}|{APOSTROPHE}|{TAG_START}|\.|{TAG_END}|{TAG_TERM}|{QUEST}|{COMMA}
TEXT_SYMBOL  \-|{EQUALS}|`|{TILDE}|{EXCLAIM}|{AT}|#|$|%|\^|&|\*|{OPAREN}|{CPAREN}|{UNDERSCORE}|\+|{OSQUARE}|{OCURLY}|{CSQUARE}|{CCURLY}|{ESC_CHAR}|{PIPE}|{SEMI_COLON}|{COLON}|{APOSTROPHE}|\"|\.|{QUEST}|{COMMA}
SYMSEQ_CHAR  \-|{EQUALS}|{TILDE}|{EXCLAIM}|$|%|\^|&|\*|{UNDERSCORE}|\+|{PIPE}|{APOSTROPHE}|\.|{TAG_START}|{TAG_TERM}|{TAG_END}
IDENT_CHAR   {ALPHA}|{NUMERIC}|{UNDERSCORE}
WORD_CHAR    {IDENT_CHAR}|{ESC_CHAR}{CHAR}
TAG_CHAR     {IDENT_CHAR}
CHAR         {ALPHA}|{NUMERIC}|{SYMBOL}|{SPACE}
STRING       \"(\\.|\"\"|[^\"])*\"
COMMENT      %([^%])*%
ANNOTATION   @\[(\\.|[^\[\]])*\]
KILL_1       @\\1
KILL_ALL     @\\\*
KILL_LF      @\\

CHAR_LITERAL  `(\\[^`]|``|[^`\n])+`

INTEGER     {NUMERIC}+
HEX         0[xX][0-9a-fA-F]+
DECOR_INT   {NUMERIC2}{NUMERIC}*
IDENT       {ALPHA}{IDENT_CHAR}*
WORD        {WORD_CHAR}+
SYM_SEQ     {SYMSEQ_CHAR}+

BEGIN         begin[ \t]+
BLOCK_END     end
INFO_START    <DocumentInfo>
INFO_END      <{TAG_TERM}DocumentInfo>
PROP_START    <Properties>
PROP_END      <{TAG_TERM}Properties>
SCH_START     {BEGIN}schema
BASIC_START   {BEGIN}basic
TYPE_START    {BEGIN}type
FREE_START    {BEGIN}free
AXDEF_START   {BEGIN}axdef
CONST_START   {BEGIN}const
GENDEF_START  {BEGIN}gendef
GENSCH_START  {BEGIN}gensch
DESC_START    <Description>
DESC_END      <{TAG_TERM}Description>
DIREC_START   <Directive>
DIREC_END     <{TAG_TERM}Directive>
WHERE         where

PROC_START  {BEGIN}process

TEXT_START  <Text>{WS}*{EOL}*
TEXT_END    <{TAG_TERM}Text>
TEXT_BODY   (\\.|[^<>\/])*

FUNC_ID  func
BOOL_ID  bool
OPER_ID  oper
REL_ID   rel
OP_TYPE  pre[1-9]|post[1-9]|bin[1-9]

TRUE   true
FALSE  false

 /*%N0  upto
   %R1  lequiv liff sequiv siff
   %L2  lor sor
   %L3  land sand
   %R4  lt leq gt geq neq eq setin setnin subeq sub prefix suffix partition seqin gen_in dcat
   %L5  plus minus oplus union setdiff seqcat
   %L6  mult div mod dres ndres rres nrres eproj eext sproj inter scomp spipe rcomp rrcomp rimg
   %R7  uplus uminus lnot gen_pre snot rnot
   %L8  func select cross
   %N9  bind */

EQUIV      <{EQUALS}>
IMPLIES    {EQUALS}{EQUALS}>
LOR        {PIPE}{PIPE}
SOR        {PIPE}
LAND       &&
SAND       &
LT         <
LEQ        <{EQUALS}
GT         >
GEQ        >{EQUALS}
NEQ        {EXCLAIM}{EQUALS}
EQ         {EQUALS}
SETIN      in
SETNIN     {EXCLAIM}in
PLUS       \+
MINUS      -
MULT       \*
EXPON      \^
ZPRE       zpre
ZPOST      zpost
ZUNP       zunp
ZTYPE      ztype
ZPROJ      zproj
ZHIDE      zhide
ZIN        zin
ZOUT       zout
ZXI        xi
LNOT       {EXCLAIM}
SNOT       {TILDE}
UPTO       {PERIOD}{PERIOD}

ALL    forAll
EXIST  exists
UNIQ   exists1

IF     if
THEN   then
ELSE   else
ELIF   elif
ENDIF  endif

SET_DISP    setDisp
SEQ_DISP    seqDisp
CROSS       cross
SET_COMP    setComp
LAMBDA      lambda
MU          mu
LET         let
PRE_DECOR   delta|delta{DECOR_INT}
POST_DECOR  {APOSTROPHE}|{APOSTROPHE}{DECOR_INT}
SCH_TYPE    schType
SCH_BIND    schBind
SCH_OVER    zover

IMPORT_START   #import<
IMPORT_CHAR    {ALPHA}|{NUMERIC}|{PERIOD}|{UNDERSCORE}|{TAG_TERM}|{ESC_CHAR}|{MINUS}
IMPORT_FILE    {IMPORT_CHAR}+
IMPORT_END     >{SPACE}*{EOL}

PRE_ID    {WS}|{EOL}
FILE_ID   #fileID<{IDENT}>

P4RIN   {LT}|{LEQ}|{GT}|{GEQ}|{NEQ}|{SETIN}|{SETNIN}

INTERNAL    \|~\|
EXTERNAL    \[\]
PARALELL    \|\|
INTERLEAVE  \|\|\|
INTERRUPT   \/\\
OIF_PAR     \[\|
CIF_PAR     \|\]
PTHEN       ->
PROC_ID     proc
CHAN_ID     chan
PSEQ        pseq
PHIDE       phide
PREN        pren

%%
<INITIAL>.*    {
                  /* This rule allows the first line of a file to be read.
                     Transition to DEFAULT state prevents an infinite loop
                     due to this rule.  Note: DEFAULT is declared with a %s */
                  strncpy(lineBuf, yytext, LINE_BUF_SIZE);
                  acceptLen = 0;

                  DEBUG("Setting fileID: %s\n", yytext);

                  BEGIN(FILEID);

                  yyless(0);
               }

<INITIAL>{LF}    {
                 }

<FIRST>.*      {
                  DEBUG("Setting default: %s\n", yytext);

                  /* This rule allows the first line of a file to be read.
                     Transition to DEFAULT state prevents an infinite loop
                     due to this rule.  Note: DEFAULT is declared with a %s */
                  strncpy(lineBuf, yytext, LINE_BUF_SIZE);
                  acceptLen = 0;

                  BEGIN(DEFAULT);

                  yyless(0);
               }

<FIRST>{LF}    {
               }

<SKIP>.*    {
               DEBUG("skipped: %s\n", yytext);
            }

<SKIP>{EOL}    {
                  DEBUG("skipped: %s\n", yytext);
               }

<FILEID>{PRE_ID}   {
                      DEBUG("read: '%s'\n", yytext);
                   }

<FILEID>{FILE_ID}   {
                       INT8  *startChar = index(yytext, '<');
                       INT8  *endChar = index(yytext, '>');

                       if((startChar == NULL) || (endChar == NULL) || (endChar < startChar) || ((endChar - startChar) < 2))
                       {
                          yyerror("Illegal fileID token %s", yytext);
                       }
                       else
                       {
                          startChar = &(startChar[1]);
                          endChar   = &(endChar[-1]);

                          UINT32  idLen   = endChar - startChar + 1;
                          INT8   *fileID = strndup(startChar, idLen);

                          DEBUG("fileID: '%s'\n", fileID);

                          if(isInList(fileID, importList, &strEquals))
                          {
                             DEBUG("Setting skip\n");

                             free(fileID);

                             BEGIN(SKIP);
                          }
                          else
                          {
                             if(importList == NULL)
                             {
                                importList = createLinkList(fileID);
                             }
                             else
                             {
                                appendLinkList(importList, fileID);
                             }

                             BEGIN(DEFAULT);
                          }
                       }
                    }

<FILEID>.  {
              yyerror("Start of file must contain a valid fileID: %s", yytext);

              if(popFile() == 0)
              {
                 yyterminate();
              }
              else
              {
                 DEBUG("Setting first for fileID: %s\n", yytext);

                 BEGIN(FIRST);
              }
           }

{COMMENT}  {
              clearFormat();
           }

{LF}.*          {
                   if(killLF == 0)
                   {
                      curFmt[strlen(curFmt)] = '\n';
                      strncpy(lineBuf, yytext + 1, LINE_BUF_SIZE);
                   }
                   else
                   {
                      killLF = 0;
                   }

                   acceptLen = 0;

                   yyless(1);
                }

{TEXT_START}       {
                      BEGIN(TEXT);
                   }

<TEXT>{TEXT_END}   {
                      BEGIN(DEFAULT);
                   }

<TEXT>.            {
                      yyerror("Ignoring illegal text character %s", yytext);
                   }


<TEXT>{TEXT_BODY}  {
                      yylval.atok = createAToken(curFmt, yytext);

                      clearFormat();

                      return TOK_TEXT;
                   }

{IMPORT_START}        {
                         DEBUG("Importing . . .\n");
                         BEGIN(IFILE);
                      }

<IFILE>{IMPORT_FILE}  {
                         DEBUG("file = %s\n", yytext);

                         tmpCh = input();

                         if(tmpCh != '>')
                         {
                            yyerror("Ignoring illegal character after import file %s", yytext);
                         }

                         DEBUG("Consumed closing '>'\n");

                         while(1)
                         {
                            tmpCh = input();

                            if(tmpCh == '\n')
                            {
                               DEBUG("Consumed newline\n");

                               break;
                            }
                            else if((tmpCh != '\t') && (tmpCh != ' ') && (tmpCh != '\r'))
                            {
                               yyerror("Ignoring illegal character after import statement");
                            }
                         }

                         BEGIN(INITIAL);

                         if(importFile(yytext) == 0)
                         {
                            yyterminate();

                            yyerror("Unable to open import file %s", yytext);

                            exit(-1);
                         }

                         lineBuf[0] = 0;
                         acceptLen  = 0;

                         DEBUG("Parsing file %s\n", yytext);
                      }
<IFILE>.  {
             yyerror("Ignoring illegal character in import statement");
          }

<<EOF>>   {
             DEBUG("EOF\n");

             if(popFile() == 0)
             {
                yyterminate();
             }
             else
             {
                DEBUG("Setting first for EOF: %s\n", yytext);

                BEGIN(FIRST);
             }
          }

{INTEGER}|{HEX} {
                   yylval.atok = createAToken(curFmt, yytext);

                   clearFormat();

                   return TOK_NUMBER;
                }

{ANNOTATION}    {
                   yytext[strlen(yytext) - 1] = 0;

                   addFormat(&(yytext[2]));  /* Trim leading and trailing brackets */
                }

{KILL_1}        {
                   curFmt[strlen(curFmt)] = 0x0E;
                }

{KILL_ALL}      {
                   curFmt[strlen(curFmt)] = '\v';
                }

{KILL_LF}       {
                   killLF = 1;
                }

{STRING}        {
                   yylval.atok = createAToken(curFmt, yytext);

                   clearFormat();

                   return TOK_STRING;
                }

{CHAR_LITERAL}  {
                   yylval.atok = createAToken(curFmt, yytext);

                   clearFormat();

                   return TOK_CHAR;
                }

{EXCLAIM}       {
                   yylval.fmt = strdup(curFmt);

                   clearFormat();

                   return TOK_EXCLAIM;
                }

{FUNC_ID}       {
                   yylval.fmt = strdup(curFmt);

                   clearFormat();

                   return TOK_FUNC_ID;
                }

{BOOL_ID}       {
                   yylval.fmt = strdup(curFmt);

                   clearFormat();

                   return TOK_BOOL_ID;
                }

{OPER_ID}       {
                   yylval.fmt = strdup(curFmt);

                   clearFormat();

                   return TOK_OPER_ID;
                }

{REL_ID}        {
                   yylval.fmt = strdup(curFmt);

                   clearFormat();

                   return TOK_REL_ID;
                }

{OP_TYPE}       {
                   yylval.atok = createAToken(curFmt, yytext);

                   clearFormat();

                   return TOK_OP_TYPE;
                }

{EQUIV}         {
                   yylval.fmt = strdup(curFmt);

                   clearFormat();

                   return TOK_EQUIV;
                }

{IMPLIES}       {
                   yylval.fmt = strdup(curFmt);

                   clearFormat();

                   return TOK_IMPLIES;
                }

{LOR}           {
                   yylval.fmt = strdup(curFmt);

                   clearFormat();

                   return TOK_LOR;
                }

{SOR}           {
                   yylval.fmt = strdup(curFmt);

                   clearFormat();

                   return TOK_SOR;
                }

{LAND}          {
                   yylval.fmt = strdup(curFmt);

                   clearFormat();

                   return TOK_LAND;
                }

{SAND}          {
                   yylval.fmt = strdup(curFmt);

                   clearFormat();

                   return TOK_SAND;
                }

{ZPRE}          {
                   yylval.fmt = strdup(curFmt);

                   clearFormat();

                   return TOK_ZPRE;
                }

{ZPOST}         {
                   yylval.fmt = strdup(curFmt);

                   clearFormat();

                   return TOK_ZPOST;
                }

{ZUNP}          {
                   yylval.fmt = strdup(curFmt);

                   clearFormat();

                   return TOK_ZUNP;
                }

{ZTYPE}         {
                   yylval.fmt = strdup(curFmt);

                   clearFormat();

                   return TOK_ZTYPE;
                }

{ZPROJ}         {
                   yylval.fmt = strdup(curFmt);

                   clearFormat();

                   return TOK_ZPROJ;
                }

{ZHIDE}         {
                   yylval.fmt = strdup(curFmt);

                   clearFormat();

                   return TOK_ZHIDE;
                }

{ZIN}           {
                   yylval.fmt = strdup(curFmt);

                   clearFormat();

                   return TOK_ZIN;
                }

{ZOUT}          {
                   yylval.fmt = strdup(curFmt);

                   clearFormat();

                   return TOK_ZOUT;
                }

{ZXI}           {
                   yylval.fmt = strdup(curFmt);

                   clearFormat();

                   return TOK_ZXI;
                }

{PLUS}          {
                   yylval.fmt = strdup(curFmt);

                   clearFormat();

                   return TOK_PLUS;
                }

{MINUS}         {
                   yylval.fmt = strdup(curFmt);

                   clearFormat();

                   return TOK_MINUS;
                }

{QUEST}         {
                   yylval.fmt = strdup(curFmt);

                   clearFormat();

                   return TOK_QUEST;
                }

{MULT}          {
                   yylval.fmt = strdup(curFmt);

                   clearFormat();

                   return TOK_MULT;
                }

{EXPON}         {
                   yylval.fmt = strdup(curFmt);

                   clearFormat();

                   return TOK_EXPON;
                }

{EQ}            {
                   yylval.fmt = strdup(curFmt);

                   clearFormat();

                   return TOK_EQUALS;
                }

{P4RIN}         {
                   yylval.atok = createAToken(curFmt, yytext);

                   clearFormat();

                   return TOK_P4RIN;
                }

{PERIOD}        {
                   yylval.fmt = strdup(curFmt);

                   clearFormat();

                   return TOK_PERIOD;
                }

{SNOT}          {
                   yylval.fmt = strdup(curFmt);

                   clearFormat();

                   return TOK_SNOT;
                }

{UPTO}          {
                   yylval.fmt = strdup(curFmt);

                   clearFormat();

                   return TOK_UPTO;
                }

{SET_DISP}      {
                   yylval.fmt = strdup(curFmt);

                   clearFormat();

                   return TOK_SET_DISP;
                }

{SEQ_DISP}      {
                   yylval.fmt = strdup(curFmt);

                   clearFormat();

                   return TOK_SEQ_DISP;
                }

{CROSS}         {
                   yylval.fmt = strdup(curFmt);

                   clearFormat();

                   return TOK_CROSS;
                }

{SET_COMP}      {
                   if(!pushSymStack(0, &yyerror))
                   {
                      yyerror("Unable to push stack for setComp");

                      exit(-1);
                   }

                   yylval.fmt = strdup(curFmt);

                   clearFormat();

                   return TOK_SET_COMP;
                }

{LAMBDA}        {
                   if(!pushSymStack(0, &yyerror))
                   {
                      yyerror("Unable to push stack for lambda");

                      exit(-1);
                   }

                   yylval.fmt = strdup(curFmt);

                   clearFormat();

                   return TOK_LAMBDA;
                }

{MU}            {
                   if(!pushSymStack(0, &yyerror))
                   {
                      yyerror("Unable to push stack for mu");

                      exit(-1);
                   }

                   yylval.fmt = strdup(curFmt);

                   clearFormat();

                   return TOK_MU;
                }

{LET}           {
                   if(!pushSymStack(0, &yyerror))
                   {
                      yyerror("Unable to push stack for let");

                      exit(-1);
                   }

                   yylval.fmt = strdup(curFmt);

                   clearFormat();

                   return TOK_LET;
                }

{PRE_DECOR}     {
                   yylval.atok = createAToken(curFmt, yytext);

                   clearFormat();

                   return TOK_PRE_DECOR;
                }

{POST_DECOR}    {
                   yylval.atok = createAToken(curFmt, yytext);

                   clearFormat();

                   return TOK_POST_DECOR;
                }

{SCH_TYPE}      {
                   if(!pushSymStack(0, &yyerror))
                   {
                      yyerror("Unable to push stack for schType");

                      exit(-1);
                   }

                   yylval.fmt = strdup(curFmt);

                   clearFormat();

                   return TOK_SCH_TYPE;
                }

{SCH_BIND}      {
                   yylval.fmt = strdup(curFmt);

                   clearFormat();

                   return TOK_SCH_BIND;
                }

{SCH_OVER}      {
                   yylval.fmt = strdup(curFmt);

                   clearFormat();

                   return TOK_SCH_OVER;
                }

{TRUE}          {
                   yylval.fmt = strdup(curFmt);

                   clearFormat();

                   return TOK_TRUE;
                }

{FALSE}         {
                   yylval.fmt = strdup(curFmt);

                   clearFormat();

                   return TOK_FALSE;
                }

{ALL}           {
                   if(!pushSymStack(0, &yyerror))
                   {
                      yyerror("Unable to push stack for all quantifier");

                      exit(-1);
                   }

                   yylval.fmt = strdup(curFmt);

                   clearFormat();

                   return TOK_ALL;
                }

{EXIST}         {
                   if(!pushSymStack(0, &yyerror))
                   {
                      yyerror("Unable to push stack for exist quantifier");

                      exit(-1);
                   }

                   yylval.fmt = strdup(curFmt);

                   clearFormat();

                   return TOK_EXIST;
                }

{UNIQ}          {
                   if(!pushSymStack(0, &yyerror))
                   {
                      yyerror("Unable to push stack for exist1 quantifier");

                      exit(-1);
                   }

                   yylval.fmt = strdup(curFmt);

                   clearFormat();

                   return TOK_UNIQ;
                }

{IF}            {
                   yylval.fmt = strdup(curFmt);

                   clearFormat();

                   return TOK_IF;
                }

{THEN}          {
                   yylval.fmt = strdup(curFmt);

                   clearFormat();

                   return TOK_THEN;
                }

{ELSE}          {
                   yylval.fmt = strdup(curFmt);

                   clearFormat();

                   return TOK_ELSE;
                }

{ELIF}          {
                   yylval.fmt = strdup(curFmt);

                   clearFormat();

                   return TOK_ELIF;
                }

{ENDIF}         {
                   yylval.fmt = strdup(curFmt);

                   clearFormat();

                   return TOK_ENDIF;
                }

{INFO_START}    {
                   return TOK_INFO_START;
                }

{INFO_END}      {
                   return TOK_INFO_END;
                }

{PROP_START}    {
                   return TOK_PROP_START;
                }

{PROP_END}      {
                   return TOK_PROP_END;
                }

{SCH_START}     {
                   if(!pushSymStack(0, &yyerror))
                   {
                      yyerror("Unable to push stack for <Schema>");

                      exit(-1);
                   }

                   clearFormat();

                   return TOK_SCH_START;
                }

{BASIC_START}   {
                   clearFormat();

                   return TOK_BASIC_START;
                }

{TYPE_START}    {
                   if(!pushSymStack(1, &yyerror))
                   {
                      yyerror("Unable to push stack for <TypeDef>");

                      exit(-1);
                   }

                   clearFormat();

                   return TOK_TYPE_START;
                }

{FREE_START}    {
                   clearFormat();

                   return TOK_FREE_START;
                }

{AXDEF_START}   {
                   if(!pushSymStack(1, &yyerror))
                   {
                      yyerror("Unable to push stack for <AxDef>");

                      exit(-1);
                   }

                   clearFormat();

                   return TOK_AXDEF_START;
                }

{CONST_START}   {
                   clearFormat();

                   return TOK_CONST_START;
                }

{GENDEF_START}  {
                   if(!pushSymStack(1, &yyerror))
                   {
                      yyerror("Unable to push stack for <GenDef>");

                      exit(-1);
                   }

                   clearFormat();

                   return TOK_GENDEF_START;
                }

{GENSCH_START}  {
                   if(!pushSymStack(0, &yyerror))
                   {
                      yyerror("Unable to push stack for <GenSchema>");

                      exit(-1);
                   }

                   clearFormat();

                   return TOK_GENSCH_START;
                }

{PROC_START}    {
                   if(!pushSymStack(1, &yyerror))
                   {
                      yyerror("Unable to push stack for <Process>");

                      exit(-1);
                   }

                   clearFormat();

                   return TOK_PROC_START;
                }

{DESC_START}    {
                   clearFormat();

                   return TOK_DESC_START;
                }

{DESC_END}      {
                   return TOK_DESC_END;
                }

{DIREC_START}   {
                   clearFormat();

                   return TOK_DIREC_START;
                }

{DIREC_END}     {
                   return TOK_DIREC_END;
                }

{BLOCK_END}     {
                   yylval.fmt = strdup(curFmt);

                   clearFormat();

                   return TOK_BLOCK_END;
                }

{WHERE}         {
                   yylval.fmt = strdup(curFmt);

                   clearFormat();

                   return TOK_WHERE;
                }

{INTERNAL}      {
                   yylval.fmt = strdup(curFmt);

                   clearFormat();

                   return TOK_INTERNAL;
                }

{EXTERNAL}      {
                   yylval.fmt = strdup(curFmt);

                   clearFormat();

                   return TOK_EXTERNAL;
                }

{INTERLEAVE}    {
                   yylval.fmt = strdup(curFmt);

                   clearFormat();

                   return TOK_INTERLEAVE;
                }

{OIF_PAR}       {
                   yylval.fmt = strdup(curFmt);

                   clearFormat();

                   return TOK_OIF_PAR;
                }

{CIF_PAR}       {
                   yylval.fmt = strdup(curFmt);

                   clearFormat();

                   return TOK_CIF_PAR;
                }

{INTERRUPT}     {
                   yylval.fmt = strdup(curFmt);

                   clearFormat();

                   return TOK_INTERRUPT;
                }

{PTHEN}         {
                   yylval.fmt = strdup(curFmt);

                   clearFormat();

                   return TOK_PTHEN;
                }

{PROC_ID}       {
                   yylval.fmt = strdup(curFmt);

                   clearFormat();

                   return TOK_PROC_ID;
                }

{CHAN_ID}       {
                   yylval.fmt = strdup(curFmt);

                   clearFormat();

                   return TOK_CHAN_ID;
                }

{PSEQ}          {
                   yylval.fmt = strdup(curFmt);

                   clearFormat();

                   return TOK_PSEQ;
                }

{PHIDE}         {
                   yylval.fmt = strdup(curFmt);

                   clearFormat();

                   return TOK_PHIDE;
                }

{PREN}          {
                   yylval.fmt = strdup(curFmt);

                   clearFormat();

                   return TOK_PREN;
                }

{SYM_SEQ}       {
                   DEBUG("WORD: %s\n", yytext);

                   tmpSym = symLookup(yytext, &yyerror);

                   if(tmpSym == NULL)
                   {
                      yylval.atok = createAToken(curFmt, yytext);
                      symType     = TOK_IDENT;

                      clearFormat();
                   }
                   else
                   {
                      yylval.atok = createAToken(curFmt, yytext);
                      symType     = tmpSym->symType;

                      clearFormat();
                   }

                   DEBUG("WORD ==> %d: %s\n", symType, yylval.atok->token);

                   return symType;
                }

{IDENT}         {
                   DEBUG("WORD: %s\n", yytext);

                   tmpSym = symLookup(yytext, &yyerror);

                   if(tmpSym == NULL)
                   {
                      yylval.atok = createAToken(curFmt, yytext);
                      symType     = TOK_IDENT;

                      clearFormat();
                   }
                   else
                   {
                      yylval.atok = createAToken(curFmt, yytext);
                      symType     = tmpSym->symType;

                      clearFormat();
                   }

                   DEBUG("WORD ==> %d: %s\n", symType, yylval.atok->token);

                   return symType;
                }

{WORD}          {
                   yylval.atok = createAToken(curFmt, yytext);

                   clearFormat();

                   return TOK_WORD;
                }

{CR}            {
                }

{SPACE}         {
                   curFmt[strlen(curFmt)] = ' ';
                }

{TAB}           {
                   UINT8  loop = 0;

                   for(loop = 0; loop < aTabGroup; loop++);
                   {
                      curFmt[strlen(curFmt)] = ' ';
                   }
                }

{SEMI_COLON}    {
                   yylval.fmt = strdup(curFmt);

                   clearFormat();

                   return TOK_SEMICOLON;
                }

{COLON}         {
                   yylval.fmt = strdup(curFmt);

                   clearFormat();

                   return TOK_COLON;
                }

{COMMA}         {
                   yylval.fmt = strdup(curFmt);

                   clearFormat();

                   return TOK_COMMA;
                }

{AT}            {
                   yylval.fmt = strdup(curFmt);

                   clearFormat();

                   return TOK_AT;
                }

{POUND}         {
                   DEBUG("state = %d\n", YY_START);

                   yylval.fmt = strdup(curFmt);

                   clearFormat();

                   return TOK_POUND;
                }

{OSQUARE}       {
                   yylval.fmt = strdup(curFmt);

                   clearFormat();

                   return TOK_OSQUARE;
                }

{CSQUARE}       {
                   yylval.fmt = strdup(curFmt);

                   clearFormat();

                   return TOK_CSQUARE;
                }

{OCURLY}        {
                   yylval.fmt = strdup(curFmt);

                   clearFormat();

                   return TOK_OCURLY;
                }

{CCURLY}        {
                   yylval.fmt = strdup(curFmt);

                   clearFormat();

                   return TOK_CCURLY;
                }

{OPAREN}        {
                   yylval.fmt = strdup(curFmt);

                   clearFormat();

                   return TOK_OPAREN;
                }

{CPAREN}        {
                   yylval.fmt = strdup(curFmt);

                   clearFormat();

                   return TOK_CPAREN;
                }

.               {
                   yyerror("Ignoring illegal character: %s", yytext);
                }
%%
