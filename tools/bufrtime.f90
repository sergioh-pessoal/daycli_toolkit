program mbufr_time
!******************************************************************************
!* MBUFR_TIME ! Check time window of a BUFR file              !MCT-INPE-CPTEC *
!******************************************************************************
!       VERSAO 1.1
!*****************************************************************************  
! 1 - General description
!
! This program reads date and time of each BUFR section 1 in the set of BUFR messages and
! return the time window of the set
!-------------------------------------------------------------------------------
!   Historical review
! 
!ABRIR 2006  - SERGIO H. - Original version
!SHSF 2011-01-18 : Modificado para poder verificar presenca de estacoes (ainda nao concluido)           



USE MBUFR
!USE MSFLIB  ! Para compilacao em Windows ( Microsoft Power Station )
USE DATELIB 
USE STRINGFLIB, only:replace ,getarg2,val
implicit none

!{ Declaracao das variaveis utilizadas em read_mbufr 
  type(sec1type)               ::sec1
  type(sec3type)               ::sec3                         
  type(sec4type)               ::sec4
  integer                      ::MBYTES,BUFR_ED         
  integer                      ::err
  Real,parameter               ::Null=-340282300   !valor nulo 
  type(selecttype),dimension(1)::select     
  integer,dimension(10)        ::col               ! Colunas para impressao
  integer                      ::v,s               !indices para variavel e subsets  
!} 


real*8::date_min,date_max,cdate
character(len=19)::labelmax,labelmin
integer*4 ::argc,i
integer::iargc,nfiles
integer::nm                                   ! Numero de mensagens
character(len=255),dimension(1000)::flist    ! Lista de arquivos de entrada 
character(len=255)::outfile                  ! Nome do arquivo de saida
character(len=255)::infile 
integer                             ::yy,mm,dd,hh,mn
integer                             ::X1
logical                             ::check_sec4
integer                             ::narg
character(len=1),dimension(10)      ::argname
character(len=255),dimension(10)    ::arg
character(len=3)::a
integer                             ::verbosity
!Dim tlbufr As Double

check_sec4=.false.
select(1)%btype=none ! Excluir a leitura de todos os tipos de mesagens bufr
                      ! Somente a secao 1 de cada mensagem sera lida


   !{ Pega os argumentos de Entrada: Data e Nomes dos arquivos de entrada e saida
   nfiles=0
   verbosity=0
   call getarg2(argname,arg,narg)
   do i=1,narg
        if (argname(i)=="o") then !,,,,,,,.....
                 outfile=arg(i)
                 x1=1
        elseif (argname(i)=="4") then
             check_sec4=.true.
             select(1)%btype=any
        elseif (argname(i)=="v") then
             verbosity=val(arg(i))
        elseif(argname(i)=="?") then
				nfiles=nfiles+1
				if (nfiles > 1000) then
					print *,"Warning! The maximum number of provide files is 300. Other files will be ignored"
					nfiles=1000
					exit
				else
				    infile=replace(arg(i),"//","/")
					flist(nfiles)=infile
				end if
        end if
	end do

	if (x1*nfiles==0) then

	   print *, "+--------------------------------------------------------------------------+"
	   print *, "| mbufr_time: reads date and time of each BUFR section 1 in a set of       |"
	   print *, "| BUFR messages and return the time window of the set e mensagens BUFR     |"
	   PRINT *, "|--------------------------------------------------------------------------|"
	   PRINT *, "| USE: mbufr_time {options} -o <outfile> bufrfile-1 bufrfile-2 etc         |"
	   print *, "|                                                                          |"
	   print *, "|     options                                                              |"
	   print *, "|      -4 : Checks date and time in section 4 insted section 1             |"
	   print *, "|      -v : Verbosity (default=0)                                          |"
	   print *, "+--------------------------------------------------------------------------+"

	   stop

  	endif
  !}

