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
#include <string.h>
#include <stdlib.h>
#include <stdio.h>

#include "a-specc/a-specc_types.h"
#include "a-specc/a-specc_api.h"
#include "a-translate/a2oztex.h"

static INT8  *tmpStr = NULL;
static INT8  *curSch = NULL;
static INT8  procDef = 0;

static void clearCurSch()
{
   if(curSch != NULL)
   {
      free(curSch);

      curSch = NULL;
   }
}
%}

%union
{
   AToken  *atok;
   INT8   *fmt;
   void    *voidptr;
}
/*
   Removed for compatibility with old version of Bison
%destructor
{
   if($$ != NULL)
   {
      AToken  *atok = (AToken *) $$;

      if(atok->preFmt != NULL)
      {
         free(atok->preFmt);
      }

      if(atok->token != NULL)
      {
         free(atok->token);
      }

      free(atok);
   }
} <atok>

%destructor
{
   if($$ != NULL) free($$);
} <fmt>

%locations
*/

%token <atok> TOK_TEXT TOK_NUMBER TOK_STRING TOK_CHAR
%token <atok> TOK_OP_TYPE
%token <atok> TOK_DATA_TYPE TOK_VAR_BINDING TOK_GEN_TYPE
%token <atok> TOK_SCH_NAME TOK_EXPR_FUNC TOK_PRED_FUNC TOK_GEN_SYM TOK_PAR_ID TOK_GEN_SCHEMA
%token <atok> TOK_IDENT TOK_WORD
%token <atok> TOK_P1FIN TOK_P1FPRE TOK_P1FPOST TOK_P1RIN TOK_P1RPRE TOK_P1RPOST
%token <atok> TOK_P2FIN TOK_P2FPRE TOK_P2FPOST TOK_P2RIN TOK_P2RPRE TOK_P2RPOST
%token <atok> TOK_P3FIN TOK_P3FPRE TOK_P3FPOST TOK_P3RIN TOK_P3RPRE TOK_P3RPOST
%token <atok> TOK_P4FIN TOK_P4FPRE TOK_P4FPOST TOK_P4RIN TOK_P4RPRE TOK_P4RPOST
%token <atok> TOK_P5FIN TOK_P5FPRE TOK_P5FPOST TOK_P5RIN TOK_P5RPRE TOK_P5RPOST
%token <atok> TOK_P6FIN TOK_P6FPRE TOK_P6FPOST TOK_P6RIN TOK_P6RPRE TOK_P6RPOST
%token <atok> TOK_P7FIN TOK_P7FPRE TOK_P7FPOST TOK_P7RIN TOK_P7RPRE TOK_P7RPOST
%token <atok> TOK_P8FIN TOK_P8FPRE TOK_P8FPOST TOK_P8RIN TOK_P8RPRE TOK_P8RPOST
%token <atok> TOK_P9FIN TOK_P9FPRE TOK_P9FPOST TOK_P9RIN TOK_P9RPRE TOK_P9RPOST
%token <atok> TOK_PRE_DECOR TOK_POST_DECOR

%token <atok> TOK_PROCESS TOK_EVENT TOK_CHANNEL TOK_GEN_CHANNEL TOK_PROC_FUNC TOK_GEN_PROC_FUNC
              TOK_PROC_VAR

%token <fmt> TOK_TRUE TOK_FALSE TOK_POUND
%token <fmt> TOK_SEMICOLON TOK_COLON TOK_COMMA TOK_QUEST TOK_EXCLAIM TOK_AT TOK_EQUALS
%token <fmt> TOK_OSQUARE TOK_CSQUARE TOK_OPAREN TOK_CPAREN TOK_OCURLY TOK_CCURLY
%token <fmt> TOK_ALL TOK_EXIST TOK_UNIQ TOK_SET_COMP TOK_LAMBDA TOK_MU TOK_LET
%token <fmt> TOK_IF TOK_THEN TOK_ELSE TOK_ELIF TOK_ENDIF TOK_WHERE TOK_BLOCK_END
%token <fmt> TOK_SET_DISP TOK_SEQ_DISP TOK_CROSS TOK_UPTO
%token <fmt> TOK_SCH_TYPE TOK_SCH_BIND TOK_SCH_OVER
%token <fmt> TOK_PERIOD
%token <fmt> TOK_EQUIV TOK_IMPLIES
%token <fmt> TOK_SOR TOK_SAND TOK_LOR TOK_LAND
%token <fmt> TOK_MULT TOK_PLUS TOK_MINUS TOK_SNOT TOK_EXPON
%token <fmt> TOK_ZPRE TOK_ZPOST TOK_ZUNP TOK_ZTYPE TOK_ZPROJ TOK_ZHIDE TOK_ZIN
%token <fmt> TOK_FUNC_ID TOK_OPER_ID TOK_REL_ID TOK_BOOL_ID TOK_ZOUT TOK_ZXI

%type <fmt> tok_if tok_endif tok_oparen tok_cparen

%token <fmt> TOK_INTERNAL TOK_EXTERNAL TOK_PTHEN TOK_PROC_ID TOK_CHAN_ID TOK_IF_PARALLEL
%token <fmt> TOK_PROC_START TOK_INTERLEAVE TOK_INTERRUPT TOK_PSEQ TOK_PHIDE TOK_OIF_PAR
%token <fmt> TOK_CIF_PAR TOK_PREN

%token TOK_INFO_START TOK_INFO_END TOK_PROP_START TOK_PROP_END
%token TOK_SCH_START TOK_BASIC_START
%token TOK_TYPE_START TOK_FREE_START
%token TOK_AXDEF_START TOK_CONST_START
%token TOK_GENDEF_START TOK_GENSCH_START
%token TOK_DESC_START TOK_DESC_END TOK_DIREC_START TOK_DIREC_END

%type <atok> par_id sch_pre_decor sch_post_decor var_post_decor sch_name all_words
%type <atok> gen_term var_ident
%type <atok> text_tokens in_rel pre_rel post_rel in_op pre_op post_op pout_ident

%type <voidptr> doc_info info_list info_entry prop prop_list prop_entry word_list
%type <voidptr> sch_ref expr_list
%type <voidptr> expr_list1 expr_list2 expr bexp schema_app hide_entries hide_entry
%type <voidptr> hide_list
%type <voidptr> tuple set_disp seq_disp cross set_comp lambda mu let_expr sch_type
%type <voidptr> sch_bind bind_list bind_entry let_list let_entry let_decl
%type <voidptr> bind cond_exp elif_exp decl_list1 decl_entry decl_type post_props
%type <voidptr> post_prop
%type <voidptr> dsch_ref var_decl func_decl op_decl pred pred_list0 pred_list pred_entry
%type <voidptr> pred_type
%type <voidptr> quantifier all_quant exist_quant uniq_quant let_pred cond_pred elif_pred
%type <voidptr> paragraphs paragraph
%type <voidptr> schema basic basic_list basic_entry type type_list type_entry type_decl
%type <voidptr> free free_list free_entry free_decl free_vars free_var axdef const
%type <voidptr> gen_field gen_list
%type <voidptr> gendef gensch desc direc dir_list dir_entry schema_hdr gensch_hdr
%type <voidptr> zexpr

%type <voidptr> process proc_decls0 proc_decls1 proc_decl pdecl_type pdecl_list1
%type <voidptr> pvar_decl proc_list0 proc_list1
%type <voidptr> proc_entry proc_def_hdr proc_oper internal external interleave
%type <voidptr> parallel if_parallel pfunc_appl
%type <voidptr> proc_cond elif_proc chan_field chan_fields1 chan_appl pout_types
%type <voidptr> internal_hdr external_hdr
%type <voidptr> interleave_hdr parallel_hdr interrupt psdecl_list1 process_hdr internal_sch
%type <voidptr> external_sch parallel_sch interleave_sch if_parallel_hdr if_parallel_sch
%type <voidptr> let_proc let_proc_hdr bcspexp cspexp

%right     TOK_EXPR
%right     TOK_POUND
%nonassoc  TOK_UPTO
%right     TOK_P1FIN TOK_P1FPRE TOK_P1FPOST TOK_P1RIN TOK_P1RPRE TOK_P1RPOST
           TOK_EQUIV TOK_IMPLIES
%left      TOK_P2FIN TOK_P2FPRE TOK_P2FPOST TOK_P2RIN TOK_P2RPRE TOK_P2RPOST
           TOK_LOR TOK_SOR TOK_PREN
%left      TOK_P3FIN TOK_P3FPRE TOK_P3FPOST TOK_P3RIN TOK_P3RPRE TOK_P3RPOST
           TOK_LAND TOK_SAND
%right     TOK_P4FIN TOK_P4FPRE TOK_P4FPOST TOK_P4RIN TOK_P4RPRE TOK_P4RPOST
           TOK_EQUALS TOK_GEN_TYPE
%left      TOK_P5FIN TOK_P5FPRE TOK_P5FPOST TOK_P5RIN TOK_P5RPRE TOK_P5RPOST
           TOK_PLUS TOK_MINUS
%left      TOK_P6FIN TOK_P6FPRE TOK_P6FPOST TOK_P6RIN TOK_P6RPRE TOK_P6RPOST
           TOK_MULT TOK_ZPRE TOK_ZPOST TOK_ZUNP TOK_ZTYPE TOK_ZPROJ TOK_ZHIDE TOK_ZIN
           TOK_ZOUT TOK_SCH_OVER
%right     TOK_P7FIN TOK_P7FPRE TOK_P7FPOST TOK_P7RIN TOK_P7RPRE TOK_P7RPOST
           TOK_SNOT TOK_EXCLAIM TOK_UPLUS TOK_UMINUS
%left      TOK_P8FIN TOK_P8FPRE TOK_P8FPOST TOK_P8RIN TOK_P8RPRE TOK_P8RPOST
           TOK_EXPON TOK_OPAREN TOK_CPAREN TOK_PAREN TOK_FUNC TOK_PERIOD
%nonassoc  TOK_P9FIN TOK_P9FPRE TOK_P9FPOST TOK_P9RIN TOK_P9RPRE TOK_P9RPOST
           TOK_BIND TOK_SCH_APPL

%left      TOK_OCURLY

%nonassoc  TOK_PROC_REPL
%left      TOK_INTERLEAVE TOK_PHIDE TOK_PARALLEL TOK_IF_PARALLEL TOK_OIF_PAR TOK_CIF_PAR
%left      TOK_PSEQ
%left      TOK_INTERRUPT
%left      TOK_EXTERNAL TOK_INTERNAL
%right     TOK_PTHEN

%%

adoc: doc_info paragraphs
      {
         docAST = createADocNode($1, $2);
      }
    ;

doc_info: TOK_INFO_START info_list TOK_INFO_END
          {
             $$ = createDocInfoNode($2);
          }
        ;

info_list: /* Empty is OK */
           {
              $$ = NULL;
           }
         | info_list info_entry
           {
              if($1 == NULL)
              {
                 $$ = createLinkList($2);
              }
              else
              {
                 appendLinkList($1, $2);

                 $$ = $1;
              }
           }
         ;

info_entry: word_list TOK_SEMICOLON
            {
               $$ = createInfoEntryNode($1);

               free($2);
            }
          ;

par_id: TOK_IDENT
        {
           if(!addSymToGlobal($1->token, TOK_PAR_ID, NULL))
           {
              yyuerror("Unable to add paragraph name to global table");

              exit(-1);
           }

           $$ = $1;
        }
      ;

prop: TOK_PROP_START prop_list TOK_PROP_END
      {
         $$ = $2;
      }
    ;

prop_list: prop_entry
           {
              $$ = createLinkList($1);
           }
         | prop_list prop_entry
           {
              appendLinkList($1, $2);

              $$ = $1;
           }
         ;

prop_entry: word_list TOK_SEMICOLON
            {
               $$ = createPropertyNode($1);

               extractOzXfm($1);

               free($2);
            }
          ;

text_tokens: all_words
             {
                $$ = $1;
             }
           | TOK_STRING
             {
                $$ = $1;
             }
           | TOK_CHAR
             {
                $$ = $1;
             }
           | TOK_NUMBER
             {
                $$ = $1;
             }
           ;

word_list: text_tokens
           {
              $$ = createLinkList($1->token);

              $1->token = NULL;

              freeAToken($1);
           }
         | word_list text_tokens
           {
              appendLinkList($1, $2->token);

              $$ = $1;

              $2->token = NULL;

              freeAToken($2);
           }
         ;

tok_oparen: TOK_OPAREN
            {
               $$ = $1;

               if(procDef == 1)
               {
                  if(!pushSymStack(0, &yyerror))
                  {
                     yyuerror("Unable to push stack for (");

                     exit(-1);
                  }
               }
            }
          ;

tok_cparen: TOK_CPAREN
            {
               $$ = $1;

               if(procDef == 1)
               {
                  if(!popSymStack(0, &yyerror))
                  {
                     yyuerror("Unable to push stack for )");

                     exit(-1);
                  }
               }
            }
          ;

sch_ref: TOK_SCH_NAME
         {
            $$ = createSchemaTypeFromRef($1->token, NULL, NULL);

            ((SyntaxTree *) $$)->ozTex = atok2oz($1);

            $1->token = NULL;

            freeAToken($1);
         }
       | TOK_GEN_SCHEMA TOK_OCURLY TOK_OSQUARE expr_list TOK_CSQUARE TOK_CCURLY
         {
            $$ = createSchemaTypeFromRef($1->token, NULL, NULL);

            ((SchemaTypeNode *) $$)->specList = $4;

            INT8  *ozList = list2oz($4, ",", "", "");

            ((SyntaxTree *) $$)->ozTex =
                  foztex("%s%s%s[%s%s]", $1->preFmt, $1->token, $2, ozList, $5);

            $1->token = NULL;

            freeAToken($1);
            free($2);
            free($3);
            free(ozList);
            free($5);
            free($6);
         }
       ;

sch_pre_decor: TOK_OSQUARE TOK_PRE_DECOR TOK_CSQUARE
               {
                  $$ = $2;

                  free($2->preFmt);
                  free($3);

                  $2->preFmt = $1;
               }
             ;

sch_post_decor: TOK_OSQUARE TOK_POST_DECOR TOK_CSQUARE
                {
                   $$ = $2;

                   free($2->preFmt);
                   free($3);

                   $2->preFmt = $1;
                }
              ;

var_ident: TOK_IDENT
           {
              $$ = $1;
           }
         | TOK_VAR_BINDING
           {
              $$ = $1;
           }
         | TOK_PROC_VAR
           {
              $$ = $1;
           }
         ;

var_post_decor: TOK_OSQUARE TOK_POST_DECOR TOK_CSQUARE
                {
                   $$ = $2;

                   free($2->preFmt);
                   free($3);

                   $2->preFmt = $1;
                }
              | TOK_OSQUARE TOK_QUEST TOK_CSQUARE
                {
                   /* Required to be consistent with rule 1 */
                   $$ = createAToken($1, "?");

                   free($1);
                   free($2);
                   free($3);
                }
              | TOK_OSQUARE TOK_EXCLAIM TOK_CSQUARE
                {
                   /* Required to be consistent with rule 1 */
                   $$ = createAToken($1, "!");

                   free($1);
                   free($2);
                   free($3);
                }
              ;

hide_entries: hide_entries TOK_COMMA hide_entry
          {
             $$ = $1;

             SyntaxTree  *tailExpr = (SyntaxTree *) getListTail($1)->object;

             appendLinkList($1, $3);

             INT8  *tmpTex = tailExpr->ozTex;

             tailExpr->ozTex = foztex("%s%s", tmpTex, $2);

             free(tmpTex);
             free($2);
          }
        | hide_entry
          {
             $$ = createLinkList($1);
          }
        ;

hide_entry: var_ident
           {
              $$ = createBindEntryNode(createVariableNode($1->token, NULL), NULL);

              ((SyntaxTree *) $$)->ozTex = atok2oz($1);

              $1->token = NULL;

              ((BindEntryNode *) $$)->var->treeType = createGenTreeType("zhide");
              ((BindEntryNode *) $$)->treeType      = createGenTreeType("zhide");
              ((BindEntryNode *) $$)->hideEntry     = 1;

              $1->token = NULL;

              freeAToken($1);
           }
         | var_ident var_post_decor
           {
              $$ = createBindEntryNode(createVariableNode($1->token, $2->token), NULL);

              DecorType  postDecor = extractDecorType($2->token);
              UINT8      postCnt   = extractDecorCount($2->token);
              INT8       *ozPost   = NULL;

              if(postDecor == POST_PRI)
              {
                 if(postCnt > 1)
                 {
                    ozPost = foztex("\\zPri{%d}", postCnt);
                 }
                 else
                 {
                    ozPost = foztex("'");
                 }
              }
              else if(postDecor == POST_IN)
              {
                 ozPost = foztex("?");
              }
              else if(postDecor == POST_OUT)
              {
                 ozPost = foztex("!");
              }

              ((SyntaxTree *) $$)->ozTex = foztex("%s%s%s%s", $1->preFmt, getOzXfm($1->token),
                                                              $2->preFmt, ozPost);

              ((BindEntryNode *) $$)->var->treeType = createGenTreeType("zhide");
              ((BindEntryNode *) $$)->treeType      = createGenTreeType("zhide");
              ((BindEntryNode *) $$)->hideEntry     = 1;

              $1->token = NULL;

              free(ozPost);
              freeAToken($1);
              freeAToken($2);
           }
         ;

in_rel: TOK_P1RIN
        {
           $$ = $1;
        }
      | TOK_P2RIN
        {
           $$ = $1;
        }
      | TOK_P3RIN
        {
           $$ = $1;
        }
      | TOK_P4RIN
        {
           $$ = $1;
        }
      | TOK_P5RIN
        {
           $$ = $1;
        }
      | TOK_P6RIN
        {
           $$ = $1;
        }
      | TOK_P7RIN
        {
           $$ = $1;
        }
      | TOK_P8RIN
        {
           $$ = $1;
        }
      | TOK_P9RIN
        {
           $$ = $1;
        }
      ;

pre_rel: TOK_P1RPRE
         {
            $$ = $1;
         }
       | TOK_P2RPRE
         {
            $$ = $1;
         }
       | TOK_P3RPRE
         {
            $$ = $1;
         }
       | TOK_P4RPRE
         {
            $$ = $1;
         }
       | TOK_P5RPRE
         {
            $$ = $1;
         }
       | TOK_P6RPRE
         {
            $$ = $1;
         }
       | TOK_P7RPRE
         {
            $$ = $1;
         }
       | TOK_P8RPRE
         {
            $$ = $1;
        }
       | TOK_P9RPRE
         {
            $$ = $1;
         }
       ;

post_rel: TOK_P1RPOST
          {
             $$ = $1;
          }
        | TOK_P2RPOST
          {
             $$ = $1;
          }
        | TOK_P3RPOST
          {
             $$ = $1;
          }
        | TOK_P4RPOST
          {
             $$ = $1;
          }
        | TOK_P5RPOST
          {
             $$ = $1;
          }
        | TOK_P6RPOST
          {
             $$ = $1;
          }
        | TOK_P7RPOST
          {
             $$ = $1;
          }
        | TOK_P8RPOST
          {
             $$ = $1;
          }
        | TOK_P9RPOST
          {
             $$ = $1;
          }
        ;

in_op: TOK_P1FIN
       {
          $$ = $1;
       }
     | TOK_P2FIN
       {
          $$ = $1;
       }
     | TOK_P3FIN
       {
          $$ = $1;
       }
     | TOK_P4FIN
       {
          $$ = $1;
       }
     | TOK_P5FIN
       {
          $$ = $1;
       }
     | TOK_P6FIN
       {
          $$ = $1;
       }
     | TOK_P7FIN
       {
          $$ = $1;
       }
     | TOK_P8FIN
       {
          $$ = $1;
       }
     | TOK_P9FIN
       {
          $$ = $1;
       }
     ;

pre_op: TOK_P1FPRE
        {
           $$ = $1;
        }
      | TOK_P2FPRE
        {
           $$ = $1;
        }
      | TOK_P3FPRE
        {
           $$ = $1;
        }
      | TOK_P4FPRE
        {
           $$ = $1;
        }
      | TOK_P5FPRE
        {
           $$ = $1;
        }
      | TOK_P6FPRE
        {
           $$ = $1;
        }
      | TOK_P7FPRE
        {
           $$ = $1;
        }
      | TOK_P8FPRE
        {
           $$ = $1;
       }
      | TOK_P9FPRE
        {
           $$ = $1;
        }
      ;

post_op: TOK_P1FPOST
         {
            $$ = $1;
         }
       | TOK_P2FPOST
         {
            $$ = $1;
         }
       | TOK_P3FPOST
         {
            $$ = $1;
         }
       | TOK_P4FPOST
         {
            $$ = $1;
         }
       | TOK_P5FPOST
         {
            $$ = $1;
         }
       | TOK_P6FPOST
         {
            $$ = $1;
         }
       | TOK_P7FPOST
         {
            $$ = $1;
         }
       | TOK_P8FPOST
         {
            $$ = $1;
         }
       | TOK_P9FPOST
         {
            $$ = $1;
         }
       ;

expr_list2: expr TOK_COMMA expr
            {
               $$ = createLinkList($1);

               appendLinkList($$, $3);

               INT8  *tmpTex = ((SyntaxTree *) $1)->ozTex;

               ((SyntaxTree *) $1)->ozTex = foztex("%s%s", tmpTex, $2);

               free(tmpTex);
               free($2);
            }
          | expr_list2 TOK_COMMA expr
            {
               $$ = $1;

               SyntaxTree  *tailExpr = (SyntaxTree *) getListTail($1)->object;

               appendLinkList($$, $3);

               INT8  *tmpTex = tailExpr->ozTex;

               tailExpr->ozTex = foztex("%s%s", tmpTex, $2);

               free(tmpTex);
               free($2);
            }
          ;

expr_list1: expr
            {
               $$ = createLinkList($1);
            }
          | expr_list2
            {
               $$ = $1;
            }
          ;
expr_list: /* Empty is OK */
           {
              $$ = NULL;
           }
         | expr_list1
           {
              $$ = $1;
           }
         ;

expr: bexp TOK_POUND TOK_OSQUARE post_props TOK_CSQUARE
      {
         $$ = $1;

         ((ExprNode *) $1)->props = $4;

         INT8  *tmpTex = ((SyntaxTree *) $1)->ozTex;

         ((SyntaxTree *) $1)->ozTex = foztex("%s%s", tmpTex, $2);

         free(tmpTex);
         free($2);
         free($3);
         free($5);
      }
    | bexp %prec TOK_EXPR
      {
         $$ = $1;
      }
    ;

