### FILE="Main.annotation"
## Copyright:   Public domain.
## Filename:    INTERPRETER.agc
## Purpose:     A section of LUM69 revision 2.
##              It is part of the reconstructed source code for the flown
##              version of the flight software for the Lunar Module's (LM)
##              Apollo Guidance Computer (AGC) for Apollo 10. The code has
##              been recreated from a copy of Luminary revsion 069, using
##              changes present in Luminary 099 which were described in
##              Luminary memos 73 and 75. The code has been adapted such
##              that the resulting bugger words exactly match those specified
##              for LUM69 revision 2 in NASA drawing 2021152B, which gives
##              relatively high confidence that the reconstruction is correct.
## Reference:   pp. 997-1089
## Assembler:   yaYUL
## Contact:     Ron Burkey <info@sandroid.org>.
## Website:     www.ibiblio.org/apollo/index.html
## Mod history: 2019-07-27 MAS  Created from Luminary 69.

## Page 997
# SECTION 1  DISPATCHER

#          ENTRY TO THE INTERPRETER. INTPRET SETS LOC TO THE FIRST  INSTRUCTION, BANKSET TO THE BBANK OF THE
# OBJECT INTERPRETIVE PROGRAM, AND INTBIT15 TO THE BIT15 CONTENTS OF FBANK. INTERPRETIVE PROGRAMS MAY BE IN
# VIRTUALLY ALL BANKS PRESENT UNDER ANY SUPER-BANK SETTING, WITH THE RESTRICTION THAT PROGRAMS IN HIGH BANKS
# (BIT15 OF FBANK = 1) DO NOT REFER TO LOWBANKS, AND VICE-VERSA. THE INTERPRETER DOES NOT SWITCH SUPERBANKS.
# E-BANK SWITCHING OCCURS WHENEVER GENERAL ERASABLE (100 - 3777) IS ADDRESSED.

                BLOCK   03
                
                COUNT*  $$/INTER
INTPRET         RELINT
                EXTEND                          # SET LOC TO THE WORD FOLLOWING THE TC.
                QXCH    LOC
                
 +2             CA      BBANK                   # INTERPRETIVE BRANCHES FINISH HERE.
                TS      BANKSET
                MASK    BIT15                   # GET 15TH BIT FOR INDEXABLE ADDRESSES.
                TS      INTBIT15

                TS      EDOP                    # MAKE SURE NO INSTRUCTIONS LEFT OVER

                TCF     NEWOPS                  # PICK UP OP CODE PAIR AND BEGIN.


INTRSM          LXCH    BBANK                   # RESUME SUSPENDED INTERPRETIVE JOB
                TCF     INTPRET +3
#          DLOAD LOADS MPAC, MPAC +1, LEAVING ZERO IN MPAC +2.

DLOAD           EXTEND
                INDEX   ADDRWD
                DCA     0                       # LOAD DP C(C(ADDRWD)) INTO MPAC,MPAX +1
SLOAD2          DXCH    MPAC
                CAF     ZERO                    # ZERO MPAC +2

## Page 998
#          AT THE END OF MOST INSTRUCTIONS, CONTROL IS GIVEN TO DANZIG TO DISPATCH THE NEXT OPERATION.

                TS      MPAC    +2              # AND DECLARE DP MODE

NEWMODE         TS      MODE                    # PROLOGUE FOR MODE-CHANGING INSTRUCTIONS.

DANZIG          CA      BANKSET                 # SET BBANK BEFORE TESTING NEWJOB SO THAT
                TS      BBANK                   # IT MAY BE SAVED DIRECTLY BY CHANJOB.

NOIBNKSW        CCS     EDOP                    # SEE IF AN ORDER CODE IS LEFT OVER FROM
                TCF     OPJUMP                  # THE LAST PAIR RETRIEVED. IF SO, EXECUTE.
                                                # EDOP IS SET TO ZERO ON ITS RE-EDITING.

                CCS     NEWJOB                  # SEE IF A JOB OF HIGHER PRIORITY IS
                TCF     CHANG2                  # PRESENT, AND IF SO, CHANGE JOBS.

                INCR    LOC                     # ADVANCE THE LOCATION COUNTER.
#          ITRACE (1) REFERS TO "NEWOPS".
NEWOPS          INDEX   LOC                     # ENTRY TO BEGIN BY PICKING OP CODE PAIR.
                CA      0                       # MAY BE AN OPCODE PAIR OR A STORE CODE.
                CCS     A                       # TEST SIGN AND GET DABS(A).
                TCF     DOSTORE                 # PROCESS STORE CODE.

LOW7            OCT     177

                TS      EDOP                    # OP CODE PAIR. LEAVE THE OTHER IN EDOP
                MASK    LOW7                    # WHERE  CCS EDOP  WILL HONOR IT NEXT.

OPJUMP          TS      CYR                     # LOWWD ENTERS HERE IF A RIGHT-HAND OP
                CCS     CYR                     # CODE IS TO BE PROCESSED. TEST PREFICES.
                TCF     OPJUMP2                 # TEST SECOND PREFIX BIT.

                TCF     EXIT                    # +0 OP CODE IS EXIT.

## Page 999
#          PROCESS ADDRESSES WHICH MAY BE DIRECT, INDEXED, OR REFERENCE THE PUSHDOWN LIST.

ADDRESS         MASK    BIT1                    # SEE IF ADDRESS IS INDEXED. CYR CONTAINED
                CCS     A                       # 400XX, SO BIT 1 IS NOW AS IT WAS IN CYR.
                TCF     INDEX                   # FORM INDEXED ADDRESS.

DIRADRES        INDEX   LOC                     # LOOK AHEAD TO NEXT WORD TO SEE IF
OCT40001        CS      1                       # ADDRESS IS GIVEN.
                CCS     A
                TCF     PUSHUP                  # IF NOT.

NEG4            DEC     -4

                INCR    LOC                     # IF SO, TO SHOW WE PICKED UP A WORD.
                TS      ADDRWD

## Page 1000
#          FINAL DIGESTION OF DIRECT ADDRESSES OF OP CODES WITH 01 PREFIX IS DONE HERE. IN EACH CASE, THE
# REQUIRED 12-BIT SUB-ADDRESS IS LEFT IN ADDRWD, WITH ANY REQUIRED E OR F BANK SWITCHING DONE. ADDRESSES LESS
# THAN 45D ARE TAKEN TO BE RELATIVE TO THE WORK AREA. THE OP CODE IS NOW IN BITS 1-5 OF CYR WITH BIT 14 = 1.


                AD      -ENDVAC                 # SEE IF ADDRESS RELATIVE TO WORK AREA.
                CCS     A
                AD      -ENDERAS                # IF NOT, SEE IF IN GENERAL ERASABLE.
                TCF     IERASTST
                
NETZERO         CA      FIXLOC                  # IF SO, LEAVE THE MODIFIED ADDRESS IN
                ADS     ADDRWD                  # ADDRWD AND DISPATCH.
ITR15           INDEX   CYR                     # THIS INDEX MAKES THE NEXT INSTRUCTION
                7       INDJUMP -1              # TCF INDJUMP + OP, EDITING CYR.
                
IERASTST        EXTEND
                BZMF    GEADDR                  # GO PROCESS GENERAL-ERASABLE ADDRESS.
                
                MASK    LOW10                   # FIXED BANK ADDRESS. RESTORE AND ADD B15.
                AD      LOW10                   # SWITCH BANKS AND LEAVE SUBADDRESS IN
                XCH     ADDRWD                  # ADDRWD FOR OPERAND RETRIEVAL. (THIS
                AD      INTBIT15                # METHOD PRECLUDES USE OF THE LAST
                TS      FBANK                   # LOCATION IN EACH FBANK.)
ITR12           INDEX   CYR
                7       INDJUMP -1
                
GEADDR          MASK    LOW8
                AD      OCT1400
                XCH     ADDRWD
                TS      EBANK
ITR10           INDEX   CYR
                7       INDJUMP -1

## Page 1001
#          THE FOLLOWING ROUTINE PROCESSES INTERPRETIVE INDEXED ADDRESSES. AN INTERPRETER INDEX REGISTER MAY
# CONTAIN THE ADDRESS OF ANY ERASABLE REGISTER (0-42 BEING RELATIVE TO THE VAC AREA) OR ANY INTERPRETIVE PROGRAM
# BANK, OR ANY INTEGER IN THAT RANGE.

DODLOAD*        CAF     DLOAD*                  # STODL* COMES HERE TO PROCESS LOAD ADR.
                TS      CYR                     # (STOVL* ENTERS HERE).
                
INDEX           CA      FIXLOC                  # SET UP INDEX LOCATION.
                TS      INDEXLOC
                INCR    LOC                     # (ADDRESS ALWAYS GIVEN).
                INDEX   LOC
                CS      0
                CCS     A                       # INDEX 2 IF ADDRESS STORED COMPLEMENTED.
                INCR    INDEXLOC
                NOOP
                
                TS      ADDRWD                  # 14 BIT ADDRESS TO ADDRWD.
                MASK    HIGH4                   # IF ADDRESS GREATER THAN 2K, ADD INTBIT15
                EXTEND
                BZF     INDEX2
                CA      INTBIT15
                ADS     ADDRWD

INDEX2          INDEX   INDEXLOC
                CS      X1
                ADS     ADDRWD                  # DO AUGMENT, IGNORING AND CORRECTING OVF.
                
                MASK    HIGH9                   # SEE IF ADDRESS IS IN WORK AREA.
                EXTEND
                BZF     INDWORK
                MASK    HIGH4                   # SEE IF IN FIXED BANK.
                EXTEND
                BZF     INDERASE

                CA      ADDRWD                  # IN FIXED - SWITCH BANKS AND CREATE
                TS      FBANK                   # SUB-ADDRESS.
                MASK    LOW10
                AD      2K
                TS      ADDRWD
ITR11           INDEX   CYR
                3       INDJUMP -1
                
INDWORK         CA      FIXLOC                  # MAKE ADDRWD RELATIVE TO WORK AREA.
                TCF     ITR13   -1

INDERASE        CA      OCT1400
                XCH     ADDRWD
                TS      EBANK
                MASK    LOW8
 -1             ADS     ADDRWD
## Page 1002
ITR13           INDEX   CYR
                3       INDJUMP -1
                
## Page 1003
#          PUSH-UP ROUTINES. WHEN NO OPERAND ADDRESS IS GIVEN, THE APPROPRIATE OPERAND IS TAKEN FROM THE PUSH-DOWN
# LIST. IN MOST CASES THE MODE OF THE RESULT (VECTOR OR SCALAR) OF THE LAST ARITHMETIC OPERATION PERFORMED
# IS THE SAME AS THE TYPE OF OPERAND DESIRED (ALL ADD/SUBTRACT ETC.). EXCEPTIONS TO THIS GENERAL RULE ARE LISTED
# BELOW (NOTE THAT IN EVERY CASE THE MODE REGISTER IS LEFT INTACT):

#          1.  VXSC AND V/SC WANT THE OPPOSITE TYPE OF OPERAND, E.G., IF THE LAST OPERATION YIELDED A VECTOR
# RESULT, VXSC WANTS A SCALAR.

#          2.  THE LOAD CODES SHOULD LOAD THE ACCUMULATOR INDEPENDENT OF THE RESULT OF THE LAST OPERATION. THIS
# INCLUDES VLOAD, DLOAD, TLOAD, PDDL, AND PDVL (NO PUSHUP WITH SLOAD).

#          3.  SOME ARITHMETIC OPERATIONS REQUIRE A STANDARD TYPE OF OPERAND REGARDLESS OF THE PREVIOUS OPERATION.
# THIS INCLUDES SIGN WANTING DP AND TAD REQUIRING TP.

PUSHUP          CAF     OCT23           # IF THE LOW 5 BITS OF CYR ARE LESS THAN
                MASK    CYR             # 20, THIS OP REQUIRES SPECIAL ATTENTION.
                AD      -OCT10          # (NO -0).
                CCS     A
                TCF     REGUP           # FOR ALL CODES GREATER THAN OCT 7.
                
-OCT10          OCT     -10

                AD      NEG4            # WE NOW HAVE 7 - OP CODE(MOD4). SEE IF
                CCS     A               # THE OP CODE (MOD4) IS THREE (REVERSE).
                INDEX   A               # NO - THE MODE IS DEFINITE. PICK UP THE
                CS      NO.WDS
                TCF     REGUP   +2
                
                INDEX   MODE            # FOR VXSC AND V/SC WE WANT THE REQUIRED
                CS      REVCNT          # PUSHLOC DECREMENT WITHOUT CHANGING THE
                TCF     REGUP   +2      # MODE AT THIS TIME.

REGUP           INDEX   MODE            # MOST ALL OP CODES PUSHUP HERE.
                CS      NO.WDS
 +2             ADS     PUSHLOC
                TS      ADDRWD
ITR14           INDEX   CYR
                7       INDJUMP -1      # (THE INDEX MAKES THIS A TCF.)

                OCT     2               # REVERSE PUSHUP DECREMENT. VECTOR TAKES 2
REVCNT          OCT     6               # WORDS, SCALAR TAKES 6.
                OCT     6
NO.WDS          OCT     2               # CONVENTIONAL DECREMENT IS 6 WORDS VECTOR
OCTAL3          OCT     3               # 2 IN DP, AND 3 IN TP.
                OCT     6

## Page 1004
#          TEST THE SECOND PREFIX BIT TO SEE IF THIS IS A MISCELLANEOUS OR A UNARY/SHORT SHIFT OPERATION.

OPJUMP2         CCS     CYR             # TEST SECOND PREFIX BIT.
                TCF     OPJUMP3         # TEST THIRD BIT TO SEE IF UNARY OR SHIFT.
                
-ENDVAC         DEC     -45

#          THE FOLLOWING ROUTINE PROCESSES ADDRESSES OF SUFFIX CLASS 10. THEY ARE BASICALLY WORK AREA ADDRESSES
# IN THE RANGE 0 - 52, ERASABLE ECADR CONSTANTS FROM 100 - 3777, AND FCADRS ABOVE THAT. ALL 15 BITS ARE AVAILABLE
# IN CONTRAST TO SUFFIX 1, IN WHICH ONLY THE LOW ORDER 14 ARE AVAILABLE.

15BITADR        INCR    LOC             # (ENTRY HERE FROM STCALL).
                INDEX   LOC             # PICK UP ADDRESS WORD.
                CA      0
                TS      POLISH          # WE MAY NEED A SUBADDRESS LATER.
                
                CAF     LOW7+2K         # THESE INSTRUCTIONS ARE IN BANK 1.
                TS      FBANK
                MASK    CYR
ITR7            INDEX   A
                TCF     MISCJUMP
                
## Page 1005
#          COMPLETE THE DISPATCHING OF UNARY AND SHORT SHIFT OPERATIONS.

OPJUMP3         TS      FBANK           # CALL IN BANK 0 (BITS 11-15 OF A ARE 0.)
#          ITRACE (6) REFERS TO "OPJUMP3".
                CCS     CYR             # TEST THIRD PREFIX BIT.
                INDEX   A               # THE DECREMENTED UNARY CODE IS IN BITS
                TCF     UNAJUMP         # 1-4 OF A (ZERO, EXIT, HAS BEEN DETECTED)
                
                CCS     MODE            # ITS A SHORT SHIFT CODE. SEE IF PRESENT
                TCF     SHORTT          # SCALAR OR VECTOR.
                TCF     SHORTT
                TCF     SHORTV          # CALLS THE APPROPRIATE ROUTINE.

                
FBANKMSK        EQUALS  BANKMASK
LVBUF           ADRES   VBUF

## Page 1006
#          THE FOLLOWING IS THE JUMP TABLE FOR OP CODES WHICH MAY HAVE INDEXABLE ADDRESSES OR MAY PUSH UP.

INDJUMP         TCF     VLOAD           # 00 - LOAD MPAC WITH A VECTOR.
                TCF     TAD             # 01 - TRIPLE PRECISION ADD TO MPAC.
                TCF     SIGN            # 02 - COMPLEMENT MPAC (V OR SC) IF X NEG.
                TCF     VXSC            # 03 - VECTOR TIMES SCALAR.
                TCF     CGOTO           # 04 - COMPUTED GO TO.
                TCF     TLOAD           # 05 - LOAD MPAC WITH TRIPLE PRECISION.
                TCF     DLOAD           # 06 - LOAD MPAC WITH A DP SCALAR.
                TCF     V/SC            # 07 - VECTOR DIVIDED BY SCALAR.
                
                TCF     SLOAD           # 10 - LOAD MPACIN SINGLE PRECISION.
                TCF     SSP             # 11 - SET SINGLE PRECISION INTO X.
                TCF     PDDL            # 12 - PUSH DOWN MPAC AND RE-LOAD IN DP.
                TCF     MXV             # 13 - MATRIX POST-MULTIPLIED BY VECTOR.
                TCF     PDVL            # 14 - PUSH DOWN AND VECTOR LOAD.
                TCF     CCALL           # 15 - COMPUTED CALL.
                TCF     VXM             # 16 - MATRIX PRE-MULTIPLIED BY VECTOR.
                TCF     TSLC            # 17 - NORMALIZE MPAC (SCALAR ONLY).
                
                TCF     DMPR            # 20 - DP MULTIPLY AND ROUND.
                TCF     DDV             # 21 - DP DIVIDE BY.
                TCF     BDDV            # 22 - DP DIVIDE INTO.
                TCF     GSHIFT          # 23 - GENERAL SHIFT INSTRUCTION.
                TCF     VAD             # 24 - VECTOR ADD.
                TCF     VSU             # 25 - VECTOR SUBTRACT.
                TCF     BVSU            # 26 - VECTOR SUBTRACT FROM.
                TCF     DOT             # 27 - VECTOR DOT PRODUCT.
                
                TCF     VXV             # 30 - VECTOR CROSS PRODUCT.
                TCF     VPROJ           # 31 - VECTOR PROJECTION.
                TCF     DSU             # 32 - DP SUBTRACT.
                TCF     BDSU            # 33 - DP SUBTRACT FROM.
                TCF     DAD             # 34 - DP ADD.
                TCF                     # 35 - AVAILABLE
                TCF     DMP1            # 36 - DP MULTIPLY.
                TCF     SETPD           # 37 - SET PUSH DOWN POINTER (DIRECT ONLY)
                
