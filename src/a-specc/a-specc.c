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

#include <getopt.h>
#include <string.h>
#include <stdarg.h>
#include <stdlib.h>
#include <unistd.h>
#include <stdio.h>
#include <fcntl.h>

#ifdef WIN32
   #include "arch/mingw/a-spec_mingw.h"
#endif

#include "a-translate/a2oztex.h"
#include "a-specc/a-specc.h"

const INT8  *OPER_STR = "oper";
const INT8  *REL_STR  = "rel";

const INT8  *PRE1_STR = "pre1";
const INT8  *PRE2_STR = "pre2";
const INT8  *PRE3_STR = "pre3";
const INT8  *PRE4_STR = "pre4";
const INT8  *PRE5_STR = "pre5";
const INT8  *PRE6_STR = "pre6";
const INT8  *PRE7_STR = "pre7";
const INT8  *PRE8_STR = "pre8";
const INT8  *PRE9_STR = "pre9";

const INT8  *IN1_STR = "bin1";
const INT8  *IN2_STR = "bin2";
const INT8  *IN3_STR = "bin3";
const INT8  *IN4_STR = "bin4";
const INT8  *IN5_STR = "bin5";
const INT8  *IN6_STR = "bin6";
const INT8  *IN7_STR = "bin7";
const INT8  *IN8_STR = "bin8";
const INT8  *IN9_STR = "bin9";

const INT8  *POST1_STR = "post1";
const INT8  *POST2_STR = "post2";
const INT8  *POST3_STR = "post3";
const INT8  *POST4_STR = "post4";
const INT8  *POST5_STR = "post5";
const INT8  *POST6_STR = "post6";
const INT8  *POST7_STR = "post7";
const INT8  *POST8_STR = "post8";
const INT8  *POST9_STR = "post9";

#define OP_SIG_COUNT   2
#define OP_TYPE_COUNT  27

#define OP_SIG_OPER  0
#define OP_SIG_REL   1

#define OP_TYPE_PRE1  0
#define OP_TYPE_PRE2  1
#define OP_TYPE_PRE3  2
#define OP_TYPE_PRE4  3
#define OP_TYPE_PRE5  4
#define OP_TYPE_PRE6  5
#define OP_TYPE_PRE7  6
#define OP_TYPE_PRE8  7
#define OP_TYPE_PRE9  8

#define OP_TYPE_IN1  9
#define OP_TYPE_IN2  10
#define OP_TYPE_IN3  11
#define OP_TYPE_IN4  12
#define OP_TYPE_IN5  13
#define OP_TYPE_IN6  14
#define OP_TYPE_IN7  15
#define OP_TYPE_IN8  16
#define OP_TYPE_IN9  17

#define OP_TYPE_POST1  18
#define OP_TYPE_POST2  19
#define OP_TYPE_POST3  20
#define OP_TYPE_POST4  21
#define OP_TYPE_POST5  22
#define OP_TYPE_POST6  23
#define OP_TYPE_POST7  24
#define OP_TYPE_POST8  25
#define OP_TYPE_POST9  26

#define LAYER_TAG   "LAYER_ID"

const static int  OP_SYM_TYPE_TBL[OP_SIG_COUNT][OP_TYPE_COUNT] =
{
   {TOK_P1FPRE, TOK_P2FPRE, TOK_P3FPRE, TOK_P4FPRE, TOK_P5FPRE, TOK_P6FPRE, TOK_P7FPRE, TOK_P8FPRE, TOK_P9FPRE,
    TOK_P1FIN, TOK_P2FIN, TOK_P3FIN, TOK_P4FIN, TOK_P5FIN, TOK_P6FIN, TOK_P7FIN, TOK_P8FIN, TOK_P9FIN,
    TOK_P1FPOST, TOK_P2FPOST, TOK_P3FPOST, TOK_P4FPOST, TOK_P5FPOST, TOK_P6FPOST, TOK_P7FPOST, TOK_P8FPOST, TOK_P9FPOST},
   {TOK_P1RPRE, TOK_P2RPRE, TOK_P3RPRE, TOK_P4RPRE, TOK_P5RPRE, TOK_P6RPRE, TOK_P7RPRE, TOK_P8RPRE, TOK_P9RPRE,
    TOK_P1RIN, TOK_P2RIN, TOK_P3RIN, TOK_P4RIN, TOK_P5RIN, TOK_P6RIN, TOK_P7RIN, TOK_P8RIN, TOK_P9RIN,
    TOK_P1RPOST, TOK_P2RPOST, TOK_P3RPOST, TOK_P4RPOST, TOK_P5RPOST, TOK_P6RPOST, TOK_P7RPOST, TOK_P8RPOST, TOK_P9RPOST}
};

const static INT8 *TYPE_STR_TBL[8] =
{
   "SCHEMA_TYPE", "SCHEMA_ENTRY_TYPE", "BASIC_TYPE", "GEN_TYPE", "SET_TYPE", "TUPLE_TYPE", "NULL_TYPE", "ERR_TYPE"
};

static struct option options[] =
{
   {"importpath", 1, 0, 'I'},
   {"outfile", 1, 0, 'o'},
   {"tabgroup", 1, 0, 't'},
   {"indent", 1, 0, 'i'},
   {"dotfile", 1, 0, 'd'},
   {"dottype", 0, 0, 'D'},
   {"xmlfile", 1, 0, 'x'},
   {"layers", 1, 0, 'L'},
   {"exclude", 1, 0, 'X'},
   {"help", 0, 0, 'h'},
   {0, 0, 0, 0}
};


static UINT32 strHash(INT8 *key);
static UINT8 addSymObjToTable(SymbolList *tablePtr, Symbol *inSym);

#if 0
static UINT8 freeSymTable(SymbolList *table);
static void freeSymList(SymbolList *list);
#endif

static LinkList *declDecor(DecorType pre, UINT8 preCnt, DecorType post, UINT8 postCnt,
                           DeclarationNode *decl, LinkList *subList);

/* These functions are used to initialize the syntax tree and symbol table with built-in types.
   If this list grows long, it would be best to pack function pointers into an array and iterate them.
   For now, they shall be called directly */
static void initInt();
static void initSet();
static void initSeq();
static void initRel();
static void initString();
static void initProc();

static void initInt()
{
   DEBUG("initInt(): Called . . .\n");

   {
      DEBUG("initInt(): Adding int . . .\n");

      SyntaxTree  *ast = (SyntaxTree *) createBasicDefNode(NULL, createLinkList(createBasicEntryNode(NULL, "int")), NULL);

      ast->treeType = createSetTreeType(createBasicTreeType("int"));

      addSymToTable("int", TOK_DATA_TYPE, ast);
      addOzXfm("int", "\\num");
   }

   {
      DEBUG("initInt(): Adding + . . .\n");

      SyntaxTree  *ast       = (SyntaxTree *) createDeclarationNode(NULL, EXPR_OP_IN_DECL, "+", NULL);
      LinkList    *inList    = createLinkList(createBasicTreeType("int"));
      LinkList    *tupleList = NULL;
      TreeType    *inTuple   = (TreeType *) createTupleTreeType(NULL, 0);
      TreeType    *out       = (TreeType *) createBasicTreeType("int");
      TreeType    *tupleType = (TreeType *) createTupleTreeType(NULL, 0);

      appendLinkList(inList, createBasicTreeType("int"));

      tupleList = createLinkList(inTuple);

      appendLinkList(tupleList, out);

      ((TupleType *) inTuple)->typeList   = inList;
      ((TupleType *) tupleType)->typeList = tupleList;

      ast->treeType = createSetTreeType(tupleType);

      addSymToTable("+", TOK_PLUS, ast);
   }

   {
      DEBUG("initInt(): Adding - . . .\n");

      SyntaxTree  *ast       = (SyntaxTree *) createDeclarationNode(NULL, EXPR_OP_IN_DECL, "-", NULL);
      LinkList    *inList    = createLinkList(createBasicTreeType("int"));
      LinkList    *tupleList = NULL;
      TreeType    *inTuple   = (TreeType *) createTupleTreeType(NULL, 0);
      TreeType    *out       = (TreeType *) createBasicTreeType("int");
      TreeType    *tupleType = (TreeType *) createTupleTreeType(NULL, 0);

      appendLinkList(inList, createBasicTreeType("int"));

      tupleList = createLinkList(inTuple);

      appendLinkList(tupleList, out);

      ((TupleType *) inTuple)->typeList   = inList;
      ((TupleType *) tupleType)->typeList = tupleList;

      ast->treeType = createSetTreeType(tupleType);

      addSymToTable("-", TOK_MINUS, ast);
   }

   {
      DEBUG("initInt(): Adding ^ . . .\n");

      SyntaxTree  *ast       = (SyntaxTree *) createDeclarationNode(NULL, EXPR_OP_IN_DECL, "^", NULL);
      LinkList    *inList    = createLinkList(createBasicTreeType("int"));
      LinkList    *tupleList = NULL;
      TreeType    *inTuple   = (TreeType *) createTupleTreeType(NULL, 0);
      TreeType    *out       = (TreeType *) createBasicTreeType("int");
      TreeType    *tupleType = (TreeType *) createTupleTreeType(NULL, 0);

      appendLinkList(inList, createBasicTreeType("int"));

      tupleList = createLinkList(inTuple);

      appendLinkList(tupleList, out);

      ((TupleType *) inTuple)->typeList   = inList;
      ((TupleType *) tupleType)->typeList = tupleList;

      ast->treeType = createSetTreeType(tupleType);

      addSymToTable("^", TOK_EXPON, ast);
   }

   {
      DEBUG("initInt(): Adding * . . .\n");

      SyntaxTree  *ast       = (SyntaxTree *) createDeclarationNode(NULL, EXPR_OP_IN_DECL, "*", NULL);
      LinkList    *inList    = createLinkList(createBasicTreeType("int"));
      LinkList    *tupleList = NULL;
      TreeType    *inTuple   = (TreeType *) createTupleTreeType(NULL, 0);
      TreeType    *out       = (TreeType *) createBasicTreeType("int");
      TreeType    *tupleType = (TreeType *) createTupleTreeType(NULL, 0);

      appendLinkList(inList, createBasicTreeType("int"));

      tupleList = createLinkList(inTuple);

      appendLinkList(tupleList, out);

      ((TupleType *) inTuple)->typeList   = inList;
      ((TupleType *) tupleType)->typeList = tupleList;

      ast->treeType = createSetTreeType(tupleType);

      addSymToTable("*", TOK_MULT, ast);
   }

   {
      DEBUG("initInt(): Adding div . . .\n");

      SyntaxTree  *ast       = (SyntaxTree *) createDeclarationNode(NULL, EXPR_OP_IN_DECL, "div", NULL);
      LinkList    *inList    = createLinkList(createBasicTreeType("int"));
      LinkList    *tupleList = NULL;
      TreeType    *inTuple   = (TreeType *) createTupleTreeType(NULL, 0);
      TreeType    *out       = (TreeType *) createBasicTreeType("int");
      TreeType    *tupleType = (TreeType *) createTupleTreeType(NULL, 0);

      appendLinkList(inList, createBasicTreeType("int"));

      tupleList = createLinkList(inTuple);

      appendLinkList(tupleList, out);

      ((TupleType *) inTuple)->typeList   = inList;
      ((TupleType *) tupleType)->typeList = tupleList;

      ast->treeType = createSetTreeType(tupleType);

      addSymToTable("div", TOK_P6FIN, ast);
      addOzXfm("div", "\\div");
   }

   {
      DEBUG("initInt(): Adding mod . . .\n");

      SyntaxTree  *ast       = (SyntaxTree *) createDeclarationNode(NULL, EXPR_OP_IN_DECL, "mod", NULL);
      LinkList    *inList    = createLinkList(createBasicTreeType("int"));
      LinkList    *tupleList = NULL;
      TreeType    *inTuple   = (TreeType *) createTupleTreeType(NULL, 0);
      TreeType    *out       = (TreeType *) createBasicTreeType("int");
      TreeType    *tupleType = (TreeType *) createTupleTreeType(NULL, 0);

      appendLinkList(inList, createBasicTreeType("int"));

      tupleList = createLinkList(inTuple);

      appendLinkList(tupleList, out);

      ((TupleType *) inTuple)->typeList   = inList;
      ((TupleType *) tupleType)->typeList = tupleList;

      ast->treeType = createSetTreeType(tupleType);

      addSymToTable("mod", TOK_P6FIN, ast);
      addOzXfm("mod", "\\mod");
   }

   {
      DEBUG("initInt(): Adding < . . .\n");

      SyntaxTree  *ast       = (SyntaxTree *) createDeclarationNode(NULL, REL_OP_IN_DECL, "<", NULL);
      LinkList    *inList    = createLinkList(createBasicTreeType("int"));
      TreeType    *inTuple   = (TreeType *) createTupleTreeType(NULL, 0);

      appendLinkList(inList, createBasicTreeType("int"));

      ((TupleType *) inTuple)->typeList   = inList;

      ast->treeType = createSetTreeType(inTuple);

      addSymToTable("<", TOK_P4RIN, ast);
   }

   {
      DEBUG("initInt(): Adding > . . .\n");

      SyntaxTree  *ast       = (SyntaxTree *) createDeclarationNode(NULL, REL_OP_IN_DECL, ">", NULL);
      LinkList    *inList    = createLinkList(createBasicTreeType("int"));
      TreeType    *inTuple   = (TreeType *) createTupleTreeType(NULL, 0);

      appendLinkList(inList, createBasicTreeType("int"));

      ((TupleType *) inTuple)->typeList   = inList;

      ast->treeType = createSetTreeType(inTuple);

      addSymToTable(">", TOK_P4RIN, ast);
   }

   {
      DEBUG("initInt(): Adding >= . . .\n");

      SyntaxTree  *ast       = (SyntaxTree *) createDeclarationNode(NULL, REL_OP_IN_DECL, ">=", NULL);
      LinkList    *inList    = createLinkList(createBasicTreeType("int"));
      TreeType    *inTuple   = (TreeType *) createTupleTreeType(NULL, 0);

      appendLinkList(inList, createBasicTreeType("int"));

      ((TupleType *) inTuple)->typeList   = inList;

      ast->treeType = createSetTreeType(inTuple);

      addSymToTable(">=", TOK_P4RIN, ast);
      addOzXfm(">=", "\\geq");
   }

   {
      DEBUG("initInt(): Adding <= . . .\n");

      SyntaxTree  *ast       = (SyntaxTree *) createDeclarationNode(NULL, REL_OP_IN_DECL, "<=", NULL);
      LinkList    *inList    = createLinkList(createBasicTreeType("int"));
      TreeType    *inTuple   = (TreeType *) createTupleTreeType(NULL, 0);

      appendLinkList(inList, createBasicTreeType("int"));

      ((TupleType *) inTuple)->typeList   = inList;

      ast->treeType = createSetTreeType(inTuple);

      addSymToTable("<=", TOK_P4RIN, ast);
      addOzXfm("<=", "\\leq");
   }

   DEBUG("initInt(): done\n");
}

static void initSet()
{
   DEBUG("initSet(): Called . . .\n");

   {
      DEBUG("initSet(): Adding set . . .\n");

      SyntaxTree  *ast = (SyntaxTree *) createGenTypeEntryNode("pset", NULL, NULL, "*");

      ast->treeType = createSetTreeType(createSetTreeType(createGenTreeType("*")));

      addSymToTable("pset", TOK_GEN_TYPE, ast);
      addOzXfm("pset", "\\pset");
   }

   {
      DEBUG("initSet(): Adding in . . .\n");

      SyntaxTree  *ast       = (SyntaxTree *) createDeclarationNode(NULL, REL_OP_IN_DECL, "in", NULL);
      LinkList    *inList    = createLinkList(createGenTreeType("*"));
      TreeType    *inTuple   = (TreeType *) createTupleTreeType(NULL, 0);

      appendLinkList(inList, createSetTreeType(createGenTreeType("*")));

      ((TupleType *) inTuple)->typeList   = inList;

      ast->treeType = createSetTreeType(inTuple);

      addSymToTable("in", TOK_P4RIN, ast);
      addOzXfm("in", "\\in");
   }

   {
      DEBUG("initSet(): Adding !in . . .\n");

      SyntaxTree  *ast       = (SyntaxTree *) createDeclarationNode(NULL, REL_OP_IN_DECL, "!in", NULL);
      LinkList    *inList    = createLinkList(createGenTreeType("*"));
      TreeType    *inTuple   = (TreeType *) createTupleTreeType(NULL, 0);

      appendLinkList(inList, createSetTreeType(createGenTreeType("*")));

      ((TupleType *) inTuple)->typeList   = inList;

      ast->treeType = createSetTreeType(inTuple);

      addSymToTable("!in", TOK_P4RIN, ast);
      addOzXfm("!in", "\\notin");
   }

   DEBUG("initSet(): done\n");
}

static void initSeq()
{
   DEBUG("initSeq(): Called . . .\n");

   {
      DEBUG("initSeq(): Adding seq . . .\n");

      SyntaxTree  *ast       = (SyntaxTree *) createGenTypeEntryNode("seq", NULL, NULL, "*");
      TreeType    *first     = (TreeType *) createBasicTreeType("int");
      TreeType    *second    = (TreeType *) createGenTreeType("*");
      LinkList    *tupleList = createLinkList(first);
      TreeType    *tuple     = (TreeType *) createTupleTreeType(NULL, 0);

      appendLinkList(tupleList, second);

      ((TupleType *) tuple)->typeList = tupleList;

      ast->treeType = createSetTreeType(createSetTreeType(tuple));

      addSymToTable("seq", TOK_GEN_TYPE, ast);
      addOzXfm("seq", "\\seq");
   }

   DEBUG("initSeq(): done\n");
}