bexp: tuple
      {
         $$ = $1;
      }
    | bind
      {
         $$ = $1;
      }
    | sch_bind
      {
         $$ = $1;
      }
    | TOK_SNOT expr
      {
         DEBUG("Parsed TOK_SNOT\n");
         $$ = createExprOpNode(NULL, strdup("~"), $2);

         ((SyntaxTree *) $$)->ozTex = foztex("%s\\lnot\\!\\! %s", $1, ((SyntaxTree *) $2)->ozTex);

         free($1);
         free(((SyntaxTree *) $2)->ozTex);

         if(!isSchemaTypeExpr($2) && !isSchemaBindExpr($2))
         {
            yyuerror("Operand is not a schema expression");
         }
         else
         {
            ((SyntaxTree *) $$)->treeType = getExprType((SyntaxTree *) $2);
         }

         printType("TOK_SNOT", ((SyntaxTree *) $$)->treeType);
      }
    | expr TOK_SOR expr
      {
         DEBUG("Parsed TOK_SOR\n");
         $$ = createExprOpNode($1, strdup("|"), $3);

         ((SyntaxTree *) $$)->ozTex = foztex("%s%s\\lor %s", ((SyntaxTree *) $1)->ozTex, $2,
                                                             ((SyntaxTree *) $3)->ozTex);

         free(((SyntaxTree *) $1)->ozTex);
         free($2);
         free(((SyntaxTree *) $3)->ozTex);

         if(isSchemaBindExpr($1))
         {
            if(!isSchemaBindExpr($3))
            {
               yyuerror("Operand type mismatch: Right expression must be a schema binding");
            }
            else
            {
               ((SyntaxTree *) $$)->treeType = joinSchemaTypes((SchemaType *) getExprType($1),
                                                               (SchemaType *) getExprType($3));
            }
         }
         else if(isSchemaTypeExpr($1))
         {
            if(!isSchemaTypeExpr($3))
            {
               yyuerror("Operand type mismatch: Right expression must be a schema type");
            }
            else
            {
               SetType  *lSet = (SetType *) getExprType((SyntaxTree *) $1);
               SetType  *rSet = (SetType *) getExprType((SyntaxTree *) $3);

               ((SyntaxTree *) $$)->treeType =
                     createSetTreeType(joinSchemaTypes((SchemaType *) lSet->setType,
                                                       (SchemaType *) rSet->setType));
            }
         }
         else
         {
            yyuerror("Operand expressions are not schema expressions");
         }

         printType("TOK_SOR", ((SyntaxTree *) $$)->treeType);
      }
    | expr TOK_SAND expr
      {
         DEBUG("Parsed TOK_SAND\n");
         $$ = createExprOpNode($1, strdup("&"), $3);

         ((SyntaxTree *) $$)->ozTex = foztex("%s%s\\land %s", ((SyntaxTree *) $1)->ozTex, $2,
                                                              ((SyntaxTree *) $3)->ozTex);

         free(((SyntaxTree *) $1)->ozTex);
         free($2);
         free(((SyntaxTree *) $3)->ozTex);

         if(isSchemaBindExpr($1))
         {
            if(!isSchemaBindExpr($3))
            {
               yyuerror("Operand type mismatch: Right expression must be a schema binding");
            }
            else
            {
               ((SyntaxTree *) $$)->treeType = joinSchemaTypes((SchemaType *) getExprType($1),
                                                               (SchemaType *) getExprType($3));
            }
         }
         else if(isSchemaTypeExpr($1))
         {
            if(!isSchemaTypeExpr($3))
            {
               yyuerror("Operand type mismatch: Right expression must be a schema type");
            }
            else
            {
               SetType  *lSet = (SetType *) getExprType((SyntaxTree *) $1);
               SetType  *rSet = (SetType *) getExprType((SyntaxTree *) $3);

               ((SyntaxTree *) $$)->treeType =
                     createSetTreeType(joinSchemaTypes((SchemaType *) lSet->setType,
                                       (SchemaType *) rSet->setType));
            }
         }
         else
         {
            yyuerror("Operand expressions are not schema expressions");
         }

         printType("TOK_SAND", ((SyntaxTree *) $$)->treeType);
      }
    | TOK_ZPRE expr
      {
         $$ = createExprOpNode(NULL, strdup("zpre"), $2);

         ((SyntaxTree *) $$)->ozTex = foztex("%s\\pre %s", $1, ((SyntaxTree *) $2)->ozTex);

         free($1);
         free(((SyntaxTree *) $2)->ozTex);

         SchemaType  *schType = NULL;

         if(isSchemaBindExpr($2))
         {
            schType = (SchemaType *) getExprType((SyntaxTree *) $2);
         }
         else if(isSchemaTypeExpr($2))
         {
            schType = (SchemaType *) getBoundSchemaType(getExprType((SyntaxTree *) $2));
         }
         else
         {
            yyuerror("Operand is not a schema expression");
         }

         if(schType != NULL)
         {
            if(isSchemaTypeExpr($2))
            {
               ((SyntaxTree *) $$)->treeType = createSetTreeType(preSchema((TreeType *) schType));
            }
            else
            {
               ((SyntaxTree *) $$)->treeType = preSchema((TreeType *) schType);
            }
         }

         printType("TOK_ZPRE", ((SyntaxTree *) $$)->treeType);
      }
    | TOK_ZPOST expr
      {
         $$ = createExprOpNode(NULL, strdup("zpost"), $2);

         ((SyntaxTree *) $$)->ozTex = foztex("%s\\post %s", $1, ((SyntaxTree *) $2)->ozTex);

         free($1);
         free(((SyntaxTree *) $2)->ozTex);

         SchemaType  *schType = NULL;

         if(isSchemaBindExpr($2))
         {
            schType = (SchemaType *) getExprType((SyntaxTree *) $2);
         }
         else if(isSchemaTypeExpr($2))
         {
            schType = (SchemaType *) getBoundSchemaType(getExprType((SyntaxTree *) $2));
         }
         else
         {
            yyuerror("Operand is not a schema expression");
         }

         if(schType != NULL)
         {
            if(isSchemaTypeExpr($2))
            {
               ((SyntaxTree *) $$)->treeType = createSetTreeType(postSchema((TreeType *) schType));
            }
            else
            {
               ((SyntaxTree *) $$)->treeType = postSchema((TreeType *) schType);
            }
         }

         printType("TOK_ZPOST", ((SyntaxTree *) $$)->treeType);
      }
    | TOK_ZIN expr
      {
         $$ = createExprOpNode(NULL, strdup("zin"), $2);

         ((SyntaxTree *) $$)->ozTex = foztex("%s\\zin %s", $1, ((SyntaxTree *) $2)->ozTex);

         free($1);
         free(((SyntaxTree *) $2)->ozTex);

         SchemaType  *schType = NULL;

         if(isSchemaBindExpr($2))
         {
            schType = (SchemaType *) getExprType((SyntaxTree *) $2);
         }
         else if(isSchemaTypeExpr($2))
         {
            schType = (SchemaType *) getBoundSchemaType(getExprType((SyntaxTree *) $2));
         }
         else
         {
            yyuerror("Operand is not a schema expression");
         }

         if(schType != NULL)
         {
            if(isSchemaTypeExpr($2))
            {
               ((SyntaxTree *) $$)->treeType = createSetTreeType(inSchema((TreeType *) schType));
            }
            else
            {
               ((SyntaxTree *) $$)->treeType = inSchema((TreeType *) schType);
            }
         }

         printType("TOK_ZIN", ((SyntaxTree *) $$)->treeType);
      }
    | TOK_ZOUT expr
      {
         $$ = createExprOpNode(NULL, strdup("zout"), $2);

         ((SyntaxTree *) $$)->ozTex = foztex("%s\\zout %s", $1, ((SyntaxTree *) $2)->ozTex);

         free($1);
         free(((SyntaxTree *) $2)->ozTex);

         SchemaType  *schType = NULL;

         if(isSchemaBindExpr($2))
         {
            schType = (SchemaType *) getExprType((SyntaxTree *) $2);
         }
         else if(isSchemaTypeExpr($2))
         {
            schType = (SchemaType *) getBoundSchemaType(getExprType((SyntaxTree *) $2));
         }
         else
         {
            yyuerror("Operand is not a schema expression");
         }

         if(schType != NULL)
         {
            if(isSchemaTypeExpr($2))
            {
               ((SyntaxTree *) $$)->treeType = createSetTreeType(outSchema((TreeType *) schType));
            }
            else
            {
               ((SyntaxTree *) $$)->treeType = outSchema((TreeType *) schType);
            }
         }

         printType("TOK_ZOUT", ((SyntaxTree *) $$)->treeType);
      }
    | TOK_ZUNP expr
      {
         $$ = createExprOpNode(NULL, strdup("zunp"), $2);

         ((SyntaxTree *) $$)->ozTex = foztex("%s\\unprime %s", $1, ((SyntaxTree *) $2)->ozTex);

         free($1);
         free(((SyntaxTree *) $2)->ozTex);

         if(!isSchemaBindExpr($2))
         {
            yyuerror("Operand is not a schema binding expression");
         }
         else
         {
            ((SyntaxTree *) $$)->treeType = unprimeSchema(getExprType($2));
         }

         printType("TOK_ZUNP", ((SyntaxTree *) $$)->treeType);
      }
    | TOK_ZTYPE expr
      {
         $$ = createExprOpNode(NULL, strdup("ztype"), $2);

         ((SyntaxTree *) $$)->ozTex = foztex("%s\\zType %s", $1, ((SyntaxTree *) $2)->ozTex);

         free($1);
         free(((SyntaxTree *) $2)->ozTex);

         if(!isSchemaBindExpr($2))
         {
            yyuerror("Operand is not a schema binding expression");
         }
         else
         {
            ((SyntaxTree *) $$)->treeType = createSetTreeType(getExprType((SyntaxTree *) $2));
         }

         printType("TOK_ZTYPE", ((SyntaxTree *) $$)->treeType);
      }
    | expr TOK_ZHIDE expr
      {
         $$ = handleSchemaHide($1, $3);

         ((SyntaxTree *) $$)->ozTex = foztex("%s%s\\zhide %s", ((SyntaxTree *) $1)->ozTex, $2,
                                                               ((SyntaxTree *) $3)->ozTex);

         free(((SyntaxTree *) $1)->ozTex);
         free($2);
         free(((SyntaxTree *) $3)->ozTex);

         printType("TOK_ZHIDE", ((SyntaxTree *) $$)->treeType);
      }
    | expr TOK_ZHIDE hide_list
      {
         $$ = handleSchemaHide($1, $3);

         ((SyntaxTree *) $$)->ozTex = foztex("%s%s\\zhide %s", ((SyntaxTree *) $1)->ozTex, $2,
                                                               ((SyntaxTree *) $3)->ozTex);

         free(((SyntaxTree *) $1)->ozTex);
         free($2);
         free(((SyntaxTree *) $3)->ozTex);

         printType("TOK_ZHIDE", ((SyntaxTree *) $$)->treeType);
      }
    | expr TOK_SCH_OVER expr
      {
         $$ = handleSchemaOver($1, $3);

         ((SyntaxTree *) $$)->ozTex = foztex("%s%s\\zover %s", ((SyntaxTree *) $1)->ozTex, $2,
                                                               ((SyntaxTree *) $3)->ozTex);

         free(((SyntaxTree *) $1)->ozTex);
         free($2);
         free(((SyntaxTree *) $3)->ozTex);

         printType("TOK_OVER", ((SyntaxTree *) $$)->treeType);
      }
    | expr TOK_ZPROJ expr
      {
         $$ = createExprOpNode($1, strdup("zproj"), $3);

         ((SyntaxTree *) $$)->ozTex = foztex("%s%s\\zproject %s", ((SyntaxTree *) $1)->ozTex, $2,
                                                                  ((SyntaxTree *) $3)->ozTex);

         free(((SyntaxTree *) $1)->ozTex);
         free($2);
         free(((SyntaxTree *) $3)->ozTex);

         if(!isSchemaTypeExpr($1) && !isSchemaBindExpr($1))
         {
            yyuerror("Left operand is not a schema expression");
         }
         else if(!isSchemaTypeExpr($3))
         {
            yyuerror("Right operand is not a schema type expression");
         }
         else
         {
            if(isSchemaBindExpr($1))
            {
               SchemaType  *schType = (SchemaType *) getBoundSchemaType(getExprType($3));
               SchemaType  *schBind = (SchemaType *) getExprType($1);
               LinkList    *ite     = schType->typeList;

               if(!typeCompatible(schType, schBind))
               {
                  yyuerror("Schema expressions are not type compatible");
               }

               while(ite != NULL)
               {
                  SchemaEntry  *entry = (SchemaEntry *) ite->object;
                  LinkList     *ite2  = schBind->typeList;
                  UINT8        found  = 0;

                  while((ite2 != NULL) && (!found))
                  {
                     SchemaEntry  *cmpEntry = (SchemaEntry *) ite2->object;

                     if(strcmp(entry->entryID, cmpEntry->entryID) == 0)
                     {
                        found = 1;
                     }

                     ite2 = ite2->next;
                  }

                  if(!found)
                  {
                     Symbol  *sym = symLookup(entry->entryID, &yyuerror);

                     if(sym == NULL)
                     {
                        yyuerror("Schema variable '%s' not in scope", entry->entryID);
                     }
                     else if(!typeCompare(sym->synTree->treeType, entry->entryType))
                     {
                        yyuerror("Schema variable '%s' has an incompatible type with in-scope variable",
                                 entry->entryID);
                     }
                  }

                  ite = ite->next;
               }

               ((SyntaxTree *) $$)->treeType = (TreeType *) schType;
            }
            else
            {
               ((SyntaxTree *) $$)->treeType = getExprType((SyntaxTree *) $3);
            }
         }

         printType("TOK_ZPROJ", ((SyntaxTree *) $$)->treeType);
      }
    | sch_type
      {
         $$ = $1;

         SchemaTypeNode  *schType = (SchemaTypeNode *) $$;

         LinkList  *subList = createGenSchSubList(schType);

         schType->expDecls = expand(schType->preDecor, schType->preCnt, schType->postDecor,
                                    schType->postCnt, getSchemaDecls(schType), subList);

         freeSubList(subList);

         LinkList  *typeList = getTypeList(schType->expDecls);

         ((SyntaxTree *) $$)->treeType = createSetTreeType(createSchemaTreeType(typeList));

         printType("sch_type", schType->treeType);
      }
    | sch_pre_decor sch_type
      {
         $$ = $2;

         SchemaTypeNode  *schType = (SchemaTypeNode *) $$;

         schType->preDecor = extractDecorType($1->token);
         schType->preCnt   = extractDecorCount($1->token);

         if(schType->preDecor == PRE_DELTA)
         {
            INT8  *tmpTex = schType->ozTex;
            INT8  *ozPre  = NULL;

            if(schType->preCnt > 1)
            {
               ozPre = foztex("%s\\zDelta{%d}", $1->preFmt, schType->preCnt);
            }
            else
            {
               ozPre = foztex("%s\\Delta ", $1->preFmt);
            }

            schType->ozTex = foztex("%s%s", ozPre, tmpTex);

            free(ozPre);
            free(tmpTex);
         }

         freeAToken($1);

         LinkList  *subList = createGenSchSubList(schType);

         schType->expDecls = expand(schType->preDecor, schType->preCnt, schType->postDecor,
                                    schType->postCnt, getSchemaDecls(schType), subList);

         freeSubList(subList);

         LinkList  *typeList = getTypeList(schType->expDecls);

         ((SyntaxTree *) $$)->treeType = createSetTreeType(createSchemaTreeType(typeList));

         printType("pre_sch_type", schType->treeType);
      }
    | sch_type sch_post_decor
      {
         $$ = $1;

         SchemaTypeNode  *schType = (SchemaTypeNode *) $$;

         schType->postDecor = extractDecorType($2->token);
         schType->postCnt   = extractDecorCount($2->token);

         if(schType->postDecor == POST_PRI)
         {
            INT8  *tmpTex = schType->ozTex;
            INT8  *ozPost = NULL;

            if(schType->postCnt > 1)
            {
               ozPost = foztex("\\zPri{%d}", schType->postCnt);
            }
            else
            {
               ozPost = foztex("'");
            }

            schType->ozTex = foztex("%s%s%s", tmpTex, $2->preFmt, ozPost);

            free(ozPost);
            free(tmpTex);
         }

         freeAToken($2);

         LinkList  *subList = createGenSchSubList(schType);

         schType->expDecls = expand(schType->preDecor, schType->preCnt, schType->postDecor,
                                    schType->postCnt, getSchemaDecls(schType), subList);

         freeSubList(subList);

         LinkList  *typeList = getTypeList(schType->expDecls);

         ((SyntaxTree *) $$)->treeType = createSetTreeType(createSchemaTreeType(typeList));

         printType("sch_type_post", schType->treeType);
      }
    | sch_pre_decor sch_type sch_post_decor
      {
         $$ = $2;

         SchemaTypeNode  *schType = (SchemaTypeNode *) $$;

         schType->preDecor  = extractDecorType($1->token);
         schType->preCnt    = extractDecorCount($1->token);
         schType->postDecor = extractDecorType($3->token);
         schType->postCnt   = extractDecorCount($3->token);

         if(schType->preDecor == PRE_DELTA)
         {
            INT8  *tmpTex = schType->ozTex;
            INT8  *ozPre  = NULL;

            if(schType->preCnt > 1)
            {
               ozPre = foztex("%s\\zDelta{%d}", $1->preFmt, schType->preCnt);
            }
            else
            {
               ozPre = foztex("%s\\Delta ", $1->preFmt);
            }

            schType->ozTex = foztex("%s%s", ozPre, tmpTex);

            free(ozPre);
            free(tmpTex);
         }

         if(schType->postDecor == POST_PRI)
         {
            INT8  *tmpTex = schType->ozTex;
            INT8  *ozPost = NULL;

            if(schType->postCnt > 1)
            {
               ozPost = foztex("\\zPri{%d}", schType->postCnt);
            }
            else
            {
               ozPost = foztex("'");
            }

            schType->ozTex = foztex("%s%s%s", tmpTex, $3->preFmt, ozPost);

            free(tmpTex);
            free(ozPost);
         }

         freeAToken($1);
         freeAToken($3);

         LinkList  *subList = createGenSchSubList(schType);

         schType->expDecls = expand(schType->preDecor, schType->preCnt, schType->postDecor,
                                    schType->postCnt, getSchemaDecls(schType), subList);

         freeSubList(subList);

         LinkList  *typeList = getTypeList(schType->expDecls);

         ((SyntaxTree *) $$)->treeType = createSetTreeType(createSchemaTreeType(typeList));

         printType("pre_sch_type_post", schType->treeType);
      }
    | set_disp
      {
         $$ = $1;
      }
    | expr TOK_UPTO expr
      {
         $$ = createUptoNode($1, $3);

         ((SyntaxTree *) $$)->ozTex = foztex("%s%s..%s", ((SyntaxTree *) $1)->ozTex, $2,
                                                       ((SyntaxTree *) $3)->ozTex);

         free(((SyntaxTree *) $1)->ozTex);
         free($2);
         free(((SyntaxTree *) $3)->ozTex);

         if(!isIntExpr($1))
         {
            printType("start", getExprType($1));

            yyuerror("Start expression is not an integer type");
         }
         else if(!isIntExpr($3))
         {
            printType("end", getExprType($3));

            yyuerror("End expression is not an integer type");
         }
         else
         {
            ((SyntaxTree *) $$)->treeType = createSetTreeType(createBasicTreeType("int"));
         }
      }
    | seq_disp
      {
         $$ = $1;
      }
    | cross
      {
         $$ = $1;
      }
    | set_comp
      {
         $$ = $1;
      }
    | lambda
      {
         $$ = $1;
      }
    | mu
      {
         $$ = $1;
      }
    | let_expr
      {
         $$ = $1;
      }
    | expr tok_oparen expr tok_cparen %prec TOK_FUNC
      {
         $$ = handleFuncApp($1, $3);

         ((SyntaxTree *) $$)->ozTex = foztex("%s%s(%s%s)", ((SyntaxTree *) $1)->ozTex, $2,
                                                           ((SyntaxTree *) $3)->ozTex, $4);

         free(((SyntaxTree *) $1)->ozTex);
         free(((SyntaxTree *) $3)->ozTex);

         free($2);
         free($4);
      }
    | expr tuple %prec TOK_FUNC
      {
         $$ = handleFuncApp($1, $2);

         ((SyntaxTree *) $$)->ozTex =
               foztex("%s%s", ((SyntaxTree *) $1)->ozTex, ((SyntaxTree *) $2)->ozTex);

         free(((SyntaxTree *) $1)->ozTex);
         free(((SyntaxTree *) $2)->ozTex);
      }
    | TOK_PROC_FUNC
      {
         $$ = createExprIdentNode($1->token);

         ((SyntaxTree *) $$)->ozTex = atok2oz($1);

         Symbol  *funcSym = symLookup($1->token, &yyuerror);

         if(funcSym == NULL)
         {
            yyuerror("Process identifier %s not found", $1->token);
         }
         else
         {
            printType($1->token, funcSym->synTree->treeType);

            ((SyntaxTree *) $$)->treeType = funcSym->synTree->treeType;
         }

         $1->token = NULL;

         freeAToken($1);
      }
    | TOK_GEN_PROC_FUNC TOK_OCURLY TOK_OSQUARE expr_list1 TOK_CSQUARE TOK_CCURLY
      {
         $$ = createExprIdentNode($1->token);

         INT8  *specList = list2oz($4, ",", "", "");

         ((ExprIdentNode *) $$)->specList = $4;
         ((SyntaxTree *) $$)->ozTex =
               foztex("%s%s%s[%s%s]", $1->preFmt, $1->token, $2, specList, $5);

         Symbol  *funcSym = symLookup($1->token, &yyuerror);

         if(funcSym == NULL)
         {
            yyuerror("Process identifier %s not found", $1->token);
         }
         else
         {
            printType($1->token, funcSym->synTree->treeType);

            DeclarationNode  *funcDecl = (DeclarationNode *) funcSym->synTree;
            LinkList         *subList  = createGenPatchList(funcDecl->genSyms, $4);

            ((SyntaxTree *) $$)->treeType = substituteGen(funcSym->synTree->treeType, subList);

            freeSubList(subList);
         }

         $1->token = NULL;

         freeAToken($1);
         free($2);
         free($3);
         free(specList);
         free($5);
         free($6);
      }
    | TOK_CHANNEL
      {
         $$ = createExprIdentNode($1->token);

         ((SyntaxTree *) $$)->ozTex = atok2oz($1);

         Symbol  *funcSym = symLookup($1->token, &yyuerror);

         if(funcSym == NULL)
         {
            yyuerror("Channel identifier %s not found", $1->token);
         }
         else
         {
            printType($1->token, funcSym->synTree->treeType);

            ((SyntaxTree *) $$)->treeType = funcSym->synTree->treeType;
         }

         $1->token = NULL;

         freeAToken($1);
      }
    | TOK_GEN_CHANNEL TOK_OCURLY TOK_OSQUARE expr_list1 TOK_CSQUARE TOK_CCURLY
      {
         $$ = createExprIdentNode($1->token);

         INT8  *specList = list2oz($4, ",", "", "");

         ((ExprIdentNode *) $$)->specList = $4;
         ((SyntaxTree *) $$)->ozTex =
               foztex("%s%s%s[%s%s]", $1->preFmt, $1->token, $2, specList, $5);

         Symbol  *funcSym = symLookup($1->token, &yyuerror);

         if(funcSym == NULL)
         {
            yyuerror("Channel identifier %s not found", $1->token);
         }
         else
         {
            printType($1->token, funcSym->synTree->treeType);

            DeclarationNode  *funcDecl = (DeclarationNode *) funcSym->synTree;
            LinkList         *subList  = createGenPatchList(funcDecl->genSyms, $4);

            ((SyntaxTree *) $$)->treeType = substituteGen(funcSym->synTree->treeType, subList);

            freeSubList(subList);
         }

         $1->token = NULL;

         freeAToken($1);
         free($2);
         free($3);
         free(specList);
         free($5);
         free($6);
      }
    | TOK_EXPR_FUNC
      {
         $$ = createExprIdentNode($1->token);

         ((SyntaxTree *) $$)->ozTex = atok2oz($1);

         Symbol  *funcSym = symLookup($1->token, &yyuerror);

         if(funcSym == NULL)
         {
            yyuerror("Function identifier %s not found", $1->token);
         }
         else
         {
            printType($1->token, funcSym->synTree->treeType);

            ((SyntaxTree *) $$)->treeType = funcSym->synTree->treeType;
         }

         $1->token = NULL;

         freeAToken($1);
      }
    | in_rel
      {
         $$ = createExprIdentNode($1->token);

         ((SyntaxTree *) $$)->ozTex = atok2oz($1);

         Symbol  *relSym = symLookup($1->token, &yyuerror);

         if(relSym == NULL)
         {
            yyuerror("Relation identifier %s not found", $1->token);
         }
         else
         {
            printType($1->token, relSym->synTree->treeType);

            ((SyntaxTree *) $$)->treeType = relSym->synTree->treeType;
         }

         $1->token = NULL;

         freeAToken($1);
      }
    | pre_rel
      {
         $$ = createExprIdentNode($1->token);

         ((SyntaxTree *) $$)->ozTex = atok2oz($1);

         Symbol  *relSym = symLookup($1->token, &yyuerror);

         if(relSym == NULL)
         {
            yyuerror("Relation identifier %s not found", $1->token);
         }
         else
         {
            printType($1->token, relSym->synTree->treeType);

            ((SyntaxTree *) $$)->treeType = relSym->synTree->treeType;
         }

         $1->token = NULL;

         freeAToken($1);
      }
    | post_rel
      {
         $$ = createExprIdentNode($1->token);

         ((SyntaxTree *) $$)->ozTex = atok2oz($1);

         Symbol  *relSym = symLookup($1->token, &yyuerror);

         if(relSym == NULL)
         {
            yyuerror("Relation identifier %s not found", $1->token);
         }
         else
         {
            printType($1->token, relSym->synTree->treeType);

            ((SyntaxTree *) $$)->treeType = relSym->synTree->treeType;
         }

         $1->token = NULL;

         freeAToken($1);
      }
    | in_op
      {
         $$ = createExprIdentNode($1->token);

         ((SyntaxTree *) $$)->ozTex = atok2oz($1);

         Symbol  *opSym = symLookup($1->token, &yyuerror);

         if(opSym == NULL)
         {
            yyuerror("Relation identifier %s not found", $1->token);
         }
         else
         {
            printType($1->token, opSym->synTree->treeType);

            ((SyntaxTree *) $$)->treeType = opSym->synTree->treeType;
         }

         $1->token = NULL;

         freeAToken($1);
      }
    | pre_op
      {
         $$ = createExprIdentNode($1->token);

         ((SyntaxTree *) $$)->ozTex = atok2oz($1);

         Symbol  *opSym = symLookup($1->token, &yyuerror);

         if(opSym == NULL)
         {
            yyuerror("Relation identifier %s not found", $1->token);
         }
         else
         {
            printType($1->token, opSym->synTree->treeType);

            ((SyntaxTree *) $$)->treeType = opSym->synTree->treeType;
         }

         $1->token = NULL;

         freeAToken($1);
      }
    | post_op
      {
         $$ = createExprIdentNode($1->token);

         ((SyntaxTree *) $$)->ozTex = atok2oz($1);

         Symbol  *opSym = symLookup($1->token, &yyuerror);

         if(opSym == NULL)
         {
            yyuerror("Relation identifier %s not found", $1->token);
         }
         else
         {
            printType($1->token, opSym->synTree->treeType);

            ((SyntaxTree *) $$)->treeType = opSym->synTree->treeType;
         }

         $1->token = NULL;

         freeAToken($1);
      }
    | TOK_GEN_SYM
      {
         $$ = createExprGenIdentNode($1->token);

         ((SyntaxTree *) $$)->treeType = createSetTreeType(createGenTreeType(strdup($1->token)));
         ((SyntaxTree *) $$)->ozTex    = atok2oz($1);

         $1->token = NULL;

         freeAToken($1);
      }
    | TOK_EVENT
      {
         $$ = createVariableNode($1->token, NULL);

         ((SyntaxTree *) $$)->ozTex = atok2oz($1);

         Symbol  *varSym = symLookup($1->token, &yyuerror);

         if(varSym == NULL)
         {
            yyuerror("Event identifier %s not found", $1->token);
         }
         else
         {
            ((SyntaxTree *) $$)->treeType = varSym->synTree->treeType;
         }

         $1->token = NULL;

         freeAToken($1);
      }
    | TOK_PROCESS
      {
         $$ = createVariableNode($1->token, NULL);

         ((SyntaxTree *) $$)->ozTex = atok2oz($1);

         Symbol  *varSym = symLookup($1->token, &yyuerror);

         if(varSym == NULL)
         {
            yyuerror("Process identifier %s not found", $1->token);
         }
         else
         {
            ((SyntaxTree *) $$)->treeType = varSym->synTree->treeType;
         }

         $1->token = NULL;

         freeAToken($1);
      }
    | var_ident
      {
         $$ = createVariableNode($1->token, NULL);

         ((SyntaxTree *) $$)->ozTex = atok2oz($1);

         Symbol  *varSym = symLookup($1->token, &yyuerror);

         if(varSym == NULL)
         {
            yyuerror("Variable identifier %s not found", $1->token);
         }
         else
         {
            ((SyntaxTree *) $$)->treeType = varSym->synTree->treeType;
         }

         $1->token = NULL;

         freeAToken($1);
      }
    | var_ident var_post_decor
      {
         tmpStr = malloc(strlen($1->token) + strlen($2->token) + 1);

         memset(tmpStr, 0, strlen($1->token) + strlen($2->token) + 1);
         strncpy(tmpStr, $1->token, strlen($1->token));
         strncpy(&(tmpStr[strlen($1->token)]), $2->token, strlen($2->token));

         if(symLookup(tmpStr, &yyuerror) == NULL)
         {
            yyuerror("Variable %s unknown", tmpStr);

            YYERROR;
         }

         $$ = createVariableNode($1->token, $2->token);

         DecorType  postDecor = extractDecorType($2->token);
         UINT8      postCnt   = extractDecorCount($2->token);
         INT8       *ozPost   = NULL;

         if(postDecor == POST_PRI)
         {
            if(postCnt > 1)
            {
               ozPost = foztex("\\zPri{%d}", postCnt);
            }
            else
            {
               ozPost = foztex("'");
            }
         }
         else if(postDecor == POST_IN)
         {
            ozPost = foztex("?");
         }
         else if(postDecor == POST_OUT)
         {
            ozPost = foztex("!");
         }

         ((SyntaxTree *) $$)->ozTex =
               foztex("%s%s%s%s", $1->preFmt, $1->token, $2->preFmt, ozPost);

         $1->token = NULL;

         free(ozPost);
         freeAToken($1);
         freeAToken($2);

         Symbol  *varSym = symLookup(tmpStr, &yyuerror);

         if(varSym == NULL)
         {
            yyuerror("Variable identifier %s not found", tmpStr);
         }
         else
         {
            ((SyntaxTree *) $$)->treeType = varSym->synTree->treeType;
         }

         free(tmpStr);

         tmpStr = NULL;
      }
    | TOK_DATA_TYPE
      {
         $$ = createExprIdentNode($1->token);

         ((SyntaxTree *) $$)->ozTex = atok2oz($1);

         Symbol  *typeSym = symLookup($1->token, &yyuerror);

         if(typeSym == NULL)
         {
            yyuerror("Type identifier %s not found", $1->token);
         }
         else
         {
            ((SyntaxTree *) $$)->treeType = typeSym->synTree->treeType;
         }

         $1->token = NULL;

         freeAToken($1);
      }
    | TOK_GEN_TYPE expr
      {
         $$ = createExprSpecIdentNode($1->token, NULL, $2);

         if(!isSetExpr($2))
         {
            yyuerror("right expression is not a set type");
         }

         ((SyntaxTree *) $$)->ozTex =
               foztex("%s\\mathrel{%s}%s", $1->preFmt, getOzXfm($1->token),
                                           ((SyntaxTree *) $2)->ozTex);

         free(((SyntaxTree *) $2)->ozTex);

         Symbol  *typeSym = symLookup($1->token, &yyuerror);

         if(typeSym == NULL)
         {
            yyuerror("Type identifier %s not found", $1->token);
         }
         else
         {
            GenSubEntry  *postSub = malloc(sizeof(GenSubEntry));
            LinkList     *subList = createLinkList(postSub);

            postSub->genID   = ((TypeEntryNode *) typeSym->synTree)->postGen;
            postSub->subType = getTypeBoundType(((SyntaxTree *) $2)->treeType);

            /* TBD: After substitution, the AST should be walked and type checked again */
            ((SyntaxTree *) $$)->treeType = substituteGen(typeSym->synTree->treeType, subList);

            free(postSub);
            freeLinkList(subList);
         }

         $1->token = NULL;

         freeAToken($1);
      }
    | expr TOK_GEN_TYPE expr
      {
         $$ = createExprSpecIdentNode($2->token, $1, $3);

         if(!isSetExpr($1))
         {
            yyuerror("Left expression is not a set type");
         }

         if(!isSetExpr($3))
         {
            yyuerror("Right expression is not a set type");
         }

         ((SyntaxTree *) $$)->ozTex =
               foztex("%s%s\\mathrel{%s}%s", ((SyntaxTree *) $1)->ozTex, $2->preFmt,
                                             getOzXfm($2->token),
                                             ((SyntaxTree *) $3)->ozTex);

         free(((SyntaxTree *) $1)->ozTex);
         free(((SyntaxTree *) $3)->ozTex);

         Symbol  *typeSym = symLookup($2->token, &yyuerror);

         if(typeSym == NULL)
         {
            yyuerror("Type identifier %s not found", $2->token);
         }
         else
         {
            GenSubEntry  *preSub  = malloc(sizeof(GenSubEntry));
            GenSubEntry  *postSub = malloc(sizeof(GenSubEntry));
            LinkList     *subList = createLinkList(preSub);

            appendLinkList(subList, postSub);

            preSub->genID   = ((TypeEntryNode *) typeSym->synTree)->preGen;
            preSub->subType = getTypeBoundType(((SyntaxTree *) $1)->treeType);

            postSub->genID   = ((TypeEntryNode *) typeSym->synTree)->postGen;
            postSub->subType = getTypeBoundType(((SyntaxTree *) $3)->treeType);

            /* TBD: After substitution, the AST should be walked and type checked again */
            ((SyntaxTree *) $$)->treeType = substituteGen(typeSym->synTree->treeType, subList);

            free(preSub);
            free(postSub);
            freeLinkList(subList);
         }

         $2->token = NULL;

         freeAToken($2);
      }
    | expr TOK_PERIOD all_words
      {
         $$ = createSelectNode($1, createVariableNode($3->token, NULL));

         ((SyntaxTree *) $$)->ozTex =
               foztex("%s%s.%s", ((SyntaxTree *) $1)->ozTex, $2, getOzXfm($3->token));

         free(((SyntaxTree *) $1)->ozTex);
         free($2);

         if(!isSchemaBindExpr($1))
         {
            yyuerror("Expression is not a schema binding");
         }
         else
         {
            SchemaType  *schBind = (SchemaType *) ((SyntaxTree *) $1)->treeType;
            LinkList    *ite     = schBind->typeList;
            TreeType    *varType = NULL;
            INT8        *varName = $3->token;

            while((ite != NULL) && (varType == NULL))
            {
               SchemaEntry  *entry = (SchemaEntry *) ite->object;

               if(strcmp(entry->entryID, varName) == 0)
               {
                  varType = entry->entryType;
               }

               ite = ite->next;
            }

            if(varType != NULL)
            {
               ((SyntaxTree *) $$)->treeType = varType;
            }
            else
            {
               yyuerror("%s is not a member of the schema expression", varName);
            }
         }

         $3->token = NULL;

         freeAToken($3);
      }
    | expr TOK_PERIOD all_words var_post_decor
      {
         VariableNode *varNode = createVariableNode($3->token, $4->token);
         INT8         *ozPost  = NULL;

         if(varNode->postDecor == POST_PRI)
         {
            if(varNode->postCnt > 1)
            {
               ozPost = foztex("\\zPri{%d}", varNode->postCnt);
            }
            else
            {
               ozPost = foztex("'");
            }
         }
         else if(varNode->postDecor == POST_IN)
         {
            ozPost = foztex("?");
         }
         else if(varNode->postDecor == POST_OUT)
         {
            ozPost = foztex("!");
         }

         $$ = createSelectNode($1, varNode);

         ((SyntaxTree *) $$)->ozTex =
               foztex("%s%s.%s%s%s%s", ((SyntaxTree *) $1)->ozTex, $2, $3->preFmt,
                                       getOzXfm($3->token), $4->preFmt, ozPost);

         free(ozPost);
         free(((SyntaxTree *) $1)->ozTex);
         free($2);
         freeAToken($4);

         if(!isSchemaBindExpr($1))
         {
            yyuerror("Expression is not a schema binding");
         }

         if(!isSchemaBindExpr($1))
         {
            yyuerror("Expression is not a schema binding");
         }
         else
         {
            SchemaType  *schBind = (SchemaType *) ((SyntaxTree *) $1)->treeType;
            LinkList    *ite     = schBind->typeList;
            TreeType    *varType = NULL;
            INT8        *varName = varToString(varNode);

            while((ite != NULL) && (varType == NULL))
            {
               SchemaEntry  *entry = (SchemaEntry *) ite->object;

               if(strcmp(entry->entryID, varName) == 0)
               {
                  varType = entry->entryType;
               }

               ite = ite->next;
            }

            if(varType != NULL)
            {
               ((SyntaxTree *) $$)->treeType = varType;
            }
            else
            {
               yyuerror("%s is not a member of the schema expression", varName);
            }

            free(varName);
         }

         $3->token = NULL;

         freeAToken($3);
      }
    | cond_exp
      {
         $$ = $1;
      }
    | expr TOK_EXPON expr
      {
         $$ = createExprOpNode($1, strdup("^"), $3);

         ((SyntaxTree *) $$)->ozTex =
               foztex("%s%s^{%s}", ((SyntaxTree *) $1)->ozTex, $2,
                                   ((SyntaxTree *) $3)->ozTex);

         free(((SyntaxTree *) $1)->ozTex);
         free($2);
         free(((SyntaxTree *) $3)->ozTex);

         symLookup("^", &yyuerror);

         if(!isIntExpr($1))
         {
            yyuerror("Base expression is not an integer type");
         }
         else if(!isIntExpr($3))
         {
            yyuerror("Exponent expression is not an integer type");
         }
         else
         {
            ((SyntaxTree *) $$)->treeType = createBasicTreeType("int");
         }
      }
    | TOK_NUMBER
      {
         $$ = createExprLiteralNode($1->token);

         ((SyntaxTree *) $$)->ozTex = atok2oz($1);

         $1->token = NULL;

         freeAToken($1);

         ((SyntaxTree *) $$)->treeType = createBasicTreeType("int");
      }
    | TOK_CHAR
      {
         $$ = createExprLiteralNode($1->token);

         INT8  *ozChar = char2oz($1->token);

         ((SyntaxTree *) $$)->ozTex = foztex("%s$%s$", $1->preFmt, ozChar);

         $1->token = NULL;

         freeAToken($1);
         free(ozChar);

         ((SyntaxTree *) $$)->treeType = createBasicTreeType("char");
      }
    | TOK_STRING
      {
         $$ = createExprLiteralNode($1->token);

         INT8  *ozStr = string2oz($1->token);

         ((SyntaxTree *) $$)->ozTex = foztex("%s$%s$", $1->preFmt, ozStr);

         $1->token = NULL;

         freeAToken($1);
         free(ozStr);

         TreeType  *first     = (TreeType *) createBasicTreeType("int");
         TreeType  *second    = createBasicTreeType("char");
         LinkList  *tupleList = createLinkList(first);
         TreeType  *tuple     = (TreeType *) createTupleTreeType(NULL, 0);

         appendLinkList(tupleList, second);

         ((TupleType *) tuple)->typeList = tupleList;

         ((SyntaxTree *) $$)->treeType = createSetTreeType((TreeType *) tuple);
      }
    | tok_oparen expr tok_cparen %prec TOK_PAREN
      {
         $$ = $2;

         INT8  *tmpTex = ((SyntaxTree *) $2)->ozTex;

         ((SyntaxTree *) $$)->ozTex = foztex("%s(%s%s)", $1, tmpTex, $3);

         free(tmpTex);
         free($1);
         free($3);
      }
    | TOK_P1FPRE expr
      {
         $$ = handleFPreOp($1->token, $2);

         ((SyntaxTree *) $$)->ozTex = foztex("%s\\mathrel{%s}%s", $1->preFmt, getOzXfm($1->token),
                                                                  ((SyntaxTree *) $2)->ozTex);

         free(((SyntaxTree *) $2)->ozTex);

         $1->token = NULL;

         freeAToken($1);
      }
    | TOK_P2FPRE expr
      {
         $$ = handleFPreOp($1->token, $2);

         ((SyntaxTree *) $$)->ozTex = foztex("%s\\mathrel{%s}%s", $1->preFmt, getOzXfm($1->token),
                                                                  ((SyntaxTree *) $2)->ozTex);

         free(((SyntaxTree *) $2)->ozTex);

         $1->token = NULL;

         freeAToken($1);
      }
    | TOK_P3FPRE expr
      {
         $$ = handleFPreOp($1->token, $2);

         ((SyntaxTree *) $$)->ozTex = foztex("%s\\mathrel{%s}%s", $1->preFmt, getOzXfm($1->token),
                                                                  ((SyntaxTree *) $2)->ozTex);

         free(((SyntaxTree *) $2)->ozTex);

         $1->token = NULL;

         freeAToken($1);
      }
    | TOK_P4FPRE expr
      {
         $$ = handleFPreOp($1->token, $2);

         ((SyntaxTree *) $$)->ozTex = foztex("%s\\mathrel{%s}%s", $1->preFmt, getOzXfm($1->token),
                                                                  ((SyntaxTree *) $2)->ozTex);

         free(((SyntaxTree *) $2)->ozTex);

         $1->token = NULL;

         freeAToken($1);
      }
    | TOK_P5FPRE expr
      {
         $$ = handleFPreOp($1->token, $2);

         ((SyntaxTree *) $$)->ozTex = foztex("%s\\mathrel{%s}%s", $1->preFmt, getOzXfm($1->token),
                                                                  ((SyntaxTree *) $2)->ozTex);

         free(((SyntaxTree *) $2)->ozTex);

         $1->token = NULL;

         freeAToken($1);
      }
    | TOK_P6FPRE expr
      {
         $$ = handleFPreOp($1->token, $2);

         ((SyntaxTree *) $$)->ozTex = foztex("%s\\mathrel{%s}%s", $1->preFmt, getOzXfm($1->token),
                                                                  ((SyntaxTree *) $2)->ozTex);

         free(((SyntaxTree *) $2)->ozTex);

         $1->token = NULL;

         freeAToken($1);
      }
    | TOK_P7FPRE expr
      {
         $$ = handleFPreOp($1->token, $2);

         ((SyntaxTree *) $$)->ozTex = foztex("%s\\mathrel{%s}%s", $1->preFmt, getOzXfm($1->token),
                                                                  ((SyntaxTree *) $2)->ozTex);

         free(((SyntaxTree *) $2)->ozTex);

         $1->token = NULL;

         freeAToken($1);
      }
    | TOK_PLUS expr %prec TOK_UPLUS
      {
         SyntaxTree  *left = (SyntaxTree *) createExprLiteralNode("0");

         left->treeType = ((SyntaxTree *) $2)->treeType;

         $$ = handleFInOp(left, strdup("+"), $2);

         ((SyntaxTree *) $$)->ozTex = foztex("%s+%s", $1, ((SyntaxTree *) $2)->ozTex);

         free($1);
         free(((SyntaxTree *) $2)->ozTex);
      }
    | TOK_MINUS expr %prec TOK_UMINUS
      {
         SyntaxTree  *left = (SyntaxTree *) createExprLiteralNode("0");

         left->treeType = ((SyntaxTree *) $2)->treeType;

         $$ = handleFInOp(left, strdup("-"), $2);

         ((SyntaxTree *) $$)->ozTex = foztex("%s-%s", $1, ((SyntaxTree *) $2)->ozTex);

         free($1);
         free(((SyntaxTree *) $2)->ozTex);
      }
    | TOK_P8FPRE expr
      {
         $$ = handleFPreOp($1->token, $2);

         ((SyntaxTree *) $$)->ozTex = foztex("%s\\mathrel{%s}%s", $1->preFmt, getOzXfm($1->token),
                                                                  ((SyntaxTree *) $2)->ozTex);

         free(((SyntaxTree *) $2)->ozTex);

         $1->token = NULL;

         freeAToken($1);
      }
    | TOK_P9FPRE expr
      {
         $$ = handleFPreOp($1->token, $2);

         ((SyntaxTree *) $$)->ozTex = foztex("%s\\mathrel{%s}%s", $1->preFmt, getOzXfm($1->token),
                                                                  ((SyntaxTree *) $2)->ozTex);

         free(((SyntaxTree *) $2)->ozTex);

         $1->token = NULL;

         freeAToken($1);
      }
    | expr TOK_P1FIN expr
      {
         $$ = handleFInOp($1, $2->token, $3);

         ((SyntaxTree *) $$)->ozTex =
               foztex("%s%s\\mathrel{%s}%s", ((SyntaxTree *) $1)->ozTex,
                                             $2->preFmt, getOzXfm($2->token),
                                             ((SyntaxTree *) $3)->ozTex);
         free(((SyntaxTree *) $1)->ozTex);
         free(((SyntaxTree *) $3)->ozTex);

         $2->token = NULL;

         freeAToken($2);
      }
    | expr TOK_P2FIN expr
      {
         $$ = handleFInOp($1, $2->token, $3);

         ((SyntaxTree *) $$)->ozTex =
               foztex("%s%s\\mathrel{%s}%s", ((SyntaxTree *) $1)->ozTex,
                                             $2->preFmt, getOzXfm($2->token),
                                             ((SyntaxTree *) $3)->ozTex);
         free(((SyntaxTree *) $1)->ozTex);
         free(((SyntaxTree *) $3)->ozTex);

         $2->token = NULL;

         freeAToken($2);
      }
    | expr TOK_P3FIN expr
      {
         $$ = handleFInOp($1, $2->token, $3);

         ((SyntaxTree *) $$)->ozTex =
               foztex("%s%s\\mathrel{%s}%s", ((SyntaxTree *) $1)->ozTex,
                                             $2->preFmt, getOzXfm($2->token),
                                             ((SyntaxTree *) $3)->ozTex);
         free(((SyntaxTree *) $1)->ozTex);
         free(((SyntaxTree *) $3)->ozTex);

         $2->token = NULL;

         freeAToken($2);
      }
    | expr TOK_P4FIN expr
      {
         $$ = handleFInOp($1, $2->token, $3);

         ((SyntaxTree *) $$)->ozTex =
               foztex("%s%s\\mathrel{%s}%s", ((SyntaxTree *) $1)->ozTex,
                                             $2->preFmt, getOzXfm($2->token),
                                             ((SyntaxTree *) $3)->ozTex);
         free(((SyntaxTree *) $1)->ozTex);
         free(((SyntaxTree *) $3)->ozTex);

         $2->token = NULL;

         freeAToken($2);
      }
    | expr TOK_P5FIN expr
      {
         $$ = handleFInOp($1, $2->token, $3);

         ((SyntaxTree *) $$)->ozTex =
               foztex("%s%s\\mathrel{%s}%s", ((SyntaxTree *) $1)->ozTex,
                                             $2->preFmt, getOzXfm($2->token),
                                             ((SyntaxTree *) $3)->ozTex);
         free(((SyntaxTree *) $1)->ozTex);
         free(((SyntaxTree *) $3)->ozTex);

         $2->token = NULL;

         freeAToken($2);
      }
    | expr TOK_PLUS expr
      {
         $$ = handleFInOp($1, strdup("+"), $3);

         ((SyntaxTree *) $$)->ozTex =
               foztex("%s%s+%s", ((SyntaxTree *) $1)->ozTex,
                                 $2, ((SyntaxTree *) $3)->ozTex);

         free(((SyntaxTree *) $1)->ozTex);
         free(((SyntaxTree *) $3)->ozTex);

         free($2);
      }
    | expr TOK_MINUS expr
      {
         $$ = handleFInOp($1, strdup("-"), $3);

         ((SyntaxTree *) $$)->ozTex =
               foztex("%s%s-%s", ((SyntaxTree *) $1)->ozTex,
                                 $2, ((SyntaxTree *) $3)->ozTex);

         free(((SyntaxTree *) $1)->ozTex);
         free(((SyntaxTree *) $3)->ozTex);

         free($2);
      }
    | expr TOK_P6FIN expr
      {
         $$ = handleFInOp($1, $2->token, $3);

         ((SyntaxTree *) $$)->ozTex =
               foztex("%s%s\\mathrel{%s}%s", ((SyntaxTree *) $1)->ozTex,
                                             $2->preFmt, getOzXfm($2->token),
                                             ((SyntaxTree *) $3)->ozTex);

         free(((SyntaxTree *) $1)->ozTex);
         free(((SyntaxTree *) $3)->ozTex);

         $2->token = NULL;

         freeAToken($2);
      }
    | expr TOK_MULT expr
      {
         $$ = handleFInOp($1, strdup("*"), $3);

         ((SyntaxTree *) $$)->ozTex =
               foztex("%s%s*%s", ((SyntaxTree *) $1)->ozTex,
                                 $2, ((SyntaxTree *) $3)->ozTex);

         free(((SyntaxTree *) $1)->ozTex);
         free(((SyntaxTree *) $3)->ozTex);

         free($2);
      }
    | expr TOK_P7FIN expr
      {
         $$ = handleFInOp($1, $2->token, $3);

         ((SyntaxTree *) $$)->ozTex =
               foztex("%s%s\\mathrel{%s}%s", ((SyntaxTree *) $1)->ozTex,
                                             $2->preFmt, getOzXfm($2->token),
                                             ((SyntaxTree *) $3)->ozTex);

         free(((SyntaxTree *) $1)->ozTex);
         free(((SyntaxTree *) $3)->ozTex);

         $2->token = NULL;

         freeAToken($2);
      }
    | expr TOK_P8FIN expr
      {
         $$ = handleFInOp($1, $2->token, $3);

         ((SyntaxTree *) $$)->ozTex =
               foztex("%s%s\\mathrel{%s}%s", ((SyntaxTree *) $1)->ozTex,
                                             $2->preFmt, getOzXfm($2->token),
                                             ((SyntaxTree *) $3)->ozTex);

         free(((SyntaxTree *) $1)->ozTex);
         free(((SyntaxTree *) $3)->ozTex);

         $2->token = NULL;

         freeAToken($2);
      }
    | expr TOK_P9FIN expr
      {
         $$ = handleFInOp($1, $2->token, $3);

         ((SyntaxTree *) $$)->ozTex =
               foztex("%s%s\\mathrel{%s}%s", ((SyntaxTree *) $1)->ozTex,
                                             $2->preFmt, getOzXfm($2->token),
                                             ((SyntaxTree *) $3)->ozTex);

         free(((SyntaxTree *) $1)->ozTex);
         free(((SyntaxTree *) $3)->ozTex);

         $2->token = NULL;

         freeAToken($2);
      }
    | expr TOK_P1FPOST
      {
         $$ = handleFPostOp($1, $2->token);

         ((SyntaxTree *) $$)->ozTex =
               foztex("%s%s\\mathrel{%s}", ((SyntaxTree *) $1)->ozTex, $2->preFmt,
                                           getOzXfm($2->token));

         free(((SyntaxTree *) $1)->ozTex);

         $2->token = NULL;

         freeAToken($2);
      }
    | expr TOK_P2FPOST
      {
         $$ = handleFPostOp($1, $2->token);

         ((SyntaxTree *) $$)->ozTex =
               foztex("%s%s\\mathrel{%s}", ((SyntaxTree *) $1)->ozTex, $2->preFmt,
                                           getOzXfm($2->token));

         free(((SyntaxTree *) $1)->ozTex);

         $2->token = NULL;

         freeAToken($2);
      }
    | expr TOK_P3FPOST
      {
         $$ = handleFPostOp($1, $2->token);

         ((SyntaxTree *) $$)->ozTex =
               foztex("%s%s\\mathrel{%s}", ((SyntaxTree *) $1)->ozTex, $2->preFmt,
                                           getOzXfm($2->token));

         free(((SyntaxTree *) $1)->ozTex);

         $2->token = NULL;

         freeAToken($2);
      }
    | expr TOK_P4FPOST
      {
         $$ = handleFPostOp($1, $2->token);

         ((SyntaxTree *) $$)->ozTex =
               foztex("%s%s\\mathrel{%s}", ((SyntaxTree *) $1)->ozTex, $2->preFmt,
                                           getOzXfm($2->token));

         free(((SyntaxTree *) $1)->ozTex);

         $2->token = NULL;

         freeAToken($2);
      }
    | expr TOK_P5FPOST
      {
         $$ = handleFPostOp($1, $2->token);

         ((SyntaxTree *) $$)->ozTex =
               foztex("%s%s\\mathrel{%s}", ((SyntaxTree *) $1)->ozTex, $2->preFmt,
                                           getOzXfm($2->token));

         free(((SyntaxTree *) $1)->ozTex);

         $2->token = NULL;

         freeAToken($2);
      }
    | expr TOK_P6FPOST
      {
         $$ = handleFPostOp($1, $2->token);

         ((SyntaxTree *) $$)->ozTex =
               foztex("%s%s\\mathrel{%s}", ((SyntaxTree *) $1)->ozTex, $2->preFmt,
                                           getOzXfm($2->token));

         free(((SyntaxTree *) $1)->ozTex);

         $2->token = NULL;

         freeAToken($2);
      }
    | expr TOK_P7FPOST
      {
         $$ = handleFPostOp($1, $2->token);

         ((SyntaxTree *) $$)->ozTex =
               foztex("%s%s\\mathrel{%s}", ((SyntaxTree *) $1)->ozTex, $2->preFmt,
                                           getOzXfm($2->token));

         free(((SyntaxTree *) $1)->ozTex);

         $2->token = NULL;

         freeAToken($2);
      }
    | expr TOK_P8FPOST
      {
         $$ = handleFPostOp($1, $2->token);

         ((SyntaxTree *) $$)->ozTex =
               foztex("%s%s\\mathrel{%s}", ((SyntaxTree *) $1)->ozTex, $2->preFmt,
                                           getOzXfm($2->token));

         free(((SyntaxTree *) $1)->ozTex);

         $2->token = NULL;

         freeAToken($2);
      }
    | expr TOK_P9FPOST
      {
         $$ = handleFPostOp($1, $2->token);

         ((SyntaxTree *) $$)->ozTex =
               foztex("%s%s\\mathrel{%s}", ((SyntaxTree *) $1)->ozTex, $2->preFmt,
                                           getOzXfm($2->token));

         free(((SyntaxTree *) $1)->ozTex);

         $2->token = NULL;

         freeAToken($2);
      }
    | expr TOK_PREN expr
      {
         $$ = handleProcessRename($1, $3);

         ((SyntaxTree *) $$)->ozTex    = foztex("%s%s\\pren%s", ((SyntaxTree *) $1)->ozTex, $2,
                                                                ((SyntaxTree *) $3)->ozTex);

         free(((SyntaxTree *) $1)->ozTex);
         free($2);
         free(((SyntaxTree *) $3)->ozTex);
      }
    ;

