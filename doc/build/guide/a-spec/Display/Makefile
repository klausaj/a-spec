ASPECC=a-specc
LAYER_SCRIPT=alayers.pl

BASE=../../../..

SRC=$(BASE)/a-spec/guide/Display/Display.as
SRC_DEP=$(BASE)/a-spec/guide/Display/*
DEST=$(BASE)/out/guide/a-spec/Display
LIB_DIR=$(BASE)/a-spec/guide
OZ=$(DEST)/Display.a.tex
OZ_LAYERS=$(DEST)/Display.a.layers
XML=$(DEST)/Display.as.xml
BZ_XML=$(DEST)/Display.as.xml.bz2
AST_DOT=$(DEST)/Display.as.dot
AST_SVG=$(DEST)/Display.as.svg
DEP=$(BASE)/out/guide/a-spec/a-spec.dep

all: $(OZ) $(BZ_XML)

$(BZ_XML): $(SRC_DEP)
	bzip2 -f $(XML)

$(OZ): $(SRC_DEP)
	mkdir -p $(DEST)
	$(ASPECC) -d $(AST_DOT) -o $(OZ) -x $(XML) -I $(LIB_DIR) $(SRC)
	$(LAYER_SCRIPT) $(OZ) > $(OZ_LAYERS)
	touch $(DEP)

valgrind:
	mkdir -p $(DEST)
	valgrind $(ASPECC) -d $(AST_DOT) -o $(OZ) -x $(XML) -X $(EX_LAYERS) -I $(LIB_DIR) $(SRC)
	$(LAYER_SCRIPT) $(OZ) > $(OZ_LAYERS)
	touch $(DEP)

clean:
	rm -rf $(DEST)/*
