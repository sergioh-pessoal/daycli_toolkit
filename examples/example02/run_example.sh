#!/bin/bash
export MBUFR_TABLES=../../bufrtables


#--------------------------------------------
# Encode daycli message im BUFR from text file
#----------------------------------------------
../../bin/daycli_encoder2 -i ./DAYCLI_MF_0-20000-0-71805_202204_INPUT_2.txt -o ./DAYCLI_MF_0-20000-0-71805_202204.bufr
#-------------------------------------------------------------
# Decode DAYCLI message from BUFR to text file (using bufrdump)
#--------------------------------------------------------------
../../bin/bufrdump -i ./DAYCLI_MF_0-20000-0-71805_202204.bufr -o ./DAYCLI_MF_0-20000-0-71805_202204.bufr.decoded.txt