# CODES 10 AND 14 MUST NOT PUSH UP. CODE 04 MAY BE USED FOR VECTOR DECLARE BEFORE PUSHUP IF DESIRED.

## Page 1007
#          THE FOLLOWING JUMP TABLE APPLIES TO INDEX, BRANCH, AND MISCELLANEOUS INSTRUCTIONS.

MISCJUMP        TCF     AXT             # 00 - ADDRESS TO INDEX TRUE.
                TCF     AXC             # 01 - ADDRESS TO INDEX COMPLEMENTED.
                TCF     LXA             # 02 - LOAD INDEX FROM ERASABLE.
                TCF     LXC             # 03 - LOAD INDEX FROM COMPLEMENT OF ERAS.
                TCF     SXA             # 04 - STORE INDEX IN ERASABLE.
                TCF     XCHX            # 05 - EXCHANGE INDEX WITH ERASABLE.
                TCF     INCR            # 06 - INCREMENT INDEX REGISTER.
                TCF     TIX             # 07 - TRANSFER ON INDEX.
                
                TCF     XAD             # 10 - INDEX REGISTER ADD FROM ERASABLE.
                TCF     XSU             # 11 - INDEX SUBTRACT FROM ERASABLE.
                TCF     BZE/GOTO        # 12 - BRANCH ZERO AND GOTO.
                TCF     BPL/BMN         # 13 - BRANCH PLUS AND BRANCH MINUS.
                TCF     RTB/BHIZ        # 14 - RETURN TO BASIC AND BRANCH HI ZERO.
                TCF     CALL/ITA        # 15 - CALL AND STORE QPRET.
                TCF     SW/             # 16 - SWITCH INSTRUCTIONS AND AVAILABLE.
                TCF     BOV(B)          # 17 - BRANCH ON OVERFLOW TO BASIC OR INT.

## Page 1008
#          THE FOLLOWING JUMP TABLE APPIES TO UNARY INSTRUCTIONS.

                COUNT*  $$/INTER
                BANK    0               # 00 - EXIT - DETECTED EARLIER.
UNAJUMP         TCF     SQRT            # 01 - SQUARE ROOT.
                TCF     SINE            # 02 - SIN.
                TCF     COSINE          # 03 - COS.
                TCF     ARCSIN          # 04 - ARC SIN.
                TCF     ARCCOS          # 05 - ARC COS.
                TCF     DSQ             # 06 - DP SQUARE.
                TCF     ROUND           # 07 - ROUND TO DP.
                
                TCF     COMP            # 10 - COMPLEMENT VECTOR OR SCALAR.
                TCF     VDEF            # 11 - VECTOR DEFINE.
                TCF     UNIT            # 12 - UNIT VECTOR.
                TCF     ABVALABS        # 13 - LENGTH OF VECTOR OR MAG OF SCALAR.
                TCF     VSQ             # 14 - SQUARE OF LENGTH OF VECTOR.
                TCF     STADR           # 15 - PUSH UP ON STORE CODE.
                TCF     RVQ             # 16 - RETURN VIA QPRET.
                TCF     PUSH            # 17 - PUSH MPAC DOWN.
                
## Page 1009
# SECTION 2  LOAD AND STORE PACKAGE.

#          A SET OF EIGHT STORE CODES IS PROVIDED AS THE PRIMARY METHOD OF STORING THE MULTI-PURPOSE
# ACCUMULATOR (MPAC). IF IN THE DANZIG SECTION LOC REFERS TO AN ALGEBRAICALLY POSITIVE WORD, IT IS TAKEN AS A 
# STORE CODE WITH A CORRESPONDING ERASABLE ADDRESS. MOST OF THESE CODES ARE TWO ADDRESS, SPECIFYING THAT THE WORD
# FOLLOWING THE STORE CODE IS TO BE USED AS AN ADDRESS FROM WHICH TO RE-LOAD MPAC. FOUR OPTIONS ARE AVAILABLE:

#          1. STORE               STORE MPAC. THE E ADDRESS MAY BE INDEXED.
#          2. STODL               STORE MPAC AND RE-LOAD IT IN DP WITH THE NEXT ADDRESS (THE LOAD MAY BE INDEXED).
#          3. STOVL               STORE MPAC AND RE-LOAD A VECTOR (AS ABOVE).
#          4. STCALL              STORE AND DO A CALL (BOTH ADDRESSES MUST BE DIRECT HERE).

#          STODL AND STOVL WILL TAKE FROM THE PUSH-DOWN LIST IF NO LOAD ADDRESS IS GIVEN.

                BLOCK   3
                
                COUNT*  $$/INTER
STADR           CA      BANKSET         # THE STADR CODE (PUSHUP UP ON STORE
                TS      FBANK           # ADDRESS) ENTERS HERE.
                INCR    LOC
ITR1            INDEX   LOC             # THE STORECODE WAS STORED COMPLEMENTED TO
                CS      0               # MAKE IT LOOK LIKE AN OPCODE PAIR.
                AD      NEGONE          # (YUL CANT REMOVE 1 BECAUSE OF EARLY CCS)
                
DOSTORE         TS      ADDRWD  
                MASK    LOW11           # ENTRY FROM DISPATCHER. SAVE THE ERASABLE
                XCH     ADDRWD          # ADDRESS AND JUMP ON THE STORE CODE NO.
                MASK    B12T14
                EXTEND
                MP      BIT5            # EACH TRANSFER VECTOR ENTRY IS TWO WORDS.
                INDEX   A
                TCF     STORJUMP
                
## Page 1010
#          STORE CODE JUMP TABLE. CALLS THE APPROPRIATE STORING ROUTINE AND EXITS TO DANZIG OR TO ADDRESS WITH
# A SUPPLIED OPERATION CODE.

#          STORE STORE,1 AND STORE,2 RETURN TO DANZIG, THUS RESETTING THE EBANK TO ITS STATE AT INTPRET.

STORJUMP        TC      STORE           # STORE.
                TCF     DANZIG          # PICK UP NEW OP CODE(S).
                TC      STORE,1
                TCF     DANZIG
                TC      STORE,2
                TCF     DANZIG
                
                TC      STORE           # STODL.
                TCF     DODLOAD
                
                TC      STORE           # STODL WITH INDEXED LOAD ADDRESS.
                TCF     DODLOAD*
                
                TC      STORE           # STOVL.
                TCF     DOVLOAD
                
                TC      STORE           # STOVL WITH INDEXED LOAD ADDRESS.
                TCF     DOVLOAD*
                TC      STORE           # STOTC.
                CAF     CALLCODE
                TS      CYR
                TCF     15BITADR        # GET A 15 BIT ADDRESS.
                
## Page 1011
#          STORE CODE ADDRESS PROCESSOR.

STORE,1         INDEX   FIXLOC
                CS      X1
                TCF     PRESTORE
                
STORE,2         INDEX   FIXLOC
                CS      X2
PRESTORE        ADS     ADDRWD          # RESULTANT ADDRESS IS IN ERASABLE.

STORE           CS      ADDRWD
                AD      DEC45
                CCS     A               # DOES THE ADDRESS POINT TO THE WORK AREA?
                CA      FIXLOC          # YES.
                TCF     AHEAD5
                CA      OCT1400         # NO. SET EBANK & MAKE UP SUBADDRESS.
                XCH     ADDRWD
                TS      EBANK
                MASK    LOW8
AHEAD5          ADS     ADDRWD

## Page 1012
#          STORING ROUTINES. STORE DP, TP, OR VECTOR AS INDICATED BY MODE.

STARTSTO        EXTEND                  # MPAC,+1 MUST BE STORED IN ANY EVENT.
#          ITRACE (5) REFERS TO "STARTSTO".
                DCA     MPAC
                INDEX   ADDRWD
                DXCH    0
                
                CCS     MODE
                TCF     TSTORE
                TC      Q
                
VSTORE          EXTEND
                DCA     MPAC     +3
                INDEX   ADDRWD
                DXCH    2
                
                EXTEND
                DCA     MPAC     +5
                INDEX   ADDRWD
                DXCH    4
                TC      Q
                
TSTORE          CA      MPAC    +2
                INDEX   ADDRWD
                TS      2
                TC      Q
                
## Page 1013
#          ROUTINES TO BEGIN PROCESSING OF THE SECOND ADDRESS ASSOCIATED WITH ALL STORE-TYPE CODES EXCEPT STORE
# ITSELF.

DODLOAD         CAF     DLOADCOD
                TS      CYR
                TCF     DIRADRES        # GO GET A DIRECT ADDRESS.

DOVLOAD         CAF     VLOADCOD
                TS      CYR
                TCF     DIRADRES

DOVLOAD*        CAF     VLOAD*
                TCF     DODLOAD* +1     # PROLOGUE TO INDEX ROUTINE.

## Page 1014
#          THE FOLLOWING LOAD INSTRUCTIONS ARE PROVIDED FOR LOADING THE MULTI-PURPOSE ACCUMULATOR MPAC.

TLOAD           INDEX   ADDRWD
                CA      2               # LOAD A TRIPLE PRECISION ARGUMENT INTO
                TS      MPAC    +2      # THE FIRST THREE MPAC REGISTERS, WITH THE
                EXTEND                  # CONTENTS OF THE OTHER FOUR IRRELEVANT.
                INDEX   ADDRWD
                DCA     0
                DXCH    MPAC
TMODE           CAF     ONE
                TCF     NEWMODE         # DECLARE TRIPLE PRECISION MODE.
                
SLOAD           ZL                      # LOAD A SINGLE PRECISION NUMBER INTO
                INDEX   ADDRWD          # MPAC, SETTING MPAC+1,2 TO ZERO. THE
                CA      0               # CONTENTS OF THE REMAINING MPAC REGISTERS
                TCF     SLOAD2          # ARE IRRELEVANT.

VLOAD           EXTEND                  # LOAD A DOUBLE PRECISION VECTOR INTO
                INDEX   ADDRWD          # MPAC,+1, MPAC+3,4, AND MPAC+5,6. THE
                DCA     0               # CONTENTS OF MPAC +2 ARE IRRELEVANT.
                DXCH    MPAC
                
ENDVLOAD        EXTEND                  # PDVL COMES HERE TO FINISH UP FOR DP, TP.
                INDEX   ADDRWD
                DCA     2
                DXCH    MPAC    +3
                
 +4             EXTEND                  # TPDVL FINISHES HERE.
                INDEX   ADDRWD
                DCA     4
                DXCH    MPAC    +5

VMODE           CS      ONE             # DECLARE VECTOR MODE.
                TCF     NEWMODE

## Page 1015
#          THE FOLLOWING INSTRUCTIONS ARE PROVIDED FOR STORING OPERANDS IN THE PUSHDOWN LIST:

#          1.  PUSH               PUSHDOWN AND NO LOAD.
#          2.  PDDL               PUSHDOWN AND DOUBLE PRECISION LOAD.
#          3.  PDVL               PUSHDOWN AND VECTOR LOAD.

PDDL            EXTEND
                INDEX   ADDRWD          # LOAD MPAC,+1, PUSHING THE FORMER
                DCA     0               # CONTENTS DOWN.
                DXCH    MPAC
                INDEX   PUSHLOC
                DXCH    0

                INDEX   MODE            # ADVANCE THE PUSHDOWN POINTER APPRO-
                CAF     NO.WDS          # PRIATELY.
                ADS     PUSHLOC

                CCS     MODE
                TCF     ENDTPUSH
                TCF     ENDDPUSH

                TS      MODE            # NOW DP.
ENDVPUSH        TS      MPAC    +2
                DXCH    MPAC    +3      # PUSH DOWN THE REST OF THE VECTOR HERE.
                INDEX   PUSHLOC
                DXCH    0       -4

                DXCH    MPAC    +5
                INDEX   PUSHLOC
                DXCH    0       -2

                TCF     DANZIG

ENDDPUSH        TS      MPAC    +2      # SET MPAC +2 TO ZERO AND EXIT ON DP.
                TCF     DANZIG

ENDTPUSH        TS      MODE
                XCH     MPAC    +2      # ON TRIPLE, SET MPAC +2 TO ZERO, PUSHING
 +2             INDEX   PUSHLOC         # DOWN THE OLD CONTENTS
                TS      0       -1
                TCF     DANZIG

## Page 1016
#          PDVL - PUSHDOWN AND VECTOR LOAD.

PDVL            EXTEND                  # RELOAD MPAC AND PUSH DOWN ITS CONTENTS.
                INDEX   ADDRWD
                DCA     0
                DXCH    MPAC
                INDEX   PUSHLOC
                DXCH    0
                
                INDEX   MODE            # ADVANCE THE PUSHDOWN POINTER.
                CAF     NO.WDS
                ADS     PUSHLOC

                CCS     MODE            # TEST PAST MODE.
                TCF     TPDVL
                TCF     ENDVLOAD        # JUST LOAD LAST FOUR REGISTERS ON DP.

VPDVL           EXTEND                  # PUSHDOWN AND RE-LOAD LAST TWO COMPONENTS
                INDEX   ADDRWD
                DCA     2
                DXCH    MPAC    +3
                INDEX   PUSHLOC
                DXCH    0       -4
                
                EXTEND
                INDEX   ADDRWD
                DCA     4
                DXCH    MPAC    +5
                INDEX   PUSHLOC
                DXCH    0       -2
                
                TCF     DANZIG
                
TPDVL           EXTEND                  # ON TP, WE MUST LOAD THE Y COMPONENT
                INDEX   ADDRWD          # BEFORE STORING MPAC +2 IN CASE THIS IS A
                DCA     2               # PUSHUP.
                DXCH    MPAC    +3
                
                CA      MPAC    +2
                INDEX   PUSHLOC         # IN DP.
                TS      0       -1
                TCF     ENDVLOAD +4
                
#          SSP (STORE SINGLE PRECISION) IS EXECUTED HERE.

SSP             INCR    LOC             # PICK UP THE WORD FOLLOWING THE GIVEN
                INDEX   LOC             # ADDRESS AND STORE IT AT X.
                CA      0
STORE1          INDEX   ADDRWD          # SOME INDEX AND MISCELLANEOUS OPS END
                TS      0               # HERE.
## Page 1017
                TCF     DANZIG
                
## Page 1018
# SEQUENCE CHANGING AND SUBROUTINE CALLING OPTIONS.

#          THE FOLLOWING OPERATIONS ARE AVAILABLE FOR SEQUENCING CHANGING, BRANCHING, AND CALLING SUBROUTINES:

#          1.  GOTO               GO TO.
#          2.  CALL               CALL SUBROUTINE SETTING QPRET.
#          3.  CGOTO              COMPUTED GO TO.
#          4.  CCALL              COMPUTED CALL.
#          7.  BPL                BRANCH IF MPAC POSITIVE OR ZERO.
#          8.  BZE                BRANCH IF MPAC ZERO.
#          9.  BMN                BRANCH IF MPAC NEGATIVE NON-ZERO.

CCALL           INCR    LOC             # MAINTAIN LOC FOR QPRET COMPUTATION.
                INDEX   LOC
                CAF     0               # GET BASE ADDRESS OF CADR LIST.
                INDEX   ADDRWD
                AD      0               # ADD INCREMENT.
                TS      FBANK           # SELECT DESIRED CADR.
                MASK    LOW10
                INDEX   A
                CAF     10000
                TS      POLISH

CALL            CA      BANKSET         # FOR ANY OF THE CALL OPTIONS, MAKE UP THE
                MASK    BANKMASK        # ADDRESS OF THE NEXT OP-CODE PAIR/STORE
                AD      BANKMASK        # CODE AND LEAVE IT IN QPRET.  NOTE THAT
                AD      LOC             # BANKMASK = -(2000 - 1).
                INDEX   FIXLOC
                TS      QPRET
                
GOTO            CA      POLISH          # BASIC BRANCHING SEQUENCE.
 +1             MASK    HIGH4
                EXTEND
                BZF     GOTOERS         # SEE IF ADDRESS POINTS TO FIXED OR ERAS.
 +4             CA      BANKSET         # SET EBANK PART OF BBANK. NEXT, SET UP
                TS      BBANK           # FBANK. THE COMBINATION IS PICKED UP &
                CA      POLISH          # PUT INTO BANKSET AT INTPRET +2.
                TS      FBANK
                MASK    LOW10
                AD      2K
                TS      LOC
                TCF     INTPRET +3
                
                EBANK=  1400            # SO YUL DOESN'T CUSS THE "CA 1400" BELOW.
                
GOTOERS         CA      POLISH          # THE GIVEN ADDRESS IS IN ERASABLE - SEE
                AD      -ENDVAC         # IF RELATIVE TO THE WORK AREA.
                CCS     A
                CA      POLISH          # GENERAL ERASABLE.
                TCF     GOTOGE

## Page 1019
                CA      FIXLOC          # WORK AREA.
                AD      POLISH
                INDEX   A               # USE THE GIVEN ADDRESS AS THE ADDRESS OF
                CA      0               # THE BRANCH ADDRESS.
                TS      POLISH
                TCF     GOTO    +1      # ALLOWS ARBITRARY INDIRECTNESS LEVELS.
                
GOTOGE          TS      EBANK
                MASK    LOW8
                INDEX   A               # USE THE GIVEN ADDRESS AS THE ADDRESS OF
                CA      1400            # THE BRANCH ADDRESS.
                TS      POLISH
                TCF     GOTO    +1
                
