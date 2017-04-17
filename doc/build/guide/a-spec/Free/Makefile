ASPECC=a-specc
LAYER_SCRIPT=alayers.pl

BASE=../../../..

SRC=$(BASE)/a-spec/guide/Free/Free.as
SRC_DEP=$(BASE)/a-spec/guide/Free/*
DEST=$(BASE)/out/guide/a-spec/Free
LIB_DIR=$(BASE)/a-spec/guide
OZ=$(DEST)/Free.a.tex
OZ_LAYERS=$(DEST)/Free.a.layers
XML=$(DEST)/Free.as.xml
BZ_XML=$(DEST)/Free.as.xml.bz2
AST_DOT=$(DEST)/Free.as.dot
AST_SVG=$(DEST)/Free.as.svg
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
