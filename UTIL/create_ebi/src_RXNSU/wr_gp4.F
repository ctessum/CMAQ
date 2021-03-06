       SUBROUTINE WR_GP4

C**********************************************************************
C
C  FUNCTION: Create source code for the hrg4 subroutine in EBI
C
C  PRECONDITIONS: None
C
C  KEY SUBROUTINES/FUNCTIONS CALLED: None
C
C  REVISION HISTORY: Created by Jerry Gipson, March, 2004
C
C**********************************************************************
      USE ENV_VARS
      USE GLOBAL_DATA
      !!USE M3UTILIO ! IOAPI parameters and declarations
      USE RXNS_DATA

      IMPLICIT NONE

C..INCLUDES: 

      
C..ARGUMENTS: None

C..PARAMETERS:
      INTEGER, PARAMETER   ::  GRPNO = 4

C..EXTERNAL FUNCTIONS:
       INTEGER   JUNIT      ! gets unit no.
!       INTEGER   NAME_INDEX     ! find position of string in list

C..SAVED LOCAL VARIABLES: None
 
C..SCRATCH LOCAL VARIABLES:
      CHARACTER(  16 )  ::    PNAME = 'WR_GP4'     ! Program name
      CHARACTER( 256 )  ::    MSG                  ! Message text
      CHARACTER( 100 )  ::    LINEIN               ! Input line
      CHARACTER(  CL )  ::    SPOUT                ! Ouput species
      CHARACTER(  16 )  ::    SPEC     
      CHARACTER( 256 )  ::    FNAME                ! Name of file to open
      CHARACTER(  72 )  ::    CLINE                ! Line of c's
      CHARACTER( 256 )  ::    LINOUT
      CHARACTER( 150 )  ::    RXOUT
      CHARACTER( 100 )  ::    BLANK_LINE
      CHARACTER*(  5 )  ::    RNUM                 ! Reaction number
      CHARACTER*(  6 )  ::    COUT                 ! Output coefficient
      CHARACTER*(  1 )  ::    SGN                  ! Coefficient sign
   

      INTEGER  :: E1, E2       ! end pos of string
      INTEGER  :: IND          ! array index
      INTEGER  :: IIN          ! Unit no. of input file
      INTEGER  :: IOUT         ! Unit no. of output file
      INTEGER  :: N, S, P, R   ! Loop indices
      INTEGER  :: NR           ! No. of reactants
      INTEGER  :: NPOS         ! Reaction index
      INTEGER  :: RPOS1        !
      INTEGER  :: RPOS2        !
      INTEGER  :: PPOS1        !
      INTEGER  :: PPOS2        !

      LOGICAL  :: LFIRST
      LOGICAL  :: LRXN1
      LOGICAL  :: LFIRST_R3 = .TRUE.  

      LOGICAL  :: LQUAD = .FALSE. 

      REAL( 8 ) :: COEFF
      REAL( 8 ) :: RNO3
      REAL( 8 ) :: PNO3
      REAL( 8 ) :: RN2O5
      REAL( 8 ) :: PN2O5

      