CGOTO           INDEX   LOC             # COMPUTED GO TO. PICK UP ADDRESS OF CADR
                CA      1               # LIST.
                INDEX   ADDRWD          # ADD MODIFIER.
                AD      0
                TS      FBANK           # SELECT GOTO ADDRESS.
                MASK    LOW10
                INDEX   A
                CA      10000
                TS      POLISH
                TCF     GOTO    +1      # WITH ADDRESS IN A.
                
SWBRANCH        CA      BANKSET         # SWITCH INSTRUCTIONS WHICH ELECT TO
                TS      FBANK           # BRANCH COME HERE TO DO SO.
                INDEX   LOC
                CA      1
                TS      POLISH
                TCF     GOTO    +1
                
## Page 1020
#          TRIPLE PRECISION BRANCHING ROUTINE. IF CALLING TC IS AT L, RETURN IS AS FOLLOWS:

#          L+1  IF MPAC IS GREATER THAN ZERO.
#          L+2  IF MPAC IS EQUAL TO +0 OR -0.
#          L+3  IF MPAC IS LESS THAN ZERO.


BRANCH          CCS     MPAC
                TC      Q
                TCF     +2              # ON ZERO.
                TCF     NEG
                
                CCS     MPAC    +1
                TC      Q
                TCF     +2
                TCF     NEG
                
                CCS     MPAC    +2
                TC      Q
                TCF     +2
                TCF     NEG
                
Q+1             INDEX   Q
                TC      1
                
NEG             INDEX   Q               # IF FIRST NON-ZERO REGISTER WAS NEGATIVE.
                TC      2

                
Q+2             =       NEG

#          ITRACE (3) REFERS TO "EXIT".
EXIT            CA      BANKSET         # RESTORE USER'S BANK SETTING, AND LEAVE
                TS      BBANK           # INTERPRETIVE MODE.
                INDEX   LOC
                TC      1

## Page 1021
# SECTION 3 - ADD/SUBTRACT PACKAGE.

#          THE FOLLOWING OPERATIONS ARE PROVIDED FOR ADDING TO AND SUBTRACTING FROM THE MULTI-PURPOSE ACCUMULATOR
# MPAC:

#          1.  DAD                DOUBLE PRECISION ADD.
#          2.  DSU                DOUBLE PRECISION SUBTRACT.
#          3.  BDSU               DOUBLE PRECISION SUBTRACT FROM.

#          4.  TAD                TRIPLE PRECISION ADD.

#          5.  VAD                VECTOR ADD.
#          6.  VSU                VECTOR SUBTRACT.
#          7.  BVSU               VECTOR SUBTRACT FROM.

# THE INTERPRETIVE OVERFLOW INDICATOR OVFIND IS SET NON-ZERO IF OVERFLOW OCCURS IN ANY OF THE ABOVE.

VSU             CAF     BIT15           # CHANGES 0 TO DCS.
                TCF     +2
                
VAD             CAF     PRIO30          # CHANGES 0 TO DCA.
                ADS     ADDRWD
                EXTEND
                INDEX   ADDRWD
                READ    HISCALAR        # DCA  2   OR   DCS  2
                DAS     MPAC    +3
                EXTEND                  # CHECK OVERFLOW.
                BZF     +2
                TC      OVERFLWY
                
                EXTEND
                INDEX   ADDRWD
                READ    CHAN5           # DCA  4  OR  DCS  4
                DAS     MPAC    +5
                EXTEND
                BZF     +2
                TC      OVERFLWZ
                
                EXTEND
                INDEX   ADDRWD
                READ    LCHAN           # DCA  0  OR  DCS  0
                TCF     ENDVXV

DAD             EXTEND
                INDEX   ADDRWD
                DCA     0
ENDVXV          DAS     MPAC            # VXV FINISHES HERE.
                EXTEND
                BZF     DANZIG
                
## Page 1022
SETOVF          TC      OVERFLOW
                TCF     DANZIG
                
## Page 1023
DSU             EXTEND
                INDEX   ADDRWD
                DCS     0
                TCF     ENDVXV

OVERFLWZ        TS      L               # ENTRY FOR THIRD COMPONENT.
                CAF     FIVE
                TCF     +3
                
OVERFLWY        TS      L               # ENTRY FOR SECOND COMPONENT.
                CAF     THREE
                XCH     L
                
OVERFLOW        INDEX   A               # ENTRY FOR 1ST COMP OR DP (L=0).
                CS      LIMITS          # PICK UP POSMAX OR NEGMAX.
                TS      BUF
                EXTEND
                AUG     A               # FORCE OVERFLOW.
                INDEX   L
                ADS     MPAC    +1
                TS      7
                CAF     ZERO
                AD      BUF
                INDEX   L
                ADS     MPAC
                TS      7
                TC      Q               # NO OVERFLOW EXIT.
                TCF     SETOVF2         # SET OVFIND AND EXIT.
                
BVSU            EXTEND
                INDEX   ADDRWD
                DCA     2
                DXCH    MPAC    +3
                EXTEND
                DCOM    
                DAS     MPAC    +3
                EXTEND
                BZF     +2
                TC      OVERFLWY
                
                EXTEND
                INDEX   ADDRWD
                DCA     4
                DXCH    MPAC    +5
                EXTEND
                DCOM
                DAS     MPAC    +5
                EXTEND
                BZF     +2
                TC      OVERFLWZ
                
## Page 1024
BDSU            EXTEND
                INDEX   ADDRWD
                DCA     0
                DXCH    MPAC
                EXTEND
                DCOM
                TCF     ENDVXV
                
## Page 1025
#          TRIPLE PRECISION ADD ROUTINE.

TAD             EXTEND
                INDEX   ADDRWD
                DCA     1               # ADD MINOR PARTS FIRST.
                DAS     MPAC    +1
                INDEX   ADDRWD
                AD      0
                AD      MPAC
                TS      MPAC
                TCF     DANZIG
                
                TCF     SETOVF          # SET OVFIND IF SUCH OCCURS.
                
## Page 1026
# ARITHMETIC SUBROUTINES REQUIRED IN FIXED-FIXED.

#          1.  DMPSUB     DOUBLE PRECISION MULTIPLY. MULTIPLY THE CONTENTS OF MPAC,+1 BY THE DP WORD WHOSE ADDRESS
#                         IS IN ADDRWD AND LEAVE A TRIPLE PRECISION RESULT IN MPAC.
#          2.  ROUNDSUB   ROUND THE TRIPLE PRECISON CONTENTS OF MPAC TO DOUBLE PRECISION.
#          3.  DOTSUB     TAKE THE DOT PRODUCT OF THE VECTOR IN MPAC AND THE VECTOR WHOSE ADDRESS IS IN ADDRWD
#                         AND LEAVE THE TRIPLE PRECISION RESULT IN MPAC.
#          4.  POLY       USING THE CONTENTS OF MPAC AS A DP ARGUMENT, EVALUATE THE POLYNOMIAL WHOSE DEGREE AND
#                         COEFFICIENTS IMMEDIATELY FOLLOW THE TC POLY INSTRUCTION (SEE ROUTINE FOR DETAILS.)


DMP             INDEX   Q               # BASIC SUBROUTINE FOR USE BY PINBALL, ETC
                CAF     0               # ADRES OF ARGUMENT FOLLOWS  TC DMP  .
                INCR    Q
 -1             TS      ADDRWD          # (PROLOGUE FOR SETTING ADDRWD.)

DMPSUB          INDEX   ADDRWD          # GET MINOR PART OF OPERAND AT C(ADDRWD).
                CA      1
                TS      MPAC    +2      # THIS WORKS FOR SQUARING MPAC AS WELL.
                CAF     ZERO            # SET MPAC +1 TO ZERO SO WE CAN ACCUMULATE
                XCH     MPAC    +1      # THE PARTIAL PRODUCTS WITH DAS
                TS      MPTEMP          # INSTRUCTIONS.
                EXTEND
                MP      MPAC    +2      # MINOR OF MPAC X MINOR OF C(ADDRWD).

                XCH     MPAC    +2      # DISCARD MINOR PART OF ABOVE RESULT AND
                EXTEND                  # FORM MAJOR OF MPAC X MINOR OF C(ADDRWD).
                MP      MPAC
                DAS     MPAC    +1      # GUARANTEED NO OVERFLOW.
                
                INDEX   ADDRWD          # GET MAJOR PART OF ARGUMENT AT C(ADDRWD).
                CA      0
                XCH     MPTEMP          # SAVE AND BRING OUT MINOR OF MPAC.
DMPSUB2         EXTEND  
                MP      MPTEMP          # MAJOR OF C(ADDRWD) X MINOR OF MPAC.
                DAS     MPAC    +1      # ACCUMULATE, SETTING A TO NET OVERFLOW.

                XCH     MPAC            # SETTING MPAC TO 0 OR +-1.
                EXTEND
                MP      MPTEMP          # MAJOR OF MPAC X MAJOR OF C(ADDRWD).
                DAS     MPAC            # GUARANTEED NO OVERFLOW.
                TC      Q               # 49 MCT = .573 MS. INCLUDING RETURN.
                
## Page 1027
#          ROUND MPAC TO DOUBLE PRECISION, SETTING OVFIND ON THE RARE EVENT OF OVERFLOW.

ROUNDSUB        CAF     ZERO            # SET MPAC +2 = 0 FOR SCALARS AND CHANGE
 +1             TS      MODE            # MODE TO DP.

VROUND          XCH     MPAC    +2      # BUT WE NEEDNT TAKE THE TIME FOR VECTORS.
                DOUBLE
                TS      L
                TC      Q

                AD      MPAC    +1      # ADD ROUNDING BIT IF MPAC +2 WAS GREATER
                TS      MPAC    +1      # THAN .5 IN MAGNITUDE.
                TC      Q

                AD      MPAC            # PROPAGATE INTERFLOW.
                TS      MPAC
                TC      Q

SETOVF2         TS      OVFIND          # (RARE).
                TC      Q

## Page 1028
#          THE DOT PRODUCT SUBROUTINE USUALLY FORMS THE DOT PRODUCT OF THE VECTOR IN MPAC WITH A STANDARD SIX
# REGISTER VECTOR WHOSE ADDRESS IS IN ADDRWD. IN THIS CASE C(DOTINC) ARE SET TO 2. VXM, HOWEVER, SETS C(DOTINC) TO
# 6 SO THAT DOTSUB DOTS MPAC WITH A COLUMN VECTOR OF THE MATRIX IN QUESTION IN THIS CASE.


PREDOT          CAF     TWO             # PROLOGUE TO SET DOTINC TO 2.
                TS      DOTINC

DOTSUB          EXTEND
                QXCH    DOTRET          # SAVE RETURN.
                TC      DMPSUB          # DOT X COMPONENTS.
                DXCH    MPAC    +3      # POSITION Y COMPONENT OF MPAC FOR
                DXCH    MPAC            # MULTIPLICATION WHILE SAVING RESULT IN
                DXCH    BUF             # THREE WORD BUFFER, BUF.
                CA      MPAC    +2
                TS      BUF     +2

                CA      DOTINC          # ADVANCE ADDRWD TO Y COMPONENT OF
                ADS     ADDRWD          # OTHER ARGUMENT.
                TC      DMPSUB
                DXCH    MPAC    +1      # ACCUMULATE PARTIAL PRODUCTS.
                DAS     BUF     +1
                AD      MPAC
                AD      BUF
                TS      BUF
                TCF     +2
                TS      OVFIND          # IF OVERFLOW OCCURS.
                
                DXCH    MPAC    +5      # MULTIPLY Z COMPONENTS.
                DXCH    MPAC
                CA      DOTINC
                ADS     ADDRWD
                TC      DMPSUB
ENDDOT          DXCH    BUF     +1      # LEAVE FINAL ACCUMULATION IN MPAC.
                DAS     MPAC    +1
                AD      MPAC
                AD      BUF
                TS      MPAC
                TC      DOTRET

                TC      OVERFLOW        # ON OVERFLOW HERE.
                TC      DOTRET

## Page 1029
# DOUBLE PRECISION POLYNOMIAL EVALUATOR

#                                    N        N-1
#          THIS ROUTINE EVALUATES A X  + A   X    + ... + A X + A  LEAVING THE DP RESULT IN MPAC ON EXIT.
#                                  N      N-1              1     0

# THE ROUTINE HAS TWO ENTRIES

#          1. ENTRY THRU POWRSERS. THE COEFFICIENTS MAY BE EITHER IN FIXED OR ERASABLE, THE CALL IS BY
#             TC POWRSERS, AND THE RETURN IS TO LOC(TC POWRSERS)+1. THE ENTERING DATA MUST BE AS FOLLOWS

#                                         A        SP     LOC-3           ADDRESS FOR REFERENCING COEF TABLE
#                                         L        SP     N-1             N IS THE DEGREE OF THE POWER SERIES
#                                         MPAC     DP     X               ARGUMENT

#                                         LOC-2N   DP     A(0)
#                                                  ...
#                                         LOC      DP     A(N)

#          2. ENTRY THRU POLY. THE CALL TO POLY AND THE ENTERING DATA MUST BE AS FOLLOWS

#                                         MPAC     DP     X               ARGUMENT
#                                         LOC      TC     POLY
#                                         LOC+1    SP     N-1
#                                         LOC+2    DP     A(0)
#                                                  ...
#                                         LOC+2N+2 DP     A(N)            RETURN IS TO LOC+2N+4

POWRSERS        EXTEND
                QXCH    POLYRET         # RETURN ADDRESS
                TS      POLISH          # POWER SERIES ADDRESS
                LXCH    POLYCNT         # N-1 TO COUNTER
                TCF     POLYCOM         # SKIP SET UP BY POLY

POLY            INDEX   Q
                CAF     0
                TS      POLYCNT         # N-1 TO COUNTER
                DOUBLE
                AD      Q
                TS      POLISH          # L(A(N))-3 TO POLISH
                AD      FIVE
                TS      POLYRET         # STORE RETURN ADDRESS

POLYCOM         CAF     LVBUF           # INCOMING X WILL BE MOVED TO VBUF, SO
                TS      ADDRWD          # SET ADDRWD SO DMPSUB WILL MPY BY VBUF.
                
                EXTEND
                INDEX   POLISH
                DCA     3
## Page 1030
                DXCH    MPAC            # LOAD A(N) INTO MPAC,
                DXCH    VBUF            # SAVING X IN VBUF
                TCF     POLY2
                
POLYLOOP        TS      POLYCNT         # SAVE DECREMENTED LOOP COUNTER
                CS      TWO
                ADS     POLISH          # REGRESS COEFFICIENT POINTER
                
POLY2           TC      DMPSUB          # MULTIPLY BY X
                EXTEND
                INDEX   POLISH
                DCA     1               # ADD IN NEXT COEFFICIENT
                DAS     MPAC            # USERS RESPONSIBILITY TO ASSURE NO OVFLOW
                
                CCS     POLYCNT
                TCF     POLYLOOP
                TC      POLYRET         # RETURN CALLER
                
## Page 1031
#          MISCELLANEOUS MULTI-PRECISION ROUTINES REQUIRED IN FIXED-FIXED BUT NOT USED BY THE INTERPRETER.

DPAGREE         CAF     ZERO            # DOUBLE PRECISION ENTRY -
                TS      MPAC    +2      # ZERO LOW-ORDER WORD

TPAGREE         LXCH    Q               # FORCE SIGN AGREEMENT AMONG THE TRIPLE
                TC      BRANCH          # PRECISION CONTENTS OF MPAC.  RETURNING
                TCF     ARG+            # WITH SIGNUM OF THE INPUT IN A.
                TCF     ARGZERO

                CS      POSMAX          # IF NEGATIVE.
                TCF             +2

ARG+            CAF     POSMAX
                TS      Q
                EXTEND
                AUG     A               # FORMS +-1.0.
                AD      MPAC    +2
                TS      MPAC    +2
                CAF     ZERO
                AD      Q
                AD      MPAC    +1
                TS      MPAC    +1
                CAF     ZERO
                AD      Q               # Q STILL HAS POSMAX OR NEGMAX IN IT.
                AD      MPAC
ARGZERO2        TS      MPAC            # ALWAYS SKIPPING UNLESS ARGZERO.
                TS      MPAC    +1
                TC      L               # RETURN VIA L.

ARGZERO         TS      MPAC    +2      # SET ALL THREE MPAC REGISTERS TO ZERO.
                TCF     ARGZERO2

#          SHORTMP MULTIPLIES THE TP CONTENTS OF MPAC BY THE SINGLE PRECISION NUMBER ARRIVING IN A.

SHORTMP         TS      MPTEMP
                EXTEND
                MP      MPAC    +2
                TS      MPAC    +2
SHORTMP2        CAF     ZERO            # SO SUBSEQUENT DAS WILL WORK.
                XCH     MPAC    +1
                TCF     DMPSUB2

## Page 1032
#        DMPNSUB MULTIPLIES THE DP FRACTION ARRIVING IN MPAC BY THE SP
# INTEGER ARRIVING IN A.  THE DP PRODUCT DEPARTS BOTH IN MPAC AND IN
# A AND L.  NOTE THAT DMPNSUB NORMALLY INCREASES THE MAGNITUDE OF THE
# CONTENTS OF MPAC.  THE CUSTOMER MUST INSURE THAT B(A) X B(MPAC,MPAC+1)
# AND B(A) X B(MPAC) ARE LESS THAN 1 IN MAGNITUDE, WHERE B, AS IS OBVIOUS,
# INDICATES THE ARRIVING CONTENTS.

DMPNSUB         TS      DMPNTEMP
                EXTEND
                MP      MPAC    +1
                DXCH    MPAC            # LOW PRODUCT TO MPAC, HIGH FACTOR TO A
                EXTEND
                MP      DMPNTEMP
                CA      L
                ADS     MPAC            # COMPLETING THE PRODUCT IN MPAC
                EXTEND
                DCA     MPAC            # BRINGING THE PRODUCT INTO A AND L
                TC      Q

## Page 1033
# MISCELLANEOUS VECTOR OPERATIONS. INCLUDED HERE ARE THE FOLLOWING:

