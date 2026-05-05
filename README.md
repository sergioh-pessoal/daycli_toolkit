DAYCLI_TOOLKIT
==========

The DAYCLI_TOOLKIT was developed in Fortran at the Brazilian National Institute for Space Research (INPE) to support the encoding and decoding of DAYCLI BUFR messages ( template **3-07-095**). In the present version There are two possibility of input data formats: The data format of daycli_encoder1 can be use to encode observations whose are performed at fixed and consistent times throughout the year. The data format of daycli_endoder2 can be use to encode data whose observation times may vary during the year.  

**Notes:**

1- The DAYCLI messages can be decoded by any available BUFR software, as well as by the daycli_decoder and/or bufr_dump tool included in this toolkit. 

2 - Simple examples is also included


1- Requirements: 
---------
 - A fortran 90 compiler or Higher. For example, gfortran, g95, ifort, pgf90, etc. 
 - make commnad (linux) or nmake (windows)

2 - Compilation in Linux 
---------

In case of you already have gfortran instaled, the daycli_toolkit can be compiled just typing the command **make** in the terminal.
if you have another fortran compiler, check the files that contains the directives for differents compiler in the directory :
- makefile_pgf90 ( for pfg90 compiler), 
- makefile_ifort (for intel fortran)
- makefile_g95 (for g95)

And edit the file "Makefile" to include the apropriate directive in your case, as in the example bellow

    #------------------------------------------------------
    # Include compilation directives for installed compiler
    #-----------------------------------------------------
    include makefile_gfortran 
    #include makefile_g95
    #include makefile_ifort  

Than type **make**

In case of you are using other fortran compiler, that is not listed above, you can edit and include the directive apropriated in you case.

3 - Compilation in MS-Windows
--------

The daycli_toolkit was developed in linux, but it can be compiled and used in Windowns (DOS terminal or MS-Windowns terminal). However it is necessary previous instalation of the g95 fortran compiler and nmake command from the Microsoftware Visual Studio.  

Type the command  bellow on DOS terminal or Windows terminal to compile
#
    nmake Makefile_windows 
#



4 - Environment variables
---------
After compilation is recommended to set the environment **MBUFR_TABLES** in your system with the path to the folder where BUFR tables are. 

The procedure of setting environment variables can be different in each system or environment. But they use to be simple and similar. 

Here is a example for linux:  In the case of **bufrtables** was saved in the path **/home/user/daycli_toolkit/bufrtables**,it is necessary to edit the .bashrc file (or equivalent) in your system and add the follow instruction 

# 
export MBUFR_TABLES=/home/user/daycli_toolkit 
#
After the edition type on terminal the command **source ./bashrc** to apply changes. 

5 - testing BUFR DAYCLI codification
---------------
**5.1 Using daycli_enconder1**

The daycli_enconder1 tool codes DAYCLI BUFR file from a text file in format1   (see text file formats)

**Basic line command**

#
    daycli_encoder1 -i *Name_of_input_text_file.txt*  -o *daycli_output_BUFR_file.bufr*
#

**Running the test example 1** 

In the  ./examples/example01 directory the script  **run_example.sh** for linux demostrates the codification of daycli with  **daycli_encoder1** as well as the decodification of daycli using  two diferentes tools: **a) daycli_decoder** (wich decodes daycli from BUFR to text format2) ;  **b) bufr_dump** wich is a generic BUFR decoder .

See and run the scripts **run_example.sh** and see the results. 

**Running the test example 2** 

In the  ./examples/example02 directory the script  **run_example.sh** demonstrate the use the **daycli_encoder2 tool**  Note that is quite similar to the one in the example1.  The difference is that the use if text file in format2 insted format1 

6 - Input text format
------------

The input data formats are based on “fortran namelist” format, in which groups of information are writes in a structure that starts with $GroupName and close with “/” . The initial groups contain fixed metadata information, such as the generating center and sub-center code,  Location of weather station as well as the fixed periods used in measurement of each variable. The last group, “$DATA SECTION”, is the group that Contains the actual daily climate variables and quality values, separated by semicolons (“;”).

**6.1-Format 1**

In case of the format1, the fixed periods used for each data, are not provided in the DATA SECTION, but provided in separated groups instead, as in the example bellow for maximum temperature.

    &STIME_TX
    HOUR=06
    MINUTE=01
    DT=0
    /
