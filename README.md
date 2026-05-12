DAYCLI_TOOLKIT (Version 1.0 )
==========


The DAYCLI_TOOLKIT was developed at the Brazilian National Institute for Space Research (INPE) to support the encoding and decoding of DAYCLI BUFR messages ( template **3-07-095**) . In the present version There are two possibility of input data formats: The data format of daycli_encoder1 can be use to encode observations whose are performed at fixed and consistent times throughout the year. The data format of daycli_endoder2 can be use to encode data whose observation times may vary during the year. Another important tool is the **daycli_decoder**. It allows decoding a DAYCLI BUFR message back into the text format used by daycli_encoder95, enabling the opening of DAYCLI BUFR files from other centers, and can also be used as a tool for verifying local encoding.


**Notes:**

1 -  This software does not perform climatological calculations or quality control decisions.

2- The DAYCLI messages can be decoded by any available BUFR software, as well as by the daycli_decoder and/or bufr_dump tool included in this toolkit. 

3 - Simple examples is also included


1- Requirements: 
---------
 - A fortran 90 compiler or Higher. For example: gfortran, g95, ifort, pgf90, etc. 
 - Linux make command or Windows nmake command

2 - Compilation in Linux 
---------

In case you already have gfortran instaled, the daycli_toolkit can be compiled by just typing the command **make** in the terminal.
if you have another fortran compiler, check the files that contain the directives for different compilers in the directory :
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


    daycli_encoder95 -i "Name_of_input_text_file.txt"  -o "daycli_output_BUFR_file.bufr"


**Running the test example** 

In the ./examples/example_01 directory, the  script **run_example.sh** demonstrates the encoding of daycli with **daycli_encoder95** as well as the decoding of daycli using two different tools: **a) daycli_decoder** (wich decodes daycli back to the text ) ; **b) bufr_dump** wich is a generic BUFR decoder suitable for all types of BUFR messages.

See and run the scripts **run_example.sh** and see the results.   
Note: this script is a bash script for linux.  If you are using dos windows or windows terminal some adaptations can be necessary 


6 - Input text format
------------

The input data formats are based on “fortran namelist” format, in which groups of information are writes in a structure that starts with $GroupName and close with “/” .  The first group is The "$SECTION1"  group. It contains identification of generating center / subcenter. The second group is the "$STATION_ID" which contains many fixed metadata about a weather station as in the example bellow . 

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
    HTEMP=  2 ! Hight of temperature sensor
    HA= 21    ! HEIGHT OF STATION GROUND ABOVE MEAN SEA LEVEL
    SMC_TEMP= ! SITING AND MEASUREMENT QUALITY CLASSIFICATION FOR TEMPERATURE                                                                      
    SMC_PREC= ! SITING AND MEASUREMENT QUALITY CLASSIFICATION FOR PRECIPITATION                         
    METHOD_TM= 3 !Method used to calculate the average daily temperature                                                                     
    TIME_OFFSET=-240! Time difference in minutes:  Local Meteorological Time Zone - UTC                                                                                            
    ! Use 0 in TIME_OFFICE in case of date and time in  UTC 
    /

Notes

1 -  the DAYCLI template 3-07-095 allow the codification of data in the Local Meteorological Time Zone to preserve and inform the date and time of observation acoording local pratices. To inform date and time in UTC use TIME_OFFICE=0. To informat data and time in LMTZ (Local Meteorological Time Zone) use TIME_OFFICE =  Time difference in minutes (LMTZ-UTC)

The last group, “$DATA SECTION”, is the group that contains the actual daily climate variables on a table format with rows and collums separated by semicolons (“;”).  The collums are:

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
  **qrr, qfsd, qtsd,qtn,qtx,qtm**   The quality flag provide here is associated with respective variable in codification process through the sequence 2-04-008; 0-31-021 which is set as 5  
  The correspondent table associated to 0-31-021 = 5 can be found on Code BUFR and Flag table  and it is also preset bellow
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

 Note:  In case of qualit flag = 5  or 6 the parameter value must be indicated  as missing (space in text format)  

The example bellow shows a DATA_SECTION to codification of two days (20220401 and 20220402) of a same weather station 

    &DATA_SECTION 
    !date;interval;tsd;qtsd;interval;rr;qrr;interval;fsd;qfsd;interval;txT qtx;interval;tn;qtn;interval;tm;qtm
     20220401;20220401T0601;0;7;20220401T0601-20220402T0600;15.5;0;20220401T0601-20220402T0600;0;7;20220401T0601-20220402T0600;278.95;0; 20200331T1801-20220401T1800;273.35;0;20220401T0001-20220402T0000;275.05;0
     20220402;20220402T0601;0;7;20220402T0601-20220403T0600;1.9;0;20220402T0601-20220403T0600;1;7;20220402T0601-20220403T0600;277.65;0;20220401T1801-20220402T1800;274.05;0;20220402T0001-20220403T0000;275.85;0

The software combines the fixed information from SECTION1 and STATION_ID with the daily information from DATA_SECTION  to encode a complitly DAYCLI message. So each message should contains one month of information (28,29 30 or 31 days) of a same wether station.

To codification of multiple wether station is necessary the codificaion of multiple DAYCLI Messages. 

**ATTENTION**: Special attention should be paid to the time interval of each parameter, considering the transitions between months or years. For example, consider a case where the reference date is 20210301 and the minimum temperature is measured at 12:00. If the measurements are recorded between 12:00 of the previous day and 12:00 of the current day, the time interval to be provided in this case should be  "20210228T1200-20210301T1200", i.e., from February 28, 2021 at 12:00 until March 1, 2021. If the measurements are recorded between 12:00 of the current day and 12:00 of the following day, the time interval should be "20210301T1200-20210302T1200", i.e., from March 1, 2021 at 12:00 until March 2, 2021. So special attention should be given to the preparation of the time period in each case, for correctly DAYCLI message.coding.

