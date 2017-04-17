DOCUMENT = a_guide

###########################################################################
###########################################################################

all: $(DOCUMENT).pdf

$(DOCUMENT).dvi: ../../../tex/guide/$(DOCUMENT).tex ../../../out/guide/a-spec/a-spec.dep
	texi2dvi -q -I ../../../tex ../../../tex/guide/$(DOCUMENT).tex

$(DOCUMENT).pdf: $(DOCUMENT).dvi
	dvipdf $(DOCUMENT).dvi
	mkdir -p ../../../out/tex
	cp -f $(DOCUMENT).pdf ../../../out/tex
	cp -f $(DOCUMENT).dvi ../../../out/tex

clean:
	rm -f   $(DOCUMENT).aux \
		$(DOCUMENT).toc \
		$(DOCUMENT).log \
		$(DOCUMENT).dvi \
		$(DOCUMENT).pdf \
		$(DOCUMENT).lot \
		$(DOCUMENT).lof \
		../../../out/tex/$(DOCUMENT).dvi \
		../../../out/tex/$(DOCUMENT).pdf \
