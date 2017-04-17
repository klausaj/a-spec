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

ARCH_DIR=$(BASE_DIR)/src/arch/mingw

ARCH_INC=$(shell ls $(BASE_DIR)/include/arch/mingw/*)

ARCH_OBJ=$(BASE_DIR)/build/mingw/lib/arch/mingw.o

ARCH_SRC=$(ARCH_DIR)/a-spec_mingw.c
ARCH_DEP=$(ARCH_SRC) $(ARCH_INC)

all: $(ARCH_OBJ)

$(ARCH_OBJ): $(ARCH_DEP)
	gcc -Wall -c -D_GNU_SOURCE -I$(BASE_DIR)/include -o $(ARCH_OBJ) $(ARCH_SRC)

debug: $(ARCH_DEP)
	gcc -Wall -c -D_GNU_SOURCE -I$(BASE_DIR)/include -o $(ARCH_OBJ) -g -DDO_DEBUG=1 $(ARCH_SRC)

valgrind: $(ARCH_DEP)
	gcc -Wall -c -D_GNU_SOURCE -I$(BASE_DIR)/include -o $(ARCH_OBJ) -g $(ARCH_SRC)

clean:
	rm -f $(ARCH_OBJ)