!{ Abre arquivo de 
   open (2,file=outfile,status='unknown',access='append')

!{ Abre o arquivo BUFR

do i=1,nfiles
   date_min=0.0
   date_max=0.0
   nm=0
    
    print *,"checking > "//trim(flist(i))
    !Call OPEN_MBUFR(1,flist(i),255,14,0)
    Call OPEN_MBUFR(1,flist(i))

 !}

 !Nesta parte e feita a leitura das mensagens BUFR  (somente a secao 1) 
 !
 !Se nao houver erro de leitura, converte a data da secao1 (ano,mes,dia,etc..)
 !em data juliana, utilizando a funcao fjulian do modulo datelib
 !
 ! A data juliana e comparada com a data minima e maxima obtida anteriormente
 ! se menor que a data minima atualiza a data minina
 ! se maior que a data maxima atualiza a data maxima
 !{

     
write(2,'("+----------------------------------------->")')
write(2,'("| bufr: ",5x,a)')trim(flist(i))
write(2,'("+-------------------+---------------------+")')
 10 CONTINUE   
  
  if (check_sec4) then
      Call READ_MBUFR(1,sec1,sec3,sec4, bUFR_ED, MBYTES,err)
  else
      Call READ_MBUFR(1,sec1,sec3,sec4, bUFR_ED, MBYTES,err,select)
  end if

    If ((MBYTES > 0).and.(IOERR(1)==0)) Then
        nm=nm+1
       !{ Obtem a data inicial e final de todos os dados 
        cdate=fjulian(sec1%year,sec1%month,sec1%day,sec1%hour,sec1%minute,0)



        if (check_sec4)  then
        !-------------------------------------------
        ! Checking date and time from section 4
        !-------------------------------------------
        ! Use date and time from section1 in case
        ! date in section 4 is note present
        !-------------------------------------------
         if( verbosity>0)  print *,"Checking date and time in section 4: message=",nm
          do s=1,sec3%nsubsets
            do v=1,sec4%nvars
              if  (sec4%d(v,s)==4001) then
                 yy=sec4%r(v,s)
              elseif (sec4%d(v,s)==4002) then
                 mm=sec4%r(v,s)
              elseif (sec4%d(v,s)==4003) then
                  dd=sec4%r(v,s)
              elseif (sec4%d(v,s)==4004) then
                 hh=sec4%r(v,s)
              elseif (sec4%d(v,s)==4005) then
                 mn=sec4%r(v,s)
                 cdate=fjulian(yy,mm,dd,hh,mn,00)
                 if (verbosity>0) print *,"Checking date and time in section 4: subset =",s,"date=",grdate(cdate)
                 exit
              end if
            end do

           if (cdate > 0) then
              if (nm==1) then
                 date_min=cdate
                 date_max=cdate
               end if

              if ((date_min>cdate)) date_min=cdate
              if ((date_max<cdate)) date_max=cdate
          end if
        end do


        else
        !---------------------------------------
        ! Checking date and time from section 1
        !-----------------------------------------
        if (cdate > 0) then
          if (nm==1) then
             date_min=cdate
             date_max=cdate
          end if
                
          if ((date_min>cdate)) date_min=cdate
          if ((date_max<cdate)) date_max=cdate
        end if
       !}
       end if
   !deallocate(sec3%d,sec4%d,sec4%r,sec4%c)
 GoTo 10
 End If

 Close (1)

!{ Imprime resultado

  write(labelmin,'("| ",i4,"-",i2.2,"-",i2.2,2x,i2.2,":00")')year(date_min),month(date_min),day(date_min),hour(date_min)
  write(labelmax,'(1x,i4,"-",i2.2,"-",i2.2,2x,i2.2,":00")')year(date_max),month(date_max),day(date_max),hour(date_max)
  write(2,'("+-------------------+---------------------+")')
  write(2,'(2(a," | "))') labelmin,labelmax
  write(2,'("+-------------------+---------------------+")')
  write(2,'("|")')
!}

end do
!}


close(2)

!}

End 

