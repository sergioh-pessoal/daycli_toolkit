DAYCLI_TOOLKIT
==========

The DAYCLI_TOOLKIT was developed in Fortran at the National Institute for Space Research (INPE) to assist in the encoding and decoding of DAYCLI BUFR messages. The **daycli_encoder95** is the main tool of the daycli_toolkit. It can be used as a technical encoding layer to convert data from national climate databases into DAYCLI BUFR messages (template 3-07-095). For its use, files in a specific text format (see item 6) need to be previously generated with valid daily climate information, quality control, and respective metadata. Another important tool is the daycli_decoder. It allows decoding a DAYCLI BUFR message back to the text format used by daycli_encoder95, allowing the opening of DAYCLI BUFR files from other centers, as well as being used as a tool for verifying encoding.

**Notes:**
1 -  This software does not perform climatological calculations or quality control decisions.

2- The DAYCLI messages can be decoded by any available BUFR software, as well as by the daycli_decoder and/or bufr_dump tool included in this toolkit. 

3 - Simple examples is also included


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

The daycli_enconder95 tool codes DAYCLI BUFR file from a text file 

**Basic line command**

#
    daycli_encoder95 -i *Name_of_input_text_file.txt*  -o *daycli_output_BUFR_file.bufr*
#

**Running the test example** 

In the ./examples/example01 directory the  script **run_example.sh** demonstrates the encoding of daycli with **daycli_encoder95** as well as the decoding of daycli using two different tools: **a) daycli_decoder** (wich decodes daycli back to the text ) ; **b) bufr_dump** wich is a generic BUFR decoder suitable for all types of BUFR messages.

See and run the scripts **run_example.sh** and see the results.   
Note: this script is a bash script for linux.  If you are using in dos windows or windows terminal some adaptations can  be necessary 


6 - Input text format
------------

The input data formats are based on “fortran namelist” format, in which groups of information are writes in a structure that starts with $GroupName and close with “/” . The initial groups contain fixed metadata information, such as the generating center and sub-center code,  Location of weather station. The last group, “$DATA SECTION”, is the group that Contains the actual daily climate variables and quality values as well as the respective reference day of each subset and time period of each paramerter, separated by semicolons (“;”).


In the case of format 1, the start or end time of the observation period is provided, as a fixed information relative to assined day. This information are used by the programa to calculate the  start and end time of the observaion period for each parameter for each day to then correctly codificate on DAYCLI message

  Example .The example bellow is for maximum temperature (STIME_TX). In this case is indicates that  maxium temperature are mesured every day at 06:00 hour and also considated as maximum temperature of the present day

    &STIME_TX
    HOUR=06
    MINUTE=00
    DT=0
    /

Using this informatiom the time period of maximum temperature are automaticaly calculate for each day of month are followed:

For example:  In the case of the assined date is 20210301 (year = 2021. month =3, day =01) the program  calculates the time period for maximum temperature as been from 20210301T0600 to 20210302T0600, becouse  DT  = 0 indicates that the  beginning time of the  period starts at the current day in LMTZ and for consequence ends in the next day.  On the other hand If DT = -1 it indicates that the beginning time is in on  previous day . So in this case the period would be calculate as from 20210228T0600 to 20210301T0600.  This is the information of time period that are efetivaly code in DAYCLI message. 

Note that only the reference data (year,monuth and day) are provided in the first collum, because the time periods for each variable are automaticaly calculated to be included in DAYCLI 

 
 The example bellow shows the data_section of format1. 

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

Note that only the reference data (year,monuth and day) are provided in the first collum, because the time periods for each variable are automaticaly calculated and included in DAYCLI 

**Format 2**
In case of  format 2. The time periods are not calculated by the program as in the format 1. they must be  directly provided by data base insted as in the example

     &DATA_SECTION !!date;interval;tsd;qtsd;interval;rr;qrr;interval;fsd;qfsd;interval;txT qtx;interval;tn;qtn;interval;tm;qtm
     20220401;20220401T0601;0;7;20220401T0601-20220402T0600;15.5;0;20220401T0601-20220402T0600;0;7;20220401T0601-20220402T0600;278.95;0; 20200331T1801-20220401T1800;273.35;0;20220401T0001-20220402T0000;275.05;0
     20220402;20220402T0601;0;7;20220402T0601-20220403T0600;1.9;0;20220402T0601-20220403T0600;1;7;20220402T0601-20220403T0600;277.65;0;20220401T1801-20220402T1800;274.05;0;20220402T0001-20220403T0000;275.85;0

Where date = reference date (year,month and day in LMTZ); inteval = time interval of the followed variable variable.

In case of  total snoll deaf (tsd) on 20220401 

    20220401T0601


 In case of  precipitation (rr) of the day 20220401

     20220401T0601-20240402T00600 

Notes:
1 - the tsd are made on a specific pont in time, while the other paramenter as rr are a cummulative mesure made from a point in time to another point in time 
2- 