static void initRel()
{
   DEBUG("initRel(): Called . . .\n");

   {
      DEBUG("initRel(): Adding = . . .\n");

      SyntaxTree  *ast       = (SyntaxTree *) createDeclarationNode(NULL, REL_OP_IN_DECL, "=", NULL);
      LinkList    *inList    = createLinkList(createGenTreeType("*"));
      TreeType    *inTuple   = (TreeType *) createTupleTreeType(NULL, 0);

      appendLinkList(inList, createGenTreeType("*"));

      ((TupleType *) inTuple)->typeList   = inList;

      ast->treeType = createSetTreeType(inTuple);

      addSymToTable("=", TOK_P4RIN, ast);
   }

   {
      DEBUG("initRel(): Adding != . . .\n");

      SyntaxTree  *ast       = (SyntaxTree *) createDeclarationNode(NULL, REL_OP_IN_DECL, "!=", NULL);
      LinkList    *inList    = createLinkList(createGenTreeType("*"));
      TreeType    *inTuple   = (TreeType *) createTupleTreeType(NULL, 0);

      appendLinkList(inList, createGenTreeType("*"));

      ((TupleType *) inTuple)->typeList   = inList;

      ast->treeType = createSetTreeType(inTuple);

      addSymToTable("!=", TOK_P4RIN, ast);
      addOzXfm("!=", "\\neq");
   }

   DEBUG("initRel(): done\n");
}

static void initString()
{
   DEBUG("initString(): Called . . .\n");

   {
      DEBUG("initString(): Adding char . . .\n");

      SyntaxTree  *ast = (SyntaxTree *) createBasicDefNode(NULL, createLinkList(createBasicEntryNode(NULL, "char")), NULL);

      ast->treeType = createSetTreeType(createBasicTreeType("char"));

      addSymToTable("char", TOK_DATA_TYPE, ast);
   }

   {
      DEBUG("initString(): Adding string . . .\n");

      SyntaxTree  *ast       = (SyntaxTree *) createTypeEntryNode("string", NULL);
      TreeType    *first     = (TreeType *) createBasicTreeType("int");
      TreeType    *second    = (TreeType *) createBasicTreeType("char");
      LinkList    *tupleList = createLinkList(first);
      TreeType    *tuple     = (TreeType *) createTupleTreeType(NULL, 0);

      appendLinkList(tupleList, second);

      ((TupleType *) tuple)->typeList = tupleList;

      ast->treeType = createSetTreeType(createSetTreeType(tuple));

      addSymToTable("string", TOK_DATA_TYPE, ast);
   }
}

static void initProc()
{
   DEBUG("initProc(): Called . . .\n");

   {
      DEBUG("initProc(): Adding PROCESS . . .\n");

      SyntaxTree  *ast = (SyntaxTree *) createBasicDefNode(NULL, createLinkList(createBasicEntryNode(NULL, "PROCESS")),
                                                           NULL);

      ast->treeType = createSetTreeType(createBasicTreeType("PROCESS"));

      addSymToTable("PROCESS", TOK_DATA_TYPE, ast);
   }

   {
      DEBUG("initProc(): Adding CSP_EVENT . . .\n");

      SyntaxTree  *ast = (SyntaxTree *) createBasicDefNode(NULL, createLinkList(createBasicEntryNode(NULL, "CSP_EVENT")),
                                                           NULL);

      ast->treeType = createSetTreeType(createBasicTreeType("CSP_EVENT"));

      addSymToTable("CSP_EVENT", TOK_DATA_TYPE, ast);
   }

   {
      DEBUG("initProc(): Adding -> . . .\n");

      SyntaxTree  *ast       = (SyntaxTree *) createDeclarationNode(NULL, EXPR_OP_IN_DECL, "->", NULL);
      LinkList    *inList    = createLinkList(createBasicTreeType("CSP_EVENT"));
      LinkList    *tupleList = NULL;
      TreeType    *inTuple   = (TreeType *) createTupleTreeType(NULL, 0);
      TreeType    *out       = (TreeType *) createBasicTreeType("PROCESS");
      TreeType    *tupleType = (TreeType *) createTupleTreeType(NULL, 0);

      appendLinkList(inList, createBasicTreeType("PROCESS"));

      tupleList = createLinkList(inTuple);

      appendLinkList(tupleList, out);

      ((TupleType *) inTuple)->typeList   = inList;
      ((TupleType *) tupleType)->typeList = tupleList;

      ast->treeType = createSetTreeType(tupleType);

      addSymToTable("->", TOK_PTHEN, ast);
      addOzXfm("->", "\\pthen");
   }

   {
      DEBUG("initProc(): Adding |~| . . .\n");

      SyntaxTree  *ast       = (SyntaxTree *) createDeclarationNode(NULL, EXPR_OP_IN_DECL, "|~|", NULL);
      LinkList    *inList    = createLinkList(createBasicTreeType("PROCESS"));
      LinkList    *tupleList = NULL;
      TreeType    *inTuple   = (TreeType *) createTupleTreeType(NULL, 0);
      TreeType    *out       = (TreeType *) createBasicTreeType("PROCESS");
      TreeType    *tupleType = (TreeType *) createTupleTreeType(NULL, 0);

      appendLinkList(inList, createBasicTreeType("PROCESS"));

      tupleList = createLinkList(inTuple);

      appendLinkList(tupleList, out);

      ((TupleType *) inTuple)->typeList   = inList;
      ((TupleType *) tupleType)->typeList = tupleList;

      ast->treeType = createSetTreeType(tupleType);

      addSymToTable("|~|", TOK_INTERNAL, ast);
      addOzXfm("|~|", "\\sqcap");
   }

   {
      DEBUG("initProc(): Adding [] . . .\n");

      SyntaxTree  *ast       = (SyntaxTree *) createDeclarationNode(NULL, EXPR_OP_IN_DECL, "[]", NULL);
      LinkList    *inList    = createLinkList(createBasicTreeType("PROCESS"));
      LinkList    *tupleList = NULL;
      TreeType    *inTuple   = (TreeType *) createTupleTreeType(NULL, 0);
      TreeType    *out       = (TreeType *) createBasicTreeType("PROCESS");
      TreeType    *tupleType = (TreeType *) createTupleTreeType(NULL, 0);

      appendLinkList(inList, createBasicTreeType("PROCESS"));

      tupleList = createLinkList(inTuple);

      appendLinkList(tupleList, out);

      ((TupleType *) inTuple)->typeList   = inList;
      ((TupleType *) tupleType)->typeList = tupleList;

      ast->treeType = createSetTreeType(tupleType);

      addSymToTable("[]", TOK_EXTERNAL, ast);
      addOzXfm("[]", "\\Box");
   }

   {
      DEBUG("initProc(): Adding pseq . . .\n");

      SyntaxTree  *ast       = (SyntaxTree *) createDeclarationNode(NULL, EXPR_OP_IN_DECL, "pseq", NULL);
      LinkList    *inList    = createLinkList(createBasicTreeType("PROCESS"));
      LinkList    *tupleList = NULL;
      TreeType    *inTuple   = (TreeType *) createTupleTreeType(NULL, 0);
      TreeType    *out       = (TreeType *) createBasicTreeType("PROCESS");
      TreeType    *tupleType = (TreeType *) createTupleTreeType(NULL, 0);

      appendLinkList(inList, createBasicTreeType("PROCESS"));

      tupleList = createLinkList(inTuple);

      appendLinkList(tupleList, out);

      ((TupleType *) inTuple)->typeList   = inList;
      ((TupleType *) tupleType)->typeList = tupleList;

      ast->treeType = createSetTreeType(tupleType);

      addSymToTable("pseq", TOK_PSEQ, ast);
      addOzXfm("pseq", "\\comp");
   }

   {
      DEBUG("initProc(): Adding || . . .\n");

      SyntaxTree  *ast       = (SyntaxTree *) createDeclarationNode(NULL, EXPR_OP_IN_DECL, "||", NULL);
      LinkList    *inList    = createLinkList(createBasicTreeType("PROCESS"));
      LinkList    *tupleList = NULL;
      TreeType    *inTuple   = (TreeType *) createTupleTreeType(NULL, 0);
      TreeType    *out       = (TreeType *) createBasicTreeType("PROCESS");
      TreeType    *tupleType = (TreeType *) createTupleTreeType(NULL, 0);

      appendLinkList(inList, createBasicTreeType("PROCESS"));

      tupleList = createLinkList(inTuple);

      appendLinkList(tupleList, out);

      ((TupleType *) inTuple)->typeList   = inList;
      ((TupleType *) tupleType)->typeList = tupleList;

      ast->treeType = createSetTreeType(tupleType);

      addSymToTable("||", TOK_PARALLEL, ast);
      addOzXfm("||", "\\parallel");
   }

   {
      DEBUG("initProc(): Adding [||] . . .\n");

      SyntaxTree  *ast       = (SyntaxTree *) createDeclarationNode(NULL, EXPR_OP_IN_DECL, "[||]", NULL);
      LinkList    *inList    = createLinkList(createBasicTreeType("PROCESS"));
      LinkList    *tupleList = NULL;
      TreeType    *inTuple   = (TreeType *) createTupleTreeType(NULL, 0);
      TreeType    *out       = (TreeType *) createBasicTreeType("PROCESS");
      TreeType    *tupleType = (TreeType *) createTupleTreeType(NULL, 0);

      appendLinkList(inList, createBasicTreeType("PROCESS"));

      tupleList = createLinkList(inTuple);

      appendLinkList(tupleList, out);

      ((TupleType *) inTuple)->typeList   = inList;
      ((TupleType *) tupleType)->typeList = tupleList;

      ast->treeType = createSetTreeType(tupleType);

      addSymToTable("[||]", TOK_IF_PARALLEL, ast);
      addOzXfm("[||]", "\\ifpar");
   }

   {
      DEBUG("initProc(): Adding ||| . . .\n");

      SyntaxTree  *ast       = (SyntaxTree *) createDeclarationNode(NULL, EXPR_OP_IN_DECL, "|||", NULL);
      LinkList    *inList    = createLinkList(createBasicTreeType("PROCESS"));
      LinkList    *tupleList = NULL;
      TreeType    *inTuple   = (TreeType *) createTupleTreeType(NULL, 0);
      TreeType    *out       = (TreeType *) createBasicTreeType("PROCESS");
      TreeType    *tupleType = (TreeType *) createTupleTreeType(NULL, 0);

      appendLinkList(inList, createBasicTreeType("PROCESS"));

      tupleList = createLinkList(inTuple);

      appendLinkList(tupleList, out);

      ((TupleType *) inTuple)->typeList   = inList;
      ((TupleType *) tupleType)->typeList = tupleList;

      ast->treeType = createSetTreeType(tupleType);

      addSymToTable("|||", TOK_INTERLEAVE, ast);
      addOzXfm("|||", "\\interleave");
   }

   {
      DEBUG("initProc(): Adding /\\ . . .\n");

      SyntaxTree  *ast       = (SyntaxTree *) createDeclarationNode(NULL, EXPR_OP_IN_DECL, "/\\", NULL);
      LinkList    *inList    = createLinkList(createBasicTreeType("PROCESS"));
      LinkList    *tupleList = NULL;
      TreeType    *inTuple   = (TreeType *) createTupleTreeType(NULL, 0);
      TreeType    *out       = (TreeType *) createBasicTreeType("PROCESS");
      TreeType    *tupleType = (TreeType *) createTupleTreeType(NULL, 0);

      appendLinkList(inList, createBasicTreeType("PROCESS"));

      tupleList = createLinkList(inTuple);

      appendLinkList(tupleList, out);

      ((TupleType *) inTuple)->typeList   = inList;
      ((TupleType *) tupleType)->typeList = tupleList;

      ast->treeType = createSetTreeType(tupleType);

      addSymToTable("/\\", TOK_INTERRUPT, ast);
      addOzXfm("/\\", "\\triangle");
   }

   {
      DEBUG("initProc(): Adding phide . . .\n");

      SyntaxTree  *ast       = (SyntaxTree *) createDeclarationNode(NULL, EXPR_OP_IN_DECL, "phide", NULL);
      LinkList    *inList    = createLinkList(createBasicTreeType("PROCESS"));
      LinkList    *tupleList = NULL;
      TreeType    *inTuple   = (TreeType *) createTupleTreeType(NULL, 0);
      TreeType    *out       = (TreeType *) createBasicTreeType("PROCESS");
      TreeType    *tupleType = (TreeType *) createTupleTreeType(NULL, 0);

      appendLinkList(inList, createSetTreeType(createBasicTreeType("CSP_EVENT")));

      tupleList = createLinkList(inTuple);

      appendLinkList(tupleList, out);

      ((TupleType *) inTuple)->typeList   = inList;
      ((TupleType *) tupleType)->typeList = tupleList;

      ast->treeType = createSetTreeType(tupleType);

      addSymToTable("phide", TOK_PHIDE, ast);
      addOzXfm("phide", "\\phide");
   }
}

UINT8 initSymStack()
{
   symStack = malloc(sizeof(SymListStack));

   if(symStack == NULL)
   {
      yyuerror("Unable to malloc symbol stack");

      exit(-1);
   }

   symStack->prev        = NULL;
   symStack->current     = malloc(SYM_TABLE_SIZE * sizeof(SymbolList));
   symStack->currentSize = 0;
   symStack->globalDecl  = 0;

   if(symStack->current == NULL)
   {
      yyuerror("Unable to initialize top-level symbol table");

      exit(-1);
   }

   memset(symStack->current, 0, SYM_TABLE_SIZE * sizeof(SymbolList));

   globalTable = symStack->current;

   initInt();
   initSet();
   initSeq();
   initRel();
   initString();
   initProc();

   return 1;
}

static void callErrorFunc(void (*errFunc)(const char *fmt, ...), const char *fmt, ...)
{
   va_list  argList;

   errors = errors + 1;

   va_start(argList, fmt);

   if(errFunc != NULL)
   {
      (*errFunc)(fmt, argList);
   }
   else
   {
      yyuerror(fmt, argList);
   }
}

UINT8 pushSymStack(UINT8 globalDecl, void (*errFunc)(const char *, ...))
{
   SymListStack  *newHead = malloc(sizeof(SymListStack));

   if(newHead == NULL)
   {
      callErrorFunc(errFunc, "Unable to malloc new symbol stack");

      exit(-1);
   }

   newHead->prev        = symStack;
   newHead->current     = malloc(SYM_TABLE_SIZE * sizeof(SymbolList));
   newHead->currentSize = 0;
   newHead->globalDecl  = globalDecl;

   if(newHead->current == NULL)
   {
      callErrorFunc(errFunc, "Unable to malloc new symbol table");

      exit(-1);
   }

   memset(newHead->current, 0, SYM_TABLE_SIZE * sizeof(SymbolList));

   symStack = newHead;

   DEBUG("pushSymStack(): Completed . . .\n");

   if(symStackList == NULL)
   {
      symStackList = createLinkList(newHead);
   }
   else
   {
      appendLinkList(symStackList, newHead);
   }

   return 1;
}

/* Can be improved by checking symStack->currentSize before clearing */
UINT8 popSymStack()
{
   if(symStack->prev != NULL)
   {
      SymListStack  *prev = symStack->prev;

      symStack = prev;

      DEBUG("popSymStack(): Completed . . .\n");

      return 1;
   }
   else
   {
      return 0;
   }
}

static UINT32 strHash(INT8 *key)
{
   UINT32  hash = 0;
   UINT8   byte = *key;

   while(byte > 0)
   {
      hash = (hash * 9) ^ byte;
      key  = key + 1;
      byte = *key;
   }

   return hash;
}

UINT8 addSymToTable(INT8 *symName, int symType, SyntaxTree *syn)
{
   if(symStack->globalDecl == 1)
   {
      return addSymToGlobal(symName, symType, syn);
   }
   else
   {
      return addSymToLocal(symName, symType, syn);
   }

   return 0;
}

UINT8 addSymToLocal(INT8 *symName, int symType, SyntaxTree *syn)
{
   Symbol  *symObj;

   if(symName == NULL)
   {
      yyuerror("addSymToLocal(): Unable to add a NULL symbol name");

      exit(-1);
   }

   DEBUG("addSymToLocal(%s, %d): Called . . .\n", symName, symType);

   if((symStack == NULL) || (symStack->current == NULL))
   {
      yyuerror("addSymToLocal(): Cannot add symbol to NULL table");

      exit(-1);
   }

   symObj = malloc(sizeof(Symbol));

   memset(symObj, 0, sizeof(Symbol));

   if(symObj == NULL)
   {
      yyuerror("addSymToLocal(): Unable to malloc symbol");

      exit(-1);
   }

   symObj->symName = strdup(symName);
   symObj->symType = symType;
   symObj->synTree = syn;

   if(!addSymObjToTable(symStack->current, symObj))
   {
      yyuerror("addSymToLocal(): addSymObjToTable failed");

      exit(-1);
   }

   return 1;
}

UINT8 addSymToGlobal(INT8 *symName, int symType, SyntaxTree *syn)
{
   Symbol  *symObj;

   if(symName == NULL)
   {
      yyuerror("addSymToGlobal(): Unable to add a NULL symbol name");

      exit(-1);
   }

   DEBUG("addSymToGlobal(%s, %d): Called . . .\n", symName, symType);

   if(globalTable == NULL)
   {
      yyuerror("addSymToGlobal(): Cannot add symbol to NULL table");

      exit(-1);
   }

   symObj = malloc(sizeof(Symbol));

   memset(symObj, 0, sizeof(Symbol));

   if(symObj == NULL)
   {
      yyuerror("addSymToGlobal(): Unable to malloc symbol");

      exit(-1);
   }

   symObj->symName = strdup(symName);
   symObj->symType = symType;
   symObj->synTree = syn;

   if(!addSymObjToTable(globalTable, symObj))
   {
      yyuerror("addSymToGlobal(): addSymObjToTable failed");

      exit(-1);
   }

   return 1;
}