C**********************************************************************

      DO N = 1, 72
        CLINE( N : N ) = 'c'
      END DO

      DO N = 1, 100
        BLANK_LINE( N : N ) = ' '
      END DO

ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c Open ouput file and code template 
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc

      E1 = LEN_TRIM( OUTPATH )

      FNAME = OUTPATH( 1 : E1 ) // '/hrg4.F' 

      IOUT = JUNIT()

      OPEN( UNIT = IOUT, FILE = FNAME, ERR = 9000 )


      IIN = JUNIT()

      E1 = LEN_TRIM( TMPLPATH )

      FNAME = TMPLPATH( 1 : E1 ) // '/hrg4.F' 

      OPEN( UNIT = IIN, FILE = FNAME, ERR = 9000 )


      IF( LWR_COPY ) CALL WR_COPYRT( IOUT )

      IF( LWR_CVS_HDR ) CALL WR_CVSHDR( IOUT )


ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c  Determine if there is a NO3+NO3 reaction ( ==> quadratic solution)
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
       LQUAD = .FALSE.
       DO N = 1, NRXNS
          IF( IRR( N, 1 ) .EQ. NO3 .AND. IRR( N, 2 ) .EQ. NO3 )
     &        LQUAD = .TRUE.
       END DO

ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c Read, modify, and write 1st section of code from template
ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc

  100 CONTINUE

      READ( IIN, 92000, END = 1000 ) LINEIN

      IF( LINEIN( 1 : 2 ) .EQ. 'R1' ) THEN

         WRITE( IOUT, 93000 ) TRIM( MECHNAME )

         GO TO 100

      ELSEIF( LINEIN( 1 : 2 ) .EQ. 'R2' ) THEN

         WRITE( IOUT, 93020 ) CR_DATE( 1 : LEN_TRIM( CR_DATE ) )

         GO TO 100

      ELSEIF( LINEIN( 1 : 2 ) .EQ. 'R3' ) THEN

         E1 = LEN_TRIM( SPECIES( NO3  ) )
         E2 = LEN_TRIM( SPECIES( N2O5 ) )
         IF( LFIRST_R3 ) THEN

            IF( LQUAD ) THEN

               WRITE( IOUT, 93500 ) SPECIES( NO3  )( 1 : E1 ),
     &                              SPECIES( N2O5 )( 1 : E2 ),
     &                              SPECIES( NO3  )( 1 : E1 )

               SPOUT = SPECIES( NO3 )
               CALL LCASE( SPOUT )
               E1 = LEN_TRIM( SPOUT )
               LINOUT = '      REAL( 8 ) ::   K15_15       ! K' //
     &            SPOUT( 1 : E1 ) // '+' //  SPOUT( 1 : E1 ) // ' * delta t'
               E1 = LEN_TRIM( LINOUT )
               WRITE( IOUT, 92000 ) LINOUT( 1 : E1 )

            ELSE

               WRITE( IOUT, 93520 ) SPECIES( NO3  )( 1 : E1 ),
     &                              SPECIES( N2O5 )( 1 : E2 ),
     &                              SPECIES( NO3  )( 1 : E1 )

            END IF
          
            SPOUT = SPECIES( N2O5 )
            CALL LCASE( SPOUT )
            E1 = LEN_TRIM( SPOUT )
            LINOUT = '      REAL( 8 ) ::   R15_16       ! K' // SPOUT( 1 : E1 ) //
     &                 '-->'
            E1 = LEN_TRIM( LINOUT )
            SPOUT = SPECIES( NO3 )
            CALL LCASE( SPOUT )
            E2 = LEN_TRIM( SPOUT )
            LINOUT = LINOUT( 1 : E1 ) // SPOUT( 1 : E2 ) //
     &          ' * delta t'
            E1 = LEN_TRIM( LINOUT )
            WRITE( IOUT, 92000 ) LINOUT( 1 : E1 )
             

            SPOUT = SPECIES( NO3 )
            CALL LCASE( SPOUT )
            E2 = LEN_TRIM( SPOUT )
            LINOUT = '      REAL( 8 ) ::   R16_15       ! K' // SPOUT( 1 : E2 ) //
     &                 '+'
            E1 = LEN_TRIM( LINOUT )
            SPOUT = SPECIES( NO2 )
            CALL LCASE( SPOUT )
            E2 = LEN_TRIM( SPOUT )
            LINOUT = LINOUT( 1 : E1 ) // SPOUT( 1 : E2 ) // '-->'
            E1 = LEN_TRIM( LINOUT )
            SPOUT = SPECIES( N2O5 )
            CALL LCASE( SPOUT )
            E2 = LEN_TRIM( SPOUT )
            LINOUT = LINOUT( 1 : E1 ) // SPOUT( 1 : E2 ) // 
     &         '[NO2] * delta t'
            E1 = LEN_TRIM( LINOUT )
            WRITE( IOUT, 92000 ) LINOUT( 1 : E1 )

            LFIRST_R3 = .FALSE.

         END IF

         GO TO 100

            
      ELSEIF( LINEIN( 1 : 2 ) .EQ. 'S1' ) THEN

         GO TO 1000

      ELSE

         WRITE( IOUT, 92000 ) LINEIN( 1 : LEN_TRIM( LINEIN ) )

         GO TO 100

      END IF

 1000 CONTINUE


cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c  P15 production section
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c    P15 includes NO3 production from all reactions except N2O5=NO2+NO3    
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
      E1 = LEN_TRIM( SPECIES( NO3 ) )
      E2 = LEN_TRIM( SPECIES( N2O5 ) )
      WRITE( IOUT, 92000 )
      WRITE( IOUT, 94000 ) SPECIES( NO3 )( 1 : E1 ), SPECIES( N2O5 )( 1 : E2 )

