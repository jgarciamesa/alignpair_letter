FIGS = fig-fst-base-calling-new.pdf fig-aln.pdf fig-fst-coati.pdf
TABS = $(addprefix figures/, table-comp.tex)
SCRIPTS = $(addprefix supplementary_materials/scripts/, kaks.R number_alignments.R plot_dseq.R)
PLOT_DATA = tri-mg tri-ecm mar-mg mar-ecm

default: all

all: alignpair_letter.pdf response_r1.pdf supplementary_materials/supplementary_materials.pdf

.PHONY: all default

alignpair_letter.pdf: alignpair_letter.tex alignpair_letter.bib $(TABS) mbe.bst
	latexmk -recorder -synctex=1 -lualatex $<

alignpair_letter.pdf: $(addprefix figures/, $(FIGS))

figures/fig-%.pdf: figures/fig-%.tex
	latexmk -cd -lualatex $<

figures/fig-%.pdf: figures/fig-%.R
	Rscript --vanilla $<

ALIGNERS = clustalo macse mafft prank

supplementary_materials/data/%/plot_distance.csv: supplementary_materials/scripts/distance_pseudo.R
	@echo creating $@
	cd supplementary_materials && Rscript --vanilla scripts/distance_pseudo.R dseq $* $* $(ALIGNERS)

supplementary_materials/supplementary_materials.pdf: supplementary_materials/supplementary_materials.Rmd figures/fig-base-calling-error.pdf
	cd supplementary_materials && Rscript -e "rmarkdown::render('supplementary_materials.Rmd')"

supplementary_materials/supplementary_materials.pdf: $(addprefix supplementary_materials/data/,$(addsuffix /plot_distance.csv, $(PLOT_DATA)))

response_r1.pdf: response_r1.md
	pandoc --pdf-engine=lualatex -o $@ $<

clean:
	@rm -f *.{aux,log,fdb_latexmk,fls,bbl,bcf,blg,run.xml,out}
	@rm -f figures/*.{aux,log,fdb_latexmk,fls,bbl,bcf,blg,run.xml,out}
