program daycli_decoder
!------------------------------------------------------------------------------!
!DAYCLI_DECODER| DECODES DATA IN BUFR FORMAT                             |INPE |
!------------------------------------------------------------------------------|
!                                                                              |
! THIS PROGRAM READ BUFR FILES OF DAYCLI DATA (Template 307095 )               |
! AND WRITES THE DATA IN A TEXT FILE  (Format 2) used by daycli_coder2         |
!                                                                              |
! Sergio H. S. Ferreira (SHSF)     (sergio.ferreira@inpe.br)                   |
!------------------------------------------------------------------------------|
!Dependencies : MBUFR-ADT,STRINGFLIB,MDAYCLI                                   |
!------------------------------------------------------------------------------!
!History
!  2025 SHSF. Version 2.0
!                     
 USE mbufr
 use stringflib
 use mdaycli
 !USE msflib  ! FOR USE WITH MICROSOFT POWER STATION
 implicit none

!{ Declaracao das variaveis utilizadas em read_mbufr 
  integer :: nss
  type(sec1type):: sec1
  type(sec3type):: sec3 
  type(sec4type):: sec4
  integer       :: NBYTES,BUFR_ED 
  integer       :: err
  logical       :: option_xml
!}


!{ AUXILIARY VARIABLES OF MAIN PROGRAM/variaveis auxiliares do progrma principal
  integer                             ::i,f,J,nsubsets,s,v,c
  character(len=255)::infile,outfile,auxc

  integer                             ::nmm !MAXIMUM NUMBER OF MESSAGES/Numero maximo de mesagens
  integer                             ::nm  !NUMBER OF BUFR MESSAGES/Numero de mensagens bufr
  integer*2                           ::numchar
  integer                             ::icod
  integer                             ::father_code ! BUFR code after the reaplication factor
  integer                             ::first_son_code
  integer                             ::replication_factor
  integer                             ::replication_index
  integer                             ::nbits
  character(len=50)                   ::ncod
  character(len=255)::TXT,TXT2
  character(len=258)::AUXTXT
  character(len=50),dimension(1:11) :: Mat
  integer :: icenter,auxi
  integer :: imaster_table
  integer :: ilocal_table
  integer :: x,a
  logical :: exists
  real                                ::null  ! Valor indefinido 
!}

	null=undef()
	call welcome (infile,outfile)
    call init_mdaycli
	NBYTES = 0
	open(2,file=outfile,status='unknown')

	Call OPEN_MBUFR(1, infile)

	print *,":DAYCLI_DECODER:Input BUFR file=",trim(infile)
	print *,":DAYCLI_DECODER:Output file=",trim(outfile)

	nm=0
	father_code=0
	first_son_code=0
	replication_index=0


