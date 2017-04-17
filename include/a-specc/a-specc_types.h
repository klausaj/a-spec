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

#ifndef a_specc_types_h
#define a_specc_types_h

typedef char       INT8;
typedef short      INT16;
typedef int        INT32;
typedef long long  INT64;

typedef unsigned char       UINT8;
typedef unsigned short      UINT16;
typedef unsigned int        UINT32;
typedef unsigned long long  UINT64;

enum
{
   /*  0 */ NODE_A_DOC, NODE_DOC_INFO, NODE_INFO_ENTRY, NODE_PROP_ENTRY, NODE_DIREC,
   /*  5 */ NODE_DESC, NODE_BASIC, NODE_BASIC_ENTRY, NODE_TYPE_DEF,  NODE_TYPE_ENTRY,
   /* 10 */ NODE_FREE_TYPE, NODE_FREE_ENTRY, NODE_AXDEF, NODE_GENDEF, NODE_SCHEMA,
   /* 15 */ NODE_GEN_SCH, NODE_CONST, NODE_DECL, NODE_PRED, NODE_PRED_OP, NODE_PRED_REL,
   /* 21 */ NODE_PRED_FUNC, NODE_PRED_LITERAL, NODE_PRED_QUANT, NODE_PRED_IF, NODE_EXPR_OP,
   /* 26 */ NODE_EXPR_FUNC, NODE_VAR, NODE_EXPR_LITERAL, NODE_EXPR_IDENT, NODE_EXPR_GEN_IDENT,
   /* 31 */ NODE_EXPR_IF, NODE_TUPLE, NODE_CROSS, NODE_SCH_BIND, NODE_BIND_ENTRY,
   /* 36 */ NODE_SELECT, NODE_SCH_TYPE, NODE_SET_DISP, NODE_SEQ_DISP, NODE_UPTO,
   /* 41 */ NODE_SET_COMP, NODE_LAMBDA, NODE_MU, NODE_SCHEMA_APP, NODE_PROCESS,
   /* 46 */ NODE_PROC_DEF, NODE_PROC_IF, NODE_CHAN_FIELD, NODE_CHAN_APPL, NODE_REPL_PROC,
   /* 51 */ NODE_LET_EXPR, NODE_LET_PRED, NODE_LET_PROC, NODE_GEN_PROC_DEF, NODE_PROC_ALIAS,
   /* 56 */ NODE_CHAN_ALIAS
};

enum DeclarationTypes_e
{
   EXPR_FUNC_DECL, PRED_FUNC_DECL, VAR_DECL, SCH_REF_DECL,
   EXPR_OP_PRE_DECL, EXPR_OP_POST_DECL, EXPR_OP_IN_DECL,
   REL_OP_PRE_DECL, REL_OP_POST_DECL, REL_OP_IN_DECL,
   PROC_DECL, PROC_FUNC_DECL, CHAN_DECL, EVENT_DECL
};

typedef enum DeclarationTypes_e  DeclType;

enum DecorationTypes_e
{
   DECOR_NULL, PRE_DELTA, POST_PRI, POST_IN, POST_OUT
};

typedef enum DecorationTypes_e DecorType;

enum NodeType_e
{
   SCHEMA_TYPE, SCHEMA_ENTRY_TYPE, BASIC_TYPE, GEN_TYPE, SET_TYPE, TUPLE_TYPE, NULL_TYPE, ERR_TYPE
};

typedef enum NodeType_e NodeType;

enum FieldType_e
{
   INPUT_FIELD, OUTPUT_FIELD, DOT_FIELD
};

typedef enum FieldType_e FieldType;

enum ReplType_e
{
   INTERNAL, EXTERNAL, PARALLEL, INTERLEAVE, IF_PARALLEL
};

typedef enum ReplType_e ReplType;

struct AToken_t
{
   INT8   *preFmt;
   INT8   *token;
};

typedef struct AToken_t AToken;

struct OzXfm_t
{
   INT8   *src;
   INT8   *tgt;
};

typedef struct OzXfm_t OzXfm;

