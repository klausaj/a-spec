ASPECC=a-specc
LAYER_SCRIPT=alayers.pl

BASE=../../../..

SRC=$(BASE)/a-spec/guide/ProcChoiceEquiv/ProcChoiceEquiv.as
SRC_DEP=$(BASE)/a-spec/guide/ProcChoiceEquiv/*
DEST=$(BASE)/out/guide/a-spec/ProcChoiceEquiv
LIB_DIR=$(BASE)/a-spec/guide
OZ=$(DEST)/ProcChoiceEquiv.a.tex
OZ_LAYERS=$(DEST)/ProcChoiceEquiv.a.layers
XML=$(DEST)/ProcChoiceEquiv.as.xml
BZ_XML=$(DEST)/ProcChoiceEquiv.as.xml.bz2
AST_DOT=$(DEST)/ProcChoiceEquiv.as.dot
AST_SVG=$(DEST)/ProcChoiceEquiv.as.svg
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
