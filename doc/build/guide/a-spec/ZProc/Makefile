ASPECC=a-specc
LAYER_SCRIPT=alayers.pl

BASE=../../../..

SRC=$(BASE)/a-spec/guide/ZProc/ZProc.as
SRC_DEP=$(BASE)/a-spec/guide/ZProc/*
DEST=$(BASE)/out/guide/a-spec/ZProc
LIB_DIR=$(BASE)/a-spec/guide
OZ=$(DEST)/ZProc.a.tex
OZ_LAYERS=$(DEST)/ZProc.a.layers
XML=$(DEST)/ZProc.as.xml
BZ_XML=$(DEST)/ZProc.as.xml.bz2
AST_DOT=$(DEST)/ZProc.as.dot
AST_SVG=$(DEST)/ZProc.as.svg
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