struct ADocNode_t;                 typedef struct ADocNode_t          ADocNode;
struct DocInfoNode_t;              typedef struct DocInfoNode_t       DocInfoNode;
struct InfoEntryNode_t;            typedef struct InfoEntryNode_t     InfoEntryNode;
struct PropertyNode_t;             typedef struct PropertyNode_t      PropertyNode;
struct ParagraphNode_t;            typedef struct ParagraphNode_t     ParagraphNode;
struct DirectiveNode_t;            typedef struct DirectiveNode_t     DirectiveNode;
struct DescriptionNode_t;          typedef struct DescriptionNode_t   DescriptionNode;
struct BasicDefNode_t;             typedef struct BasicDefNode_t      BasicDefNode;
struct BasicEntryNode_t;           typedef struct BasicEntryNode_t    BasicEntryNode;
struct TypeDefNode_t;              typedef struct TypeDefNode_t       TypeDefNode;
struct TypeEntryNode_t;            typedef struct TypeEntryNode_t     TypeEntryNode;
struct FreeTypeNode_t;             typedef struct FreeTypeNode_t      FreeTypeNode;
struct FreeEntryNode_t;            typedef struct FreeEntryNode_t     FreeEntryNode;
struct AxDefNode_t;                typedef struct AxDefNode_t         AxDefNode;
struct GenDefNode_t;               typedef struct GenDefNode_t        GenDefNode;
struct SchemaNode_t;               typedef struct SchemaNode_t        SchemaNode;
struct GenSchemaNode_t;            typedef struct GenSchemaNode_t     GenSchemaNode;
struct ConstraintNode_t;           typedef struct ConstraintNode_t    ConstraintNode;
struct ProcessNode_t;              typedef struct ProcessNode_t       ProcessNode;
struct DeclarationNode_t;          typedef struct DeclarationNode_t   DeclarationNode;
struct PredicateNode_t;            typedef struct PredicateNode_t     PredicateNode;
struct PredOpNode_t;               typedef struct PredOpNode_t        PredOpNode;
struct PredRelNode_t;              typedef struct PredRelNode_t       PredRelNode;
struct PredFuncNode_t;             typedef struct PredFuncNode_t      PredFuncNode;
struct PredLiteralNode_t;          typedef struct PredLiteralNode_t   PredLiteralNode;
struct PredQuantNode_t;            typedef struct PredQuantNode_t     PredQuantNode;
struct LetPredNode_t;              typedef struct LetPredNode_t       LetPredNode;
struct SchemaAppNode;              typedef struct SchemaAppNode_t     SchemaAppNode;
struct CondPredNode_t;             typedef struct CondPredNode_t      CondPredNode;
struct ExprNode_t;                 typedef struct ExprNode_t          ExprNode;
struct ExprOpNode_t;               typedef struct ExprOpNode_t        ExprOpNode;
struct ExprFuncNode_t;             typedef struct ExprFuncNode_t      ExprFuncNode;
struct VariableNode_t;             typedef struct VariableNode_t      VariableNode;
struct SchemaRefNode_t;            typedef struct SchemaRefNode_t     SchemaRefNode;
struct ExprLiteralNode_t;          typedef struct ExprLiteralNode_t   ExprLiteralNode;
struct ExprIdentNode_t;            typedef struct ExprIdentNode_t     ExprIdentNode;
struct ExprGenIdentNode_t;         typedef struct ExprGenIdentNode_t  ExprGenIdentNode;
struct CondExprNode_t;             typedef struct CondExprNode_t      CondExprNode;
struct TupleNode_t;                typedef struct TupleNode_t         TupleNode;
struct CrossNode_t;                typedef struct CrossNode_t         CrossNode;
struct SchemaBindNode_t;           typedef struct SchemaBindNode_t    SchemaBindNode;
struct BindEntryNode_t;            typedef struct BindEntryNode_t     BindEntryNode;
struct SelectNode_t;               typedef struct SelectNode_t        SelectNode;
struct SchemaTypeNode_t;           typedef struct SchemaTypeNode_t    SchemaTypeNode;
struct SetDispNode_t;              typedef struct SetDispNode_t       SetDispNode;
struct SeqDispNode_t;              typedef struct SeqDispNode_t       SeqDispNode;
struct UptoNode_t;                 typedef struct UptoNode_t          UptoNode;
struct SetCompNode_t;              typedef struct SetCompNode_t       SetCompNode;
struct LambdaNode_t;               typedef struct LambdaNode_t        LambdaNode;
struct MuNode_t;                   typedef struct MuNode_t            MuNode;
struct LetExprNode_t;              typedef struct LetExprNode_t       LetExprNode;
struct ProcDefNode_t;              typedef struct ProcDefNode_t       ProcDefNode;
struct GenProcDefNode_t;           typedef struct GenProcDefNode_t    GenProcDefNode;
struct ProcAliasNode_t;            typedef struct ProcAliasNode_t     ProcAliasNode;
struct ChanAliasNode_t;            typedef struct ChanAliasNode_t     ChanAliasNode;
struct CondProcNode_t;             typedef struct CondProcNode_t      CondProcNode;
struct ChanFieldNode_t;            typedef struct ChanFieldNode_t     ChanFieldNode;
struct ChanApplNode_t;             typedef struct ChanApplNode_t      ChanApplNode;
struct ReplProcNode_t;             typedef struct ReplProcNode_t      ReplProcNode;
struct LetProcNode_t;              typedef struct LetProcNode_t       LetProcNode;

