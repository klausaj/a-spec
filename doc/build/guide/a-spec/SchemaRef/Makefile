ASPECC=a-specc
LAYER_SCRIPT=alayers.pl

BASE=../../../..

SRC=$(BASE)/a-spec/guide/SchemaRef/SchemaRef.as
SRC_DEP=$(BASE)/a-spec/guide/SchemaRef/*
DEST=$(BASE)/out/guide/a-spec/SchemaRef
LIB_DIR=$(BASE)/a-spec/guide
OZ=$(DEST)/SchemaRef.a.tex
OZ_LAYERS=$(DEST)/SchemaRef.a.layers
XML=$(DEST)/SchemaRef.as.xml
BZ_XML=$(DEST)/SchemaRef.as.xml.bz2
AST_DOT=$(DEST)/SchemaRef.as.dot
AST_SVG=$(DEST)/SchemaRef.as.svg
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
