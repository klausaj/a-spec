ASPECC=a-specc
LAYER_SCRIPT=alayers.pl

BASE=../../../..

SRC=$(BASE)/a-spec/guide/Basic/Basic.as
SRC_DEP=$(BASE)/a-spec/guide/Basic/*
DEST=$(BASE)/out/guide/a-spec/Basic
LIB_DIR=$(BASE)/a-spec/guide
OZ=$(DEST)/Basic.a.tex
OZ_LAYERS=$(DEST)/Basic.a.layers
XML=$(DEST)/Basic.as.xml
BZ_XML=$(DEST)/Basic.as.xml.bz2
AST_DOT=$(DEST)/Basic.as.dot
AST_SVG=$(DEST)/Basic.as.svg
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