struct SymListStack_t;   typedef struct SymListStack_t  SymListStack;
struct SymbolList_t;     typedef struct SymbolList_t    SymbolList;
struct Symbol_t;         typedef struct Symbol_t        Symbol;

struct TreeType_t;     typedef struct TreeType_t     TreeType;
struct SchemaType_t;   typedef struct SchemaType_t   SchemaType;
struct BasicType_t;    typedef struct BasicType_t    BasicType;
struct GenType_t;      typedef struct GenType_t      GenType;
struct SetType_t;      typedef struct SetType_t      SetType;
struct TupleType_t;    typedef struct TupleType_t    TupleType;
struct SchemaEntry_t;  typedef struct SchemaEntry_t  SchemaEntry;

/* List structures */
struct LinkList_t
{
   struct LinkList_t  *next;
   struct LinkList_t  *prev;

   void  *object;
};

typedef struct LinkList_t  LinkList;


/* AST Structures */
struct SyntaxTree_t
{
   SymListStack  *symStack;
   TreeType      *treeType;
   TreeType      *specType;
   INT8          *ozTex;
   UINT16        nodeType;
};

typedef struct SyntaxTree_t  SyntaxTree;

struct ADocNode_t
{
   SymListStack  *symStack;
   TreeType      *treeType;
   TreeType      *specType;
   INT8          *ozTex;
   UINT16        nodeType;

   DocInfoNode  *info;
   LinkList     *paragraphs;
};

struct DocInfoNode_t
{
   SymListStack  *symStack;
   TreeType      *treeType;
   TreeType      *specType;
   INT8          *ozTex;
   UINT16        nodeType;

   LinkList  *infoEntries;
};

struct InfoEntryNode_t
{
   SymListStack  *symStack;
   TreeType      *treeType;
   TreeType      *specType;
   INT8          *ozTex;
   UINT16        nodeType;

   LinkList  *infoList;
};

struct PropertyNode_t
{
   SymListStack  *symStack;
   TreeType      *treeType;
   TreeType      *specType;
   INT8          *ozTex;
   UINT16        nodeType;

   LinkList  *propList;
};

struct ParagraphNode_t
{
   SymListStack  *symStack;
   TreeType      *treeType;
   TreeType      *specType;
   INT8          *ozTex;
   UINT16        nodeType;

   LinkList  *props;
};

struct DirectiveNode_t
{
   SymListStack  *symStack;
   TreeType      *treeType;
   TreeType      *specType;
   INT8          *ozTex;
   UINT16        nodeType;

   LinkList  *props;
   LinkList  *commands;
};

struct DescriptionNode_t
{
   SymListStack  *symStack;
   TreeType      *treeType;
   TreeType      *specType;
   INT8          *ozTex;
   UINT16        nodeType;

   LinkList  *props;
   INT8      *text;
};