tuple: tok_oparen expr_list2 tok_cparen
       {
          $$ = createTupleNode($2);

          INT8  *ozList = list2oz($2, ",", "", "");

          ((SyntaxTree *) $$)->treeType = createTupleTreeType($2, 0);
          ((SyntaxTree *) $$)->ozTex    = foztex("%s(%s%s)", $1, ozList, $3);

          free($1);
          free($3);
          free(ozList);
       }
     ;

set_disp: TOK_SET_DISP TOK_OCURLY expr_list TOK_CCURLY
          {
             $$ = createSetDispNode($3);

             INT8  *ozList = list2oz($3, ",", "", "");

             if(ozList != NULL)
             {
                ((SyntaxTree *) $$)->ozTex =
                      foztex("%s%s\\setof{%s%s}", $1, $2, ozList, $4);

                free(ozList);
             }
             else
             {
                ((SyntaxTree *) $$)->ozTex = foztex("%s%s\\setof{%s}", $1, $2, $4);
             }

             free($1);
             free($2);
             free($4);

             LinkList  *typeList = typeExprList($3, 0);
             TreeType  *setType  = NULL;

             if(!isSetList(typeList))
             {
                yyuerror("Set has inconsistent type");

                YYERROR;
             }

             if(typeList != NULL)
             {
                setType = typeList->object;
             }

             freeLinkList(typeList);

             ((SyntaxTree *) $$)->treeType = createSetTreeType((TreeType *) setType);
          }
        ;

seq_disp: TOK_SEQ_DISP TOK_OCURLY expr_list1 TOK_CCURLY
          {
             $$ = createSeqDispNode($3);

             INT8  *ozList = list2oz($3, ",", "", "");

             ((SyntaxTree *) $$)->ozTex =
                   foztex("%s%s\\seqof{%s%s}", $1, $2, ozList, $4);

             free($1);
             free($2);
             free(ozList);
             free($4);

             LinkList  *typeList = typeExprList($3, 0);
             TreeType  *seqType  = NULL;

             if(!isSetList(typeList))
             {
                yyuerror("Sequence has inconsistent type");

                YYERROR;
             }

             if(typeList != NULL)
             {
                seqType = typeList->object;
             }

             TreeType  *first     = (TreeType *) createBasicTreeType("int");
             TreeType  *second    = seqType;
             LinkList  *tupleList = createLinkList(first);
             TreeType  *tuple     = (TreeType *) createTupleTreeType(NULL, 0);

             appendLinkList(tupleList, second);

             ((TupleType *) tuple)->typeList = tupleList;

             freeLinkList(typeList);

             ((SyntaxTree *) $$)->treeType = createSetTreeType((TreeType *) tuple);
          }
        | TOK_SEQ_DISP TOK_OCURLY TOK_CCURLY
          {
             $$ = createSeqDispNode(NULL);

             Symbol  *typeSym = symLookup("seq", &yyuerror);

             if(typeSym == NULL)
             {
                yyuerror("Type identifier %s not found", "seq");
             }
             else
             {
                ((SyntaxTree *) $$)->treeType = getTypeBoundType(typeSym->synTree->treeType);
             }

             ((SyntaxTree *) $$)->ozTex = foztex("%s%s\\seqof{%s}", $1, $2, $3);

             free($1);
             free($2);
             free($3);
          }
        ;

cross: TOK_CROSS TOK_OCURLY expr_list2 TOK_CCURLY
       {
          $$ = createCrossNode($3);

          INT8  *ozList = list2oz($3, " \\cross ", "", "");

          ((SyntaxTree *) $$)->ozTex = foztex("%s%s(%s%s)", $1, $2, ozList, $4);

          free($1);
          free($2);
          free(ozList);
          free($4);

          ((SyntaxTree *) $$)->treeType = createSetTreeType(createTupleTreeType($3, 1));
       }
     ;

set_comp: TOK_SET_COMP TOK_OCURLY decl_list1 TOK_QUEST pred_list0 TOK_AT expr TOK_CCURLY
          {
             if(!popSymStack())
             {
                yyuerror("Unable to pop stack for setComp");

                exit(-1);
             }

             $$ = createSetCompNode($3, $5, $7);

             INT8  *declList = list2oz($3, "", "", "");
             INT8  *predList = list2oz($5, "", "|", "");

             ((SyntaxTree *) $$)->ozTex =
                   foztex("%s%s\\setof{%s%s%s%s@%s%s}", $1, $2, declList, $4, predList,
                                                        $6, ((SyntaxTree *) $7)->ozTex,
                                                        $8);

             free($1);
             free($2);
             free(declList);
             free($4);
             free(predList);
             free($6);
             free(((SyntaxTree *) $7)->ozTex);
             free($8);

             ((SyntaxTree *) $$)->treeType = createSetTreeType(getExprType($7));
          }
        ;

lambda: TOK_LAMBDA TOK_OCURLY decl_list1 TOK_QUEST pred_list0 TOK_AT expr TOK_CCURLY
        {
           if(!popSymStack())
           {
              yyuerror("Unable to pop stack for lambda");

              exit(-1);
           }

           $$ = createLambdaNode($3, $5, $7);

           INT8  *declList = list2oz($3, "", "", "");
           INT8  *predList = list2oz($5, "", "|", "");

           ((SyntaxTree *) $$)->ozTex =
                 foztex("%s\\lambda%s(%s%s%s%s@%s%s)", $1, $2, declList, $4, predList,
                                                       $6, ((SyntaxTree *) $7)->ozTex,
                                                       $8);

           free($1);
           free($2);
           free(declList);
           free($4);
           free(predList);
           free($6);
           free(((SyntaxTree *) $7)->ozTex);
           free($8);

           ((LambdaNode *) $$)->expDecls = expand(DECOR_NULL, 0, DECOR_NULL, 0, $3, NULL);

           TreeType  *tupleType = createTupleTreeType(NULL, 0);
           TreeType  *outType   = getExprType($7);
           TreeType  *inType    = NULL;

           if(((LambdaNode *) $$)->expDecls->next != NULL)
           {
              inType = createTupleTreeTypeFromDecls(((LambdaNode *) $$)->expDecls);
           }
           else
           {
              DeclarationNode  *decl = (DeclarationNode *) ((LambdaNode *) $$)->expDecls->object;

              inType = getTypeBoundType(decl->defExpr->treeType);
           }

           LinkList  *typeList  = createLinkList(inType);

           appendLinkList(typeList, outType);

           ((TupleType *) tupleType)->typeList = typeList;

           ((SyntaxTree *) $$)->treeType = createSetTreeType((TreeType *) tupleType);
        }
      ;

mu: TOK_MU TOK_OCURLY decl_list1 TOK_QUEST pred_list0 TOK_AT expr TOK_CCURLY
    {
       if(!popSymStack())
       {
          yyuerror("Unable to pop stack for mu");

          exit(-1);
       }

       $$ = createMuNode($3, $5, $7);

       INT8  *declList = list2oz($3, "", "", "");
       INT8  *predList = list2oz($5, "", "|", "");

       ((SyntaxTree *) $$)->ozTex =
             foztex("%s\\mu%s(%s%s%s%s@%s%s)", $1, $2, declList, $4, predList,
                                               $6, ((SyntaxTree *) $7)->ozTex,
                                               $8);

       free($1);
       free($2);
       free(declList);
       free($4);
       free(predList);
       free($6);
       free(((SyntaxTree *) $7)->ozTex);
       free($8);

       ((SyntaxTree *) $$)->treeType = getExprType($7);
    }
  ;

let_list: let_entry
           {
              $$ = createLinkList($1);
           }
         | let_list let_entry
           {
              appendLinkList($1, $2);

              $$ = $1;
           }
         ;

let_entry: let_decl TOK_SEMICOLON
            {
               $$ = $1;

               INT8  *tmpTex = ((SyntaxTree *) $1)->ozTex;

               ((SyntaxTree *) $1)->ozTex = foztex("%s%s;", tmpTex, $2);

               free(tmpTex);
               free($2);
            }
          | let_decl TOK_SEMICOLON TOK_POUND TOK_OSQUARE post_props TOK_CSQUARE
            {
               ((TypeEntryNode *) $1)->props = $5;

               $$ = $1;

               INT8  *tmpTex = ((SyntaxTree *) $1)->ozTex;

               ((SyntaxTree *) $1)->ozTex = foztex("%s%s;%s", tmpTex, $2, $3);

               free(tmpTex);
               free($2);
               free($3);
               free($4);
               free($6);
            }
          ;

let_decl: var_ident TOK_EQUALS expr
          {
             $$ = createDeclarationNode(NULL, VAR_DECL, createVariableNode($1->token, NULL), $3);

             printType($1->token, ((SyntaxTree *) $3)->treeType);

             ((SyntaxTree *) $$)->treeType = ((SyntaxTree *) $3)->treeType;
             ((SyntaxTree *) $$)->ozTex    =
                   foztex("%s%s%s==%s", $1->preFmt, getOzXfm($1->token),
                                        $2, ((SyntaxTree *) $3)->ozTex);

             ((SyntaxTree *) ((DeclarationNode *) $$)->ident)->treeType =
                   ((SyntaxTree *) $3)->treeType;

             free($2);
             free(((SyntaxTree *) $3)->ozTex);

             if(!addSymToTable($1->token, TOK_VAR_BINDING, $$))
             {
                yyuerror("Unable to add variable to symbol table");

                exit(-1);
             }

             $1->token = NULL;

             freeAToken($1);
          }
        | var_ident var_post_decor TOK_EQUALS expr
          {
             tmpStr = malloc(strlen($1->token) + strlen($2->token) + 1);

             memset(tmpStr, 0, strlen($1->token) + strlen($2->token) + 1);
             strncpy(tmpStr, $1->token, strlen($1->token));
             strncpy(&(tmpStr[strlen($1->token)]), $2->token, strlen($2->token));

             $$ = createDeclarationNode(NULL, VAR_DECL,
                                        createVariableNode($1->token, $2->token),
                                        $4);

             DecorType  postDecor = extractDecorType($2->token);
             UINT8      postCnt   = extractDecorCount($2->token);
             INT8       *ozPost   = NULL;

             if(postDecor == POST_PRI)
             {
                if(postCnt > 1)
                {
                   ozPost = foztex("\\zPri{%d}", postCnt);
                }
                else
                {
                   ozPost = foztex("'");
                }
             }
             else if(postDecor == POST_IN)
             {
                ozPost = foztex("?");
             }
             else if(postDecor == POST_OUT)
             {
                ozPost = foztex("!");
             }

             ((SyntaxTree *) $$)->ozTex =
                   foztex("%s%s%s%s%s==%s", $1->preFmt, getOzXfm($1->token),
                                            $2->preFmt, ozPost,
                                            $3, ((SyntaxTree *) $4)->ozTex);

             free(ozPost);
             freeAToken($2);
             free($3);
             free(((SyntaxTree *) $4)->ozTex);

             printType($1->token, ((SyntaxTree *) $4)->treeType);

             ((SyntaxTree *) $$)->treeType = ((SyntaxTree *) $4)->treeType;

             ((SyntaxTree *) ((DeclarationNode *) $$)->ident)->treeType =
                   ((SyntaxTree *) $4)->treeType;

             if(!addSymToTable(tmpStr, TOK_VAR_BINDING, $$))
             {
                yyuerror("Unable to add variable to symbol table");

                exit(-1);
             }

             free(tmpStr);

             tmpStr    = NULL;
             $1->token = NULL;

             freeAToken($1);
          }
        ;

let_expr: TOK_LET TOK_OCURLY let_list TOK_AT expr TOK_CCURLY
          {
             if(!popSymStack())
             {
                yyuerror("Unable to pop stack for let expression");

                exit(-1);
             }

             $$ = createLetExprNode($3, $5);

             INT8  *declList = list2oz($3, "", "", "");

             ((SyntaxTree *) $$)->treeType = getExprType($5);
             ((SyntaxTree *) $$)->ozTex    =
                   foztex("%s\\LET%s(%s%s@%s%s)", $1, $2, declList, $4,
                                                  ((SyntaxTree *) $5)->ozTex, $6);

             free($1);
             free($2);
             free(declList);
             free($4);
             free(((SyntaxTree *) $5)->ozTex);
             free($6);
          }
        ;

sch_type: TOK_SCH_TYPE TOK_OCURLY decl_list1 TOK_QUEST pred_list0 TOK_CCURLY
          {
             if(!popSymStack())
             {
                yyuerror("Unable to pop stack for schType");

                exit(-1);
             }

             $$ = createSchemaTypeNode($3, $5, NULL, NULL);

             INT8  *declList = list2oz($3, "", "", "");
             INT8  *predList = list2oz($5, "", "|", "");

             ((SyntaxTree *) $$)->ozTex =
                   foztex("%s%s\\schType{%s%s%s%s}", $1, $2, declList, $4,
                                                     predList, $6);

             free($1);
             free($2);
             free(declList);
             free($4);
             free(predList);
             free($6);
          }
        | TOK_SCH_TYPE TOK_OCURLY decl_list1 TOK_CCURLY
          {
             if(!popSymStack())
             {
                yyuerror("Unable to pop stack for schType");

                exit(-1);
             }

             $$ = createSchemaTypeNode($3, NULL, NULL, NULL);

             INT8  *declList = list2oz($3, "", "", "");

             ((SyntaxTree *) $$)->ozTex =
                   foztex("%s%s\\schType{%s%s}", $1, $2, declList, $4);

             free($1);
             free($2);
             free(declList);
             free($4);
          }
        | sch_ref
          {
             $$ = $1;
          }
        ;

sch_bind: TOK_SCH_BIND TOK_OCURLY bind_list TOK_CCURLY
          {
             $$ = createSchemaBindNode($3);

             ((SyntaxTree *) $$)->treeType = createSchemaTreeTypeFromBindList($3);

             INT8  *bindList = list2oz($3, ",", "", "");

             ((SyntaxTree *) $$)->ozTex =
                   foztex("%s%s\\schBind{%s%s}", $1, $2, bindList, $4);

             free($1);
             free($2);
             free(bindList);
             free($4);
          }
        ;

bind_list: bind_entry
           {
              $$ = createLinkList($1);
           }
         | bind_list TOK_COMMA bind_entry
           {
              $$ = $1;

              SyntaxTree  *tailExpr = (SyntaxTree *) getListTail($1)->object;

              appendLinkList($1, $3);

              INT8  *tmpTex = tailExpr->ozTex;

              tailExpr->ozTex = foztex("%s%s", tmpTex, $2);

              free(tmpTex);
              free($2);
           }
         ;

bind_entry: var_ident TOK_EQUALS expr
            {
               $$ = createBindEntryNode(createVariableNode($1->token, NULL), $3);

               ((SyntaxTree *) $$)->ozTex =
                     foztex("%s%s%s\\bindeq %s", $1->preFmt, getOzXfm($1->token),
                                                 $2, ((SyntaxTree *) $3)->ozTex);

               $1->token = NULL;

               ((BindEntryNode *) $$)->var->treeType = ((SyntaxTree *) $3)->treeType;
               ((BindEntryNode *) $$)->treeType      = ((SyntaxTree *) $3)->treeType;

               freeAToken($1);
               free($2);
               free(((SyntaxTree *) $3)->ozTex);
            }
          | var_ident var_post_decor TOK_EQUALS expr
            {
               $$ = createBindEntryNode(createVariableNode($1->token, $2->token), $4);

               DecorType  postDecor = extractDecorType($2->token);
               UINT8      postCnt   = extractDecorCount($2->token);
               INT8      *ozPost   = NULL;

               if(postDecor == POST_PRI)
               {
                  if(postCnt > 1)
                  {
                     ozPost = foztex("\\zPri{%d}", postCnt);
                  }
                  else
                  {
                     ozPost = foztex("'");
                  }
               }
               else if(postDecor == POST_IN)
               {
                  ozPost = foztex("?");
               }
               else if(postDecor == POST_OUT)
               {
                  ozPost = foztex("!");
               }

               ((SyntaxTree *) $$)->ozTex =
                     foztex("%s%s%s%s%s\\bindeq %s", $1->preFmt, getOzXfm($1->token),
                                                     $2->preFmt, ozPost,
                                                     $3, ((SyntaxTree *) $4)->ozTex);

               $1->token = NULL;

               ((BindEntryNode *) $$)->var->treeType = ((SyntaxTree *) $4)->treeType;
               ((BindEntryNode *) $$)->treeType      = ((SyntaxTree *) $4)->treeType;

               free(ozPost);
               freeAToken($1);
               freeAToken($2);
               free($3);
               free(((SyntaxTree *) $4)->ozTex);
            }
          ;

hide_list: TOK_OCURLY hide_entries TOK_CCURLY
           {
              $$ = createSchemaBindNode($2);

              ((SchemaBindNode *) $$)->hideNode = 1;
              ((SyntaxTree *) $$)->treeType     = createSchemaTreeTypeFromBindList($2);

              INT8  *bindList = list2oz($2, ",", "", "");

              ((SyntaxTree *) $$)->ozTex = foztex("%s(%s%s)", $1, bindList, $3);

              free($1);
              free(bindList);
              free($3);
           }

bind: TOK_MULT expr %prec TOK_BIND
      {
         printType("bind", ((SyntaxTree *) $2)->treeType);

         $$ = createExprOpNode(NULL, strdup("*"), $2);

         ((SyntaxTree *) $$)->ozTex = foztex("%s\\theta %s", $1, ((SyntaxTree *) $2)->ozTex);

         free($1);
         free(((SyntaxTree *) $2)->ozTex);

         if(!isSchemaTypeExpr($2))
         {
            yyuerror("Bind expression is not a schema type");
         }
         else
         {
            SchemaType  *schType = (SchemaType *) getBoundSchemaType(getExprType($2));
            LinkList    *ite     = schType->typeList;

            while(ite != NULL)
            {
               SchemaEntry  *entry = (SchemaEntry *) ite->object;
               Symbol       *sym   = symLookup(entry->entryID, &yyuerror);

               if(sym == NULL)
               {
                  yyuerror("Schema variable '%s' not in scope", entry->entryID);
               }
               else if(!typeCompare(sym->synTree->treeType, entry->entryType))
               {
                  yyuerror("Schema variable '%s' has an incompatible type with in-scope variable",
                           entry->entryID);
               }

               ite = ite->next;
            }

            ((SyntaxTree *) $$)->treeType = (TreeType *) schType;
         }
      }
    ;

tok_if: TOK_IF
        {
           if(procDef == 1)
           {
              if(!pushSymStack(0, &yyerror))
              {
                 yyuerror("Unable to push stack for if");

                 exit(-1);
              }
           }

           $$ = $1;
        }
      ;

tok_endif: TOK_ENDIF
           {
              if(procDef == 1)
              {
                 if(!popSymStack(0, &yyerror))
                 {
                    yyuerror("Unable to pop stack for endif");

                    exit(-1);
                 }
              }

              $$ = $1;
           }
         ;

cond_exp: tok_if pred_list TOK_THEN expr tok_endif
          {
             $$ = createCondExprNode($2, $4, NULL);

             INT8  *predList = list2oz($2, "", "", "");

             ((SyntaxTree *) $$)->treeType = ((SyntaxTree *) $4)->treeType;
             ((SyntaxTree *) $$)->ozTex    =
                   foztex("%s\\IF %s%s\\THEN %s%s\\ENDIF", $1, predList, $3,
                                                           ((SyntaxTree *) $4)->ozTex,
                                                           $5);

             free($1);
             free(predList);
             free($3);
             free(((SyntaxTree *) $4)->ozTex);
             free($5);
          }
        | tok_if pred_list TOK_THEN expr TOK_ELIF elif_exp
          {
             $$ = createCondExprNode($2, $4, $6);

             if(!typeCompare(getExprType($4), getExprType($6)))
             {
                yyuerror("Then branch and else branch are of incompatible types");
             }

             INT8  *predList = list2oz($2, "", "", "");

             ((SyntaxTree *) $$)->treeType = ((SyntaxTree *) $4)->treeType;
             ((SyntaxTree *) $$)->ozTex    =
                   foztex("%s\\IF %s%s\\THEN %s%s\\ELIF %s", $1, predList, $3,
                                                             ((SyntaxTree *) $4)->ozTex, $5,
                                                             ((SyntaxTree *) $6)->ozTex);

             free($1);
             free(predList);
             free($3);
             free(((SyntaxTree *) $4)->ozTex);
             free($5);
             free(((SyntaxTree *) $6)->ozTex);
          }
        | tok_if pred_list TOK_THEN expr TOK_ELSE expr tok_endif
          {
             $$ = createCondExprNode($2, $4, $6);

             if(!typeCompare(getExprType($4), getExprType($6)))
             {
                yyuerror("Then branch and else branch are of incompatible types");
             }

             INT8  *predList = list2oz($2, "", "", "");

             ((SyntaxTree *) $$)->treeType = ((SyntaxTree *) $4)->treeType;
             ((SyntaxTree *) $$)->ozTex    =
                   foztex("%s\\IF %s%s\\THEN %s%s\\ELSE %s%s\\ENDIF", $1, predList, $3,
                                                                      ((SyntaxTree *) $4)->ozTex, $5,
                                                                      ((SyntaxTree *) $6)->ozTex, $7);

             free($1);
             free(predList);
             free($3);
             free(((SyntaxTree *) $4)->ozTex);
             free($5);
             free(((SyntaxTree *) $6)->ozTex);
             free($7);
          }
        | tok_if pred_type TOK_THEN expr tok_endif
          {
             $$ = createCondExprNode(createLinkList($2), $4, NULL);

             ((SyntaxTree *) $$)->treeType = ((SyntaxTree *) $4)->treeType;
             ((SyntaxTree *) $$)->ozTex    =
                   foztex("%s\\IF %s%s\\THEN %s%s\\ENDIF", $1, ((SyntaxTree *) $2)->ozTex, $3,
                                                           ((SyntaxTree *) $4)->ozTex, $5);

             free($1);
             free(((SyntaxTree *) $2)->ozTex);
             free($3);
             free(((SyntaxTree *) $4)->ozTex);
             free($5);
          }
        | tok_if pred_type TOK_THEN expr TOK_ELIF elif_exp
          {
             $$ = createCondExprNode(createLinkList($2), $4, $6);

             if(!typeCompare(getExprType($4), getExprType($6)))
             {
                yyuerror("Then branch and else branch are of incompatible types");
             }

             ((SyntaxTree *) $$)->treeType = ((SyntaxTree *) $4)->treeType;
             ((SyntaxTree *) $$)->ozTex    =
                   foztex("%s\\IF %s%s\\THEN %s%s\\ELIF %s", $1, ((SyntaxTree *) $2)->ozTex, $3,
                                                             ((SyntaxTree *) $4)->ozTex, $5,
                                                             ((SyntaxTree *) $6)->ozTex);

             free($1);
             free(((SyntaxTree *) $2)->ozTex);
             free($3);
             free(((SyntaxTree *) $4)->ozTex);
             free($5);
             free(((SyntaxTree *) $6)->ozTex);
          }
        | tok_if pred_type TOK_THEN expr TOK_ELSE expr tok_endif
          {
             $$ = createCondExprNode(createLinkList($2), $4, $6);

             if(!typeCompare(getExprType($4), getExprType($6)))
             {
                yyuerror("Then branch and else branch are of incompatible types");
             }

             ((SyntaxTree *) $$)->treeType = ((SyntaxTree *) $4)->treeType;
             ((SyntaxTree *) $$)->ozTex    =
                   foztex("%s\\IF %s%s\\THEN %s%s\\ELSE %s%s\\ENDIF", $1, ((SyntaxTree *) $2)->ozTex, $3,
                                                                      ((SyntaxTree *) $4)->ozTex, $5,
                                                                      ((SyntaxTree *) $6)->ozTex, $7);

             free($1);
             free(((SyntaxTree *) $2)->ozTex);
             free($3);
             free(((SyntaxTree *) $4)->ozTex);
             free($5);
             free(((SyntaxTree *) $6)->ozTex);
             free($7);
          }
        ;

