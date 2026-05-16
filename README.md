DAYCLI_TOOLKIT (Version 1.0 )
==========


The DAYCLI_TOOLKIT was developed at the Brazilian National Institute for Space Research (INPE) to support the encoding and decoding of DAYCLI BUFR messages ( template **3-07-095**). In the present version there are two tools to encode DAYCLI BUFR message: The **daycli_encoder1** and **daycli_encoder2**. The **daycli_encoder1**  can be use to encode observations which are measure at fixed and consistent times throughout the year. The **daycli_endoder2** can be use to encode data observation whose times may vary during the year. Another important tool is the **daycli_decoder**. It allows decoding a DAYCLI BUFR message back into the text format used by daycli_encode2, enabling the opening of DAYCLI BUFR files from other centers.  It can also be used as a tool for verifying local encoding.


**Notes:**

1 -  This software does not perform climatological calculations or quality control decisions.

2- The DAYCLI messages can be decoded by any available BUFR software, as well as by the daycli_decoder and/or bufr_dump tools included in this toolkit. 

3 - Simple examples is also included


1- Requirements: 
---------
 - A fortran 90 compiler or Higher. For example: gfortran, g95, ifort, pgf90, etc. 
- Linux "make" command or Windows "nmake" command.

2 - Compilation in Linux 
---------

In case you already have gfortran installed, the daycli_toolkit can be compiled by just typing the command **make** in the terminal.
if you have another fortran compiler, check the file that contains the directives for different compilers in the directory :
- makefile_pgf90 ( for pfg90 compiler), 
- makefile_ifort (for intel fortran)
- makefile_g95 (for g95)

And edit the file "Makefile" to include the apropriate directive in your case, as in the example below

    #------------------------------------------------------
    # Include compilation directives for installed compiler
    #-----------------------------------------------------
    include makefile_gfortran 
    #include makefile_g95
    #include makefile_ifort  

Then type **make**

In case you are using another fortran compiler, that is not listed above, you can edit and include the appropriate directive in you case.

3 - Compilation in MS-Windows
--------

The daycli_toolkit was developed in linux, but it can be compiled and used in Windows (DOS terminal or MS-Windows terminal).However, the g95 fortran compiler and nmake command from the Microsoftware Visual Studio must be installed in your system.

Type the command  below on DOS terminal or Windows terminal to compile
#
    nmake Makefile_windows 
#


4 - Environment variables
---------
After compilation it is recommended that you set the environment **MBUFR_TABLES** in your system with the path to the folder where BUFR tables are. 

The procedure for setting environment variables can be different in each system or environment. But they are simple and similar. 

Here is an example for linux:  In the case of **bufrtables** saved in the path **/home/user/daycli_toolkit/bufrtables**,it is necessary to edit the .bashrc file (or equivalent) in your system and add the follow instruction 

# 
export MBUFR_TABLES=/home/user/daycli_toolkit/bufrtables 
#
After the edition type on terminal the command **source ./bashrc** to apply changes. 

5 - testing BUFR DAYCLI codification
---------------

The daycli_enconder1 tool code DAYCLI BUFR file from a text file in format1  

**Basic line command**


    daycli_encoder2 -i "Name_of_input_text_file_format2.txt"  -o "daycli_output_BUFR_file.bufr"


**Running the test example** 

There are two examples of DAYCLI codification using daycli_tookit: In the example/example_01 directory the  script  **run_example01.sh** demonstrates the encoding of daycli with **daycli_encoder1** ,  using text input file format-1; in the example/example_02, the script **run_example02.sh** demonstrates the encoding of daycli with **daycli_encoder2** ,  using text input file format-2. Demostration of the decoding of daycli using two different tools: **a) daycli_decoder** (which decodes daycli back to the text ) and **b) bufr_dump** are also included.


See and run the scripts **run_example01.sh**  or **run_example02.sh** and see the results.   

Note: this script is a bash script for linux.  If you are using dos windows or windows terminal some adaptations can be necessary. 


6 - Input data formats 
------------