struct BasicDefNode_t
{
   SymListStack  *symStack;
   TreeType      *treeType;
   TreeType      *specType;
   INT8          *ozTex;
   UINT16        nodeType;

   LinkList  *props;
   LinkList  *entries;
   INT8      *name;
};

struct BasicEntryNode_t
{
   SymListStack  *symStack;
   TreeType      *treeType;
   TreeType      *specType;
   INT8          *ozTex;
   UINT16        nodeType;

   LinkList  *props;
   INT8      *name;
};

struct TypeDefNode_t
{
   SymListStack  *symStack;
   TreeType      *treeType;
   TreeType      *specType;
   INT8          *ozTex;
   UINT16        nodeType;

   LinkList  *props;
   LinkList  *entries;
   INT8      *name;
};

struct TypeEntryNode_t
{
   SymListStack  *symStack;
   TreeType      *treeType;
   TreeType      *specType;
   INT8          *ozTex;
   UINT16        nodeType;

   LinkList    *props;
   SyntaxTree  *defExpr;
   INT8        *name;
   INT8        *preGen;
   INT8        *postGen;
};

struct FreeTypeNode_t
{
   SymListStack  *symStack;
   TreeType      *treeType;
   TreeType      *specType;
   INT8          *ozTex;
   UINT16        nodeType;

   LinkList  *props;
   LinkList  *entries;
   INT8      *name;
};

struct FreeEntryNode_t
{
   SymListStack  *symStack;
   TreeType      *treeType;
   TreeType      *specType;
   INT8          *ozTex;
   UINT16        nodeType;

   LinkList  *props;
   LinkList  *freeVars;
   INT8      *name;
};

struct AxDefNode_t
{
   SymListStack  *symStack;
   TreeType      *treeType;
   TreeType      *specType;
   INT8          *ozTex;
   UINT16        nodeType;

   LinkList  *props;
   LinkList  *decls;
   LinkList  *preds;
   INT8      *name;
};

struct GenDefNode_t
{
   SymListStack  *symStack;
   TreeType      *treeType;
   TreeType      *specType;
   INT8          *ozTex;
   UINT16        nodeType;

   LinkList  *props;
   LinkList  *decls;
   LinkList  *preds;
   INT8      *name;
   LinkList  *syms;  /* Placed last to allow AxDef and GenDef to be otherwise identical */
};

struct SchemaNode_t
{
   SymListStack  *symStack;
   TreeType      *treeType;
   TreeType      *specType;
   INT8          *ozTex;
   UINT16        nodeType;

   LinkList  *props;
   LinkList  *decls;
   LinkList  *preds;
   INT8      *name;
};

struct GenSchemaNode_t
{
   SymListStack  *symStack;
   TreeType      *treeType;
   TreeType      *specType;
   INT8          *ozTex;
   UINT16        nodeType;

   LinkList  *props;
   LinkList  *decls;
   LinkList  *preds;
   INT8      *name;
   LinkList  *syms;  /* Placed last to allow Schema and GenSchema to be otherwise identical */
};

struct ConstraintNode_t
{
   SymListStack  *symStack;
   TreeType      *treeType;
   TreeType      *specType;
   INT8          *ozTex;
   UINT16        nodeType;

   LinkList  *props;
   LinkList  *preds;
   INT8      *name;
};

struct ProcessNode_t
{
   SymListStack  *symStack;
   TreeType      *treeType;
   TreeType      *specType;
   INT8          *ozTex;
   UINT16        nodeType;

   LinkList  *props;
   LinkList  *decls;
   LinkList  *procs;
   INT8      *name;
};

struct DeclarationNode_t
{
   SymListStack  *symStack;
   TreeType      *treeType;
   TreeType      *specType;
   INT8          *ozTex;
   UINT16        nodeType;

   LinkList    *props;
   SyntaxTree  *defExpr;
   DeclType    declType;
   void        *ident;
   LinkList    *genSyms;
};

struct PredicateNode_t
{
   SymListStack  *symStack;
   TreeType      *treeType;
   TreeType      *specType;
   INT8          *ozTex;
   UINT16        nodeType;

   LinkList    *props;
   SyntaxTree  *predNode;
};

