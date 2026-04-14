module mdaycli
 use mbufr, only : undef, sec1type
 use stringflib
 use xmlparse
 implicit none
 public
 type WIGOSID
    integer::W1
    integer::W2
    integer::W3
    character(len=17)::W4
 end type




 type VarId
    integer         :: d
    character(len=4)::VarName
 end type

 type daycli_DateTime
   integer::lmtz_utc
   integer::year
   integer::month
   integer::day
   integer::hour
   integer::minute
   logical::defined
 end type

 type Daycli_var
   character(len=256)::fullname
   character(len=4)::varname
   character(len=16)::unit
   integer         ::d
   real            ::val
   integer         ::qc
   integer         ::timeSignificance
   type(daycli_datetime)::t1
   type(daycli_datetime)::t2
 end type

  type wmo_station_number
   integer::sblock
   integer::snumber
   logical::defined
  end type


  type daycli_data
      type(wigosid)::wigos
      type(wmo_station_number)::wmo
      real                    :: latitude
      real                    :: longitude
      real                    :: ha       !HEIGHT OF STATION GROUND ABOVE MEAN SEA LEVEL
      real                    :: htemp    !HEIGHT OF SENSOR ABOVE LOCAL GROUND (OR DECK OF MARINE PLATFORM) (M) - Temperature
      integer                 :: SMC_TEMP ! SITING AND MEASUREMENT QUALITY CLASSIFICATION FOR TEMPERATURE(CODE TABLE)
      integer                 :: SMC_PREC ! SITING AND MEASUREMENT QUALITY CLASSIFICATION FOR PRECIPITATION (CODE TABLE)
      integer                 :: method_tm! Method used to calculate the average daily temperature
      integer                 :: lmtz_utc
      type(daycli_DateTime)   :: rd       ! Reference Date
      type(daycli_var),allocatable::ddata(:)
  end type


 type(wmo_station_number) ::wmo
 type(daycli_DateTime)::rd,vdt     ! Reference date and time and time of instantaneous observation
 type(daycli_DateTime)::vdt1,vdt2  ! Start time and end time of a period
 type(WIGOSID) ::WIGOS,WIGOS_CUR
 type(daycli_data)::line
 type(VarId),dimension(20)::Var
 integer:: TimeSignificance
 integer:: Associated_field
 integer::lmtz_utc
 integer::FO_statistic          ! First Order statistic code table
 integer,parameter::maximum=2
 integer,parameter::minimum=3
 integer,parameter::mean=4
 real:: latitude
 real:: longitude
 real:: ha        !HEIGHT OF STATION GROUND ABOVE MEAN SEA LEVEL
 integer:: SMC_TEMP ! SITING AND MEASUREMENT QUALITY CLASSIFICATION FOR TEMPERATURE(CODE TABLE)
 integer:: SMC_PREC ! SITING AND MEASUREMENT QUALITY CLASSIFICATION FOR PRECIPITATION (CODE TABLE)
 integer:: method_tm! Method used to calculate the average daily temperature

 character(len=1),parameter::a='"'

 character(len=1),parameter::cr=char(13)

 type(daycli_var),dimension(6):: ddata
 private a,cr