elif_exp: pred_list TOK_THEN expr tok_endif
          {
             $$ = createCondExprNode($1, $3, NULL);

             INT8  *predList = list2oz($1, "", "", "");

             ((SyntaxTree *) $$)->treeType = ((SyntaxTree *) $3)->treeType;
             ((SyntaxTree *) $$)->ozTex    =
                   foztex("%s%s\\THEN %s%s\\ENDIF", predList, $2, ((SyntaxTree *) $3)->ozTex, $4);

             free(predList);
             free($2);
             free(((SyntaxTree *) $3)->ozTex);
             free($4);
          }
        | pred_list TOK_THEN expr TOK_ELIF elif_exp
          {
             $$ = createCondExprNode($1, $3, $5);

             if(!typeCompare(getExprType($3), getExprType($5)))
             {
                yyuerror("Then branch and else branch are of incompatible types");
             }

             INT8  *predList = list2oz($1, "", "", "");

             ((SyntaxTree *) $$)->treeType = ((SyntaxTree *) $3)->treeType;
             ((SyntaxTree *) $$)->ozTex    =
                   foztex("%s%s\\THEN %s%s\\ELIF %s", predList, $2,
                                                      ((SyntaxTree *) $3)->ozTex, $4,
                                                      ((SyntaxTree *) $5)->ozTex);

             free(predList);
             free($2);
             free(((SyntaxTree *) $3)->ozTex);
             free($4);
             free(((SyntaxTree *) $5)->ozTex);
          }
        | pred_list TOK_THEN expr TOK_ELSE expr tok_endif
          {
             $$ = createCondExprNode($1, $3, $5);

             if(!typeCompare(getExprType($3), getExprType($5)))
             {
                yyuerror("Then branch and else branch are of incompatible types");
             }

             INT8  *predList = list2oz($1, "", "", "");

             ((SyntaxTree *) $$)->treeType = ((SyntaxTree *) $3)->treeType;
             ((SyntaxTree *) $$)->ozTex    =
                   foztex("%s%s\\THEN %s%s\\ELSE %s%s\\ENDIF", predList, $2,
                                                               ((SyntaxTree *) $3)->ozTex, $4,
                                                               ((SyntaxTree *) $5)->ozTex, $6);

             free(predList);
             free($2);
             free(((SyntaxTree *) $3)->ozTex);
             free($4);
             free(((SyntaxTree *) $5)->ozTex);
             free($6);
          }
        | pred_type TOK_THEN expr tok_endif
          {
             $$ = createCondExprNode(createLinkList($1), $3, NULL);

             ((SyntaxTree *) $$)->treeType = ((SyntaxTree *) $3)->treeType;
             ((SyntaxTree *) $$)->ozTex    = foztex("%s%s\\THEN %s%s\\ENDIF", ((SyntaxTree *) $1)->ozTex, $2,
                                                                              ((SyntaxTree *) $3)->ozTex, $4);

             free(((SyntaxTree *) $1)->ozTex);
             free($2);
             free(((SyntaxTree *) $3)->ozTex);
             free($4);
          }
        | pred_type TOK_THEN expr TOK_ELIF elif_exp
          {
             $$ = createCondExprNode(createLinkList($1), $3, $5);

             if(!typeCompare(getExprType($3), getExprType($5)))
             {
                yyuerror("Then branch and else branch are of incompatible types");
             }

             ((SyntaxTree *) $$)->treeType = ((SyntaxTree *) $3)->treeType;
             ((SyntaxTree *) $$)->ozTex    =
                   foztex("%s%s\\THEN %s%s\\ELIF %s", ((SyntaxTree *) $1)->ozTex, $2,
                                                      ((SyntaxTree *) $3)->ozTex, $4,
                                                      ((SyntaxTree *) $5)->ozTex);

             free(((SyntaxTree *) $1)->ozTex);
             free($2);
             free(((SyntaxTree *) $3)->ozTex);
             free($4);
             free(((SyntaxTree *) $5)->ozTex);
          }
        | pred_type TOK_THEN expr TOK_ELSE expr tok_endif
          {
             $$ = createCondExprNode(createLinkList($1), $3, $5);

             if(!typeCompare(getExprType($3), getExprType($5)))
             {
                yyuerror("Then branch and else branch are of incompatible types");
             }

             ((SyntaxTree *) $$)->treeType = ((SyntaxTree *) $3)->treeType;
             ((SyntaxTree *) $$)->ozTex    =
                   foztex("%s%s\\THEN %s%s\\ELSE %s%s\\ENDIF", ((SyntaxTree *) $1)->ozTex, $2,
                                                               ((SyntaxTree *) $3)->ozTex, $4,
                                                               ((SyntaxTree *) $5)->ozTex, $6);

             free(((SyntaxTree *) $1)->ozTex);
             free($2);
             free(((SyntaxTree *) $3)->ozTex);
             free($4);
             free(((SyntaxTree *) $5)->ozTex);
             free($6);
          }
        ;

decl_list1: decl_entry
            {
               $$ = createLinkList($1);
            }
          | decl_list1 decl_entry
            {
               appendLinkList($1, $2);

               $$ = $1;
            }
          ;

decl_entry: decl_type TOK_SEMICOLON
            {
               $$ = $1;

               INT8  *tmpTex = ((SyntaxTree *) $1)->ozTex;

               ((SyntaxTree *) $1)->ozTex = foztex("%s%s;", tmpTex, $2);

               free(tmpTex);
               free($2);
            }
          | decl_type TOK_SEMICOLON TOK_POUND TOK_OSQUARE post_props TOK_CSQUARE
            {
               ((DeclarationNode *) $1)->props = $5;

               $$ = $1;

               INT8  *tmpTex = ((SyntaxTree *) $1)->ozTex;

               ((SyntaxTree *) $1)->ozTex = foztex("%s%s;%s", tmpTex, $2, $3);

               free(tmpTex);
               free($2);
               free($3);
               free($4);
               free($6);
            }
          ;

decl_type: dsch_ref
           {
              $$ = $1;
           }
         | var_decl
           {
              $$ = $1;
           }
         | func_decl
           {
              $$ = $1;
           }
         | op_decl
           {
              $$ = $1;
           }
         ;

post_props: post_prop
            {
               $$ = createLinkList($1);
            }
          | post_props TOK_COMMA post_prop
            {
               appendLinkList($1, $3);

               $$ = $1;

               free($2);
            }
          ;

post_prop: word_list
           {
              $$ = createPropertyNode($1);
           }
         ;

dsch_ref: sch_type
          {
             SchemaTypeNode  *schType = (SchemaTypeNode *) $1;

             if((curSch != NULL) && (schType->refName != NULL) && (strcmp(curSch, schType->refName) == 0))
             {
                yyuerror("Recursive definition of schema %s", curSch);

                YYERROR;
             }

             LinkList  *subList = createGenSchSubList(schType);

             schType->expDecls = expand(schType->preDecor, schType->preCnt, schType->postDecor, schType->postCnt,
                                        getSchemaDecls(schType), subList);

             freeSubList(subList);

             if(!addDeclsToSymTab(schType->expDecls))
             {
                yyuerror("Unable to add delcarations to symbol table");

                YYERROR;
             }

             $$ = createDeclarationNode(NULL, SCH_REF_DECL, NULL, $1);

             ((SyntaxTree *) $$)->ozTex = schType->ozTex;
          }
        | sch_pre_decor sch_type
          {
             SchemaTypeNode  *schType = (SchemaTypeNode *) $2;

             if((curSch != NULL) && (schType->refName != NULL) && (strcmp(curSch, schType->refName) == 0))
             {
                yyuerror("Recursive definition of schema %s", curSch);

                YYERROR;
             }

             schType->preDecor = extractDecorType($1->token);
             schType->preCnt   = extractDecorCount($1->token);

             if(schType->preDecor == PRE_DELTA)
             {
                INT8  *tmpTex = schType->ozTex;
                INT8  *ozPre  = NULL;

                if(schType->preCnt > 1)
                {
                   ozPre = foztex("%s\\zDelta{%d}", $1->preFmt, schType->preCnt);
                }
                else
                {
                   ozPre = foztex("%s\\Delta ", $1->preFmt);
                }

                schType->ozTex = foztex("%s%s", ozPre, tmpTex);

                free(ozPre);
                free(tmpTex);
             }

             freeAToken($1);

             LinkList  *subList = createGenSchSubList(schType);

             schType->expDecls = expand(schType->preDecor, schType->preCnt, schType->postDecor, schType->postCnt,
                                        getSchemaDecls(schType), subList);

             freeSubList(subList);

             if(!addDeclsToSymTab(schType->expDecls))
             {
                yyuerror("Unable to add delcarations to symbol table");

                YYERROR;
             }

             $$ = createDeclarationNode(NULL, SCH_REF_DECL, NULL, $2);

             ((SyntaxTree *) $$)->ozTex = schType->ozTex;
          }
        | sch_type sch_post_decor
          {
             SchemaTypeNode  *schType = (SchemaTypeNode *) $1;

             if((curSch != NULL) && (schType->refName != NULL) && (strcmp(curSch, schType->refName) == 0))
             {
                yyuerror("Recursive definition of schema %s", curSch);

                YYERROR;
             }

             schType->postDecor = extractDecorType($2->token);
             schType->postCnt   = extractDecorCount($2->token);

             if(schType->postDecor == POST_PRI)
             {
                INT8  *tmpTex = schType->ozTex;
                INT8  *ozPost = NULL;

                if(schType->postCnt > 1)
                {
                   ozPost = foztex("\\zPri{%d}", schType->postCnt);
                }
                else
                {
                   ozPost = foztex("'");
                }

                schType->ozTex = foztex("%s%s%s", tmpTex, $2->preFmt, ozPost);

                free(tmpTex);
                free(ozPost);
             }

             freeAToken($2);

             LinkList  *subList = createGenSchSubList(schType);

             schType->expDecls = expand(schType->preDecor, schType->preCnt, schType->postDecor, schType->postCnt,
                                        getSchemaDecls(schType), subList);

             freeSubList(subList);

             if(!addDeclsToSymTab(schType->expDecls))
             {
                yyuerror("Unable to add delcarations to symbol table");

                YYERROR;
             }

             $$ = createDeclarationNode(NULL, SCH_REF_DECL, NULL, $1);

             ((SyntaxTree *) $$)->ozTex = schType->ozTex;
          }
        | sch_pre_decor sch_type sch_post_decor
          {
             SchemaTypeNode  *schType = (SchemaTypeNode *) $2;

             if((curSch != NULL) && (schType->refName != NULL) && (strcmp(curSch, schType->refName) == 0))
             {
                yyuerror("Recursive definition of schema %s", curSch);

                YYERROR;
             }

             schType->preDecor  = extractDecorType($1->token);
             schType->preCnt    = extractDecorCount($1->token);
             schType->postDecor = extractDecorType($3->token);
             schType->postCnt   = extractDecorCount($3->token);

             if(schType->preDecor == PRE_DELTA)
             {
                INT8  *tmpTex = schType->ozTex;
                INT8  *ozPre  = NULL;

                if(schType->preCnt > 1)
                {
                   ozPre = foztex("%s\\zDelta{%d}", $1->preFmt, schType->preCnt);
                }
                else
                {
                   ozPre = foztex("%s\\Delta ", $1->preFmt);
                }

                schType->ozTex = foztex("%s%s", ozPre, tmpTex);

                free(ozPre);
                free(tmpTex);
             }

             if(schType->postDecor == POST_PRI)
             {
                INT8  *tmpTex = schType->ozTex;
                INT8  *ozPost = NULL;

                if(schType->postCnt > 1)
                {
                   ozPost = foztex("\\zPri{%d}", schType->postCnt);
                }
                else
                {
                   ozPost = foztex("'");
                }

                schType->ozTex = foztex("%s%s%s", tmpTex, $3->preFmt, ozPost);

                free(tmpTex);
                free(ozPost);
             }

             freeAToken($1);
             freeAToken($3);

             LinkList  *subList = createGenSchSubList(schType);

             schType->expDecls = expand(schType->preDecor, schType->preCnt, schType->postDecor, schType->postCnt,
                                        getSchemaDecls(schType), subList);

             freeSubList(subList);

             if(!addDeclsToSymTab(schType->expDecls))
             {
                yyuerror("Unable to add delcarations to symbol table");

                YYERROR;
             }

             $$ = createDeclarationNode(NULL, SCH_REF_DECL, NULL, $2);

             ((SyntaxTree *) $$)->ozTex = schType->ozTex;
          }
        ;

var_decl: var_ident TOK_COLON expr
          {
             $$ = createDeclarationNode(NULL, VAR_DECL, createVariableNode($1->token, NULL), $3);

             if(!isSetExpr($3))
             {
                yyuerror("Defining expression is not a set type");
             }

             printType($1->token, ((SyntaxTree *) $3)->treeType);

             ((SyntaxTree *) $$)->treeType = getTypeBoundType(((SyntaxTree *) $3)->treeType);
             ((SyntaxTree *) $$)->ozTex    = foztex("%s%s%s\\colon %s", $1->preFmt, getOzXfm($1->token), $2,
                                                                        ((SyntaxTree *) $3)->ozTex);

             ((SyntaxTree *) ((DeclarationNode *) $$)->ident)->treeType =
                   getTypeBoundType(((SyntaxTree *) $3)->treeType);

             free($2);
             free(((SyntaxTree *) $3)->ozTex);

             printType("bound", ((SyntaxTree *) $$)->treeType);

             if(!addSymToTable($1->token, TOK_VAR_BINDING, $$))
             {
                yyuerror("Unable to add variable to symbol table");

                exit(-1);
             }

             $1->token = NULL;

             freeAToken($1);
          }
        | var_ident var_post_decor TOK_COLON expr
          {
             tmpStr = malloc(strlen($1->token) + strlen($2->token) + 1);

             memset(tmpStr, 0, strlen($1->token) + strlen($2->token) + 1);
             strncpy(tmpStr, $1->token, strlen($1->token));
             strncpy(&(tmpStr[strlen($1->token)]), $2->token, strlen($2->token));

             $$ = createDeclarationNode(NULL, VAR_DECL, createVariableNode($1->token, $2->token), $4);

             DecorType  postDecor = extractDecorType($2->token);
             UINT8      postCnt   = extractDecorCount($2->token);
             INT8      *ozPost   = NULL;

             if(postDecor == POST_PRI)
             {
                if(postCnt > 1)
                {
                   ozPost = foztex("\\zPri{%d}", postCnt);
                }
                else
                {
                   ozPost = foztex("'");
                }
             }
             else if(postDecor == POST_IN)
             {
                ozPost = foztex("?");
             }
             else if(postDecor == POST_OUT)
             {
                ozPost = foztex("!");
             }

             ((SyntaxTree *) $$)->ozTex = foztex("%s%s%s%s%s\\colon %s", $1->preFmt, getOzXfm($1->token),
                                                                         $2->preFmt, ozPost, $3,
                                                                         ((SyntaxTree *) $4)->ozTex);

             free(ozPost);
             freeAToken($2);
             free($3);
             free(((SyntaxTree *) $4)->ozTex);

             if(!isSetExpr($4))
             {
                yyuerror("Defining expression is not a set type");
             }

             printType($1->token, ((SyntaxTree *) $4)->treeType);

             ((SyntaxTree *) $$)->treeType = getTypeBoundType(((SyntaxTree *) $4)->treeType);

             ((SyntaxTree *) ((DeclarationNode *) $$)->ident)->treeType =
                   getTypeBoundType(((SyntaxTree *) $4)->treeType);

             printType("bound", ((SyntaxTree *) $$)->treeType);

             if(!addSymToTable(tmpStr, TOK_VAR_BINDING, $$))
             {
                yyuerror("Unable to add variable to symbol table");

                exit(-1);
             }

             free(tmpStr);

             tmpStr    = NULL;
             $1->token = NULL;

             freeAToken($1);
          }
        ;

func_decl: TOK_BOOL_ID TOK_IDENT TOK_COLON expr
           {
              $$ = createDeclarationNode(NULL, PRED_FUNC_DECL, $2->token, $4);

              INT8  *identFmt = $2->preFmt;

              if(strspn(identFmt, " \t") == strlen(identFmt))
              {
                 identFmt = "";
              }

              printType($2->token, ((SyntaxTree *) $4)->treeType);

              ((SyntaxTree *) $$)->treeType = getTypeBoundType(((SyntaxTree *) $4)->treeType);
              ((SyntaxTree *) $$)->ozTex    = foztex("%s%s%s%s\\colon %s", $1, identFmt, getOzXfm($2->token),
                                                                           $3, ((SyntaxTree *) $4)->ozTex);

              free($1);
              free($3);
              free(((SyntaxTree *) $4)->ozTex);

              printType("bound", ((SyntaxTree *) $$)->treeType);

              if(!addSymToTable($2->token, TOK_PRED_FUNC, $$))
              {
                 yyuerror("Unable to add pred function name to symbol table");

                 exit(-1);
              }

              $2->token = NULL;

              freeAToken($2);
           }
         | TOK_FUNC_ID TOK_IDENT TOK_COLON expr
           {
              $$ = createDeclarationNode(NULL, EXPR_FUNC_DECL, $2->token, $4);

              INT8  *identFmt = $2->preFmt;

              if(strspn(identFmt, " \t") == strlen(identFmt))
              {
                 identFmt = "";
              }

              printType($2->token, ((SyntaxTree *) $4)->treeType);

              ((SyntaxTree *) $$)->treeType = getTypeBoundType(((SyntaxTree *) $4)->treeType);
              ((SyntaxTree *) $$)->ozTex    = foztex("%s%s%s%s\\colon %s", $1, identFmt, getOzXfm($2->token),
                                                                           $3, ((SyntaxTree *) $4)->ozTex);

              free($1);
              free($3);
              free(((SyntaxTree *) $4)->ozTex);

              printType("bound", ((SyntaxTree *) $$)->treeType);

              if(!addSymToTable($2->token, TOK_EXPR_FUNC, $$))
              {
                 yyuerror("Unable to add expr function name to symbol table");

                 exit(-1);
              }

              $2->token = NULL;

              freeAToken($2);
           }
         ;

op_decl: TOK_REL_ID TOK_OP_TYPE TOK_IDENT TOK_COLON expr
         {
            INT8  *identFmt = $3->preFmt;
            INT8  *typeFmt  = $2->preFmt;

            if(strspn(identFmt, " \t") == strlen(identFmt))
            {
               identFmt = "";
            }

            if(strspn(typeFmt, " \t") == strlen(typeFmt))
            {
               typeFmt = "";
            }

            if(strncmp($2->token, "pre", 3) == 0)
            {
               $$ = createDeclarationNode(NULL, REL_OP_PRE_DECL, $3->token, $5);

               ((SyntaxTree *) $$)->ozTex = foztex("%s%s%s%s\\_%s\\colon %s", $1, typeFmt, identFmt,
                                                                              getOzXfm($3->token), $4,
                                                                              ((SyntaxTree *) $5)->ozTex);
            }
            else if(strncmp($2->token, "post", 4) == 0)
            {
               $$ = createDeclarationNode(NULL, REL_OP_POST_DECL, $3->token, $5);

               ((SyntaxTree *) $$)->ozTex = foztex("%s%s\\_%s%s%s\\colon %s", $1, typeFmt, identFmt,
                                                                              getOzXfm($3->token), $4,
                                                                              ((SyntaxTree *) $5)->ozTex);
            }
            else if(strncmp($2->token, "bin", 3) == 0)
            {
               $$ = createDeclarationNode(NULL, REL_OP_IN_DECL, $3->token, $5);

               ((SyntaxTree *) $$)->ozTex = foztex("%s%s\\_%s%s\\_%s\\colon %s", $1, typeFmt, identFmt,
                                                                                 getOzXfm($3->token), $4,
                                                                                 ((SyntaxTree *) $5)->ozTex);
            }

            free($1);
            free($4);
            free(((SyntaxTree *) $5)->ozTex);

            printType($3->token, ((SyntaxTree *) $5)->treeType);

            ((SyntaxTree *) $$)->treeType = getTypeBoundType(((SyntaxTree *) $5)->treeType);

            printType("bound", ((SyntaxTree *) $$)->treeType);

            if(!addSymToTable($3->token, getOpSymType("rel", $2->token), $$))
            {
                 yyuerror("Unable to add relational operator name to symbol table");

                 exit(-1);
            }

            $3->token = NULL;

            freeAToken($2);
            freeAToken($3);
         }
       | TOK_OPER_ID TOK_OP_TYPE TOK_IDENT TOK_COLON expr
         {
            INT8  *identFmt = $3->preFmt;
            INT8  *typeFmt  = $2->preFmt;

            if(strspn(identFmt, " \t") == strlen(identFmt))
            {
               identFmt = "";
            }

            if(strspn(typeFmt, " \t") == strlen(typeFmt))
            {
               typeFmt = "";
            }

            if(strncmp($2->token, "pre", 3) == 0)
            {
               $$ = createDeclarationNode(NULL, EXPR_OP_PRE_DECL, $3->token, $5);

               ((SyntaxTree *) $$)->ozTex = foztex("%s%s%s%s\\_%s\\colon %s", $1, typeFmt, identFmt,
                                                                              getOzXfm($3->token), $4,
                                                                              ((SyntaxTree *) $5)->ozTex);
            }
            else if(strncmp($2->token, "post", 4) == 0)
            {
               $$ = createDeclarationNode(NULL, EXPR_OP_POST_DECL, $3->token, $5);

               ((SyntaxTree *) $$)->ozTex = foztex("%s%s\\_%s%s%s\\colon %s", $1, typeFmt, identFmt,
                                                                              getOzXfm($3->token), $4,
                                                                              ((SyntaxTree *) $5)->ozTex);
            }
            else if(strncmp($2->token, "bin", 3) == 0)
            {
               $$ = createDeclarationNode(NULL, EXPR_OP_IN_DECL, $3->token, $5);

               ((SyntaxTree *) $$)->ozTex = foztex("%s%s\\_%s%s\\_%s\\colon %s", $1, typeFmt, identFmt,
                                                                                getOzXfm($3->token), $4,
                                                                                ((SyntaxTree *) $5)->ozTex);
            }

            free($1);
            free($4);
            free(((SyntaxTree *) $5)->ozTex);

            printType($3->token, ((SyntaxTree *) $5)->treeType);

            ((SyntaxTree *) $$)->treeType = getTypeBoundType(((SyntaxTree *) $5)->treeType);

            printType("bound", ((SyntaxTree *) $$)->treeType);

            if(!addSymToTable($3->token, getOpSymType("oper", $2->token), $$))
            {
                 yyuerror("Unable to add expr operator name to symbol table");

              exit(-1);
            }

            $3->token = NULL;

            freeAToken($2);
            freeAToken($3);
         }
       ;

pred: pred_list0
      {
         $$ = $1;
      }
    ;

pred_list0: /* Empty is OK */
            {
               $$ = NULL;
            }
          | pred_list
            {
               $$ = $1;
            }
          | pred_type
            {
               PredicateNode  *predNode = createPredicateNode(NULL, (SyntaxTree *) $1);

               predNode->ozTex = ((SyntaxTree *) $1)->ozTex;

               $$ = createLinkList(predNode);
            }
          ;

pred_list: pred_entry
           {
              $$ = createLinkList($1);
           }
         | pred_list pred_entry
           {
              appendLinkList($1, $2);

              $$ = $1;
           }
         ;

pred_entry: pred_type TOK_SEMICOLON
            {
               $$ = createPredicateNode(NULL, (SyntaxTree *) $1);

               INT8  *tmpTex = ((SyntaxTree *) $1)->ozTex;

               ((SyntaxTree *) $$)->ozTex = foztex("%s%s;", tmpTex, $2);

               free(tmpTex);
               free($2);
            }
          | pred_type TOK_SEMICOLON TOK_POUND TOK_OSQUARE post_props TOK_CSQUARE
            {
               $$ = createPredicateNode($5, (SyntaxTree *) $1);

               INT8  *tmpTex = ((SyntaxTree *) $1)->ozTex;

               ((SyntaxTree *) $$)->ozTex = foztex("%s%s;%s", tmpTex, $2, $3);

               free(tmpTex);
               free($2);
               free($3);
               free($4);
               free($6);
            }
          ;

