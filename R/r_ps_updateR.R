# installing/loading the package:
if(!require(installr)) {
  install.packages("installr"); require(installr)} #load / install+load installr

# using the package:
# this will start the updating process of your R installation.  
# It will check for newer versions, and if one is available.
updateR() 

########--------------------------------------###############
# installing/loading the package:
#load / install+load installr
if(!require(installr)) { install.packages("installr"); require(installr)} 

# step by step functions:
check.for.updates.R() # tells you if there is a new version of R or not.
install.R() # download and run the latest R installer
copy.packages.between.libraries() 
# copy your packages to the newest R installation from the one version before it 
#(if ask=T, it will ask you between which two versions to perform the copying)