10	CONTINUE
	father_code=0
	replication_index=0
	Call READ_MBUFR(1,sec1,sec3,sec4, bUFR_ED, NBYTES,err)

	If ((NBYTES > 0).and.(IOERR(1)==0)) Then

      !{ Check if it is a DAYCLI MESSAGE
		exists=.false.
		do i=1,sec3%ndesc
          if (sec3%d(i)==307095) then
            exists=.true.
            exit
          end if
        end do

        if (.not.exists ) then
          print *, ":DAYCLI_DECODES: Looking for DAYCLI messages: Template 307095"
          goto 10
        else
          nm=nm+1
          nsubsets=sec3%nsubsets
          print *,":DAYCLI_DECODES:Decoding DAYCLI message n=",nm
          print *,":DAYCLI_DECODES:Decoding DAYCLI n.subsets=",nsubsets
        end if
       !}

        !--------------------------
        ! Decoding a daycli message
        ! -------------------------
        ! outer loop (subsets) {

        WIGOS_CUR%W3=0
		do s=1,nsubsets
            WIGOS%W4=""
            timeSignificance=0
            a=0

            !Inner loop (variables) {
			do v=1,sec4%nvars
             !{ cases
             select case(sec4%d(v,s))

            case(001125) !WIGOS IDENTIFIER SERIES (NUMERIC)
                WIGOS%W1=sec4%r(v,s)

             case(001126) !WIGOS ISSUER OF IDENTIFIER    (NUMERIC)
                WIGOS%W2=sec4%r(v,s)

             case(001127) !WIGOS ISSUE NUMBER (NUMERIC)
                WIGOS%W3=sec4%r(v,s)

             case(001128) !WIGOS LOCAL IDENTIFIER (CHARACTER) (CCITTIA5))
                 c=sec4%c(v,s)
                 WIGOS%W4(c:c)=char(int(sec4%r(v,s)))
                 if (c==16) then
                   line%wigos=WIGOS
                 end if
            case(001001) !-WMO BLOCK NUMBER (NUMERIC)
              line%wmo%sblock=int(sec4%r(v,s))
              line%wmo%defined=.false.
            case(001002) !-WMO STATION NUMBER (NUMERIC)
               line%wmo%snumber=int(sec4%r(v,s))
               line%wmo%defined=.true.
            case(005001) !-LATITUDE (HIGH ACCURACY) (DEG)
              line%latitude=(sec4%r(v,s))
            case(006001)!-LONGITUDE (HIGH ACCURACY) (DEG)
              line%longitude=(sec4%r(v,s))
            case(007030) !-HEIGHT OF STATION GROUND ABOVE MEAN SEA LEVEL (M)
              line%ha=(sec4%r(v,s))
            case(007032) !-HEIGHT OF SENSOR ABOVE LOCAL GROUND (OR DECK OF MARINE PLATFORM) (M)
              line%htemp=(sec4%r(v,s))
            case(008095) !-SITING AND MEASUREMENT QUALITY CLASSIFICATION FOR TEMPERATURE (CODE TABLE)
              line%SMC_TEMP=int(sec4%r(v,s))
            case(008096) !-SITING AND MEASUREMENT QUALITY CLASSIFICATION FOR PRECIPITATION (CODE TABLE)
              line%SMC_PREC=int(sec4%r(v,s))
            case(008094) !<- Method used to calculate the average daily temperature
              line%method_tm=int(sec4%r(v,s))
             case(008028) ! SET EXTENDED TIME SIGNIFICANCE
                 timeSignificance=sec4%r(v,s)

                 !{ initialization of reference date (rd) and time windows (vdt, vdt1, vdt2)
                   rd%defined=.false.
                   vdt%defined=.false.
                   vdt1%defined=.false.
                   vdt2%defined=.false.
                 !}
             case(008023)
                if (sec4%r(v,s)>=0) then
                  FO_STATISTIC=int(sec4%r(v,s))
                else
                 FO_STATISTIC=0
                end if
             case(31021)! Associated Field SIGNIFICANCE
                Associated_Field=sec4%r(v,s)
                if (sec4%r(v+1,s)<0) then
                  Associated_Field=255
                else
                  Associated_field=sec4%r(v+1,s)
                end if
                a=a+1

             case (026003) ! lmtz-utc (minutes)
                line%lmtz_utc=sec4%r(v,s)
             end select

             !{ Date and time: set or cancel vdt1,vdt2 and rd
              if (timeSignificance>0) then
                  if ((sec4%d(v,s)>4000).and.(sec4%d(v,s)<4006)) then

                   ! checking missing date values.
                   ! Missing date is possible in case of variable not provided by station
                   !{
                    if (sec4%r(v,s)<0) then
                      auxi=0
                    else
                      auxi=int(sec4%r(v,s))
                    end if
                    !}

                    call set_daycli_DateTime(sec4%d(v,s),auxi,timeSignificance)
                    if (timeSignificance==40) line%rd=rd

                else
                    vdt1%defined=.false.
                    vdt2%defined=.false.
                end if
              endif
              !}
               !-----------------------------------------------------
               !Getting variables and time widowns from the template
               !---------------------------------------------------
               !  x | Variables
               !----+-----------------------------------------------
               !  1 |rr = Total Acumulate Precipitation
               !  2 |ds = Fresh snow
               !  3 |tsd= Total Snow deph
               !  4 |tx = Maximum temperature
               !  5 |tn = Minimum temperature
               !  6 |tm = Mean temparature
               !----+-----------------------------------------------
              do x =1,3
                if (sec4%d(v,s)==ddata(x)%d) then
                  ddata(x)%val=sec4%r(v,s)
                  ddata(x)%qc=Associated_Field_sig(sec4,v,s)
                  ddata(x)%timeSignificance=timeSignificance
                  ddata(x)%t1=vdt1
                  if (timeSignificance==41)ddata(x)%t2=vdt2
                end if
              end do

              if (sec4%d(v,s)==ddata(4)%d) then
                if(FO_STATISTIC==minimum) x=5
                if(FO_STATISTIC==maximum) x=4
                if(FO_STATISTIC==mean) x=6
                ddata(x)%val=sec4%r(v,s)
                ddata(x)%qc=Associated_Field_sig(sec4,v,s)
                ddata(x)%timeSignificance=timeSignificance
                ddata(x)%t1=vdt1
                if (timeSignificance==41)ddata(x)%t2=vdt2
              end if

            end do !} End of inerloop  (variables)
			!}
			!line%tsd=ddata(1)
			line%ddata=ddata

            call write_line2(2,sec1,line)

		end do !} Outer loop (subset)


		deallocate(sec3%d,sec4%r,sec4%d,sec4%c)
		goto 10
	end if
 close(2)
 call Close_mbufr (1)
 print *,":DAYCLI_DECODES:Done"