pred_type: quantifier
           {
              $$ = $1;
           }
         | let_pred
           {
              $$ = $1;
           }
         | schema_app
           {
              $$ = $1;
           }
         | TOK_PRED_FUNC tok_oparen expr tok_cparen %prec TOK_FUNC
           {
              $$ = handleRelFunc($1->token, $3);

              ((SyntaxTree *) $$)->ozTex = foztex("%s%s%s(%s%s)", $1->preFmt, getOzXfm($1->token), $2,
                                                                  ((SyntaxTree *) $3)->ozTex, $4);

              $1->token = NULL;

              freeAToken($1);
              free($2);
              free(((SyntaxTree *) $3)->ozTex);
              free($4);
           }
         | TOK_PRED_FUNC tuple %prec TOK_FUNC
           {
              $$ = handleRelFunc($1->token, $2);

              ((SyntaxTree *) $$)->ozTex = foztex("%s%s%s", $1->preFmt, getOzXfm($1->token),
                                                            ((SyntaxTree *) $2)->ozTex);

              $1->token = NULL;

              freeAToken($1);
              free(((SyntaxTree *) $2)->ozTex);
           }
         | cond_pred
           {
              $$ = $1;
           }
         | tok_oparen pred_type tok_cparen %prec TOK_PAREN
           {
              $$ = $2;

              INT8  *tmpTex = ((SyntaxTree *) $2)->ozTex;

              ((SyntaxTree *) $$)->ozTex = foztex("%s(%s%s)", $1, tmpTex, $3);

              free(tmpTex);
              free($1);
              free($3);
           }
         | TOK_TRUE
           {
              $$ = createPredLiteralNode(strdup("true"));

              ((SyntaxTree *) $$)->ozTex = foztex("%strue", $1);

              free($1);
           }
         | TOK_FALSE
           {
              $$ = createPredLiteralNode(strdup("false"));

              ((SyntaxTree *) $$)->ozTex = foztex("%sfalse", $1);

              free($1);
           }
         | TOK_P1RPRE expr
           {
              $$ = handleRPreOp($1->token, $2);

              ((SyntaxTree *) $$)->ozTex = foztex("%s\\mathrel{%s}%s", $1->preFmt, getOzXfm($1->token),
                                                                       ((SyntaxTree *) $2)->ozTex);

              $1->token = NULL;

              freeAToken($1);
              free(((SyntaxTree *) $2)->ozTex);
           }
         | TOK_P2RPRE expr
           {
              $$ = handleRPreOp($1->token, $2);

              ((SyntaxTree *) $$)->ozTex = foztex("%s\\mathrel{%s}%s", $1->preFmt, getOzXfm($1->token),
                                                                       ((SyntaxTree *) $2)->ozTex);

              $1->token = NULL;

              freeAToken($1);
              free(((SyntaxTree *) $2)->ozTex);
           }
         | TOK_P3RPRE expr
           {
              $$ = handleRPreOp($1->token, $2);

              ((SyntaxTree *) $$)->ozTex = foztex("%s\\mathrel{%s}%s", $1->preFmt, getOzXfm($1->token),
                                                                       ((SyntaxTree *) $2)->ozTex);

              $1->token = NULL;

              freeAToken($1);
              free(((SyntaxTree *) $2)->ozTex);
           }
         | TOK_P4RPRE expr
           {
              $$ = handleRPreOp($1->token, $2);

              ((SyntaxTree *) $$)->ozTex = foztex("%s\\mathrel{%s}%s", $1->preFmt, getOzXfm($1->token),
                                                                       ((SyntaxTree *) $2)->ozTex);

              $1->token = NULL;

              freeAToken($1);
              free(((SyntaxTree *) $2)->ozTex);
           }
         | TOK_P5RPRE expr
           {
              $$ = handleRPreOp($1->token, $2);

              ((SyntaxTree *) $$)->ozTex = foztex("%s\\mathrel{%s}%s", $1->preFmt, getOzXfm($1->token),
                                                                       ((SyntaxTree *) $2)->ozTex);

              $1->token = NULL;

              freeAToken($1);
              free(((SyntaxTree *) $2)->ozTex);
           }
         | TOK_P6RPRE expr
           {
              $$ = handleRPreOp($1->token, $2);

              ((SyntaxTree *) $$)->ozTex = foztex("%s\\mathrel{%s}%s", $1->preFmt, getOzXfm($1->token),
                                                                       ((SyntaxTree *) $2)->ozTex);

              $1->token = NULL;

              freeAToken($1);
              free(((SyntaxTree *) $2)->ozTex);
           }
         | TOK_P7RPRE expr
           {
              $$ = handleRPreOp($1->token, $2);

              ((SyntaxTree *) $$)->ozTex = foztex("%s\\mathrel{%s}%s", $1->preFmt, getOzXfm($1->token),
                                                                       ((SyntaxTree *) $2)->ozTex);

              $1->token = NULL;

              freeAToken($1);
              free(((SyntaxTree *) $2)->ozTex);
           }
         | TOK_P8RPRE expr
           {
              $$ = handleRPreOp($1->token, $2);

              ((SyntaxTree *) $$)->ozTex = foztex("%s\\mathrel{%s}%s", $1->preFmt, getOzXfm($1->token),
                                                                       ((SyntaxTree *) $2)->ozTex);

              $1->token = NULL;

              freeAToken($1);
              free(((SyntaxTree *) $2)->ozTex);
           }
         | TOK_P9RPRE expr
           {
              $$ = handleRPreOp($1->token, $2);

              ((SyntaxTree *) $$)->ozTex = foztex("%s\\mathrel{%s}%s", $1->preFmt, getOzXfm($1->token),
                                                                       ((SyntaxTree *) $2)->ozTex);

              $1->token = NULL;

              freeAToken($1);
              free(((SyntaxTree *) $2)->ozTex);
           }
         | expr TOK_P1RIN expr
           {
              $$ = handleRInOp($1, $2->token, $3);

              ((SyntaxTree *) $$)->ozTex = foztex("%s%s\\mathrel{%s}%s",
                                                  ((SyntaxTree *) $1)->ozTex, $2->preFmt,
                                                  getOzXfm($2->token),
                                                  ((SyntaxTree *) $3)->ozTex);

              $2->token = NULL;

              free(((SyntaxTree *) $1)->ozTex);
              freeAToken($2);
              free(((SyntaxTree *) $3)->ozTex);
           }
         | expr TOK_P2RIN expr
           {
              $$ = handleRInOp($1, $2->token, $3);

              ((SyntaxTree *) $$)->ozTex = foztex("%s%s\\mathrel{%s}%s",
                                                  ((SyntaxTree *) $1)->ozTex, $2->preFmt,
                                                  getOzXfm($2->token),
                                                  ((SyntaxTree *) $3)->ozTex);

              $2->token = NULL;

              free(((SyntaxTree *) $1)->ozTex);
              freeAToken($2);
              free(((SyntaxTree *) $3)->ozTex);
           }
         | expr TOK_P3RIN expr
           {
              $$ = handleRInOp($1, $2->token, $3);

              ((SyntaxTree *) $$)->ozTex = foztex("%s%s\\mathrel{%s}%s",
                                                  ((SyntaxTree *) $1)->ozTex, $2->preFmt,
                                                  getOzXfm($2->token),
                                                  ((SyntaxTree *) $3)->ozTex);

              $2->token = NULL;

              free(((SyntaxTree *) $1)->ozTex);
              freeAToken($2);
              free(((SyntaxTree *) $3)->ozTex);
           }
         | expr TOK_P4RIN expr
           {
              $$ = handleRInOp($1, $2->token, $3);

              ((SyntaxTree *) $$)->ozTex = foztex("%s%s\\mathrel{%s}%s",
                                                  ((SyntaxTree *) $1)->ozTex, $2->preFmt,
                                                  getOzXfm($2->token),
                                                  ((SyntaxTree *) $3)->ozTex);

              $2->token = NULL;

              free(((SyntaxTree *) $1)->ozTex);
              freeAToken($2);
              free(((SyntaxTree *) $3)->ozTex);
           }
         | expr TOK_EQUALS expr
           {
              DEBUG("Parsed = operator\n");
              $$ = handleRInOp($1, strdup("="), $3);

              ((SyntaxTree *) $$)->ozTex = foztex("%s%s=%s", ((SyntaxTree *) $1)->ozTex, $2,
                                                             ((SyntaxTree *) $3)->ozTex);

              free(((SyntaxTree *) $1)->ozTex);
              free($2);
              free(((SyntaxTree *) $3)->ozTex);
           }
         | expr TOK_P5RIN expr
           {
              $$ = handleRInOp($1, $2->token, $3);

              ((SyntaxTree *) $$)->ozTex = foztex("%s%s\\mathrel{%s}%s",
                                                  ((SyntaxTree *) $1)->ozTex, $2->preFmt,
                                                  getOzXfm($2->token),
                                                  ((SyntaxTree *) $3)->ozTex);

              $2->token = NULL;

              free(((SyntaxTree *) $1)->ozTex);
              freeAToken($2);
              free(((SyntaxTree *) $3)->ozTex);
           }
         | expr TOK_P6RIN expr
           {
              $$ = handleRInOp($1, $2->token, $3);

              ((SyntaxTree *) $$)->ozTex = foztex("%s%s\\mathrel{%s}%s",
                                                  ((SyntaxTree *) $1)->ozTex, $2->preFmt,
                                                  getOzXfm($2->token),
                                                  ((SyntaxTree *) $3)->ozTex);

              $2->token = NULL;

              free(((SyntaxTree *) $1)->ozTex);
              freeAToken($2);
              free(((SyntaxTree *) $3)->ozTex);
           }
         | expr TOK_P7RIN expr
           {
              $$ = handleRInOp($1, $2->token, $3);

              ((SyntaxTree *) $$)->ozTex = foztex("%s%s\\mathrel{%s}%s",
                                                  ((SyntaxTree *) $1)->ozTex, $2->preFmt,
                                                  getOzXfm($2->token),
                                                  ((SyntaxTree *) $3)->ozTex);

              $2->token = NULL;

              free(((SyntaxTree *) $1)->ozTex);
              freeAToken($2);
              free(((SyntaxTree *) $3)->ozTex);
           }
         | expr TOK_P8RIN expr
           {
              $$ = handleRInOp($1, $2->token, $3);

              ((SyntaxTree *) $$)->ozTex = foztex("%s%s\\mathrel{%s}%s",
                                                  ((SyntaxTree *) $1)->ozTex, $2->preFmt,
                                                  getOzXfm($2->token),
                                                  ((SyntaxTree *) $3)->ozTex);

              $2->token = NULL;

              free(((SyntaxTree *) $1)->ozTex);
              freeAToken($2);
              free(((SyntaxTree *) $3)->ozTex);
           }
         | expr TOK_P9RIN expr
           {
              $$ = handleRInOp($1, $2->token, $3);

              ((SyntaxTree *) $$)->ozTex = foztex("%s%s\\mathrel{%s}%s",
                                                  ((SyntaxTree *) $1)->ozTex, $2->preFmt,
                                                  getOzXfm($2->token),
                                                  ((SyntaxTree *) $3)->ozTex);

              $2->token = NULL;

              free(((SyntaxTree *) $1)->ozTex);
              freeAToken($2);
              free(((SyntaxTree *) $3)->ozTex);
           }
         | expr TOK_P1RPOST
           {
              $$ = handleRPostOp($1, $2->token);

              ((SyntaxTree *) $$)->ozTex = foztex("%s%s\\mathrel{%s}", ((SyntaxTree *) $1)->ozTex, $2->preFmt,
                                                                       getOzXfm($2->token));

              $2->token = NULL;

              free(((SyntaxTree *) $1)->ozTex);
              freeAToken($2);
           }
         | expr TOK_P2RPOST
           {
              $$ = handleRPostOp($1, $2->token);

              ((SyntaxTree *) $$)->ozTex = foztex("%s%s\\mathrel{%s}", ((SyntaxTree *) $1)->ozTex, $2->preFmt,
                                                                       getOzXfm($2->token));

              $2->token = NULL;

              free(((SyntaxTree *) $1)->ozTex);
              freeAToken($2);
           }
         | expr TOK_P3RPOST
           {
              $$ = handleRPostOp($1, $2->token);

              ((SyntaxTree *) $$)->ozTex = foztex("%s%s\\mathrel{%s}", ((SyntaxTree *) $1)->ozTex, $2->preFmt,
                                                                       getOzXfm($2->token));

              $2->token = NULL;

              free(((SyntaxTree *) $1)->ozTex);
              freeAToken($2);
           }
         | expr TOK_P4RPOST
           {
              $$ = handleRPostOp($1, $2->token);

              ((SyntaxTree *) $$)->ozTex = foztex("%s%s\\mathrel{%s}", ((SyntaxTree *) $1)->ozTex, $2->preFmt,
                                                                       getOzXfm($2->token));

              $2->token = NULL;

              free(((SyntaxTree *) $1)->ozTex);
              freeAToken($2);
           }
         | expr TOK_P5RPOST
           {
              $$ = handleRPostOp($1, $2->token);

              ((SyntaxTree *) $$)->ozTex = foztex("%s%s\\mathrel{%s}", ((SyntaxTree *) $1)->ozTex, $2->preFmt,
                                                                       getOzXfm($2->token));

              $2->token = NULL;

              free(((SyntaxTree *) $1)->ozTex);
              freeAToken($2);
           }
         | expr TOK_P6RPOST
           {
              $$ = handleRPostOp($1, $2->token);

              ((SyntaxTree *) $$)->ozTex = foztex("%s%s\\mathrel{%s}", ((SyntaxTree *) $1)->ozTex, $2->preFmt,
                                                                       getOzXfm($2->token));

              $2->token = NULL;

              free(((SyntaxTree *) $1)->ozTex);
              freeAToken($2);
           }
         | expr TOK_P7RPOST
           {
              $$ = handleRPostOp($1, $2->token);

              ((SyntaxTree *) $$)->ozTex = foztex("%s%s\\mathrel{%s}", ((SyntaxTree *) $1)->ozTex, $2->preFmt,
                                                                       getOzXfm($2->token));

              $2->token = NULL;

              free(((SyntaxTree *) $1)->ozTex);
              freeAToken($2);
           }
         | expr TOK_P8RPOST
           {
              $$ = handleRPostOp($1, $2->token);

              ((SyntaxTree *) $$)->ozTex = foztex("%s%s\\mathrel{%s}", ((SyntaxTree *) $1)->ozTex, $2->preFmt,
                                                                       getOzXfm($2->token));

              $2->token = NULL;

              free(((SyntaxTree *) $1)->ozTex);
              freeAToken($2);
           }
         | expr TOK_P9RPOST
           {
              $$ = handleRPostOp($1, $2->token);

              ((SyntaxTree *) $$)->ozTex = foztex("%s%s\\mathrel{%s}", ((SyntaxTree *) $1)->ozTex, $2->preFmt,
                                                                       getOzXfm($2->token));

              $2->token = NULL;

              free(((SyntaxTree *) $1)->ozTex);
              freeAToken($2);
           }
         | pred_type TOK_IMPLIES pred_type
           {
              $$ = createPredOpNode($1, strdup("==>"), $3);

              ((SyntaxTree *) $$)->ozTex = foztex("%s%s\\imp %s", ((SyntaxTree *) $1)->ozTex, $2,
                                                                  ((SyntaxTree *) $3)->ozTex);

              free(((SyntaxTree *) $1)->ozTex);
              free($2);
              free(((SyntaxTree *) $3)->ozTex);
           }
         | pred_type TOK_EQUIV pred_type
           {
              $$ = createPredOpNode($1, strdup("<=>"), $3);

              ((SyntaxTree *) $$)->ozTex = foztex("%s%s\\iff %s", ((SyntaxTree *) $1)->ozTex, $2,
                                                                  ((SyntaxTree *) $3)->ozTex);

              free(((SyntaxTree *) $1)->ozTex);
              free($2);
              free(((SyntaxTree *) $3)->ozTex);
           }
         | pred_type TOK_LOR pred_type
           {
              DEBUG("Parsed || operator\n");
              $$ = createPredOpNode($1, strdup("||"), $3);

              ((SyntaxTree *) $$)->ozTex = foztex("%s%s\\lor %s", ((SyntaxTree *) $1)->ozTex, $2,
                                                                  ((SyntaxTree *) $3)->ozTex);

              free(((SyntaxTree *) $1)->ozTex);
              free($2);
              free(((SyntaxTree *) $3)->ozTex);
           }
         | pred_type TOK_LAND pred_type
           {
              $$ = createPredOpNode($1, strdup("&&"), $3);

              ((SyntaxTree *) $$)->ozTex = foztex("%s%s\\land %s", ((SyntaxTree *) $1)->ozTex, $2,
                                                                   ((SyntaxTree *) $3)->ozTex);

              free(((SyntaxTree *) $1)->ozTex);
              free($2);
              free(((SyntaxTree *) $3)->ozTex);
           }
         | TOK_EXCLAIM pred_type
           {
              $$ = createPredOpNode(NULL, strdup("!"), $2);

              ((SyntaxTree *) $$)->ozTex = foztex("%s\\lnot\\!\\! %s", $1, ((SyntaxTree *) $2)->ozTex);

              free($1);
              free(((SyntaxTree *) $2)->ozTex);
           }
         ;

quantifier: all_quant
            {
               $$ = $1;
            }
          | exist_quant
            {
               $$ = $1;
            }
          | uniq_quant
            {
               $$ = $1;
            }
          ;

all_quant: TOK_ALL TOK_OCURLY decl_list1 TOK_QUEST pred_list0 TOK_AT pred_list0 TOK_CCURLY
           {
              if(!popSymStack())
              {
                 yyuerror("Unable to pop stack for all quantifier");

                 exit(-1);
              }

              $$ = createPredQuantNode(strdup("forAll"), $3, $5, $7);

              INT8  *declList = list2oz($3, "", "", "");
              INT8  *filtList = list2oz($5, "", "|", "");
              INT8  *predList = list2oz($7, "", "@", "");

              ((SyntaxTree *) $$)->ozTex = foztex("%s\\all%s(%s%s%s%s%s%s)", $1, $2, declList,
                                                                             $4, filtList,
                                                                             $6, predList, $8);

              free($1);
              free($2);
              free(declList);
              free($4);
              free(filtList);
              free($6);
              free(predList);
              free($8);
           }
         ;

exist_quant: TOK_EXIST TOK_OCURLY decl_list1 TOK_QUEST pred_list0 TOK_AT pred_list0 TOK_CCURLY
             {
                if(!popSymStack())
                {
                   yyuerror("Unable to pop stack for exist quantifier");

                   exit(-1);
                }

                $$ = createPredQuantNode(strdup("exists"), $3, $5, $7);

                INT8  *declList = list2oz($3, "", "", "");
                INT8  *filtList = list2oz($5, "", "|", "");
                INT8  *predList = list2oz($7, "", "@", "");

                ((SyntaxTree *) $$)->ozTex = foztex("%s\\exists%s(%s%s%s%s%s%s)", $1, $2, declList,
                                                                                 $4, filtList,
                                                                                  $6, predList, $8);

                free($1);
                free($2);
                free(declList);
                free($4);
                free(filtList);
                free($6);
                free(predList);
                free($8);
             }
           ;

uniq_quant: TOK_UNIQ TOK_OCURLY decl_list1 TOK_QUEST pred_list0 TOK_AT pred_list0 TOK_CCURLY
            {
               if(!popSymStack())
               {
                  yyuerror("Unable to pop stack for exist1 quantifier");

                  exit(-1);
               }

               $$ = createPredQuantNode(strdup("exists1"), $3, $5, $7);

               INT8  *declList = list2oz($3, "", "", "");
               INT8  *filtList = list2oz($5, "", "|", "");
               INT8  *predList = list2oz($7, "", "@", "");

               ((SyntaxTree *) $$)->ozTex = foztex("%s\\exione%s(%s%s%s%s%s%s)", $1, $2, declList,
                                                                                 $4, filtList,
                                                                                 $6, predList, $8);

               free($1);
               free($2);
               free(declList);
               free($4);
               free(filtList);
               free($6);
               free(predList);
               free($8);
            }
          ;

let_pred: TOK_LET TOK_OCURLY let_list TOK_AT pred_list0 TOK_CCURLY
          {
             if(!popSymStack())
             {
                yyuerror("Unable to pop stack for let predicate");

                exit(-1);
             }

             $$ = createLetPredNode($3, $5);

             INT8  *declList = list2oz($3, "", "", "");
             INT8  *predList = list2oz($5, "", "@", "");

             ((SyntaxTree *) $$)->ozTex = foztex("%s\\LET%s(%s%s%s%s)", $1, $2, declList, $4,
                                                                        predList, $6);

             free($1);
             free($2);
             free(declList);
             free($4);
             free(predList);
             free($6);
          }
        ;

schema_app: TOK_OCURLY expr TOK_CCURLY expr TOK_OCURLY expr TOK_CCURLY %prec TOK_SCH_APPL
            {
               $$ = createSchemaAppNode($2, $4, $6, 1);

               if(!isSchemaBindExpr($2))
               {
                  yyuerror("Pre-condition is not a schema binding");
               }
               else if(!isSchemaTypeExpr($4))
               {
                  yyuerror("Command is not a schema type");
               }
               else if(!isSchemaBindExpr($6))
               {
                  yyuerror("Post-condition is not a schema binding");
               }
               else
               {
                  TreeType  *preCond     = ((SyntaxTree *) $2)->treeType;
                  TreeType  *postCond    = ((SyntaxTree *) $6)->treeType;
                  TreeType  *preCommand  = preSchema(getBoundSchemaType(((SyntaxTree *) $4)->treeType));
                  TreeType  *postCommand = postSchema(getBoundSchemaType(((SyntaxTree *) $4)->treeType));
                  TreeType  *unpPostComm = unprimeSchema(postCommand);
                  TreeType  *unpPreCond  = unprimeSchema(preCond);
                  TreeType  *unpPostCond = unprimeSchema(postCond);

                  /* Freeing of preCommand and postCommand is required in each branch
                     because yyuerror may cause the compiler to exit */
                  if(!typeCompare(preCommand, unpPreCond))
                  {
                     freeTypeTree(preCommand);
                     freeTypeTree(postCommand);
                     freeTypeTree(unpPostComm);
                     freeTypeTree(unpPreCond);
                     freeTypeTree(unpPostCond);

                     yyuerror("Pre-condition type mismatch");
                  }
                  else if(!typeCompare(unpPostComm, unpPostCond))
                  {
                     freeTypeTree(preCommand);
                     freeTypeTree(postCommand);
                     freeTypeTree(unpPostComm);
                     freeTypeTree(unpPreCond);
                     freeTypeTree(unpPostCond);

                     yyuerror("Post-condition type mismatch");
                  }
                  else
                  {
                     freeTypeTree(preCommand);
                     freeTypeTree(postCommand);
                     freeTypeTree(unpPostComm);
                     freeTypeTree(unpPreCond);
                     freeTypeTree(unpPostCond);
                  }
               }

               ((SyntaxTree *) $$)->ozTex =
                     foztex("%s\\{%s%s\\}%s%s\\{%s%s\\}", $1, ((SyntaxTree *) $2)->ozTex, $3,
                                                          ((SyntaxTree *) $4)->ozTex, $5,
                                                          ((SyntaxTree *) $6)->ozTex, $7);

               free($1);
               free(((SyntaxTree *) $2)->ozTex);
               free($3);
               free(((SyntaxTree *) $4)->ozTex);
               free($5);
               free(((SyntaxTree *) $6)->ozTex);
               free($7);
            }
          | TOK_OCURLY expr TOK_CCURLY TOK_ZXI TOK_OCURLY expr TOK_CCURLY %prec TOK_SCH_APPL
            {
               $$ = createSchemaAppNode($2, NULL, $6, 1);

               if(!isSchemaBindExpr($2))
               {
                  yyuerror("Pre-condition is not a schema binding");
               }
               else if(!isSchemaBindExpr($6))
               {
                  yyuerror("Post-condition is not a schema binding");
               }
               else
               {
                  TreeType  *unpPreCond  = unprimeSchema(((SyntaxTree *) $2)->treeType);
                  TreeType  *unpPostCond = unprimeSchema(((SyntaxTree *) $6)->treeType);

                  if(!typeCompare(unpPreCond, unpPostCond))
                  {
                     freeTypeTree(unpPreCond);
                     freeTypeTree(unpPostCond);

                     yyuerror("Condition type mismatch");
                  }
                  else
                  {
                     freeTypeTree(unpPreCond);
                     freeTypeTree(unpPostCond);
                  }
               }

               ((SyntaxTree *) $$)->ozTex =
                     foztex("%s\\{%s%s\\}%s\\Xi%s\\{%s%s\\}", $1, ((SyntaxTree *) $2)->ozTex, $3, $4,
                                                              $5, ((SyntaxTree *) $6)->ozTex, $7);

               free($1);
               free(((SyntaxTree *) $2)->ozTex);
               free($3);
               free($4);
               free($5);
               free(((SyntaxTree *) $6)->ozTex);
               free($7);
            }

cond_pred: tok_if pred_list TOK_THEN pred_list tok_endif
           {
              $$ = createCondPredNode($2, $4, NULL);

              INT8  *condList = list2oz($2, "", "", "");
              INT8  *thenList = list2oz($4, "", "", "");

              ((SyntaxTree *) $$)->ozTex =
                    foztex("%s\\IF %s%s\\THEN %s%s\\ENDIF", $1, condList, $3, thenList, $5);

              free($1);
              free(condList);
              free($3);
              free(thenList);
              free($5);
           }
         | tok_if pred_list TOK_THEN pred_list TOK_ELIF elif_pred
           {
              $$ = createCondPredNode($2, $4, createLinkList($6));

              INT8  *condList = list2oz($2, "", "", "");
              INT8  *thenList = list2oz($4, "", "", "");

              ((SyntaxTree *) $$)->ozTex =
                    foztex("%s\\IF %s%s\\THEN %s%s\\ELIF %s", $1, condList, $3, thenList,
                                                              $5, ((SyntaxTree *) $6)->ozTex);

              free($1);
              free(condList);
              free($3);
              free(thenList);
              free($5);
              free(((SyntaxTree *) $6)->ozTex);
           }
         | tok_if pred_list TOK_THEN pred_list TOK_ELSE pred_list tok_endif
           {
              $$ = createCondPredNode($2, $4, $6);

              INT8  *condList = list2oz($2, "", "", "");
              INT8  *thenList = list2oz($4, "", "", "");
              INT8  *elseList = list2oz($6, "", "", "");

              ((SyntaxTree *) $$)->ozTex =
                    foztex("%s\\IF %s%s\\THEN %s%s\\ELSE %s%s\\ENDIF", $1, condList, $3, thenList,
                                                                       $5, elseList, $7);

              free($1);
              free(condList);
              free($3);
              free(thenList);
              free($5);
              free(elseList);
              free($7);
           }
         | tok_if pred_type TOK_THEN pred_list tok_endif
           {
              $$ = createCondPredNode(createLinkList($2), $4, NULL);

              INT8  *thenList = list2oz($4, "", "", "");

              ((SyntaxTree *) $$)->ozTex =
                    foztex("%s\\IF %s%s\\THEN %s%s\\ENDIF", $1, ((SyntaxTree *) $2)->ozTex,
                                                            $3, thenList, $5);

              free($1);
              free(((SyntaxTree *) $2)->ozTex);
              free($3);
              free(thenList);
              free($5);
           }
         | tok_if pred_type TOK_THEN pred_list TOK_ELIF elif_pred
           {
              $$ = createCondPredNode(createLinkList($2), $4, createLinkList($6));

              INT8  *thenList = list2oz($4, "", "", "");

              ((SyntaxTree *) $$)->ozTex =
                    foztex("%s\\IF %s%s\\THEN %s%s\\ELIF%s", $1, ((SyntaxTree *) $2)->ozTex,
                                                             $3, thenList, $5,
                                                             ((SyntaxTree *) $6)->ozTex);

              free($1);
              free(((SyntaxTree *) $2)->ozTex);
              free($3);
              free(thenList);
              free($5);
              free(((SyntaxTree *) $6)->ozTex);
           }
         | tok_if pred_type TOK_THEN pred_list TOK_ELSE pred_list tok_endif
           {
              $$ = createCondPredNode(createLinkList($2), $4, $6);

              INT8  *thenList = list2oz($4, "", "", "");
              INT8  *elseList = list2oz($6, "", "", "");

              ((SyntaxTree *) $$)->ozTex =
                    foztex("%s\\IF %s%s\\THEN %s%s\\ELSE %s%s\\ENDIF", $1, ((SyntaxTree *) $2)->ozTex,
                                                                       $3, thenList, $5, elseList, $7);

              free($1);
              free(((SyntaxTree *) $2)->ozTex);
              free($3);
              free(thenList);
              free($5);
              free(elseList);
              free($7);
           }
         ;

elif_pred: pred_list TOK_THEN pred_list tok_endif
           {
              $$ = createCondPredNode($1, $3, NULL);

              INT8  *condList = list2oz($1, "", "", "");
              INT8  *thenList = list2oz($3, "", "", "");

              ((SyntaxTree *) $$)->ozTex = foztex("%s%s\\THEN %s%s\\ENDIF", condList, $2, thenList, $4);

              free(condList);
              free($2);
              free(thenList);
              free($4);
           }
         | pred_list TOK_THEN pred_list TOK_ELIF elif_pred
           {
              $$ = createCondPredNode($1, $3, createLinkList($5));

              INT8  *condList = list2oz($1, "", "", "");
              INT8  *thenList = list2oz($3, "", "", "");

              ((SyntaxTree *) $$)->ozTex = foztex("%s%s\\THEN %s%s\\ELIF %s", condList, $2, thenList,
                                                                              $4, ((SyntaxTree *) $5)->ozTex);

              free(condList);
              free($2);
              free(thenList);
              free($4);
              free(((SyntaxTree *) $5)->ozTex);
           }
         | pred_list TOK_THEN pred_list TOK_ELSE pred_list tok_endif
           {
              $$ = createCondPredNode($1, $3, $5);

              INT8  *condList = list2oz($1, "", "", "");
              INT8  *thenList = list2oz($3, "", "", "");
              INT8  *elseList = list2oz($5, "", "", "");

              ((SyntaxTree *) $$)->ozTex = foztex("%s%s\\THEN %s%s\\ELSE %s%s\\ENDIF", condList, $2, thenList,
                                                                                       $4, elseList, $6);

              free(condList);
              free($2);
              free(thenList);
              free($4);
              free(elseList);
              free($6);
           }
         | pred_type TOK_THEN pred_list tok_endif
           {
              $$ = createCondPredNode(createLinkList($1), $3, NULL);

              INT8  *thenList = list2oz($3, "", "", "");

              ((SyntaxTree *) $$)->ozTex = foztex("%s%s\\THEN %s%s\\ENDIF", ((SyntaxTree *) $1)->ozTex,
                                                                            $2, thenList, $4);

              free(((SyntaxTree *) $1)->ozTex);
              free($2);
              free(thenList);
              free($4);
           }
         | pred_type TOK_THEN pred_list TOK_ELIF elif_pred
           {
              $$ = createCondPredNode(createLinkList($1), $3, createLinkList($5));

              INT8  *thenList = list2oz($3, "", "", "");

              ((SyntaxTree *) $$)->ozTex = foztex("%s%s\\THEN %s%s\\ELIF%s", ((SyntaxTree *) $1)->ozTex,
                                                                             $2, thenList, $4,
                                                                             ((SyntaxTree *) $5)->ozTex);

              free(((SyntaxTree *) $1)->ozTex);
              free($2);
              free(thenList);
              free($4);
              free(((SyntaxTree *) $5)->ozTex);
           }
         | pred_type TOK_THEN pred_list TOK_ELSE pred_list tok_endif
           {
              $$ = createCondPredNode(createLinkList($1), $3, $5);

              INT8  *thenList = list2oz($3, "", "", "");
              INT8  *elseList = list2oz($5, "", "", "");

              ((SyntaxTree *) $$)->ozTex =
                    foztex("%s%s\\THEN %s%s\\ELSE %s%s\\ENDIF", ((SyntaxTree *) $1)->ozTex,
                                                                $2, thenList, $4, elseList, $6);

              free(((SyntaxTree *) $1)->ozTex);
              free($2);
              free(thenList);
              free($4);
              free(elseList);
              free($6);
           }
         ;

paragraphs: /* Empty OK */
            {
               $$ = NULL;
            }
          | paragraphs paragraph
            {
               if($1 == NULL)
               {
                  $$ = createLinkList($2);
               }
               else
               {
                  appendLinkList($1, $2);

                  $$ = $1;
               }

               if($2 != NULL)
               {
                  writeA2OzTex((ParagraphNode *) $2);
               }
            }
          ;

paragraph: doc_info
           {
              $$ = $1;
           }
         |
           schema
           {
              $$ = $1;
           }
         | basic
           {
              $$ = $1;
           }
         | type
           {
              $$ = $1;
           }
         | free
           {
              $$ = $1;
           }
         | axdef
           {
              $$ = $1;
           }
         | const
           {
              $$ = $1;
           }
         | gendef
           {
              $$ = $1;
           }
         | gensch
           {
              $$ = $1;
           }
         | process
           {
              $$ = $1;
           }
         | desc
           {
              $$ = $1;
           }
         | direc
           {
              $$ = $1;
           }
         | error TOK_BLOCK_END
           {
              $$ = NULL;
           }
         ;

schema_hdr: TOK_SCH_START sch_name prop decl_list1 TOK_WHERE
            {
               clearCurSch();

               $$ = createSchemaNode($3, $4, NULL, $2->token);

               INT8  *declList = list2oz($4, "", "", "");

               ((SyntaxTree *) $$)->ozTex =
                     foztex("\\begin{schema}{%s}\v%s%s\\where\v", getOzXfm($2->token), declList, $5);

               free(declList);

               Symbol  *schSym = symLookup($2->token, &yyuerror);

               if(schSym != NULL)
               {
                  schSym->synTree = $$;
               }
               else
               {
                  yyuerror("Schema %s symbol was not inserted into symbol table", $2->token);

                  exit(-1);
               }

               $2->token = NULL;

               freeAToken($2);
               free($5);
            }
          | TOK_SCH_START sch_name decl_list1 TOK_WHERE
            {
               clearCurSch();

               $$ = createSchemaNode(NULL, $3, NULL, $2->token);

               INT8  *declList = list2oz($3, "", "", "");

               ((SyntaxTree *) $$)->ozTex =
                     foztex("\\begin{schema}{%s}\v%s%s\\where\v", getOzXfm($2->token), declList, $4);

               free(declList);

               Symbol  *schSym = symLookup($2->token, &yyuerror);

               if(schSym != NULL)
               {
                  schSym->synTree = $$;
               }
               else
               {
                  yyuerror("Schema %s symbol was not inserted into symbol table", $2->token);

                  exit(-1);
               }

               $2->token = NULL;

               freeAToken($2);
               free($4);
            }
          ;

schema: schema_hdr pred TOK_BLOCK_END
        {
           if(!popSymStack())
           {
              yyuerror("Unable to pop stack for schema");

              exit(-1);
           }

           Symbol  *schSym = symLookup(((SchemaNode *) $1)->name, &yyuerror);

           if(schSym != NULL)
           {
              ((SchemaNode *) $1)->preds = $2;

              $$ = $1;

              INT8  *tmpTex   = ((SyntaxTree *) $$)->ozTex;
              INT8  *predList = list2oz($2, "", "", "");

              ((SyntaxTree *) $$)->ozTex = foztex("%s%s%s\\end{schema}\v\n", tmpTex, predList, $3);

              free(predList);
              free(tmpTex);
              free($3);
           }
           else
           {
              yyuerror("Schema %s symbol was not inserted into symbol table", $2);

              exit(-1);
           }
        }
      ;

sch_name: TOK_IDENT
          {
             if(!addSymToGlobal($1->token, TOK_SCH_NAME, NULL))
             {
                yyuerror("Unable to add schema name to global table");

                exit(-1);
             }

             if(curSch != NULL)
             {
                free(curSch);

                curSch = NULL;
             }

             curSch = strdup($1->token);

             $$ = $1;
          }
        ;

basic: TOK_BASIC_START par_id prop basic_list TOK_BLOCK_END
       {
          $$ = createBasicDefNode($3, $4, $2->token);

          INT8  *basicList = list2oz($4, "", "", "");

          ((SyntaxTree *) $$)->ozTex = foztex("\\begin{zed}\v%s%s\\end{zed}\v\n", basicList, $5);

          $2->token = NULL;

          free(basicList);
          freeAToken($2);
          free($5);
       }
     | TOK_BASIC_START par_id basic_list TOK_BLOCK_END
       {
          $$ = createBasicDefNode(NULL, $3, $2->token);

          INT8  *basicList = list2oz($3, "", "", "");

          ((SyntaxTree *) $$)->ozTex = foztex("\\begin{zed}\v%s%s\\end{zed}\v\n", basicList, $4);

          $2->token = NULL;

          free(basicList);
          freeAToken($2);
          free($4);
       }
     ;

basic_list: basic_entry
            {
               $$ = createLinkList($1);
            }
          | basic_list basic_entry
            {
               appendLinkList($1, $2);

               $$ = $1;
            }
          ;

basic_entry: TOK_IDENT TOK_SEMICOLON
             {
                $$ = createBasicEntryNode(NULL, $1->token);

                ((SyntaxTree *) $$)->treeType = createSetTreeType(createBasicTreeType($1->token));
                ((SyntaxTree *) $$)->ozTex    = foztex("%s[%s]%s;", $1->preFmt, getOzXfm($1->token), $2);

                if(!addSymToTable($1->token, TOK_DATA_TYPE, $$))
                {
                   yyuerror("Unable to add basic type to symbol table");

                   exit(-1);
                }

                $1->token = NULL;

                freeAToken($1);
                free($2);
             }
           | TOK_IDENT TOK_SEMICOLON TOK_POUND TOK_OSQUARE post_props TOK_CSQUARE
             {
                $$ = createBasicEntryNode($5, $1->token);

                ((SyntaxTree *) $$)->treeType = createSetTreeType(createBasicTreeType($1->token));
                ((SyntaxTree *) $$)->ozTex    = foztex("%s[%s]%s;%s", $1->preFmt, getOzXfm($1->token),
                                                                          $2, $3);

                if(!addSymToTable($1->token, TOK_DATA_TYPE, $$))
                {
                   yyuerror("Unable to add basic type to symbol table");

                   exit(-1);
                }

                $1->token = NULL;

                freeAToken($1);
                free($2);
                free($3);
                free($4);
                free($6);
             }
           ;

/* Declarations go into global type symbol table */
type: TOK_TYPE_START par_id prop type_list TOK_BLOCK_END
      {
         if(!popSymStack())
         {
            yyuerror("Unable to pop stack for typedef");

            exit(-1);
         }

         $$ = createTypeDefNode($3, $4, $2->token);

         INT8  *typeList = list2oz($4, "", "", "");

         ((SyntaxTree *) $$)->ozTex = foztex("\\begin{zed}\v%s%s\\end{zed}\v\n", typeList, $5);

         $2->token = NULL;

         free(typeList);
         freeAToken($2);
         free($5);
      }
    | TOK_TYPE_START par_id type_list TOK_BLOCK_END
      {
         if(!popSymStack())
         {
            yyuerror("Unable to pop stack for typedef");

            exit(-1);
         }

         $$ = createTypeDefNode(NULL, $3, $2->token);

         INT8  *typeList = list2oz($3, "", "", "");

         ((SyntaxTree *) $$)->ozTex = foztex("\\begin{zed}\v%s%s\\end{zed}\v\n", typeList, $4);

         $2->token = NULL;

         free(typeList);
         freeAToken($2);
         free($4);
      }
    ;

type_list: type_entry
           {
              $$ = createLinkList($1);
           }
         | type_list type_entry
           {
              appendLinkList($1, $2);

              $$ = $1;
           }
         ;

type_entry: type_decl TOK_SEMICOLON
            {
               $$ = $1;

               INT8  *tmpTex = ((SyntaxTree *) $1)->ozTex;

               ((SyntaxTree *) $1)->ozTex = foztex("%s%s;", tmpTex, $2);

               free(tmpTex);
               free($2);
            }
          | type_decl TOK_SEMICOLON TOK_POUND TOK_OSQUARE post_props TOK_CSQUARE
            {
               ((TypeEntryNode *) $1)->props = $5;

               $$ = $1;

               INT8  *tmpTex = ((SyntaxTree *) $1)->ozTex;

               ((SyntaxTree *) $1)->ozTex = foztex("%s%s;%s", tmpTex, $2, $3);

               free(tmpTex);
               free($2);
               free($3);
               free($4);
               free($6);
            }
          ;