static UINT8 addSymObjToTable(SymbolList *tablePtr, Symbol *inSym)
{
   SymbolList  *list;
   SymbolList  *remain;
   Symbol      *symObj;
   UINT32      symIdx;

   if(inSym == NULL)
   {
      yyuerror("addSymObjToTable(): inSym == NULL");

      exit(-1);
   }

   if(inSym->symName == NULL)
   {
      yyuerror("addSymObjToTable(): symName == NULL");

      exit(-1);
   }

   if(inSym->symType < MIN_SYM_TYPE_NUM)
   {
      yyuerror("addSymObjToTable(): symType < MIN_SYM_TYPE_NUM)");

      exit(-1);
   }

   DEBUG("addSymObjToTable(%s, %d): Called . . .\n", inSym->symName, inSym->symType);

   symIdx  = strHash(inSym->symName) % SYM_TABLE_SIZE;
   list    = &(tablePtr[symIdx]);
   remain  = list;
   symObj  = remain->symbol;

   while(symObj != NULL)
   {
      DEBUG("symObj != NULL\n");

      if(strcmp(inSym->symName, symObj->symName) == 0)
      {
         /* Symbol already exists.  This should not happen since the parser
            will only add a symbol if it is unknown.  Therefore, we shall
            return failure */
         yyuerror("Symbol %s already exists", inSym->symName);

         return 0;
      }
      else if(remain->next == NULL)
      {
         remain->next = malloc(sizeof(SymbolList));

         if(remain->next == NULL)
         {
            yyuerror("addSymObjToTable(): malloc");

            exit(-1);
         }

         memset(remain->next, 0, sizeof(SymbolList));
      }

      remain = remain->next;
      symObj = remain->symbol;
   }

   remain->symbol = inSym;

   return 1;
}

Symbol *lookup(SymbolList *tablePtr, INT8 *symName)
{
   SymbolList  *list;
   SymbolList  *remain;
   UINT32      symIdx;
   Symbol      *symObj;

   if(symName == NULL)
   {
      yyuerror("lookup(): Received NULL symName");

      exit(-1);
   }

   symIdx  = strHash(symName) % SYM_TABLE_SIZE;
   list    = &(tablePtr[symIdx]);
   remain  = list;
   symObj  = remain->symbol;

   while(symObj != NULL)
   {
      if(strcmp(symName, symObj->symName) == 0)
      {
         return symObj;
      }
      else if(remain->next == NULL)
      {
         /* End of the list with no match */
         remain = NULL;
         symObj = NULL;
      }
      else
      {
         remain = remain->next;
         symObj = remain->symbol;
      }
   }

   return NULL;
}

Symbol *symLookup(INT8 *symName, void (*errFunc)(const char *fmt, ...))
{
   SymListStack  *idxStack = symStack;
   Symbol        *retVal   = NULL;

   if(symName == NULL)
   {
      callErrorFunc(errFunc, "symLookup(): Received NULL symName");

      exit(-1);
   }

   DEBUG("symLookup(%s): Called . . .\n", symName);

   while((retVal == NULL) && (idxStack != NULL))
   {
      if(idxStack->current == NULL)
      {
         callErrorFunc(errFunc, "symLookup(): Encountered a NULL symbol table");

         exit(-1);
      }

      retVal = lookup(idxStack->current, symName);

      idxStack = idxStack->prev;
   }

   if(retVal != NULL)
   {
      DEBUG("symLookup(%s): Symbol found\n", symName);

      if((retVal->synTree != NULL) && (retVal->synTree->treeType != NULL))
      {
         printType(symName, retVal->synTree->treeType);
      }
   }

   return retVal;
}

#if 0
static UINT8 freeSymTable(SymbolList *table)
{
   SymbolList  *list;
   UINT32      symIdx;

   for(symIdx = 0; symIdx < SYM_TABLE_SIZE; symIdx++)
   {
      list = &(table[symIdx]);

      freeSymList(list);
   }
}
#endif

void freeSymbol(Symbol *symObj)
{
   if(symObj != NULL)
   {
      if(symObj->symName != NULL)
      {
         free(symObj->symName);

         symObj->symName = NULL;
      }

      free(symObj);
   }
}

#if 0
static void freeSymList(SymbolList *list)
{
   if(list != NULL)
   {
      if(list->next != NULL)
      {
         freeSymList(list->next);
         free(list->next);

         list->next = NULL;
      }

      if(list->symbol != NULL)
      {
         freeSymbol(list->symbol);

         list->symbol = NULL;
      }
   }
}
#endif

int getOpSymType(INT8 *opSig, INT8 *opType)
{
   UINT8  sigNum  = -1;
   UINT8  typeNum = -1;

   DEBUG("opSig = %s, opType = %s\n", opSig, opType);

   if(strcmp(opSig, OPER_STR) == 0)
   {
      sigNum = OP_SIG_OPER;
   }
   else if(strcmp(opSig, REL_STR) == 0)
   {
      sigNum = OP_SIG_REL;
   }
   else
   {
      return -1;
   }

   if(strcmp(opType, PRE1_STR) == 0)
   {
      typeNum = OP_TYPE_PRE1;
   }
   else if(strcmp(opType, PRE2_STR) == 0)
   {
      typeNum = OP_TYPE_PRE2;
   }
   else if(strcmp(opType, PRE3_STR) == 0)
   {
      typeNum = OP_TYPE_PRE3;
   }
   else if(strcmp(opType, PRE4_STR) == 0)
   {
      typeNum = OP_TYPE_PRE4;
   }
   else if(strcmp(opType, PRE5_STR) == 0)
   {
      typeNum = OP_TYPE_PRE5;
   }
   else if(strcmp(opType, PRE6_STR) == 0)
   {
      typeNum = OP_TYPE_PRE6;
   }
   else if(strcmp(opType, PRE7_STR) == 0)
   {
      typeNum = OP_TYPE_PRE7;
   }
   else if(strcmp(opType, PRE8_STR) == 0)
   {
      typeNum = OP_TYPE_PRE8;
   }
   else if(strcmp(opType, PRE9_STR) == 0)
   {
      typeNum = OP_TYPE_PRE9;
   }
   else if(strcmp(opType, IN1_STR) == 0)
   {
      typeNum = OP_TYPE_IN1;
   }
   else if(strcmp(opType, IN2_STR) == 0)
   {
      typeNum = OP_TYPE_IN2;
   }
   else if(strcmp(opType, IN3_STR) == 0)
   {
      typeNum = OP_TYPE_IN3;
   }
   else if(strcmp(opType, IN4_STR) == 0)
   {
      typeNum = OP_TYPE_IN4;
   }
   else if(strcmp(opType, IN5_STR) == 0)
   {
      typeNum = OP_TYPE_IN5;
   }
   else if(strcmp(opType, IN6_STR) == 0)
   {
      typeNum = OP_TYPE_IN6;
   }
   else if(strcmp(opType, IN7_STR) == 0)
   {
      typeNum = OP_TYPE_IN7;
   }
   else if(strcmp(opType, IN8_STR) == 0)
   {
      typeNum = OP_TYPE_IN8;
   }
   else if(strcmp(opType, IN9_STR) == 0)
   {
      typeNum = OP_TYPE_IN9;
   }
   else if(strcmp(opType, POST1_STR) == 0)
   {
      typeNum = OP_TYPE_POST1;
   }
   else if(strcmp(opType, POST2_STR) == 0)
   {
      typeNum = OP_TYPE_POST2;
   }
   else if(strcmp(opType, POST3_STR) == 0)
   {
      typeNum = OP_TYPE_POST3;
   }
   else if(strcmp(opType, POST4_STR) == 0)
   {
      typeNum = OP_TYPE_POST4;
   }
   else if(strcmp(opType, POST5_STR) == 0)
   {
      typeNum = OP_TYPE_POST5;
   }
   else if(strcmp(opType, POST6_STR) == 0)
   {
      typeNum = OP_TYPE_POST6;
   }
   else if(strcmp(opType, POST7_STR) == 0)
   {
      typeNum = OP_TYPE_POST7;
   }
   else if(strcmp(opType, POST8_STR) == 0)
   {
      typeNum = OP_TYPE_POST8;
   }
   else if(strcmp(opType, POST9_STR) == 0)
   {
      typeNum = OP_TYPE_POST9;
   }
   else
   {
      return -1;
   }

   return OP_SYM_TYPE_TBL[sigNum][typeNum];
}

LinkList *createLinkList(void *headObj)
{
   LinkList  *retVal = malloc(sizeof(LinkList));

   DEBUG("%d = createLinkList(): Called . . .\n", (int) retVal);

   if(retVal == NULL)
   {
      return NULL;
   }

   retVal->object = headObj;
   retVal->prev   = NULL;
   retVal->next   = NULL;

   return retVal;
}

LinkList *copyLinkList(LinkList *list)
{
   LinkList  *retList  = NULL;
   LinkList  *curList  = list;
   LinkList  *newList  = NULL;
   LinkList  *prevList = NULL;

   while(curList != NULL)
   {
      newList = createLinkList(curList->object);

      curList = curList->next;

      if(prevList != NULL)
      {
         prevList->next = newList;
      }

      prevList = newList;

      if(retList == NULL)
      {
         retList = newList;
      }
   }

   return retList;
}

LinkList *getListTail(LinkList *list)
{
   if(list == NULL)
   {
      return NULL;
   }
   else if(list->next == NULL)
   {
      return list;
   }
   else
   {
      return getListTail(list->next);
   }
}

UINT8 appendLinkList(LinkList *list, void *nextObj)
{
   LinkList  *current = list;
   LinkList  *new     = NULL;

   DEBUG("appendLinkList(%d): Called . . .\n", (int) list);

   if(list == NULL)
   {
      return 0;
   }

   if(nextObj == NULL)
   {
      return 0;
   }

   while(current->next != NULL)
   {
      current = current->next;
   }

   new = createLinkList(NULL);

   if(new == NULL)
   {
      return 0;
   }

   new->prev   = current;
   new->next   = NULL;
   new->object = nextObj;

   current->next = new;

   return 1;
}

UINT8 conLinkList(LinkList *list, LinkList *newTail)
{
   LinkList  *current = list;

   DEBUG("conLinkList(%d): Called . . .\n", (int) list);

   if(list == NULL)
   {
      return 0;
   }

   if(newTail == NULL)
   {
      return 0;
   }

   while(current->next != NULL)
   {
      current = current->next;
   }

   newTail->prev = current;
   current->next = newTail;

   return 1;
}

UINT32 sizeLinkList(LinkList *list)
{
   if(list == NULL)
   {
      return 0;
   }

   return sizeLinkList(list->next) + 1;
}

void freeLinkList(LinkList *list)
{
   if(list == NULL)
   {
      return;
   }

   if(list->next != NULL)
   {
      freeLinkList(list->next);

      list->next = NULL;
   }

   free(list);
}

UINT8 isInList(void *object, LinkList *list, UINT8 (*cmpFunc)(void *obj1, void *obj2))
{
   if((list == NULL) || (object == NULL) || (cmpFunc == NULL))
   {
      return 0;
   }

   if((list->object != NULL) && ((*cmpFunc)(object, list->object)))
   {
      return 1;
   }
   else
   {
      return isInList(object, list->next, cmpFunc);
   }
}

void initFormat()
{
   fmtSize = 1024;
   curFmt  = malloc(fmtSize);

   clearFormat();
}

void clearFormat()
{
   memset(curFmt, 0, fmtSize);
}

void addFormat(INT8 *addFmt)
{
   INT32  addLen = strlen(addFmt);
   INT32  curLen = strlen(curFmt);

   if((addLen + curLen + 1) > fmtSize)
   {
      fmtSize = addLen + curLen + 1024;

      INT8  *newFmt = malloc(fmtSize);

      memset(newFmt, 0, fmtSize);
      strncpy(newFmt, curFmt, curLen);
      free(curFmt);

      curFmt = newFmt;
   }

   strncpy(&(curFmt[curLen]), addFmt, addLen);
}

UINT8 strEquals(void *str1, void *str2)
{
   return (strcmp(str1, str2) == 0);
}

AToken *createAToken(INT8 *preFmt, INT8 *tokVal)
{
   AToken  *retVal = malloc(sizeof(AToken));

   retVal->preFmt = strdup(preFmt);
   retVal->token  = strdup(tokVal);

   return retVal;
}

void freeAToken(AToken *tok)
{
   if(tok != NULL)
   {
      if(tok->preFmt != NULL)
      {
         free(tok->preFmt);
      }

      if(tok->token != NULL)
      {
         free(tok->token);
      }

      free(tok);
   }
}

static void freeExpandedDecl(DeclarationNode *decl)
{
   VariableNode  *ident = (VariableNode *) decl->ident;

   if(decl->declType != VAR_DECL)
   {
      return;
   }

   freeTypeTree(decl->treeType);
   free(ident->name);
   free(ident);
   free(decl);
}

static void freeExpandedDeclList(LinkList *declList)
{
   if(declList == NULL)
   {
      return;
   }

   if(declList->next != NULL)
   {
      freeExpandedDeclList(declList->next);

      declList->next = NULL;
   }

   DeclarationNode  *decl  = (DeclarationNode *) declList->object;

   freeExpandedDecl(decl);
   free(declList);
}

LinkList *getSchemaDecls(SchemaTypeNode *schType)
{
   /* TBD: For now, schema declarations shall not be copied due to the memory potentially required
      to do this.  Using a reference to the syntax tree is accpetable as long as no freeing of a
      syntax tree is performed.  If tree cleanup is required, each node in a tree should indicate
      if its sub-trees are a deep or shallow copy.  If a deep copy was performed, then the subtrees
      should be freed, otherwise only free the node and return */
   SchemaNode  *schTree;
   Symbol      *schSym;

   if(schType->refName == NULL)
   {
      if(schType->decls == NULL)
      {
         yyuerror("SchemaType has a NULL declaration list");
      }

      return schType->decls;
   }
   else
   {
      schSym = symLookup(schType->refName, &yyuerror);

      if(schSym == NULL)
      {
         yyuerror("Schema %s not found", schType->refName);

         return NULL;
      }
      else
      {
         schTree = (SchemaNode *) schSym->synTree;

         if(schTree == NULL)
         {
            yyuerror("Schema %s has an invalid/incomplete syntax tree", schType->refName);

            return NULL;
         }
         else if((schTree->nodeType == NODE_SCHEMA) || (schTree->nodeType == NODE_GEN_SCH))
         {
            if(schTree->decls == NULL)
            {
               yyuerror("Schema %s has a NULL declaration list", schType->refName);
            }

            return schTree->decls;
         }
         else
         {
            yyuerror("Schema %s has an invalid tree type %d", schType->refName, schTree->nodeType);

            return NULL;
         }
      }
   }
}

static LinkList *declDecor(DecorType pre, UINT8 preCnt, DecorType post, UINT8 postCnt,
                           DeclarationNode *decl, LinkList *subList)
{
   DeclarationNode  *decl2    = NULL;
   VariableNode     *ident    = NULL;
   VariableNode     *ident2   = NULL;
   LinkList         *tmpList  = NULL;
   DecorType        varDecor  = DECOR_NULL;
   DecorType        pre2      = DECOR_NULL;
   UINT8            varCnt    = 0;
   UINT8            preCnt2   = 0;

   if((decl == NULL) || (decl->declType != VAR_DECL))
   {
      yyuerror("declDecor(): declaration is NULL or not a variable declaration");

      return NULL;
   }

   ident    = (VariableNode *) decl->ident;
   varDecor = ident->postDecor;
   varCnt   = ident->postCnt;

   DEBUG("declDecor(): varDecor = %d, varCnt = %d\n", ident->postDecor, ident->postCnt);

   if(post == DECOR_NULL)
   {
      DEBUG("post == NULL\n");

      if((pre == DECOR_NULL) || (preCnt == 0))
      {
         DEBUG("pre == NULL\n");

         ident2 = createVariableNode(strdup(ident->name), NULL);

         ident2->postDecor = ident->postDecor;
         ident2->postCnt   = ident->postCnt;

         decl2 = createDeclarationNode(decl->props, decl->declType, ident2, decl->defExpr);

         decl2->treeType = substituteGen(decl->treeType, subList);

         return createLinkList(decl2);
      }
      else
      {
         if((varDecor != DECOR_NULL) && (varDecor != POST_PRI))
         {
            yyuerror("declDecor(): variable has an incompatible decoration");

            return NULL;
         }

         DEBUG("pre = %d\n", preCnt);

         ident2 = createVariableNode(strdup(ident->name), NULL);

         if(varDecor == DECOR_NULL)
         {
            DEBUG("varDecor == NULL\n");

            ident2->postDecor = POST_PRI;
            ident2->postCnt   = preCnt;
         }
         else if(varDecor == POST_PRI)
         {
            DEBUG("varDecor != NULL\n");

            ident2->postDecor = POST_PRI;
            ident2->postCnt   = varCnt + preCnt;
         }

         pre2    = PRE_DELTA;
         preCnt2 = preCnt - 1;

         /* defExpr should not be copied as the object referenced by defExpr should be freed at the point
            in the AST where the object was created */
         decl2 = createDeclarationNode(decl->props, decl->declType, ident2, decl->defExpr);

         decl2->treeType = substituteGen(decl->treeType, subList);

         tmpList = declDecor(pre2, preCnt2, DECOR_NULL, 0, decl, subList);

         if(appendLinkList(tmpList, decl2) != 1)
         {
            yyuerror("declDecor(): Unable to append declaration list");

            return NULL;
         }

         return tmpList;
      }
   }
   else
   {
      DEBUG("post != NULL\n");

      if((varDecor != DECOR_NULL) && (varDecor != POST_PRI))
      {
         yyuerror("declDecor(): variable has an incompatible decoration");

         return NULL;
      }

      ident2 = createVariableNode(strdup(ident->name), NULL);

      if(varDecor == DECOR_NULL)
      {
         DEBUG("varDecor == NULL\n");

         ident2->postDecor = POST_PRI,
         ident2->postCnt   = postCnt;
      }
      else
      {
         DEBUG("varDecor != NULL\n");

         ident2->postDecor = POST_PRI,
         ident2->postCnt   = varCnt + postCnt;
      }

      /* defExpr should not be copied as the object referenced by defExpr should be freed at the point
         in the AST where the object was created */
      decl2 = createDeclarationNode(decl->props, decl->declType, ident2, decl->defExpr);

      decl2->treeType = substituteGen(decl->treeType, subList);

      tmpList = declDecor(pre, preCnt, DECOR_NULL, 0, decl2, subList);

      freeExpandedDecl(decl2);

      return tmpList;
   }
}

