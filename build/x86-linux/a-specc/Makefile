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

BISON_H=$(BASE_DIR)/include/grammar/a-spec.tab.h
BISON_C=$(BASE_DIR)/src/grammar/a-spec.tab.c

FLEX_C=$(BASE_DIR)/src/grammar/a-spec.lex.c

ASPEC_DIR=$(BASE_DIR)/src/a-specc
LIB_DIR=$(BASE_DIR)/build/x86-linux/lib

ASPECC_INC=$(shell ls $(BASE_DIR)/include/a-specc/*)

ASPECC_OBJ=$(BASE_DIR)/build/x86-linux/lib/a-specc/a-specc.o
ASPECC_AST_OBJ=$(BASE_DIR)/build/x86-linux/lib/a-specc/a-specc_ast.o
ASPECC_DOT_OBJ=$(BASE_DIR)/build/x86-linux/lib/a-specc/a-specc_dot.o
ASPECC_XML_OBJ=$(BASE_DIR)/build/x86-linux/lib/a-specc/a-specc_xml.o

ASPECC_SRC=$(ASPEC_DIR)/a-specc.c
ASPECC_AST_SRC=$(ASPEC_DIR)/a-specc_ast.c
ASPECC_DOT_SRC=$(ASPEC_DIR)/a-specc_dot.c
ASPECC_XML_SRC=$(ASPEC_DIR)/a-specc_xml.c

ASPECC_DEP=$(ASPECC_SRC) $(ASPECC_INC)
ASPECC_AST_DEP=$(ASPECC_AST_SRC) $(ASPECC_INC)
ASPECC_DOT_DEP=$(ASPEC_DOT_SRC) $(ASPECC_INC)
ASPECC_XML_DEP=$(ASPEC_XML_SRC) $(ASPECC_INC)

INSTALL_PATH=/usr/local/a-spec
LIB_PATH=$(INSTALL_PATH)/lib
ALIB_PATH=\"$(LIB_PATH)\"

all: $(ASPECC_OBJ) $(ASPECC_AST_OBJ) $(ASPECC_DOT_OBJ) $(ASPECC_XML_OBJ)

$(ASPECC_OBJ): $(ASPECC_DEP)
	gcc -c -Wall -D_GNU_SOURCE -DALIB_PATH="$(ALIB_PATH)" -I$(BASE_DIR)/include -o $(ASPECC_OBJ) $(ASPECC_SRC)

$(ASPECC_AST_OBJ): $(ASPECC_AST_DEP)
	gcc -c -Wall -D_GNU_SOURCE -I$(BASE_DIR)/include -o $(ASPECC_AST_OBJ) $(ASPECC_AST_SRC)

$(ASPECC_DOT_OBJ): $(ASPECC_DOT_DEP)
	gcc -c -Wall -D_GNU_SOURCE -I$(BASE_DIR)/include -o $(ASPECC_DOT_OBJ) $(ASPECC_DOT_SRC)

$(ASPECC_XML_OBJ): $(ASPECC_XML_DEP)
	gcc -c -Wall -D_GNU_SOURCE -I$(BASE_DIR)/include -o $(ASPECC_XML_OBJ) $(ASPECC_XML_SRC)

debug: $(ASPECC_DEP) $(ASPECC_AST_DEP) $(ASPECC_DOT_DEP) $(ASPECC_XML_DEP)
	gcc -c -Wall -D_GNU_SOURCE -DALIB_PATH="$(ALIB_PATH)" -I$(BASE_DIR)/include -o $(ASPECC_OBJ) -g -DDO_DEBUG=1 $(ASPECC_SRC)
	gcc -c -Wall -D_GNU_SOURCE -I$(BASE_DIR)/include -o $(ASPECC_AST_OBJ) -g -DDO_DEBUG=1 $(ASPECC_AST_SRC)
	gcc -c -Wall -D_GNU_SOURCE -I$(BASE_DIR)/include -o $(ASPECC_DOT_OBJ) -g -DDO_DEBUG=1 $(ASPECC_DOT_SRC)
	gcc -c -Wall -D_GNU_SOURCE -I$(BASE_DIR)/include -o $(ASPECC_XML_OBJ) -g -DDO_DEBUG=1 $(ASPECC_XML_SRC)

valgrind: $(ASPECC_DEP) $(ASPECC_AST_DEP) $(ASPECC_DOT_DEP) $(ASPECC_XML_DEP)
	gcc -c -Wall -D_GNU_SOURCE -DALIB_PATH="$(ALIB_PATH)" -I$(BASE_DIR)/include -o $(ASPECC_OBJ) -g  $(ASPECC_SRC)
	gcc -c -Wall -D_GNU_SOURCE -I$(BASE_DIR)/include -o $(ASPECC_AST_OBJ) -g  $(ASPECC_AST_SRC)
	gcc -c -Wall -D_GNU_SOURCE -I$(BASE_DIR)/include -o $(ASPECC_DOT_OBJ) -g  $(ASPECC_DOT_SRC)
	gcc -c -Wall -D_GNU_SOURCE -I$(BASE_DIR)/include -o $(ASPECC_XML_OBJ) -g  $(ASPECC_XML_SRC)

clean:
	rm -f $(ASPECC_OBJ) $(ASPECC_AST_OBJ) $(ASPECC_DOT_OBJ) $(ASPECC_XML_OBJ)