#          1.  DOT                DP VECTOR DOT PRODUCT.
#          2.  VXV                DP VECTOR CROSS PRODUCT.
#          3.  VXSC               DP VECTOR TIMES SCALAR.
#          4.  V/SC               DP VECTOR DIVIDED BY SCALAR.
#          5.  VPROJ              DP VECTOR PROJECTION. ( (MPAC.X)MPAC ).
#          6.  VXM                DP VECTOR POST-MULTIPLIED BY MATRIX.
#          7.  MXV                DP VECTOR PRE-MULTIPLIED BY MATRIX.


DOT             TC      PREDOT          # DO THE DOT PRODUCT AND EXIT, CHANGING
DMODE           CAF     ZERO            # THE MODE TO DP SCALAR.
                TCF     NEWMODE


MXV             CAF     TWO             # SET UP MATINC AND DOTINC FOR ROW
                TS      MATINC          # VECTORS.
                TCF     VXM/MXV         # GO TO COMMON PORTION.

VXM             CS      TEN             # SET MATINC AND DOTINC TO REFER TO MATRIX
                TS      MATINC          # AS THREE COLUMN VECTORS.
                CAF     SIX

## Page 1034
#          COMMON PORTION OF MXV AND VXM.

VXM/MXV         TS      DOTINC
#          ITRACE (2) REFERS TO "VXM/MXV".
                TC      MPACVBUF        # SAVE VECTOR IN MPAC FOR FURTHER USE.

                TC      DOTSUB          # GO DOT TO GET X COMPONENT OF ANSWER.
                EXTEND
                DCA     VBUF            # MOVE MPAC VECTOR BACK INTO MPAC, SAVING
                DXCH    MPAC            # NEW X COMPONENT IN BUF2.
                DXCH    BUF2
                EXTEND
                DCA     VBUF    +2
                DXCH    MPAC    +3
                EXTEND
                DCA     VBUF    +4
                DXCH    MPAC    +5
                CA      MATINC          # INITIALIZE ADDRWD FOR NEXT DOT PRODUCT.
                ADS     ADDRWD          # FORMS BASE ADDRESS OF NEXT COLUMN(ROW).

                TC      DOTSUB
                DXCH    VBUF            # MOVE GIVEN VECTOR BACK TO MPAC, SAVING Y
                DXCH    MPAC            # COMPONENT OF ANSWER IN VBUF +2.
                DXCH    VBUF    +2
                DXCH    MPAC    +3
                DXCH    VBUF    +4
                DXCH    MPAC    +5
                CA      MATINC          # FORM ADDRESS OF LAST COLUMN OR ROW.
                ADS     ADDRWD

                TC      DOTSUB
                DXCH    BUF2            # ANSWER NOW COMPLETE. PUT COMPONENTS INTO
                DXCH    MPAC            # PROPER MPAC REGISTERS.
                DXCH    MPAC    +5
                DXCH    VBUF    +2
                DXCH    MPAC    +3
                TCF     DANZIG          # EXIT.

## Page 1035
#          VXSC - VECTOR TIMES SCALAR.

VXSC            CCS     MODE            # TEST PRESENT MODE.
                TCF     DVXSC           # SEPARATE ROUTINE WHEN SCALAR IS IN MPAC.
                TCF     DVXSC

VVXSC           TC      DMPSUB          # COMPUTE X COMPONENT
                TC      VROUND          # AND ROUND IT.
                DXCH    MPAC    +3      # PUT Y COMPONENT INTO MPAC SAVING MPAC IN
                DXCH    MPAC            # MPAC +3.
                DXCH    MPAC    +3

                TC      DMPSUB          # DO SAME FOR Y AND Z COMPONENTS.
                TC      VROUND
                DXCH    MPAC    +5
                DXCH    MPAC
                DXCH    MPAC    +5

                TC      DMPSUB
                TC      VROUND
VROTATEX        DXCH    MPAC            # EXIT USED TO RESTORE MPAC AFTER THIS
                DXCH    MPAC    +5      # TYPE OF ROTATION. CALLED BY VECTOR SHIFT
                DXCH    MPAC    +3      # RIGHT, V/SC, ETC.
                DXCH    MPAC
                TCF     DANZIG

## Page 1036
#          DP VECTOR PROJECTION ROUTINE.

VPROJ           TC      PREDOT          # (MPAC.X)MPAC IS COMPUTED AND LEFT IN
                CS      FOUR            # MPAC. DO DOT AND FALL INTO DVXSC.
                ADS     ADDRWD

#          VXSC WHEN SCALAR ARRIVES IN MPAC AND VECTOR IS AT X.

DVXSC           EXTEND                  # SAVE SCALAR IN MPAC +3 AND GET X
                DCA     MPAC            # COMPONENT OF ANSWER.
                DXCH    MPAC    +3
                TC      DMPSUB
                TC      VROUND

                CAF     TWO             # ADVANCE ADDRWD TO Y COMPONENT OF X.
                ADS     ADDRWD
                EXTEND
                DCA     MPAC    +3      # PUT SCALAR BACK INTO MPAC AND SAVE
                DXCH    MPAC            # X RESULT IN MPAC +5.
                DXCH    MPAC    +5
                TC      DMPSUB
                TC      VROUND

                CAF     TWO
                ADS     ADDRWD          # TO Z COMPONENT.
                DXCH    MPAC    +3      # BRING SCALAR BACK, PUTTING Y RESULT IN
                DXCH    MPAC            # THE PROPER PLACE.
                DXCH    MPAC    +3
                TC      DMPSUB
                TC      VROUND

                DXCH    MPAC            # PUT Z COMPONENT IN PROPER PLACE, ALSO
                DXCH    MPAC    +5      # POSITIONING X.
                DXCH    MPAC

                TCF     VMODE           # MODE HAS CHANGED TO VECTOR.

## Page 1037
#          THE VECTOR CROSS PRODUCT ROUTINE CALCULATES (X M -X M ,X M -X M ,X M -X M ) WHERE M IS THE VECTOR IN
#                                                        3 2  2 3  1 3  3 1  2 1  1 2
# MPAC AND X THE VECTOR AT THE GIVEN ADDRESS.


VXV             EXTEND
                DCA     MPAC    +5      # FORM UP M3X1, LEAVING M1 IN VBUF.
                DXCH    MPAC
                DXCH    VBUF
                TC      DMPSUB          # BY X1.

                EXTEND
                DCS     MPAC    +3      # CALCULATE -X1M2, SAVING X1M3 IN VBUF +2.
                DXCH    MPAC
                DXCH    VBUF    +2
                TC      DMPSUB

                CAF     TWO             # ADVANCE ADDRWD TO X2.
                ADS     ADDRWD
                EXTEND
                DCS     MPAC    +5      # PREPARE TO GET -X2M3, SAVING -X1M2 IN
                DXCH    MPAC            # MPAC +5.
                DXCH    MPAC    +5
                TC      DMPSUB

                EXTEND
                DCA     VBUF            # GET X2M1, SAVING -X2M3 IN VBUF +4.
                DXCH    MPAC
                DXCH    VBUF    +4
                TC      DMPSUB

                CAF     TWO             # ADVANCE ADDRWD TO X3.
                ADS     ADDRWD
                EXTEND
                DCS     VBUF            # GET -X3M1, ADDING X2M1 TO MPAC +5 TO
                DXCH    MPAC            # COMPLETE THE Z COMPONENT OF THE ANSWER.
                DAS     MPAC    +5

                EXTEND
                BZF     +2
                TC      OVERFLWZ

                TC      DMPSUB
                DXCH    VBUF    +2      # MOVE X1M3 TO MPAC +3 SETTING UP FOR X3M2
                DXCH    MPAC    +3      # AND ADD -X3M1 TO MPAC +3 TO COMPLETE THE
                DXCH    MPAC            # Y COMPONENT OF THE RESULT.
                DAS     MPAC    +3

                EXTEND
                BZF             +2
## Page 1038
                TC OVERFLWY

                TC      DMPSUB
                DXCH    VBUF    +4      # GO ADD -X2M3 TO X3M2 TO COMPLETE THE X
                TCF     ENDVXV          # COMPONENT (TAIL END OF DAD).

#          THE MPACVBUF SUBROUTINE SAVES THE VECTOR IN MPAC IN VBUF WITHOUT CLOBBERING MPAC.

MPACVBUF        EXTEND                  # CALLED BY MXV, VXM, AND UNIT.
                DCA     MPAC
                DXCH    VBUF
                EXTEND
                DCA     MPAC    +3
                DXCH    VBUF    +2
                EXTEND
                DCA     MPAC    +5
                DXCH    VBUF    +4
                TC      Q               # RETURN TO CALLER.


#          DOUBLE PRECISION SIGN AGREE ROUTINE. ARRIVE WITH INPUT IN A+L. OUTPUT IS IN A + L.

ALSIGNAG        CCS     A               # TEST UPPER PART.
                TCF     UPPOS           # IT IS POSITIVE
                TC      Q               # ZERO
                TCF     UPNEG           # NEGATIVE
                TC      Q               # ZERO

UPPOS           XCH     L               # SAVE DECREMENTED UPPER PART.
                AD      HALF
                AD      HALF
                TS      A               # SKIPS ON OVERFLOW
                TCF     +2
                INCR    L               # RESTORE UPPER TO ROIGINAL VALUE
                XCH     L               # SWAP A + L BACK.
                TC      Q

UPNEG           XCH     L               # SAVE COMPLEMENTED + DECREMENTED UPPER PT
                AD      NEGMAX
                AD      NEGONE
                TS      A
                TCF     +2              # DONT INCREMENT IF NO OVERFLOW.
                INCR    L
                XCH     L
                COM                     # MAKE NEGATIVE AGAIN.
                TC      Q

## Page 1039
#          INTERPRETIVE INSTRUCTIONS WHOSE EXECUTION CONSISTS OF PRINCIPALLY CALLING SUBROUTINES.

DMP1            TC      DMPSUB          # DMP INSTRUCTION.
                TCF     DANZIG

DMPR            TC      DMPSUB
                TC      ROUNDSUB +1     # (C(A) = +0).
                TCF     DANZIG

DDV             EXTEND
                INDEX   ADDRWD          # MOVE DIVIDEND INTO BUF.
                DCA     0
                TCF     BDDV    +4

BDDV            EXTEND                  # MOVE DIVISOR INTO MPAC SAVING MPAC, THE
                INDEX   ADDRWD          # DIVIDEND, IN BUF.
                DCA     0
                DXCH    MPAC
 +4             DXCH    BUF
                CAF     ZERO            # DIVIDE ROUTINES IN BANK 0.
                TS      FBANK
                TCF     DDV/BDDV

SETPD           CA      ADDRWD          # MUST SET TO WORK AREA, OR EBANK TROUBLE.
                TS      PUSHLOC
                TCF     NOIBNKSW        # NO FBANK SWITCH REQUIRED.

TSLC            CAF     ZERO            # SHIFTING ROUTINES LOCATED IN BANK 00.
                TS      FBANK
                TCF     TSLC2

GSHIFT          CAF     LOW7            # USED AS MASK AT GENSHIFT. THIS PROCESSES
                TS      FBANK           # ANY SHIFT INSTRUCTION (EXCEPT TSLC) WITH
                TCF     GENSHIFT        # AN ADDRESS (ROUTINES IN BANK 0).

## Page 1040
#          THE FOLLOWING IS THE PROLOGUE TO V/SC. IF THE PRESENT MODE IS VECTOR, IT SAVES THE SCALAR AT X IN BUF
# AND CALLS THE V/SC ROUTINE IN BANK 0. IF THE PRESENT MODE IS SCALAR, IT MOVES THE VECTOR AT X INTO MPAC, SAVING
# THE SCALAR IN MPAC IN BUF BEFORE CALLING THE V/SC ROUTINE IN BANK 0.

V/SC            CCS     MODE
                TCF     DV/SC           # MOVE VECTOR INTO MPAC.
                TCF     DV/SC

VV/SC           EXTEND
                INDEX   ADDRWD
                DCA     0
V/SC1           DXCH    BUF             # IN BOTH CASES, VECTOR IS NOW IN MPAC AND
                CAF     ZERO            # SCALAR IN BUF.
                TS      FBANK
                TCF     V/SC2

DV/SC           EXTEND
                INDEX   ADDRWD
                DCA     2
                DXCH    MPAC    +3
                EXTEND
                INDEX   ADDRWD
                DCA     4
                DXCH    MPAC    +5

                CS      ONE             # CHANGE MODE TO VECTOR.
                TS      MODE

                EXTEND
                INDEX   ADDRWD
                DCA     0
                DXCH    MPAC
                TCF     V/SC1           # FINISH PROLOGUE AT COMMON SECTION.

## Page 1041
#          SIGN AND COMPLEMENT INSTRUCTIONS.

SIGN            INDEX   ADDRWD          # CALL COMP INSTRUCTION IF WORD AT X IS
                CCS     0               # NEGATIVE NON-ZERO.
                TCF     DANZIG
                TCF     +2
                TCF     COMP            # DO THE COMPLEMENT.

                INDEX   ADDRWD
CCSL            CCS     1
                TCF     DANZIG
                TCF     DANZIG
                TCF     COMP
                TCF     DANZIG
COMP            EXTEND                  # COMPLEMENT DP MPAC IN EVERY CASE.
                DCS     MPAC
                DXCH    MPAC

                CCS     MODE            # EITHER COMPLEMENT MPAC +3 OR THE REST OF
                TCF     DCOMP           # THE VECTOR ACCUMULATOR.
                TCF     DCOMP

                EXTEND                  # VECTOR COMPLEMENT.
                DCS     MPAC    +3
                DXCH    MPAC    +3
                EXTEND
                DCS     MPAC    +5
                DXCH    MPAC    +5
                TCF     DANZIG

DCOMP           CS      MPAC    +2
                TS      MPAC    +2
                TCF     DANZIG

## Page 1042
#          THE FOLLOWING SHORT SHIFT CODES REQUIRE NO ADDRESS WORD:

#          1.  SR1 TO SR4         SCALAR SHIFT RIGHT.
#          2.  SR1R TO SR4R       SCALAR SHIFT RIGHT AND ROUND.
#          3.  SL1 TO SL4         SCALAR SHIFT LEFT.
#          4.  SL1R TO SL4R       SCALAR SHIFT LEFT AND ROUND.

#          5.  VSR1 TO VSR8       VECTOR SHIFT RIGHT (ALWAYS ROUNDS).
#          6.  VSL1 TO VSL8       VECTOR SHIFT LEFT (NEVER ROUNDS).

#          THE FOLLOWING CODES REQUIRE AN ADDRESS WHICH MAY BE INDEXED:*

#          1.  SR                 SCALAR SHIFT RIGHT.
#          2.  SRR                SCALAR SHIFT RIGHT AND ROUND.
#          3.  SL                 SCALAR SHIFT LEFT.
#          4.  SLR                SCALAR SHIFT LEFT AND ROUND.

#          5.  VSR                VECTOR SHIFT RIGHT.
#          6.  VSL                VECTOR SHIFT LEFT.

# *  IF THE ADDRESS IS INDEXED, AND THE INDEX MODIFICATION RESULTS IN A NEGATIVE SHIFT COUNT, A SHIFT OF THE
# ABSOLUTE VALUE OF THE COUNT IS DONE IN THE OPPOSITE DIRECTION.


                BANK    00

                COUNT*  $$/INTER
SHORTT          CAF     SIX             # SCALAR SHORT SHIFTS COME HERE. THE SHIFT
                MASK    CYR             # COUNT-1 IS NOW IN BITS 2-3 OF CYR. THE
                TS      SR              # ROUNDING BIT IS IN BIT1 AT THIS POINT.

                CCS     CYR             # SEE IF RIGHT OR LEFT SHIFT DESIRED.
                TCF     TSSL            # SHIFT LEFT.

SRDDV           DEC     20              # MPTEMP SETTING FOR SR BEFORE DDV.

TSSR            INDEX   SR              # GET SHIFTING BIT.
                CAF     BIT14
                TS      MPTEMP

                CCS     CYR             # SEE IF A ROUND IS DESIRED.
RIGHTR          TC      MPACSRND        # YES - SHIFT RIGHT AND ROUND.
                TCF     NEWMODE         # SET MODE TO DP (C(A) = 0).
MPACSHR         CA      MPTEMP          # DO A TRIPLE PRECISION SHIFT RIGHT.
                EXTEND
                MP      MPAC    +2
 +3             TS      MPAC    +2      # (EXIT FROM SQRT AND ABVAL).
                CA      MPTEMP
                EXTEND
                MP      MPAC            # SHIFT MAJOR PART INTO A,L AND PLACE IN
## Page 1043
                DXCH    MPAC            # MPAC,+1.
                CA      MPTEMP
                EXTEND
                MP      L               # ORIGINAL C(MPAC +1).
                DAS     MPAC    +1      # GUARANTEED NO OVERFLOW.
                TCF     DANZIG

#          MPAC SHIFT RIGHT AND ROUND SUBROUTINES.

MPACSRND        CA      MPAC    +2      # WE HAVE TO DO ALL THREE MULTIPLIES SINCE
                EXTEND                  # MPAC +1 AND MPAC +2 MIGHT HAVE SIGN
                MP      MPTEMP          # DISAGREEMENT WITH A SHIFT RIGHT OF 1.
                XCH     MPAC    +1
                EXTEND
                MP      MPTEMP
                XCH     MPAC    +1      # TRIAL MINOR PART.
                AD      L

VSHR2           DOUBLE                  # (FINISH VECTOR COMPONENT SHIFT RIGHT
                TS      MPAC    +2      # AND ROUND.
                TCF     +2
                ADS     MPAC    +1      # GUARANTEED NO OVERFLOW.

                CAF     ZERO
                TS      MPAC    +2
                XCH     MPAC            # SETTING TO ZERO SO FOLLOWING DAS WORKS.
                EXTEND
                MP      MPTEMP
                DAS     MPAC            # AGAIN NO OVERFLOW.
                TC      Q

