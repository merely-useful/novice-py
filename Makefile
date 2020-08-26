.PHONY : all clean chapters commands crossrefs fixme html links nbspref proposals settings tex-packages

ALL_HTML=_book/index.html
ALL_PDF=_book/novice-py.pdf
EXTRA=data

PY_NOVICE_FILES=\
  _bookdown.yml \
  index.Rmd \
  chapters/intro.Rmd \
  chapters/getting-started.Rmd \
  chapters/data-manipulation.Rmd \
  chapters/development.Rmd \
  chapters/objectives.Rmd \
  chapters/publishing.Rmd \
  chapters/keypoints.Rmd \
  chapters/version-control.Rmd

COMMON_FILES=\
  _common.R \
  appendix.Rmd \
  LICENSE.md \
  CONDUCT.md \
  CONTRIBUTING.md \
  gloss.md \
  references.Rmd \
  links.md \
  book.bib \
  preamble.tex

#-------------------------------------------------------------------------------

all : commands

## commands : show all commands.
commands :
	@grep -h -E '^##' ${MAKEFILE_LIST} | sed -e 's/## //g' | column -t -s ':'

## everything : rebuild all HTML and PDF.
everything : ${ALL_HTML} ${ALL_PDF}

#-------------------------------------------------------------------------------

## html           : build all HTML versions.
html : ${ALL_HTML}

_book/index.html : ${PY_NOVICE_FILES} ${COMMON_FILES}
	rm -f novice-py.Rmd
	Rscript -e "bookdown::render_book(input='index.Rmd', output_format='bookdown::gitbook'); warnings()"
	cp -r ${EXTRA} _book

#-------------------------------------------------------------------------------

## pdf : build PDF version.
pdf : ${ALL_PDF}

_book/novice-py.pdf : ${PY_FILES} ${COMMON_FILES}
	rm -f novice-py.Rmd
	Rscript -e "bookdown::render_book(input='index.Rmd', output_format='bookdown::pdf_book'); warnings()"

#-------------------------------------------------------------------------------

## clean : clean up generated files.
clean :
	@rm -rf _book _bookdown_files
	@rm -f *.aux *.lof *.log *.lot *.out *.toc
	@find . -name '*~' -exec rm {} \;

## chapters : check consistency of chapters.
chapters :
	@make settings | bin/chapters.py _bookdown.yml ${PY_NOVICE_FILES}

## crossrefs : check cross-references.
crossrefs :
	@bin/crossrefs.py "NOVICE PY" ${PY_NOVICE_FILES} ${COMMON_FILES}

## fixme : list all the FIXME markers
fixme :
	@fgrep FIXME ${PY_NOVICE_FILES} ${COMMON_FILES}

## images : check that all images are defined and used.
images :
	@bin/images.py ./figures ${PY_NOVICE_FILES} ${COMMON_FILES}

## links : check that links and glossary entries are defined and used.
links :
	@bin/links.py ./links.md ./gloss.md ${PY_NOVICE_FILES} ${COMMON_FILES}

## exercises : check that exercises have solutions and solutions have exercises.
exercises :
	@bin/exercises.py ${PY_NOVICE_FILES}

## nbspref : check that all cross-references are prefixed with a non-breaking space.
nbspref :
	@bin/nbspref.py ${PY_NOVICE_FILES} ${COMMON_FILES}

## proposals : regenerate PDFs of proposals.
proposals :
	pandoc -o manning/manning-proposal-2020-07.pdf manning/manning-proposal-2020-07.md
	pandoc -o taylor-francis/taylor-francis-proposal-2020-07.pdf taylor-francis/taylor-francis-proposal-2020-07.md

## settings : echo all variable values.
settings :
	@echo ALL_HTML: ${ALL_HTML}
	@echo ALL_PDF: ${ALL_PDF}
	@echo PY_NOVICE_FILES: ${PY_NOVICE_FILES}
	@echo COMMON_FILES: ${COMMON_FILES}

## tex-packages : install required LaTeX packages.
tex-packages :
	-tlmgr install $$(cat ./tex-packages.txt)