struct PredOpNode_t
{
   SymListStack  *symStack;
   TreeType      *treeType;
   TreeType      *specType;
   INT8          *ozTex;
   UINT16        nodeType;

   SyntaxTree  *left;
   SyntaxTree  *right;
   INT8        *opName;
};

struct PredRelNode_t
{
   SymListStack  *symStack;
   TreeType      *treeType;
   TreeType      *specType;
   INT8          *ozTex;
   UINT16        nodeType;

   SyntaxTree  *left;
   SyntaxTree  *right;
   INT8        *opName;
};

struct PredFuncNode_t
{
   SymListStack  *symStack;
   TreeType      *treeType;
   TreeType      *specType;
   INT8          *ozTex;
   UINT16        nodeType;

   SyntaxTree  *params;
   INT8        *funcName;
};

struct PredLiteralNode_t
{
   SymListStack  *symStack;
   TreeType      *treeType;
   TreeType      *specType;
   INT8          *ozTex;
   UINT16        nodeType;

   INT8    *value;
};

struct PredQuantNode_t
{
   SymListStack  *symStack;
   TreeType      *treeType;
   TreeType      *specType;
   INT8          *ozTex;
   UINT16        nodeType;

   LinkList  *decls;
   LinkList  *filters;
   LinkList  *preds;
   INT8      *quantName;
};

struct LetPredNode_t
{
   SymListStack  *symStack;
   TreeType      *treeType;
   TreeType      *specType;
   INT8          *ozTex;
   UINT16        nodeType;

   LinkList  *decls;
   LinkList  *preds;
};

struct SchemaAppNode_t
{
   SymListStack  *symStack;
   TreeType      *treeType;
   TreeType      *specType;
   INT8          *ozTex;
   UINT16        nodeType;

   SyntaxTree  *preCond;
   SyntaxTree  *command;
   SyntaxTree  *postCond;
   UINT8       strictFlag;
};

struct CondPredNode_t
{
   SymListStack  *symStack;
   TreeType      *treeType;
   TreeType      *specType;
   INT8          *ozTex;
   UINT16        nodeType;

   LinkList  *condList;
   LinkList  *thenList;
   LinkList  *elseList;
};

struct ExprNode_t
{
   SymListStack  *symStack;
   TreeType      *treeType;
   TreeType      *specType;
   INT8          *ozTex;
   UINT16        nodeType;

   LinkList  *props;
};

struct ExprOpNode_t
{
   SymListStack  *symStack;
   TreeType      *treeType;
   TreeType      *specType;
   INT8          *ozTex;
   UINT16        nodeType;

   LinkList    *props;
   SyntaxTree  *left;
   SyntaxTree  *right;
   INT8        *opName;
   SyntaxTree  *qualifier;
};

struct ExprFuncNode_t
{
   SymListStack  *symStack;
   TreeType      *treeType;
   TreeType      *specType;
   INT8          *ozTex;
   UINT16        nodeType;

   LinkList    *props;
   SyntaxTree  *funcExpr;
   SyntaxTree  *params;
};

struct VariableNode_t
{
   SymListStack  *symStack;
   TreeType      *treeType;
   TreeType      *specType;
   INT8          *ozTex;
   UINT16        nodeType;

   LinkList   *props;
   DecorType  postDecor;
   INT8       *name;
   UINT8      postCnt;
};

struct ExprLiteralNode_t
{
   SymListStack  *symStack;
   TreeType      *treeType;
   TreeType      *specType;
   INT8          *ozTex;
   UINT16        nodeType;

   LinkList  *props;
   INT8      *value;
};

struct ExprIdentNode_t
{
   SymListStack  *symStack;
   TreeType      *treeType;
   TreeType      *specType;
   INT8          *ozTex;
   UINT16        nodeType;

   LinkList    *props;
   SyntaxTree  *preSpec;
   SyntaxTree  *postSpec;
   LinkList    *specList;
   INT8        *ident;
};

struct ExprGenIdentNode_t
{
   SymListStack  *symStack;
   TreeType      *treeType;
   TreeType      *specType;
   INT8          *ozTex;
   UINT16        nodeType;

   LinkList  *props;
   INT8      *ident;
};