VSHRRND         CA      MPTEMP          # ENTRY TO SHIFT RIGHT AND ROUND MPAC WHEN
                EXTEND                  # MPAC CONTAINS A VECTOR COMPONENT.
                MP      MPAC    +1
                TS      MPAC    +1
                XCH     L
                TCF     VSHR2           # GO ADD ONE IF NECESSARY AND FINISH.

## Page 1044
#          ROUTINE FOR SHORT SCALAR SHIFT LEFT (AND MAYBE ROUND).

TSSL            CA      SR              # GET SHIFT COUNT FOR SR.
 +1             TS      MPTEMP

 +2             EXTEND                  # ENTRY HERE FROM SL FOR SCALARS.
                DCA     MPAC    +1      # SHIFTING LEFT ONE PLACE AT A TIME IS
                DAS     MPAC    +1      # FASTER THAN DOING THE WHOLE SHIFT WITH
                AD      MPAC            # MULTIPLIES ASSUMING THAT FREQUENCY OF
                AD      MPAC            # SHIFT COUNTS GOES DOWN RAPIDLY AS A
                TS      MPAC            # FUNCTION OF THEIR MAGNITUDE.
                TCF     +2
                TS      OVFIND          # OVERFLOW. (LEAVES OVERFLOW-CORRECTED
                                        # RESULT ANYWAY).
                CCS     MPTEMP          # LOOP ON DECREMENTED SHIFT COUNT.
                TCF     TSSL    +1

                CCS     CYR             # SEE IF ROUND WANTED.
ROUND           TC      ROUNDSUB        # YES - ROUND AND EXIT.
                TCF     DANZIG          # SL LEAVES A ZERO IN CYR FOR NO ROUND.
                TCF     DANZIG          # NO - EXIT IMMEDIATL

## Page 1045
# VECTOR SHIFTING ROUTINES.

SHORTV          CAF     LOW3            # SAVE 3 BIT SHIFT COUNT - 1 WITHOUT
                MASK    CYR             # EDITING CYR.
                TS      MPTEMP
                CCS     CYR             # SEE IF LEFT OR RIGHT SHIFT.
                TCF     VSSL            # VECTOR SHIFT LEFT.
OCT176          OCT     176             # USED IN PROCESSED SHIFTS WITH - COUNT.

VSSR            INDEX   MPTEMP          # (ENTRY FROM SR). PICK UP SHIFTING BIT.
                CAF     BIT14           # MPTEMP CONTAINS THE SHIFT COUNT - 1.
                TS      MPTEMP
                TC      VSHRRND         # SHIFT X COMPONENT.

                DXCH    MPAC            # SWAP X AND Y COMPONENTS.
                DXCH    MPAC    +3
                DXCH    MPAC
                TC      VSHRRND         # SHIFT Y COMPONENT.

                DXCH    MPAC            # SWAP Y AND Z COMPONENTS.
                DXCH    MPAC    +5
                DXCH    MPAC
                TC      VSHRRND         # SHIFT Z COMPONENT.

                TCF     VROTATEX        # RESTORE COMPONENTS TO PROPER PLACES.

## Page 1046
# VECTOR SHIFT LEFT - DONE ONE PLACE AT A TIME.

 -1             TS      MPTEMP          # SHIFTING LOOP.

VSSL            EXTEND
                DCA     MPAC
                DAS     MPAC
                EXTEND
                BZF     +2
                TC      OVERFLOW

                EXTEND
                DCA     MPAC    +3
                DAS     MPAC    +3
                EXTEND
                BZF     +2
                TC      OVERFLWY

                EXTEND
                DCA     MPAC    +5
                DAS     MPAC    +5
                EXTEND
                BZF     +2
                TC      OVERFLWZ

                CCS     MPTEMP          # LOOP ON DECREMENTED SHIFT COUNTER.
                TCF     VSSL    -1
                TCF     DANZIG          # EXIT.

## Page 1047
#          TSLC - TRIPLE SHIFT LEFT AND COUNT. SHIFTS MPAC LEFT UNTIL GREATER THAN .5 IN MAGNITUDE, LEAVING
# THE COMPLEMENT OF THE NUMBER OF SHIFTS REQUIRED IN X.

TSLC2           TS      MPTEMP          # START BY ZEROING SHIFT COUNT (IN A NOW).
                TC      BRANCH          # EXIT WITH NO SHIFTING IF ARGUMENT ZERO.
                TCF     +2
                TCF     ENDTSLC         # STORES ZERO SHIFT COUNT IN THIS CASE.

                TC      TPAGREE         # MAY CAUSE UPSHIFT OF ONE EXTRA PLACE.

                CA      MPAC            # BEGIN NORMALIZATION LOOP.
                TCF     TSLCTEST

TSLCLOOP        INCR    MPTEMP          # INCREMENT SHIFT COUNTER.
                EXTEND
                DCA     MPAC    +1
                DAS     MPAC    +1
                AD      MPAC
                ADS     MPAC
TSLCTEST        DOUBLE                  # SEE IF (ANOTHER) SHIFT IS REQUIRED.
                OVSK
                TCF     TSLCLOOP        # YES - INCREMENT COUNT AND SHIFT AGAIN.

ENDTSLC         CS      MPTEMP
                TCF     STORE1          # STORE SHIFT COUNT AND RETURN TO DANZIG.

## Page 1048
#          THE FOLLOWING ROUTINES PROCESSES THE GENERAL SHIFT INSTRUCTIONS SR, SRR, SL, AND SLR.
# THE GIVEN ADDRESS IS DECODED AS FOLLOWS:

#          BITS 1-7    SHIFT COUNT (SUBADDRESS) LESS THAN 125 DECIMAL.
#          BIT 8       PSEUDO SIGN BIT (DETECTS CHANGE IN SIGN IN INDEXED SHIFTS).
#          BIT 9       0 FOR LEFT SHIFT, AND 1 FOR RIGHT SHIFT.
#          BIT 10      1 FOR TERMINAL ROUND ON SCALAR SHIFTS, 0 OTHERWISE.
#          BITS 11-13  0.
#          BIT 14      1.
#          BIT 15      0.

# THE ABOVE ENCODING IS DONE BY THE YUL SYSTEM.

GENSHIFT        MASK    ADDRWD          # GET SHIFT COUNT, TESTING FOR ZERO.
                CCS     A               # (ARRIVES WITH C(A) = LOW7).
                TCF     GENSHFT2        # IF NON-ZERO, PROCEED WITH DECREMENTED CT

                CAF     BIT10           # ZERO SHIFT COUNT. NO SHIFTS NEEDED BUT
                MASK    ADDRWD          # WE MIGHT HAVE TO ROUND MPAC ON SLR AND
                CCS     A               # SRR (SCALAR ONLY).
                TC      ROUNDSUB
                TCF     DANZIG

GENSHFT2        TS      MPTEMP          # DECREMENTED SHIFT COUNT TO MPTEMP.
                CAF     BIT8            # TEST MEANING OF LOW SEVEN BIT COUNT IN
                EXTEND                  # MPTEMP NOW.
                MP      ADDRWD
                MASK    LOW2            # JUMPS ON SHIFT DIRECTION (BIT8) AND
                INDEX   A
                TCF     +1              # ORIGINAL SHIFT DIRECTION (BIT 9).
                TCF     RIGHT-          # NEGATIVE SHIFT COUNT FOR SL OR SLR.
                TCF     LEFT            # SL OR SLR.
                TCF     LEFT-           # NEGATIVE SHIFT COUNT WITH SR OR SRR.

## Page 1049
#          GENERAL SHIFT RIGHT.

RIGHT           CCS     MODE            # SEE IF VECTOR OR SCALAR.
                TCF     GENSCR
                TCF     GENSCR

                CA      MPTEMP          # SEE IF SHIFT COUNT LESS THAN 14D.
VRIGHT2         AD      NEG12
                EXTEND
                BZMF    VSSR            # IF SO, BRANCH AND SHIFT IMMEDIATELY.

                AD      NEGONE          # IF NOT, REDUCE MPTEMP BY A TOTAL OF 14,
                TS      MPTEMP          # AND DO A SHIFT RIGHT AND ROUND BY 14.
                CAF     ZERO            # THE ROUND AT THIS STAGE MAY INTRODUCE A
                TS      L               # ONE BIT ERROR IN A SHIFT RIGHT 15D.
                XCH     MPAC
                XCH     MPAC    +1
                TC      SETROUND        # X COMPONENT NOW SHIFTED, SO MAKE UP THE
                DAS     MPAC            # ROUNDING QUANTITY (0 IN A AND 0 OR +-1
                                        # IN L).
                XCH     MPAC    +3      # REPEAT THE ABOVE PROCESS FOR Y AND Z.
                XCH     MPAC    +4
                TC      SETROUND
                DAS     MPAC    +3      # NO OVERFLOW ON THESE ADDS.

                XCH     MPAC    +5
                XCH     MPAC    +6
                TC      SETROUND
                DAS     MPAC    +5

                CCS     MPTEMP          # SEE IF DONE, DOING FINAL DECREMENT.
                TS      MPTEMP
                TCF     VRIGHT2
BIASLO          DEC     .2974   B-1     # SQRT CONSTANT

                TCF     DANZIG


SETROUND        DOUBLE                  # MAKES UP ROUNDING QUANTITY FROM ARRIVING
                TS      MPAC    +2      # C(A). L IS ZERO INITIALLY.
                CAF     ZERO
                XCH     L
                TC      Q               # RETURN AND DO THE DAS, RESETTING L TO 0.

## Page 1050
#          PROCESS SR AND SRR FOR SCALARS.

GENSCR          CA      MPTEMP          # SEE IF THE ORIGINAL SHIFT COUNT WAS LESS
 +1             AD      NEG12           # THAN 14D.
                EXTEND
                BZMF    DOSSHFT         # DO THE SHIFT IMMEDIATELY IF SO.

 +4             AD      NEGONE          # IF NOT, DECREMENT SHIFT COUNT BY 14D AND
                TS      MPTEMP          # SHIFT MPAC RIGHT 14 PLACES.
                CAF     ZERO
                XCH     MPAC
                XCH     MPAC    +1
                TS      MPAC    +2
                CCS     MPTEMP          # SEE IF FINISHED, DO FINAL DECREMENT.
                TS      MPTEMP
                TC      GENSCR  +1
SLOPEHI         DEC     .5884           # SQRT CONSTANT.
                CAF     BIT10           # FINISHED WITH SHIFT.  SEE IF ROUND
                MASK    ADDRWD          # WANTED.
                CCS     A
                TC      ROUNDSUB
                TCF     DANZIG          # DO SO AND/OR EXIT.

DOSSHFT         INDEX   MPTEMP          # PICK UP SHIFTING BIT.
                CAF     BIT14
                TS      MPTEMP
                CAF     BIT10           # SEE IF TERMINAL ROUND DESIRED.
                MASK    ADDRWD
                CCS     A
                TCF     RIGHTR          # YES.
                TCF     MPACSHR         # JUST SHIFT RIGHT.

## Page 1051
#          PROCESS THE RIGHT- (SL(R) WITH A NEGATIVE COUNT), LEFT-, AND LEFT OPTIONS.

RIGHT-          CS      MPTEMP          # GET ABSOLUTE VALUE - 1 OF SHIFT COUNT
                AD      OCT176          # UNDERSTANDING THAT BIT8 (PSEUDO-SIGN)
                TS      MPTEMP          # WAS 1 INITIALLY.
                TCF     RIGHT           # DO NORMAL SHIFT RIGHT.

LEFT-           CS      OCT176          # SAME PROLOGUE TO LEFT FOR INDEXED RIGHT
                AD      MPTEMP          # SHIFTS WHOSE NET SHIFT COUNT IS NEGATIVE
                COM
                TS      MPTEMP

LEFT            CCS     MODE            # SINCE LEFT SHIFTING IS SONE ONE PLACE AT
                TCF     GENSCL          # A TIME, NO COMPARISON WITH 14 NEED BE
                TCF     GENSCL          # DONE. FOR SCALARS, SEE IF TERMINAL ROUND
                TCF     VSSL            # DESIRED. FOR VECTORS, SHIFT IMMEDIATELY.

GENSCL          CS      ADDRWD          # PUT ROUNDING BIT (BIT 10 OF ADDRWD) INTO
                EXTEND                  # BIT 15 OF CYR WHERE THE ROUNDING BIT OF
                MP      BIT6            # A SHORT SHIFT LEFT WOULD BE
                TS      CYR
                TCF     TSSL    +2      # DO THE SHIFT.

## Page 1052
#          SCALAR DIVISION INSTRUCTIONS, DDV AND BDDV, ARE EXECUTED HERE. AT THIS POINT, THE DIVIDEND IS IN MPAC
# AND THE DIVISOR IN BUF.

DDV/BDDV        CS      ONE             # INITIALIZATION.
                TS      DVSIGN          # +-1 FOR POSITIVE QUOTIENT - -0 FOR NEG.
                TS      DVNORMCT        # DIVIDEND NORMALIZATION COUNT.
                TS      MAXDVSW         # NEAR-ONE DIVIDE FLAG.

                CCS     BUF             # FORCE BUF POSITIVE WITH THE MAJOR PART
                TCF     BUFPOS          # NON-ZERO.
                TCF     +2
                TCF     BUFNEG

BUFZERO         TS      MPAC    +2      # ZERO THIS.
                TC      TPAGREE         # FORCE SIGN AGREEMENT BEFORE OVERFLOW

                CCS     MPAC            # TEST TO SEE IF MPAC NON-ZERO.  (TOO BIG)
                TCF     OVF+            # MAJOR PART OF DIVIDEND IS POSITIVE NON-0
                TCF     +2
                TCF     OVF+    -1      # MAJOR PART OF DIVIDEND IS NEG. NON-ZERO

                XCH     BUF     +1      # SHIFT DIVIDEND AND DIVISOR LEFT 14.
                XCH     BUF
                XCH     MPAC    +1
                XCH     MPAC
                CCS     BUF             # TRY AGAIN ON FORMER MINOR PART.
                TCF     BUF+
                TCF     +2              # OVERFLOW ON ZERO DIVISOR.
                TCF     BUF-

                CS      MPAC            # SIGN OF MPAC DETERMINES SIGN OF RESULT.
SGNDVOVF        EXTEND
                BZMF    +2
                INCR    DVSIGN          # NEGMAX IN MPAC PERHAPS.
DVOVF           CAF     POSMAX          # ON DIVISION OVERFLOW OF ANY SORT, SET
                TS      MPAC            # SET DP MPAC TO +-POSMAX.
                TC      FINALDV +3
                CAF     ONE             # SET OVERFLOW INDICATOR AND EXIT.
                TS      OVFIND
                TC      DANZIG

 -1             INCR    DVSIGN
OVF+            CS      BUF     +1      # LOAD LOWER ORDER PART OF DIVISOR.
                TCF     SGNDVOVF        # GET SIGN OF RESULT.

BUF-            EXTEND                  # IF BUF IS NEGATIVE, COMPLEMENT IT AND
                DCS     BUF             # MAINTAIN DVSIGN FOR FINAL QUOTIENT SIGN.
                DXCH    BUF
                INCR    DVSIGN          # NOW -0.

## Page 1053
BUF+            CCS     MPAC            # FORCE MPAC POSITIVE, CHECKING FOR ZERO
                TCF     MPAC+           # DIVIDEND IN THE PROCESS.
                TCF     +2
                TCF     MPAC-
                CCS     MPAC    +1
                TCF     MPAC+
                TCF     DANZIG          # EXIT IMMEDIATELY ON ZERO DIVIDEND.
                TCF     MPAC-
                TCF     DANZIG

MPAC-           EXTEND                  # FORCE MPAC POSITIVE AS BUF IN BUF-.
                DCS     MPAC
                DXCH    MPAC
                INCR    DVSIGN          # NOW +1 OR -0.

## Page 1054
MPAC+           CS      MPAC            # CHECK FOR DIVISION OVERFLOW. IF THE
                AD      NEGONE          # MAJOR PART OF THE DIVIDEND IS LESS THAN
                AD      BUF             # THE MAJOR PART OF THE DIVISOR BY AT
                CCS     A               # LEAST TWO, WE CAN PROCEED IMMEDIATELY
                TCF     DVNORM          # WITHOUT NORMALIZATION PRODUCING A DVMAX.
-1/2+2          OCT     60001           # USED IN SQRTSUB.

                TCF     +1              # IF THE ABOVE DOES NOT HOLD, FORCE SIGN
                CAF     HALF            # AGREEMENT IN NUMERATOR AND DENOMINATOR
                DOUBLE                  # TO FACILITATE OVERFLOW AND NEAR-ONE
                AD      MPAC    +1      # CHECKING.
                TS      MPAC    +1
                CAF     ZERO
                AD      POSMAX
                ADS     MPAC

                CAF     HALF            # SAME FOR BUF.
                DOUBLE
                AD      BUF     +1
                TS      BUF     +1
                CAF     ZERO
                AD      POSMAX
                ADS     BUF

                CS      MPAC            # CHECK MAGNITUDE OF SIGN-CORRECTED
                AD      BUF             # OPERANDS.
                CCS     A
                TCF     DVNORM          # DIVIDE OK - WILL NOT BECOME MAXDV CASE.
LBUF2           ADRES   BUF2
                TCF     DVOVF           # DIVISOR NOT LESS THAN DIVIDEND - OVF.

                TS      MAXDVSW         # IF THE MAJOR PARTS OF THE DIVIDEND AND
                CS      MPAC    +1      # DIVISOR ARE EQUAL, A SPECIAL APPROXIMA-
                AD      BUF     +1      # TION IS USED (PROVIDED THE DIVISION IS
                EXTEND                  # POSSIBLE, OF COURSE).
                BZMF    DVOVF
                TCF     DVNORM          # IF NO OVERFLOW.

## Page 1055
BUFNORM         EXTEND                  # ADD -1 TO AUGMENT SHIFT COUNT AND SHIFT
                AUG     DVNORMCT        # LEFT ONE PLACE.
                EXTEND
                DCA     BUF
                DAS     BUF

