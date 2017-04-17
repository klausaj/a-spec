ASPECC=a-specc
LAYER_SCRIPT=alayers.pl

BASE=../../../..

SRC=$(BASE)/a-spec/guide/ReplInterleave/ReplInterleave.as
SRC_DEP=$(BASE)/a-spec/guide/ReplInterleave/*
DEST=$(BASE)/out/guide/a-spec/ReplInterleave
LIB_DIR=$(BASE)/a-spec/guide
OZ=$(DEST)/ReplInterleave.a.tex
OZ_LAYERS=$(DEST)/ReplInterleave.a.layers
XML=$(DEST)/ReplInterleave.as.xml
BZ_XML=$(DEST)/ReplInterleave.as.xml.bz2
AST_DOT=$(DEST)/ReplInterleave.as.dot
AST_SVG=$(DEST)/ReplInterleave.as.svg
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