LinkList *expand(DecorType pre, UINT8 preCnt, DecorType post, UINT8 postCnt, LinkList *declList, LinkList *subList)
{
   DeclarationNode  *decl      = NULL;
   SchemaTypeNode   *t         = NULL;
   LinkList         *tail      = NULL;
   LinkList         *retList   = NULL;
   LinkList         *tmpList   = NULL;
   LinkList         *tSubList  = NULL;
   DecorType        tPre       = DECOR_NULL;
   DecorType        tPost      = DECOR_NULL;
   UINT8            tPreCnt    = 0;
   UINT8            tPostCnt   = 0;

   if(declList == NULL)
   {
      yyuerror("expand(): Input list is NULL");

      return NULL;
   }

   decl = (DeclarationNode *) declList->object;
   tail = declList->next;

   if(decl->declType == SCH_REF_DECL)
   {
      t = (SchemaTypeNode *) decl->defExpr;

      tPre      = t->preDecor;
      tPreCnt   = t->preCnt;
      tPost     = t->postDecor;
      tPostCnt  = t->postCnt;
      tSubList  = createGenSchSubList(t);
      tmpList   = expand(tPre, tPreCnt, tPost, tPostCnt, getSchemaDecls(t), tSubList);
      retList   = expand(pre, preCnt, post, postCnt, tmpList, subList);

      freeSubList(tSubList);
      freeExpandedDeclList(tmpList);
   }
   else if(decl->declType == VAR_DECL)
   {
      retList = declDecor(pre, preCnt, post, postCnt, decl, subList);
   }

   if(tail != NULL)
   {
      if(conLinkList(retList, expand(pre, preCnt, post, postCnt, tail, subList)) != 1)
      {
         yyuerror("expand(): Unable to concatenate declaration list");

         return NULL;
      }
   }

   return retList;
}

UINT8 addDeclsToSymTab(LinkList *declList)
{
   DeclarationNode  *decl    = NULL;
   VariableNode     *ident   = NULL;
   LinkList         *current = declList;
   INT8            *varName = NULL;

   DEBUG("addDeclsToSymTab(%d): Called . . .\n", (int) declList);

   if(declList == NULL)
   {
      return 0;
   }

   while(1)
   {
      decl = current->object;

      if((decl == NULL) || (decl->declType != VAR_DECL))
      {
         yyuerror("addDeclsToSymTab(): Encountered invalid declaration");

         return 0;
      }

      ident = (VariableNode *) decl->ident;

      if((ident == NULL) || (ident->name == NULL))
      {
         yyuerror("addDeclsToSymTab(): Encountered declaration with NULL var node");

         return 0;
      }

      varName = varToString(ident);

      if(!addSymToTable(varName, TOK_VAR_BINDING, (SyntaxTree *) decl))
      {
         yyuerror("addDeclsToSymTab(): Unable to add var to symbol table");

         return 0;
      }

      free(varName);

      if(current->next != NULL)
      {
         current = current->next;
      }
      else
      {
         break;
      }
   }

   return 1;
}

LinkList *getProperty(LinkList *props, INT8 *propID)
{
   while(props != NULL)
   {
      PropertyNode  *curProp = (PropertyNode *) props->object;

      if(curProp != NULL)
      {
         LinkList  *propList = curProp->propList;

         if((propList != NULL) && (propList->object != NULL) && (strcmp(propList->object, propID) == 0))
         {
            return propList;
         }
      }

      props = props->next;
   }

   return NULL;
}

INT8 *getLayer(LinkList *props)
{
   LinkList  *propList = getProperty(props, LAYER_TAG);

   if((sizeLinkList(propList) == 2) && (propList->next->object != NULL))
   {
      return propList->next->object;
   }

   return NULL;
}

/* Returns TRUE if layer is NOT excluded */
UINT8 excludeCheck(INT8 *layerID)
{
   INT8  *found = exLayers;

   if((exLayers == NULL) || (strlen(exLayers) == 0))
   {
      return 1;
   }

   if(layerID == NULL)
   {
      layerID = "NULL";
   }

   found = strstr(found, layerID);

   while(found != NULL)
   {
      if(found[strlen(layerID)] == ' ')
      {
         return 0;
      }
      else if(found[strlen(layerID)] == ',')
      {
         return 0;
      }
      else if(found[strlen(layerID)] == '\0')
      {
         return 0;
      }

      found = strstr(&(found[strlen(layerID)]), layerID);
   }

   return 1;
}

UINT8 exportCheck(INT8 *layerID)
{
   INT8  *found = outLayers;

   if((outLayers == NULL) || (strlen(outLayers) == 0))
   {
      return excludeCheck(layerID);
   }

   if(layerID == NULL)
   {
      layerID = "NULL";
   }

   found = strstr(found, layerID);

   while(found != NULL)
   {
      if(found[strlen(layerID)] == ' ')
      {
         return excludeCheck(layerID);
      }
      else if(found[strlen(layerID)] == ',')
      {
         return excludeCheck(layerID);
      }
      else if(found[strlen(layerID)] == '\0')
      {
         return excludeCheck(layerID);
      }

      found = strstr(&(found[strlen(layerID)]), layerID);
   }

   return 0;
}

LinkList *getCommand(LinkList *commandList, INT8 *commandID)
{
   LinkList  *ite = commandList;

   while(ite != NULL)
   {
      LinkList  *command = (LinkList *) ite->object;

      if((command != NULL) && (command->object != NULL) && (strcmp(command->object, commandID) == 0))
      {
         return command;
      }

      ite = ite->next;
   }

   return NULL;
}

TreeType *createNullTreeType()
{
   DEBUG("createNullTreeType(): Called . . . \n");

   TreeType  *retVal = malloc(sizeof(TreeType));

   if(retVal == NULL)
   {
      return NULL;
   }

   retVal->nodeType = NULL_TYPE;

   return retVal;
}

TreeType *createSchemaTreeType(LinkList *typeList)
{
   DEBUG("createSchemaTreeType(): Called . . . \n");

   SchemaType  *retVal = malloc(sizeof(SchemaType));

   if(retVal == NULL)
   {
      return NULL;
   }

   retVal->nodeType = SCHEMA_TYPE;
   retVal->typeList = typeList;

   return (TreeType *) retVal;
}

TreeType *createSchemaTreeTypeFromBindList(LinkList *bindList)
{
   DEBUG("createSchemaTreeTypeFromBindList(): Called . . . \n");

   SchemaEntry  *newEntry = NULL;
   SchemaType   *retVal   = malloc(sizeof(SchemaType));
   LinkList     *ite      = bindList;
   LinkList     *typeList = NULL;
   LinkList     *newList  = NULL;
   LinkList     *prevList = NULL;

   if(retVal == NULL)
   {
      return NULL;
   }

   retVal->nodeType = SCHEMA_TYPE;

   while(ite != NULL)
   {
      BindEntryNode  *entry = (BindEntryNode *) ite->object;

      if(entry->treeType == NULL)
      {
         yyuerror("Schema entry has no defining type");

         retVal->typeList = typeList;

         return (TreeType *) retVal;
      }

      if(entry->var == NULL)
      {
         yyuerror("Schema entry has no identifier");

         retVal->typeList = typeList;

         return (TreeType *) retVal;
      }

      newList  = createLinkList(NULL);
      newEntry = malloc(sizeof(SchemaEntry));

      newEntry->nodeType  = SCHEMA_ENTRY_TYPE;
      newEntry->entryID   = varToString((VariableNode *) entry->var);
      newEntry->entryType = entry->treeType;

      newList->object = newEntry;

      if(prevList != NULL)
      {
         prevList->next = newList;
      }

      prevList = newList;

      if(typeList == NULL)
      {
         typeList = newList;
      }

      ite = ite->next;
   }

   retVal->typeList = typeList;

   return (TreeType *) retVal;
}

TreeType *createBasicTreeType(INT8 *basicID)
{
   DEBUG("createBasicTreeType(): Called . . . \n");

   BasicType  *retVal = malloc(sizeof(BasicType));

   if(retVal == NULL)
   {
      return NULL;
   }

   retVal->nodeType = BASIC_TYPE;
   retVal->basicID  = basicID;

   return (TreeType *) retVal;
}

TreeType *createGenTreeType(INT8 *genID)
{
   DEBUG("createGenTreeType(): Called . . . \n");

   GenType  *retVal = malloc(sizeof(GenType));

   if(retVal == NULL)
   {
      return NULL;
   }

   retVal->nodeType = GEN_TYPE;
   retVal->genID    = genID;

   return (TreeType *) retVal;
}

TreeType *createSetTreeType(TreeType *setType)
{
   DEBUG("createSetTreeType(): Called . . . \n");

   SetType  *retVal = malloc(sizeof(SetType));

   if(retVal == NULL)
   {
      return NULL;
   }

   retVal->nodeType = SET_TYPE;
   retVal->setType  = setType;

   return (TreeType *) retVal;
}

TreeType *createTupleTreeType(LinkList *exprList, UINT8 useBoundType)
{
   DEBUG("createTupleTreeType(): Called . . . \n");

   TupleType  *retVal = malloc(sizeof(TupleType));

   if(retVal == NULL)
   {
      return NULL;
   }

   retVal->nodeType = TUPLE_TYPE;
   retVal->typeList = typeExprList(exprList, useBoundType);

   return (TreeType *) retVal;
}

TreeType *createTupleTreeTypeFromDecls(LinkList *declList)
{
   DEBUG("createTupleTreeTypeFromDecls(): Called . . . \n");

   TupleType  *retVal   = malloc(sizeof(TupleType));
   LinkList   *ite      = declList;
   LinkList   *typeList = NULL;
   LinkList   *newList  = NULL;
   LinkList   *prevList = NULL;

   if(retVal == NULL)
   {
      return NULL;
   }

   retVal->nodeType = TUPLE_TYPE;

   while(ite != NULL)
   {
      DeclarationNode  *decl = (DeclarationNode *) ite->object;

      if(decl->declType != VAR_DECL)
      {
         yyuerror("Non-variable declaration found in tuple list");

         retVal->typeList = typeList;

         return (TreeType *) retVal;
      }

      if(decl->defExpr == NULL)
      {
         yyuerror("Tuple entry has no defining expression");

         retVal->typeList = typeList;

         return (TreeType *) retVal;
      }

      newList  = createLinkList(NULL);

      newList->object = copyTypeTree(getTypeBoundType(decl->defExpr->treeType));

      if(prevList != NULL)
      {
         prevList->next = newList;
      }

      prevList = newList;

      if(typeList == NULL)
      {
         typeList = newList;
      }

      ite = ite->next;
   }

   retVal->typeList = typeList;

   return (TreeType *) retVal;
}

TreeType *copyTypeTree(TreeType *src)
{
   DEBUG("copyTypeTree(): Called . . . \n");

   printType("src", src);

   TreeType  *retVal = NULL;

   if(src == NULL)
   {
      return NULL;
   }

   LinkList  *list     = NULL;
   LinkList  *newList  = NULL;

   switch(src->nodeType)
   {
      case SCHEMA_TYPE:
         list = ((SchemaType *) src)->typeList;

         while(list != NULL)
         {
            if(newList == NULL)
            {
               newList = createLinkList(copyTypeTree(list->object));
            }
            else
            {
               appendLinkList(newList, copyTypeTree(list->object));
            }

            list = list->next;
         }

         retVal = malloc(sizeof(SchemaType));

         ((SchemaType *) retVal)->nodeType = SCHEMA_TYPE;
         ((SchemaType *) retVal)->typeList = newList;
      break;

      case SCHEMA_ENTRY_TYPE:
         retVal = malloc(sizeof(SchemaEntry));

         ((SchemaEntry *) retVal)->nodeType  = SCHEMA_ENTRY_TYPE;
         ((SchemaEntry *) retVal)->entryID   = strdup(((SchemaEntry *) src)->entryID);
         ((SchemaEntry *) retVal)->entryType = copyTypeTree(((SchemaEntry *) src)->entryType);
      break;

      case BASIC_TYPE:
         retVal = malloc(sizeof(BasicType));

         ((BasicType *) retVal)->nodeType  = BASIC_TYPE;
         ((BasicType *) retVal)->basicID   = strdup(((BasicType *) src)->basicID);
      break;

      case GEN_TYPE:
         retVal = malloc(sizeof(GenType));

         ((GenType *) retVal)->nodeType  = GEN_TYPE;
         ((GenType *) retVal)->genID   = strdup(((GenType *) src)->genID);
      break;

      case SET_TYPE:
         retVal = malloc(sizeof(SetType));

         ((SetType *) retVal)->nodeType = SET_TYPE;
         ((SetType *) retVal)->setType  = copyTypeTree(((SetType *) src)->setType);
      break;

      case TUPLE_TYPE:
         list = ((TupleType *) src)->typeList;

         while(list != NULL)
         {
            if(newList == NULL)
            {
               newList = createLinkList(copyTypeTree(list->object));
            }
            else
            {
               appendLinkList(newList, copyTypeTree(list->object));
            }

            list = list->next;
         }

         retVal = malloc(sizeof(TupleType));

         ((TupleType *) retVal)->nodeType = TUPLE_TYPE;
         ((TupleType *) retVal)->typeList = newList;
      break;

      default:
         yyuerror("Unknown source type during type tree copy");
         retVal = NULL;
      break;
   }

   printType("result", retVal);

   return retVal;
}

static void freeTypeList(LinkList *typeList)
{
   if(typeList == NULL)
   {
      return;
   }

   freeTypeList(typeList->next);
   freeTypeTree(typeList->object);
   free(typeList);
}

void freeTypeTree(TreeType *typeTree)
{
   DEBUG("freeTypeTree(): Called . . . \n");

   if(typeTree == NULL)
   {
      return;
   }

   switch(typeTree->nodeType)
   {
      case SCHEMA_TYPE:
         freeTypeList(((SchemaType *) typeTree)->typeList);
      break;

      case SCHEMA_ENTRY_TYPE:
         free(((SchemaEntry *) typeTree)->entryID);
         freeTypeTree(((SchemaEntry *) typeTree)->entryType);
      break;

      case BASIC_TYPE:
         free(((BasicType *) typeTree)->basicID);
      break;

      case GEN_TYPE:
         free(((GenType *) typeTree)->genID);
      break;

      case SET_TYPE:
         freeTypeTree(((SetType *) typeTree)->setType);
      break;

      case TUPLE_TYPE:
         freeTypeList(((TupleType *) typeTree)->typeList);
      break;

      default:
         yyuerror("Unknown source type during type tree free");

         return;
      break;
   }

   free(typeTree);
}

static void doPrintType(TreeType *src)
{
   if(src == NULL)
   {
      DEBUG("null");

      return;
   }

   LinkList  *list = NULL;

   switch(src->nodeType)
   {
      case SCHEMA_TYPE:
         list = ((SchemaType *) src)->typeList;

         DEBUG("@(");

         while(list != NULL)
         {
            doPrintType(list->object);

            list = list->next;

            if(list != NULL)
            {
               DEBUG(",");
            }
         }

         DEBUG(")");
      break;

      case SCHEMA_ENTRY_TYPE:
         DEBUG("%s=(", ((SchemaEntry *) src)->entryID);
         doPrintType(((SchemaEntry *) src)->entryType);
         DEBUG(")");
      break;

      case BASIC_TYPE:
         DEBUG("*%s", ((BasicType *) src)->basicID);
      break;

      case GEN_TYPE:
         DEBUG("&%s", ((GenType *) src)->genID);
      break;

      case SET_TYPE:
         DEBUG("$(");
         doPrintType(((SetType *) src)->setType);
         DEBUG(")");
      break;

      case TUPLE_TYPE:
         DEBUG("#(");

         list = ((TupleType *) src)->typeList;

         while(list != NULL)
         {
            doPrintType(list->object);

            list = list->next;

            if(list != NULL)
            {
               DEBUG(",");
            }
         }

         DEBUG(")");
      break;

      default:
      return;
   }
}

void printType(INT8 *ident, TreeType *src)
{
   DEBUG("%s ===============================> ", ident);
   doPrintType(src);
   DEBUG("\n");
}

static INT8* typeListToStr(LinkList *list)
{
   if(list == NULL)
   {
      return NULL;
   }

   INT8  *thisStr = treeTypeToStr((TreeType *) list->object);
   INT8  *nextStr = typeListToStr(list->next);

   if(nextStr == NULL)
   {
      return thisStr;
   }
   else
   {
      INT8  *retStr = malloc(strlen(thisStr) + strlen(nextStr) + 2);

      sprintf(retStr, "%s,%s", thisStr, nextStr);

      free(thisStr);
      free(nextStr);

      return retStr;
   }
}

INT8* treeTypeToStr(TreeType *src)
{
   if(src == NULL)
   {
      return strdup("null");
   }

   LinkList  *list     = NULL;
   INT8      *listStr  = NULL;
   INT8      *entryStr = NULL;
   INT8      *idStr    = NULL;
   INT8      *setStr   = NULL;
   INT8      *retVal   = NULL;

   switch(src->nodeType)
   {
      case SCHEMA_TYPE:
         list    = ((SchemaType *) src)->typeList;
         listStr = typeListToStr(list);

         if(listStr == NULL)
         {
            listStr = strdup("null");
         }

         retVal  = malloc(strlen(listStr) + 4);

         sprintf(retVal, "@(%s)", listStr);

         free(listStr);
      break;

      case SCHEMA_ENTRY_TYPE:
         entryStr = treeTypeToStr(((SchemaEntry *) src)->entryType);
         idStr    = ((SchemaEntry *) src)->entryID;
         retVal   = malloc(strlen(idStr) + strlen(entryStr) + 4);

         sprintf(retVal, "%s=(%s)", idStr, entryStr);

         free(entryStr);
      break;

      case BASIC_TYPE:
         idStr  = ((BasicType *) src)->basicID;
         retVal = malloc(strlen(idStr) + 2);

         sprintf(retVal, "*%s", idStr);
      break;

      case GEN_TYPE:
         idStr  = ((GenType *) src)->genID;
         retVal = malloc(strlen(idStr) + 2);

         sprintf(retVal, "&%s", idStr);
      break;

      case SET_TYPE:
         setStr = treeTypeToStr(((SetType *) src)->setType);
         retVal = malloc(strlen(setStr) + 4);

         sprintf(retVal, "$(%s)", setStr);

         free(setStr);
      break;

      case TUPLE_TYPE:
         list    = ((TupleType *) src)->typeList;
         listStr = typeListToStr(list);

         if(listStr == NULL)
         {
            listStr = strdup("null");
         }

         retVal  = malloc(strlen(listStr) + 4);

         sprintf(retVal, "#(%s)", listStr);

         free(listStr);
      break;

      default:
      break;
   }

   return retVal;
}

