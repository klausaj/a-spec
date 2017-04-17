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

ATRAN_DIR=$(BASE_DIR)/src/a-translate

ASPECC_INC=$(shell ls $(BASE_DIR)/include/a-specc/*)
ATRAN_INC=$(shell ls $(BASE_DIR)/include/a-translate/*)

ATRAN_OBJ=$(BASE_DIR)/build/mingw/lib/a-translate/a-translate.o

ATRAN_SRC=$(ATRAN_DIR)/a2oztex.c
ATRAN_DEP=$(ATRAN_SRC) $(ASPECC_INC) $(ATRAN_INC)

all: $(ATRAN_OBJ)

$(ATRAN_OBJ): $(ATRAN_DEP)
	gcc -Wall -c -D_GNU_SOURCE -I$(BASE_DIR)/include -o $(ATRAN_OBJ) $(ATRAN_SRC)

debug: $(ATRAN_DEP)
	gcc -Wall -c -D_GNU_SOURCE -I$(BASE_DIR)/include -o $(ATRAN_OBJ) -g -DDO_DEBUG=1 $(ATRAN_SRC)

valgrind: $(ATRAN_DEP)
	gcc -Wall -c -D_GNU_SOURCE -I$(BASE_DIR)/include -o $(ATRAN_OBJ) -g $(ATRAN_SRC)

clean:
	rm -f $(ATRAN_OBJ)
