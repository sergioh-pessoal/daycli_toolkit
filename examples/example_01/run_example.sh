#!/bin/bash
export MBUFR_TABLES=../../bufrtables

#-------------------------------------------------------
# Encode daycli message in BUFR from text file (Format1)
#--------------------------------------------------------
../../bin/daycli_encoder1 -i ./DAYCLI_82191_f1.txt -o ./DAYCLI_sample_82191.bufr
../../bin/daycli_encoder1 -i ./DAYCLI_MF_0-20000-0-71805_202204_f1.txt -o ./DAYCLI_MF_0-20000-0-71805_202204.bufr
#----------------------------------------------------------------------------
# Decode DAYCLI message from BUFR to text file using daycli_decoder (format2)
#---------------------------------------------------------------------------
../../bin/daycli_decoder -i ./DAYCLI_sample_82191.bufr -o ./DAYCLI_sample_82191.decoded.output1.txt
../../bin/daycli_decoder -i ./DAYCLI_MF_0-20000-0-71805_202204.bufr -o ./DAYCLI_MF_0-20000-0-71805_202204.decoded_output1.txt

#-------------------------------------------------------------
# Decode DAYCLI message from BUFR to text file using BUFRDUMP
#--------------------------------------------------------------
../../bin/bufrdump -i ./DAYCLI_sample_82191.bufr -o DAYCLI_sample_82191.decoded_output2.txt
../../bin/bufrdump -i ./DAYCLI_MF_0-20000-0-71805_202204.bufr -o ./DAYCLI_MF_0-20000-0-71805_202204.decoded_output2.txt

