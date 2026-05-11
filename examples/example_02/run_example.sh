#!/bin/bash
export MBUFR_TABLES=../../bufrtables


#--------------------------------------------
# Encode daycli message in BUFR from text file
#----------------------------------------------
../../bin/daycli_encoder2 -i DAYCLI_MF_0-20000-0-71805_202204_f2.txt -o ./DAYCLI_MF_0-20000-0-71805_202204.bufr

#----------------------------------------------------------------
# decode daycli message back to text file (using daycli_decoder)
#----------------------------------------------------------------
../../bin/daycli_decoder -i ./DAYCLI_MF_0-20000-0-71805_202204.bufr -o decoded_output1.txt
#-------------------------------------------------------------
# Decode DAYCLI message from BUFR to text file (using bufrdump)
#--------------------------------------------------------------
../../bin/bufrdump -i ./DAYCLI_MF_0-20000-0-71805_202204.bufr -o decoded_output2.txt
