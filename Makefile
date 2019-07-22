render:
	Rscript -e 'Sys.setenv("RSTUDIO_PANDOC" = "/Applications/RStudio.app/Contents/MacOS/pandoc"); rmarkdown::render("$(file).Rmd", output_file = "$(file).html")'

open:
	open $(file).html

deploy:
	zsh deploy.sh