DVNORM          CA      BUF             # SEE IF DIVISOR NORMALIZED YET.
                DOUBLE
                OVSK
                TCF     BUFNORM         # NO - SHIFT LEFT ONE AND TRY AGAIN.

                DXCH    MPAC            # CALL DIVIDEND NORMALIZATION SEQUENCE
                INDEX   DVNORMCT        # PRIOR TO DOING THE DIVIDE.
                TC      MAXTEST

                TS      MPAC    +2      # RETURNS WITH DIVISION DONE AND C(A) = 0.
                TCF     DANZIG

BUFPOS          CCS     A
                TCF     BUF+            # TO BUF+ IF BUF IS GREATER THAN +1.

                CS      BUF     +1      # IF BUF IS +1, FORCING SIGN AGREEMENT
                EXTEND                  # MAY CAUSE BUF TO BECOME ZERO.
                BZMF    BUF+            # BRANCH IF SIGNS AGREE.

                CA      HALF            # SIGNS DISAGREE.  FORCE AGREEMENT.
 +6             DOUBLE
                ADS     BUF     +1
                CA      ZERO
                TS      BUF
                TCF     BUFZERO


BUFNEG          CCS     A
                TCF     BUF-            # TO BUF- IF BUF IS LESS THAN -1.

                CA      BUF     +1      # IF BUF IS -1, FORCING SIGN AGREEMENT
                EXTEND                  # MAY CAUSE BUF TO BECOME ZERO.
                BZMF    BUF-            # BRANCH IF SIGNS AGREE.

                CS      HALF            # SIGNS DISAGREE.  FORCE AGREEMENT.
                TCF     BUFPOS +6

## Page 1056
#          THE FOLLOWING ARE PROLOGUES TO SHIFT THE DIVIDEND ARRIVING IN A AND L BEFORE THE DIVIDE.

 -21D           LXCH    SR              # SPECIAL PROLOGUE FOR UNIT WHEN THE
                EXTEND                  # LENGTH OF THE ARGUMENT WAS NOT LESS THAN
                MP      HALF            # .5. IN THIS CASE, EACH COMPONENT MUST BE
                XCH     L               # SHIFTED RIGHT ONE TO PRODUCE A HALF-UNIT
                AD      SR              # VECTOR.
                XCH     L
                TCF     GENDDV  +1      # WITH DP DIVIDEND IN A,L.

                DDOUBL                  # PROLOGUE WHICH NORMALIZES THE DIVIDEND
                DDOUBL                  # WHEN IT IS KNOWN THAT NO DIVISION
                DDOUBL                  # OVERFLOW WILL OCCUR.
                DDOUBL
                DDOUBL
                DDOUBL
                DDOUBL
                DDOUBL
                DDOUBL
                DDOUBL
                DDOUBL
                DDOUBL
                DDOUBL
                DXCH    MPAC

MAXTEST         CCS     MAXDVSW         # 0 IF MAJORS MIGHT BE =, -1 OTHERWISE.
BIASHI          DEC     .4192   B-1     # SQRT CONSTANTS

                TCF     MAXDV           # CHECK TO SEE IF THEY ARE NOW EQUAL.

## Page 1057
#          THE FOLLOWING IS A GENERAL PURPOSE DOUBLE PRECISION DIVISION ROUTINE. IT DIVIDES MPAC BY BUF AND LEAVES
# THE RESULT IN MPAC. THE FOLLOWING CONDITIONS MUST BE SATISFIED:

#          1.  THE DIVISOR (BUF) MUST BE POSITIVE AND NOT LESS THAN .5.

#          2.  THE DIVIDEND (MPAC) MUST BE POSITIVE WITH THE MAJOR PART OF MPAC STRICTLY LESS THAN THAT OF BUF
# (A SPECIAL APPROXIMATION, MAXDV, IS USED WHEN THE MAJOR PARTS ARE EQUAL).

#          UNDERSTANDING THAT A/B = Q + S(R/B) WHERE S = 2(-14) AND Q AND R ARE QUOTIENT AND REMAINDER, RESPEC-
# TIVELY, THE FOLLOWING APPROXIMATION IS OBTAINED BY MULTIPLYING ABOVE AND BELOW BY C - SD AND NEGLECTING TERMS OF
# ORDER S-SQUARED (POSSIBLY INTRODUCING ERROR INTO THE LOW TWO BITS OF THE RESULT). SIGN AGREEMENT IS UNNECESSARY.

#          A + SB .      (R - QD)                                             A + SB
#          ------ = Q + S(------) WHERE Q AND R ARE QUOTIENT AND REMAINDER OF ------ RESPECTIVELY.
#          C + SD        (  C   )                                                C


GENDDV          DXCH    MPAC            # WE NEED A AND B ONLY FOR FIRST DV.
 +1             EXTEND                  # (SPECIAL UNIT PROLOGUE ENTERS HERE).
                DV      BUF             # A NOW CONTAINS Q AND L, R.
                DXCH    MPAC

                CS      MPAC            # FORM DIVIDEND FOR MINOR PART OF RESULT.
                EXTEND
                MP      BUF     +1
                AD      MPAC    +1      # OVERFLOW AT THIS POINT IS POSITIVE SINCE
                OVSK                    # R IS POSITIVE IN EVERY CASE.
                TCF     +5

                EXTEND                  # OVERFLOW CAN BE REMOVED BY SUBTRACTING C
                SU      BUF             # (BUF) ONCE SINCE R IS ALWAYS LESS THAN C
                INCR    MPAC            # IN THIS CASE. INCR COMPENSATES SUBTRACT.
                TCF     +DOWN           # (SINCE C(A) IS STILL POSITIVE).

 +5             EXTEND                  # C(A) CAN BE MADE LESS THAN C IN MAGNI-
                BZMF    -UP             # TUDE BY DIMINISHING IT BY C (SINCE C IS
                                        # NOT LESS THAN .5) UNLESS C(A) = 0.

## Page 1058
+DOWN           EXTEND
                SU      BUF             # IF POSITIVE, REDUCE ONLY IF NECESSARY
                EXTEND                  # SINCE THE COMPENSATING INCR MIGHT CAUSE
                BZF     +3              # OVERFLOW.
                EXTEND                  # DONT SUBTRACT UNLESS RESULT IS POSITIVE
                BZMF    ENDMAXDV        # OR ZERO.

 +3             INCR    MPAC            # KEEP SUBTRACT HERE AND COMPENSATE.
                TCF     FINALDV

-UP             EXTEND                  # IF ZERO, SET MINOR PART OF RESULT TO
                BZF     FINALDV +3      # ZERO.

                EXTEND                  # IF NEGATIVE, ADD C TO A, SUBTRACTING ONE
                DIM     MPAC            # TO COMPENSATE. DIM IS OK HERE SINCE THE
ENDMAXDV        AD      BUF             # MAJOR PART NEVER GOES NEGATIVE.

## Page 1059
FINALDV         ZL                      # DO DV TO OBTAIN MINOR PART OF RESULT.
                EXTEND
                DV      BUF
 +3             TS      MPAC    +1

                CCS     DVSIGN          # LEAVE RESULT POSITIVE UNLESS C(DVSIGN)=
                TC      Q               # -0.
                TC      Q
                TC      Q

                EXTEND
                DCS     MPAC
                DXCH    MPAC
                CAF     ZERO            # SO WE ALWAYS RETURN WITH C(A) = 0.
                TC      Q

## Page 1060
#          IF THE MAJOR PARTS OF THE DIVISOR AND DIVIDEND ARE EQUAL, BUT THE MINOR PARTS ARE SUCH THAT THE
# DIVIDEND IS STRICTLY LESS THAN THE DIVISOR IN MAGNITUDE, THE FOLLOWING APPROXIMATION IS USED. THE ASSUMPTIONS
# ARE THE SAME AS THE GENERAL ROUTINE WITH THE ADDITION THAT SIGN AGREEMENT IS NECESSARY (B, C, & D POSITIVE).

#                 C + SB .          (C + B - D)
#                 ------ = 37777 + S(---------)
#                 C + SD            (    C    )

#          THE DIVISION MAY BE PERFORMED IMMEDIATELY SINCE B IS STRICTLY LESS THAN D AND C IS NOT LESS THAN .5.


MAXDV           CS      MPAC            # SEE IF MAXDV CASE STILL HOLDS AFTER
                AD      BUF             # NORMALIZATION.
                EXTEND
                BZF     +2
                TCF     GENDDV          # MPAC NOW LESS THAN BUF - DIVIDE AS USUAL

 +2             CAF     POSMAX          # SET MAJOR PART OF RESULT.
                TS      MPAC

                CS      BUF     +1      # FORM DIVIDEND OF MINOR PART OF RESULT.
                AD      MPAC    +1
                TCF     ENDMAXDV        # GO ADD C AND DO DIVIDE, ATTACHING SIGN
                                        # BEFORE EXITING.

## Page 1061
#          VECTOR DIVIDED BY SCALAR, V/SC, IS EXECUTED HERE. THE VECTOR IS NOW IN MPAC WITH SCALAR IN BUF.

V/SC2           CS      ONE             # INITIALIZE DIVIDEND NORMALIZATION COUNT
                TS      DVNORMCT        # AND DIVISION SIGN REGISTER.
                TS      VBUF    +5

                TC      VECAGREE        # FORCE SIGN AGREEMENT IN VECTOR

                DXCH    BUF
                TC      ALSIGNAG        # SIGN AGREE BUF
                DXCH    BUF
                CCS     BUF             # FORCE DIVISOR POSITIVE WITH MAJOR PART
                TCF     /BUF+           # NON-ZERO (IF POSSIBLE).
                TCF     +2
                TCF     /BUF-

                XCH     BUF     +1      # SHIFT VECTOR AND SCALAR LEFT 14.
                XCH     BUF
                XCH     MPAC    +1
                XCH     MPAC
                EXTEND                  # CHECK FOR OVERFLOW IN EACH CASE.
                BZF     +2
                TCF     DVOVF

                XCH     MPAC    +4
                XCH     MPAC    +3
                EXTEND
                BZF     +2
                TCF     DVOVF

                XCH     MPAC    +6
                XCH     MPAC    +5
                EXTEND
                BZF     +2
                TCF     DVOVF

                CCS     BUF
                TCF     /BUF+
                TCF     DVOVF           # ZERO DIVISOR - OVERFLOW.
                TCF     /BUF-
                TCF     DVOVF

/BUF-           EXTEND                  # ON NEGATIVE, COMPLEMENT BUF AND MAINTAIN
                DCS     BUF             # DVSIGN IN VBUF +5.
                DXCH    BUF
                INCR    VBUF    +5

## Page 1062
/BUF+           EXTEND
                DCA     BUF             # LEAVE ABS(ORIG DIVISOR) IN BUF2
                DXCH    BUF2            # FOR OVERFLOW TESTING
                TCF     /NORM           # NORMALIZE DIVISOR IN BUF.

/NORM2          EXTEND                  # IF LESS THAN .5, AUGMENT DVNORMCT AND
                AUG     DVNORMCT        # DOUBLE DIVISOR.
                EXTEND
                DCA     BUF
                DAS     BUF

/NORM           CA      BUF             # SEE IF DIVISOR NORMALIZED.
                DOUBLE
                OVSK
                TCF     /NORM2          # DOUBLE AND TRY AGAIN IF NOT.

                TC      V/SCDV          # DO X COMPONENT DIVIDE.
                DXCH    MPAC    +3      # SUPPLY ARGUMENTS IN USUAL SEQUENCE.
                DXCH    MPAC
                DXCH    MPAC    +3

                TC      V/SCDV          # Y COMPONENT.
                DXCH    MPAC    +5
                DXCH    MPAC
                DXCH    MPAC    +5

                TC      V/SCDV          # Z COMPONENT.
                TCF     VROTATEX        # GO RE-ARRANGE COMPONENTS BEFORE EXIT.

## Page 1063
#          SUBROUTINE USED BY V/SC TO DIVIDE VECTOR COMPONENT IN MPAC,+1 BY THE SCALAR GIVEN IN BUF.

V/SCDV          CA      VBUF    +5      # REFLECTS SIGN OF SCALAR.
                TS      DVSIGN

                CCS     MPAC            # FORCE MPAC POSITIVE, EXITING ON ZERO.
                TCF     /MPAC+
                TCF     +2
                TCF     /MPAC-

                CCS     MPAC    +1
                TCF     /MPAC+
                TC      Q
                TCF     /MPAC-
                TC      Q

/MPAC-          EXTEND                  # USUAL COMPLEMENTING AND SETTING OF SIGN.
                DCS     MPAC
                DXCH    MPAC
                INCR    DVSIGN

/MPAC+          CS      ONE             # INITIALIZE NEAR-ONE SWITCH.
                TS      MAXDVSW

                CS      MPAC            # CHECK POSSIBLE OVERFLOW.
                AD      BUF2            # UNNORMALIZED INPUT DIVISOR.
                CCS     A
                TCF     DDVCALL         # NOT NEAR-ONE
                TCF     +2              # +0 IS JUST POSSIBLE
                TCF     DVOVF           # NO HOPE
                TS      MAXDVSW         # SIGNAL POSSIBLE NEAR-ONE CASE
                CS      MPAC    +1      # SEE IF DIVISION CAN BE DONE
                AD      BUF2    +1
                EXTEND
                BZMF    DVOVF

DDVCALL         DXCH    MPAC            # CALL PRE-DIVIDE NORMALIZATION.
                INDEX   DVNORMCT
                TCF     MAXTEST

## Page 1064
SLOPELO         DEC     .8324

VECAGREE        XCH     Q               # SAVE Q IN A
                DXCH    MPAC
                TC      ALSIGNAG        # SIGNAGREE MPAC
                DXCH    MPAC
                DXCH    MPAC    +3
                TC      ALSIGNAG        # SIGN AGREE MPAC +3
                DXCH    MPAC    +3
                DXCH    MPAC    +5
                TC      ALSIGNAG        # SIGNAGREE MPAC +5
                DXCH    MPAC    +5
                TC      A

## Page 1065
#          THE FOLLOWING ROUTINE EXECUTES THE UNIT INSTRUCTION, WHICH TAKES THE UNIT OF THE VECTOR IN MPAC.

UNIT            TC      VECAGREE        # FORCE SIGN AGREEMENT IN VECTOR
                TC      MPACVBUF        # SAVE ARGUMENT IN VBUF
                CAF     ZERO            # MUST SENSE OVERFLOW IN FOLLOWING DOT.
                XCH     OVFIND
                TS      TEM1
                TC      VSQSUB          # DOT MPAC WITH ITSELF.
                CA      TEM1
                XCH     OVFIND
                EXTEND
                BZF     +2
                TCF     DVOVF
                EXTEND
                DCA     MPAC            # LEAVE THE SQUARE OF THE LENGTH OF THE
                INDEX   FIXLOC          # ARGUMENT IN LVSQUARE.
                DXCH    LVSQUARE

                TC      SQRTSUB         # GO TAKE THE NORMALIZED SQUARE ROOT.

                CCS     MPAC            # CHECK FOR UNIT OVERFLOW.
                TCF     +5              # MPAC IS NOT LESS THAN .5 UNLESS
                TS      L
                INDEX   FIXLOC
                DXCH    LV
                TCF     DVOVF           # INPUT TO SQRTSUB WAS 0.

                CS      FOURTEEN        # SEE IF THE INPUT WAS SO SMALL THE THE
                AD      MPTEMP          # FIRST TWO REGISTERS OF THE SQUARE WERE 0
                CCS     A
                COM                     # IF SO, SAVE THE NEGATIVE OF THE SHIFT
                TCF     SMALL           # COUNT -15D.

                TCF     LARGE           # (THIS IS USUALLY THE CASE.)

                CS      THIRTEEN        # IF THE SHIFT COUNT WAS EXACTLY 14, SET
                TS      MPTEMP          # THE PRE-DIVIDE NORM COUNT TO -13D.

                CA      MPAC            # SHIFT THE LENGTH RIGHT 14 BEFORE STORING
SMALL2          TS      L               # (SMALL EXITS TO THIS POINT).
                CAF     ZERO
                TCF     LARGE2          # GO TO STORE LENGTH AND PROCEED.

LARGE           CCS     MPTEMP          # MOST ALL CASES COME HERE.
                TCF     LARGE3          # SEE IF NO NORMALIZATION WAS REQUIRED BY
                
                CS      SRDDV           # SQRT, AND IF SO, SET UP FOR A SHIFT
                TS      MPTEMP          # RIGHT 1 BEFORE DIVIDING TO PRODUCE
                EXTEND                  # THE DESIRED HALF UNIT VECTOR.
                DCA     MPAC
## Page 1066
                TCF     LARGE2

## Page 1067
LARGE3          COM                     # LEAVE NEGATIVE OF SHIFT COUNT-1 FOR
                TS      MPTEMP          # PREDIVIDE LEFT SHIFT.

                COM                     # PICK UP REQUIRED SHIFTING BIT TO UNNORM-
                INDEX   A               # ALIZE THE SQRT RESULT.
                CAF     BIT14
                TS      BUF
                EXTEND
                MP      MPAC    +1
                XCH     BUF
                EXTEND                  # (UNNORMALIZE THE SQRT FOR LV).
                MP      MPAC
                XCH     L
                AD      BUF
                XCH     L

LARGE2          INDEX   FIXLOC
                DXCH    LV              # LENGTH NOW STORED IN WORK AREA.

                CS      ONE
                TS      MAXDVSW         # NO MAXDV CASES IN UNIT.

                DXCH    VBUF            # PREPARE X COMPONENT FOR DIVIDE, SETTING
                DXCH    MPAC            # LENGTH OF VECTOR AS DIVISOR IN BUF.
                DXCH    BUF
                TC      UNITDV

                DXCH    VBUF    +2      # DO Y AND Z IN USUAL FASHION SO WE CAN
                DXCH    MPAC            # EXIT THROUGH VROTATEX.
                DXCH    MPAC    +3
                TC      UNITDV

                DXCH    VBUF    +4
                DXCH    MPAC
                DXCH    MPAC    +5
                TC      UNITDV
                TCF     VROTATEX        # AND EXIT.