There are two possible formats for the input data: The format used by daycli_encoder1 tool (format-1) and the format used by daycli_encoder2 (format-2). Both tools produce the exactly same BUFR DAYCLI message according to template **3-07-095**. The differece is that the daycli_encoder1 automaticaly calculates the time period of each variable, necessary for DAYCLI messages acording to fixed parameters provided in format-1, while daycli_encoder2 does not process any calculations. It just encodes all information as it is provided in format-2. In both cases, the input data formats are based on “fortran namelist” format, in which groups of information are written in a structure that starts with "$GroupName" and closes with “/” .  More detailes about format-1 and 2 are provided below

**6.1 Common grous in format 1 and format2**

Both formats have the same initial groups as in the example

SECTION 1 group

     &SECTION1
     CENTER= 85     !<-Identification of Originating/Generating 
     SUBCENTER=  0  !<-Sub-center of generating center (See common code C12)
     /

 STATION_ID group

     &STATION_ID
     LATITUDE=  46.45980
     LONGITUDE= -56.10750
     WIGOS=0-20000-0-71805
     WMO=71805
     HTEMP=  2 ! Height of temperature sensor
     HA= 21    ! Height of station above mean sea level 
     SMC_TEMP=5! Siting and measurement quality classification for temperature       
     SMC_PREC= ! Siting and measurement quality classification for precipitation                         
     METHOD_TM= 3 !Method used to calculate the average daily temperature                                                                     
     TIME_OFFSET=-240! Time difference in minutes:  Local Meteorological Time Zone -UTC                                                                                            
     ! Use 0 in TIME_OFFICE in case of date and time in UTC 
     /


**6.2 Input text Format 1**
  
In addition to the groups presented in item 6.1, format-1 there are the following groups.

 - The groups: &STIME_{TT,TN,TM,RR,DS} define a daily time period for each variable. For example for TN (Minimum temperature)

 **Minimum temperature**

    &STIME_TN
    HOUR=18
    MINUTE=01
    DT=-1
    /

The example above indicates that the minimum temperature is measured at 18:01 LMTZ ( HOUR=18, MINUTE=01). DT=-1 indicates that the measurements are taken from the previous day to the present day (reference day). Use DT=1 to indicate that the measurements are taken fron 18:01 LMTZ at reference day to next day.

With the information above the daycli_encoder-1 performs the calculation for time periods for all the minimum temperatures provided. For example. In case of DT=-1 and data assined as minimum temperature of 1st March 2021  the sofware calculates the time period as  20210228T1801-20210301T1800 i e . from February 28, 2021 at 12:00 until March 1, 2021.  In case of DT=1 the time period would be 20210301T1801-20210302T1800. 

Note that the software consideres the transitions between months or years to calculate the time period and than codes the information in DAYCLI BUFR message.
**we are here**

- The DATA_SECTION group 
The last group, “&DATA SECTION”, is the group that contains the actual daily climate variables on a table format with rows and collums separated by semicolons (“;”).  The collums in format 1 are: date;  rr; qrr; fsd; qfsd; tsd; qtsd; tn; qtn;  tx;  qtx; tm; qtm

where 
 - **date** = Reference date LMTZ
 - **rr** = Total Acumulate Precipitation ( Kg m-2)
 - **fsd** = Fresh snow depth (m)
 - **tsd** = Total snow depth (m)
 - **tx** = Maximum temperature (K)
 - **tn** = Minimum temperature (K)
 - **tm** = Mean temperature (K)

  The quality flag for each respective parameter above are identified by:
  **qrr, qfsd, qtsd,qtn,qtx,qtm**

The example below shows the first few rows of the $DATA_SECTION of the format1.

     &DATA_SECTION
     !date= Reference date and time in LMTZ / Attribution Day
     !date  ;   rr; qrr; fsd; qfsd; tsd; qtsd;    tn; qtn;    tx;  qtx;     tm; qtm
     20220401;15.5;   0;   0;   7;    0;    7;273.35;   0;278.95;    0; 275.05;   0
     20220402;1.9;0;1;7;0;7;274.05;0;277.65;0;275.85;0
     20220403;0.0;0;1;7;0;7;273.35;0;276.65;0;274.45;0
     20220404;23.6;0;0;7;0;7;271.75;0;278.35;0;275.15;0
     20220405;0.6;0;1;7;0;7;273.45;0;277.15;0;274.75;0
     20220406;0.0;0;1;7;0;7;272.85;0;278.25;0;274.95;0
     ...
