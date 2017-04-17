#*******************************************************************************
#*  Copyright (c) 2009, A-Spec Project                                         *
#*  All rights reserved.                                                       *
#*                                                                             *
#*  Redistribution and use in source and binary forms, with or without         *
#*  modification, are permitted provided that the following conditions         *
#*  are met:                                                                   *
#*      - Redistributions of source code must retain the above copyright       *
#*        notice, this list of conditions and the following disclaimer.        *
#*      - Redistributions in binary form must reproduce the above copyright    *
#*        notice, this list of conditions and the following disclaimer in the  *
#*        documentation and/or other materials provided with the distribution. *
#*      - Neither the name of the A-Spec Project nor the names of its          *
#*        contributors may be used to endorse or promote products derived from *
#*        this software without specific prior written permission.             *
#*                                                                             *
#*  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS        *
#*  "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED  *
#*  TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR *
#*  PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR          *
#*  CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,      *
#*  EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,        *
#*  PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR         *
#*  PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF     *
#*  LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING       *
#*  NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS         *
#*  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.               *
#*******************************************************************************

BASE_DIR=$(shell pwd)/../../..

BISON_SRC=$(BASE_DIR)/src/grammar/a-spec.y
BISON_H=$(BASE_DIR)/include/grammar/a-spec.tab.h
BISON_C=$(BASE_DIR)/src/grammar/a-spec.tab.c
BISON_H_SRC=$(BASE_DIR)/src/grammar/a-spec.tab.h
BISON_GRAPH=./a-spec.dot
BISON_REPORT=./a-spec.report

FLEX_SRC=$(BASE_DIR)/src/grammar/a-spec.l
FLEX_C=$(BASE_DIR)/src/grammar/a-spec.lex.c

ASPECC_INC=$(shell ls $(BASE_DIR)/include/a-specc/*)

A_PARSER_OBJ=$(BASE_DIR)/build/mingw/lib/grammar/a-parser.o
A_LEXER_OBJ=$(BASE_DIR)/build/mingw/lib/grammar/a-lexer.o

all: $(A_PARSER_OBJ) $(A_LEXER_OBJ)

$(A_PARSER_OBJ): $(BISON_C) $(ASPECC_INC)
	gcc -c -Wall -D_GNU_SOURCE -I$(BASE_DIR)/include -o $(A_PARSER_OBJ) $(BISON_C)

$(A_LEXER_OBJ): $(FLEX_C) $(ASPECC_INC)
	gcc -c -Wall -D_GNU_SOURCE -I$(BASE_DIR)/include -o $(A_LEXER_OBJ) $(FLEX_C)

$(BISON_C): $(BISON_SRC)
	bison --output=$(BISON_C) --defines $(BISON_SRC)
	mv  $(BISON_H_SRC) $(BISON_H)

$(FLEX_C): $(FLEX_SRC) $(BISON_H)
	flex -o$(FLEX_C) $(FLEX_SRC)

debug:
	bison --graph=$(BISON_GRAPH) --output=$(BISON_C) --defines --report=solved --report-file=$(BISON_REPORT) $(BISON_SRC)
	mv  $(BISON_H_SRC) $(BISON_H)
	flex -p -p -o$(FLEX_C) $(FLEX_SRC)
	gcc -c -Wall -D_GNU_SOURCE -DDO_DEBUG=1 -I$(BASE_DIR)/include -g -o $(A_PARSER_OBJ) $(BISON_C)
	gcc -c -Wall -D_GNU_SOURCE -DDO_DEBUG=1 -I$(BASE_DIR)/include -g -o $(A_LEXER_OBJ) $(FLEX_C)

valgrind:
	bison --graph=$(BISON_GRAPH) --output=$(BISON_C) --defines --report=solved --report-file=$(BISON_REPORT) $(BISON_SRC)
	mv  $(BISON_H_SRC) $(BISON_H)
	flex -p -p -o$(FLEX_C) $(FLEX_SRC)
	gcc -c -Wall -D_GNU_SOURCE -I$(BASE_DIR)/include -g -o $(A_PARSER_OBJ) $(BISON_C)
	gcc -c -Wall -D_GNU_SOURCE -I$(BASE_DIR)/include -g -o $(A_LEXER_OBJ) $(FLEX_C)

clean:
	rm -f $(BISON_GRAPH) $(BISON_REPORT) $(BISON_H) $(BISON_C) $(FLEX_C) $(A_PARSER_OBJ) $(A_LEXER_OBJ)
