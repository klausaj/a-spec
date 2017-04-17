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

#ifndef a_specc_api_h
#define a_specc_api_h

#include "a-specc/a-specc_types.h"

DecorType extractDecorType(INT8 *decor);
UINT8 extractDecorCount(INT8 *decor);

LinkList *createLinkList(void *headObj);
LinkList *copyLinkList(LinkList *list);
LinkList *getListTail(LinkList *list);
UINT8 appendLinkList(LinkList *list, void *nextObj);
UINT8 conLinkList(LinkList *list, LinkList *newTail);
UINT32 sizeLinkList(LinkList *list);
void freeLinkList(LinkList *list);
UINT8 isInList(void *object, LinkList *list, UINT8 (*cmpFunc)(void *obj1, void *obj2));

UINT8 strEquals(void *str1, void *str2);

AToken *createAToken(INT8 *preFmt, INT8 *tokVal);
void freeAToken(AToken *tok);

/* Syntax tree functions */
ADocNode *createADocNode(DocInfoNode *info, LinkList *paragraphs);
DocInfoNode *createDocInfoNode(LinkList *infoEntries);
InfoEntryNode *createInfoEntryNode(LinkList *infoList);
PropertyNode *createPropertyNode(LinkList *propList);
DirectiveNode *createDirectiveNode(LinkList *props, LinkList *commands);
DescriptionNode *createDescriptionNode(LinkList *props, INT8 *text);
BasicDefNode *createBasicDefNode(LinkList *props, LinkList *basicList, INT8 *name);
BasicEntryNode *createBasicEntryNode(LinkList *props, INT8 *typeName);
TypeDefNode *createTypeDefNode(LinkList *props, LinkList *typeList, INT8 *name);
TypeEntryNode *createTypeEntryNode(INT8 *typeName, SyntaxTree *defExpr);
TypeEntryNode *createGenTypeEntryNode(INT8 *typeName, SyntaxTree *defExpr, INT8 *preGen, INT8 *postGen);
FreeTypeNode *createFreeTypeNode(LinkList *props, LinkList *typeList, INT8 *name);
FreeEntryNode *createFreeEntryNode(LinkList *props, INT8 *typeName, LinkList *varList);
AxDefNode *createAxDefNode(LinkList *props, LinkList *decls, LinkList *preds, INT8 *name);
GenDefNode *createGenDefNode(LinkList *props, LinkList *syms, LinkList *decls, LinkList *preds, INT8 *name);
SchemaNode *createSchemaNode(LinkList *props, LinkList *decls, LinkList *preds, INT8 *name);
GenSchemaNode *createGenSchemaNode(LinkList *props, LinkList *syms, LinkList *decls, LinkList *preds, INT8 *name);
ConstraintNode *createConstraintNode(LinkList *props, LinkList *preds, INT8 *name);
ProcessNode *createProcessNode(LinkList *props, LinkList *decls, LinkList *procs, INT8 *name);
DeclarationNode *createDeclarationNode(LinkList *props, DeclType declType, void *ident, SyntaxTree *defExpr);
PredicateNode *createPredicateNode(LinkList *props, SyntaxTree *predNode);
PredOpNode *createPredOpNode(SyntaxTree *left, INT8 *opName, SyntaxTree *right);
PredRelNode *createPredRelNode(SyntaxTree *left, INT8 *opName, SyntaxTree *right);
PredFuncNode *createPredFuncNode(INT8 *funcName, SyntaxTree *params);
PredLiteralNode *createPredLiteralNode(INT8 *value);
PredQuantNode *createPredQuantNode(INT8 *quantName, LinkList *decls, LinkList *filters, LinkList *preds);
LetPredNode *createLetPredNode(LinkList *decls, LinkList *preds);
SchemaAppNode *createSchemaAppNode(SyntaxTree *preCond, SyntaxTree *command, SyntaxTree *postCond, UINT8 strictFlag);
CondPredNode *createCondPredNode(LinkList *condList, LinkList *thenList, LinkList *elseList);
ExprOpNode *createExprOpNode(SyntaxTree *left, INT8 *opName, SyntaxTree *right);
ExprFuncNode *createExprFuncNode(SyntaxTree *funcExpr, SyntaxTree *params);
VariableNode *createVariableNode(INT8 *varName, INT8 *postDecor);
INT8 *varToString(VariableNode *var);
ExprLiteralNode *createExprLiteralNode(INT8 *value);
ExprIdentNode *createExprIdentNode(INT8 *ident);
ExprIdentNode *createExprSpecIdentNode(INT8 *ident, SyntaxTree *preExpr, SyntaxTree *postExpr);
ExprGenIdentNode *createExprGenIdentNode(INT8 *ident);
CondExprNode *createCondExprNode(LinkList *condList, SyntaxTree *thenExpr, SyntaxTree *elseExpr);
TupleNode *createTupleNode(LinkList *exprList);
CrossNode *createCrossNode(LinkList *exprList);
SchemaBindNode *createSchemaBindNode(LinkList *bindList);
BindEntryNode *createBindEntryNode(VariableNode *var, SyntaxTree *bindExpr);
SelectNode *createSelectNode(SyntaxTree *leftExpr, VariableNode *var);
SchemaTypeNode *createSchemaTypeNode(LinkList *decls, LinkList *filters, INT8 *preDecor, INT8 *postDecor);
SchemaTypeNode *createSchemaTypeFromRef(INT8 *refName, INT8 *preDecor, INT8 *postDecor);
SetDispNode *createSetDispNode(LinkList *exprList);
SeqDispNode *createSeqDispNode(LinkList *exprList);
UptoNode *createUptoNode(SyntaxTree *startExpr, SyntaxTree *endExpr);
SetCompNode *createSetCompNode(LinkList *decls, LinkList *filters, SyntaxTree *expr);
LambdaNode *createLambdaNode(LinkList *decls, LinkList *filters, SyntaxTree *expr);
MuNode *createMuNode(LinkList *decls, LinkList *filters, SyntaxTree *expr);
LetExprNode *createLetExprNode(LinkList *decls, SyntaxTree *expr);
ProcDefNode *createProcDefNode(INT8 *procName, LinkList *decls, SyntaxTree *defExpr);
GenProcDefNode *createGenProcDefNode(INT8 *procName, LinkList *decls, SyntaxTree *defExpr, LinkList *genSyms);
ProcAliasNode *createProcAliasNode(INT8 *procName, SyntaxTree *defExpr);
ChanAliasNode *createChanAliasNode(INT8 *chanName, SyntaxTree *defExpr);
CondProcNode *createCondProcNode(LinkList *condList, SyntaxTree *thenExpr, SyntaxTree *elseExpr);
ChanFieldNode *createChanFieldNode(UINT16 fieldType, SyntaxTree *fieldExpr);
ChanApplNode *createChanApplNode(SyntaxTree *chanExpr, LinkList *fields);
ReplProcNode *createReplProcNode(UINT16 replType, LinkList *decls, LinkList *filters, SyntaxTree *expr);
LetProcNode *createLetProcNode(LinkList *decls, SyntaxTree *expr);

