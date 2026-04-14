#####################################################################
# This makefile compiles INPE-MBUFRTOOLS + daycli_encoder  
#####################################################################

#------------------------------------------------------
# Include compilation directives for installed compiler
#-----------------------------------------------------
 include makefile_gfortran 
 #include makefile_g95
 #include makefile_ifort 

#--------------------------------------------------------------------
# DIRECTORIES
#--------------------------------------------------------------------
DIRSHARED=./shared
DIRBIN=./bin
DIRTOOLS=./tools
SRC=./src

#--------------
# MAIN PROGRAM 
#--------------
MAIN1         =$(SRC)/daycli_encoder1.f90
MAIN2         =$(SRC)/daycli_encoder2.f90
DECODER       =$(SRC)/daycli_decoder.f90
MDAYCLI       =$(SRC)/mdaycli.f90
# ----------------------
# MBUFRTOOLS programs 
#----------------------
BUFRDUMPF     = $(DIRTOOLS)/bufrdump.f90
BUFRTIMEF     = $(DIRTOOLS)/bufrtime.f90
BUFRLISTF     = $(DIRTOOLS)/bufrcontent.f90
BUFRGENF      = $(DIRTOOLS)/bufrgen.f90
BUFRQCF       = $(DIRTOOLS)/bufrqc.f90
BUFR2CSVF      = $(DIRTOOLS)/bufr2csv.f90
BUFRSPLITF    = $(DIRTOOLS)/bufrsplit.f90

#--------------------------------------------------------------------
# SHARED MODULES  
#----------------------------------------------------------------------
STRINGFLIBF   = $(DIRSHARED)/f90lib/stringflib.f90
DATELIBF      = $(DIRSHARED)/f90lib/datelib.f90
MBUFRF        = $(DIRSHARED)/mbufr-adt/mbufr.f90
MTEMPLATESF   = $(DIRSHARED)/mbufr-adt/mformats.f90
MCODESFLAGS   = $(DIRSHARED)/mbufr-adt/mcodesflags.f90
MGRADSOF      = $(DIRSHARED)/grdlib/mgrads_obs.f90

#---------------------------
# EXEC
#--------------------------
DAYCLI_ENCODER1= $(DIRBIN)/daycli_encoder1
DAYCLI_ENCODER2= $(DIRBIN)/daycli_encoder2
DAYCLI_DECODER = $(DIRBIN)/daycli_decoder
BUFRLIST     =  $(DIRBIN)/bufrcontent
BUFRGEN      =  $(DIRBIN)/bufrgen
BUFRDUMP     =  $(DIRBIN)/bufrdump
BUFRTIME     =  $(DIRBIN)/bufrtime
BUFR2CSV     =  $(DIRBIN)/bufr2csv
BUFRSPLIT    =  $(DIRBIN)/bufrsplit

#-------------
# COMPILATION
#-------------

all:$(DAYCLI_ENCODER1) $(DAYCLI_ENCODER2) $(BUFRDUMP) $(BUFRGEN) $(BUFRLIST) $(BUFRTIME) $(BUFRSPLIT)
$(DAYCLI_ENCODER1) : $(MAIN1) mbufr.o stringflib.o  datelib.o
	mkdir -p $(DIRBIN)
	$(F90)  -o $@ $(MAIN1) mbufr.o stringflib.o  datelib.o
$(DAYCLI_ENCODER2) : $(MAIN2) mbufr.o stringflib.o  datelib.o
	mkdir -p $(DIRBIN)
	$(F90)  -o $@ $(MAIN2) mbufr.o stringflib.o datelib.o
#-------------
# Basic tools 
#-------------
$(BUFRDUMP) : $(BUFRDUMPF) mbufr.o stringflib.o mcodesflags.o
	$(F90)  -o $@ $(BUFRDUMPF) mbufr.o stringflib.o mcodesflags.o
$(BUFRLIST) : $(BUFRLISTF) mbufr.o stringflib.o mcodesflags.o
	$(F90)  -o $@ $(BUFRLISTF) mbufr.o stringflib.o mcodesflags.o
$(BUFRTIME) : $(BUFRTIMEF) mbufr.o datelib.o stringflib.o
	$(F90)  -o $@ $(BUFRTIMEF) mbufr.o datelib.o stringflib.o
$(BUFRGEN) : $(BUFRGENF) mbufr.o stringflib.o
	$(F90)  -o $@ $(BUFRGENF) mbufr.o stringflib.o
$(BUFRSPLIT) : $(BUFRSPLITF) mbufr.o stringflib.o datelib.o
	$(F90) -o $@ $(BUFRSPLITF) mbufr.o stringflib.o datelib.o
#---------
# Modules 
#---------
mbufr.o   : $(MBUFRF)
	$(F90) -c $(MBUFRF)
stringflib.o   : $(STRINGFLIBF)
	$(F90) -c $(STRINGFLIBF)
datelib.o   : $(DATELIBF) stringflib.o
	$(F90) -c $(DATELIBF)
mformats.o : $(MTEMPLATESF) mbufr.o
	$(F90) -c $(MTEMPLATESF)
mcodesflags.o : $(MCODESFLAGS) stringflib.o mbufr.o
	$(F90) -c $(MCODESFLAGS)
mdaycli.o : $(MDAYCLI) stringflib.o
	$(F90) -c $(MDAYCLI) stringflib.o

clean:
	rm *.o  *.mod