!}
stop

contains
!-----------------
! WELCOME
!-----------------
subroutine welcome(infile,outfile)
 !{Interface variables
  character(len=*),intent(out)::infile
  character(len=*),intent(out)::outfile
 !}

 !{ local variables
  integer                          ::CK,X1,X2
  character(len=1),dimension(10)   ::namearg ! Argments names
  character(len=1024),dimension(10)::arg     ! Argments values
  integer                          ::nargss  ! Number of argments
  !}
   CK=0
   X1=0
   X2=0

   call getarg2(namearg,arg,nargss)
   do i=1, nargss

      if (namearg(i)=="i") then
        infile=arg(i)
        x1=1
      end if

      if (namearg(i)=="o") then
        outfile=arg(i)
        x2=1
      end if

   end do

  print *,"+---------------------------------------------------------------------+"
  print *,"| INPE DAYCLI_DECODER: decode DAYCLI messages in BUFR4 (3-07-095)     |"
  print *,"| Autor: sergio.ferreira@inpe.br - Version 2.0 2025                   |"
  print *,"| Include MBUFR-ADT module ",MBUFR_VERSION,"                  |"

 if ((x1*X2)==0) then
  print *,"+---------------------------------------------------------------------+"
  print *,"| use daycli_decoder -i <infile> -o <outfile>                         |"
  print *,"|   infile:= input bufr file name                                     |"
  print *,"|   outfile:= outpur file name (txt)                                  |"
  print *,"|                                                                     |"
  print *,"+---------------------------------------------------------------------+"
	stop
 else
  print *,"+---------------------------------------------------------------------+"
   end if
end subroutine

function Associated_field_sig(sec4,v,s); integer::Associated_field_sig

 type(sec4type),intent(in)::sec4
 integer,intent(in)::v,s
    !print *,"d=",sec4%d(v,s),sec4%d(v-1,s),sec4%r(v-1,s)
  if (sec4%d(v-1,s)==999999) then
    if (sec4%r(v-1,s)<0) then
      Associated_Field_sig=255
    else
      Associated_Field_sig=int(sec4%r(v-1,s))
      !print *,"d=",sec4%d(v,s),sec4%d(v-1,s),sec4%r(v-1,s)
    end if
  else
    Associated_Field_sig=255
  end if

  end function

End