c..Determine the reactions to include & get coefficients for the prod terms
      LRXN1 = .TRUE.
      DO N = 1, NRXNS
         COEFF = 0.0D0
         CALL SUM_COEFF( RN2O5, 'R', N2O5, N )
         CALL SUM_COEFF( RNO3,  'R', NO3,  N )
         CALL SUM_COEFF( PNO3,  'P', NO3,  N )

         IF( PNO3 .LE. RNO3 ) CYCLE                ! Skip rxns with Pno3=0

                                                   ! Skip N2O5=NO3+NO2 Rxn
         IF( IRR( N, 1 ) .EQ. N2O5 .AND. IRR( N, 4 ) .EQ. NO3 .OR.
     &       IRR( N, 1 ) .EQ. N2O5 .AND. IRR( N, 5 ) .EQ. NO3 )
     &     CYCLE          

         COEFF = PNO3 - RNO3                       ! Rxns w/ Pc2o3>0

c..call routine to create output line & write it
         NPOS = 30
         RPOS1 = 0
         RPOS2 = 0
         PPOS1 = NO3
         PPOS2 = 0
         CALL BLD_OUTLINE( 'RXRAT', 'P15', '   ', 0, COEFF, N, GRPNO,  
     &        NPOS, LINOUT, LRXN1, RPOS1, RPOS2, PPOS1, PPOS2 )

         LRXN1 = .FALSE.

         E1 = LEN_TRIM( LINOUT )
         WRITE( IOUT, 92000 ) LINOUT( 1 : E1 )

      END DO


cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c  L15 computation ( Loss of NO3 )
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
C    L15 includes the following NO3 loss terms:
c      a) all reactions in which NO3 is lost except NO3+NO3 if present
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
      SPOUT = SPECIES( NO3 )
      E1 = LEN_TRIM( SPOUT )
      WRITE( IOUT, 92000 )
      WRITE( IOUT, 94020 ) SPOUT( 1 : E1 ), SPOUT( 1 : E1 ), SPOUT( 1 : E1 )
      LRXN1 = .TRUE.
      DO N = 1, NRXNS         

c..Determine the rxn to include & get the coefficient for the loss term
         COEFF = 0.0D0
         CALL SUM_COEFF( RNO3, 'R', NO3,  N )
         CALL SUM_COEFF( PNO3, 'P', NO3,  N )

         IF( PNO3 .GE. RNO3 ) CYCLE          ! Skip rxns w/ Lno3=0
 

         ! Skip NO3+NO3 rxn
         IF( IRR( N, 1 ) .EQ. NO3 .AND. IRR( N, 2 ) .EQ. NO3 ) CYCLE
        
         COEFF = RNO3 - PNO3

c..call routine to create output line & write it
         NPOS  = 20
         RPOS1 = NO3
         RPOS2 = 0
         PPOS1 = 0
         PPOS2 = 0
         CALL BLD_OUTLINE( 'LFREQ', 'L15', 'NO3', NO3, COEFF, N, GRPNO,  
     &        NPOS, LINOUT, LRXN1, RPOS1, RPOS2, PPOS1, PPOS2 )

         LRXN1 = .FALSE.

         E1 = LEN_TRIM( LINOUT )
         WRITE( IOUT, 92000 ) LINOUT( 1 : E1 )

      END DO
       

cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c  L16 computation ( Loss of N2O5 )
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c    L15 includes all reactions in which N2O5 is lost
c
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
      SPOUT = SPECIES( N2O5 )
      E1 = LEN_TRIM( SPOUT )
      WRITE( IOUT, 92000 )
      WRITE( IOUT, 94040 ) SPOUT( 1 : E1 )
      LRXN1 = .TRUE.
      DO N = 1, NRXNS         

c..Determine the rxn to include & get the coefficient for the loss term
         COEFF = 0.0D0
         CALL SUM_COEFF( RN2O5, 'R', N2O5,  N )
         CALL SUM_COEFF( PN2O5, 'P', N2O5,  N )

         IF( RN2O5 .LE. PN2O5 ) CYCLE          ! Skip rxns w/ Ln2o5=0
         
         COEFF = RN2O5 - PN2O5

c..call routine to create output line & write it
         NPOS  = 20
         RPOS1 = N2O5
         RPOS2 = 0
         PPOS1 = 0
         PPOS2 = 0
         CALL BLD_OUTLINE( 'LFREQ', 'L16', 'N2O5', N2O5, COEFF, N, GRPNO,  
     &        NPOS, LINOUT, LRXN1, RPOS1, RPOS2, PPOS1, PPOS2 )

         LRXN1 = .FALSE.

         E1 = LEN_TRIM( LINOUT )
         WRITE( IOUT, 92000 ) LINOUT( 1 : E1 )

      END DO

cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c  k15_15, R15_16, and R16_15 terms
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc

c..Header & K15_15 term if present ( NO3+NO3=)
      IF( LQUAD ) THEN

         WRITE( IOUT, 92000 )      
         WRITE( IOUT, 94060 )

         DO N = 1, NRXNS
            IF( IRR( N, 1 ) .EQ. NO3 .AND.  IRR( N, 2 ) .EQ. NO3 ) THEN
               WRITE( RNUM, '( I5 )' ) N
               LINOUT = '      K15_15  = RKI( ' // RNUM // ' ) * DTC'
               E1 = LEN_TRIM( LINOUT )
               WRITE( IOUT, 92000 ) LINOUT( 1 : E1 )
            END IF
         END DO

      ELSE

        WRITE( IOUT, 92000 )      
        WRITE( IOUT, 94080 )


      END IF

c..R15_16 term ( production of NO3 from N2O5 )
      LRXN1 = .TRUE.
      DO N = 1, NRXNS
         IF( IRR( N, 1 ) .EQ. N2O5 .AND. IRR( N, 4 ) .EQ. NO3 .OR.
     &       IRR( N, 1 ) .EQ. N2O5 .AND. IRR( N, 5 ) .EQ. NO3 ) THEN
            WRITE( RNUM, '( I5 )' ) N
            IF( LRXN1 )THEN
                LINOUT = '      R15_16  = ( RKI( ' // RNUM // ' ) '
                LRXN1  = .FALSE.
            ELSE
                LINOUT = '     &        +   RKI( ' // RNUM // ' ) ' 
            END IF
            E1 = LEN_TRIM( LINOUT )
            WRITE( IOUT, 92040, ADVANCE = 'NO' ) LINOUT( 1 : E1 )
         END IF
      END DO
      WRITE( IOUT, 92060)
      WRITE( IOUT, 92020)

c..R16_15 term ( production of N2O5 from NO3 )
      DO N = 1, NRXNS
         IF( ( IRR( N, 1 ) .EQ. NO3 .AND. IRR( N, 4 ) .EQ. N2O5  ) .OR.
     &       ( IRR( N, 2 ) .EQ. NO3 .AND. IRR( N, 4 ) .EQ. N2O5 ) ) THEN
            WRITE( RNUM, '( I5 )' ) N
            
            LINOUT = '      R16_15  = RKI( ' // RNUM // 
     &       ' ) * YCP( NO2 ) * DTC'
            E1 = LEN_TRIM( LINOUT )
            WRITE( IOUT, 92000 ) LINOUT( 1 : E1 )
         END IF
      END DO

cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
c  Write the remaining code
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
      IF( LQUAD ) THEN

         LINOUT = 'c..Solution of quadratic equation to get ' //
     &      SPECIES( NO3  )( 1 : LEN_TRIM( SPECIES( NO3  ) ) ) // ' & ' //
     &      SPECIES( N2O5 )( 1 : LEN_TRIM( SPECIES( N2O5 ) ) )
         E1 = LEN_TRIM( LINOUT )
         WRITE( IOUT, 92000 )
         WRITE( IOUT, 92000 ) LINOUT( 1 : E1 )

         WRITE( IOUT, 95000) SPECIES( NO3  )( 1 : LEN_TRIM( SPECIES( NO3  ) ) ),
     &                       SPECIES( N2O5 )( 1 : LEN_TRIM( SPECIES( N2O5 ) ) )

         WRITE( IOUT, 95020) 

         WRITE( IOUT, 95040) SPECIES( NO3  )( 1 : LEN_TRIM( SPECIES( NO3  ) ) )

         WRITE( IOUT, 95060) SPECIES( N2O5 )( 1 : LEN_TRIM( SPECIES( N2O5 ) ) ),
     &                       SPECIES( N2O5 )( 1 : LEN_TRIM( SPECIES( N2O5 ) ) ),
     &                       SPECIES( NO3  )( 1 : LEN_TRIM( SPECIES( NO3  ) ) )


      ELSE

         WRITE( IOUT, 96000) 

         WRITE( IOUT, 96020) SPECIES( NO3  )( 1 : LEN_TRIM( SPECIES( NO3  ) ) )

         WRITE( IOUT, 96040) SPECIES( N2O5 )( 1 : LEN_TRIM( SPECIES( N2O5 ) ) ),
     &                       SPECIES( N2O5 )( 1 : LEN_TRIM( SPECIES( N2O5 ) ) )

         WRITE( IOUT, 96060) SPECIES( NO3  )( 1 : LEN_TRIM( SPECIES( NO3  ) ) ),
     &                       SPECIES( N2O5 )( 1 : LEN_TRIM( SPECIES( N2O5 ) ) )


      END IF
      
      WRITE( IOUT, 97000)
        
      CLOSE( IIN )

      CLOSE( IOUT )

      NOUTFLS = NOUTFLS + 1
      OUTFLNAM( NOUTFLS ) = 'hrg4.F'

      RETURN 

 9000 MSG = 'ERROR: Could not open ' // FNAME( 1 : LEN_TRIM( FNAME ) )

      WRITE(LOGDEV,'(a)')TRIM( PNAME ) // ': ' // TRIM( MSG )
      STOP
       