LinkList *getProperty(LinkList *props, INT8 *propID);
INT8 *getLayer(LinkList *props);
UINT8 exportCheck(INT8 *layerID);
UINT8 excludeCheck(INT8 *layerID);
LinkList *getCommand(LinkList *commandList, INT8 *commandID);

TreeType *createNullTreeType();
TreeType *createSchemaTreeType(LinkList *typeList);
TreeType *createSchemaTreeTypeFromBindList(LinkList *bindList);
TreeType *createBasicTreeType(INT8 *basicID);
TreeType *createGenTreeType(INT8 *genID);
TreeType *createSetTreeType(TreeType *setType);
TreeType *createTupleTreeType(LinkList *exprList, UINT8 useBoundType);
TreeType *createTupleTreeTypeFromDecls(LinkList *declList);

TreeType *copyTypeTree(TreeType *src);
void freeTypeTree(TreeType *typeTree);

LinkList *createSubList(TreeType *genTree, TreeType *specTree);
LinkList *createGenSchSubList(SchemaTypeNode *schType);
LinkList *createGenPatchList(LinkList *genList, LinkList *specList);
TreeType *substituteGen(TreeType *src, LinkList *subList);
INT8 compareGenSyms(LinkList *gen1, LinkList *gen2);
void freeSubList(LinkList *subList);

TreeType *unprimeSchema(TreeType *src);
TreeType *preSchema(TreeType *src);
TreeType *postSchema(TreeType *src);
TreeType *inSchema(TreeType *src);
TreeType *outSchema(TreeType *src);

void printType(INT8 *ident, TreeType *src);
INT8* treeTypeToStr(TreeType *src);

LinkList *getTypeList(LinkList *declList);
TreeType *getExprType(SyntaxTree *ast);
TreeType *getTypeBoundType(TreeType *treeType);
TreeType *getFuncAppliedType(TreeType *treeType);
TreeType *getFuncParamType(TreeType *treeType);
TreeType *getBoundSchemaType(TreeType *treeType);
LinkList *typeExprList(LinkList *exprList, UINT8 useBoundType);

UINT8 isSchemaTypeExpr(SyntaxTree *expr);
UINT8 isSchemaBindExpr(SyntaxTree *expr);
UINT8 isIntExpr(SyntaxTree *expr);
UINT8 isFuncExpr(SyntaxTree *expr);
UINT8 isRelExpr(SyntaxTree *expr);
UINT8 isSetList(LinkList *typeList);
UINT8 isSetExpr(SyntaxTree *expr);
UINT8 isEventExpr(SyntaxTree *expr);
UINT8 isEventSetExpr(SyntaxTree *expr);
UINT8 isProcessExpr(SyntaxTree *expr);
UINT8 isChannelExpr(SyntaxTree *expr);
UINT8 isProcRenExpr(SyntaxTree *expr);