struct CondExprNode_t
{
   SymListStack  *symStack;
   TreeType      *treeType;
   TreeType      *specType;
   INT8          *ozTex;
   UINT16        nodeType;

   LinkList    *props;
   SyntaxTree  *thenExpr;
   SyntaxTree  *elseExpr;
   LinkList    *condList;
};

struct TupleNode_t
{
   SymListStack  *symStack;
   TreeType      *treeType;
   TreeType      *specType;
   INT8          *ozTex;
   UINT16        nodeType;

   LinkList  *props;
   LinkList  *exprList;
};

struct CrossNode_t
{
   SymListStack  *symStack;
   TreeType      *treeType;
   TreeType      *specType;
   INT8          *ozTex;
   UINT16        nodeType;

   LinkList  *props;
   LinkList  *exprList;
};

struct SchemaBindNode_t
{
   SymListStack  *symStack;
   TreeType      *treeType;
   TreeType      *specType;
   INT8          *ozTex;
   UINT16        nodeType;

   LinkList  *props;
   LinkList  *bindList;
   INT8      hideNode;
};

struct BindEntryNode_t
{
   SymListStack  *symStack;
   TreeType      *treeType;
   TreeType      *specType;
   INT8          *ozTex;
   UINT16        nodeType;

   LinkList      *props;
   VariableNode  *var;
   SyntaxTree    *expr;
   INT8          hideEntry;
};

struct SelectNode_t
{
   SymListStack  *symStack;
   TreeType      *treeType;
   TreeType      *specType;
   INT8          *ozTex;
   UINT16        nodeType;

   LinkList      *props;
   SyntaxTree    *leftExpr;
   VariableNode  *var;
};

struct SchemaTypeNode_t
{
   SymListStack  *symStack;
   TreeType      *treeType;
   TreeType      *specType;
   INT8          *ozTex;
   UINT16        nodeType;

   LinkList   *props;
   DecorType  preDecor;
   DecorType  postDecor;
   LinkList   *decls;
   LinkList   *expDecls;
   LinkList   *specList;
   LinkList   *filters;
   INT8       *refName;
   UINT8      preCnt;
   UINT8      postCnt;
};

struct SetDispNode_t
{
   SymListStack  *symStack;
   TreeType      *treeType;
   TreeType      *specType;
   INT8          *ozTex;
   UINT16        nodeType;

   LinkList  *props;
   LinkList  *exprList;
};

struct SeqDispNode_t
{
   SymListStack  *symStack;
   TreeType      *treeType;
   TreeType      *specType;
   INT8          *ozTex;
   UINT16        nodeType;

   LinkList  *props;
   LinkList  *exprList;
};

struct UptoNode_t
{
   SymListStack  *symStack;
   TreeType      *treeType;
   TreeType      *specType;
   INT8          *ozTex;
   UINT16        nodeType;

   LinkList    *props;
   SyntaxTree  *startExpr;
   SyntaxTree  *endExpr;
};

struct SetCompNode_t
{
   SymListStack  *symStack;
   TreeType      *treeType;
   TreeType      *specType;
   INT8          *ozTex;
   UINT16        nodeType;

   LinkList    *props;
   SyntaxTree  *expr;
   LinkList    *decls;
   LinkList    *filters;
};

struct LambdaNode_t
{
   SymListStack  *symStack;
   TreeType      *treeType;
   TreeType      *specType;
   INT8          *ozTex;
   UINT16        nodeType;

   LinkList    *props;
   SyntaxTree  *expr;
   LinkList    *decls;
   LinkList    *filters;
   LinkList    *expDecls;
};

struct MuNode_t
{
   SymListStack  *symStack;
   TreeType      *treeType;
   TreeType      *specType;
   INT8          *ozTex;
   UINT16        nodeType;

   LinkList    *props;
   SyntaxTree  *expr;
   LinkList    *decls;
   LinkList    *filters;
};

struct LetExprNode_t
{
   SymListStack  *symStack;
   TreeType      *treeType;
   TreeType      *specType;
   INT8          *ozTex;
   UINT16        nodeType;

   LinkList    *props;
   SyntaxTree  *expr;
   LinkList    *decls;
};