static const INT8 *getTypeStr(NodeType nodeType)
{
   if(nodeType < 8)
   {
      return TYPE_STR_TBL[nodeType];
   }
   else
   {
      return "error";
   }
}

LinkList *createSubList(TreeType *genTree, TreeType *specTree)
{
   DEBUG("createSubList(): Called . . . \n");

   printType("genTree", genTree);
   printType("specTree", specTree);

   if((genTree == NULL) || (specTree == NULL))
   {
      return NULL;
   }

   GenSubEntry  *subEntry = NULL;
   LinkList     *subList  = NULL;
   LinkList     *genList  = NULL;
   LinkList     *specList = NULL;
   LinkList     *tmpSub   = NULL;
   TreeType     *nextGen  = NULL;
   TreeType     *nextSpec = NULL;

   switch(genTree->nodeType)
   {
      case SCHEMA_TYPE:
         if(specTree->nodeType != SCHEMA_TYPE)
         {
            yyuerror("Generic tree type mismatch: gen=%s, spec=%s", getTypeStr(genTree->nodeType),
                                                                    getTypeStr(specTree->nodeType));

            return subList;
         }

         genList  = ((SchemaType *) genTree)->typeList;
         specList = ((SchemaType *) specTree)->typeList;

         while(genList != NULL)
         {
            if(specList == NULL)
            {
               yyuerror("Generic tree schema is larger than specifier tree schema");

               return subList;
            }

            nextGen  = (TreeType *) genList->object;
            nextSpec = (TreeType *) specList->object;

            tmpSub = createSubList(nextGen, nextSpec);

            if(tmpSub != NULL)
            {
               if(subList == NULL)
               {
                  subList = tmpSub;
                  tmpSub  = NULL;
               }
               else
               {
                  LinkList  *ite  = tmpSub;
                  LinkList  *ite2 = NULL;
                  UINT8     found = 0;

                  while(ite != NULL)
                  {
                     GenSubEntry  *candidate = (GenSubEntry *) ite->object;

                     ite2  = subList;
                     found = 0;

                     while((ite2 != NULL) && (!found))
                     {
                        GenSubEntry  *cmpEntry = (GenSubEntry *) ite2->object;

                        if(strcmp(candidate->genID, cmpEntry->genID) == 0)
                        {
                           found = 1;
                        }

                        ite2 = ite2->next;
                     }

                     if(!found)
                     {
                        appendLinkList(subList, candidate);
                     }
                     else
                     {
                        free(candidate);
                     }

                     ite = ite->next;
                  }
               }

               if(tmpSub != NULL)
               {
                  freeLinkList(tmpSub); /* Only free the list structure */

                  tmpSub = NULL;
               }
            }

            genList  = genList->next;
            specList = specList->next;
         }
      return subList;

      case SCHEMA_ENTRY_TYPE:
         if(specTree->nodeType != SCHEMA_ENTRY_TYPE)
         {
            yyuerror("Generic tree type mismatch: gen=%s, spec=%s", getTypeStr(genTree->nodeType),
                                                                    getTypeStr(specTree->nodeType));

            return subList;
         }

         nextGen  = ((SchemaEntry *) genTree)->entryType;
         nextSpec = ((SchemaEntry *) specTree)->entryType;

         tmpSub = createSubList(nextGen, nextSpec);

         if(tmpSub != NULL)
         {
            if(subList == NULL)
            {
               subList = tmpSub;
               tmpSub  = NULL;
            }
            else
            {
               LinkList  *ite  = tmpSub;
               LinkList  *ite2 = NULL;
               UINT8     found = 0;

               while(ite != NULL)
               {
                  GenSubEntry  *candidate = (GenSubEntry *) ite->object;

                  ite2  = subList;
                  found = 0;

                  while((ite2 != NULL) && (!found))
                  {
                     GenSubEntry  *cmpEntry = (GenSubEntry *) ite2->object;

                     if(strcmp(candidate->genID, cmpEntry->genID) == 0)
                     {
                        found = 1;
                     }

                     ite2 = ite2->next;
                  }

                  if(!found)
                  {
                     appendLinkList(subList, candidate);
                  }
                  else
                  {
                     free(candidate);
                  }

                  ite = ite->next;
               }
            }

            if(tmpSub != NULL)
            {
               freeLinkList(tmpSub); /* Only free the list structure */

               tmpSub = NULL;
            }
         }
      return subList;

      case BASIC_TYPE:
         if(specTree->nodeType != BASIC_TYPE)
         {
            yyuerror("Generic tree type mismatch: gen=%s, spec=%s", getTypeStr(genTree->nodeType),
                                                                    getTypeStr(specTree->nodeType));

            return subList;
         }
      return NULL;

      case GEN_TYPE:
         if((specTree->nodeType != GEN_TYPE) ||
            (strcmp(((GenType *) genTree)->genID, ((GenType *) specTree)->genID) != 0))
         {
            subEntry = malloc(sizeof(GenSubEntry));

            subEntry->genID   = ((GenType *) genTree)->genID;
            subEntry->subType = specTree;

            return createLinkList(subEntry);
         }
         else
         {
            return NULL;
         }
      break;

      case SET_TYPE:
         if(specTree->nodeType != SET_TYPE)
         {
            yyuerror("Generic tree type mismatch: gen=%s, spec=%s", getTypeStr(genTree->nodeType),
                                                                    getTypeStr(specTree->nodeType));

            return subList;
         }

         nextGen  = ((SetType *) genTree)->setType;
         nextSpec = ((SetType *) specTree)->setType;

         tmpSub = createSubList(nextGen, nextSpec);

         if(tmpSub != NULL)
         {
            if(subList == NULL)
            {
               subList = tmpSub;
               tmpSub  = NULL;
            }
            else
            {
               LinkList  *ite  = tmpSub;
               LinkList  *ite2 = NULL;
               UINT8     found = 0;

               while(ite != NULL)
               {
                  GenSubEntry  *candidate = (GenSubEntry *) ite->object;

                  ite2  = subList;
                  found = 0;

                  while((ite2 != NULL) && (!found))
                  {
                     GenSubEntry  *cmpEntry = (GenSubEntry *) ite2->object;

                     if(strcmp(candidate->genID, cmpEntry->genID) == 0)
                     {
                        found = 1;
                     }

                     ite2 = ite2->next;
                  }

                  if(!found)
                  {
                     appendLinkList(subList, candidate);
                  }
                  else
                  {
                     free(candidate);
                  }

                  ite = ite->next;
               }
            }

            if(tmpSub != NULL)
            {
               freeLinkList(tmpSub); /* Only free the list structure */

               tmpSub = NULL;
            }
         }
      return subList;

      case TUPLE_TYPE:
         if(specTree->nodeType != TUPLE_TYPE)
         {
            yyuerror("Generic tree type mismatch: gen=%s, spec=%s", getTypeStr(genTree->nodeType),
                                                                    getTypeStr(specTree->nodeType));

            return subList;
         }

         genList  = ((TupleType *) genTree)->typeList;
         specList = ((TupleType *) specTree)->typeList;

         while(genList != NULL)
         {
            if(specList == NULL)
            {
               yyuerror("Generic tree tuple is larger than specifier tree tuple");

               return subList;
            }

            nextGen  = (TreeType *) genList->object;
            nextSpec = (TreeType *) specList->object;

            tmpSub = createSubList(nextGen, nextSpec);

            if(tmpSub != NULL)
            {
               if(subList == NULL)
               {
                  subList = tmpSub;
                  tmpSub  = NULL;
               }
               else
               {
                  LinkList  *ite  = tmpSub;
                  LinkList  *ite2 = NULL;
                  UINT8     found = 0;

                  while(ite != NULL)
                  {
                     GenSubEntry  *candidate = (GenSubEntry *) ite->object;

                     ite2  = subList;
                     found = 0;

                     while((ite2 != NULL) && (!found))
                     {
                        GenSubEntry  *cmpEntry = (GenSubEntry *) ite2->object;

                        if(strcmp(candidate->genID, cmpEntry->genID) == 0)
                        {
                           found = 1;
                        }

                        ite2 = ite2->next;
                     }

                     if(!found)
                     {
                        appendLinkList(subList, candidate);
                     }
                     else
                     {
                        free(candidate);
                     }

                     ite = ite->next;
                  }
               }

               if(tmpSub != NULL)
               {
                  freeLinkList(tmpSub); /* Only free the list structure */

                  tmpSub = NULL;
               }
            }

            genList  = genList->next;
            specList = specList->next;
         }
      return subList;

      default:
         yyuerror("Generic tree type error: gen=%d, spec=%d", genTree->nodeType, specTree->nodeType);
      return NULL;
   }

   return subList;
}

LinkList *createGenSchSubList(SchemaTypeNode *schType)
{
   SchemaNode  *schTree;
   Symbol      *schSym;

   if(schType->specList == NULL)
   {
      return NULL;
   }

   if(schType->refName == NULL)
   {
      return NULL;
   }
   else
   {
      schSym = symLookup(schType->refName, &yyuerror);

      if(schSym == NULL)
      {
         yyuerror("Schema %s not found", schType->refName);

         return NULL;
      }
      else
      {
         schTree = (SchemaNode *) schSym->synTree;

         if(schTree == NULL)
         {
            yyuerror("Schema %s has an invalid/incomplete syntax tree", schType->refName);

            return NULL;
         }
         else if(schTree->nodeType == NODE_SCHEMA)
         {
            return NULL;
         }
         else if(schTree->nodeType == NODE_GEN_SCH)
         {
            GenSchemaNode  *genTree   = (GenSchemaNode *) schTree;
            LinkList       *genSyms   = genTree->syms;
            LinkList       *subList   = NULL;
            LinkList       *specExprs = schType->specList;

            while(genSyms != NULL)
            {
               if((specExprs == NULL) || (genSyms->object == NULL) || (specExprs->object == NULL))
               {
                  freeSubList(subList);

                  return NULL;
               }

               GenSubEntry  *subEntry = malloc(sizeof(GenSubEntry));

               subEntry->genID   = genSyms->object;
               subEntry->subType = getTypeBoundType(((SyntaxTree *) specExprs->object)->treeType);

               if(subList == NULL)
               {
                  subList = createLinkList(subEntry);
               }
               else
               {
                  appendLinkList(subList, subEntry);
               }

               genSyms   = genSyms->next;
               specExprs = specExprs->next;
            }

            if(specExprs != NULL)
            {
               freeSubList(subList);

               return NULL;
            }

            return subList;
         }
         else
         {
            yyuerror("Schema %s has an invalid tree type %d", schType->refName, schTree->nodeType);

            return NULL;
         }
      }
   }
}

LinkList *createGenPatchList(LinkList *genList, LinkList *specList)
{
   if(genList == NULL)
   {
      yyuerror("Generic symbol list is NULL");

      return NULL;
   }
   else if(specList == NULL)
   {
      yyuerror("Generic specifier list is NULL");

      return NULL;
   }
   else if(sizeLinkList(genList) != sizeLinkList(specList))
   {
      yyuerror("Size mismatch between generic and specifier lists");

      return NULL;
   }

   LinkList  *genIte  = genList;
   LinkList  *specIte = specList;
   LinkList  *subList = NULL;

   while(genIte != NULL)
   {
      SyntaxTree  *specExpr = (SyntaxTree *) specIte->object;
      INT8        *genID    = genIte->object;

      if(genID == NULL)
      {
         yyuerror("Generic symbol list is invalid");

         return subList;
      }
      else if(specExpr == NULL)
      {
         yyuerror("Generic specifier list is invalid");

         return subList;
      }
      else if(specExpr->treeType == NULL)
      {
         yyuerror("Generic specifier list contains incomplete type information");

         return subList;
      }

      GenSubEntry  *subEntry = (GenSubEntry *) malloc(sizeof(GenSubEntry));

      subEntry->genID   = genID;
      subEntry->subType = getTypeBoundType(specExpr->treeType);

      if(subList == NULL)
      {
         subList = createLinkList(subEntry);
      }
      else
      {
         appendLinkList(subList, subEntry);
      }

      genIte  = genIte->next;
      specIte = specIte->next;
   }

   return subList;
}

INT8 compareGenSyms(LinkList *gen1, LinkList *gen2)
{
   if((gen1 == NULL) || (gen2 == NULL))
   {
      return 0;
   }

   if(sizeLinkList(gen1) != sizeLinkList(gen2))
   {
      return 0;
   }

   LinkList  *ite1 = gen1;
   LinkList  *ite2 = gen2;

   while(ite1 != NULL)
   {
      if((ite1->object == NULL) || (ite2->object == NULL))
      {
         return 0;
      }

      if(strcmp((INT8 *) ite1->object, (INT8 *) ite2->object) != 0)
      {
         return 0;
      }

      ite1 = ite1->next;
      ite2 = ite2->next;
   }

   return 1;
}


void freeSubList(LinkList *subList)
{
   if(subList == NULL)
   {
      return;
   }

   if(subList->next != NULL)
   {
      freeSubList(subList->next);

      subList->next = NULL;
   }

   free(subList->object);
   free(subList);
}

TreeType *substituteGen(TreeType *src, LinkList *subList)
{
   DEBUG("substituteGen(): Called . . . \n");

   printType("src", src);

   TreeType  *retVal = NULL;

   if(src == NULL)
   {
      return NULL;
   }

   if(subList == NULL)
   {
      return copyTypeTree(src);
   }

   GenSubEntry  *subEntry = NULL;
   LinkList     *list     = NULL;
   LinkList     *newList  = NULL;
   INT8         *id       = NULL;

   switch(src->nodeType)
   {
      case SCHEMA_TYPE:
         list = ((SchemaType *) src)->typeList;

         while(list != NULL)
         {
            if(newList == NULL)
            {
               newList = createLinkList(substituteGen(list->object, subList));
            }
            else
            {
               appendLinkList(newList, substituteGen(list->object, subList));
            }

            list = list->next;
         }

         retVal = malloc(sizeof(SchemaType));

         ((SchemaType *) retVal)->nodeType = SCHEMA_TYPE;
         ((SchemaType *) retVal)->typeList = newList;
      break;

      case SCHEMA_ENTRY_TYPE:
         retVal = malloc(sizeof(SchemaEntry));

         ((SchemaEntry *) retVal)->nodeType  = SCHEMA_ENTRY_TYPE;
         ((SchemaEntry *) retVal)->entryID   = strdup(((SchemaEntry *) src)->entryID);
         ((SchemaEntry *) retVal)->entryType = substituteGen(((SchemaEntry *) src)->entryType, subList);
      break;

      case BASIC_TYPE:
         retVal = copyTypeTree(src);
      break;

      case GEN_TYPE:
         id   = ((GenType *) src)->genID;
         list = subList;

         while(list != NULL)
         {
            subEntry = (GenSubEntry *) list->object;

            DEBUG("substituteGen(): id = %s, subID = %s\n", id, subEntry->genID);

            if((subEntry != NULL) && (strcmp(id, subEntry->genID) == 0))
            {
               retVal = copyTypeTree(subEntry->subType);

               printType("sub", subEntry->subType);

               break;
            }

            list = list->next;
         }

         if(retVal == NULL)
         {
            retVal = copyTypeTree(src);
         }
      break;

      case SET_TYPE:
         retVal = malloc(sizeof(SetType));

         ((SetType *) retVal)->nodeType = SET_TYPE;
         ((SetType *) retVal)->setType  = substituteGen(((SetType *) src)->setType, subList);
      break;

      case TUPLE_TYPE:
         list = ((TupleType *) src)->typeList;

         while(list != NULL)
         {
            if(newList == NULL)
            {
               newList = createLinkList(substituteGen(list->object, subList));
            }
            else
            {
               appendLinkList(newList, substituteGen(list->object, subList));
            }

            list = list->next;
         }

         retVal = malloc(sizeof(TupleType));

         ((TupleType *) retVal)->nodeType = TUPLE_TYPE;
         ((TupleType *) retVal)->typeList = newList;
      break;

      default:
         yyuerror("Unknown source type during generic substitution");
         retVal = copyTypeTree(src);
      break;
   }

   printType("result", retVal);

   return retVal;
}

TreeType *unprimeSchema(TreeType *src)
{
   DEBUG("unprimeSchema(): Called . . . \n");

   printType("src", src);

   if(src->nodeType != SCHEMA_TYPE)
   {
      return src;
   }

   SchemaType  *schType = (SchemaType *) src;
   LinkList    *ite     = schType->typeList;
   LinkList    *newList = NULL;

   while(ite != NULL)
   {
      SchemaEntry  *entry  = (SchemaEntry *) ite->object;
      LinkList     *ite2   = newList;
      UINT32       baseLen = strcspn(entry->entryID, "'");
      UINT8        found   = 0;

      while((ite2 != NULL) && (!found))
      {
         SchemaEntry  *cmpEntry  = (SchemaEntry *) ite2->object;
         UINT32       cmpBaseLen = strcspn(cmpEntry->entryID, "'");

         if((baseLen == cmpBaseLen) && (strncmp(entry->entryID, cmpEntry->entryID, baseLen) == 0))
         {
            found = 1;

            yyuerror("Unprime operations created a variable name conflict for %s", entry->entryID);
         }

         ite2 = ite2->next;
      }

      if(!found)
      {
         SchemaEntry  *newEntry = malloc(sizeof(SchemaEntry));

         newEntry->nodeType  = SCHEMA_ENTRY_TYPE;
         newEntry->entryID   = strndup(entry->entryID, baseLen);
         newEntry->entryType = copyTypeTree(entry->entryType);

         if(newList == NULL)
         {
            newList = createLinkList(newEntry);
         }
         else
         {
            appendLinkList(newList, newEntry);
         }
      }

      ite = ite->next;
   }

   TreeType  *retVal = (TreeType *) createSchemaTreeType(newList);

   printType("result", retVal);

   return retVal;
}