type_decl: TOK_IDENT TOK_EQUALS expr
           {
              $$ = createTypeEntryNode($1->token, $3);

              if(!isSetExpr($3))
              {
                 yyuerror("Defining expression is not a set type");
              }

              printType($1->token, ((SyntaxTree *) $3)->treeType);

              ((SyntaxTree *) $$)->treeType = ((SyntaxTree *) $3)->treeType;
              ((SyntaxTree *) $$)->ozTex    = foztex("%s%s%s==%s", $1->preFmt, getOzXfm($1->token), $2,
                                                                   ((SyntaxTree *) $3)->ozTex);

              printType("bound", ((SyntaxTree *) $$)->treeType);

              if(!addSymToTable($1->token, TOK_DATA_TYPE, $$))
              {
                 yyuerror("Unable to add data type to symbol table");

                 exit(-1);
              }

              $1->token = NULL;

              freeAToken($1);
              free($2);
              free(((SyntaxTree *) $3)->ozTex);
           }
         | TOK_IDENT gen_term TOK_EQUALS expr
           {
              $$ = createGenTypeEntryNode($1->token, $4, NULL, $2->token);

              if(!isSetExpr($4))
              {
                 yyuerror("Defining expression is not a set type");
              }

              printType($1->token, ((SyntaxTree *) $4)->treeType);

              ((SyntaxTree *) $$)->treeType = ((SyntaxTree *) $4)->treeType;
              ((SyntaxTree *) $$)->ozTex    = foztex("%s%s%s%s%s==%s", $1->preFmt, getOzXfm($1->token),
                                                                       $2->preFmt, getOzXfm($2->token), $3,
                                                                       ((SyntaxTree *) $4)->ozTex);

              printType("bound", ((SyntaxTree *) $$)->treeType);

              if(!addSymToTable($1->token, TOK_GEN_TYPE, $$))
              {
                 yyuerror("Unable to add genpre name to symbol table");

                 exit(-1);
              }

              $1->token = NULL;
              $2->token = NULL;

              freeAToken($1);
              freeAToken($2);
              free($3);
              free(((SyntaxTree *) $4)->ozTex);
           }
         | gen_term TOK_IDENT gen_term TOK_EQUALS expr
           {
              $$ = createGenTypeEntryNode($2->token, $5, $1->token, $3->token);

              if(!isSetExpr($5))
              {
                 yyuerror("Defining expression is not a set type");
              }

              printType($2->token, ((SyntaxTree *) $5)->treeType);

              ((SyntaxTree *) $$)->treeType = ((SyntaxTree *) $5)->treeType;
              ((SyntaxTree *) $$)->ozTex    = foztex("%s%s%s%s%s%s%s==%s", $1->preFmt, getOzXfm($1->token),
                                                                           $2->preFmt, getOzXfm($2->token),
                                                                           $3->preFmt, getOzXfm($3->token),
                                                                           $4, ((SyntaxTree *) $5)->ozTex);

              printType("bound", ((SyntaxTree *) $$)->treeType);

              if(!addSymToTable($2->token, TOK_GEN_TYPE, $$))
              {
                 yyuerror("Unable to add genin name to symbol table");

                 exit(-1);
              }

              $1->token = NULL;
              $2->token = NULL;
              $3->token = NULL;

              freeAToken($1);
              freeAToken($2);
              freeAToken($3);
              free($4);
              free(((SyntaxTree *) $5)->ozTex);
           }
         ;

gen_term: TOK_OSQUARE TOK_IDENT TOK_CSQUARE
          {
             $$ = $2;

             if(!addSymToLocal($2->token, TOK_GEN_SYM, NULL))
             {
                yyuerror("Unable to add genterm name to symbol table");

                exit(-1);
             }

             free($2->preFmt);
             free($3);

             $2->preFmt = $1;
          }
        | TOK_OSQUARE TOK_GEN_SYM TOK_CSQUARE
          {
             $$ = $2;

             free($2->preFmt);
             free($3);

             $2->preFmt = $1;
          }
        ;

free: TOK_FREE_START par_id prop free_list TOK_BLOCK_END
      {
         $$ = createFreeTypeNode($3, $4, $2->token);

         INT8  *freeList = list2oz($4, "", "", "");

         ((SyntaxTree *) $$)->ozTex = foztex("\\begin{zed}\v%s%s\\end{zed}\v\n", freeList, $5);

         $2->token = NULL;

         free(freeList);
         freeAToken($2);
         free($5);
      }
    | TOK_FREE_START par_id free_list TOK_BLOCK_END
      {
         $$ = createFreeTypeNode(NULL, $3, $2->token);

         INT8  *freeList = list2oz($3, "", "", "");

         ((SyntaxTree *) $$)->ozTex = foztex("\\begin{zed}\v%s%s\\end{zed}\v\n", freeList, $4);

         $2->token = NULL;

         free(freeList);
         freeAToken($2);
         free($4);
      }
    ;

free_list: free_entry
           {
              $$ = createLinkList($1);
           }
         | free_list free_entry
           {
              appendLinkList($1, $2);

              $$ = $1;
           }
         ;

free_entry: free_decl TOK_SEMICOLON
            {
               $$ = $1;

               INT8  *tmpTex = ((SyntaxTree *) $1)->ozTex;

               ((SyntaxTree *) $1)->ozTex = foztex("%s%s;", tmpTex, $2);

               free(tmpTex);
               free($2);
            }
          | free_decl TOK_SEMICOLON TOK_POUND TOK_OSQUARE post_props TOK_CSQUARE
            {
               ((FreeEntryNode *) $1)->props = $5;

               $$ = $1;

               INT8  *tmpTex = ((SyntaxTree *) $1)->ozTex;

               ((SyntaxTree *) $1)->ozTex = foztex("%s%s;%s", tmpTex, $2, $3);

               free(tmpTex);
               free($2);
               free($3);
               free($4);
               free($6);
            }
          ;

free_decl: TOK_IDENT TOK_EQUALS free_vars
           {
              $$ = createFreeEntryNode(NULL, $1->token, $3);

              INT8  *freeList = list2oz($3, "|", "", "");

              ((SyntaxTree *) $$)->treeType = createSetTreeType(createBasicTreeType($1->token));
              ((SyntaxTree *) $$)->ozTex    = foztex("%s%s%s=%s", $1->preFmt, getOzXfm($1->token), $2, freeList);

              if(!addSymToTable($1->token, TOK_DATA_TYPE, $$))
              {
                 yyuerror("Unable to add free type to symbol table");

                 exit(-1);
              }

              LinkList  *ite = (LinkList *) $3;

              while(ite != NULL)
              {
                 ((SyntaxTree *) ite->object)->treeType = getTypeBoundType(((SyntaxTree *) $$)->treeType);

                 ite = ite->next;
              }

              $1->token = NULL;

              freeAToken($1);
              free($2);
              free(freeList);
           }
         ;

free_vars: free_var
           {
              $$ = createLinkList($1);
           }
         | free_vars TOK_SOR free_var
           {
              appendLinkList($1, $3);

              free($2);

              $$ = $1;
           }
         ;

free_var: TOK_IDENT TOK_POUND TOK_OSQUARE post_props TOK_CSQUARE
          {
             $$ = createVariableNode($1->token, NULL);

             ((SyntaxTree *) $$)->ozTex = foztex("%s%s%s", $1->preFmt, getOzXfm($1->token), $2);

             ((VariableNode *) $$)->props = $4;

             if(!addSymToTable($1->token, TOK_VAR_BINDING, $$))
             {
                yyuerror("Unable to add free var to symbol table");

                exit(-1);
             }

             $1->token = NULL;

             freeAToken($1);
             free($2);
             free($3);
             free($5);
          }
        | TOK_IDENT
          {
             $$ = createVariableNode($1->token, NULL);

             ((SyntaxTree *) $$)->ozTex = atok2oz($1);

             if(!addSymToTable($1->token, TOK_VAR_BINDING, $$))
             {
                yyuerror("Unable to add free var to symbol table");

                exit(-1);
             }

             $1->token = NULL;

             freeAToken($1);
          }
        ;

/* Declarations go into global identifier symbol table */
axdef: TOK_AXDEF_START par_id prop decl_list1 TOK_WHERE pred TOK_BLOCK_END
       {
          if(!popSymStack())
          {
             yyuerror("Unable to pop stack for axdef");

             exit(-1);
          }

          $$ = createAxDefNode($3, $4, $6, $2->token);

          INT8  *declList = list2oz($4, "", "", "");
          INT8  *predList = list2oz($6, "", "", "");

          ((SyntaxTree *) $$)->ozTex =
                foztex("\\begin{axdef}\v%s%s\\where\v%s%s\\end{axdef}\v\n", declList, $5, predList, $7);

          $2->token = NULL;

          freeAToken($2);
          free(declList);
          free($5);
          free(predList);
          free($7);
       }
     | TOK_AXDEF_START par_id decl_list1 TOK_WHERE pred TOK_BLOCK_END
       {
          if(!popSymStack())
          {
             yyuerror("Unable to pop stack for axdef");

             exit(-1);
          }

          $$ = createAxDefNode(NULL, $3, $5, $2->token);

          INT8  *declList = list2oz($3, "", "", "");
          INT8  *predList = list2oz($5, "", "", "");

          ((SyntaxTree *) $$)->ozTex =
                foztex("\\begin{axdef}\v%s%s\\where\v%s%s\\end{axdef}\v\n", declList, $4, predList, $6);

          $2->token = NULL;

          freeAToken($2);
          free(declList);
          free($4);
          free(predList);
          free($6);
       }
     ;

const: TOK_CONST_START par_id prop pred TOK_BLOCK_END
       {
          $$ = createConstraintNode($3, $4, $2->token);

          INT8  *predList = list2oz($4, "", "", "");

          ((SyntaxTree *) $$)->ozTex = foztex("\\begin{zed}\v%s%s\\end{zed}\v\n", predList, $5);

          $2->token = NULL;

          freeAToken($2);
          free(predList);
          free($5);
       }
     | TOK_CONST_START par_id pred TOK_BLOCK_END
       {
          $$ = createConstraintNode(NULL, $3, $2->token);

          INT8  *predList = list2oz($3, "", "", "");

          ((SyntaxTree *) $$)->ozTex = foztex("\\begin{zed}\v%s%s\\end{zed}\v\n", predList, $4);

          $2->token = NULL;

          freeAToken($2);
          free(predList);
          free($4);
       }
     ;

gen_field: TOK_OSQUARE gen_list TOK_CSQUARE
           {
              $$ = $2;

              free($1);
              free($3);
           }
         ;

gen_list: TOK_IDENT
          {
             $$ = createLinkList($1->token);

             addSymToLocal($1->token, TOK_GEN_SYM, NULL);

             $1->token = NULL;

             freeAToken($1);
          }
        | TOK_GEN_SYM
           {
             $$ = createLinkList($1->token);

             $1->token = NULL;

             freeAToken($1);
           }
        | gen_list TOK_COMMA TOK_IDENT
          {
             $$ = $1;

             addSymToLocal($3->token, TOK_GEN_SYM, NULL);
             appendLinkList($1, $3->token);

             $3->token = NULL;

             freeAToken($3);
             free($2);
          }
        | gen_list TOK_COMMA TOK_GEN_SYM
          {
             $$ = $1;

             appendLinkList($1, $3->token);

             $3->token = NULL;

             freeAToken($3);
             free($2);
          }
        ;

/* Declarations go into global identifier symbol table */
gendef: TOK_GENDEF_START gen_field par_id prop decl_list1 TOK_WHERE pred TOK_BLOCK_END
        {
           if(!popSymStack())
           {
              yyuerror("Unable to pop stack for gendef");

              exit(-1);
           }

           $$ = createGenDefNode($4, $2, $5, $7, $3->token);

           INT8  *declList = list2oz($5, "", "", "");
           INT8  *predList = list2oz($7, "", "", "");
           INT8  *genList  = genList2oz($2);

           ((SyntaxTree *) $$)->ozTex =
                 foztex("\\begin{gendef}{%s}\v%s%s\\where\v%s%s\\end{gendef}\v\n", genList, declList,
                                                                                   $6, predList, $8);

           $3->token = NULL;

           freeAToken($3);
           free(genList);
           free(declList);
           free($6);
           free(predList);
           free($8);
        }
      | TOK_GENDEF_START gen_field par_id decl_list1 TOK_WHERE pred TOK_BLOCK_END
        {
           if(!popSymStack())
           {
              yyuerror("Unable to pop stack for gendef");

              exit(-1);
           }

           $$ = createGenDefNode(NULL, $2, $4, $6, $3->token);

           INT8  *declList = list2oz($4, "", "", "");
           INT8  *predList = list2oz($6, "", "", "");
           INT8  *genList  = genList2oz($2);

           ((SyntaxTree *) $$)->ozTex =
                 foztex("\\begin{gendef}{%s}\v%s%s\\where\v%s%s\\end{gendef}\v\n", genList, declList,
                                                                                   $5, predList, $7);

           $3->token = NULL;

           freeAToken($3);
           free(genList);
           free(declList);
           free($5);
           free(predList);
           free($7);
        }
      ;

/* Declarations go into schema's local identifier symbol table */
gensch_hdr: TOK_GENSCH_START gen_field sch_name prop decl_list1 TOK_WHERE
            {
               clearCurSch();

               $$ = createGenSchemaNode($4, $2, $5, NULL, $3->token);

               INT8  *declList = list2oz($5, "", "", "");
               INT8  *genList  = genList2oz($2);

               ((SyntaxTree *) $$)->ozTex =
                     foztex("\\begin{genschema}{%s}{%s}\v%s\n\\where\v", getOzXfm($3->token), genList,
                                                                             declList, $6);

               free(declList);
               free(genList);
               free($6);

               Symbol  *schSym = symLookup(((GenSchemaNode *) $$)->name, &yyuerror);

               if(schSym != NULL)
               {
                  schSym->symType = TOK_GEN_SCHEMA;
                  schSym->synTree = $$;
               }
               else
               {
                  yyuerror("Generic schema %s symbol was not found in symbol table", $2);

                  exit(-1);
               }

               $3->token = NULL;

               freeAToken($3);
            }
          | TOK_GENSCH_START gen_field sch_name decl_list1 TOK_WHERE
            {
               clearCurSch();

               $$ = createGenSchemaNode(NULL, $2, $4, NULL, $3->token);

               INT8  *declList = list2oz($4, "", "", "");
               INT8  *genList  = genList2oz($2);

               ((SyntaxTree *) $$)->ozTex =
                     foztex("\\begin{genschema}{%s}{%s}\v%s\n\\where\v", getOzXfm($3->token), genList,
                                                                             declList, $5);

               free(declList);
               free(genList);
               free($5);

               Symbol  *schSym = symLookup(((GenSchemaNode *) $$)->name, &yyuerror);

               if(schSym != NULL)
               {
                  schSym->symType = TOK_GEN_SCHEMA;
                  schSym->synTree = $$;
               }
               else
               {
                  yyuerror("Generic schema %s symbol was not found in symbol table", $2);

                  exit(-1);
               }

               $3->token = NULL;

               freeAToken($3);
            }
          ;

gensch: gensch_hdr pred TOK_BLOCK_END
        {
           if(!popSymStack())
           {
              yyuerror("Unable to pop stack for gensch");

              exit(-1);
           }

           Symbol  *schSym = symLookup(((GenSchemaNode *) $1)->name, &yyuerror);

           if(schSym != NULL)
           {
              ((GenSchemaNode *) $1)->preds = $2;

              $$ = $1;

              INT8  *tmpTex   = ((SyntaxTree *) $$)->ozTex;
              INT8  *predList = list2oz($2, "", "", "");

              ((SyntaxTree *) $$)->ozTex = foztex("%s%s%s\\end{genschema}\v\n", tmpTex, predList, $3);

              free(predList);
              free(tmpTex);
              free($3);
           }
           else
           {
              yyuerror("Schema %s symbol was not inserted into symbol table", $2);

              exit(-1);
           }
        }
      ;

process_hdr: TOK_PROC_START par_id proc_decls0 TOK_WHERE
             {
                if(!pushSymStack(0, &yyerror))
                {
                   yyuerror("Unable to push stack for process definition");

                   exit(-1);
                }

                $$ = createProcessNode(NULL, $3, NULL, $2->token);

                INT8  *declList = list2oz($3, "", "", "");

                ((SyntaxTree *) $$)->ozTex =
                      foztex("\\begin{process}{%s}\v%s%s\\where\v", $2->token, declList, $4);

                $2->token = NULL;

                freeAToken($2);
                free(declList);
                free($4);
             }
           | TOK_PROC_START par_id prop proc_decls0 TOK_WHERE
             {
                if(!pushSymStack(0, &yyerror))
                {
                   yyuerror("Unable to push stack for process definition");

                   exit(-1);
                }

                $$ = createProcessNode($3, $4, NULL, $2->token);

                INT8  *declList = list2oz($4, "", "", "");

                ((SyntaxTree *) $$)->ozTex =
                      foztex("\\begin{process}{%s}\v%s%s\\where\v", $2->token, declList, $5);

                $2->token = NULL;

                freeAToken($2);
                free(declList);
                free($5);
             }
           ;

process: process_hdr proc_list0 TOK_BLOCK_END
         {
            /* Pop process definition */
            if(!popSymStack())
            {
               yyuerror("Unable to pop stack for process definition");

               exit(-1);
            }

            /* Pop process paragraph */
            if(!popSymStack())
            {
               yyuerror("Unable to pop stack for process paragraph");

               exit(-1);
            }

            $$ = $1;

            INT8  *tmpTex   = ((ProcessNode *) $$)->ozTex;
            INT8  *procList = list2oz($2, "", "", "");

            ((ProcessNode *) $$)->procs = $2;
            ((SyntaxTree *) $$)->ozTex  = foztex("%s%s%s\\end{process}\v\n", tmpTex, procList, $3);

            free(tmpTex);
            free(procList);
            free($3);
         }
       ;

desc: TOK_DESC_START prop TOK_TEXT TOK_DESC_END
      {
         $$ = createDescriptionNode($2, $3->token);

         ((SyntaxTree *) $$)->ozTex = foztex("%s", $3->token);

         $3->token = NULL;

         freeAToken($3);
      }
    | TOK_DESC_START TOK_TEXT TOK_DESC_END
      {
         $$ = createDescriptionNode(NULL, $2->token);

         ((SyntaxTree *) $$)->ozTex = foztex("%s", $2->token);

         $2->token = NULL;

         freeAToken($2);
      }
    ;

direc: TOK_DIREC_START prop dir_list TOK_DIREC_END
       {
          $$ = createDirectiveNode($2, $3);
       }
     | TOK_DIREC_START dir_list TOK_DIREC_END
       {
          $$ = createDirectiveNode(NULL, $2);
       }
     ;

dir_list: dir_entry TOK_SEMICOLON
          {
             $$ = createLinkList($1);

             free($2);
          }
        | dir_list dir_entry TOK_SEMICOLON
          {
             appendLinkList($1, $2);

             $$ = $1;

             free($3);
          }
        ;

dir_entry: word_list
           {
              $$ = $1;
           }
         ;

proc_decls1: proc_decl
             {
                $$ = createLinkList($1);
             }
           | proc_decls1 proc_decl
             {
                appendLinkList($1, $2);

                $$ = $1;
             }
           ;

proc_decls0: /* Empty OK */
             {
                $$ = NULL;
             }
           | proc_decls1
             {
                $$ = $1;
             }
           ;


proc_decl: pdecl_type TOK_SEMICOLON
           {
              $$ = $1;

              INT8  *tmpTex = ((SyntaxTree *) $1)->ozTex;

              ((SyntaxTree *) $1)->ozTex = foztex("%s%s;", tmpTex, $2);

              free(tmpTex);
              free($2);
           }
         | pdecl_type TOK_SEMICOLON TOK_POUND TOK_OSQUARE post_props TOK_CSQUARE
           {
              ((DeclarationNode *) $1)->props = $5;

              $$ = $1;

              INT8  *tmpTex = ((SyntaxTree *) $1)->ozTex;

              ((SyntaxTree *) $1)->ozTex = foztex("%s%s;%s", tmpTex, $2, $3);

              free(tmpTex);
              free($2);
              free($3);
              free($4);
              free($6);
           }
         ;

pdecl_type: TOK_PROC_ID TOK_IDENT
             {
                $$ = createDeclarationNode(NULL, PROC_DECL, createVariableNode($2->token, NULL), NULL);

                ((SyntaxTree *) $$)->treeType = createBasicTreeType("PROCESS");
                ((SyntaxTree *) $$)->ozTex    = foztex("%s\\proc %s%s", $1, $2->preFmt, $2->token);

                ((SyntaxTree *) ((DeclarationNode *) $$)->ident)->treeType = createBasicTreeType("PROCESS");

                if(!addSymToTable($2->token, TOK_PROCESS, $$))
                {
                   yyuerror("Unable to add process to symbol table");

                   exit(-1);
                }

                $2->token = NULL;

                free($1);
                freeAToken($2);
             }
           | TOK_PROC_ID TOK_IDENT TOK_COLON expr
             {
                $$ = createDeclarationNode(NULL, PROC_FUNC_DECL, $2->token, $4);

                TreeType  *in        = getTypeBoundType(((SyntaxTree *) $4)->treeType);
                TreeType  *out       = (TreeType *) createBasicTreeType("PROCESS");
                LinkList  *tupleList = createLinkList(in);
                TreeType  *tuple     = (TreeType *) createTupleTreeType(NULL, 0);

                appendLinkList(tupleList, out);

                ((TupleType *) tuple)->typeList = tupleList;

                ((SyntaxTree *) $$)->treeType = createSetTreeType(tuple);
                ((SyntaxTree *) $$)->ozTex    =
                      foztex("%s\\proc %s%s%s\\colon %s", $1, $2->preFmt, getOzXfm($2->token), $3,
                                                          ((SyntaxTree *) $4)->ozTex);

                if(!addSymToTable($2->token, TOK_PROC_FUNC, $$))
                {
                   yyuerror("Unable to add process function name to symbol table");

                   exit(-1);
                }

                $2->token = NULL;

                free($1);
                freeAToken($2);
                free($3);
                free(((SyntaxTree *) $4)->ozTex);
             }
           | TOK_PROC_ID TOK_IDENT TOK_EQUALS expr
             {
                $$ = createProcAliasNode($2->token, $4);

                ((SyntaxTree *) $$)->treeType = ((SyntaxTree *) $4)->treeType;
                ((SyntaxTree *) $$)->ozTex    =
                      foztex("%s\\proc %s%s%s==%s", $1, $2->preFmt, getOzXfm($2->token),
                                                    $3, ((SyntaxTree *) $4)->ozTex);

                if(!isProcessExpr($4))
                {
                   yyuerror("Defining expression is not a process expression");
                }

                if(isFuncExpr($4))
                {
                   if(!addSymToTable($2->token, TOK_PROC_FUNC, $$))
                   {
                      yyuerror("Unable to add process function name to symbol table");

                      exit(-1);
                   }
                }
                else
                {
                   if(!addSymToTable($2->token, TOK_PROCESS, $$))
                   {
                      yyuerror("Unable to add process to symbol table");

                      exit(-1);
                   }
                }

                $2->token = NULL;

                free($1);
                freeAToken($2);
                free($3);
                free(((SyntaxTree *) $4)->ozTex);
             }
           | TOK_PROC_ID gen_field TOK_IDENT TOK_COLON expr
             {
                $$ = createDeclarationNode(NULL, PROC_FUNC_DECL, $3->token, $5);

                TreeType  *in        = getTypeBoundType(((SyntaxTree *) $5)->treeType);
                TreeType  *out       = (TreeType *) createBasicTreeType("PROCESS");
                LinkList  *tupleList = createLinkList(in);
                TreeType  *tuple     = (TreeType *) createTupleTreeType(NULL, 0);
                INT8      *genList   = genList2oz($2);

                appendLinkList(tupleList, out);

                ((TupleType *) tuple)->typeList = tupleList;

                ((DeclarationNode *) $$)->genSyms = $2;
                ((SyntaxTree *) $$)->treeType     = createSetTreeType(tuple);
                ((SyntaxTree *) $$)->ozTex        =
                      foztex("%s\\proc\\!\\![%s]\\ %s%s%s\\colon %s", $1, genList, $3->preFmt,
                                                                      getOzXfm($3->token),
                                                                      $4, ((SyntaxTree *) $5)->ozTex);

                if(!addSymToTable($3->token, TOK_GEN_PROC_FUNC, $$))
                {
                   yyuerror("Unable to add process function name to symbol table");

                   exit(-1);
                }

                $3->token = NULL;

                free($1);
                free(genList);
                freeAToken($3);
                free($4);
                free(((SyntaxTree *) $5)->ozTex);
             }
           | TOK_CHAN_ID TOK_IDENT TOK_COLON expr
             {
                $$ = createDeclarationNode(NULL, CHAN_DECL, $2->token, $4);

                TreeType  *in        = getTypeBoundType(((SyntaxTree *) $4)->treeType);
                TreeType  *out       = (TreeType *) createBasicTreeType("CSP_EVENT");
                LinkList  *tupleList = createLinkList(in);
                TreeType  *tuple     = (TreeType *) createTupleTreeType(NULL, 0);

                appendLinkList(tupleList, out);

                ((TupleType *) tuple)->typeList = tupleList;

                ((SyntaxTree *) $$)->treeType = createSetTreeType(tuple);
                ((SyntaxTree *) $$)->ozTex    =
                      foztex("%s\\chan %s%s%s\\colon %s", $1, $2->preFmt, getOzXfm($2->token), $3,
                                                          ((SyntaxTree *) $4)->ozTex);

                if(!addSymToTable($2->token, TOK_CHANNEL, $$))
                {
                   yyuerror("Unable to add channel name to symbol table");

                   exit(-1);
                }

                $2->token = NULL;

                free($1);
                freeAToken($2);
                free($3);
                free(((SyntaxTree *) $4)->ozTex);
             }
           | TOK_CHAN_ID TOK_IDENT TOK_EQUALS expr
             {
                $$ = createChanAliasNode($2->token, $4);

                ((SyntaxTree *) $$)->treeType = ((SyntaxTree *) $4)->treeType;
                ((SyntaxTree *) $$)->ozTex    =
                      foztex("%s\\chan %s%s%s==%s", $1, $2->preFmt, getOzXfm($2->token),
                                                    $3, ((SyntaxTree *) $4)->ozTex);

                if(!isChannelExpr($4))
                {
                   yyuerror("Defining expression is not a channel expression");
                }

                if(isFuncExpr($4))
                {
                   if(!addSymToTable($2->token, TOK_CHANNEL, $$))
                   {
                      yyuerror("Unable to add channel name to symbol table");

                      exit(-1);
                   }
                }
                else
                {
                   if(!addSymToTable($2->token, TOK_EVENT, $$))
                   {
                      yyuerror("Unable to add event to symbol table");

                      exit(-1);
                   }
                }

                $2->token = NULL;

                free($1);
                freeAToken($2);
                free($3);
                free(((SyntaxTree *) $4)->ozTex);
             }
           | TOK_CHAN_ID gen_field TOK_IDENT TOK_COLON expr
             {
                $$ = createDeclarationNode(NULL, CHAN_DECL, $3->token, $5);

                TreeType  *in        = getTypeBoundType(((SyntaxTree *) $5)->treeType);
                TreeType  *out       = (TreeType *) createBasicTreeType("CSP_EVENT");
                LinkList  *tupleList = createLinkList(in);
                TreeType  *tuple     = (TreeType *) createTupleTreeType(NULL, 0);
                INT8      *genList   = genList2oz($2);

                appendLinkList(tupleList, out);

                ((TupleType *) tuple)->typeList = tupleList;

                ((DeclarationNode *) $$)->genSyms = $2;
                ((SyntaxTree *) $$)->treeType     = createSetTreeType(tuple);
                ((SyntaxTree *) $$)->ozTex        =
                      foztex("%s\\chan\\!\\![%s]\\ %s%s%s\\colon %s", $1, genList, $3->preFmt,
                                                                      getOzXfm($3->token),
                                                                      $4, ((SyntaxTree *) $5)->ozTex);

                if(!addSymToTable($3->token, TOK_GEN_CHANNEL, $$))
                {
                   yyuerror("Unable to add channel name to symbol table");

                   exit(-1);
                }

                $3->token = NULL;

                free($1);
                free(genList);
                freeAToken($3);
                free($4);
                free(((SyntaxTree *) $5)->ozTex);
             }
           | TOK_CHAN_ID TOK_IDENT
             {
                $$ = createDeclarationNode(NULL, EVENT_DECL, createVariableNode($2->token, NULL), NULL);

                ((SyntaxTree *) $$)->treeType = createBasicTreeType("CSP_EVENT");
                ((SyntaxTree *) $$)->ozTex    = foztex("%s\\chan %s%s", $1, $2->preFmt, $2->token);

                ((SyntaxTree *) ((DeclarationNode *) $$)->ident)->treeType = createBasicTreeType("CSP_EVENT");

                if(!addSymToTable($2->token, TOK_EVENT, $$))
                {
                   yyuerror("Unable to add event to symbol table");

                   exit(-1);
                }

                $2->token = NULL;

                free($1);
                freeAToken($2);
             }
           ;

proc_list1: proc_entry
            {
                $$ = createLinkList($1);
            }
          | proc_list1 proc_entry
            {
                $$ = $1;

                appendLinkList($1, $2);
            }
          ;

proc_list0: /* Empty OK */
            {
               $$ = NULL;
            }
          | proc_list1
            {
               $$ = $1;
            }
          ;

pdecl_list1: pvar_decl
             {
                $$ = createLinkList($1);
             }
           | pdecl_list1 TOK_COMMA pvar_decl
             {
                $$ = $1;

                SyntaxTree  *tailExpr = (SyntaxTree *) getListTail($1)->object;

                appendLinkList($1, $3);

                INT8  *tmpTex = tailExpr->ozTex;

                tailExpr->ozTex = foztex("%s%s", tmpTex, $2);

                free(tmpTex);
                free($2);
             }
           ;

psdecl_list1: pvar_decl TOK_SEMICOLON
              {
                 $$ = createLinkList($1);

                 INT8  *tmpTex = ((SyntaxTree *) $1)->ozTex;

                 ((SyntaxTree *) $1)->ozTex = foztex("%s%s;", tmpTex, $2);

                 free(tmpTex);
                 free($2);
              }
            | pvar_decl TOK_SEMICOLON TOK_POUND TOK_OSQUARE post_props TOK_CSQUARE
              {
                 $$ = createLinkList($1);

                 INT8  *tmpTex = ((SyntaxTree *) $1)->ozTex;

                 ((DeclarationNode *) $1)->props = $5;
                 ((SyntaxTree *) $1)->ozTex      = foztex("%s%s;%s", tmpTex, $2, $3);

                 free(tmpTex);
                 free($2);
                 free($3);
                 free($4);
                 free($6);
              }
            | psdecl_list1 pvar_decl TOK_SEMICOLON
              {
                 $$ = $1;

                 appendLinkList($1, $2);

                 INT8  *tmpTex = ((SyntaxTree *) $2)->ozTex;

                 ((SyntaxTree *) $2)->ozTex = foztex("%s%s;", tmpTex, $3);

                 free(tmpTex);
                 free($3);
              }
            | psdecl_list1 pvar_decl TOK_SEMICOLON TOK_POUND TOK_OSQUARE post_props TOK_CSQUARE
              {
                 $$ = $1;

                 appendLinkList($1, $2);

                 INT8  *tmpTex = ((SyntaxTree *) $2)->ozTex;

                 ((DeclarationNode *) $1)->props = $6;
                 ((SyntaxTree *) $2)->ozTex      = foztex("%s%s;%s", tmpTex, $3, $4);

                 free(tmpTex);
                 free($3);
                 free($4);
                 free($5);
                 free($7);
              }
            ;