TreeType *joinSchemaTypes(SchemaType *lSch, SchemaType *rSch);
UINT8 typeCompare(TreeType *type1, TreeType *type2);
UINT8 typeCompatible(SchemaType *lSch, SchemaType *rSch);
UINT8 validateParams(TreeType *funcType, TreeType *inParam);
UINT8 validateRelParams(TreeType *relType, TreeType *inParam);

SyntaxTree *handleFuncApp(SyntaxTree *funcExpr, SyntaxTree *param);
SyntaxTree *handleFInOp(SyntaxTree *left, INT8 *opName, SyntaxTree *right);
SyntaxTree *handleFPreOp(INT8 *opName, SyntaxTree *right);
SyntaxTree *handleFPostOp(SyntaxTree *left, INT8 *opName);
SyntaxTree *handleRelFunc(INT8 *funcName, SyntaxTree *param);
SyntaxTree *handleRInOp(SyntaxTree *left, INT8 *opName, SyntaxTree *right);
SyntaxTree *handleRPreOp(INT8 *opName, SyntaxTree *right);
SyntaxTree *handleRPostOp(SyntaxTree *left, INT8 *opName);
SyntaxTree *handleSchemaHide(SyntaxTree *left, SyntaxTree *right);
SyntaxTree *handleSchemaOver(SyntaxTree *left, SyntaxTree *right);

SyntaxTree *handleProcessRename(SyntaxTree *left, SyntaxTree *right);

INT8 processChanAppl(LinkList *chanList, LinkList *paramList);

#ifdef DO_DEBUG
   #define DEBUG(...) printf(__VA_ARGS__)
#else
   #define DEBUG(...)
#endif

#define LINE_BUF_SIZE   8192
#define ERR_INDENT      "   "

extern SymListStack  *symStack;    /* from a-specc.h */
extern SymbolList    *globalTable; /* from a-specc.h */
extern LinkList      *importList;  /* from a-specc.h */
extern ADocNode      *docAST;      /* from a-specc.h */

extern UINT16  acceptLen;               /* from a-specc.h */
extern UINT16  prevLen;                 /* from a-specc.h */
extern UINT16  curLen;                  /* from a-specc.h */
extern UINT8   errors;                  /* from a-specc.h */
extern UINT8   tmpCh;                   /* from a-specc.h */
extern UINT8   a2OzTex;                 /* from a-specc.h */
extern UINT8   a2ATex;                  /* from a-specc.h */
extern UINT8   aTabGroup;               /* from a-specc.h */
extern UINT8   aIndent;                 /* from a-specc.h */
extern UINT8   xmlIndent;               /* from a-specc.h */
extern UINT8   exportType;              /* from a-specc.h */
extern UINT8   maxErrors;               /* from a-specc.h */
extern INT8    lineBuf[LINE_BUF_SIZE];  /* from a-specc.h */
extern INT8    *curFile;                /* from a-specc.h */
extern INT8    *curFmt;                 /* from a-specc.h */
extern INT8    *outLayers;              /* from a-specc.h */
extern INT8    *exLayers;               /* from a-specc.h */

extern int     yylineno;                /* from lexer */
extern int     yyleng;                  /* from lexer */

void yyerror(const char *fmt, ...);
void yyuerror(const char *fmt, ...);
void yyferror(const char *fmt, ...);

UINT8 newFile(INT8 *filePath);
UINT8 importFile(INT8 *fileName);
UINT8 popFile();

UINT8 initSymStack();
UINT8 pushSymStack(UINT8 globalDecl, void (*errFunc)(const char *fmt, ...));
UINT8 popSymStack();
UINT8 addSymToTable(INT8 *symName, int symType, SyntaxTree *syn);
UINT8 addSymToLocal(INT8 *symName, int symType, SyntaxTree *syn);
UINT8 addSymToGlobal(INT8 *symName, int symType, SyntaxTree *syn);
Symbol *lookup(SymbolList *tablePtr, INT8 *symName);
Symbol *symLookup(INT8 *symName, void (*errFunc)(const char *fmt, ...));
int getOpSymType(INT8 *opSig, INT8 *opType);
void freeSymbol(Symbol *symObj);

UINT8 addDeclsToSymTab(LinkList *declList);

void initFormat();
void clearFormat();
void addFormat(INT8 *addFmt);

LinkList *getSchemaDecls(SchemaTypeNode *schType);
LinkList *expand(DecorType pre, UINT8 preCnt, DecorType post, UINT8 postCnt, LinkList *declList, LinkList *subList);

#endif /* a_specc_api_h */