TreeType *preSchema(TreeType *src)
{
   if(src->nodeType != SCHEMA_TYPE)
   {
      return src;
   }

   LinkList  *newList = NULL;
   LinkList  *ite     = NULL;

   ite = ((SchemaType *) src)->typeList;

   while(ite != NULL)
   {
      SchemaEntry  *entry  = (SchemaEntry *) ite->object;

      if(strcspn(entry->entryID, "'!") == strlen(entry->entryID))
      {
         if(newList == NULL)
         {
            newList = createLinkList(copyTypeTree((TreeType *) entry));
         }
         else
         {
            appendLinkList(newList, copyTypeTree((TreeType *) entry));
         }
      }

      ite = ite->next;
   }

   return createSchemaTreeType(newList);
}

TreeType *postSchema(TreeType *src)
{
   if(src->nodeType != SCHEMA_TYPE)
   {
      return src;
   }

   LinkList  *newList = NULL;
   LinkList  *ite     = NULL;

   ite = ((SchemaType *) src)->typeList;

   while(ite != NULL)
   {
      SchemaEntry  *entry  = (SchemaEntry *) ite->object;

      if(strchr(entry->entryID, '?') == NULL)
      {
         if(strchr(entry->entryID, '!') != NULL)
         {
            if(newList == NULL)
            {
               newList = createLinkList(copyTypeTree((TreeType *) entry));
            }
            else
            {
               appendLinkList(newList, copyTypeTree((TreeType *) entry));
            }
         }
         else
         {
            UINT32  baseLen = strcspn(entry->entryID, "'");
            INT8    *decor  = strchr(entry->entryID, '\'');

            DEBUG("TOK_ZPOST: entryID = %s, baseLen = %d, decor = %s\n", entry->entryID, baseLen, decor);

            if(newList == NULL)
            {
               DEBUG("TOK_ZPOST: %s added to newList as first entry\n", entry->entryID);

               newList = createLinkList(copyTypeTree((TreeType *) entry));
            }
            else
            {
               LinkList  *ite2 = newList;
               UINT8     found = 0;

               while((ite2 != NULL) && (!found))
               {
                  SchemaEntry  *cmpEntry  = (SchemaEntry *) ite2->object;
                  UINT32       cmpBaseLen = strcspn(cmpEntry->entryID, "'");
                  INT8         *cmpDecor  = strchr(cmpEntry->entryID, '\'');

                  DEBUG("TOK_ZPOST: cmpID = %s, cmpDecor = %s\n", cmpEntry->entryID, cmpDecor);

                  if((cmpBaseLen == baseLen) && (strncmp(cmpEntry->entryID, entry->entryID, baseLen) == 0))
                  {
                     UINT8  cnt    = extractDecorCount(decor);
                     UINT8  cmpCnt = extractDecorCount(cmpDecor);

                     DEBUG("TOK_ZPOST: cnt = %d, cmpCnt = %d\n", cnt, cmpCnt);

                     if(cnt > cmpCnt)
                     {
                        freeTypeTree((TreeType *) ite2->object);

                        ite2->object = copyTypeTree((TreeType *) entry);
                     }

                     /* If entry base names match then found should always be set.  This flag indicates
                        the base name has been found and appropriately handled */
                     found = 1;
                  }

                  ite2 = ite2->next;
               }

               if(!found)
               {
                  appendLinkList(newList, copyTypeTree((TreeType *) entry));
               }
            }
         }
      }

      ite = ite->next;
   }

   return createSchemaTreeType(newList);
}

TreeType *inSchema(TreeType *src)
{
   if(src->nodeType != SCHEMA_TYPE)
   {
      return src;
   }

   LinkList  *newList = NULL;
   LinkList  *ite     = NULL;

   ite = ((SchemaType *) src)->typeList;

   while(ite != NULL)
   {
      SchemaEntry  *entry  = (SchemaEntry *) ite->object;

      if(index(entry->entryID, '?') != NULL)
      {
         if(newList == NULL)
         {
            newList = createLinkList(copyTypeTree((TreeType *) entry));
         }
         else
         {
            appendLinkList(newList, copyTypeTree((TreeType *) entry));
         }
      }

      ite = ite->next;
   }

   return createSchemaTreeType(newList);
}

TreeType *outSchema(TreeType *src)
{
   if(src->nodeType != SCHEMA_TYPE)
   {
      return src;
   }

   LinkList  *newList = NULL;
   LinkList  *ite     = NULL;

   ite = ((SchemaType *) src)->typeList;

   while(ite != NULL)
   {
      SchemaEntry  *entry  = (SchemaEntry *) ite->object;

      if(index(entry->entryID, '!') != NULL)
      {
         if(newList == NULL)
         {
            newList = createLinkList(copyTypeTree((TreeType *) entry));
         }
         else
         {
            appendLinkList(newList, copyTypeTree((TreeType *) entry));
         }
      }

      ite = ite->next;
   }

   return createSchemaTreeType(newList);
}

LinkList *getTypeList(LinkList *declList)
{
   DEBUG("getTypeList(): Called . . . \n");

   SchemaEntry  *newEntry = NULL;
   LinkList     *ite      = declList;
   LinkList     *retList  = NULL;
   LinkList     *newList  = NULL;
   LinkList     *prevList = NULL;

   while(ite != NULL)
   {
      DeclarationNode  *decl = (DeclarationNode *) ite->object;

      if(decl->declType != VAR_DECL)
      {
         yyuerror("Non-variable declaration found in schema type");

         return retList;
      }

      if(decl->defExpr == NULL)
      {
         yyuerror("Schema entry has no defining expression");

         return retList;
      }

      if(decl->ident == NULL)
      {
         yyuerror("Schema entry has no identifier");

         return retList;
      }

      newList  = createLinkList(NULL);
      newEntry = malloc(sizeof(SchemaEntry));

      newEntry->nodeType  = SCHEMA_ENTRY_TYPE;
      newEntry->entryID   = varToString((VariableNode *) decl->ident);
      newEntry->entryType = decl->treeType;

      newList->object = newEntry;

      if(prevList != NULL)
      {
         prevList->next = newList;
      }

      prevList = newList;

      if(retList == NULL)
      {
         retList = newList;
      }

      ite = ite->next;
   }

   return retList;
}

TreeType *getExprType(SyntaxTree *ast)
{
   DEBUG("getExprType(): Called . . . \n");

   if(ast == NULL)
   {
      return NULL;
   }

   return ast->treeType;
}

TreeType *getTypeBoundType(TreeType *treeType)
{
   DEBUG("getTypeBoundType(): Called . . . \n");

   if(treeType == NULL)
   {
      return NULL;
   }

   if(treeType->nodeType != SET_TYPE)
   {
      return NULL;
   }

   SetType  *setType = (SetType *) treeType;

   return setType->setType;
}

TreeType *getFuncAppliedType(TreeType *treeType)
{
   DEBUG("getFuncAppliedType(): Called . . . \n");

   if(treeType == NULL)
   {
      return NULL;
   }

   if(treeType->nodeType != SET_TYPE)
   {
      return NULL;
   }

   SetType  *setType = (SetType *) treeType;

   if(setType->setType == NULL)
   {
      return NULL;
   }

   if(setType->setType->nodeType != TUPLE_TYPE)
   {
      return NULL;
   }

   TupleType  *tupleType = (TupleType *) setType->setType;

   if(tupleType->typeList == NULL)
   {
      return NULL;
   }

   LinkList  *typeList  = tupleType->typeList;
   TreeType  *paramType = NULL;
   TreeType  *retType   = NULL;

   if(typeList->next == NULL)
   {
      return NULL;
   }

   if(typeList->next->next != NULL)
   {
      return NULL;
   }

   paramType = (TreeType *) typeList->object;
   retType   = (TreeType *) typeList->next->object;

   if((paramType == NULL) || (retType == NULL))
   {
      return NULL;
   }

   return retType;
}

TreeType *getFuncParamType(TreeType *treeType)
{
   DEBUG("getFuncParamType(): Called . . . \n");

   if(treeType == NULL)
   {
      return NULL;
   }

   if(treeType->nodeType != SET_TYPE)
   {
      return NULL;
   }

   SetType  *setType = (SetType *) treeType;

   if(setType->setType == NULL)
   {
      return NULL;
   }

   if(setType->setType->nodeType != TUPLE_TYPE)
   {
      return NULL;
   }

   TupleType  *tupleType = (TupleType *) setType->setType;

   if(tupleType->typeList == NULL)
   {
      return NULL;
   }

   LinkList  *typeList  = tupleType->typeList;
   TreeType  *paramType = NULL;
   TreeType  *retType   = NULL;

   if(typeList->next == NULL)
   {
      return NULL;
   }

   if(typeList->next->next != NULL)
   {
      return NULL;
   }

   paramType = (TreeType *) typeList->object;
   retType   = (TreeType *) typeList->next->object;

   if((paramType == NULL) || (retType == NULL))
   {
      return NULL;
   }

   return paramType;
}

TreeType *getBoundSchemaType(TreeType *treeType)
{
   DEBUG("getBoundSchemaType(): Called . . . \n");

   if(treeType == NULL)
   {
      return NULL;
   }

   if(treeType->nodeType != SET_TYPE)
   {
      return NULL;
   }

   SetType  *setType = (SetType *) treeType;

   if(setType->setType == NULL)
   {
      return NULL;
   }

   if(setType->setType->nodeType != SCHEMA_TYPE)
   {
      return NULL;
   }

   return setType->setType;
}


LinkList *typeExprList(LinkList *exprList, UINT8 useBoundType)
{
   DEBUG("typeExprList(): Called . . . \n");

   LinkList  *ite      = exprList;
   LinkList  *retList  = NULL;
   LinkList  *newList  = NULL;
   LinkList  *prevList = NULL;
   UINT8     exprNum   = 0;

   while(ite != NULL)
   {
      SyntaxTree  *expr = (SyntaxTree *) ite->object;

      exprNum = exprNum + 1;

      if(expr == NULL)
      {
         yyuerror("Expr list entry %d has no expression", exprNum);

         return NULL;
      }

      TreeType  *type = expr->treeType;

      if(type == NULL)
      {
         yyuerror("Expr list entry %d has no type", exprNum);

         return NULL;
      }

      newList = createLinkList(NULL);

      if(!useBoundType)
      {
         newList->object = type;
      }
      else
      {
         newList->object = getTypeBoundType(type);
      }

      if(prevList != NULL)
      {
         prevList->next = newList;
      }

      prevList = newList;

      if(retList == NULL)
      {
         retList = newList;
      }

      ite = ite->next;
   }

   return retList;
}

UINT8 isSchemaTypeExpr(SyntaxTree *expr)
{
   DEBUG("isSchemaTypeExpr(): Called . . . \n");

   if(expr == NULL)
   {
      return 0;
   }

   if(expr->treeType == NULL)
   {
      return 0;
   }

   if(expr->treeType->nodeType != SET_TYPE)
   {
      return 0;
   }

   SetType  *setType = (SetType *) expr->treeType;

   if(setType->setType == NULL)
   {
      return 0;
   }

   if(setType->setType->nodeType != SCHEMA_TYPE)
   {
      return 0;
   }

   return 1;
}

UINT8 isSchemaBindExpr(SyntaxTree *expr)
{
   DEBUG("isSchemaBindExpr(): Called . . . \n");

   if(expr == NULL)
   {
      return 0;
   }

   if(expr->treeType == NULL)
   {
      return 0;
   }

   if(expr->treeType->nodeType != SCHEMA_TYPE)
   {
      return 0;
   }

   return 1;
}

UINT8 isIntExpr(SyntaxTree *expr)
{
   DEBUG("isIntExpr(): Called . . . \n");

   if(expr == NULL)
   {
      return 0;
   }

   if(expr->treeType == NULL)
   {
      return 0;
   }

   if(expr->treeType->nodeType != BASIC_TYPE)
   {
      return 0;
   }

   BasicType  *basicType = (BasicType *) expr->treeType;

   if(basicType->basicID == NULL)
   {
      return 0;
   }

   if(strncmp(basicType->basicID, "int", 3) != 0)
   {
      return 0;
   }

   return 1;
}

UINT8 isFuncExpr(SyntaxTree *expr)
{
   DEBUG("isFuncExpr(): Called . . .\n");

   if(expr == NULL)
   {
      DEBUG("isFuncExpr(): expr == NULL\n");

      return 0;
   }

   if(expr->treeType == NULL)
   {
      DEBUG("isFuncExpr(): expr->treeType == NULL\n");

      return 0;
   }

   printType("func", expr->treeType);

   if(expr->treeType->nodeType != SET_TYPE)
   {
      DEBUG("isFuncExpr(): expr->treeType->nodeType != SET_TYPE\n");

      return 0;
   }

   SetType  *setType = (SetType *) expr->treeType;

   if(setType->setType == NULL)
   {
      DEBUG("isFuncExpr(): setType->setType == NULL\n");

      return 0;
   }

   if(setType->setType->nodeType != TUPLE_TYPE)
   {
      DEBUG("isFuncExpr(): setType->setType->nodeType != TUPLE_TYPE\n");

      return 0;
   }

   TupleType  *tupleType = (TupleType *) setType->setType;

   if(tupleType->typeList == NULL)
   {
      DEBUG("isFuncExpr(): tupleType->typeList == NULL\n");

      return 0;
   }

   LinkList  *typeList  = tupleType->typeList;
   TreeType  *paramType = NULL;
   TreeType  *retType   = NULL;

   if(typeList->next == NULL)
   {
      DEBUG("isFuncExpr(): typeList->next == NULL\n");

      return 0;
   }

   if(typeList->next->next != NULL)
   {
      DEBUG("isFuncExpr(): typeList->next->next != NULL\n");

      return 0;
   }

   paramType = (TreeType *) typeList->object;
   retType   = (TreeType *) typeList->next->object;

   if((paramType == NULL) || (retType == NULL))
   {
      DEBUG("isFuncExpr(): (paramType == NULL) || (retType == NULL)\n");

      return 0;
   }

   DEBUG("isFuncExpr(): expr is a function type\n");

   return 1;
}

UINT8 isRelExpr(SyntaxTree *expr)
{
   DEBUG("isRelExpr(): Called . . .\n");

   if(expr == NULL)
   {
      DEBUG("isRelExpr(): expr == NULL\n");

      return 0;
   }

   if(expr->treeType == NULL)
   {
      DEBUG("isRelExpr(): expr->treeType == NULL\n");

      return 0;
   }

   printType("rel", expr->treeType);

   if(expr->treeType->nodeType != SET_TYPE)
   {
      DEBUG("isRelExpr(): expr->treeType->nodeType != SET_TYPE\n");

      return 0;
   }

   return 1;
}

UINT8 isSetList(LinkList *typeList)
{
   DEBUG("isSetList(): Called . . . \n");

   LinkList  *ite      = typeList;
   TreeType  *first    = NULL;
   TreeType  *cur      = NULL;

   if(ite == NULL)
   {
      return 1; /* Empty is OK */
   }

   first = ite->object;

   while(ite != NULL)
   {
      cur = ite->object;

      if(!typeCompare(first, cur))
      {
         return 0;
      }

      ite = ite->next;
   }

   return 1;
}

UINT8 isSetExpr(SyntaxTree *expr)
{
   DEBUG("isSetExpr(): Called . . . \n");

   printType("expr", expr->treeType);

   if(expr == NULL)
   {
      return 0;
   }

   if(expr->treeType == NULL)
   {
      return 0;
   }

   if(expr->treeType->nodeType != SET_TYPE)
   {
      return 0;
   }

   return 1;
}

UINT8 isEventExpr(SyntaxTree *expr)
{
   DEBUG("isEventExpr(): Called . . . \n");

   if(expr == NULL)
   {
      return 0;
   }

   if(expr->treeType == NULL)
   {
      return 0;
   }

   if(expr->treeType->nodeType != BASIC_TYPE)
   {
      return 0;
   }

   BasicType  *basicType = (BasicType *) expr->treeType;

   if(basicType->basicID == NULL)
   {
      return 0;
   }

   if(strncmp(basicType->basicID, "CSP_EVENT", 9) != 0)
   {
      return 0;
   }

   return 1;
}

UINT8 isEventSetExpr(SyntaxTree *expr)
{
   DEBUG("isEventSetExpr(): Called . . . \n");

   if(expr == NULL)
   {
      return 0;
   }

   if(expr->treeType == NULL)
   {
      return 0;
   }

   if(expr->treeType->nodeType != SET_TYPE)
   {
      DEBUG("isEventSetExpr(): expr->treeType->nodeType != SET_TYPE\n");

      return 0;
   }

   SetType  *setType = (SetType *) expr->treeType;

   if(setType->setType == NULL)
   {
      DEBUG("isEventSetExpr(): setType->setType == NULL\n");

      return 0;
   }

   if(setType->setType->nodeType != BASIC_TYPE)
   {
      DEBUG("isEventSetExpr(): setType->setType->nodeType != BASIC_TYPE\n");

      return 0;
   }

   BasicType  *basicType = (BasicType *) setType->setType;

   if(basicType->basicID == NULL)
   {
      return 0;
   }

   if(strncmp(basicType->basicID, "CSP_EVENT", 9) != 0)
   {
      return 0;
   }

   return 1;
}