92000 FORMAT( A )
92020 FORMAT( / )
92040 FORMAT( /, A )
92060 FORMAT(' ) * DTC ')

93000 FORMAT( 'C  PRECONDITIONS: For the ', A, ' mechanism' )
93020 FORMAT( 'C  REVISION HISTORY: Created by EBI solver program, ', A )

93500 FORMAT( 
     & '      REAL( 8 ) ::   A, B, C, Q   ! Quadratic equation terms'/
     & '      REAL( 8 ) ::   CMN          ! Temp scalar'/
     & '      REAL( 8 ) ::   L15          ! Loss of ', A /
     & '      REAL( 8 ) ::   L16          ! Loss of ', A /
     & '      REAL( 8 ) ::   P15          ! Production of ', A )

93520 FORMAT( 
     & '      REAL( 8 ) ::   A1, A2, A3   ! Temp scalars'/
     & '      REAL( 8 ) ::   ATOP3        ! Temp scalar'/
     & '      REAL( 8 ) ::   ATOP5        ! Temp scalar'/
     & '      REAL( 8 ) ::   BOTT         ! Temp scalar'/
     & '      REAL( 8 ) ::   L15          ! Loss of ', A /
     & '      REAL( 8 ) ::   L16          ! Loss of ', A /
     & '      REAL( 8 ) ::   P15          ! Production of ', A )


94000 FORMAT( 
     & 'c..Production of ', A, ' (except from ', A, ' )' )

94020 FORMAT( 
     & 'c..Loss frequency of ', A, ' ( except ', A, 
     & ' + ', A, ' if present )' )

94040 FORMAT( 
     & 'c..Loss frequency of ', A ) 


94060 FORMAT(
     & 'c..K15_15, R15_16, and R16_15 terms' )


94080 FORMAT(
     & 'c..R15_16 and R16_15 terms' )

95000 FORMAT( 
     & '      CMN = 1.0D0 + L16 * DTC' /
     & '      A = 2.0D0 * K15_15 * CMN' /
     & '      B = CMN * ( 1.0D0 + L15 * DTC ) - R15_16 * R16_15' /
     & '      C = CMN * ( YC0( ', A, ' ) + P15 * DTC ) + ',
     & ' R15_16 * YC0( ', A, ' )' )

95020 FORMAT(/ 
     & '      Q = -0.5D0 * ( B + SIGN( 1.0D0, B ) * ',
     &  'SQRT( B * B + 4.0D0 * A * C ) )' )

95040 FORMAT( 
     & '      YCP( ', A, ' ) = MAX( Q / A , -C / Q  )' )

95060 FORMAT( 
     & '      YCP( ', A, ' ) = ( YC0( ', A, ' ) + R16_15 * ',
     & 'YCP( ', A, ' ) ) / CMN' )


96000 FORMAT(/
     & 'c..Solve analytically' )

96020 FORMAT(/
     & '      A1    = 1.0D0 + L16 * DTC' /
     & '      A2    = 1.0D0 + L15 * DTC' /
     & '      A3    = YC0( ', A, ' ) + P15 * DTC' )

96040 FORMAT(/
     & '      ATOP3 = A1 * A3 + R15_16 * YC0( ', A, ' )' /
     & '      ATOP5 = A2 * YC0( ', A, ' ) + R16_15 * A3' /
     & '      BOTT  = A1 * A2 - R15_16 * R16_15' )


96060 FORMAT(/
     & '      YCP( ', A, ' ) = ATOP3 / BOTT' /
     & '      YCP( ', A, ' ) = ATOP5 / BOTT' )


97000 FORMAT( /
     & '      RETURN' //
     & '      END' )

      END