/
Complete examples of format 1 are included in the ./examples/example01/ 

6.3 Input text format 2

Format 2 does not have the &STIME_{TT,TN,TM,RR,DS} groups like format 1. Instead, the time periods are provided directly in the $DATA_SECTION group. In other words, daycli_encoder2 does not perform any time window processing; it directly encodes the data in the DAYCLI message as it is provided in format 2.

In that way the $DATA_SECTION group have the followed collums separated by semicolons (“;”).  

   **date; interval; tsd; qtsd; interval; rr; qrr; interval; fsd; qfsd; interval; tx qtx;interval;tn;qtn;interval;tm;qtm**


where 
- **date** = reference date in the format "*yyyymmdd*"  (year, month and day)
- **interval (before tsd)** = Date and time of fresh snow depht mesurement in format (yyyymmddThhmm)
- **interval** = time interval used in processing extreme, average, or cumulative measurements that are provided in the following columns. The format is "yyyymmddThhmm-yyyymmddThhmm" to indicate the start and end time of the period

 - **rr** = Total Acumulate Precipitation ( Kg m-2)
 - **fsd** = Fresh snow depth (m)
 - **tsd** = Total snow depth (m)
 - **tx** = Maximum temperature (K)
 - **tn** = Minimum temperature (K)
 - **tm** = Mean temperature (K)

  The quality flag for each respective parameter above are identified by:
  **qrr, qfsd, qtsd,qtn,qtx,qtm**  
  
The example below shows the first few rows of the $DATA_SECTION of the format2.


    &DATA_SECTION 
    !date;interval;tsd;qtsd;interval;rr;qrr;interval;fsd;qfsd;interval;txT qtx;interval;tn;qtn;interval;tm;qtm
     20220401;20220401T0601;0;7;20220401T0601-20220402T0600;15.5;0;20220401T0601-20220402T0600;0;7;20220401T0601-20220402T0600;278.95;0; 20200331T1801-20220401T1800;273.35;0;20220401T0001-20220402T0000;275.05;0
     20220402;20220402T0601;0;7;20220402T0601-20220403T0600;1.9;0;20220402T0601-20220403T0600;1;7;20220402T0601-20220403T0600;277.65;0;20220401T1801-20220402T1800;274.05;0;20220402T0001-20220403T0000;275.85;0
     ...
     /

Complete examples of format 2 are included in the ./examples/example02/ 


7 - Notes
--------
7.1 - The quality flag provide in format 1 and 2 are associated with respective variable in codification process through the BUFR sequence 2-04-008; 0-31-021 which is set as 5  
  The correspondent table associated to 0-31-021 = 5 can be found on Code BUFR and Flag table  and it is also preset below
   - 0 = Data checked and declared good;
   - 1 = Data checked and declared suspect;
   - 2 = Data checked and declared aggregated;
   - 3 = Data checked and declared out of instrument range;
   - 4 = Data checked, declared aggregated, and out of instrument range;
   - 5 = Parameter is not measured at the station;
   - 6 = Daily value not provided;
   - 7 = Data unchecked,
   - 8-254 = Reserved;
   - 255 = Missing (QC info not available)

   8 - REFERENCES
   --------------
[1] Manual on Codes (WMO-No 306), Volume 1.2 - FM94 BUFR edition 4 FT2026-1 Version 46.
Available on    https://wmo.int/latest-version

[2] Propose of DAYCLI message at WMO/ET-DATA - Actual Version (template 307095): "A new BUFR sequence for the exchange of daily summary report (DAYCLI)" 
https://github.com/wmo-im/BUFR4/issues/238


[3] Propose of DAYCLI message at WMO/ET-DATA - previous version (template 307075) 
https://github.com/wmo-im/BUFR4/issues/51 

