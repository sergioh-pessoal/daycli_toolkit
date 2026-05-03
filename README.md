DAYCLI_TOOLKIT
==========

The DAYCLI_TOOLKIT was developed at the Brazilian National Institute for Space Research (INPE) to support the encoding and decoding of DAYCLI BUFR messages ( template **3-07-095**). In the present version There are two possibility of input data formats: The data format of daycli_encoder1 can be use to encode observations whose are performed at fixed and consistent times throughout the year. The data format of daycli_endoder2 can be use to encode data whose observation times may vary during the year.  

**Notes:**

1- The DAYCLI messages can be decoded by any available BUFR software, as well as by the daycli_decoder and/or bufr_dump tool included in this toolkit. 

2 - Simple examples is also included


1- Requirements: 
---------
 - A fortran 90 compiler. For example, gfortran, g95, ifort, pgf90, etc. 
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

The daycli_toolkit was developed in linux, but it cam be compiled and used in Windowns (DOS terminal or MS-Windowns terminal). It is necessary just the instalation of the g95 fortran compiler and nmake command.  

Type the command  bellow on DOS terminal to compile
#
    nmake Makefile_windows 
#

Notes:

1 - There are othe compilations options in Windows like using MS Visual studio. In those cases, some small modifications in the solfware are eventualy necessay.

4 - Environment variables
---------
After compilation is necessary to set the environment **MBUFR_TABLES** in your sistem with the path to the folder **bufrtable**  where BUFR tables are. 

The procedure of setting environment variables cam be different in each system or environment. But they use to be simple and similar. 

Here is a example for linux:  In the case of **bufrtables** was saved in the path **/home/user/daycli_toolkit/bufrtables**, just edit the basrc file and add the follow instruction 

# 
export MBUFR_TABLES=/home/user/daycli_toolkit 
#
After the edition type on terminal the command **source ./bashrc** to update the configuration. 

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


