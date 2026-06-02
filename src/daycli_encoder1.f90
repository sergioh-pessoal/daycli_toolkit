program daycli_encoder
 use stringflib
 use mbufr
 use datelib, only: fjulian, fyear=>year, fmonth=>month, fday=>day, fhour=>hour, fminute=>minute
 implicit none
 
 type time_slot
	real year
	real month
	real day
	real hour
	real minute
	real dt
 end type
 type(time_slot)                  ::TIME_TX
 type(time_slot)                  ::TIME_TN
 type(time_slot)                  ::TIME_TM
 type(time_slot)                  ::TIME_RR
 type(time_slot)                  ::TIME_DS
 type(time_slot)                  ::TIME_TSD
 real,parameter                   ::null_val =-99999999   ! Undefined value used in input namelist
 real                             ::undefval              ! Undefined value used by mbufr module
 character(len=1024)              ::filein
 character(len=1024)              ::fileout
 character(len=255)               ::line
 character(len=1),dimension(10)   ::namearg ! Nome dos argumentos!
 character(len=1024),dimension(10)::arg     ! argumentos 
 integer                          ::nargss
 integer                          ::l,i,j,s,i2,k
 integer                          ::c          !Number of character
 character(len=20),dimension(20)  ::substrings
 integer                          ::nelements
 integer                          ::WIGOS1,WIGOS2,WIGOS3,WMO1,WMO2
 character(len=17)                ::WIGOS4
 real(kind=realk),dimension(31)   ::RR,TN,TX,TM
 real(kind=realk),dimension(31)   ::HNEIGEF    !Death of Fresh Snow
 real(kind=realk),dimension(31)   ::NEIGETOT06 !Total Snow Death
 real(kind=realk),dimension(31)   ::QRR,QTN,QTX,QTM,QHNEIGEF,QNEIGETOT06
 character(len=10),dimension(31)  ::POSTE,DATE
 character(len=60)                ::auxc
 character(len=10),dimension(13)  ::cn
 character(len=22)                ::header !Telecomunication header (T1T2A1A1ii_cccc_YYGGgg(_BBB)
 integer                          ::nnn    !Sequence Number for header 
 real(kind=realk)                 ::LON,HT
 character(len=2)                 ::SM_TEMP, SM_PREC
 real,parameter                   ::FieldSig=5
 real,parameter                   ::maximum=2
 real,parameter                   ::minimum=3
 real,parameter                   ::mean=4
 integer                          ::day
 integer                          ::nday
 integer                          ::START_TIME,END_TIME
 real(kind=realk)                 ::LAT=null_val
 real(kind=realk)                 ::LATITUDE=null_val
 real(kind=realk)                 ::LONGITUDE=null_val
 character(len=60)                ::WIGOS=' '
 integer                          ::WMO=null_val
 real(kind=realk)                 ::HTEMP=null_val
 real(kind=realk)                 ::HA=null_val                 !HEIGHT OF STATION GROUND ABOVE MEAN SEA LEVEL
 real(kind=realk)                 ::SMC_TEMP=null_val           !SITING AND MEASUREMENT QUALITY CLASSFICATION FOR TEMPERATURE (CODE TABLE) 22=B5
 real(kind=realk)                 ::SMC_PREC=null_val           !SITING AND MEASUREMENT QUALITY CLASSIFICATION FOR PRECIPITAION (CCITTIA5)
 real(kind=realk)                 ::METHOD_TM=null_val         !Method used to calculate the average daily temperature 
 integer                          ::YEAR=null_val
 integer                          ::MONTH=null_val
 integer                          ::TIME_OFFSET
 real(kind=realk)                 ::HOUR=null_val              !Maximum Temperature - Hour
 real(kind=realk)                 ::MINUTE=null_val            !Maximum Temperature - Hour
 real(kind=realk)                 ::SECOND=null_val            !Maximum Temperature - Hour
 real(kind=realk)                 ::DT=null_val               !Time period or displacement
 real(kind=realk)                 ::CK                        !Use 0 or +273.16 to convert temperature from C to K
 integer                          ::X1,X2
 REAL(kind=realk)                 ::CENTER=255
 real(kind=realk)                 ::SUBCENTER=0 
 REAL(8)                          ::JDATE1,JDATE2
 !{ Declaracao de variaveis para MBUFR-ADT
   type(sec1type)::sec1
   type(sec3type)::sec3
   type(sec4type)::sec4
   integer       ::err
!}
NAMELIST /SECTION1/CENTER,SUBCENTER
NAMELIST /STATION_ID/LATITUDE,LONGITUDE, WIGOS,WMO,HTEMP,HA,SMC_TEMP,SMC_PREC,METHOD_TM,TIME_OFFSET
NAMELIST /STIME_TX/HOUR,MINUTE,DT
NAMELIST /STIME_TN/HOUR,MINUTE,DT
NAMELIST /STIME_TM/HOUR,MINUTE,DT
NAMELIST /STIME_RR/HOUR,MINUTE,DT
NAMELIST /STIME_DS/HOUR,MINUTE,DT
NAMELIST /STIME_TSD/HOUR,MINUTE,DT
!---------
! WELCOME
!---------
   CK=0
   X1=0
   X2=0
   header=""
   nnn=0
   call getarg2(namearg,arg,nargss)                                         
   do i=1, nargss 
                                                          
      if (namearg(i)=="i") then 
        filein=arg(i)
        x1=1
      end if

      if (namearg(i)=="o") then 
        fileout=arg(i)
        x2=1
      end if
      if (namearg(i)=="h") then 
        header=arg(i)
        ![.471...INMX11.EUMP.272231...]

      end if
      if (namearg(i)=="s") then 
        nnn=val(arg(i))
      end if
   end do
   

  print *,"+---------------------------------------------------------------------+"
  print *,"| INPE DAYCLI_ENCODER: Encode DAYCLI messages in FM94-BUFR (3-07-075) |"
  print *,"| Autor: sergio.ferreira@inpe.br - Version 1.2 2026                   |"
  print *,"| Include MBUFR-ADT module ",MBUFR_VERSION,"                  |"
  print *,"+---------------------------------------------------------------------+"
 if ((x1*X2)==0) then
  print *,"| use daycli_encoder -i <infile> -o <outfile>  {-s nnn -h header}     |"
  print *,"|   infile:= input text file name                                     |"
  print *,"|   outfile:= outpur BUFR file name (DAYCLI)                          |"
  print *,"|                                                                     |"
  print *,"|   Optional: Inclusion of Abbreviation header                        |"
  print *,"|   -s nnn    := sequence number of Abbreviation header               |"
  print *,'|   -h header := "T1T2A1A2ii cccc YYGGgg ( BBB)"                      |'
  print *,"+---------------------------------------------------------------------+"
   
  
	stop
   end if
 !-----------------------------------------------------------------------------------
 ! gets the undefined value used by mbufr and sets stringflib to use the same value
 !-----------------------------------------------------------------------------------
  undefval=undef()
  call init_stringflib(undefval)
  
 
!----------------------------------------
! READ NAMELIST STATION_ID and TIME_SLOT
!----------------------------------------

 open (1,file=filein,status='old')
	READ  (1, SECTION1)
	if (SUBCENTER<0) SUBCENTER=255
	READ  (1, STATION_ID)
	READ  (1, STIME_TX)
	TIME_TX%HOUR=HOUR
	TIME_TX%MINUTE=MINUTE
	TIME_TX%DT=DT
	
	READ  (1, STIME_TN)
	TIME_TN%HOUR=HOUR
	TIME_TN%MINUTE=MINUTE
	TIME_TN%DT=DT
	
	READ  (1, STIME_TM)
	TIME_TM%HOUR=HOUR
	TIME_TM%MINUTE=MINUTE
	TIME_TM%DT=DT
	
	READ  (1, STIME_RR)
	TIME_RR%HOUR=HOUR
	TIME_RR%MINUTE=MINUTE
	TIME_RR%DT=DT
	
	READ  (1, STIME_DS)
	TIME_DS%HOUR=HOUR
	TIME_DS%MINUTE=MINUTE
	TIME_DS%DT=DT
	
	READ  (1, STIME_TSD)
	TIME_TSD%HOUR=HOUR
	TIME_TSD%MINUTE=MINUTE
	TIME_TSD%DT=DT
	
 close(1)

print *, "NAMELIST: STATION_ID and TIME_SLOT (Ok)"


!---------------------------------
! WMO STATION NUMBER AND WIGOS ID
!---------------------------------

 if (WMO>0) then 
	WMO1=int(WMO/1000)
	WMO2=WMO-WMO1*1000
 else
	WMO1=undefval
	WMO2=undefval
 end if
 WIGOS1=null_val
 WIGOS2=null_val
 WIGOS3=null_val
 WIGOS4=""
 if (len_trim(WIGOS)>0) then
	call split(WIGOS,"-",substrings, nelements)
	if (nelements/=4) print *,"Error in WIGOS ID"
	WIGOS1= val(substrings(1))  !*001125-WIGOS IDENTIFIER SERIES (NUMERIC)
	WIGOS2= val(substrings(2))  ! 001126-WIGOS ISSUER OF IDENTIFIER (NUMERIC)
	WIGOS3= val(substrings(3))  ! 001127-WIGOS ISSUE NUMBER (NUMERIC)
	WIGOS4=trim(substrings(4))  ! 001128-WIGOS LOCAL IDENTIFIER (CHARACTER) (CCITTIA5)
 end if

 
LAT=(LATITUDE)
LON=(LONGITUDE)

HT=HTEMP                  !Highr of temperature sensor
write(*,'(" WIGOS=[",i2.2,"-",i5.5,"-",i5.5,"-",a16,"]")')WIGOS1,WIGOS2,WIGOS3,WIGOS4
 print *,'LATITUDE   =',LAT
 print *,'LONGITUDE  =',LON
 print *,'HTEMP      =',HTEMP
 print *,'HA         =',HA
 print *,'SMC_TEMP   =',SMC_TEMP
 print *,'SMC_PREC   =',SMC_PREC
 print *,'METHOD_TM  =',METHOD_TM
 print *,'TIME_OFFSET=',TIME_OFFSET
 write (*,'(" WMO        = ",i2,i3)')WMO1,WMO2
 
 
 cn(1)="date"
 cn(2)="rr(mm)"
 cn(3)="qrr"
 cn(4)="ds"
 cn(5)="qds"
 cn(6)="tsd"
 cn(7)="qtsd"
 cn(8)="tn(K)"
 cn(9)="qtn"
 cn(10)="tx(K)"
 cn(11)="qtx"
 cn(12)="tm(K)"
 cn(13)="qtm"

 !-------------------
 ! Init Variables 
 !------------------
 
 RR(:)=null_val
 tN(:)=null_val
 tX(:)=null_val
 TM(:)=null_val
 HNEIGEF(:)   =null_val
 NEIGETOT06(:)=null_val
 QRR(i)=null_val
 qtN(i)=null_val
 qtX(i)=null_val
 qTM(i)=null_val
 qHNEIGEF(i)=null_val
 qNEIGETOT06(i)=null_val
 
 


!----------
! READ DATA 
!----------

	open (1,file=filein,status='old')
 5	read(1,'(a)',end=999) line
	print *,trim(line),index(line,"DATA_SECTION")
	if (index(line,"DATA_SECTION")==0) then
		goto 5
	end if 
	i=0
 10	read(1,'(a)',end=999)line
		l=index(line,"#")+index(line,"!")+index(ucases(line),"DATE")
		if ((index(line,"/")>0).and.(l==0)) goto 999
		if ((l==0).and.(len_trim(line)>0)) then !{

			i=i+1
			!line=replace(line,",",".")
			line=replace(line,char(9),";")
			call split(line,";",.false.,substrings, nelements)
			if (nelements<13) then !{
				print *,"Error reading the line =",i
				print *,line 
				print *,"Error: nelements=",nelements
				stop
			end if !}
			
			read(substrings(1),'(i4,i2,i2)')YEAR,MONTH,DAY
			if (i/=day) then !{
				print *,"Error: Error in day sequence "
				print *,"The spected value = ",i
				print *,"The provided value =",day
				stop
			end if !}
	
			RR (i)=val(substrings(2))
			QRR(i)=val(substrings(3))
			HNEIGEF(i)=val(substrings(4))
			qHNEIGEF(i)=val(substrings(5))
			NEIGETOT06(i)=val(substrings(6))
			qNEIGETOT06(i)=val(substrings(7))
			
			tN(i)=val(substrings(8))
			qtN(i)=val(substrings(9))
			tX(i)=val(substrings(10))
			qtX(i)=val(substrings(11))
			TM(i)=val(substrings(12))
			qTM(i)=val(substrings(13))

			if ((tn(i)<100)) then !{
			  ck=273.16
			else
			  ck=0.0
			end if !}
			
			!------------------------------------------------
			! Consistence of temperature (Must be in Kelvin)
			! ----------------------------------------------
			if (((tn(i)+ck)<0).and.(tn(i)>-3000)) then !{
				print *,"Error 1 in values of temperature"
				write (*,'(" -> tn=",f5.2," tm=",f5.2," tx=",f5.2)')tn(i),tm(i),tx(i)
				do k=1,13
					print *,cn(k),"=",val(substrings(k))
				end do
				stop
			end if !}

			
			!------------------------------------------------
			! Consistence of temperature 
			! ----------------------------------------------
			if ((tn(i)>-3000).and.(tm(i)>-3000).and.(tx(i)>-3000)) then !{
			if (int(tn(i))>int(tx(i)).or.int(tn(i))>int(tm(i)).or.int(tx(i))<int(tm(i))) then !{
				print *,"Warning! Inconsistency in temperature values."
				write (*,'(" -> tn=",f7.2," tm=",f7.2," tx=",f7.2)')tn(i),tm(i),tx(i)
				print *," -> ",trim(line)
				
				print *,""
				print *,"Other values:"
			
				do k=1,13
					print *,cn(k),"=",val(substrings(k))
				end do
				!stop -
			end if !}
			end if !}
			!print *,i," Quality flag=",qrr(i),qtn(i),qtx(i),qtm(i)
			!print *,nelements,trim(line)
		end if !}
		
		goto 10
 999	continue
        close(1)
	nday=i
	if (nday<1) then
		print *,"*** Error reading data *** "
		print *,"*** nday=",nday
		stop
	end if
	if (len_trim(header)>0) write(*,'(1x,"HEADER = ",i3.3," ",a)')nnn,trim(header)
	
    !--------------------------
	! INITIALIZE  MBUFR MODULE
	!--------------------------
	call INIT_MBUFR(3,.true.)
	call open_mbufr(2,fileout)
	if (len_trim(header)>0) call write_header(2,nnn,header)
	
	!----------------
	! SECTION 1 DATA
	!---------------
	if (SUBCENTER<0) SUBCENTER=255
	sec1%NumMasterTable=0
	sec1%center        =CENTER
	sec1%subcenter     =SUBCENTER
	sec1%update        =0
	sec1%btype         =0
	sec1%Intbsubtype   =21
	sec1%bsubtype      =0
	sec1%VerMasterTable=46
	sec1%VerLocalTable =0
	sec1%year          =YEAR
	sec1%month         =MONTH
	sec1%day           =0
	sec1%hour          =0
	sec1%minute        =0
	sec1%second        =0
			
	!----------------		
	! SECTION 3 DATA
	!---------------		
	sec3%nsubsets=nday
	sec3%ndesc=100
	sec3%is_cpk=0
	allocate(sec3%d(sec3%ndesc))
	j=0
	j=j+1;sec3%d(j)=307095 !daily temperatures and precipitations, including snow, for climate report (DAYCLI)
	sec3%ndesc=j
	
	
	!
	! SECTION 4
	!
	sec4%nvars=200
	allocate(sec4%r(sec4%nvars,sec3%nsubsets))
	allocate(sec4%c(sec4%nvars,sec3%nsubsets))
	sec4%r(:,:)=0
	sec4%c(:,:)=0
	
	do day=1,nday
	s=day
        j=0 	
		j=j+1;sec4%r(j,s)= WIGOS1 !1) *001125-WIGOS IDENTIFIER SERIES (NUMERIC)
        j=j+1;sec4%r(j,s)= WIGOS2 !2)  001126-WIGOS ISSUER OF IDENTIFIER (NUMERIC)
        j=j+1;sec4%r(j,s)= WIGOS3 !3)  001127-WIGOS ISSUE NUMBER (NUMERIC)
	
	auxc=WIGOS4               !# 4-19)  001128-WIGOS LOCAL IDENTIFIER (CHARACTER) (CCITTIA5)
	c=0
	do i2=1,16
		j=j+1
		c=c+1
		sec4%r(j,s)=ichar(auxc(i2:i2))
		sec4%c(j,s)=c
	end do

	j=j+1;sec4%r(j,s)= WMO1        ! 5)*001001-WMO BLOCK NUMBER (NUMERIC)
	j=j+1;sec4%r(j,s)= WMO2        ! 6) 001002-WMO STATION NUMBER (NUMERIC)
	j=j+1;sec4%r(j,s)= LAT         ! 7) 005001-LATITUDE (HIGH ACCURACY) (DEG)
	j=j+1;sec4%r(j,s)= LON         ! 8) 006001-LONGITUDE (HIGH ACCURACY) (DEG)
	j=j+1;sec4%r(j,s)= HA          ! 9) 007030-HEIGHT OF STATION GROUND ABOVE MEAN SEA LEVEL (SEE NOTE 3) (M)
	j=j+1;sec4%r(j,s)= SMC_TEMP    !10) 008095-SITING AND MEASUREMENT QUALITY CLASSFICATION FOR TEMPERATURE (CODE TABLE) 22=B5
	j=j+1;sec4%r(j,s)= SMC_PREC    !11) 008096-SITING AND MEASUREMENT QUALITY CLASSIFICATION FOR PRECIPITAION (CCITTIA5)
	j=j+1;sec4%r(j,s)= METHOD_TM   !12) 008094-Method used to calculate the average daily temperature  (8)
	j=j+1;sec4%r(j,s)= 40          !13) 008028-EXTENDED TIME SIGNIFICANCE SET=40 Attribution Day (LMTZ)
	j=j+1;sec4%r(j,s)= 3           !14) 008025-TIME DIFFERENCE QUALIFIER (CODE TABLE) SET = 3 (LMTZ-UTC)
	j=j+1;sec4%r(j,s)= TIME_OFFSET !15) 026003 TIME DIFFERENCE (MIN)
	j=j+1;sec4%r(j,s)= YEAR        !16) 004001-YEAR (A)
	j=j+1;sec4%r(j,s)= MONTH       !17) 004002-MONTH (MON)
	j=j+1;sec4%r(j,s)= DAY         !18) 004003-DAY (D)

	! 	Total snow depth(Instantaneous measurement)
	!---------------
	call get_time_slot2(YEAR,MONTH,DAY,TIME_TSD,JDATE1,JDATE2)
	j=j+1;sec4%r(j,s)= 42             !19) 008028-EXTENDED TIME SIGNIFICANCE FOR TOTAL SNOW DEATH
	j=j+1;sec4%r(j,s)= fYEAR(JDATE1)  !20) *004001-YEAR (A)
	j=j+1;sec4%r(j,s)= fMONTH(JDATE1) !21)  004002-MONTH (MON)
	j=j+1;sec4%r(j,s)= fDAY(JDATE1)   !22)  004003-DAY (D)
	j=j+1;sec4%r(j,s)= fHOUR(JDATE1)  !23) *004004-HOUR (H)
	j=j+1;sec4%r(j,s)= fMINUTE(JDATE1)!24)  004005-MINUTE (MIN)
	j=j+1;sec4%r(j,s)= 0              !25)  204008-ADD ASSOCIATED FIELD
	j=j+1;sec4%r(j,s)= FieldSig       !26)  031021-1-BIT INDICATOR OF QUALITY
	j=j+1;sec4%r(j,s)= qHNEIGEF(day)  !27)  999999-VALUE OF THE ASSOCIATED FIELD
	j=j+1;sec4%r(j,s)= HNEIGEF(DAY)   !28)  013013-TOTAL SNOW DEPTH (M)
	j=j+1;sec4%r(j,s)= 0              !29)  204000-ADD ASSOCIATED FIELD CANCEL

	! Period over which the daily measurement is made (LMTZ)
	!--------------------------------------------------------
	j=j+1;sec4%r(j,s)=41               !30) 008028-EXTENDED TIME SIGNIFICANCE (CODE TABLE)

	!(precipitation)
	!---------------
	call get_time_slot2(YEAR,MONTH,DAY,TIME_RR,JDATE1,JDATE2)
	j=j+1;sec4%r(j,s)= fYEAR(JDATE1)   !31) *004001-YEAR (A)
	j=j+1;sec4%r(j,s)= fMONTH(JDATE1)  !32)  004002-MONTH (MON)
	j=j+1;sec4%r(j,s)= fDAY(JDATE1)    !33)  004003-DAY (D)
	j=j+1;sec4%r(j,s)= fHOUR(JDATE1)   !34) *004004-HOUR (H)
	j=j+1;sec4%r(j,s)= fMINUTE(JDATE1) !35)  004005-MINUTE (MIN)
	j=j+1;sec4%r(j,s)= fYEAR(JDATE2)   !36) *004001-YEAR (A)
	j=j+1;sec4%r(j,s)= fMONTH(JDATE2)  !37)  004002-MONTH (MON)
	j=j+1;sec4%r(j,s)= fDAY(JDATE2)    !38)  004003-DAY (D)
	j=j+1;sec4%r(j,s)= fHOUR(JDATE2)   !39) *004004-HOUR (H)
	j=j+1;sec4%r(j,s)= fMINUTE(JDATE2) !40)  004005-MINUTE (MIN)
	j=j+1;sec4%r(j,s)= 0               !41)  204008-ADD ASSOCIATED FIELD
	j=j+1;sec4%r(j,s)= FieldSig        !42)  031021-1-BIT INDICATOR OF QUALITY <- ASSOCIATED FIELD SIGNIFICANCE (CODE TABLE)
	j=j+1;sec4%r(j,s)= QRR(day)        !43)  999999-VALUE OF THE ASSOCIATED FIELD (SIZE =  8BITS)
	j=j+1;sec4%r(j,s)= RR(day)         !44)  013060-TOTAL ACCUMULATED PRECIPITATION (KG M-2)
	j=j+1;sec4%r(j,s)=  0              !45)  204000-ADD ASSOCIATED FIELD

	!Depth of fresh snow
	!----------------
	if ((qHNEIGEF(day)==5).or.(qHNEIGEF(day)<0)) then
		call undef_date_time (j,sec4)
		call undef_date_time (j,sec4)
		j=j+1;sec4%r(j,s)= 0               !56)  204008-ADD ASSOCIATED FIELD
		j=j+1;sec4%r(j,s)= FieldSig        !57)  031021-1-BIT INDICATOR OF QUALITY <- ASSOCIATED FIELD SIGNIFICANCE (CODE TABLE)
		j=j+1;sec4%r(j,s)= qHNEIGEF(day)   !58)  999999 Assoaciated field
		j=j+1;sec4%r(j,s)= undef()         !59)  013012-DEPTH OF FRESH SNOW (M)
		j=j+1;sec4%r(j,s)=  0              !60)  204000-CANCE
	else
		call get_time_slot2(YEAR,MONTH,DAY,TIME_DS,JDATE1,JDATE2)
		j=j+1;sec4%r(j,s)= fYEAR(JDATE1)   !46) *004001-YEAR (A)
		j=j+1;sec4%r(j,s)= fMONTH(JDATE1)   !47)  004002-MONTH (MON)
		j=j+1;sec4%r(j,s)= fDAY(JDATE1)     !48)  004003-DAY (D)
		j=j+1;sec4%r(j,s)= fHOUR(JDATE1)    !49) *004004-HOUR (H)
		j=j+1;sec4%r(j,s)= fMINUTE(JDATE1)  !50)  004005-MINUTE (MIN)
		j=j+1;sec4%r(j,s)= fYEAR(JDATE2)    !51) *004001-YEAR (A)
		j=j+1;sec4%r(j,s)= fMONTH(JDATE2)   !52)  004002-MONTH (MON)
		j=j+1;sec4%r(j,s)= fDAY(JDATE2)     !53)  004003-DAY (D)
		j=j+1;sec4%r(j,s)= fHOUR(JDATE2)    !54) *004004-HOUR (H)
		j=j+1;sec4%r(j,s)= fMINUTE(JDATE2)  !55)  004005-MINUTE (MIN)
		j=j+1;sec4%r(j,s)= 0               !56)  204008-ADD ASSOCIATED FIELD
		j=j+1;sec4%r(j,s)= FieldSig        !57)  031021-1-BIT INDICATOR OF QUALITY <- ASSOCIATED FIELD SIGNIFICANCE (CODE TABLE)
		j=j+1;sec4%r(j,s)= qHNEIGEF(day)   !58)  999999 Assoaciated field
		j=j+1;sec4%r(j,s)= HNEIGEF(DAY)    !59)  013012-DEPTH OF FRESH SNOW (M)
		j=j+1;sec4%r(j,s)=  0              !60)  204000-CANCEL
    end if


	!Temperatures
	!----------------
	j=j+1;sec4%r(j,s)=  HT             !61)  007032-HEIGHT OF SENSOR ABOVE LOCAL GROUND
	
	 !{ Loop tx,tn,tt	
	 !{TX
	 call get_time_slot2(YEAR,MONTH,DAY,TIME_TX,JDATE1,JDATE2)
	j=j+1;sec4%r(j,s)= fYEAR(JDATE1)    !62) *004001-YEAR (A)
	j=j+1;sec4%r(j,s)= fMONTH(JDATE1)   !63)  004002-MONTH (MON)
	j=j+1;sec4%r(j,s)= fDAY(JDATE1)     !64)  004003-DAY (D)
	j=j+1;sec4%r(j,s)= fHOUR(JDATE1)    !65) *004004-HOUR (H)
	j=j+1;sec4%r(j,s)= fMINUTE(JDATE1)  !66)  004005-MINUTE (MIN)
	j=j+1;sec4%r(j,s)= fYEAR(JDATE2)    !67) *004001-YEAR (A)
	j=j+1;sec4%r(j,s)= fMONTH(JDATE2)   !68)  004002-MONTH (MON)
	j=j+1;sec4%r(j,s)= fDAY(JDATE2)     !69)  004003-DAY (D)
	j=j+1;sec4%r(j,s)= fHOUR(JDATE2)    !70) *004004-HOUR (H)
	j=j+1;sec4%r(j,s)= fMINUTE(JDATE2)  !71)  004005-MINUTE (MIN)
	j=j+1;sec4%r(j,s)= maximum          !72)  008023-RESERVED <- FIRST-ORDER STATISTICS (CODE TABLE)
	j=j+1;sec4%r(j,s)= 0                !73)  204008-ADD ASSOCIATED FIELD
	j=j+1;sec4%r(j,s)= FieldSig         !74)  031021-1-BIT INDICATOR OF QUALITY <- ASSOCIATED FIELD SIGNIFICANCE (CODE TABLE)
	j=j+1;sec4%r(j,s)= qtX(day)        !75) *999999-VALUE OF THE ASSOCIATED FIELD (SIZE =  8BITS)
	j=j+1;sec4%r(j,s)= TX(DAY)+CK      !76)  012101-TEMPERATURE/AIR TEMPERATURE (K) - MAXIMUM
	j=j+1;sec4%r(j,s)=  0              !77)  20400 -Cancel
	 !}
	!{TN
	call get_time_slot2(YEAR,MONTH,DAY,TIME_TN,JDATE1,JDATE2)
	j=j+1;sec4%r(j,s)= fYEAR(JDATE1)    !78) *004001-YEAR (A)
	j=j+1;sec4%r(j,s)= fMONTH(JDATE1)   !79)  004002-MONTH (MON)
	j=j+1;sec4%r(j,s)= fDAY(JDATE1)     !80)  004003-DAY (D)
	j=j+1;sec4%r(j,s)= fHOUR(JDATE1)    !81) *004004-HOUR (H)
	j=j+1;sec4%r(j,s)= fMINUTE(JDATE1)  !82)  004005-MINUTE (MIN)
	j=j+1;sec4%r(j,s)= fYEAR(JDATE2)    !83) *004001-YEAR (A)
	j=j+1;sec4%r(j,s)= fMONTH(JDATE2)   !84)  004002-MONTH (MON)
	j=j+1;sec4%r(j,s)= fDAY(JDATE2)     !85)  004003-DAY (D)
	j=j+1;sec4%r(j,s)= fHOUR(JDATE2)   !86) *004004-HOUR (H)
	j=j+1;sec4%r(j,s)= fMINUTE(JDATE2)  !87)  004005-MINUTE (MIN)
	j=j+1;sec4%r(j,s)= minimum         !88)  008023-RESERVED <- FIRST-ORDER STATISTICS (CODE TABLE)
	j=j+1;sec4%r(j,s)= 0               !89)  204008-ADD ASSOCIATED FIELD
	j=j+1;sec4%r(j,s)= FieldSig        !90)  031021-1-BIT INDICATOR OF QUALITY <- ASSOCIATED FIELD SIGNIFICANCE (CODE TABLE)
	j=j+1;sec4%r(j,s)=qtn(day)         !91)  999999-VALUE OF THE ASSOCIATED FIELD (SIZE =  8BITS)
	j=j+1;sec4%r(j,s)= TN(DAY)+CK      !92)  012101-TEMPERATURE/AIR TEMPERATURE (K)
	j=j+1;sec4%r(j,s)= 0               !93)  204000-ADD ASSOCIATED FIELD
	 !}
	 !{
	call get_time_slot2(YEAR,MONTH,DAY,TIME_TM,JDATE1,JDATE2)
	j=j+1;sec4%r(j,s)= fYEAR(JDATE1)    !94) *004001-YEAR (A)
	j=j+1;sec4%r(j,s)= fMONTH(JDATE1)   !95)  004002-MONTH (MON)
	j=j+1;sec4%r(j,s)= fDAY(JDATE1)     !96)  004003-DAY (D)
	j=j+1;sec4%r(j,s)= fHOUR(JDATE1)    !97) *004004-HOUR (H)
	j=j+1;sec4%r(j,s)= fMINUTE(JDATE1)  !98)  004005-MINUTE (MIN
	j=j+1;sec4%r(j,s)= fYEAR(JDATE2)    !99) *004001-YEAR (A)
	j=j+1;sec4%r(j,s)= fMONTH(JDATE2)   !100)  004002-MONTH (MON)
	j=j+1;sec4%r(j,s)= fDAY(JDATE2)    !101)  004003-DAY (D)
	j=j+1;sec4%r(j,s)= fHOUR(JDATE2)    !102) *004004-HOUR (H)
	j=j+1;sec4%r(j,s)= fMINUTE(JDATE2)  !103)  004005-MINUTE (MIN)
	j=j+1;sec4%r(j,s)= mean            !104)  008023-RESERVED <- FIRST-ORDER STATISTICS (CODE TABLE)
	j=j+1;sec4%r(j,s)= 0               !105)  204008-ADD ASSOCIATED FIELD
	j=j+1;sec4%r(j,s)= FieldSig        !106)  031021-1-BIT INDICATOR OF QUALITY <- ASSOCIATED FIELD SIGNIFICANCE (CODE TABLE)
	j=j+1;sec4%r(j,s)=qtm(day)         !107)  999999-VALUE OF THE ASSOCIATED FIELD (SIZE =  8BITS)
	j=j+1;sec4%r(j,s)= TM(DAY)+CK      !108)  012101-TEMPERATURE/AIR TEMPERATURE (K)
	j=j+1;sec4%r(j,s)=  0              !109)  204000-ADD ASSOCIATED FIELD
	!}
	!}
	j=j+1;sec4%r(j,s)= undef()         !110) 008023-FIRST-ORDER STATISTICS (CODE TABLE)

	sec4%nvars=j
	end do
	!print *," :DAYCLI2BUFR:Nvars=",sec4%nvars
	call write_mbufr(2,sec1,sec3,sec4)
	
	if (len_trim(header)>0) call write_end_of_message(2)
	call close_mbufr(2)
        
    
    
    print *," ------------------"
	print *," :DAYCLI2BUFR: Done"
    print *," ------------------"

 
 
	stop
	contains
	!--------------------------------------------------------------------------
    !get_time_slot2:
    ! Retrieves start time and end time of time_slot for each reference date
    !--------------------------------------------------------------------------
	subroutine get_time_slot(year,month,day,ts,start_time,end_time)
	  integer,           intent(in)::year,month,day ! Reference date and time in LMTZ
	  type(time_slot),intent(inout)::ts
	  integer,          intent(out)::start_time,end_time
	  !real(8)::JDATE
	  ts%year=year
	  ts%month=month
	  ts%day=day
	  if(ts%dt==-1) then
	    start_time=-24
	    end_time=0
	  elseif(ts%dt==1) then
	    start_time=0
	    end_time=24
	  end if

	end subroutine
	!--------------------------------------------------------------------------
    !get_time_slot2:
    ! Retrieves start time and end time of time_slot for each reference date
    ! (Results based on julinan date and time)
    !--------------------------------------------------------------------------
	subroutine get_time_slot2(year,month,day,ts,JDATE1,JDATE2)
	  integer,           intent(in)::year,month,day ! Reference date and time in LMTZ
	  type(time_slot),intent(inout)::ts             ! Time slot
	  real(8),        intent(out)::JDATE1,JDATE2    ! Returns start time (DATE1) and end time (DATE2)

	  real(8)::JDATE

	  JDATE=fjulian(year,month,day,int(ts%hour),int(ts%minute),0)


	  if(ts%dt==-1) then   ! Case start date  = reference date - 1 day
	    JDATE1=JDATE-1.0
	    JDATE2=JDATE
	  elseif(ts%dt==1.0) then ! Case start date = referece date
	    JDATE1=JDATE
	    JDATE2=JDATE+1.0
	  else                   !Similar to the previous case
		JDATE1=JDATE
		JDATE2=JDATE+1.0
	  end if
	  if (ts%minute==1) JDATE2=JDATE2-1.0/60.0/24.0

	  ! The software considers the time interval as closed at both ends.
	  ! In this case the start time starts 1 minute after of the last mesurement
      ! Example: Interval  {T : Day 01 05:01 <= T <=  Day 02 05:00}]{
      !
      ! However, it is possible consider a opened start time  e.g. The time starts at same time of last measurement.
	  ! In this case: { T :Day 01 05:00 <  T <= Day 02 05:00} it also be possible.

	end subroutine

	subroutine undef_date_time(j,sec4)
		integer,intent(inout)::j
		type(sec4type),intent(inout)::sec4
		j=j+1;sec4%r(j,s)= undef()   ! Year
	    j=j+1;sec4%r(j,s)= undef()   ! 47)  004002-MONTH (MON)
		j=j+1;sec4%r(j,s)= undef()   ! 48)  004003-DAY (D)
		j=j+1;sec4%r(j,s)= undef()   ! 49) *004004-HOUR (H)
		j=j+1;sec4%r(j,s)= undef()   ! 50)  004005-MINUTE (MIN)
	end subroutine
end program 
!
!2025-05-26T08:00+5/2025-05-27T08:00+5 (local time, UTC+5) this would correspond to !!2025-05-26T03:00+0/2025-05-27T03:00+0 (UTC). In this case what should the reference time be