!   rr  ! Total Acumulate Precipitation
!  tsd= Total Snow deph
!  tn = Minimum temperature
!  tx = Maximum temperature
!  tm = Mean temparature
 contains
 !
 ! WIGOS Identifier ="n-nnnnn-nnnnn-cccccccccccccccc"
 !
 function get_wigos(wigos); character(len=30)::get_wigos
    type(wigosid), intent (in)::wigos
    character(len=30)::aux
    character(len=5)::W1,W2,W3
    w1=strs(wigos%w1)
    w2=strs(wigos%w2)
    w3=strs(wigos%w3)
    aux=trim(w1)//"-"//trim(w2)//"-"//trim(w3)//"-"//trim(wigos%w4)
    get_wigos=aux
 end function

 subroutine init_mdaycli
  print *,"mdaycli has been initialized"
  var(1)%d=001001 !-WMO BLOCK NUMBER (NUMERIC)
  var(2)%d=001002 !-WMO STATION NUMBER (NUMERIC)
  var(3)%d=005001 !-LATITUDE (HIGH ACCURACY) (DEG)
  var(4)%d=006001 !-LONGITUDE (HIGH ACCURACY) (DEG)
  var(5)%d=007030 !-HEIGHT OF STATION GROUND ABOVE MEAN SEA LEVEL (M)
  var(6)%d=008095 !-SITING AND MEASUREMENT QUALITY CLASSIFICATION FOR TEMPERATURE (CODE TABLE)
  var(7)%d=008096 !-SITING AND MEASUREMENT QUALITY CLASSIFICATION FOR PRECIPITATION (CODE TABLE)
  var(8)%d=008094 !-METHOD USED TO CALCULATE THE A
  var(9)%d=008028 !-ATTRIBUTION DAY IN LOCAL METEOROLOGICAL TIME ZONE (LMTZ) <- EXTENDED TIME SIGNIFICANCE (COD
  var(10)%d=008025!-TIME DIFFERENCE QUALIFIER (CODE TABLE)
  var(11)%d=026003!-TIME DIFFERENCE (MIN)
  var(12)%d=004001!-YEAR (A)
  var(13)%d=004002! -MONTH (MON)
  var(14)%d=004003! -DAY (D)
  var(15)%d=008028! -TIME AT WHICH THE DAILY AND INSTANTANEOUS MEASUREMENT IS MADE (LMTZ) <- EXTENDED TIME SIGNI
  var(16)%d=004001! -YEAR (A)*
  var(17)%d=004002! -MONTH (MON)
  var(18)%d=004003! -DAY (D)
  var(19)%d=004004! -HOUR (H)
  var(20)%d=004005! -MINUTE (MIN)
  !              0.00000 #    25)  204008-ADD ASSOCIATED FIELD
  !              5.00000 #    26)  031021-ASSOCIATED FIELD SIGNIFICANCE (CODE TABLE)
  !              5.00000 #    27)  999999-PARAMETER IS NOT MEASURED AT THE STATION <- VALUE OF THE ASSOCIATED FIELD
  !                 Null #    28)  013013-TOTAL SNOW DEPTH (M)
  !              0.00000 #    29)  204000-ADD ASSOCIATED FIELD
  !             41.00000 #    30)  008028-PERIOD OVER WHICH THE DAILY MEASUREMENT IS MADE (LMTZ) <- EXTENDED TIME SIGNIFICANCE (CODE
  !           2021.00000 #    31) *004001-YEAR (A)
  !             12.00000 #    32)  004002-MONTH (MON)
  !             31.00000 #    33)  004003-DAY (D)
  !             12.00000 #    34) *004004-HOUR (H)
  rd%defined=.false.
  vdt%defined=.false.
  vdt1%defined=.false.
  vdt2%defined=.false.
  associated_field=0
  ddata(1)%varname='TSD';ddata(1)%d=013013;ddata(1)%unit="m";ddata(1)%fullname="Total snow deph"
  ddata(2)%varname='RR' ;ddata(2)%d =013060;ddata(2)%unit="Kg.m^-2"; ddata(2)%fullname="Total acumulated precipitation"
  ddata(3)%varname='DS' ;ddata(3)%d =013012;ddata(3)%unit="m" ;ddata(3)%fullname="Death of fresh snow"
  ddata(4)%varname='Tx' ;ddata(5)%d =012101;ddata(5)%unit="K" ;ddata(5)%fullname="Maximum temperature"
  ddata(5)%varname='Tn' ;ddata(4)%d =012101;ddata(4)%unit="K" ;ddata(4)%fullname="Minimum temperature"
  ddata(6)%varname='Tm' ;ddata(6)%d =012101;ddata(6)%unit="K" ;ddata(6)%fullname="Mean temparature"
  allocate(line%ddata(1:6))
  FO_STATISTIC=0
end subroutine


!---------------------------------------------------------------------------------------!
! Receive a descritor d , the corresponded value  'v' and the current timeSignificance !                                                                         !
! Acoording descriptor and time siginificance, set the respective date parameter
! (year, month, day, etc)
!
!  Public variable
!   rd = Reference date
!   vdt1 = Start time
!   lmtz_utc
!
!  Descriptors from 4001 to 4005
!-----------------------------------------------------------------------------!
subroutine set_daycli_DateTime(d,v,timeSignificance)
 integer, intent(in)::d
 integer,intent(in)::v
 integer,intent(in)::timeSignificance
 !{ If date and time descritor
 if ((d>4000).and.(d<4010)) then
   !{ If atribution day
   if (timeSignificance==40) then  !ATTRIBUTION DAY IN LOCAL METEOROLOGICAL TIME ZONE (LMTZ)
      if (d==4001) rd%year=v
      if (d==4002) rd%month=v
      if (d==4003) then
         rd%day=v
         !write(*,'("Reference Date=",i4.4,2i2.2)')rd%year,rd%month,rd%day
         rd%lmtz_utc=lmtz_utc
         rd%defined=.true.
     end if

   !}
   !{ If instantaneous date
   elseif (timeSignificance==42) then !TIME AT WHICH THE DAILY AND INSTANTANEOUS MEASUREMENT IS MADE (LMTZ)
      if (d==4001) vdt1%year=v
      if (d==4002) vdt1%month=v
      if (d==4003) vdt1%day=v
      if (d==4004) vdt1%hour=v
      if (d==4005) then
         vdt1%minute=v
         !write(*,'("Date and Time =",i4.4,2i2.2,"T",2I2.2)')vdt%year,vdt%month,vdt%day,vdt%hour,vdt%minute
         vdt1%defined=.true.
         vdt1%lmtz_utc=lmtz_utc
      end if
   !}
   !{ If periord
   elseif (timeSignificance==41) then !PERIOD OVER WHICH THE DAILY MEASUREMENT IS MADE (LMTZ)
      !{ If start time
      if (.not. vdt1%defined) then
      !{
         if (d==4001) vdt1%year=v
         if (d==4002) vdt1%month=v
         if (d==4003) vdt1%day=v
         if (d==4004) vdt1%hour=v
         if (d==4005) then
         !{
            vdt1%minute=v
            vdt1%defined=.true.
            vdt1%lmtz_utc=lmtz_utc
           ! write(*,'("Start Date and Time =",i4.4,2i2.2,"T",2I2.2)')vdt1%year,vdt1%month,vdt1%day,vdt1%hour,vdt1%minute
         !}
         end if
       !}
       !{ if end time
       else

         if (d==4001) vdt2%year=v
         if (d==4002) vdt2%month=v
         if (d==4003) vdt2%day=v
         if (d==4004) vdt2%hour=v
         if (d==4005) then
         !{
            vdt2%minute=v
            vdt2%defined=.true.    !Set as true to indicate that the start time and and time were provided
            vdt1%defined=.false.   !Set as false to prepare the subroutine for the next start time
            vdt2%lmtz_utc=lmtz_utc
           ! write(*,100)vdt1%year,vdt1%month,vdt1%day,vdt1%hour,vdt1%minute, vdt2%year,vdt2%month,vdt2%day,vdt2%hour,vdt2%minute
         !}
        end if
      end if !} End if time period
   end if !} End of date and time descritor
   else
     vdt1%defined=.false.
     vdt2%defined=.false.
   end if
100 format ("Period = ",i4.4,2i2.2,"T",2I2.2," - ",i4.4,2i2.2,"T",2I2.2)
end subroutine

!-----------------------------------------------------------------------------!
!                                                                             !
!                                                                             !
!-----------------------------------------------------------------------------!
subroutine write_line(un,line)
   integer,intent(in)::un
   type(daycli_data),intent(in)::line
   character(len=255)::auxc
   integer::x
   auxc=trim(strs(line%wigos%w1))//"-"//trim(strs(line%wigos%w2))//"-"//trim(strs(line%wigos%w3))//"-"//line%wigos%w4
   write(un,*)"{"
   write(un,*)"   WIGOS                 =",trim(auxc),","
   write(auxc,'(i2.2,i3.3,",")')line%wmo%sblock,line%wmo%snumber
   write(un,*)"   WMO                   =",trim(auxc)
   write(un,'("    Latitude              =",f10.5,",")')line%latitude
   write(un,'("    Longitude             =",f10.5,",")')line%longitude
   write(un,'("    ha (m)                =",f7.2,",")') line%ha
   write(un,'("    htemp (m)             =",f7.2,",")') line%htemp
   write( un,'(a)') fformat('("    SMC_TEMP (code table) =",i3.3,",")',line%SMC_TEMP)  ! SITING AND MEASUREMENT QUALITY CLASSIFICATION FOR TEMPERATURE(CODE TABLE)
   write(un,'("    SMC_PREC (code table) =",i3.3,",")') line%SMC_PREC ! SITING AND MEASUREMENT QUALITY CLASSIFICATION FOR PRECIPITATION (CODE TABLE)
   write(un,'("    METHOD_TM (code table)=",I3.3,",")') line%METHOD_TM !method_tm! Method used to calculate the average daily temperature
   write(un,'("    TIME_OFFSET (minutes) =",I3.3,",")') line%lmtz_utc
   write(un,'("    Reference date (LMTZ) =",i4.4,2i2.2,",")')line%rd%year,line%rd%month,line%rd%day
   do x=1,6

       if (((line%ddata(x)%val==undef()).and.(line%ddata(x)%qc==255))) goto 300
         write(un,*)"{"
         write(un,*)"varname="//trim((line%ddata(x)%varname))//","
         write(un,*)"unit="//trim((line%ddata(x)%unit))//","
         write(un,*)"time="//trim(write_datetime(line%ddata(x)))
         if (line%ddata(x)%val==undef()) then
            write(un,'(5x,a)')"value= ,"
         else
            write(un,'(5x,"value=",f7.2,a)')line%ddata(x)%val,","
         end if
         if (line%ddata(x)%qc==255) then
            write(un,'(5x,a)')"quality= ,"
         else
            write(un,'(5x,a)')"quality="//trim(strs(line%ddata(x)%qc))//","
         end if
         write(un,'(3x,a)')"}"


    300 continue
   end do

  write(un,*)"}"


end subroutine


!-----------------------------------------------------------------------------!
!                                                                             !
!                                                                             !
!-----------------------------------------------------------------------------!
subroutine write_line2(un,sec1,line)

   !Interface{
   type(sec1type),   intent(in)::sec1
   integer,          intent(in)::un
   type(daycli_data),intent(in)::line
   !}
   !Local Variables{
   character(len=255) ::auxc
   integer            ::x
   character(len=5000)::xline
   !}

   if (.not.wigos1_eq_wigos2(WIGOS_CUR,WIGOS)) then
     !{Section 1
     write(un,'(a9)')'&SECTION1'
     auxc="     !<-Identification of Originating/Generating center (See commom code table C1 and C11 )"
     write(un,'("CENTER=",I3,a)')sec1%center,trim(auxc)
     !}
     !{Section 4 - Station ID informations
     auxc=trim(strs(line%wigos%w1))//"-"//trim(strs(line%wigos%w2))//"-"//trim(strs(line%wigos%w3))//"-"//line%wigos%w4
     auxc="  !<-Sub-center of generating center (See common code C12)"
     write(un,'("SUBCENTER=",i3,a)')sec1%subcenter,trim(auxc)
     write(un,'(a1)')'/'
     write(un,'(a)')'! Note: space    <- Missing value'

      write(un,'(a)')'!-------------------------'
      write(un,'(a)')'! Location identification'
      write(un,'(a)')'!-------------------------'
      write(un,'(a)')'&STATION_ID'
      write(un,'("LATITUDE=",f10.5)')line%latitude
      write(un,'("LONGITUDE=",f10.5)')line%longitude
      auxc=trim(strs(line%wigos%w1))//"-"//trim(strs(line%wigos%w2))//"-"//trim(strs(line%wigos%w3))//"-"//line%wigos%w4
      write(un,'(a)')'WIGOS='//trim(auxc)
      write(un,'("WMO=",i2.2,i3.3)')line%wmo%sblock,line%wmo%snumber
      write(un,'("HTEMP=",i3," ! Hight of temperature sensor")')int(line%htemp)
      write(un,'("HA=",i3,"    ! 007030-HEIGHT OF STATION GROUND ABOVE MEAN SEA LEVEL")')int(line%ha)
      auxc=" ! 008095-SITING AND MEASUREMENT QUALITY CLASSIFICATION FOR TEMPERATURE(CODE TABLE)"
      write(un,'(a)') trim(fformat('("SMC_TEMP=",i3.3)',line%SMC_TEMP))// auxc
      auxc=" ! 008096-SITING AND MEASUREMENT QUALITY CLASSIFICATION FOR PRECIPITATION (CODE TABLE)"
      write(un,'(a)') trim(fformat('("SMC_PREC=",i3.3)',line%SMC_PREC))//auxc
      auxc=" ! 008094-Method used to calculate the average daily temperature"
      write(un,'(a)') trim(fformat('("METHOD_TM=",i5)',line%METHOD_TM))//auxc
      auxc="! Time difference in minutes:  Local Meteorological Time Zone - UTC (LMTZ-UTC)"
      write(un,'("TIME_OFFSET=",I4,a)') line%lmtz_utc,auxc
      write(un, '(a)')'                ! Use 0 in case of the use of UTC values'
      write(un,'(a1)')"/"
      WIGOS_CUR=WIGOS
      !}

      write(un,'(a)')'!----------------------------------------------------------------------------------'
      write(un,'(a)')'! Note: In this text file, Each parameter is identified by the followed Acronyms:'
      write(un,'(a)')'! parameter = name, unit, scale'
      write(un,'(a)')'!  rr = Total Acumulate Precipitation, Kg m-2 (= mm), 1'
      write(un,'(a)')'!  fsd = Fresh snow depth, m, 2'
      write(un,'(a)')'!  tsd= Total snow depth, m, 2'
      write(un,'(a)')'!  tx = Maximum temperature, K, 2'
      write(un,'(a)')'!  tn = Minimum temperature, K, 2'
      write(un,'(a)')'!  tm = Mean temperature, K, 2'
      write(un,'(a)')'!  The quality flag for each respective parameter above are identified by:'
      write(un,'(a)')'!  qrr, qfsd, qtsd,qtn,qtx,qtm'
      write(un,'(a)')'!'
      write(un,'(a)')'!  The value of quality flag are:'
      write(un,'(a)')'!   0 = Data checked and declared good;'
      write(un,'(a)')'!   1 = Data checked and declared suspect;'
      write(un,'(a)')'!   2 = Data checked and declared aggregated;'
      write(un,'(a)')'!   3 = Data checked and declared out of instrument range;'
      write(un,'(a)')'!   4 = Data checked, declared aggregated, and out of instrument range;'
      write(un,'(a)')'!   5 = Parameter is not measured at the station;'
      write(un,'(a)')'!   6 = Daily value not provided;'
      write(un,'(a)')'!   7 = Data unchecked,'
      write(un,'(a)')'!   8-254 = Reserved;'
      write(un,'(a)')'!---------------------------------------------------------------------------------'
      write(un,'(a)')'&DATA_SECTION'
      write(un,'(a)')'!rdate= Reference date and time in LMTZ / Attribution Day'
      write(un,'(a)')'!intertval = time interval for next variable'
      write(un,'(a)')'!date;interval;tsd;qtsd;interval;rr;qrr;interval;fsd;qfsd;interval;tx;qtx;interval;tn;qtn;interval;tm;qtm'
      write(un,'(a)')""
   endif
   write(xline,'(i4.4,2i2.2,";")')line%rd%year,line%rd%month,line%rd%day
   do x=1,6

       if (((line%ddata(x)%val==undef()).and.(line%ddata(x)%qc==255))) goto 300
         xline=trim(xline)//trim(write_datetime(line%ddata(x)))//";"
         if (line%ddata(x)%val==undef()) then
            auxc=""
         else
            write(auxc,'(f7.2)')line%ddata(x)%val
         end if
         xline=trim(xline)//trim(auxc)//";"

         if (line%ddata(x)%qc==255) then
            auxc=""
         else
            auxc=trim(strs(line%ddata(x)%qc))
         end if
         xline=trim(xline)//trim(auxc)
         if (x<6)xline=trim(xline)//";"
    300 continue
   end do
   write(un,'(a)')trim(xline)



end subroutine
!-----------------------------------------------------------------------------!
!                                                                             !
!                                                                             !
!-----------------------------------------------------------------------------!
subroutine write_xml(un,subset)
   integer,intent(in)::un
   type(daycli_data),intent(in)::subset
   character(len=255)::auxc
   integer::x
   character(len=1),parameter::a='"'
   character(len=1),parameter::cr=char(13)
   auxc=trim(strs(subset%wigos%w1))//"-"//trim(strs(subset%wigos%w2))//"-"//trim(strs(subset%wigos%w3))//"-"//subset%wigos%w4
   write(un,'(2x,a)')"<subset>"//cr
   write(un,'(4x,a)')"<weather_station"//cr
   write(un,'(6x,a)')"WIGOS="//a//trim(auxc)//a//cr
   write(auxc,'(a1,i2.2,i3.3,a1)')a,subset%wmo%sblock,subset%wmo%snumber,a
   write(un,'(6x,a)')"WMO="//trim(auxc)//cr
   write(un,'(6x,"Latitude=",a1,f10.5,a2)')a,subset%latitude,a//cr
   write(un,'(6x,"Longitude=",a1,f10.5,a2)')a,subset%longitude,a//cr
   write(un,'(6x,"ha=",a1,f7.2,a2)')a,subset%ha,a//cr
   write(un,'(6x,"htemp=",a1,f7.2,a2)')a,subset%htemp,a//cr
   write(un,'(6x,"SMC_TEMP=",a1,i3.3,a2)') a,subset%SMC_TEMP,a//cr
   write(un,'(6x,"SMC_PREC=",a1,i3.3,a2)') a,subset%SMC_PREC,a//cr
   write(un,'(6x,"METHOD_TM=",a1,I3.3,a1,"/>",a1)') a,subset%METHOD_TM,a,cr
   write(un,901)a,subset%lmtz_utc,a,a,subset%rd%year,subset%rd%month,subset%rd%day,a,cr
901 format(4x,"<Reference_date time_difference=",a1,I3.3,a1," date=",a1,i4.4,2i2.2,a1,"/>",a1)
   do x=1,6

      if (((subset%ddata(x)%val==undef()).and.(subset%ddata(x)%qc==255))) goto 300
         write(un,'(4x,a)')"<element name="//a//trim(subset%ddata(x)%varname)//a//cr
         write(un,'(6x,a)')"fullname="//a//trim(subset%ddata(x)%fullname)//a//cr
         write(un,'(6x,a)')"unit="//a//trim(subset%ddata(x)%unit)//a//cr
         write(un,'(6x,a)')trim(write_datetime_xml(subset%ddata(x)))
         if (subset%ddata(x)%qc==255) then
            auxc="quality="//a//"null"//a//">"
         else
            auxc="quality="//a//trim(strs(subset%ddata(x)%qc))//a//">"
         end if

         if (line%ddata(x)%val==undef()) then
            write(un,'(6x,a)')trim(auxc)//"</element>"//cr
         else
            write(un,'(6x,a,f7.2,"</element>",a1)')trim(auxc),line%ddata(x)%val,cr
         end if


    300 continue
   end do

 write(un,'(2x,a)')"</subset>"//cr
end subroutine

!-----------------------------------------------------------------------------!
!                                                                             !
!                                                                             !
!-----------------------------------------------------------------------------!
subroutine close_xml(un)
 integer,intent(in)::un
 write(un,'(2x,a)')"</daycli>"//cr
  print *,"Daycli Ok"
end subroutine

!-----------------------------------------------------------------------------!
!                                                                             !
!                                                                             !
!-----------------------------------------------------------------------------!
subroutine write_xml_header(un)
 integer,intent(in)::un
 print *,"OPTIONS: dataout in xml"
 write(2,'(a)') '<?xml version="1.0"?>'
 write(2,'(3x,a)') '<!-- Identification of Originating/Generating center (See commom code table C1 and C11 )-->'
 write(2,'(3x,a)') '<!-- Sub-center of generating center (See common code C12)-->'
 write(2,'(3x,a)') '<!-- HTEMP        !Highr of temperature sensor'
 write(2,'(6x,a)') 'HA=          !007030-HEIGHT OF STATION GROUND ABOVE MEAN SEA LEVEL'
 write(2,'(6x,a)') 'SMC_TEMP     !008095-SITING AND MEASUREMENT QUALITY CLASSFICATION FOR TEMPERATURE'
 write(2,'(6x,a)') 'SMC_PREC     !008096-SITING AND MEASUREMENT QUALITY CLASSIFICATION FOR PRECIPITAION'
 write(2,'(6x,a)') 'METHOD_TM    !008094-Method used to calculate the average daily temperature'
 write(2,'(9x,a)') 'time_difference !Time difference in minutes:  Local Meteorologica Time Zone - UTC (LMTZ-UTC)'
 write(2,'(6x,a)') '!Use 0 in case of the use of UTC values'
 write(2,'(6x,a)') '-->'
end subroutine

!-----------------------------------------------------------------------------!
!                                                                             !
!                                                                             !
!-----------------------------------------------------------------------------!
subroutine writesec1_xml(un,sec1)
 integer,intent(in)::un
 type(sec1type),intent(in)::sec1
 write(un,'(2x,a)')"<daycli>"
 write(un,11)sec1%center,sec1%subcenter,sec1%year,sec1%month
 11 format(2x,'<sec1 center="',i3,'" subcenter="',i3,'" year="',i4.4,'" month="',I2.2,'" day="0" />')
 print *,sec1%center
end subroutine

!-----------------------------------------------------------------------------!
!                                                                             !
!                                                                             !
!-----------------------------------------------------------------------------!
function write_datetime_xml(var); character(len=255)::write_datetime_xml
   type(daycli_var),intent(in)::var
   integer::y1,m1,d1,h1,n1
   integer::y2,m2,d2,h2,n2
   character(len=1),parameter::a='"'
   if (var%t1%year==0) then
     if (var%TimeSignificance==41) then
      write_datetime_xml="period="//a//"null"//a
       return
     elseif (var%TimeSignificance==42 )then
       write_datetime_xml="time="//a//"null"//a
       return
     else
       write_datetime_xml=""
     end if
   end if
   if (var%TimeSignificance==41) then
      y1=var%t1%year
      m1=var%t1%month
      d1=var%t1%day
      h1=var%t1%hour
      n1=var%t1%minute
      y2=var%t2%year
      m2=var%t2%month
      d2=var%t2%day
      h2=var%t2%hour
      n2=var%t2%minute
      write(write_datetime_xml,100)a,y1,m1,d1,h1,n1,y2,m2,d2,h2,n2,a
   elseif(var%TimeSignificance==42) then
      y1=var%t1%year
      m1=var%t1%month
      d1=var%t1%day
      h1=var%t1%hour
      n1=var%t1%minute
       write(write_datetime_xml,101)a,y1,m1,d1,h1,n1,a
   else
      y1=var%t1%year
      m1=var%t1%month
      d1=var%t1%day
       write(write_datetime_xml,102)y1,m1,d1
   end if
 100 format ("period=",a1,i4.4,2i2.2,"T",2I2.2,"-",i4.4,2i2.2,"T",2I2.2,a1)
 101 format ("time=",a1,i4.4,2i2.2,"T",2I2.2,a1)
 102 format (i4.4,2i2.2)
end function

!-----------------------------------------------------------------------------!
! function                                                                    !
! write_datetime                                                              !
!-----------------------------------------------------------------------------!
function write_datetime(var); character(len=255)::write_datetime

   type(daycli_var),intent(in)::var
   integer::y1,m1,d1,h1,n1
   integer::y2,m2,d2,h2,n2

   if (var%t1%year==0) then
    write_datetime=""
    return
   end if
   if (var%TimeSignificance==41) then
      y1=var%t1%year
      m1=var%t1%month
      d1=var%t1%day
      h1=var%t1%hour
      n1=var%t1%minute
      y2=var%t2%year
      m2=var%t2%month
      d2=var%t2%day
      h2=var%t2%hour
      n2=var%t2%minute
      write(write_datetime,100)y1,m1,d1,h1,n1,y2,m2,d2,h2,n2
   elseif(var%TimeSignificance==42) then
      y1=var%t1%year
      m1=var%t1%month
      d1=var%t1%day
      h1=var%t1%hour
      n1=var%t1%minute
       write(write_datetime,101)y1,m1,d1,h1,n1
   else
      y1=var%t1%year
      m1=var%t1%month
      d1=var%t1%day
       write(write_datetime,102)y1,m1,d1
   end if
 100 format (i4.4,2i2.2,"T",2I2.2,"-",i4.4,2i2.2,"T",2I2.2)
 101 format (i4.4,2i2.2,"T",2I2.2)
 102 format (i4.4,2i2.2)
end function

!------------------------------------------------------------
!   Check if WIGOS1 EQUAL WIGOS2  and return .true. or .false
!-------------------------------------------------------------
logical function wigos1_eq_wigos2(wigos1,wigos2)
   type(wigosid),intent(in)::wigos1
   type(wigosid),intent(in)::wigos2
   logical::t
   t=.false.
   if (wigos1%W1==wigos2%w1) then
      if (wigos1%w2==wigos2%w2) then
         if (wigos1%w3==wigos2%w3) then
          if (trim(wigos1%w4)==trim(wigos2%w4)) then
             t=.true.
          end if
         end if
      end if
   end if
   wigos1_eq_wigos2=t
end function

function fformat(output_format,ivalue); character(len=255)::fformat
  character(len=*),intent(in)::output_format
  integer,intent(in)::ivalue
   write(fformat,output_format)ivalue
   if (index(fformat,"*")>0)  fformat=remove_char(fformat,"*")
   fformat=trim(fformat)
end function
end module
