#!/bin/bash
export MBUFR_TABLES=../../bufrtables

#--------------------------------------------
# Encode daycli message im BUFR from text file
#----------------------------------------------
../../bin/daycli_encoder1 -i ./DAYCLI_82191.txt -o ./DAYCLI_sample_82191.bufr
../../bin/daycli_encoder1 -i ./DAYCLI_MF_0-20000-0-71805_202204.txt -o ./DAYCLI_MF_0-20000-0-71805_202204.bufr
#-------------------------------------------------------------
# Decode DAYCLI message from BUFR to text file (using bufrdump)
#--------------------------------------------------------------
../../bin/daycli_decoder -i ./DAYCLI_sample_82191.bufr -o ./DAYCLI_sample_82191.format2.txt
../../bin/daycli_decoder -i ./DAYCLI_MF_0-20000-0-71805_202204.bufr -o ./DAYCLI_MF_0-20000-0-71805_202204.formato2.txt
../../bin/bufrdump -i ./DAYCLI_sample_82191.bufr -o DAYCLI_sample_82191.bufr.decoded.txt
../../bin/bufrdump -i ./DAYCLI_MF_0-20000-0-71805_202204.bufr -o ./DAYCLI_MF_0-20000-0-71805_202204.bufr.decoded.txt