UINT8 isProcessExpr(SyntaxTree *expr)
{
   DEBUG("isProcessExpr(): Called . . . \n");

   if(expr == NULL)
   {
      return 0;
   }

   if(expr->treeType == NULL)
   {
      return 0;
   }

   TreeType  *exprType = NULL;

   if(isFuncExpr(expr))
   {
      exprType = getFuncAppliedType(expr->treeType);
   }
   else
   {
      exprType = expr->treeType;
   }

   if(exprType->nodeType != BASIC_TYPE)
   {
      return 0;
   }

   BasicType  *basicType = (BasicType *) exprType;

   if(basicType->basicID == NULL)
   {
      return 0;
   }

   if(strncmp(basicType->basicID, "PROCESS", 7) != 0)
   {
      return 0;
   }

   return 1;
}

UINT8 isChannelExpr(SyntaxTree *expr)
{
   DEBUG("isChannelExpr(): Called . . . \n");

   if(expr == NULL)
   {
      return 0;
   }

   if(expr->treeType == NULL)
   {
      return 0;
   }

   TreeType  *exprType = NULL;

   if(isFuncExpr(expr))
   {
      exprType = getFuncAppliedType(expr->treeType);
   }
   else
   {
      exprType = expr->treeType;
   }

   if(exprType->nodeType != BASIC_TYPE)
   {
      return 0;
   }

   BasicType  *basicType = (BasicType *) exprType;

   if(basicType->basicID == NULL)
   {
      return 0;
   }

   if(strncmp(basicType->basicID, "CSP_EVENT", 9) != 0)
   {
      return 0;
   }

   return 1;
}

UINT8 isProcRenExpr(SyntaxTree *expr)
{
   DEBUG("isProcRenExpr(): Called . . . \n");

   if(!isFuncExpr(expr))
   {
      return 0;
   }

   TreeType  *paramType = getFuncParamType(expr->treeType);
   TreeType  *outType   = getFuncAppliedType(expr->treeType);

   if(!typeCompare(paramType, outType))
   {
      return 0;
   }

   if(paramType->nodeType != BASIC_TYPE)
   {
      return 0;
   }

   BasicType  *basicType = (BasicType *) paramType;

   if(basicType->basicID == NULL)
   {
      return 0;
   }

   if(strncmp(basicType->basicID, "CSP_EVENT", 9) != 0)
   {
      return 0;
   }

   return 1;
}

TreeType *joinSchemaTypes(SchemaType *lSch, SchemaType *rSch)
{
   DEBUG("joinSchemaTypes(): Called . . . \n");

   SchemaEntry  *candidate = NULL;
   SchemaEntry  *exist     = NULL;
   LinkList     *newList   = NULL;
   LinkList     *appList   = NULL;
   LinkList     *search    = NULL;

   if((lSch == NULL) || (rSch == NULL))
   {
      return NULL;
   }

   newList = copyLinkList(lSch->typeList);
   appList = rSch->typeList;

   while(appList != NULL)
   {
      UINT8  found = 0;

      candidate = (SchemaEntry *) appList->object;
      search    = lSch->typeList;

      while((search != NULL) && (!found))
      {
         exist = (SchemaEntry *) search->object;

         if(strcmp(exist->entryID, candidate->entryID) == 0)
         {
            if(!typeCompare(exist->entryType, candidate->entryType))
            {
               yyuerror("Join of incompatible schemas");

               return createSchemaTreeType(newList);
            }
            else
            {
               found = 1;
            }
         }

         search = search->next;
      }

      if(!found)
      {
         appendLinkList(newList, candidate);
      }

      appList = appList->next;
   }

   if(newList != NULL)
   {
      return createSchemaTreeType(newList);
   }
   else
   {
      return NULL;
   }
}

UINT8 typeCompare(TreeType *type1, TreeType *type2)
{
   DEBUG("typeCompare(): Called . . . \n");

   printType("type1", type1);
   printType("type2", type2);

   if((type1 == NULL) || (type2 == NULL))
   {
      return 0;
   }

   /* Type check of generics is always OK */
   /*if((type1->nodeType == GEN_TYPE) || (type2->nodeType == GEN_TYPE))
   {
      return 1;
   }*/

   if(type1->nodeType != type2->nodeType)
   {
      return 0;
   }

   SchemaEntry  *entry1 = NULL;
   SchemaEntry  *entry2 = NULL;
   LinkList     *sList1 = NULL;
   LinkList     *sList2 = NULL;
   LinkList     *tList1 = NULL;
   LinkList     *tList2 = NULL;
   UINT8        found   = 0;

   switch(type1->nodeType)
   {
      case SCHEMA_TYPE:
         sList1 = ((SchemaType *) type1)->typeList;
         sList2 = ((SchemaType *) type2)->typeList;

         if(sizeLinkList(sList1) != sizeLinkList(sList2))
         {
            return 0;
         }

         while(sList1 != NULL)
         {
            entry1 = (SchemaEntry *) sList1->object;

            if(entry1 == NULL)
            {
               return 0;
            }

            sList2 = ((SchemaType *) type2)->typeList;
            found  = 0;

            while((sList2 != NULL) && !found)
            {
               entry2 = (SchemaEntry *) sList2->object;

               if(strcmp(entry1->entryID, entry2->entryID) == 0)
               {
                  found = 1;

                  if(!typeCompare(entry1->entryType, entry2->entryType))
                  {
                     return 0;
                  }
               }

               sList2 = sList2->next;
            }

            if(!found)
            {
               return 0;
            }

            sList1 = sList1->next;
         }
      break;

      /* Unreachable placeholder */
      case BASIC_TYPE:
         if(strcmp(((BasicType *) type1)->basicID , ((BasicType *) type2)->basicID) != 0)
         {
            return 0;
         }
      break;

      case GEN_TYPE:
         if(strcmp(((GenType *) type1)->genID , ((GenType *) type2)->genID) != 0)
         {
            return 0;
         }
      break;

      case SET_TYPE:
         if((((SetType *) type1)->setType == NULL) || (((SetType *) type2)->setType == NULL))
         {
            /* Not proper according to Z notation, but an empty set can be
               a set of anything therefore a-specc shall accept it*/
            return 1;
         }
         else
         {
            return typeCompare(((SetType *) type1)->setType, ((SetType *) type2)->setType);
         }
      break;

      case TUPLE_TYPE:
         tList1 = ((TupleType *) type1)->typeList;
         tList2 = ((TupleType *) type2)->typeList;

         if(sizeLinkList(tList1) != sizeLinkList(tList2))
         {
            return 0;
         }

         while(tList1 != NULL)
         {
            if(tList2 == NULL)
            {
               return 0;
            }

            if(!typeCompare((TreeType *) tList1->object, (TreeType *) tList2->object))
            {
               return 0;
            }

            tList1 = tList1->next;
            tList2 = tList2->next;
         }

         if(tList2 != NULL)
         {
            return 0;
         }
      break;

      default:
      return 0;
   }

   return 1;
}

UINT8 typeCompatible(SchemaType *lSch, SchemaType *rSch)
{
   DEBUG("typeCompatible(): Called . . . \n");

   SchemaEntry  *lEntry = NULL;
   SchemaEntry  *rEntry = NULL;
   LinkList     *lList  = NULL;
   LinkList     *rList  = NULL;

   if((lSch == NULL) || (rSch == NULL))
   {
      return 0;
   }

   lList = lSch->typeList;
   rList = rSch->typeList;

   while(lList != NULL)
   {
      lEntry = (SchemaEntry *) lList->object;
      rList  = rSch->typeList;

      while(rList != NULL)
      {
         rEntry = (SchemaEntry *) rList->object;

         if(strcmp(lEntry->entryID, rEntry->entryID) == 0)
         {
            if(!typeCompare(lEntry->entryType, rEntry->entryType))
            {
               return 0;
            }
         }

         rList = rList->next;
      }

      lList = lList->next;
   }

   return 1;
}

UINT8 validateParams(TreeType *funcType, TreeType *inParam)
{
   DEBUG("validateParams(): Called . . . \n");

   if(funcType == NULL)
   {
      yyuerror("Function type is undefined");

      return 0;
   }

   if(funcType->nodeType != SET_TYPE)
   {
      yyuerror("Function type is not a set");

      return 0;
   }

   SetType  *setType = (SetType *) funcType;

   if(setType->setType == NULL)
   {
      yyuerror("Function set expression is undefined");

      return 0;
   }

   if(setType->setType->nodeType != TUPLE_TYPE)
   {
      yyuerror("Function set expression is not a tuple");

      return 0;
   }

   TupleType  *tupleType = (TupleType *) setType->setType;

   if(tupleType->typeList == NULL)
   {
      yyuerror("Function tuple is undefined");

      return 0;
   }

   LinkList  *typeList = tupleType->typeList;
   TreeType  *param    = NULL;
   TreeType  *ret      = NULL;

   if(typeList->next == NULL)
   {
      yyuerror("Function return type is undefined");

      return 0;
   }

   if(typeList->next->next != NULL)
   {
      yyuerror("Function tuple is not a tuple pair");

      return 0;
   }

   param = (TreeType *) typeList->object;
   ret   = (TreeType *) typeList->next->object;

   if((param == NULL) || (ret == NULL))
   {
      yyuerror("Function parameter type or return type is undefined");

      return 0;
   }

   if(!typeCompare(param, inParam))
   {
      INT8  *expected = treeTypeToStr(param);
      INT8  *actual   = treeTypeToStr(inParam);

      yyuerror("Parameter type mismatch: \n\texpected=\n\t\t%s\n\tactual=\n\t\t%s", expected, actual);

      free(expected);
      free(actual);

      return 0;
   }

   return 1;
}

UINT8 validateRelParams(TreeType *relType, TreeType *inParam)
{
   DEBUG("validateRelParams(): Called . . . \n");

   if(relType == NULL)
   {
      yyuerror("Function type is undefined");

      return 0;
   }

   if(relType->nodeType != SET_TYPE)
   {
      yyuerror("Function type is not a set");

      return 0;
   }

   SetType  *setType = (SetType *) relType;

   if(setType->setType == NULL)
   {
      yyuerror("Function set expression is undefined");

      return 0;
   }

   if(!typeCompare(setType->setType, inParam))
   {
      INT8  *expected = treeTypeToStr(setType->setType);
      INT8  *actual   = treeTypeToStr(inParam);

      yyuerror("Parameter type mismatch: \n\texpected=\n\t\t%s\n\tactual=\n\t\t%s", expected, actual);

      free(expected);
      free(actual);

      return 0;
   }

   return 1;
}

SyntaxTree *handleFuncApp(SyntaxTree *funcExpr, SyntaxTree *param)
{
   DEBUG("handleFuncApp(): Called . . . \n");

   SyntaxTree  *retVal   = (SyntaxTree *) createExprFuncNode(funcExpr, param);
   TreeType    *exprType = getExprType(funcExpr);

   if(!isFuncExpr(funcExpr))
   {
      yyuerror("Expression is not a function");
   }
   else
   {
      TreeType  *paramType = getFuncParamType(exprType);
      LinkList  *subList   = NULL;
      TreeType  *inType    = param->treeType;

      DEBUG("creating subList\n");
      subList = createSubList(paramType, inType);
      DEBUG("done\n");

      retVal->specType = substituteGen(funcExpr->treeType, subList);

      if(!validateParams(retVal->specType, inType))
      {
         yyuerror("Parameter type error in function call");
      }

      retVal->treeType = getFuncAppliedType(retVal->specType);

      freeSubList(subList);
   }

   return retVal;
}

SyntaxTree *handleFInOp(SyntaxTree *left, INT8 *opName, SyntaxTree *right)
{
   DEBUG("handleFInOp(): Called . . . \n");

   SyntaxTree  *retVal = (SyntaxTree *) createExprOpNode(left, opName, right);
   Symbol      *opSym  = symLookup(opName, &yyuerror);

   if(opSym == NULL)
   {
      yyuerror("Operator identifier %s not found", opName);
   }
   else
   {
      TreeType  *opType = opSym->synTree->treeType;

      printType(opName, opType);

      if(!isFuncExpr(opSym->synTree))
      {
         yyuerror("Operator %s type signature invalid", opSym->symName);
      }
      else
      {
         TreeType  *paramType = getFuncParamType(opType);
         LinkList  *subList   = NULL;
         LinkList  *inList    = createLinkList(left);

         appendLinkList(inList, right);

         TreeType  *inType = createTupleTreeType(inList, 0);

         subList = createSubList(paramType, inType);

         retVal->specType = substituteGen(opType, subList);

         if(!validateParams(retVal->specType, inType))
         {
            yyuerror("Parameter type error in operator evaluation");
         }

         freeLinkList(((TupleType *) inType)->typeList);
         free(inType);
         freeLinkList(inList);

         retVal->treeType = getFuncAppliedType(retVal->specType);

         freeSubList(subList);
      }
   }

   return retVal;
}

SyntaxTree *handleFPreOp(INT8 *opName, SyntaxTree *right)
{
   DEBUG("handleFPreOp(): Called . . . \n");

   SyntaxTree  *retVal = (SyntaxTree *) createExprOpNode(NULL, opName, right);
   Symbol      *opSym  = symLookup(opName, &yyuerror);

   if(opSym == NULL)
   {
      yyuerror("Operator identifier %s not found", opName);
   }
   else
   {
      TreeType  *opType = opSym->synTree->treeType;

      printType(opName, opType);

      if(!isFuncExpr(opSym->synTree))
      {
         yyuerror("Operator %s type signature invalid", opSym->symName);
      }
      else
      {
         TreeType  *paramType = getFuncParamType(opType);
         LinkList  *subList   = NULL;
         TreeType  *inType    = right->treeType;

         subList = createSubList(paramType, inType);

         retVal->specType = substituteGen(opType, subList);

         if(!validateParams(retVal->specType, inType))
         {
            yyuerror("Parameter type error in operator evaluation");
         }

         retVal->treeType = getFuncAppliedType(retVal->specType);

         freeSubList(subList);
      }
   }

   return retVal;
}

SyntaxTree *handleFPostOp(SyntaxTree *left, INT8 *opName)
{
   DEBUG("handleFPostOp(): Called . . . \n");

   SyntaxTree  *retVal = (SyntaxTree *) createExprOpNode(left, opName, NULL);
   Symbol      *opSym  = symLookup(opName, &yyuerror);

   if(opSym == NULL)
   {
      yyuerror("Operator identifier %s not found", opName);
   }
   else
   {
      TreeType  *opType = opSym->synTree->treeType;

      printType(opName, opType);

      if(!isFuncExpr(opSym->synTree))
      {
         yyuerror("Operator %s type signature invalid", opSym->symName);
      }
      else
      {
         TreeType  *paramType = getFuncParamType(opType);
         LinkList  *subList   = NULL;
         TreeType  *inType    = left->treeType;

         subList = createSubList(paramType, inType);

         retVal->specType = substituteGen(opType, subList);

         if(!validateParams(retVal->specType, inType))
         {
            yyuerror("Parameter type error in operator evaluation");
         }

         retVal->treeType = getFuncAppliedType(retVal->specType);

         freeSubList(subList);
      }
   }

   return retVal;
}

SyntaxTree *handleRelFunc(INT8 *funcName, SyntaxTree *param)
{
   DEBUG("handleRelFunc(): Called . . . \n");

   SyntaxTree  *retVal = (SyntaxTree *) createPredFuncNode(funcName, param);
   Symbol      *funcSym  = symLookup(funcName, &yyuerror);

   if(funcSym == NULL)
   {
      yyuerror("Function identifier %s not found", funcName);
   }
   else
   {
      TreeType  *funcType = funcSym->synTree->treeType;

      printType(funcName, funcType);

      if(!isRelExpr(funcSym->synTree))
      {
         yyuerror("Relation %s type signature invalid", funcSym->symName);
      }
      else
      {
         TreeType  *paramType = getTypeBoundType(funcType);
         LinkList  *subList   = NULL;
         TreeType  *inType    = param->treeType;

         subList = createSubList(paramType, inType);

         retVal->specType = substituteGen(funcType, subList);

         if(!validateRelParams(retVal->specType, inType))
         {
            yyuerror("Parameter type error in relation evaluation");
         }

         freeSubList(subList);
      }
   }

   return retVal;
}

SyntaxTree *handleRInOp(SyntaxTree *left, INT8 *opName, SyntaxTree *right)
{
   DEBUG("handleRInOp(): Called . . . \n");

   SyntaxTree  *retVal = (SyntaxTree *) createPredRelNode(left, opName, right);
   Symbol      *opSym  = symLookup(opName, &yyuerror);

   if(opSym == NULL)
   {
      yyuerror("Relation identifier %s not found", opName);
   }
   else
   {
      TreeType  *opType = opSym->synTree->treeType;

      printType(opName, opType);

      if(!isRelExpr(opSym->synTree))
      {
         yyuerror("Relation %s type signature invalid", opSym->symName);
      }
      else
      {
         TreeType  *paramType = getTypeBoundType(opType);
         LinkList  *subList   = NULL;
         LinkList  *inList    = createLinkList(left);

         appendLinkList(inList, right);

         TreeType  *inType = createTupleTreeType(inList, 0);

         subList = createSubList(paramType, inType);

         retVal->specType = substituteGen(opType, subList);

         if(!validateRelParams(retVal->specType, inType))
         {
            yyuerror("Parameter type error in relation evaluation");
         }

         freeLinkList(((TupleType *) inType)->typeList);
         free(inType);
         freeLinkList(inList);

         freeSubList(subList);
      }
   }

   return retVal;
}

SyntaxTree *handleRPreOp(INT8 *opName, SyntaxTree *right)
{
   DEBUG("handleRPreOp(): Called . . . \n");

   SyntaxTree  *retVal = (SyntaxTree *) createPredRelNode(NULL, opName, right);
   Symbol      *opSym  = symLookup(opName, &yyuerror);

   if(opSym == NULL)
   {
      yyuerror("Relation identifier %s not found", opName);
   }
   else
   {
      TreeType  *opType = opSym->synTree->treeType;

      printType(opName, opType);

      if(!isRelExpr(opSym->synTree))
      {
         yyuerror("Relation %s type signature invalid", opSym->symName);
      }
      else
      {
         TreeType  *paramType = getTypeBoundType(opType);
         LinkList  *subList   = NULL;
         TreeType  *inType    = right->treeType;

         subList = createSubList(paramType, inType);

         retVal->specType = substituteGen(opType, subList);

         if(!validateRelParams(retVal->specType, inType))
         {
            yyuerror("Parameter type error in relation evaluation");
         }

         freeSubList(subList);
      }
   }

   return retVal;
}