In this example Hour and minute is the fixed hour and minute used for the maximum temperature.  DT  = 0 indicate the  beginning time of the parameter period starts at the current day in LMTZ .  DT = -1  indicates that  the beginning time of the parameter period starts the previous day in LMTZ. 
The data section contains only reference date and the sequence of measurements and quality information separated by “;” as in the example bellow

    &DATA_SECTION
    !date ;rr(mm); qrr;  ds;qds;tsd;qtsd;tn(c);qtn; tx(c);  qtx;tm(c);qtm
    20220101 ;2.9;   0;   ; 5 ;   ; 5 ;   23.0; 0;   31.9;    0;25.9; 0
    20220102 ;7,4;   0;   ; 5 ;   ; 5 ;   23,4; 0;   32.3;    0;26.3; 0
    20220103 ;6.0;   0;   ; 5 ;   ; 5 ;   22.8; 0;   28.4;    0;24.7; 0
    20220104 ;3.3;   0;   ; 5 ;   ; 5 ;   21.7; 0;   32.1;    0;25.8; 0
    20220105 ;1.4;   0;   ; 5 ;   ; 5 ;   22.8; 0;   31.5;    0;26.4; 0
    20220106 ;0.2;   0;   ; 5 ;   ; 5 ;   22.9; 0;   31.9;    0;26.3; 0
    20220107 ;0.1;   0;   ; 5 ;   ; 5 ;   23.3; 0;   31.7;    0;26.9; 0
    20220108 ;7.4;   0;   ; 5 ;   ; 5 ;   22.5; 0;   31.1;    0;25.9; 0
    / 

where rr = Total Accumulated Precipitation; ds = Fresh snow; tsd= Total Snow depth ; tn = Minimum temperature ; tx = Maximum temperature; tm = Mean temperature.
Note:  "qrr" represents the quality flag for "rr" , "qds" is the quality flag for "ds" and so on
The software will use the informations of fixed times and the reference data  to calculate the start time and end time necessary to encode DAYCLI in BUFR. 

**Format 2**
In case of  format 2 , the fixed period for each variable group are not provided. Insted  the reference date, the sequence of intervals, values and as quality information separated by “;” for each variables are provided in data section for each day.

    $SECTION1
    CENTER= 85     !<-Identification of Originating/Generating center
    SUBCENTER=  0  !<-Sub-center of generating center (See common code C12)
    /
    ! Note: space    <- Missing value
    !-------------------------
    ! Location identification
    !-------------------------
    &STATION_ID
    LATITUDE=  46.45980
    LONGITUDE= -56.10750
    WIGOS=0-20000-0-71805  ! SAINT-PIERRE
    WMO=71805
    HTEMP=  2 ! Hight of temperature sensor
    HA= 21    ! 007030-HEIGHT OF STATION GROUND ABOVE MEAN SEA LEVEL
    SMC_TEMP= ! 008095-SITING AND MEASUREMENT QUALITY CLASSIFICATION FOR TEMPERATURE                                                                                                  
    SMC_PREC= ! 008096-SITING AND MEASUREMENT QUALITY CLASSIFICATION FOR PRECIPITATION (CODE TABLE)                                                                                                                                                                         
    METHOD_TM=    3 ! 008094-Method used to calculate the average daily temperature                                                                          
    TIME_OFFSET=-240! Time difference in minutes:  Local Meteorological Time Zone - UTC (LMTZ-UTC)                       (Note: Use 0 in case of the use of UTC values )
/

     &DATA_SECTION !!date;interval;tsd;qtsd;interval;rr;qrr;interval;fsd;qfsd;interval;txT qtx;interval;tn;qtn;interval;tm;qtm
     20220401;20220401T0601;0;7;20220401T0601-20220402T0600;15.5;0;20220401T0601-20220402T0600;0;7;20220401T0601-20220402T0600;278.95;0; 20200331T1801-20220401T1800;273.35;0;20220401T0001-20220402T0000;275.05;0
     20220402;20220402T0601;0;7;20220402T0601-20220403T0600;1.9;0;20220402T0601-20220403T0600;1;7;20220402T0601-20220403T0600;277.65;0;20220401T1801-20220402T1800;274.05;0;20220402T0001-20220403T0000;275.85;0