## Page 1068
#          IF THE LENGTH OF THE ARGUMENT VECTOR WAS LESS THAN 2(-28), EACH COMPONENT MUST BE SHIFTED LEFT AT LEAST
# 14 PLACES BEFORE THE DIVIDE. NOTE THAT IN THIS CASE, THE MAJOR PART OF EACH COMPONENT IS ZERO.

SMALL           TS      MPTEMP          # NEGATIVE OF PRE-DIVIDE SHIFT COUNT.

                CAF     ZERO            # SHIFT EACH COMPONENT LEFT 14.
                XCH     VBUF    +1
                XCH     VBUF
                XCH     VBUF    +3
                XCH     VBUF    +2
                XCH     VBUF    +5
                XCH     VBUF    +4

                CS      MPTEMP
                INDEX   A
                CAF     BIT14
                EXTEND
                MP      MPAC
                TCF     SMALL2

THIRTEEN        =       OCT15
FOURTEEN        =       OCT16
OCT16           =       R1D1

## Page 1069
#          THE FOLLOWING ROUTINE SETS UP THE CALL TO THE DIVIDE ROUTINES.

UNITDV          CCS     MPAC            # FORCE MPAC POSITIVE IF POSSIBLE, SETTING
                TCF     UMPAC+          # DVSIGN ACCORDING TO THE SIGN OF MPAC
                TCF     +2              # SINCE THE DIVISOR IS ALWAYS POSITIVE
                TCF     UMPAC-          # HERE.

                CCS     MPAC    +1
                TCF     UMPAC+
                TC      Q               # EXIT IMMEDIATELY ON ZERO.
                TCF     UMPAC-
                TC      Q

UMPAC-          CS      ZERO            # IF NEGATIVE, SET -0 IN DVSIGN FOR FINAL
                TS      DVSIGN          # COMPLEMENT.
                EXTEND
                DCS     MPAC            # PICK UP ABSOLUTE VALUE OF ARG AND JUMP.
                INDEX   MPTEMP
                TCF     MAXTEST -1

UMPAC+          TS      DVSIGN          # SET DVSIGN FOR POSITIVE QUOTIENT.
                DXCH    MPAC
                INDEX   MPTEMP
                TCF     MAXTEST -1

## Page 1070
#          MISCELLANEOUS UNARY OPERATIONS.

DSQ             TC      DSQSUB          # SQUARE THE DP CONTENTS OF MPAC.
                TCF     DANZIG

ABVALABS        CCS     MODE            # ABVAL OR ABS INSTRUCTION.
                TCF     ABS             # DO ABS ON SCALAR.
                TCF     ABS

ABVAL           TC      VSQSUB          # DOT MPAC WITH ITSELF.
                LXCH    MODE            # MODE IS NOW DP (L ZERO AFTER DAS).

                EXTEND                  # STORE SQUARE OF LENGTH IN WORK AREA.
                DCA     MPAC
                INDEX   FIXLOC
                DXCH    LVSQUARE

## Page 1071
# PROGRAM DESCRIPTION- SUBROUTINE SQRT
# FUNCTIONAL DESCRIPTION-DOUBLE PRECISION SQUARE ROOT ROUTINE
#     THIS PROGRAM TAKES THE SQUARE ROOT OF THE 27 OR 28 MOST SIGNIFICANT BITS IN THE TRIPLE PRECISION SET OF
#     NUMBERS-MPAC,MPAC+1,AND MPAC+2.  THE ROOT IS RETURNED DOUBLE        PRECISION IN MPAC AND MPAC+1.
# WARNING- THIS SUBROUTINE USES A TRIPLE PRECISION INPUT. THE PROGRAMMER  MUST ASSURE THE CONTENTS OF MPAC+2
#     ESPECIALLY IF THE CONTENTS OF MPAC IS SMALL OR ZERO.  FOR DETAILS SEE STG MEMO NO.949.
# CALLING SEQUENCE- IN INTERPRETIVE MODE I.E., FOLLOWING TC  INTPRET,SQRT   NO ADDRESS IS ALLOWED
# INPUT SCALING  THE BINARY POINT IS ASSUMED TO THE RIGHT OF BIT 15. THE  ANSWER IS RETURNED WITH THE SAME SCALING
# SUBROUTINES- GENSCR,MPACSHR, SQRTSUB,ABORT
# ABORT EXIT MODE- ABORTS ON NEGATIVE INPUT -1.2X10E-4 (77775  OCTAL)     OR LESS.
#     DISPLAYS ERROR CODE 1302
#                 TC   ABORT
#                 OCT  1302
# DEBRIS -  LOCATIONS BUF,MPTEMP,ADDRWD ARE USED
SQRT            TC      SQRTSUB         # TAKE THE SQUARE ROOT OF MPAC.
                CCS     MPTEMP          # RETURNED NORMALIZED SQUARE ROOT. SEE IF
                TCF     +2              # ANY UN-NORMALIZATION REQUIRED AND EXIT
                TCF     DANZIG          # IF NOT.

                AD      NEG12           # A RIGHT SHIFT OF MORE THAN 13 COULD BE
                EXTEND                  # REQUIRED IF INPUT WAS ZERO IN MPAC,+1.
                BZMF    SQRTSHFT        # GOES HERE IN MOST CASES.
                ZL                      # IF A LONG SHIFT IS REQUIRED, GO TO
                LXCH    ADDRWD          # GENERAL RIGHT SHIFT ROUTINES.
                TCF     GENSCR  +4      # ADDRWD WAS ZERO TO PREVENT ROUND.

SQRTSHFT        INDEX   MPTEMP          # SELECT SHIFTING BIT AND EXIT THROUGH
                CAF     BIT15           # SHIFT ROUTINES.
                TS      MPTEMP
                CAF     ZERO            # TO ZERO MPAC +2 IN THE PROCESS.
                TCF     MPACSHR +3

ABS             TC      BRANCH          # TEST SIGN OF MPAC AND COMPLEMENT IF
                TCF     DANZIG
                TCF     DANZIG
                TCF     COMP

## Page 1072
VDEF            CS      FOUR            # VECTOR DEFINE - ESSENTIALLY TREATS
                ADS     PUSHLOC         # SCALAR IN MPAC AS X COMPONENT, PUSHES UP
                EXTEND                  # FOR Y AND THEN AGAIN FOR Z.
                INDEX   A
                DCA     2
                DXCH    MPAC    +3
                EXTEND
                INDEX   PUSHLOC
                DCA     0
                DXCH    MPAC    +5
                TCF     VMODE           # MODE IS NON VECTOR.

VSQ             TC      VSQSUB          # DOT MPAC WITH ITSELF.
                TCF     DMODE           # MODE IS NOW DP.

PUSH            EXTEND                  # PUSH DOWN MPAC LEAVING IT LOADED.
                DCA     MPAC
                INDEX   PUSHLOC         # PUSH DOWN FIRST TWO REGISTERS IN EACH
                DXCH    0

                INDEX   MODE            # INCREMENT PUSHDOWN POINTER.
                CAF     NO.WDS
                ADS     PUSHLOC

                CCS     MODE
                TCF     TPUSH           # PUSH DOWN MPAC +2.
                TCF     DANZIG          # DONE FOR DP.

                EXTEND                  # ON VECTOR, PUSH DOWN Y AND Z COMPONENTS.
                DCA     MPAC    +3
                INDEX   PUSHLOC
                DXCH    0       -4
                EXTEND
                DCA     MPAC    +5
                INDEX   PUSHLOC
                DXCH    0       -2
                TCF     DANZIG

TPUSH           CA      MPAC    +2
                TCF     ENDTPUSH +2

RVQ             INDEX   FIXLOC          # RVQ - RETURN IVA QPRET.
                CA      QPRET
                TS      POLISH
                TCF     GOTO    +4      # (ASSUME QPRET POINTS TO FIXED ONLY.)

## Page 1073
#          THE FOLLOWING SUBROUTINES ARE USED IN SQUARING MPAC, IN BOTH THE SCALAR AND VECTOR SENSE. THEY ARE
# SPECIAL CASES OF DMPSUB AND DOTSUB, PUT IN TO SAVE SOME TIME.

DSQSUB          CA      MPAC    +1      # SQUARES THE SCALAR CONTENTS OF MPAC.
                EXTEND
                SQUARE
                TS      MPAC    +2
                CAF     ZERO            # FORM 2(CROSS TERM).
                XCH     MPAC    +1
                EXTEND
                MP      MPAC
                DDOUBL                  # AND MAYBE OVERFLOW.
                DAS     MPAC    +1      # AND SET A TO NET OVERFLOW.
                XCH     MPAC
                EXTEND
                SQUARE
                DAS     MPAC
                TC      Q

VSQSUB          EXTEND                  # DOTS THE VECTOR IN MPAC WITH ITSELF.
                QXCH    DOTRET
                TC      DSQSUB          # SQUARE THE X COMPONENT.
                DXCH    MPAC    +3
                DXCH    MPAC
                DXCH    BUF             # SO WE CAN END IN DOTSUB.
                CA      MPAC    +2
                TS      BUF     +2

                TC      DSQSUB          # SQUARE Y COMPONENT.
                DXCH    MPAC    +1
                DAS     BUF     +1
                AD      MPAC
                AD      BUF
                TS      BUF
                TCF     +2
                TS      OVFIND          # IF OVERFLOW.

                DXCH    MPAC    +5
                DXCH    MPAC
                TC      DSQSUB          # SQUARE Z COMPONENT.
                TCF     ENDDOT          # END AS IN DOTSUB.

## Page 1074
#          DOUBLE PRECISION SQUARE ROOT ROUTINE. TAKE THE SQUARE ROOT OF THE TRIPLE PRECISION (MPAC +2 USED ONLY
# IN NORMALIZATION) CONTENTS OF MPAC AND LEAVE THE NORMALIZED RESULT IN MPAC (C(MPAC) GREATER THAN OR EQUAL TO
# .5). THE RIGHT SHIFT COUNT (TO UNNORMALIZE) IS LEFT IN MPTEMP.


SQRTSUB         CAF     ZERO            # START BY ZEROING RIGHT SHIFT COUNT.
                TS      MPTEMP

                CCS     MPAC            # CHECK FOR POSITIVE ARGUMENT, SHIFTING
                TCF     SMPAC+          # FIRST SIGNIFICANT MPAC REGISTER INTO
                TCF     +2              # MPAC ITSELF.
                TCF     SQRTNEG         # SEE IF MAG OF ARGUMENT LESS THAN 10(-4).

                XCH     MPAC    +2      # MPAC IS ZERO - SHIFT LEFT 14.
                XCH     MPAC    +1
                TS      MPAC
                CAF     SEVEN           # AUGMENT RIGHT SHIFT COUNTER.
                TS      MPTEMP

                CCS     MPAC            # SEE IF MPAC NOW PNZ.
                TCF     SMPAC+
                TCF     +2
                TCF     ZEROANS         # NEGATIVE BUT LESS THAN 10(-4) IN MAG.

                XCH     MPAC    +1      # ZERO - SHIFT LEFT 14 AGAIN.
                TS      MPAC
                CAF     SEVEN           # AUGMENT RIGHT SHIFT COUNTER.
                ADS     MPTEMP

                CCS     MPAC
                TCF     SMPAC+
                TC      Q               # SQRT(0) = 0.
                TCF     ZEROANS
                TCF     FIXROOT         # DO NOT LEAVE SQRTSUB WITH -0 IN MPAC.


SQRTNEG         CCS     A               # ARGUMENT IS NEGATIVE, BUT SEE IF SIGN-
                TCF     SQRTABRT        # CORRECTED ARGUMENT IS LESS THAN 10(-4)

                CCS     MPAC    +1      # IN MAGNITUDE. IF SO, CALL ANSWER ZERO.
ZEROANS         CAF     ZERO            # FORCE ANSWER TO ZERO HERE.
                TCF     FIXROOT
                TCF     SQRTABRT
                TCF     FIXROOT

SQRTABRT        DXCH    LOC
                TC      POODOO1
                OCT     1302

## Page 1075
SMPAC+          AD      -1/2+2          # SEE IF ARGUMENT GREATER THAN OR EQUAL TO
                EXTEND                  # .5.
                BZMF    SRTEST          # IF SO, SEE IF LESS THAN .25.

                DXCH    MPAC            # WE WILL TAKE THE SQUARE ROOT OF MPAC/2.
                LXCH    SR              # SHIFT RIGHT 1 AND GO TO THE SQRT ROUTINE
                EXTEND
                MP      HALF
                DXCH    MPAC
                XCH     SR
                ADS     MPAC    +1      # GUARANTEED NO OVERFLOW.

ARGHI           CAF     SLOPEHI         # ARGUMENT BETWEEN .25 AND .5. GET A
                EXTEND                  # LINEAR APPROXIMATION FOR THIS RANGE.
                MP      MPAC
                AD      BIASHI          # X0/2 = (MPAC/2)(SLOPEHI) + BIASHI/2.

 +4             TS      BUF             # X0/2 (ARGLO ENTERS HERE).
                CA      MPAC            # SINGLE-PRECISION THROUGHOUT.
                ZL
                EXTEND
                DV      BUF             # (MPAC/2)/(X0/2)
                EXTEND
                MP      HALF
                ADS     BUF             # X1 = X0/2 + .5(MPAC/2)/(X0/2).

                EXTEND
                MP      HALF            # FORM UP X1/2.
                DXCH    MPAC            # SAVE AND BRING OUT ARGUMENT.
                EXTEND                  # TAKE DP QUOTIENT WITH X1.
                DV      BUF
                TS      BUF     +1      # SAVE MAJOR PART OF QUOTIENT.
                CAF     ZERO            # FORM MINOR PART OF QUOTIENT USING
                XCH     L               # (REMAINDER,0).
                EXTEND
                DV      BUF
                TS      L               # IN PREPARATION FOR DAS.
                CA      BUF     +1
                DAS     MPAC            # X2 = X1/2 + (MPAC/2)X1

                EXTEND                  # OVERFLOWS IF ARG. NEAR POSMAX.
                BZF     TCQBNK00
                CAF     POSMAX
FIXROOT         TS      MPAC
                TS      MPAC    +1
TCQBNK00        TC      Q               # RETURN TO CALLER TO UNNORMALIZE, ETC.

## Page 1076
SRTEST          AD      QUARTER         # ARGUMENT WAS LESS THAN .5, SEE IF LESS
                EXTEND                  # THAN .25.
                BZMF    SQRTNORM        # IF SO, BEGIN NORMALIZATION.

                DXCH    MPAC            # IF BETWEEN .5 AND .25, SHIFT RIGHT 1 AND
                LXCH    SR              # START AT ARGLO.
                EXTEND
                MP      HALF
                DXCH    MPAC
                XCH     SR
                ADS     MPAC    +1      # NO OVERFLOW.

ARGLO           CAF     SLOPELO         # (NORMALIZED) ARGUMENT BETWEEN .125 AND
                EXTEND                  # .25
                MP      MPAC
                AD      BIASLO
                TCF     ARGHI   +4      # BEGIN SQUARE ROOT.

SQRTNM2         EXTEND                  # SHIFT LEFT 2 AND INCREMENT RIGHT SHIFT
                DCA     MPAC    +1      # COUNT (FOR TERMINAL UNNORMALIZATION).
                DAS     MPAC    +1
                AD      MPAC
                ADS     MPAC            # (NO OVERFLOW).

SQRTNORM        INCR    MPTEMP          # FIRST TIME THROUGH, JUST SHIFT LEFT 1
                EXTEND                  # (PUTS IN EFFECTIVE RIGHT SHIFT SINCE
                DCA     MPAC    +1      # WE WANT MPAC/2).
                DAS     MPAC    +1
                AD      MPAC
                ADS     MPAC            # (AGAIN NO OVERFLOW).
                DOUBLE
                TS      CYL

NORMTEST        CCS     CYL             # SEE IF ARGUMENT NOW NORMALIZED AT
                CCS     CYL             # GREATER THAN .125.
                TCF     SQRTNM2         # NO - SHIFT LEFT 2 MORE AND TRY AGAIN.
                TCF     ARGHI           # YES - NOW BETWEEN .5 AND .25.
                TCF     ARGLO           # ARGUMENT NOW BETWEEN .25 AND .125.

## Page 1077
# TRIGONOMETRIC FUNCTION PACKAGE.

#          THE FOLLOWING TRIGONOMETRIC FUNCTIONS ARE AVAILABLE AS INTERPRETIVE OPERATIONS:

#          1.  SIN                COMPUTES (1/2)SINE(2 PI MPAC).
#          2.  COS                COMPUTES (1/2)COSINE(2 PI MPAC).

#          3.  ASIN               COMPUTES (1/2PI)ARCSINE(2 MPAC).
#          4.  ACOS               COMPUTES (1/2PI)ARCCOSINE(2 MPAC).

# SIN-ASIN AND COS-ACOS ARE MUTUALLY INVERSE, IE SIN(ASIN(X)) = X.


COSINE          TC      BRANCH          # FINDS COSINE USING THE IDENTITY
                TCF     +3              # COS(X) = SIN(PI/2 - ABS(X)).
                TCF     PRESINE
                TCF     PRESINE

 +3             EXTEND
                DCS     MPAC
                DXCH    MPAC

PRESINE         CAF     QUARTER         # PI/2 SCALED.
                ADS     MPAC


