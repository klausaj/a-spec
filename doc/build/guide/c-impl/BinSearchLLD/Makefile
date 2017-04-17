BASE=../../../..

SRC=$(BASE)/c-impl/guide/BinSearchLLD/BinSearchLLD.c $(BASE)/c-impl/guide/BinSearchLLD/BinSearchMain.c
DEST=$(BASE)/out/guide/c-impl/BinSearchLLD
OUT=$(DEST)/BinSearchLLD

.PHONY: all clean

all: $(OUT)

$(OUT): $(SRC)
	mkdir -p $(DEST)
	gcc -g $(SRC) -o $(OUT)

clean:
	rm -rf $(DEST)/*