pvar_decl: var_ident TOK_COLON expr
           {
              $$ = createDeclarationNode(NULL, VAR_DECL, createVariableNode($1->token, NULL), $3);

              if(!isSetExpr($3))
              {
                 yyuerror("Defining expression is not a set type");
              }

              printType($1->token, ((SyntaxTree *) $3)->treeType);

              ((SyntaxTree *) $$)->treeType = getTypeBoundType(((SyntaxTree *) $3)->treeType);
              ((SyntaxTree *) $$)->ozTex    = foztex("%s%s%s\\colon %s", $1->preFmt, getOzXfm($1->token), $2,
                                                                         ((SyntaxTree *) $3)->ozTex);

              ((SyntaxTree *) ((DeclarationNode *) $$)->ident)->treeType =
                    getTypeBoundType(((SyntaxTree *) $3)->treeType);

              free($2);
              free(((SyntaxTree *) $3)->ozTex);

              printType("bound", ((SyntaxTree *) $$)->treeType);

              if(!addSymToTable($1->token, TOK_PROC_VAR, $$))
              {
                 yyuerror("Unable to add variable to symbol table");

                 exit(-1);
              }

              $1->token = NULL;

              freeAToken($1);
           }
         | var_ident var_post_decor TOK_COLON expr
           {
              if(($2->token)[0] != '\'')
              {
                 yyuerror("%s decoration is not valid for process variables", $2->token);
              }

              tmpStr = malloc(strlen($1->token) + strlen($2->token) + 1);

              memset(tmpStr, 0, strlen($1->token) + strlen($2->token) + 1);
              strncpy(tmpStr, $1->token, strlen($1->token));
              strncpy(&(tmpStr[strlen($1->token)]), $2->token, strlen($2->token));

              $$ = createDeclarationNode(NULL, VAR_DECL, createVariableNode($1->token, $2->token), $4);

              DecorType  postDecor = extractDecorType($2->token);
              UINT8      postCnt   = extractDecorCount($2->token);
              INT8      *ozPost    = NULL;

              if(postDecor == POST_PRI)
              {
                 if(postCnt > 1)
                 {
                    ozPost = foztex("\\zPri{%d}", postCnt);
                 }
                 else
                 {
                    ozPost = foztex("'");
                 }
              }
              else if(postDecor == POST_IN)
              {
                 ozPost = foztex("?");
              }
              else if(postDecor == POST_OUT)
              {
                 ozPost = foztex("!");
              }

              ((SyntaxTree *) $$)->ozTex = foztex("%s%s%s%s%s\\colon %s", $1->preFmt, getOzXfm($1->token),
                                                                          $2->preFmt, ozPost, $3,
                                                                          ((SyntaxTree *) $4)->ozTex);

              free(ozPost);
              freeAToken($2);
              free($3);
              free(((SyntaxTree *) $4)->ozTex);

              if(!isSetExpr($4))
              {
                 yyuerror("Defining expression is not a set type");
              }

              printType($1->token, ((SyntaxTree *) $4)->treeType);

              ((SyntaxTree *) $$)->treeType = getTypeBoundType(((SyntaxTree *) $4)->treeType);

              ((SyntaxTree *) ((DeclarationNode *) $$)->ident)->treeType = getTypeBoundType(((SyntaxTree *) $4)->treeType);

              printType("bound", ((SyntaxTree *) $$)->treeType);

              if(!addSymToTable(tmpStr, TOK_PROC_VAR, $$))
              {
                 yyuerror("Unable to add variable to symbol table");

                 exit(-1);
              }

              free(tmpStr);

              tmpStr    = NULL;
              $1->token = NULL;

              freeAToken($1);
           }
         ;

proc_entry: proc_def_hdr cspexp TOK_SEMICOLON
            {
               /* Pop most recent sub-process */
               if(!popSymStack())
               {
                  yyuerror("Unable to pop stack for sub-process definition");

                  exit(-1);
               }

               /* Pop process */
               if(!popSymStack())
               {
                  yyuerror("Unable to pop stack for process definition");

                  exit(-1);
               }

               /* Prep for next process */
               if(!pushSymStack(0, &yyerror))
               {
                  yyuerror("Unable to push stack for process definition");

                  exit(-1);
               }

               if(!isProcessExpr($2))
               {
                  yyuerror("Defining expression is not a process expression");
               }

               procDef = 0;

               $$ = $1;

               ((ProcDefNode *) $$)->defExpr = $2;

               INT8  *tmpTex = ((SyntaxTree *) $$)->ozTex;

               ((SyntaxTree *) $$)->ozTex = foztex("%s%s%s", tmpTex, ((SyntaxTree *) $2)->ozTex, $3);

               free(tmpTex);
               free(((SyntaxTree *) $2)->ozTex);
               free($3);
            }
          | proc_def_hdr cspexp TOK_SEMICOLON TOK_POUND TOK_OSQUARE post_props TOK_CSQUARE
            {
               /* Pop most recent sub-process */
               if(!popSymStack())
               {
                  yyuerror("Unable to pop stack for sub-process definition");

                  exit(-1);
               }

               /* Pop process */
               if(!popSymStack())
               {
                  yyuerror("Unable to pop stack for process definition");

                  exit(-1);
               }

               /* Prep for next process */
               if(!pushSymStack(0, &yyerror))
               {
                  yyuerror("Unable to push stack for sub-process definition");

                  exit(-1);
               }

               if(!isProcessExpr($2))
               {
                  yyuerror("Defining expression is not a process expression");
               }

               procDef = 0;

               $$ = $1;

               ((ProcDefNode *) $$)->defExpr = $2;
               ((ProcDefNode *) $$)->props   = $6;

               INT8  *tmpTex = ((SyntaxTree *) $$)->ozTex;

               ((SyntaxTree *) $$)->ozTex = foztex("%s%s%s%s", tmpTex, ((SyntaxTree *) $2)->ozTex,
                                                                   $3, $4);

               free(tmpTex);
               free(((SyntaxTree *) $2)->ozTex);
               free($3);
               free($4);
               free($5);
               free($7);
            }
          ;

proc_def_hdr: TOK_PROCESS TOK_EQUALS
              {
                 if(!pushSymStack(0, &yyerror))
                 {
                    yyuerror("Unable to push stack for sub-process definition");

                    exit(-1);
                 }

                 procDef = 1;

                 $$ = createProcDefNode($1->token, NULL, NULL);

                 Symbol  *procSym = symLookup($1->token, &yyuerror);

                 if(procSym == NULL)
                 {
                    yyuerror("Process declaration %s not found", $1->token);
                 }
                 else
                 {
                    TreeType  *defType = (TreeType *) createBasicTreeType(strdup("PROCESS"));

                    if(!typeCompare(procSym->synTree->treeType, defType))
                    {
                       yyuerror("Process definition type does not match declaration for %s", $1->token);
                    }

                    freeTypeTree(defType);
                 }

                 ((SyntaxTree *) $$)->ozTex = foztex("%s%s%s=", $1->preFmt, getOzXfm($1->token), $2);

                 $1->token = NULL;

                 freeAToken($1);
                 free($2);
              }
            | TOK_PROC_FUNC tok_oparen pdecl_list1 tok_cparen TOK_EQUALS
              {
                 if(!pushSymStack(0, &yyerror))
                 {
                    yyuerror("Unable to push stack for sub-process definition");

                    exit(-1);
                 }

                 procDef = 1;

                 $$ = createProcDefNode($1->token, $3, NULL);

                 Symbol  *procSym = symLookup($1->token, &yyuerror);

                 if(procSym == NULL)
                 {
                    yyuerror("Process declaration %s not found", $1->token);
                 }
                 else
                 {
                    TreeType  *defInType    = NULL;
                    TreeType  *defOutType   = (TreeType *) createBasicTreeType(strdup("PROCESS"));
                    TreeType  *defTupleType = createTupleTreeType(NULL, 0);
                    TreeType  *defType      = NULL;

                    if(((ProcDefNode *) $$)->decls->next != NULL)
                    {
                       defInType = createTupleTreeTypeFromDecls(((ProcDefNode *) $$)->decls);
                    }
                    else
                    {
                       DeclarationNode  *decl = (DeclarationNode *) ((ProcDefNode *) $$)->decls->object;

                       defInType = (TreeType *) copyTypeTree(getTypeBoundType(decl->defExpr->treeType));
                    }

                    LinkList  *defTypeList  = createLinkList(defInType);

                    appendLinkList(defTypeList, defOutType);

                    ((TupleType *) defTupleType)->typeList = defTypeList;

                    defType = createSetTreeType((TreeType *) defTupleType);

                    if(!typeCompare(procSym->synTree->treeType, defType))
                    {
                       yyuerror("Process definition type does not match declaration for %s", $1->token);
                    }

                    freeTypeTree(defType);
                 }

                 INT8  *declList = list2oz($3, ",", "", "");

                 ((SyntaxTree *) $$)->ozTex = foztex("%s%s%s(%s%s)%s=", $1->preFmt, getOzXfm($1->token), $2,
                                                                        declList, $4, $5);

                 free(declList);

                 $1->token = NULL;

                 freeAToken($1);
                 free($2);
                 free($4);
                 free($5);
              }
            | TOK_GEN_PROC_FUNC gen_field tok_oparen pdecl_list1 tok_cparen TOK_EQUALS
              {
                 if(!pushSymStack(0, &yyerror))
                 {
                    yyuerror("Unable to push stack for sub-process definition");

                    exit(-1);
                 }

                 procDef = 1;

                 $$ = createGenProcDefNode($1->token, $4, NULL, $2);

                 Symbol  *procSym = symLookup($1->token, &yyuerror);

                 if(procSym == NULL)
                 {
                    yyuerror("Process declaration %s not found", $1->token);
                 }
                 else
                 {
                    TreeType  *defInType    = NULL;
                    TreeType  *defOutType   = (TreeType *) createBasicTreeType(strdup("PROCESS"));
                    TreeType  *defTupleType = createTupleTreeType(NULL, 0);
                    TreeType  *defType      = NULL;

                    if(!compareGenSyms(((DeclarationNode *) procSym->synTree)->genSyms, $2))
                    {
                       yyuerror("Generic symbol list does not match process declaration");
                    }

                    if(((ProcDefNode *) $$)->decls->next != NULL)
                    {
                       defInType = createTupleTreeTypeFromDecls(((ProcDefNode *) $$)->decls);
                    }
                    else
                    {
                       DeclarationNode  *decl = (DeclarationNode *) ((ProcDefNode *) $$)->decls->object;

                       defInType = (TreeType *) copyTypeTree(getTypeBoundType(decl->defExpr->treeType));
                    }

                    LinkList  *defTypeList  = createLinkList(defInType);

                    appendLinkList(defTypeList, defOutType);

                    ((TupleType *) defTupleType)->typeList = defTypeList;

                    defType = createSetTreeType((TreeType *) defTupleType);

                    if(!typeCompare(procSym->synTree->treeType, defType))
                    {
                       yyuerror("Process definition type does not match declaration for %s", $1->token);
                    }

                    freeTypeTree(defType);
                 }

                 INT8  *declList = list2oz($4, ",", "", "");
                 INT8  *genList  = genList2oz($2);

                 ((SyntaxTree *) $$)->ozTex = foztex("%s%s[%s]%s(%s%s)%s=", $1->preFmt, getOzXfm($1->token),
                                                                            genList, $3, declList, $5, $6);

                 free(declList);

                 $1->token = NULL;

                 freeAToken($1);
                 free(genList);
                 free($3);
                 free($5);
                 free($6);
              }
            ;

cspexp: bcspexp %prec TOK_EXPR
        {
          $$ = $1;
        }
      | bcspexp TOK_POUND TOK_OSQUARE post_props TOK_CSQUARE
        {
           $$ = $1;

           ((ExprNode *) $1)->props = $4;

           INT8  *tmpTex = ((SyntaxTree *) $1)->ozTex;

           ((SyntaxTree *) $1)->ozTex = foztex("%s%s", tmpTex, $2);

           free(tmpTex);
           free($2);
           free($3);
           free($5);
        }
      ;

zexpr: TOK_OSQUARE expr TOK_CSQUARE
       {
          $$ = $2;

          INT8  *tmpTex = ((SyntaxTree *) $2)->ozTex;

          ((SyntaxTree *) $$)->ozTex = foztex("%s[%s%s]", $1, tmpTex, $3);

          free(tmpTex);
          free($1);
          free($3);
       }

bcspexp: TOK_EVENT
         {
            $$ = createVariableNode($1->token, NULL);

            ((SyntaxTree *) $$)->ozTex = atok2oz($1);

            Symbol  *varSym = symLookup($1->token, &yyuerror);

            if(varSym == NULL)
            {
               yyuerror("Event identifier %s not found", $1->token);
            }
            else
            {
               ((SyntaxTree *) $$)->treeType = varSym->synTree->treeType;
            }

            $1->token = NULL;

            freeAToken($1);
         }
       | zexpr
         {
            $$ = $1;
         }
       | chan_appl
         {
            $$ = $1;
         }
       | TOK_PROCESS
         {
            /* Pop sub-process */
            if(!popSymStack())
            {
               yyuerror("Unable to pop stack for sub-process definition");

               exit(-1);
            }

            /* Prep for next sub-process */
            if(!pushSymStack(0, &yyerror))
            {
               yyuerror("Unable to push stack for sub-process definition");

               exit(-1);
            }

            $$ = createVariableNode($1->token, NULL);

            ((SyntaxTree *) $$)->ozTex = atok2oz($1);

            Symbol  *varSym = symLookup($1->token, &yyuerror);

            if(varSym == NULL)
            {
               yyuerror("Process identifier %s not found", $1->token);
            }
            else
            {
               ((SyntaxTree *) $$)->treeType = varSym->synTree->treeType;
            }

            $1->token = NULL;

            freeAToken($1);
         }
       | pfunc_appl
         {
            /* Pop sub-process */
            if(!popSymStack())
            {
               yyuerror("Unable to pop stack for sub-process definition");

               exit(-1);
            }

            /* Prep for next sub-process */
            if(!pushSymStack(0, &yyerror))
            {
               yyuerror("Unable to push stack for sub-process definition");

               exit(-1);
            }

            $$ = $1;
         }
       | proc_oper
         {
            /* Pop sub-process */
            if(!popSymStack())
            {
               yyuerror("Unable to pop stack for sub-process definition");

               exit(-1);
            }

            /* Prep for next sub-process */
            if(!pushSymStack(0, &yyerror))
            {
               yyuerror("Unable to push stack for sub-process definition");

               exit(-1);
            }

            $$ = $1;
         }
       | proc_cond
         {
            /* Pop sub-process */
            if(!popSymStack())
            {
               yyuerror("Unable to pop stack for sub-process definition");

               exit(-1);
            }

            /* Prep for next sub-process */
            if(!pushSymStack(0, &yyerror))
            {
               yyuerror("Unable to push stack for sub-process definition");

               exit(-1);
            }

            $$ = $1;
         }
       | tok_oparen cspexp tok_cparen
         {
            /* Pop sub-process */
            if(!popSymStack())
            {
               yyuerror("Unable to pop stack for sub-process definition");

               exit(-1);
            }

            /* Prep for next sub-process */
            if(!pushSymStack(0, &yyerror))
            {
               yyuerror("Unable to push stack for sub-process definition");

               exit(-1);
            }

            if(!isProcessExpr($2))
            {
               yyuerror("Parenthesized expression is not a process expression");
            }

            $$ = $2;

            INT8  *tmpTex = ((SyntaxTree *) $2)->ozTex;

            ((SyntaxTree *) $$)->ozTex = foztex("%s(%s%s)", $1, tmpTex, $3);

            free(tmpTex);
            free($1);
            free($3);
         }
       ;

chan_appl: zexpr chan_fields1
           {
              SyntaxTree  *chanAST = (SyntaxTree *) $1;
              TreeType    *outType = (TreeType *) createBasicTreeType("CSP_EVENT");

              if(!isFuncExpr(chanAST) || !typeCompare(getFuncAppliedType(chanAST->treeType), outType))
              {
                 yyuerror("Expression is not a channel type");
              }
              else
              {
                 TreeType  *chanType = getFuncParamType(chanAST->treeType);
                 LinkList  *chanList = NULL;

                 if(chanType->nodeType == TUPLE_TYPE)
                 {
                    chanList = ((TupleType *) chanType)->typeList;
                 }
                 else
                 {
                    chanList = createLinkList(chanType);
                 }

                 if(!processChanAppl(chanList, $2))
                 {
                    yyuerror("Channel expression parameter mismatch");
                 }

                 $$ = createChanApplNode(chanAST, $2);

                 INT8  *fieldList = list2oz($2, "", "", "");

                 ((SyntaxTree *) $$)->treeType = outType;
                 ((SyntaxTree *) $$)->ozTex    = foztex("%s%s", chanAST->ozTex, fieldList);

                 if(chanType->nodeType != TUPLE_TYPE)
                 {
                    freeLinkList(chanList);
                 }

                 free(chanAST->ozTex);
                 free(fieldList);
              }
           }
         | TOK_CHANNEL chan_fields1
           {
              SyntaxTree  *chanAST = (SyntaxTree *) createExprIdentNode($1->token);

              chanAST->ozTex = atok2oz($1);

              $$ = createChanApplNode(chanAST, $2);

              Symbol  *chanSym = symLookup($1->token, &yyuerror);

              if(chanSym == NULL)
              {
                 yyuerror("Channel identifier %s not found", $1->token);
              }
              else
              {
                 chanAST->treeType = chanSym->synTree->treeType;

                 TreeType  *chanType = getFuncParamType(chanSym->synTree->treeType);
                 LinkList  *chanList = NULL;

                 if(chanType->nodeType == TUPLE_TYPE)
                 {
                    chanList = ((TupleType *) chanType)->typeList;
                 }
                 else
                 {
                    chanList = createLinkList(chanType);
                 }

                 if(!processChanAppl(chanList, $2))
                 {
                    yyuerror("Channel %s parameter mismatch", $1->token);
                 }

                 INT8  *fieldList = list2oz($2, "", "", "");

                 ((SyntaxTree *) $$)->treeType = (TreeType *) createBasicTreeType("CSP_EVENT");
                 ((SyntaxTree *) $$)->ozTex    = foztex("%s%s", chanAST->ozTex, fieldList);

                 if(chanType->nodeType != TUPLE_TYPE)
                 {
                    freeLinkList(chanList);
                 }

                 free(chanAST->ozTex);
                 free(fieldList);
              }

              $1->token = NULL;

              freeAToken($1);
           }
         | TOK_GEN_CHANNEL TOK_OCURLY TOK_OSQUARE expr_list TOK_CSQUARE TOK_CCURLY
           chan_fields1
           {
              SyntaxTree  *chanAST = (SyntaxTree *) createExprIdentNode($1->token);

              chanAST->ozTex = atok2oz($1);

              ((ExprIdentNode *) chanAST)->specList = $4;

              $$ = createChanApplNode(chanAST, $7);

              Symbol  *chanSym = symLookup($1->token, &yyuerror);

              if(chanSym == NULL)
              {
                 yyuerror("Channel identifier %s not found", $1->token);
              }
              else
              {
                 DeclarationNode  *chanDecl = (DeclarationNode *) chanSym->synTree;
                 LinkList         *subList  = createGenPatchList(chanDecl->genSyms, $4);

                 chanAST->treeType = substituteGen(chanSym->synTree->treeType, subList);

                 freeSubList(subList);

                 TreeType  *chanType = getFuncParamType(chanAST->treeType);
                 LinkList  *chanList = NULL;

                 if(chanType->nodeType == TUPLE_TYPE)
                 {
                    chanList = ((TupleType *) chanType)->typeList;
                 }
                 else
                 {
                    chanList = createLinkList(chanType);
                 }

                 if(!processChanAppl(chanList, $7))
                 {
                    yyuerror("Channel %s parameter mismatch", $1->token);
                 }

                 INT8  *specList  = list2oz($4, ",", "", "");
                 INT8  *fieldList = list2oz($7, "", "", "");

                 ((SyntaxTree *) $$)->treeType = (TreeType *) createBasicTreeType("CSP_EVENT");
                 ((SyntaxTree *) $$)->ozTex    = foztex("%s%s[%s%s]%s", chanAST->ozTex, $2, specList,
                                                                        $5, fieldList);

                 if(chanType->nodeType != TUPLE_TYPE)
                 {
                    freeLinkList(chanList);
                 }

                 free(chanAST->ozTex);
                 free($2);
                 free($3);
                 free(specList);
                 free($5);
                 free($6);
                 free(fieldList);
              }

              $1->token = NULL;

              freeAToken($1);
           }
         ;

chan_fields1: chan_field
              {
                 DEBUG("first chanField = %s\n", ((SyntaxTree *) $1)->ozTex);

                 $$ = createLinkList($1);
              }
            | chan_fields1 chan_field
              {
                 DEBUG("next chanField = %s\n", ((SyntaxTree *) $2)->ozTex);

                 appendLinkList($1, $2);

                 $$ = $1;
              }
            ;

chan_field: TOK_QUEST TOK_IDENT
            {
               SyntaxTree  *varAST = (SyntaxTree *) createVariableNode($2->token, NULL);

               varAST->ozTex = atok2oz($2);

               $$ = createChanFieldNode(INPUT_FIELD, varAST);

               ((SyntaxTree *) $$)->ozTex    = foztex("%s?%s", $1, varAST->ozTex);
               ((SyntaxTree *) $$)->treeType = NULL;

               if(!addSymToTable($2->token, TOK_PROC_VAR, $$))
               {
                  yyuerror("Unable to add variable to symbol table");

                  exit(-1);
               }

               $2->token = NULL;

               free($1);
               free(varAST->ozTex);
               freeAToken($2);
            }
          | TOK_QUEST var_ident var_post_decor
            {
               if(($3->token)[0] != '\'')
               {
                  yyuerror("%s decoration is not valid for process variables", $3->token);
               }

               tmpStr = malloc(strlen($2->token) + strlen($3->token) + 1);

               memset(tmpStr, 0, strlen($2->token) + strlen($3->token) + 1);
               strncpy(tmpStr, $2->token, strlen($2->token));
               strncpy(&(tmpStr[strlen($2->token)]), $3->token, strlen($3->token));

               SyntaxTree  *varAST   = (SyntaxTree *) createVariableNode($2->token, $3->token);
               DecorType   postDecor = extractDecorType($3->token);
               UINT8       postCnt   = extractDecorCount($3->token);
               INT8        *ozPost   = NULL;

               if(postDecor == POST_PRI)
               {
                  if(postCnt > 1)
                  {
                     ozPost = foztex("\\zPri{%d}", postCnt);
                  }
                  else
                  {
                     ozPost = foztex("'");
                  }
               }
               else if(postDecor == POST_IN)
               {
                  ozPost = foztex("?");
               }
               else if(postDecor == POST_OUT)
               {
                  ozPost = foztex("!");
               }

               varAST->ozTex = foztex("%s%s%s%s", $2->preFmt, getOzXfm($2->token), $3->preFmt, ozPost);

               $$ = createChanFieldNode(INPUT_FIELD, varAST);

               ((SyntaxTree *) $$)->ozTex    = foztex("%s?%s", $1, varAST->ozTex);
               ((SyntaxTree *) $$)->treeType = NULL;

               if(!addSymToTable(tmpStr, TOK_PROC_VAR, $$))
               {
                  yyuerror("Unable to add variable to symbol table");

                  exit(-1);
               }

               $2->token = NULL;

               free($1);
               free(varAST->ozTex);
               free(ozPost);
               freeAToken($2);
               freeAToken($3);
               free(tmpStr);

               tmpStr = NULL;
            }
          | TOK_PERIOD pout_types
            {
               $$ = createChanFieldNode(DOT_FIELD, $2);

               ((SyntaxTree *) $$)->ozTex    = foztex("%s.%s", $1, ((SyntaxTree *) $2)->ozTex);
               ((SyntaxTree *) $$)->treeType = ((SyntaxTree *) $2)->treeType;

               free($1);
               free(((SyntaxTree *) $2)->ozTex);
            }
          | TOK_EXCLAIM pout_types
            {
               $$ = createChanFieldNode(OUTPUT_FIELD, $2);

               ((SyntaxTree *) $$)->ozTex    = foztex("%s!%s", $1, ((SyntaxTree *) $2)->ozTex);
               ((SyntaxTree *) $$)->treeType = ((SyntaxTree *) $2)->treeType;

               free($1);
               free(((SyntaxTree *) $2)->ozTex);
            }
          ;

pout_ident: TOK_VAR_BINDING
            {
               $$ = $1;
            }
          | TOK_PROC_VAR
            {
               $$ = $1;
            }
          ;

pout_types: pout_ident
            {
               $$ = createVariableNode($1->token, NULL);

               ((SyntaxTree *) $$)->ozTex = atok2oz($1);

               Symbol  *varSym = symLookup($1->token, &yyuerror);

               if(varSym == NULL)
               {
                  yyuerror("Variable identifier %s not found", $1->token);
               }
               else
               {
                  ((SyntaxTree *) $$)->treeType = varSym->synTree->treeType;
               }

               $1->token = NULL;

               freeAToken($1);
            }
          | var_ident var_post_decor
            {
               if(($2->token)[0] != '\'')
               {
                  yyuerror("%s decoration is not valid for process variables", $2->token);
               }

               tmpStr = malloc(strlen($1->token) + strlen($2->token) + 1);

               memset(tmpStr, 0, strlen($1->token) + strlen($2->token) + 1);
               strncpy(tmpStr, $1->token, strlen($1->token));
               strncpy(&(tmpStr[strlen($1->token)]), $2->token, strlen($2->token));

               $$ = createVariableNode($1->token, $2->token);

               DecorType   postDecor = extractDecorType($2->token);
               UINT8       postCnt   = extractDecorCount($2->token);
               INT8        *ozPost   = NULL;

               if(postDecor == POST_PRI)
               {
                  if(postCnt > 1)
                  {
                     ozPost = foztex("\\zPri{%d}", postCnt);
                  }
                  else
                  {
                     ozPost = foztex("'");
                  }
               }
               else if(postDecor == POST_IN)
               {
                  ozPost = foztex("?");
               }
               else if(postDecor == POST_OUT)
               {
                  ozPost = foztex("!");
               }

               ((SyntaxTree *) $$)->ozTex = foztex("%s%s%s%s", $1->preFmt, getOzXfm($1->token),
                                                               $2->preFmt, ozPost);

               Symbol  *varSym = symLookup(tmpStr, &yyuerror);

               if(varSym == NULL)
               {
                  yyuerror("Variable identifier %s not found", varSym);
               }
               else
               {
                  ((SyntaxTree *) $$)->treeType = varSym->synTree->treeType;
               }

               $1->token = NULL;

               freeAToken($1);
               freeAToken($2);

               free(tmpStr);
               free(ozPost);

               tmpStr = NULL;
            }
          | TOK_NUMBER
            {
               $$ = createExprLiteralNode($1->token);

               ((SyntaxTree *) $$)->ozTex = atok2oz($1);

               $1->token = NULL;

               freeAToken($1);

               ((SyntaxTree *) $$)->treeType = createBasicTreeType("int");
            }
          | TOK_STRING
            {
               $$ = createExprLiteralNode($1->token);

               INT8  *ozStr = string2oz($1->token);

               ((SyntaxTree *) $$)->ozTex = foztex("%s$%s$", $1->preFmt, ozStr);

               $1->token = NULL;

               freeAToken($1);
               free(ozStr);

               TreeType  *first     = (TreeType *) createBasicTreeType("int");
               TreeType  *second    = createBasicTreeType("char");
               LinkList  *tupleList = createLinkList(first);
               TreeType  *tuple     = (TreeType *) createTupleTreeType(NULL, 0);

               appendLinkList(tupleList, second);

               ((TupleType *) tuple)->typeList = tupleList;

               ((SyntaxTree *) $$)->treeType = createSetTreeType((TreeType *) tuple);
            }
          | TOK_CHAR
            {
               $$ = createExprLiteralNode($1->token);

               INT8  *ozChar = char2oz($1->token);

               ((SyntaxTree *) $$)->ozTex = foztex("%s$%s$", $1->preFmt, ozChar);

               $1->token = NULL;

               freeAToken($1);
               free(ozChar);

               ((SyntaxTree *) $$)->treeType = createBasicTreeType("char");
            }
          | zexpr
            {
               $$ = $1;
            }
          ;

pfunc_appl: TOK_PROC_FUNC tok_oparen expr tok_cparen
            {
               SyntaxTree  *funcAST = (SyntaxTree *) createExprIdentNode($1->token);

               funcAST->ozTex = atok2oz($1);

               Symbol  *varSym = symLookup($1->token, &yyuerror);

               if(varSym == NULL)
               {
                  yyuerror("Process identifier %s not found", $1->token);
               }
               else
               {
                  funcAST->treeType = varSym->synTree->treeType;
               }

               $$ = handleFuncApp(funcAST, $3);

               ((SyntaxTree *) $$)->ozTex = foztex("%s%s(%s%s)", funcAST->ozTex, $2,
                                                                 ((SyntaxTree *) $3)->ozTex, $4);

               $1->token = NULL;

               freeAToken($1);
               free(funcAST->ozTex);
               free($2);
               free(((SyntaxTree *) $3)->ozTex);
               free($4);
            }
          | TOK_PROC_FUNC tuple %prec TOK_FUNC
            {
               SyntaxTree  *funcAST = (SyntaxTree *) createExprIdentNode($1->token);

               funcAST->ozTex = atok2oz($1);

               Symbol  *varSym = symLookup($1->token, &yyuerror);

               if(varSym == NULL)
               {
                  yyuerror("Process identifier %s not found", $1->token);
               }
               else
               {
                  funcAST->treeType = varSym->synTree->treeType;
               }

               $$ = handleFuncApp(funcAST, $2);

               ((SyntaxTree *) $$)->ozTex = foztex("%s%s", funcAST->ozTex, ((SyntaxTree *) $2)->ozTex);

               $1->token = NULL;

               freeAToken($1);
               free(funcAST->ozTex);
               free(((SyntaxTree *) $2)->ozTex);
            }
          | TOK_GEN_PROC_FUNC TOK_OCURLY TOK_OSQUARE expr_list TOK_CSQUARE TOK_CCURLY
            tok_oparen expr tok_cparen
            {
               SyntaxTree  *funcAST = (SyntaxTree *) createExprIdentNode($1->token);

               funcAST->ozTex = atok2oz($1);

               ((ExprIdentNode *) funcAST)->specList = $4;

               Symbol  *varSym   = symLookup($1->token, &yyuerror);
               INT8    *specList = list2oz($4, ",", "", "");

               if(varSym == NULL)
               {
                  yyuerror("Process identifier %s not found", $1->token);
               }
               else
               {
                  printType($1->token, varSym->synTree->treeType);

                  DeclarationNode  *funcDecl = (DeclarationNode *) varSym->synTree;
                  LinkList         *subList  = createGenPatchList(funcDecl->genSyms, $4);

                  funcAST->treeType = substituteGen(varSym->synTree->treeType, subList);

                  freeSubList(subList);
               }

               $$ = handleFuncApp(funcAST, $8);

               ((SyntaxTree *) $$)->ozTex = foztex("%s%s[%s%s]%s(%s%s)", funcAST->ozTex, $2, specList,
                                                                         $5, $7, ((SyntaxTree *) $8)->ozTex,
                                                                         $9);

               $1->token = NULL;

               freeAToken($1);
               free(funcAST->ozTex);
               free($2);
               free($3);
               free(specList);
               free($5);
               free($6);
               free($7);
               free(((SyntaxTree *) $8)->ozTex);
               free($9);
            }
          | TOK_GEN_PROC_FUNC TOK_OCURLY TOK_OSQUARE expr_list TOK_CSQUARE TOK_CCURLY
            tuple %prec TOK_FUNC
            {
               SyntaxTree  *funcAST = (SyntaxTree *) createExprIdentNode($1->token);

               funcAST->ozTex = atok2oz($1);

               ((ExprIdentNode *) funcAST)->specList = $4;

               Symbol  *varSym   = symLookup($1->token, &yyuerror);
               INT8    *specList = list2oz($4, ",", "", "");

               if(varSym == NULL)
               {
                  yyuerror("Process identifier %s not found", $1->token);
               }
               else
               {
                  printType($1->token, varSym->synTree->treeType);

                  DeclarationNode  *funcDecl = (DeclarationNode *) varSym->synTree;
                  LinkList         *subList  = createGenPatchList(funcDecl->genSyms, $4);

                  funcAST->treeType = substituteGen(varSym->synTree->treeType, subList);

                  freeSubList(subList);
               }

               $$ = handleFuncApp(funcAST, $7);

               ((SyntaxTree *) $$)->ozTex = foztex("%s%s[%s%s]%s", funcAST->ozTex, $2, specList, $5,
                                                                   ((SyntaxTree *) $7)->ozTex);

               $1->token = NULL;

               freeAToken($1);
               free(funcAST->ozTex);
               free($2);
               free($3);
               free(specList);
               free($5);
               free($6);
               free(((SyntaxTree *) $7)->ozTex);
            }
          ;

proc_oper: cspexp TOK_PTHEN cspexp
           {
              $$ = handleFInOp($1, "->", $3);

              ((SyntaxTree *) $$)->ozTex    = foztex("%s%s\\mathrel{\\pthen}%s",
                                                     ((SyntaxTree *) $1)->ozTex, $2,
                                                     ((SyntaxTree *) $3)->ozTex);

              free(((SyntaxTree *) $1)->ozTex);
              free(((SyntaxTree *) $3)->ozTex);

              free($2);
           }
         | internal
           {
              $$ = $1;
           }
         | external
           {
              $$ = $1;
           }
         | parallel
           {
              $$ = $1;
           }
         | if_parallel
           {
              $$ = $1;
           }
         | interleave
           {
              $$ = $1;
           }
         | let_proc
           {
              $$ = $1;
           }
         | interrupt
           {
              $$ = $1;
           }
         | cspexp TOK_PSEQ cspexp
           {
              $$ = handleFInOp($1, "pseq", $3);

              ((SyntaxTree *) $$)->ozTex    = foztex("%s%s\\mathrel{\\zbig\\comp}%s",
                                                     ((SyntaxTree *) $1)->ozTex, $2,
                                                     ((SyntaxTree *) $3)->ozTex);

              free(((SyntaxTree *) $1)->ozTex);
              free(((SyntaxTree *) $3)->ozTex);

              free($2);
           }
         | cspexp TOK_PHIDE expr
           {
              $$ = handleFInOp($1, "phide", $3);

              ((SyntaxTree *) $$)->ozTex    = foztex("%s%s\\phide%s", ((SyntaxTree *) $1)->ozTex, $2,
                                                                      ((SyntaxTree *) $3)->ozTex);

              free(((SyntaxTree *) $1)->ozTex);
              free($2);
              free(((SyntaxTree *) $3)->ozTex);
           }
         ;