SINE            DXCH    MPAC            # DOUBLE ARGUMENT.
                DDOUBL
                OVSK                    # SEE IF OVERFLOW PRESENT.
                TCF     +3              # IF NOT, ARGUMENT OK AS IS.

                EXTEND                  # IF SO, WE LOST (OR GAINED) PI, SO
                DCOM                    # COMPLEMENT MPAC USING THE IDENTITY
                                        # SIN(X-(+)PI) = SIN(-X).
 +3             DXCH    MPAC
                CA      MPAC            # SEE IF ARGUMENT GREATER THAN .5 IN
                DOUBLE                  # MAGNITUDE. IF SO, REDUCE IT TO LESS THAN
                TS      L               # .5 (+-PI/2 SCALED) AS FOLLOWS:
                TCF     SN1

                INDEX   A               # IF POSITIVE, FORM PI - X, IF NEGATIVE
                CAF     NEG1/2 +1       # USE -PI - X.
                DOUBLE
                EXTEND
                SU      MPAC            # GUARANTEED NO OVERFLOW.
                TS      MPAC
                CS      MPAC    +1
                TS      MPAC    +1

## Page 1078
SN1             EXTEND                  # SET UP TO EVALUATE HASTINGS POLYNOMIAL
                DCA     MPAC
                DXCH    BUF2
                TC      DSQSUB          # SQUARE MPAC.

                TC      POLY            # EVALUATE FOURTH ORDER POLYNOMIAL.
                DEC     3
                2DEC    +.3926990796
                
                2DEC    -.6459637111
                
                2DEC    +.318758717
                
                2DEC    -.074780249
                
                2DEC    +.009694988

                CAF     LBUF2           # MULTIPLY BY ARGUMENT AND SHIFT LEFT 2.
                TC      DMPSUB  -1

                EXTEND
                DCA     MPAC    +1
                DAS     MPAC    +1
                AD      MPAC
                ADS     MPAC            # NEITHER SHIFT OVERFLOWS.
                EXTEND
                DCA     MPAC    +1
                DAS     MPAC    +1
                AD      MPAC
                ADS     MPAC
                TCF     DANZIG

## Page 1079
#          ARCSIN/ARCCOS ROUTINE.

ARCSIN          CAF     LASINEX         # COMPUTE ARCSIN BY USING THE IDENTITY
                TCF     +2              # ARCSIN(X) = PI/2 - ARCCOS(X).

ARCCOS          CAF     LDANZIG         # (EXITS IMMEDIATELY).
                TS      ESCAPE
                TC      BRANCH          # TEST SIGN OF INPUT.
                TCF     ACOSST          # START IMMEDIATELY IF POSITIVE.
                TCF     ACOSZERO        # ARCCOS(0) = PI/2 = .25.
                EXTEND                  # IF NEGATIVE, USE THE IDENTITY
                DCS     MPAC            # ARCCOS(X) = PI - ARCCOS(-X), FORCING
                DXCH    MPAC            # ARGUMENT POSITIVE.
                CAF     TCSUBTR         # SET EXIT  TO DO ABOVE BEFORE
                XCH     ESCAPE          # ARCSIN/ARCCOS CONSIDERATIONS.
                TS      ESCAPE2

ACOSST          CS      HALF            # TEST MAGNITUDE OF INPUT.
                AD      MPAC
                CCS     A
                TCF     ACOSOVF         # THIS IS PROBABLY AN OVERFLOW CASE.

LASINEX         TCF     ASINEX

                TCF     ACOSST2         # NO OVERFLOW - PROCEED.

                CCS     MPAC    +1      # IF MAJOR PART IS .5, CALL ANSWER 0
                CAF     ZERO            # UNLESS MINOR PART NEGATIVE.
                TCF     ACOS=0

                TCF     ACOSST2

ACOS=0          TS      MPAC    +1
                TS      MPAC
                TC      ESCAPE

ACOSST2         EXTEND                  # NOW THAT ARGUMENT IS IN PROPER RANGE,
                DCS     MPAC            # BEGIN COMPUTATION. USE HASTINGS
                AD      HALF            # APPROXIMATION ARCCOS(X) = SQRT(1-X)P(X)
                DXCH    MPAC            # IN A SCALED VERSION WHERE P(X) IS A
                DXCH    BUF2            # SEVENTH ORDER POLYNOMIAL.

                TC      SQRTSUB         # RETURNS WITH NORMALIZED SQUARE ROOT.

                CCS     MPTEMP          # SEE IF UN-NORMALIZATION REQUIRED.
                TCF     ACOSSHR         # IF SO.

## Page 1080
ACOS3           DXCH    MPAC            # SET UP FOR POLYNOMIAL EVALUATION.
                DXCH    BUF2
                DXCH    MPAC

                TC      POLY
                DEC     6
                2DEC    +.353553385     # COEFFICIENTS ARE C 2(+I)/PISQRT(2) WHERE
                
                2DEC*   -.0483017006 B+1* #                 I
                
                2DEC*   +.0200273085 B+2* #    WHERE C STANDS FOR ORIGINAL COEFFS.
                
                2DEC*   -.0112931863 B+3*
                
                2DEC*   +.00695311612 B+4*
                
                2DEC*   -.00384617957 B+5*
                
                2DEC*   +.001501297736 B+6*
                
                2DEC*   -.000284160334 B+7*
                

                CAF     LBUF2           # DO FINAL MULTIPLY AND GO TO ANY
                TC      DMPSUB  -1      # EPILOGUE SEQUENCES.
                TC      ESCAPE

SUBTR           EXTEND                  # EPILOGUE FOR NEGATIVE INPUTS TO ARCCOS.
                DCS     MPAC
                AD      HALF            # FORMS PI - ARCCOS(-X) = ARCCOS(X).
                DXCH    MPAC
                TC      ESCAPE2         # GO TO POSSIBLE ARCSIN EPILOGUE.

ASINEX          EXTEND
                DCS     MPAC            # ARCSIN EPILOGUE - GET ARCSIN(X)
                AD      QUARTER         # = PI/2 - ARCCOS(X).
                DXCH    MPAC
LDANZIG         TCF     DANZIG

## Page 1081
ACOSSHR         INDEX   A               # THE SHIFT RIGHT IS LESS THAN 14 SINCE
                CAF     BIT14           # THE INPUT WAS NON-ZERO DP.
                TS      MPTEMP
                TC      VSHRRND         # DP SHIFT RIGHT AND ROUND.
                TCF     ACOS3           # PROCEED.

ACOSOVF         EXTEND                  # IF MAJOR PART WAS ONLY 1 MORE THAN .5,
                BZF     ACOS=0          # CALL ANSWER ZERO.

ACOSABRT        EXTEND                  # IF OVERFLOW, CALL ANSWER ZERO BUT
                DCA     LOC             # SOUND AN ALARM.
                TC      ALARM1
                OCT     1301

                CAF     ZERO
                TCF     ACOS=0

ACOSZERO        CAF     QUARTER         # ACOS(0) = PI/2.
                TCF     ACOS=0  +1      # SET MPAC AND EXIT VIA ESCAPE.

NEG12           DEC     -12
TCSUBTR         TCF     SUBTR

## Page 1082
#          THE FOLLOWING INSTRUCTIONS ARE AVAILABLE FOR SETTING, MODIFYING, AND BRANCHING ON INDEX REGISTERS:

#          1.  AXT                ADDRESS TO INDEX TRUE.
#          1.  AXC                ADDRESS TO INDEX COMPLEMENTED.
#          3.  LXA                LOAD INDEX FROM ERASABLE.
#          4.  LXC                LOAD INDEX COMPLEMENTED FROM ERASABLE.
#          5.  SXA                STORE INDEX IN ERASABLE.
#          6.  XCHX               EXCHANGE INDEX REIGSTER WITH ERASABLE.

#          7.  INCR               INCREMENT INDEX REGISTER.
#          8.  XAD                ERASABLE ADD TO INDEX REGISTER.
#          9.  XSU                ERASABLE SUBTRACT FROM INDEX REGISTER.

#         10.  TIX                BRANCH ON INDEX REGISTER AND DECREMENT.

                BANK    01

                COUNT*  $$/INTER
AXT             TC      TAGSUB          # SELECT APPROPRIATE INDEX REGISTER.
                CA      POLISH
XSTORE          INDEX   INDEXLOC        # CONTAINS C(FIXLOC) OR C(FIXLOC)+1.
                TS      X1
                TCF     DANZIG

AXC             TC      TAGSUB
                CS      POLISH
                TC      XSTORE

LXA             TC      15ADRERS        # LOAD INDEX REGISTER FROM ERASABLE.
                INDEX   POLISH
                CA      0
                TCF     XSTORE

LXC             TC      15ADRERS        # LOAD NDX REG FROM ERASABLE COMPLEMENTED.
                INDEX   POLISH
                CS      0
                TCF     XSTORE

SXA             TC      15ADRERS        # STORE INDEX REGISTER IN ERASABLE.
                INDEX   INDEXLOC
                CA      X1
MSTORE1         INDEX   POLISH
                TS      0
                TCF     DANZIG

## Page 1083
XCHX            TC      15ADRERS        # EXCHANGE INDEX REGISTER WITH ERASABLE.
                INDEX   POLISH
                CA      0
                INDEX   INDEXLOC
                XCH     X1
                TCF     MSTORE1

XAD             TC      15ADRERS        # ADD ERASABLE TO INDEX REGISTER.
                INDEX   POLISH
                CA      0
XAD2            INDEX   INDEXLOC
                ADS     X1              # IGNORING OVERFLOWS.
                TCF     DANZIG

INCR            TC      TAGSUB          # INCREMENT INDEX REGISTER.
                CA      POLISH
                TCF     XAD2

XSU             TC      15ADRERS        # SUBTRACT ERASABLE FROM INDEX REGISTER.
                INDEX   POLISH
                CS      0
                TCF     XAD2

TIX             TC      TAGSUB          # BRANCH AND DECREMENT ON INDEX.
                INDEX   INDEXLOC
                CS      S1
                INDEX   INDEXLOC
                AD      X1
                EXTEND                  # NO OPERATION IF DECREMENTED INDEX IS
                BZMF    DANZIG          # NEGATIVE OR ZERO.

DOTIXBR         INDEX   INDEXLOC
                XCH     X1              # IGNORING OVERFLOWS.

                TCF     GOTO            # DO THE BRANCH USING THE CADR IN POLISH.

## Page 1084
#          SUBROUTINE TO CONVERT AN ERASABLE ADDRESS (11 BITS) TO AN EBANK SETTING AND SUBADDRESS.

15ADRERS        CS      POLISH
                AD      DEC45
                CCS     A               # DOES THE ADDRESS POINT TO THE WORK AREA?
                CA      FIXLOC          # YES.  ADD FIXLOC.  EBANK OK AS IS.
                TCF     +5

                CA      OCT1400         # NO.  SET EBANK & MAKE UP SUBADDRESS.
                XCH     POLISH
                TS      EBANK
                MASK    LOW8
 +5             ADS     POLISH          # FALL INTO TAGSUB, AND RETURN VIA Q.

#          SUBROUTINE WHICH SETS THE ADDRESS OF THE SPECIFIED INDEX IN INDEXLOC. (ACTUALLY, THE ADDRESS -38D.)

TAGSUB          CA      FIXLOC
                TS      INDEXLOC

                CCS     CYR             # BIT 15 SPECIFIES INDEX.
                INCR    INDEXLOC        # 0 MEANS USE X2.
                TC      Q
                TC      Q               # 1 FOR X1.

## Page 1085
#          MISCELLANEOUS OPERATION CODES WITH DIRECT ADDRESSES. INCLUDED HERE ARE:

#          1.  ITA                STORE QPRET (RETURN ADDRESS) IN ERASABLE.
#          2.  CALL               CALL A SUBROUTINE, LEAVING RETURN IN QPRET.
#          3.  RTB                RETURN TO BASIC LANGUAGE AT THE GIVEN ADDRESS.
#          4.  BHIZ               BRANCH IF THE HIGH ORDER OF MPAC IS ZERO (SINGLE PRECISION).
#          5.  BOV                BRANCH ON OVERFLOW.
#          6.  GOTO               SIMPLE SEQUENCE CHANGE.

RTB/BHIZ        CCS     CYR
RTB             CA      POLISH
                TC      SWCALL  -1      # SO A "TC Q" FROM ROUTINE LEADS TO DANZIG

BHIZ            CCS     MPAC
                TCF     DANZIG
                TCF     GOTO
                TCF     DANZIG
                TCF     GOTO

BOV(B)          CCS     OVFIND          # BRANCH ON OVERFLOW TO BASIC OR INTERP.
                TCF     +2
                TCF     DANZIG
                TS      OVFIND
                CCS     CYR
                TCF     RTB             # IF BASIC.
B5TOBB          OCT     360
                TCF     GOTO

## Page 1086
BZE/GOTO        CCS     CYR             # SEE WHICH OP-CODE IS DESIRED.
                TC      BRANCH          # DO BZE.
                TCF     DANZIG
                TCF     GOTO            # DO GOTO.
                TCF     DANZIG

BPL/BMN         CCS     CYR
                TCF     BPL
5B10            DEC     5 B+10          # SHIFTS OP CODE IN SWITCH INSTRUCTION ADR

                TC      BRANCH          # DO BMN.
                TCF     DANZIG
                TCF     DANZIG
                TCF     GOTO            # ONLY IF NNZ.

BPL             TC      BRANCH
                TCF     GOTO            # IF POSITIVE OR ZERO.
                TCF     GOTO
                TCF     DANZIG

CALL/ITA        CCS     CYR
                TCF     CALL

                TC      CCSHOLE
                TC      15ADRERS        # STORE QPRET. (TAGSUB AFTER 15ADRERS IS
                INDEX   FIXLOC          # SLOW IN THIS CASE, BUT SAVES STORAGE.)
                CA      QPRET
                TCF     MSTORE1

## Page 1087
#          THE FOLLOWING OPERATIONS ARE AVAILABLE FOR ALTERING AND TESTING INTERPRETIVE SWITCHES:

# 00       BONSET                 SET A SWITCH AND DO A GOTO IF IT WAS ON.
# 01       SETGO                  SET A SWITCH AND DO A GOTO.
# 02       BOFSET                 SET A SWITCH AND DOA GOTO IF IT WAS OFF
# 03       SET                    SET A SWITCH.

# 04       BONINV                 INVERT A SWITCH AND BRANCH IF IT WAS ON.
# 05       INVGO                  INVERT A SWITCH AND DO A GOTO.
# 06       BOFINV                 INVERT A SWITCH AND BRANCH IF IT WAS OFF
# 07       INVERT                 INVERT A SWITCH.

# 10       BONCLR                 CLEAR A SWITCH AND BRANCH IF IT WAS ON.
# 11       CLRGO                  CLEAR A SWITCH AND DO A GOTO.
# 12       BOFCLR                 CLEAR A SWITCH AND BRANCH IF IT WAS OFF.
# 13       CLEAR                  CLEAR A SWITCH.

# 14       BON                    BRANCH IF A SWITCH WAS ON.
# 16       BOFF                   BRANCH IF A SWITCH WAS OFF.


#          THE ADDRESS SUPPLIED WITH THE SWITCH INSTRUCTION IS INTERPRETED AS FOLLOWS:

#          BITS 1-4    SWITCH BIT NUMBER (1-15).
#          BITS 5-8    SWITCH OPERATION NUMBER.
#          BITS 9-     SWITCH WORD NUMBER (UP TO 64 SWITCH WORDS).

#          THE ADDRESS ITSELF IS MADE UP BY THE YUL SYSTEM ASSEMBLER. THE BRANCH INSTRUCTIONS REQUIRE TWO
# ADDRESSES, THE SECOND TAKEN AS THE DIRECT (OR INDIRECT IF IN ERASABLE) ADDRESS OF THE BRANCH.


SWITCHES        CAF     LOW4            # LEAVE THE SWITCH BIT IN  SWBIT  .
                MASK    POLISH
                INDEX   A
                CAF     BIT15           # (NUMBER FROM LEFT TO RIGHT.)
                TS      SWBIT

                CAF     BIT7            # LEAVE THE SWITCH NUMBER IN SWWORD.
                EXTEND
                MP      POLISH
                TS      SWWORD

                INHINT                  # DURING SWITCH CHANGE SO RUPT CAN USE TOO
                INDEX   A               # LEAVE THE SWITCH WORD ITSELF IN L.
                CA      STATE
                TS      Q               # Q WILL BE USED AS A CHANNEL.
## Page 1088
                CAF     BIT11
                EXTEND                  # DISPATCH SWITCH BIT OPERATION AS IN BITS
                MP      POLISH          # 7-8 OF POLISH.
                MASK    B3TOB4          # GETS 4X2-BIT CODE.
                INDEX   A
                TCF     +1

 +1             CA      SWBIT           # 00 - SET SWITCH IN QUESTION.
                EXTEND
                ROR     QCHAN
                TCF     SWSTORE

 +5             CA      SWBIT           # 01 - INVERT SWITCH.
                EXTEND
                RXOR    QCHAN
                TCF     SWSTORE

 +9D            CS      SWBIT           # 10 - CLEAR.
                MASK    Q
SWSTORE         INDEX   SWWORD
                TS      STATE           # NEW SWITCH WORD.

## Page 1089
 +13D           RELINT                  # 11 - NOOP.
                CAF     BIT13
                EXTEND                  # DISPATCH SEQUCE CHANGING OR BRANCHING
                MP      POLISH          # CODE.
                MASK    B3TOB4
                INDEX   A
                TCF     +1              # ORIGINALLY STORED IN BITS 5-6.

 +1             CS      Q               # 00 - BRANCH IF ON.
TEST            MASK    SWBIT
                CCS     A
                TCF     SWSKIP

 +5             TCF     SWBRANCH        # 01 - GO TO.

                TCF     SWSKIP          # HERE ONLY ON BIT 15.

                TC      CCSHOLE
                TC      CCSHOLE

 +9D            CA      Q               # 10 - BRANCH IF OFF.
                TCF     TEST

B3TOB4          OCT     0014
SWSKIP          INCR    LOC

SW/             EQUALS  SWITCHES

 +13D           TCF     DANZIG          # 11 - NOOP.
