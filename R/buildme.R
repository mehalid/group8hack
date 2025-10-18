# buildme.R

# A script to build your package

# set working directory to package root
setwd("/cloud/project")

# Unload your package and uninstall it first.
unloadNamespace("Group8hack"); remove.packages("Group8hack")

# Auto-document your package, turning roxygen comments into manuals in the `/man` folder
devtools::document(".")
# Load your package temporarily!
devtools::load_all(".")


# Test out our functions
# Group8hack::DataDistrubition(x = c(1,5,7,12)) #CHANGE THIS--------

# When finished, remember to unload the package
unloadNamespace("Group8hack")

# Then, when ready, document, unload, build, and install the package!
# For speedy build, use binary = FALSE and vignettes = FALSE
devtools::document("."); # document the package
unloadNamespace("Group8hack"); # unload the package

# Build the package
devtools::build(pkg = ".", path = getwd(), binary = FALSE, vignettes = FALSE)


# Restart R
rstudioapi::restartSession()

# Install your package from a local build file
# such as 
# install.packages("nameofyourpackagefile.tar.gz", type = "source")
# or in our case:
install.packages("Group8hack_1.0.tar.gz", type = "source") #CHANGE THIS--------


# Load your package!
library("Group8hack")


# When finished, remember to unload the package
unloadNamespace("Group8hack"); remove.packages("Group8hack")

# Always a good idea to clear your environment and cache
rm(list = ls()); gc()