SyntaxTree *handleRPostOp(SyntaxTree *left, INT8 *opName)
{
   DEBUG("handleRPostOp(): Called . . . \n");

   SyntaxTree  *retVal = (SyntaxTree *) createPredRelNode(left, opName, NULL);
   Symbol      *opSym  = symLookup(opName, &yyuerror);

   if(opSym == NULL)
   {
      yyuerror("Relation identifier %s not found", opName);
   }
   else
   {
      TreeType  *opType = opSym->synTree->treeType;

      printType(opName, opType);

      if(!isRelExpr(opSym->synTree))
      {
         yyuerror("Relation %s type signature invalid", opSym->symName);
      }
      else
      {
         TreeType  *paramType = getTypeBoundType(opType);
         LinkList  *subList   = NULL;
         TreeType  *inType    = left->treeType;

         subList = createSubList(paramType, inType);

         retVal->specType = substituteGen(opType, subList);

         if(!validateRelParams(retVal->specType, inType))
         {
            yyuerror("Parameter type error in relation evaluation");
         }

         freeSubList(subList);
      }
   }

   return retVal;
}

SyntaxTree *handleSchemaHide(SyntaxTree *left, SyntaxTree *right)
{
   SyntaxTree  *retVal = (SyntaxTree *) createExprOpNode(left, strdup("zhide"), right);

   if(!isSchemaTypeExpr(left) && !isSchemaBindExpr(left))
   {
      yyuerror("Left operand is not a schema expression");
   }
   else if(isSchemaTypeExpr(right) || isSchemaBindExpr(right))
   {
      SchemaType  *srcSch  = NULL;
      SchemaType  *hideSch = NULL;

      if(isSchemaBindExpr(left))
      {
         srcSch = (SchemaType *) getExprType((SyntaxTree *) left);
      }
      else if(isSchemaTypeExpr(left))
      {
         srcSch = (SchemaType *) getBoundSchemaType(getExprType((SyntaxTree *) left));
      }

      if(isSchemaBindExpr(right))
      {
         if((right->nodeType == NODE_SCH_BIND) && (((SchemaBindNode *) right)->hideNode == 1))
         {
            hideSch = (SchemaType *) getExprType((SyntaxTree *) right);
         }
         else
         {
            yyuerror("Right operand must be a schema type or hide list");
         }
      }
      else if(isSchemaTypeExpr(right))
      {
         hideSch = (SchemaType *) getBoundSchemaType(getExprType((SyntaxTree *) right));
      }

      LinkList  *ite     = srcSch->typeList;
      LinkList  *newList = NULL;

      while(ite != NULL)
      {
         SchemaEntry  *srcEntry = (SchemaEntry *) ite->object;
         LinkList     *ite2     = hideSch->typeList;
         UINT8        found     = 0;

         while((ite2 != NULL) && (!found))
         {
            SchemaEntry  *hideEntry = (SchemaEntry *) ite2->object;

            if(strcmp(srcEntry->entryID, hideEntry->entryID) == 0)
            {
               found = 1;
            }

            ite2 = ite2->next;
         }

         if(!found)
         {
            if(newList == NULL)
            {
               newList = createLinkList(srcEntry);
            }
            else
            {
               appendLinkList(newList, srcEntry);
            }
         }

         ite = ite->next;
      }

      if(isSchemaTypeExpr(left))
      {
         ((SyntaxTree *) retVal)->treeType = createSetTreeType(createSchemaTreeType(newList));
      }
      else
      {
         ((SyntaxTree *) retVal)->treeType = createSchemaTreeType(newList);
      }
   }
   else
   {
      yyuerror("Right operand is not a valid hiding expression");
   }

   return retVal;
}

SyntaxTree *handleSchemaOver(SyntaxTree *left, SyntaxTree *right)
{
   SyntaxTree  *retVal = (SyntaxTree *) createExprOpNode(left, strdup("zover"), right);

   if(!isSchemaBindExpr(left))
   {
      yyuerror("Left operand is not a schema bind expression");
   }
   else if(isSchemaBindExpr(right))
   {
      SchemaType  *srcSch  = (SchemaType *) getExprType((SyntaxTree *) left);
      SchemaType  *overSch = (SchemaType *) getExprType((SyntaxTree *) right);

      if(!typeCompatible(srcSch, overSch))
      {
         yyuerror("Schema expressions are not type compatible");
      }

      LinkList  *ite     = overSch->typeList;

      while(ite != NULL)
      {
         SchemaEntry  *overEntry = (SchemaEntry *) ite->object;
         LinkList     *ite2      = srcSch->typeList;
         UINT8        found      = 0;

         while((ite2 != NULL) && (!found))
         {
            SchemaEntry  *srcEntry = (SchemaEntry *) ite2->object;

            if(strcmp(srcEntry->entryID, overEntry->entryID) == 0)
            {
               found = 1;
            }

            ite2 = ite2->next;
         }

         if(!found)
         {
            yyuerror("Over-ride entry `%s`, not found in source schema", overEntry->entryID);

            return retVal;
         }

         ite = ite->next;
      }

      ((SyntaxTree *) retVal)->treeType = copyTypeTree((TreeType *) srcSch);
   }
   else
   {
      yyuerror("Right operand is not a valid over-ride expression");
   }

   return retVal;
}

SyntaxTree *handleProcessRename(SyntaxTree *left, SyntaxTree *right)
{
   SyntaxTree  *retVal = (SyntaxTree *) createExprOpNode(left, strdup("pren"), right);

   if(!isProcessExpr(left))
   {
      yyuerror("Left operand is not a process expression");
   }
   else if(isProcRenExpr(right))
   {
      retVal->treeType = copyTypeTree(left->treeType);
   }
   else
   {
      yyuerror("Right operand is not a process renaming expression");
   }

   return retVal;
}

INT8 processChanAppl(LinkList *chanList, LinkList *paramList)
{
   DEBUG("processChanAppl(): Called . . . \n");

   LinkList  *chanIte  = chanList;
   LinkList  *paramIte = paramList;
   INT32     index     = 1;

   while(1)
   {
      DEBUG("index = %d\n", index);

      if((chanIte == NULL) || (paramIte == NULL))
      {
         yyuerror("Field list size does not match channel definition");

         return 0;
      }

      ChanFieldNode  *paramNode = (ChanFieldNode *) paramIte->object;

      if(paramNode == NULL)
      {
         yyuerror("Field %d definition incomplete", index);

         return 0;
      }

      TreeType  *chanType  = chanIte->object;
      TreeType  *paramType = paramNode->treeType;

      printType("chanType", chanType);
      printType("paramType", paramType);

      if(chanType == NULL)
      {
         yyuerror("Channel parameter %d type definition incomplete", index);

         return 0;
      }

      if(paramType != NULL)
      {
         if(!typeCompare(chanType, paramType))
         {
            INT8  *expected = treeTypeToStr(chanType);
            INT8  *actual   = treeTypeToStr(paramType);

            yyuerror("Parameter %d type mismatch: \n\texpected=\n\t\t%s\n\tactual=\n\t\t%s",
                     index, expected, actual);

            free(expected);
            free(actual);

            return 0;
         }
      }
      else
      {
         if(paramNode->fieldType != INPUT_FIELD)
         {
            yyuerror("In-line field declaration for non-input field %d", index);

            return 0;
         }

         paramNode->treeType = copyTypeTree(chanType);
         ((ChanFieldNode *) paramNode)->fieldExpr->treeType = copyTypeTree(chanType);
      }

      chanIte  = chanIte->next;
      paramIte = paramIte->next;
      index    = index + 1;

      if((chanIte == NULL) && (paramIte == NULL))
      {
         break;
      }
   }

   return 1;
}

UINT8 importFile(INT8 *fileName)
{
   if(fileName[0] != '/')
   {
      LinkList  *ite      = importPaths;
      INT8     *fullPath = NULL;

      while(ite != NULL)
      {
         if(ite->object != NULL)
         {
            DEBUG("importPath = %s\n", (INT8 *) ite->object);

            asprintf((char **) &fullPath, "%s/%s", (INT8 *) ite->object, fileName);

            UINT8  retVal = newFile(fullPath);

            free(fullPath);

            fullPath = NULL;

            if(retVal != 0)
            {
               return retVal;
            }
         }

         ite = ite->next;
      }

      yyerror("File %s not found", fileName);

      return 0;
   }
   else
   {
      return newFile(fileName);
   }
}

void yyuerror(const char *str, ...)
{
   va_list  argList;
   INT32    loop;
   INT32    leadWS;
   INT8     *fileName;

   errors = errors + 1;

   va_start(argList, str);

   for(leadWS = 0; leadWS < strlen(lineBuf); leadWS++)
   {
      if((lineBuf[leadWS] != ' ') && (lineBuf[leadWS] != '\t'))
      {
         break;
      }
   }

   if(curFile == NULL)
   {
      fileName = "toplevel";
   }
   else
   {
      fileName = curFile;
   }

   fprintf(stderr, "\n%s:%d: ", fileName, yylineno);
   vfprintf(stderr, str, argList);
   fprintf(stderr, "\n");
   fprintf(stderr, "%s%s\n", ERR_INDENT, &(lineBuf[leadWS]));

   for(loop = 0; (loop < (acceptLen + strlen(ERR_INDENT) - curLen - prevLen - leadWS)) && (loop < strlen(lineBuf)); loop++)
   {
      fprintf(stderr, " ");
   }

   fprintf(stderr, "^");
   fprintf(stderr, "\n");

#ifdef DO_DEBUG
   exit(-1);
#endif

   if(errors >= maxErrors)
   {
      fprintf(stderr, "Error limit reached\n");

      exit(-1);
   }
}

void yyerror(const char *str, ...)
{
   va_list  argList;
   INT32    loop;
   INT32    leadWS;
   INT8     *fileName;

   errors = errors + 1;

   va_start(argList, str);

   for(leadWS = 0; leadWS < strlen(lineBuf); leadWS++)
   {
      if((lineBuf[leadWS] != ' ') && (lineBuf[leadWS] != '\t'))
      {
         break;
      }
   }

   if(curFile == NULL)
   {
      fileName = "toplevel";
   }
   else
   {
      fileName = curFile;
   }

   fprintf(stderr, "\n%s:%d: ", fileName, yylineno);
   vfprintf(stderr, str, argList);
   fprintf(stderr, "\n");
   fprintf(stderr, "%s%s\n", ERR_INDENT, &(lineBuf[leadWS]));

   for(loop = 0; (loop < (acceptLen + strlen(ERR_INDENT) - curLen - leadWS)) && (loop < strlen(lineBuf)); loop++)
   {
      fprintf(stderr, " ");
   }

   fprintf(stderr, "^");
   fprintf(stderr, "\n");

#ifdef DO_DEBUG
   exit(-1);
#endif

   if(errors >= maxErrors)
   {
      fprintf(stderr, "Error limit reached\n");

      exit(-1);
   }
}

void yyferror(const char *str, ...)
{
   va_list  argList;

   errors = errors + 1;

   va_start(argList, str);

   fprintf(stderr, "Fatal Error: ");
   vfprintf(stderr, str, argList);
   fprintf(stderr, "\n");

   exit(-1);
}

static void parseImportPath(INT8 *listStr)
{
   INT8  *delim = listStr;

   DEBUG("parseImportPath(%s): Called . . .\n", listStr);

   while(delim != NULL)
   {
      DEBUG("delim = %s\n", delim);

      if((delim - listStr) < strlen(listStr))
      {
         UINT32  pathLen    = strlen(delim);
         INT8   *nextDelim = index(delim, ',');

         if(nextDelim != NULL)
         {
            pathLen = nextDelim - delim;

            nextDelim = nextDelim + 1;
         }

         INT8  *newPath = strndup(delim, pathLen);

         DEBUG("adding = %s\n", newPath);

         appendLinkList(importPaths, newPath);

         delim = nextDelim;
      }
      else
      {
         break;
      }

   }
}

static void copyFile(INT8 *src, INT8 *dest)
{
   INT32  readCount;
   INT32  outFile;
   INT32  inFile;
   INT8   buffer[512];

   inFile = open(src, O_RDONLY);

   if(inFile == -1)
   {
      yyuerror("Unable to open %s", src);

      return;
   }

   outFile = open(dest, O_WRONLY | O_CREAT | O_TRUNC, S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH);

   if(outFile == -1)
   {
      yyuerror("Unable to create %s", dest);

      return;
   }

   while((readCount = read(inFile, buffer, sizeof(buffer))) > 0)
   {
      write(outFile, buffer, readCount);
   }

   close(inFile);
   close(outFile);
}

static void deleteFile(INT8 *path)
{
   unlink(path);
}

static void usage(char *argv[])
{
   printf("Usage: %s [options] [src_file]\n", argv[0]);
   printf("  -I, --importpath=path1,path2,...  Path list to add to the import path search list\n");
   printf("  -o, --outfile=FILENAME            LaTeX output file\n");
   printf("  -t, --tabgroup=NUMBER             Spaces per A-Spec tabgroup\n");
   printf("  -i, --indent=NUMBER               Initial spaces to be counted as source indent\n");
   printf("  -d, --dotfile=FILENAME            Export AST to GraphViz 'dot' output file\n");
   printf("  -D, --dottype                     Export data types to GraphViz file\n");
   printf("  -x, --xmlfile=FILENAME            Export AST to XML output file\n");
   printf("  -L, --layers=layer1,layer2,...    Design layers to be exported to ATeX, XML or dot formats\n");
   printf("  -X, --exclude=layer1,layer2,...   Design layers to be excluded from ATeX, XML or dot formats\n");

   exit(-1);
}

int main(int argc, char *argv[])
{
   INT8  *ozFile    = malloc(1024);
   INT8  *tmpOz     = malloc(1028);
   INT8  *dotFile   = malloc(1024);
   INT8  *xmlFile   = malloc(1024);
   INT8  *srcFile   = NULL;
   INT8   opt        = -1;
   INT8   retCode    = 0;

   importPaths = createLinkList(".");

#ifdef ALIB_PATH
   appendLinkList(importPaths, ALIB_PATH);
#endif

   outLayers = NULL;
   exLayers  = NULL;

   memset(ozFile, 0, 1024);
   memset(tmpOz, 0, 1028);
   memset(dotFile, 0, 1024);
   memset(xmlFile, 0, 1024);

   /*{"importpath", 1, 0, 'I'},
     {"outfile", 1, 0, 'o'}
     {"tabgroup", 1, 0, 't'}
     {"indent", 1, 0, 'i'}
     {"dotfile", 1, 0, 'd'}
     {"dottype", 0, 0, 'D'}
     {"xmlfile", 1, 0, 'x'}
     {"layers", 1, 0, 'L'}
     {"exclude", 1, 0, 'X'}
     {"help", 0, 0, 'h'}*/
   while(1)
   {
      int  optIdx = 0;

      opt = getopt_long(argc, argv, "o:t:i:d:Dx:L:X:I:h", options, &optIdx);

      if(opt == -1)
      {
         break;
      }

      DEBUG("Parsed option: %c\n", opt);

      switch(opt)
      {
         case 'I':
            parseImportPath(optarg);
         break;

         case 'o':
            strcpy(ozFile, optarg);
         break;

         case 'd':
            strcpy(dotFile, optarg);
         break;

         case 'x':
            strcpy(xmlFile, optarg);
         break;

         case 't':
            aTabGroup = atoi(optarg);
         break;

         case 'i':
            aIndent = atoi(optarg);
         break;

         case 'D':
            exportType = 1;
         break;

         case 'L':
            outLayers = malloc(strlen(optarg) + 1);
            strcpy(outLayers, optarg);
         break;

         case 'X':
            exLayers = malloc(strlen(optarg) + 1);
            strcpy(exLayers, optarg);
         break;

         default:
            usage(argv);
         break;
      }
   }

   if((argc <= optind) || (optind <= 0))
   {
      usage(argv);
   }

   srcFile = argv[optind];

   DEBUG("Loading file %s\n", srcFile);

   initOzXfm();

   if(!initSymStack())
   {
      yyerror("Unable to init symbol table");

      exit(-1);
   }

   DEBUG("Symbol table initialized\n");

   if(strlen(ozFile) > 0)
   {
      sprintf(tmpOz, "%s.tmp", ozFile);

      DEBUG("ATeX file %s\n", ozFile);

      initA2OzTex(tmpOz);
   }

   initFormat();

   acceptLen  = 0;
   lineBuf[0] = 0;
   errors     = 0;

   if(!newFile(srcFile))
   {
      yyferror("Unable to open file %s\n", srcFile);
   }

   yyparse();

   if((symStack->current != globalTable) && (errors == 0))
   {
      yyerror("Symbol stack discrepancy");
   }

   printf("Parse for %s completed ", srcFile);

   if(errors > 0)
   {
      printf("with errors\n\n");

      retCode = -1;
   }
   else
   {
      printf("successfully\n\n");
   }

   if((docAST != NULL) && (strlen(xmlFile) > 0))
   {
      DEBUG("XML file %s\n", xmlFile);

      aDocToXML(docAST, xmlFile);
   }

   if((docAST != NULL) && (strlen(dotFile) > 0))
   {
      DEBUG("Dot file %s\n", dotFile);

      aDocToDOT(docAST, dotFile);
   }

   closeA2OzTex();

   if(strlen(ozFile) > 0)
   {
      if(errors == 0)
      {
         copyFile(tmpOz, ozFile);
      }

      deleteFile(tmpOz);
   }

   free(ozFile);
   free(tmpOz);
   free(dotFile);
   free(xmlFile);

   if(outLayers != NULL)
   {
      free(outLayers);
   }

   if(exLayers != NULL)
   {
      free(exLayers);
   }

   return retCode;
}
