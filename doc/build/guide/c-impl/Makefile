BASE=`pwd`/../../..

DEST=$(BASE)/out/guide/c-impl
DIRS=BinSearchLLD

.PHONY: sub clean $(DIRS)

sub:	$(DIRS)

$(DIRS):
	make -C $@

clean:
	rm -rf $(DEST)/*