struct ProcDefNode_t
{
   SymListStack  *symStack;
   TreeType      *treeType;
   TreeType      *specType;
   INT8          *ozTex;
   UINT16        nodeType;

   LinkList    *props;
   INT8        *procName;
   SyntaxTree  *defExpr;
   LinkList    *decls;
};

struct GenProcDefNode_t
{
   SymListStack  *symStack;
   TreeType      *treeType;
   TreeType      *specType;
   INT8          *ozTex;
   UINT16        nodeType;

   LinkList    *props;
   INT8        *procName;
   SyntaxTree  *defExpr;
   LinkList    *decls;
   LinkList    *syms;  /* Placed last to allow ProcDef and GenProcDef to be otherwise identical */
};

struct ProcAliasNode_t
{
   SymListStack  *symStack;
   TreeType      *treeType;
   TreeType      *specType;
   INT8          *ozTex;
   UINT16        nodeType;

   LinkList    *props;
   SyntaxTree  *defExpr;
   INT8        *name;
};

struct ChanAliasNode_t
{
   SymListStack  *symStack;
   TreeType      *treeType;
   TreeType      *specType;
   INT8          *ozTex;
   UINT16        nodeType;

   LinkList    *props;
   SyntaxTree  *defExpr;
   INT8        *name;
};

struct CondProcNode_t
{
   SymListStack  *symStack;
   TreeType      *treeType;
   TreeType      *specType;
   INT8          *ozTex;
   UINT16        nodeType;

   LinkList    *props;
   SyntaxTree  *thenProc;
   SyntaxTree  *elseProc;
   LinkList    *condList;
};

struct ChanFieldNode_t
{
   SymListStack  *symStack;
   TreeType      *treeType;
   TreeType      *specType;
   INT8          *ozTex;
   UINT16        nodeType;

   LinkList    *props;
   SyntaxTree  *fieldExpr;
   UINT16      fieldType;
};

struct ChanApplNode_t
{
   SymListStack  *symStack;
   TreeType      *treeType;
   TreeType      *specType;
   INT8          *ozTex;
   UINT16        nodeType;

   LinkList    *props;
   SyntaxTree  *chanExpr;
   LinkList    *fields;
};

struct ReplProcNode_t
{
   SymListStack  *symStack;
   TreeType      *treeType;
   TreeType      *specType;
   INT8          *ozTex;
   UINT16        nodeType;

   LinkList    *props;
   SyntaxTree  *expr;
   LinkList    *decls;
   LinkList    *filters;
   UINT16      replType;
   SyntaxTree  *ifAlph;
};

struct LetProcNode_t
{
   SymListStack  *symStack;
   TreeType      *treeType;
   TreeType      *specType;
   INT8          *ozTex;
   UINT16        nodeType;

   LinkList    *props;
   SyntaxTree  *expr;
   LinkList    *decls;
};

/* Symbol structures */
struct Symbol_t
{
   SyntaxTree  *synTree;
   INT8        *symName;
   int         symType;
};

struct SymbolList_t
{
   SymbolList  *next;
   Symbol      *symbol;
};

struct SymListStack_t
{
   SymListStack  *prev;
   SymbolList    *current;
   UINT32        currentSize;
   UINT8         globalDecl;
};


/* Type checking structures */
struct TreeType_t
{
   NodeType  nodeType;
};

struct SchemaType_t
{
   NodeType  nodeType;
   LinkList  *typeList;
};

struct SchemaEntry_t
{
   NodeType  nodeType;
   TreeType  *entryType;
   INT8      *entryID;
};

struct BasicType_t
{
   NodeType  nodeType;
   INT8      *basicID;
};

struct GenType_t
{
   NodeType  nodeType;
   INT8      *genID;
};

struct SetType_t
{
   NodeType  nodeType;
   TreeType  *setType;
};

struct TupleType_t
{
   NodeType  nodeType;
   LinkList  *typeList;
};

struct GenSubEntry_t
{
   TreeType  *subType;
   INT8      *genID;
};

typedef struct GenSubEntry_t  GenSubEntry;

#endif /* a_specc_types_h */
