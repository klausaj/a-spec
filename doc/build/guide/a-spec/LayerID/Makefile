ASPECC=a-specc
LAYER_SCRIPT=alayers.pl

BASE=../../../..

SRC=$(BASE)/a-spec/guide/LayerID/LayerID.as
SRC_DEP=$(BASE)/a-spec/guide/LayerID/*
DEST=$(BASE)/out/guide/a-spec/LayerID
LIB_DIR=$(BASE)/a-spec/guide
OZ=$(DEST)/LayerID.a.tex
OZ_LAYERS=$(DEST)/LayerID.a.layers
XML=$(DEST)/LayerID.as.xml
BZ_XML=$(DEST)/LayerID.as.xml.bz2
AST_DOT=$(DEST)/LayerID.as.dot
AST_SVG=$(DEST)/LayerID.as.svg
EX_LAYERS=toolkitlib,hidden
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
