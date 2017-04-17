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

#ifndef a_specc_h
#define a_specc_h

/************** Headers **************/
#include "a-specc/a-specc_api.h"
#include "a-specc/a-specc_types.h"
#include "grammar/a-spec.tab.h"


/************** Defines **************/
#define MIN_SYM_TYPE_NUM  258
#define SYM_TABLE_SIZE    6


/************** Basic Types **************/


/************** Structures **************/


/************** Global Vars **************/
SymListStack  *symStack     = NULL;
SymbolList    *globalTable  = NULL;
LinkList      *importList   = NULL;
LinkList      *importPaths  = NULL;
LinkList      *symStackList = NULL;
ADocNode      *docAST       = NULL;

INT8   lineBuf[LINE_BUF_SIZE];

UINT32  fmtSize    = 0;
UINT16  acceptLen  = 0;
UINT16  prevLen    = 0;
UINT16  curLen     = 0;
UINT8   errors     = 0;
INT8    *curFile   = NULL;
INT8    *curFmt    = NULL;
INT8    *outLayers = NULL;
INT8    *exLayers  = NULL;
UINT8   tmpCh      = 0;
UINT8   a2OzTex    = 0;
UINT8   a2ATex     = 0;
UINT8   aTabGroup  = 5;
UINT8   aIndent    = 3;
UINT8   xmlIndent  = 3;
UINT8   exportType = 0;
UINT8   maxErrors  = 10;

/************** Functions **************/
void aDocToDOT(ADocNode *ast, INT8 *outPath);
void aDocToXML(ADocNode *ast, INT8 *outPath);

#endif /* a_specc_h */
