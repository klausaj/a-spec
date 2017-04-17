DOCUMENT = a_grammar

all: doc

###########################################################################
###########################################################################

$(DOCUMENT).dvi: ../../../tex/grammar/$(DOCUMENT).tex
	texi2dvi -q -I ../../../tex ../../../tex/grammar/$(DOCUMENT).tex

$(DOCUMENT).pdf: $(DOCUMENT).dvi
	dvipdf $(DOCUMENT).dvi

doc: $(DOCUMENT).pdf
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


