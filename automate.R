###############################################################################
# The following lines of code don't need to be run, except for the libraries used
###############################################################################


# install.packages("here")
# install.packages("tidyverse")
# install.packages("stringr")

library(here)
library(tidyverse)
library(stringr)

# delete unnecessary files
for(i in 1:63){
  unlink(here(paste0("slice_", i), "MF2K.exe"))
  unlink(here(paste0("slice_", i), paste0("slice_", i, ".bas")))
  unlink(here(paste0("slice_", i), paste0("slice_", i, ".bas")))
  unlink(here(paste0("slice_", i), paste0("slice_", i, ".chd")))
  unlink(here(paste0("slice_", i), paste0("slice_", i, ".ddn")))
  unlink(here(paste0("slice_", i), paste0("slice_", i, ".dis")))
  unlink(here(paste0("slice_", i), paste0("slice_", i, ".glo")))
  unlink(here(paste0("slice_", i), paste0("slice_", i, ".gmg")))
  unlink(here(paste0("slice_", i), paste0("slice_", i, ".hds")))
  unlink(here(paste0("slice_", i), paste0("slice_", i, ".lpf")))
  unlink(here(paste0("slice_", i), paste0("slice_", i, ".lst")))
  unlink(here(paste0("slice_", i), paste0("slice_", i, ".nam")))
  unlink(here(paste0("slice_", i), paste0("slice_", i, ".oc")))
  unlink(here(paste0("slice_", i), paste0("slice_", i, ".zone")))
}

# copy .cbb files into input
temp <- vector(length = 63)
for(i in 1:63){
  temp[i] = normalizePath(here(paste0("slice_", i), paste0("slice_", i, ".cbb")))
}

# copy all files into input/cbb
file.copy(temp, here("input","cbb"))


################################################################################
# Run the following lines of code to create system-specific model runs
################################################################################



# make input files
inp <- read_lines(here("input","rw3d_1_d1_r2.inp"))

for(i in 1:63){
  lines <- inp  %>% str_replace("slice_1", here("input", "cbb", paste0("slice_", i))) 
  write_lines(lines, here("input", "inp", paste0("slice_", i, ".inp")))
}


# make name files write files to new directories
other <- here("output","other")
btc <- here("output","btc")
cbtc <- here("output","cbtc")
part_evol <- here("output","part_evol")

nam <- read_lines(here("input","rw3d_1_d1_r2.nam"))

for(i in 1:63){
  lines <- nam %>% str_replace("rw3d_1_d1_r2", paste0("slice_", i)) %>% 
    str_replace("1_d1_r2", paste0("_slice_", i)) %>% 
    str_replace("rw3d", paste0("slice_",i,"_rw3d"))
  
  lines[1] <- here("input", "inp", paste0("slice_", i, ".inp")) # name file
  lines[2] <- paste0(btc, "/", lines[2]) # btc
  lines[3] <- paste0(cbtc, "/", lines[3]) # cbtc
  lines[4] <- paste0(part_evol, "/", lines[4]) # part_evol
  lines[c(5:17)] <- paste0(other, "/", lines[4]) # other
  
  write_lines(lines, here("input", "nam", paste0("slice_", i, ".nam")))
}


# run all slices 

for(i in 1:63){
  cmd_name <- here("RW3D.exe")
  name_file <- here("input", "nam", paste0("slice_", i, ".nam"))
  system2(cmd_name, args = name_file)
}