proc_cond: tok_if pred_list TOK_THEN cspexp tok_endif
           {
              if(!isProcessExpr($4))
              {
                 yyuerror("Then expression is not a process expression");
              }

              $$ = createCondProcNode($2, $4, NULL);

              INT8  *predList = list2oz($2, "", "", "");

              ((SyntaxTree *) $$)->treeType = ((SyntaxTree *) $4)->treeType;
              ((SyntaxTree *) $$)->ozTex    =
                    foztex("%s\\IF %s%s\\THEN %s%s\\ENDIF", $1, predList, $3, ((SyntaxTree *) $4)->ozTex, $5);

              free($1);
              free(predList);
              free($3);
              free(((SyntaxTree *) $4)->ozTex);
              free($5);
           }
         | tok_if pred_list TOK_THEN cspexp TOK_ELIF elif_proc
           {
              if(!isProcessExpr($4))
              {
                 yyuerror("Then expression is not a process expression");
              }

              $$ = createCondProcNode($2, $4, $6);

              if(!typeCompare(getExprType($4), getExprType($6)))
              {
                 yyuerror("Then branch and else branch are of incompatible types");
              }

              INT8  *predList = list2oz($2, "", "", "");

              ((SyntaxTree *) $$)->treeType = ((SyntaxTree *) $4)->treeType;
              ((SyntaxTree *) $$)->ozTex    =
                    foztex("%s\\IF %s%s\\THEN %s%s\\ELIF %s", $1, predList, $3, ((SyntaxTree *) $4)->ozTex,
                                                              $5, ((SyntaxTree *) $6)->ozTex);

              free($1);
              free(predList);
              free($3);
              free(((SyntaxTree *) $4)->ozTex);
              free($5);
              free(((SyntaxTree *) $6)->ozTex);
           }
         | tok_if pred_list TOK_THEN cspexp TOK_ELSE cspexp tok_endif
           {
              if(!isProcessExpr($4))
              {
                 yyuerror("Then expression is not a process expression");
              }

              if(!isProcessExpr($6))
              {
                 yyuerror("Else expression is not a process expression");
              }

              $$ = createCondProcNode($2, $4, $6);

              if(!typeCompare(getExprType($4), getExprType($6)))
              {
                 yyuerror("Then branch and else branch are of incompatible types");
              }

              INT8  *predList = list2oz($2, "", "", "");

              ((SyntaxTree *) $$)->treeType = ((SyntaxTree *) $4)->treeType;
              ((SyntaxTree *) $$)->ozTex    =
                    foztex("%s\\IF %s%s\\THEN %s%s\\ELSE %s%s\\ENDIF", $1, predList, $3,
                                                                       ((SyntaxTree *) $4)->ozTex, $5,
                                                                       ((SyntaxTree *) $6)->ozTex, $7);

              free($1);
              free(predList);
              free($3);
              free(((SyntaxTree *) $4)->ozTex);
              free($5);
              free(((SyntaxTree *) $6)->ozTex);
              free($7);
           }
         | tok_if pred_type TOK_THEN cspexp tok_endif
           {
              if(!isProcessExpr($4))
              {
                 yyuerror("Then expression is not a process expression");
              }

              $$ = createCondProcNode(createLinkList($2), $4, NULL);

              ((SyntaxTree *) $$)->treeType = ((SyntaxTree *) $4)->treeType;
              ((SyntaxTree *) $$)->ozTex    =
                    foztex("%s\\IF %s%s\\THEN %s%s\\ENDIF", $1, ((SyntaxTree *) $2)->ozTex, $3,
                                                            ((SyntaxTree *) $4)->ozTex, $5);

              free($1);
              free(((SyntaxTree *) $2)->ozTex);
              free($3);
              free(((SyntaxTree *) $4)->ozTex);
              free($5);
           }
         | tok_if pred_type TOK_THEN cspexp TOK_ELIF elif_proc
           {
              if(!isProcessExpr($4))
              {
                 yyuerror("Then expression is not a process expression");
              }

              $$ = createCondProcNode(createLinkList($2), $4, $6);

              if(!typeCompare(getExprType($4), getExprType($6)))
              {
                 yyuerror("Then branch and else branch are of incompatible types");
              }

              ((SyntaxTree *) $$)->treeType = ((SyntaxTree *) $4)->treeType;
              ((SyntaxTree *) $$)->ozTex    =
                    foztex("%s\\IF %s%s\\THEN %s%s\\ELIF %s", $1, ((SyntaxTree *) $2)->ozTex, $3,
                                                              ((SyntaxTree *) $4)->ozTex, $5,
                                                              ((SyntaxTree *) $6)->ozTex);

              free($1);
              free(((SyntaxTree *) $2)->ozTex);
              free($3);
              free(((SyntaxTree *) $4)->ozTex);
              free($5);
              free(((SyntaxTree *) $6)->ozTex);
           }
         | tok_if pred_type TOK_THEN cspexp TOK_ELSE cspexp tok_endif
           {
              if(!isProcessExpr($4))
              {
                 yyuerror("Then expression is not a process expression");
              }

              if(!isProcessExpr($6))
              {
                 yyuerror("Else expression is not a process expression");
              }

              $$ = createCondProcNode(createLinkList($2), $4, $6);

              if(!typeCompare(getExprType($4), getExprType($6)))
              {
                 yyuerror("Then branch and else branch are of incompatible types");
              }

              ((SyntaxTree *) $$)->treeType = ((SyntaxTree *) $4)->treeType;
              ((SyntaxTree *) $$)->ozTex    =
                    foztex("%s\\IF %s%s\\THEN %s%s\\ELSE %s%s\\ENDIF", $1, ((SyntaxTree *) $2)->ozTex, $3,
                                                                       ((SyntaxTree *) $4)->ozTex, $5,
                                                                       ((SyntaxTree *) $6)->ozTex, $7);

              free($1);
              free(((SyntaxTree *) $2)->ozTex);
              free($3);
              free(((SyntaxTree *) $4)->ozTex);
              free($5);
              free(((SyntaxTree *) $6)->ozTex);
              free($7);
           }
         ;

elif_proc: pred_list TOK_THEN cspexp tok_endif
           {
              if(!isProcessExpr($3))
              {
                 yyuerror("Then expression is not a process expression");
              }

              $$ = createCondProcNode($1, $3, NULL);

              INT8  *predList = list2oz($1, "", "", "");

              ((SyntaxTree *) $$)->treeType = ((SyntaxTree *) $3)->treeType;
              ((SyntaxTree *) $$)->ozTex    =
                    foztex("%s%s\\THEN %s%s\\ENDIF", predList, $2, ((SyntaxTree *) $3)->ozTex, $4);

              free(predList);
              free($2);
              free(((SyntaxTree *) $3)->ozTex);
              free($4);
           }
         | pred_list TOK_THEN cspexp TOK_ELIF elif_proc
           {
              if(!isProcessExpr($3))
              {
                 yyuerror("Then expression is not a process expression");
              }

              $$ = createCondProcNode($1, $3, $5);

              if(!typeCompare(getExprType($3), getExprType($5)))
              {
                 yyuerror("Then branch and else branch are of incompatible types");
              }

              INT8  *predList = list2oz($1, "", "", "");

              ((SyntaxTree *) $$)->treeType = ((SyntaxTree *) $3)->treeType;
              ((SyntaxTree *) $$)->ozTex    =
                    foztex("%s%s\\THEN %s%s\\ELIF %s", predList, $2, ((SyntaxTree *) $3)->ozTex, $4,
                                                       ((SyntaxTree *) $5)->ozTex);

              free(predList);
              free($2);
              free(((SyntaxTree *) $3)->ozTex);
              free($4);
              free(((SyntaxTree *) $5)->ozTex);
           }
         | pred_list TOK_THEN cspexp TOK_ELSE cspexp tok_endif
           {
              if(!isProcessExpr($3))
              {
                 yyuerror("Then expression is not a process expression");
              }

              if(!isProcessExpr($5))
              {
                 yyuerror("Else expression is not a process expression");
              }

              $$ = createCondProcNode($1, $3, $5);

              if(!typeCompare(getExprType($3), getExprType($5)))
              {
                 yyuerror("Then branch and else branch are of incompatible types");
              }

              INT8  *predList = list2oz($1, "", "", "");

              ((SyntaxTree *) $$)->treeType = ((SyntaxTree *) $3)->treeType;
              ((SyntaxTree *) $$)->ozTex    =
                    foztex("%s%s\\THEN %s%s\\ELSE %s%s\\ENDIF", predList, $2, ((SyntaxTree *) $3)->ozTex,
                                                                $4, ((SyntaxTree *) $5)->ozTex, $6);

              free(predList);
              free($2);
              free(((SyntaxTree *) $3)->ozTex);
              free($4);
              free(((SyntaxTree *) $5)->ozTex);
              free($6);
           }
         | pred_type TOK_THEN cspexp tok_endif
           {
              if(!isProcessExpr($3))
              {
                 yyuerror("Then expression is not a process expression");
              }

              $$ = createCondProcNode(createLinkList($1), $3, NULL);

              ((SyntaxTree *) $$)->treeType = ((SyntaxTree *) $3)->treeType;
              ((SyntaxTree *) $$)->ozTex    =
                    foztex("%s%s\\THEN %s%s\\ENDIF", ((SyntaxTree *) $1)->ozTex, $2,
                                                     ((SyntaxTree *) $3)->ozTex, $4);

              free(((SyntaxTree *) $1)->ozTex);
              free($2);
              free(((SyntaxTree *) $3)->ozTex);
              free($4);
           }
         | pred_type TOK_THEN cspexp TOK_ELIF elif_proc
           {
              if(!isProcessExpr($3))
              {
                 yyuerror("Then expression is not a process expression");
              }

              $$ = createCondProcNode(createLinkList($1), $3, $5);

              if(!typeCompare(getExprType($3), getExprType($5)))
              {
                 yyuerror("Then branch and else branch are of incompatible types");
              }

              ((SyntaxTree *) $$)->treeType = ((SyntaxTree *) $3)->treeType;
              ((SyntaxTree *) $$)->ozTex    =
                    foztex("%s%s\\THEN %s%s\\ELIF %s", ((SyntaxTree *) $1)->ozTex, $2,
                                                       ((SyntaxTree *) $3)->ozTex, $4,
                                                       ((SyntaxTree *) $5)->ozTex);

              free(((SyntaxTree *) $1)->ozTex);
              free($2);
              free(((SyntaxTree *) $3)->ozTex);
              free($4);
              free(((SyntaxTree *) $5)->ozTex);
           }
         | pred_type TOK_THEN cspexp TOK_ELSE cspexp tok_endif
           {
              if(!isProcessExpr($3))
              {
                 yyuerror("Then expression is not a process expression");
              }

              if(!isProcessExpr($5))
              {
                 yyuerror("Else expression is not a process expression");
              }

              $$ = createCondProcNode(createLinkList($1), $3, $5);

              if(!typeCompare(getExprType($3), getExprType($5)))
              {
                 yyuerror("Then branch and else branch are of incompatible types");
              }

              ((SyntaxTree *) $$)->treeType = ((SyntaxTree *) $3)->treeType;
              ((SyntaxTree *) $$)->ozTex    =
                    foztex("%s%s\\THEN %s%s\\ELSE %s%s\\ENDIF", ((SyntaxTree *) $1)->ozTex, $2,
                                                                ((SyntaxTree *) $3)->ozTex, $4,
                                                                ((SyntaxTree *) $5)->ozTex, $6);

              free(((SyntaxTree *) $1)->ozTex);
              free($2);
              free(((SyntaxTree *) $3)->ozTex);
              free($4);
              free(((SyntaxTree *) $5)->ozTex);
              free($6);
           }
         ;

internal_hdr: TOK_INTERNAL TOK_OCURLY
              {
                 if(!pushSymStack(0, &yyerror))
                 {
                    yyuerror("Unable to push stack for replicated internal choice");

                    exit(-1);
                 }

                 $$ = createReplProcNode(INTERNAL, NULL, NULL, NULL);

                 ((SyntaxTree *) $$)->ozTex = foztex("%s\\zBig\\sqcap%s(", $1, $2);

                 free($1);
                 free($2);
              }

internal_sch: internal_hdr psdecl_list1 TOK_QUEST pred_list0 TOK_AT
              {
                 if(!pushSymStack(0, &yyerror))
                 {
                    yyuerror("Unable to push stack for sub-process");

                    exit(-1);
                 }

                 $$ = $1;

                 INT8  *tmpTex   = ((SyntaxTree *) $1)->ozTex;
                 INT8  *declList = list2oz($2, "", "", "");
                 INT8  *predList = list2oz($4, "", "|", "");

                 ((ReplProcNode *) $$)->decls    = $2;
                 ((ReplProcNode *) $$)->filters  = $4;
                 ((ReplProcNode *) $$)->ozTex    = foztex("%s%s%s%s%s@", tmpTex, declList, $3, predList, $5);

                 free(tmpTex);
                 free(declList);
                 free($3);
                 free(predList);
                 free($5);
              }
            ;

internal: internal_sch cspexp TOK_CCURLY %prec TOK_PROC_REPL
          {
             if(!popSymStack())
             {
                yyuerror("Unable to pop stack for sub-process");

                exit(-1);
             }

             if(!popSymStack())
             {
                yyuerror("Unable to pop stack for replicated internal choice");

                exit(-1);
             }

             if(!isProcessExpr($2))
             {
                yyuerror("Replicated expression is not a process expression");
             }

             $$ = $1;

             INT8  *tmpTex   = ((SyntaxTree *) $1)->ozTex;

             ((ReplProcNode *) $$)->expr     = $2;
             ((ReplProcNode *) $$)->treeType = createBasicTreeType("PROCESS");
             ((ReplProcNode *) $$)->ozTex    = foztex("%s%s%s)", tmpTex, ((SyntaxTree *) $2)->ozTex, $3);

             free(tmpTex);
             free(((SyntaxTree *) $2)->ozTex);
             free($3);
          }
        | cspexp TOK_INTERNAL cspexp
          {
             $$ = handleFInOp($1, "|~|", $3);

             ((SyntaxTree *) $$)->ozTex = foztex("%s%s\\mathrel{\\sqcap}%s", ((SyntaxTree *) $1)->ozTex, $2,
                                                                             ((SyntaxTree *) $3)->ozTex);
             free(((SyntaxTree *) $1)->ozTex);
             free(((SyntaxTree *) $3)->ozTex);

             free($2);
          }
        ;

external_hdr: TOK_EXTERNAL TOK_OCURLY
              {
                 if(!pushSymStack(0, &yyerror))
                 {
                    yyuerror("Unable to push stack for replicated external choice");

                    exit(-1);
                 }

                 $$ = createReplProcNode(EXTERNAL, NULL, NULL, NULL);

                 ((SyntaxTree *) $$)->ozTex = foztex("%s\\zBig\\Box%s(", $1, $2);

                 free($1);
                 free($2);
              }

external_sch: external_hdr psdecl_list1 TOK_QUEST pred_list0 TOK_AT
              {
                 if(!pushSymStack(0, &yyerror))
                 {
                    yyuerror("Unable to push stack for sub-process");

                    exit(-1);
                 }

                 $$ = $1;

                 INT8  *tmpTex   = ((SyntaxTree *) $1)->ozTex;
                 INT8  *declList = list2oz($2, "", "", "");
                 INT8  *predList = list2oz($4, "", "|", "");

                 ((ReplProcNode *) $$)->decls    = $2;
                 ((ReplProcNode *) $$)->filters  = $4;
                 ((ReplProcNode *) $$)->ozTex    = foztex("%s%s%s%s%s@", tmpTex, declList, $3, predList, $5);

                 free(tmpTex);
                 free(declList);
                 free($3);
                 free(predList);
                 free($5);
              }
            ;

external: external_sch cspexp TOK_CCURLY %prec TOK_PROC_REPL
          {
             if(!popSymStack())
             {
                yyuerror("Unable to pop stack for sub-process");

                exit(-1);
             }

             if(!popSymStack())
             {
                yyuerror("Unable to pop stack for replicated external choice");

                exit(-1);
             }

             if(!isProcessExpr($2))
             {
                yyuerror("Replicated expression is not a process expression");
             }

             $$ = $1;

             INT8  *tmpTex   = ((SyntaxTree *) $1)->ozTex;

             ((ReplProcNode *) $$)->expr     = $2;
             ((ReplProcNode *) $$)->treeType = createBasicTreeType("PROCESS");
             ((ReplProcNode *) $$)->ozTex    = foztex("%s%s%s)", tmpTex, ((SyntaxTree *) $2)->ozTex, $3);

             free(tmpTex);
             free(((SyntaxTree *) $2)->ozTex);
             free($3);
          }
        | cspexp TOK_EXTERNAL cspexp
          {
             $$ = handleFInOp($1, "[]", $3);

             ((SyntaxTree *) $$)->ozTex = foztex("%s%s\\mathrel{\\Box}%s", ((SyntaxTree *) $1)->ozTex, $2,
                                                                           ((SyntaxTree *) $3)->ozTex);
             free(((SyntaxTree *) $1)->ozTex);
             free(((SyntaxTree *) $3)->ozTex);

             free($2);
          }
        ;

parallel_hdr: TOK_LOR TOK_OCURLY
              {
                 if(!pushSymStack(0, &yyerror))
                 {
                    yyuerror("Unable to push stack for replicated parallel composition");

                    exit(-1);
                 }

                 $$ = createReplProcNode(PARALLEL, NULL, NULL, NULL);

                 ((SyntaxTree *) $$)->ozTex = foztex("%s\\zBig\\parallel%s(", $1, $2);

                 free($1);
                 free($2);
              }

parallel_sch: parallel_hdr psdecl_list1 TOK_QUEST pred_list0 TOK_AT
              {
                 if(!pushSymStack(0, &yyerror))
                 {
                    yyuerror("Unable to push stack for sub-process");

                    exit(-1);
                 }

                 $$ = $1;

                 INT8  *tmpTex   = ((SyntaxTree *) $1)->ozTex;
                 INT8  *declList = list2oz($2, "", "", "");
                 INT8  *predList = list2oz($4, "", "|", "");

                 ((ReplProcNode *) $$)->decls    = $2;
                 ((ReplProcNode *) $$)->filters  = $4;
                 ((ReplProcNode *) $$)->ozTex    = foztex("%s%s%s%s%s@", tmpTex, declList, $3, predList, $5);

                 free(tmpTex);
                 free(declList);
                 free($3);
                 free(predList);
                 free($5);
              }
            ;

parallel: parallel_sch cspexp TOK_CCURLY %prec TOK_PROC_REPL
          {
             if(!popSymStack())
             {
                yyuerror("Unable to pop stack for sub-process");

                exit(-1);
             }

             if(!popSymStack())
             {
                yyuerror("Unable to pop stack for replicated parallel composition");

                exit(-1);
             }

             if(!isProcessExpr($2))
             {
                yyuerror("Replicated expression is not a process expression");
             }

             $$ = $1;

             INT8  *tmpTex   = ((SyntaxTree *) $1)->ozTex;

             ((ReplProcNode *) $$)->expr     = $2;
             ((ReplProcNode *) $$)->treeType = createBasicTreeType("PROCESS");
             ((ReplProcNode *) $$)->ozTex    = foztex("%s%s%s)", tmpTex, ((SyntaxTree *) $2)->ozTex, $3);

             free(tmpTex);
             free(((SyntaxTree *) $2)->ozTex);
             free($3);
          }
        | cspexp TOK_LOR cspexp %prec TOK_PARALLEL
          {
             $$ = handleFInOp($1, "||", $3);

             ((SyntaxTree *) $$)->ozTex =
                   foztex("%s%s\\mathrel{\\parallel}%s", ((SyntaxTree *) $1)->ozTex, $2,
                                                         ((SyntaxTree *) $3)->ozTex);
             free(((SyntaxTree *) $1)->ozTex);
             free(((SyntaxTree *) $3)->ozTex);

             free($2);
          }
        ;

interleave_hdr: TOK_INTERLEAVE TOK_OCURLY
                {
                   if(!pushSymStack(0, &yyerror))
                   {
                      yyuerror("Unable to push stack for replicated interleaved composition");

                      exit(-1);
                   }

                   $$ = createReplProcNode(INTERLEAVE, NULL, NULL, NULL);

                   ((SyntaxTree *) $$)->ozTex = foztex("%s\\zBig\\interleave%s(", $1, $2);

                   free($1);
                   free($2);
                }

interleave_sch: interleave_hdr psdecl_list1 TOK_QUEST pred_list0 TOK_AT
              {
                 if(!pushSymStack(0, &yyerror))
                 {
                    yyuerror("Unable to push stack for sub-process");

                    exit(-1);
                 }

                 $$ = $1;

                 INT8  *tmpTex   = ((SyntaxTree *) $1)->ozTex;
                 INT8  *declList = list2oz($2, "", "", "");
                 INT8  *predList = list2oz($4, "", "|", "");

                 ((ReplProcNode *) $$)->decls    = $2;
                 ((ReplProcNode *) $$)->filters  = $4;
                 ((ReplProcNode *) $$)->ozTex    = foztex("%s%s%s%s%s@", tmpTex, declList, $3, predList, $5);

                 free(tmpTex);
                 free(declList);
                 free($3);
                 free(predList);
                 free($5);
              }
            ;

interleave: interleave_sch cspexp TOK_CCURLY %prec TOK_PROC_REPL
            {
               if(!popSymStack())
               {
                  yyuerror("Unable to pop stack for sub-process");

                  exit(-1);
               }

               if(!popSymStack())
               {
                  yyuerror("Unable to pop stack for replicated interleaved composition");

                  exit(-1);
               }

               if(!isProcessExpr($2))
               {
                  yyuerror("Replicated expression is not a process expression");
               }

               $$ = $1;

               INT8  *tmpTex   = ((SyntaxTree *) $1)->ozTex;

               ((ReplProcNode *) $$)->expr     = $2;
               ((ReplProcNode *) $$)->treeType = createBasicTreeType("PROCESS");
               ((ReplProcNode *) $$)->ozTex    = foztex("%s%s%s)", tmpTex, ((SyntaxTree *) $2)->ozTex, $3);

               free(tmpTex);
               free(((SyntaxTree *) $2)->ozTex);
               free($3);
            }
          | cspexp TOK_INTERLEAVE cspexp
            {
               $$ = handleFInOp($1, "|||", $3);

               ((SyntaxTree *) $$)->ozTex =
                     foztex("%s%s\\mathrel{\\interleave}%s", ((SyntaxTree *) $1)->ozTex, $2,
                                                             ((SyntaxTree *) $3)->ozTex);
               free(((SyntaxTree *) $1)->ozTex);
               free(((SyntaxTree *) $3)->ozTex);

               free($2);
            }
          ;

if_parallel_hdr: TOK_OIF_PAR expr TOK_CIF_PAR TOK_OCURLY
                 {
                    if(!pushSymStack(0, &yyerror))
                    {
                       yyuerror("Unable to push stack for replicated interface parallel composition");

                       exit(-1);
                    }

                    if(!isEventSetExpr($2))
                    {
                       yyuerror("Interface is not an event set expression");
                    }

                    $$ = createReplProcNode(IF_PARALLEL, NULL, NULL, NULL);

                    ((ReplProcNode *) $$)->ifAlph = $2;
                    ((SyntaxTree *) $$)->ozTex    =
                          foztex("%s\\ifparrepl{%s%s}%s(", $1, ((SyntaxTree *) $2)->ozTex,
                                                           $3, $4);

                    free($1);
                    free(((SyntaxTree *) $2)->ozTex);
                    free($3);
                    free($4);
                 }

if_parallel_sch: if_parallel_hdr psdecl_list1 TOK_QUEST pred_list0 TOK_AT
                 {
                    if(!pushSymStack(0, &yyerror))
                    {
                       yyuerror("Unable to push stack for sub-process");

                       exit(-1);
                    }

                    $$ = $1;

                    INT8  *tmpTex   = ((SyntaxTree *) $1)->ozTex;
                    INT8  *declList = list2oz($2, "", "", "");
                    INT8  *predList = list2oz($4, "", "|", "");

                    ((ReplProcNode *) $$)->decls    = $2;
                    ((ReplProcNode *) $$)->filters  = $4;
                    ((ReplProcNode *) $$)->ozTex    = foztex("%s%s%s%s%s@", tmpTex, declList, $3, predList, $5);

                    free(tmpTex);
                    free(declList);
                    free($3);
                    free(predList);
                    free($5);
                 }
               ;

if_parallel: if_parallel_sch cspexp TOK_CCURLY %prec TOK_PROC_REPL
             {
                if(!popSymStack())
                {
                   yyuerror("Unable to pop stack for sub-process");

                   exit(-1);
                }

                if(!popSymStack())
                {
                   yyuerror("Unable to pop stack for replicated interface parallel composition");

                   exit(-1);
                }

                if(!isProcessExpr($2))
                {
                   yyuerror("Replicated expression is not a process expression");
                }

                $$ = $1;

                INT8  *tmpTex   = ((SyntaxTree *) $1)->ozTex;

                ((ReplProcNode *) $$)->expr     = $2;
                ((ReplProcNode *) $$)->treeType = createBasicTreeType("PROCESS");
                ((ReplProcNode *) $$)->ozTex    = foztex("%s%s%s)", tmpTex, ((SyntaxTree *) $2)->ozTex, $3);

                free(tmpTex);
                free(((SyntaxTree *) $2)->ozTex);
                free($3);
             }
           | cspexp TOK_OIF_PAR expr TOK_CIF_PAR cspexp %prec TOK_IF_PARALLEL
             {
                $$ = handleFInOp($1, "[||]", $5);

                if(!isEventSetExpr($3))
                {
                   yyuerror("Interface is not an event set expression");
                }

                ((ExprOpNode *) $$)->qualifier = $3;
                ((SyntaxTree *) $$)->ozTex     =
                      foztex("%s%s\\mathrel{\\ifpar{%s}}%s%s", ((SyntaxTree *) $1)->ozTex, $2,
                                                               ((SyntaxTree *) $3)->ozTex, $4,
                                                               ((SyntaxTree *) $5)->ozTex);

                free(((SyntaxTree *) $1)->ozTex);
                free($2);
                free(((SyntaxTree *) $3)->ozTex);
                free($4);
                free(((SyntaxTree *) $5)->ozTex);
             }
           ;

interrupt: cspexp TOK_INTERRUPT cspexp
           {
              $$ = handleFInOp($1, "/\\", $3);

              ((SyntaxTree *) $$)->ozTex =
                    foztex("%s%s\\mathrel{\\triangle}%s", ((SyntaxTree *) $1)->ozTex, $2,
                                                          ((SyntaxTree *) $3)->ozTex);
              free(((SyntaxTree *) $1)->ozTex);
              free(((SyntaxTree *) $3)->ozTex);

              free($2);
           }
         ;

let_proc_hdr: TOK_LET TOK_OCURLY let_list TOK_AT
              {
                 if(!pushSymStack(0, &yyerror))
                 {
                    yyuerror("Unable to push stack for let process definition");

                    exit(-1);
                 }

                 $$ = createLetProcNode($3, NULL);

                 INT8  *declList = list2oz($3, "", "", "");

                 ((SyntaxTree *) $$)->ozTex = foztex("%s\\LET%s(%s%s@", $1, $2, declList, $4);

                 free($1);
                 free($2);
                 free(declList);
                 free($4);
              }
            ;

let_proc: let_proc_hdr cspexp TOK_CCURLY
          {
             if(!popSymStack())
             {
                yyuerror("Unable to pop stack for let process definition");

                exit(-1);
             }

             if(!popSymStack())
             {
                yyuerror("Unable to pop stack for let process");

                exit(-1);
             }

             $$ = $1;

             INT8  *tmpTex = ((SyntaxTree *) $$)->ozTex;

             ((LetProcNode *) $$)->expr    = $2;
             ((SyntaxTree *) $$)->treeType = getExprType($2);
             ((SyntaxTree *) $$)->ozTex    = foztex("%s%s%s)", tmpTex, ((SyntaxTree *) $2)->ozTex, $3);

             free(tmpTex);
             free(((SyntaxTree *) $2)->ozTex);
             free($3);
          }
        ;

all_words: TOK_WORD
           {
              $$ = $1;
           }
         | TOK_PROC_VAR
           {
              $$ = $1;
           }
         | TOK_PROC_FUNC
           {
              $$ = $1;
           }
         | TOK_GEN_PROC_FUNC
           {
              $$ = $1;
           }
         | TOK_EVENT
           {
              $$ = $1;
           }
         | TOK_PROCESS
           {
              $$ = $1;
           }
         | TOK_CHANNEL
           {
              $$ = $1;
           }
         | TOK_GEN_CHANNEL
           {
              $$ = $1;
           }
         | TOK_IDENT
           {
              $$ = $1;
           }
         | TOK_GEN_SYM
           {
              $$ = $1;
           }
         | TOK_VAR_BINDING
           {
              $$ = $1;
           }
         | TOK_DATA_TYPE
           {
              $$ = $1;
           }
         | TOK_SCH_NAME
           {
              $$ = $1;
           }
         | TOK_GEN_SCHEMA
           {
              $$ = $1;
           }
         | TOK_PAR_ID
           {
              $$ = $1;
           }
         | TOK_EXPR_FUNC
           {
              $$ = $1;
           }
         | TOK_PRED_FUNC
           {
              $$ = $1;
           }
         | TOK_P1FPRE
           {
              $$ = $1;
           }
         | TOK_P2FPRE
           {
              $$ = $1;
           }
         | TOK_P3FPRE
           {
              $$ = $1;
           }
         | TOK_P4FPRE
           {
              $$ = $1;
           }
         | TOK_P5FPRE
           {
              $$ = $1;
           }
         | TOK_P6FPRE
           {
              $$ = $1;
           }
         | TOK_P7FPRE
           {
              $$ = $1;
           }
         | TOK_P8FPRE
           {
              $$ = $1;
           }
         | TOK_P9FPRE
           {
              $$ = $1;
           }
         | TOK_P1FIN
           {
              $$ = $1;
           }
         | TOK_P2FIN
           {
              $$ = $1;
           }
         | TOK_P3FIN
           {
              $$ = $1;
           }
         | TOK_P4FIN
           {
              $$ = $1;
           }
         | TOK_P5FIN
           {
              $$ = $1;
           }
         | TOK_P6FIN
           {
              $$ = $1;
           }
         | TOK_P7FIN
           {
              $$ = $1;
           }
         | TOK_P8FIN
           {
              $$ = $1;
           }
         | TOK_P9FIN
           {
              $$ = $1;
           }
         | TOK_P1FPOST
           {
              $$ = $1;
           }
         | TOK_P2FPOST
           {
              $$ = $1;
           }
         | TOK_P3FPOST
           {
              $$ = $1;
           }
         | TOK_P4FPOST
           {
              $$ = $1;
           }
         | TOK_P5FPOST
           {
              $$ = $1;
           }
         | TOK_P6FPOST
           {
              $$ = $1;
           }
         | TOK_P7FPOST
           {
              $$ = $1;
           }
         | TOK_P8FPOST
           {
              $$ = $1;
           }
         | TOK_P9FPOST
           {
              $$ = $1;
           }
         | TOK_P1RPRE
           {
              $$ = $1;
           }
         | TOK_P2RPRE
           {
              $$ = $1;
           }
         | TOK_P3RPRE
           {
              $$ = $1;
           }
         | TOK_P4RPRE
           {
              $$ = $1;
           }
         | TOK_P5RPRE
           {
              $$ = $1;
           }
         | TOK_P6RPRE
           {
              $$ = $1;
           }
         | TOK_P7RPRE
           {
              $$ = $1;
           }
         | TOK_P8RPRE
           {
              $$ = $1;
           }
         | TOK_P9RPRE
           {
              $$ = $1;
           }
         | TOK_P1RIN
           {
              $$ = $1;
           }
         | TOK_P2RIN
           {
              $$ = $1;
           }
         | TOK_P3RIN
           {
              $$ = $1;
           }
         | TOK_P4RIN
           {
              $$ = $1;
           }
         | TOK_P5RIN
           {
              $$ = $1;
           }
         | TOK_P6RIN
           {
              $$ = $1;
           }
         | TOK_P7RIN
           {
              $$ = $1;
           }
         | TOK_P8RIN
           {
              $$ = $1;
           }
         | TOK_P9RIN
           {
              $$ = $1;
           }
         | TOK_P1RPOST
           {
              $$ = $1;
           }
         | TOK_P2RPOST
           {
              $$ = $1;
           }
         | TOK_P3RPOST
           {
              $$ = $1;
           }
         | TOK_P4RPOST
           {
              $$ = $1;
           }
         | TOK_P5RPOST
           {
              $$ = $1;
           }
         | TOK_P6RPOST
           {
              $$ = $1;
           }
         | TOK_P7RPOST
           {
              $$ = $1;
           }
         | TOK_P8RPOST
           {
              $$ = $1;
           }
         | TOK_P9RPOST
           {
              $$ = $1;
           }
         ;
%%
