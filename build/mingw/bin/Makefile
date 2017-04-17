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

LIB_DIR=$(BASE_DIR)/build/mingw/lib

ASPECC_OBJS=$(shell ls $(LIB_DIR)/a-specc/*.o)
A_TRANS_OBJS=$(shell ls $(LIB_DIR)/a-translate/*.o)
A_GRAMMAR_OBJS=$(shell ls $(LIB_DIR)/grammar/*.o)
ARCH_OBJS=$(shell ls $(LIB_DIR)/arch/*.o)

ALL_OBJS=$(ARCH_OBJS) $(A_GRAMMAR_OBJS) $(ASPECC_OBJS) $(A_TRANS_OBJS)

ASPEC_BIN=$(BASE_DIR)/build/mingw/bin/a-specc

A_LIB_SRC_PATH=$(BASE_DIR)/library
A_SCRIPT_SRC_PATH=$(BASE_DIR)/scripts

INSTALL_PATH=/usr/local/a-spec
LIB_PATH=$(INSTALL_PATH)/lib
SCRIPT_PATH=$(INSTALL_PATH)/scripts
BIN_PATH=$(INSTALL_PATH)/bin
BIN_FILE=$(BIN_PATH)/a-specc

all: $(ASPEC_BIN)

install: $(BIN_FILE)

$(BIN_FILE): $(ASPEC_BIN)
	mkdir -p $(BIN_PATH)
	mkdir -p $(LIB_PATH)
	mkdir -p $(SCRIPT_PATH)
	cp -a $(A_LIB_SRC_PATH)/* $(LIB_PATH)
	cp $(A_SCRIPT_SRC_PATH)/* $(SCRIPT_PATH)
	cp $(ASPEC_BIN) $(BIN_FILE)
	chmod a+x $(SCRIPT_PATH)/*
	ln -sf /usr/local/a-spec/bin/a-specc /usr/local/bin/a-specc
	ln -sf /usr/local/a-spec/scripts/* /usr/local/bin/

$(ASPEC_BIN): $(ALL_OBJS)
	gcc -Wall -D_GNU_SOURCE -I$(BASE_DIR)/include $(ALL_OBJS) -o $(ASPEC_BIN)

debug:
	gcc -Wall -D_GNU_SOURCE -I$(BASE_DIR)/include $(ALL_OBJS) -o $(ASPEC_BIN) -g -DDO_DEBUG=1

valgrind:
	gcc -Wall -D_GNU_SOURCE -I$(BASE_DIR)/include $(ALL_OBJS) -o $(ASPEC_BIN) -g

clean:
	rm -f $(ASPEC_BIN)
