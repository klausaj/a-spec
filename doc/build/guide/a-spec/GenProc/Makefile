ASPECC=a-specc
LAYER_SCRIPT=alayers.pl

BASE=../../../..

SRC=$(BASE)/a-spec/guide/GenProc/GenProc.as
SRC_DEP=$(BASE)/a-spec/guide/GenProc/*
DEST=$(BASE)/out/guide/a-spec/GenProc
LIB_DIR=$(BASE)/a-spec/guide
OZ=$(DEST)/GenProc.a.tex
OZ_LAYERS=$(DEST)/GenProc.a.layers
XML=$(DEST)/GenProc.as.xml
BZ_XML=$(DEST)/GenProc.as.xml.bz2
AST_DOT=$(DEST)/GenProc.as.dot
AST_SVG=$(DEST)/GenProc.as.svg
EX_LAYERS=toolkitlib
DEP=$(BASE)/out/guide/a-spec/a-spec.dep

all: $(OZ) $(BZ_XML)

$(BZ_XML): $(SRC_DEP)
	bzip2 -f $(XML)

$(OZ): $(SRC_DEP)
	mkdir -p $(DEST)
	$(ASPECC) -d $(AST_DOT) -o $(OZ) -x $(XML) -X $(EX_LAYERS) -I $(LIB_DIR) $(SRC)
	$(LAYER_SCRIPT) $(OZ) > $(OZ_LAYERS)
	touch $(DEP)

valgrind:
	mkdir -p $(DEST)
	valgrind $(ASPECC) -d $(AST_DOT) -o $(OZ) -x $(XML) -X $(EX_LAYERS) -I $(LIB_DIR) $(SRC)
	$(LAYER_SCRIPT) $(OZ) > $(OZ_LAYERS)
	touch $(DEP)

clean:
	rm -rf $(DEST)/*
