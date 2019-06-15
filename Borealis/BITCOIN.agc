### FILE="Main.annotation"
## Copyright:   Public domain.
## Filename:    AGC_VERSION_CHECK.agc
## Purpose:     Hack to mine bitcoin.
## Assembler:   yaYUL
## Contact:     Ken Shirriff <ken.shirriff@gmail.com>.
## Website:     www.ibiblio.org/apollo/index.html
## Mod history: 2019-06-13 KWS  Created.

                BANK            25

                EBANK=          MH0
BITCOIN         CAF             MBK
                TS              EBANK

                CAF             N23
H0LOOP          TS              MCNT        # Copy 24 words from H0INIT to MH0
                INDEX           A
                CAF             H0INIT
                INDEX           MCNT
                TS              MH0
                CCS             MCNT
                TC              H0LOOP

                CCS             NEWJOB          # See if any jobs pending sowe
                TC              CHANG1          # don't crash into the Moon

                # Test addition
                CAF             N0
                TS              MS0
                CAF             N1
                TS              MS0 +1
                CAF             NOTTOP
                TS              MS0 +2
                CAF             MS0A
                TC              DISPLAY3

                CAF             N1
                TS              MS1
                TS              MS1 +1
                TS              MS1 +2

                CAF             MS1A
                TC              DISPLAY3

                CAF             MS0A
                TS              MPAC
                CAF             MS1A
                TS              MPAC +1
                TC              ADD

                CAF             MS0A
                TC              DISPLAY3
                
                CAF             N47
INLOOP          TS              MCNT        # Copy 48 words (16 32words) from INPUT to MW
                INDEX           A
                CAF             INPUT
                INDEX           MCNT
                TS              MW
                CCS             MCNT
                TC              INLOOP

                # Display W[0-8]
                CAF             MWA
                TC              DISPLAY8

                # Loop to initialize W 16-63
                CAF             N0
                TS              MCNT         # MCNT = (i-16)*3. I.e. starts at 0 instead of 16, and counts over 3-word values.

INITLOOP        INDEX           MCNT
                CA              MW +3D      # W[i-15] to ROR
                TS              RORBUF
                INDEX           MCNT
                CA              MW +4D
                TS              RORBUF +1
                INDEX           MCNT
                CA              MW +5D
                TS              RORBUF +2
                CA              N7
                TS              RORCNT

                CCS             NEWJOB          # See if any jobs pending
                TC              CHANG1          # Don't crash into the moon

                # Display before rotation
                CA              RORBUFA
                TC              DISPLAY3

                # Rotate
                TC              RORN            # rightrotate 3

                # S0 = W[i-15] rightshift 3. Zero top 3 bits for shift instead of rotate
                CA              N0
                TS              MS0             # Top 2 bits 0
                CA              RORBUF +1
                MASK            NOTTOP          # Remove top bit from next word
                TS              MS0 +1
                CA              RORBUF +2
                TS              MS0 +2

                # Rotate 4 more to get rightrotate 7
                CA              N4
                TS              RORCNT
                TC              RORN            # rightrotate

                # XOR into s0.
                CAF             MS0A
                TS              MPAC
                CAF             RORBUFA
                TS              MPAC +1
                TC              XOR

                # Rotate 11 more to get rightrotate 18
                CA              N11
                TS              RORCNT
                TC              RORN            # rightrotate

                # XOR into s0
                TC              XOR             # MPAC, MPAC+1 still set up

                # Put w[i-2] in ROR
                # Index is MCNT[(16-2)*3] = MCNT[42]
                INDEX           MCNT
                CA              MW +42D
                TS              RORBUF
                INDEX           MCNT
                CA              MW +43D
                TS              RORBUF +1
                INDEX           MCNT
                CA              MW +44D
                TS              RORBUF +2
                CA              N7
                TS              RORCNT

                # Rightrotate 10
                CA              N10
                TS              RORCNT
                TC              RORN            # rightrotate

                # Mask to get rightshift 10 and store in S1
                # Remove 2 bits from first word, top 8 from second word
                CA              N0
                TS              MS1             # Top 2 bits 0
                CA              RORBUF +1
                MASK            N127          # Leave 7 bits in next word
                TS              MS1 +1
                CA              RORBUF +2
                TS              MS1 +2

                # Rightrotate 7 more to get rightrotate 17
                CA              N7
                TS              RORCNT
                TC              RORN            # rightrotate

                # XOR into S1
                CAF             MS1A
                TS              MPAC            # MPAC +1 still RORBUFA
                TC              XOR

                # Rightrotate 2 more to get rightrotate 19
                CA              N2
                TS              RORCNT
                TC              RORN            # rightrotate

                # XOR into S1
                TC              XOR

                # Copy W[i-16] to W[i]. I.e. MCNT to MCNT + 3*16
                INDEX           MCNT
                CA              MW
                INDEX           MCNT
                TS              MW +48D

                INDEX           MCNT
                CA              MW +1
                INDEX           MCNT
                TS              MW +49D

                INDEX           MCNT
                CA              MW +2
                INDEX           MCNT
                TS              MW +50D

                # Add S0 to W[i] (i.e. MCNT + 48)

                CAF             MS0A
                TS              MPAC +1
                CAF             MW48A
                AD              MCNT
                TS              MPAC
                TC              ADD

                # Add W[i-7] (i.e. MCNT + (16-7)*3 = 27)
                CAF             MW27A
                AD              MCNT
                TS              MPAC
                TC              ADD

                # Add S1
                CAF             MS1A
                TS              MPAC
                TC              ADD

                # End of init loop, loop back.
                CCS             MCNT         # MCNT--
                TC              INITLOOP





                # Copy H0 to H7 into A to H
                CAF             N23
COPYAH          TS              MCNT        # Copy 24 words from H0... to A...
                INDEX           A
                CAF             MH0
                INDEX           MCNT
                TS              MA
                CCS             MCNT
                TC              COPYAH


                CCS             NEWJOB          # See if any jobs pending
                TC              CHANG1



                # Main loop, 64 times
                # MCNT is the memory index from 0 to 63*3 in steps of 3.
                CAF             N0
MAINLOOP        TS              MCNT

                CCS             NEWJOB          # See if any jobs pending
                TC              CHANG1

                # E rightrotate 6
                CA              ME
                TS              RORBUF
                CA              ME +1
                TS              RORBUF +1
                CA              ME +2
                TS              RORBUF +2
                CA              N6
                TS              RORCNT
                TC              RORN

                # Store in S1
                CA              RORBUF
                TS              S1
                CA              RORBUF +1
                TS              S1 +1
                CA              RORBUF +2
                TS              S1 +2

                # rightrotate 5 more to get E rightrotate 11
                CA              N5
                TS              RORCNT
                TC              RORN

                # XOR into S1
                CAF             MS1A
                TS              MPAC
                CAF             RORBUFA
                TS              MPAC +1
                TC              XOR

                # rightrotate 14 more to get E rightrotate 25
                CA              N14
                TS              RORCNT
                TC              RORN

                # XOR into S1
                TC              XOR

                # Compute (NOT E) AND G, store in CH (S0's storage used for CH)
MCH             EQUALS          MS0
MCHA            EQUALS          MS0A
                CS              ME
                MASK            MG
                TS              MCH
                CS              ME +1
                MASK            MG +1
                TS              MCH +1
                CS              ME +2
                MASK            MG +2
                TS              MCH =2

                # Compute TEMP1 = E AND F
                CA              ME
                MASK            MF
                TS              TEMP1
                CA              ME +1
                MASK            MF +1
                TS              TEMP1 +1
                CA              ME +2
                MASK            MF +2
                TS              TEMP1 +2

                # XOR into CH
                CAF             MCHA
                TS              MPAC
                CAF             TEMP1A
                TS              MPAC +1
                TC              XOR

                # TEMP1 = H
                CA              MH
                TS              TEMP1
                CA              MH +1
                TS              TEMP1 +1
                CA              MH +2
                TS              TEMP1 +2

                # Add S1
                CAF             TEMP1A
                TS              MPAC
                CAF             MS1A
                TS              MPAC +1
                TC              ADD

                # Add CH
                CAF             MCHA
                TS              MPAC +1
                TC              ADD

                # Add K[i]
                CAF             MKA
                AD              MCNT
                TS              MPAC +1
                TC              ADD

                # Add W{i]
                CAF             MWA
                AD              MCNT
                TS              MPAC +1
                TC              ADD

                # A rightrotate 2
                CA              N2
                TS              RORCNT
                TC              RORN

                # Store in S0
                CA              RORBUF
                TS              MS0
                CA              RORBUF +1
                TS              MS0 +1
                CA              RORBUF +2
                TS              MS0 +2

                # rightrotate 11 more to get rightrotate 13
                CA              N11
                TS              RORCNT
                TC              RORN

                # XOR into S0
                CAF             MS0A
                TS              MPAC
                TC              RORBUFA
                TS              MPAC +1
                TC              XOR

                # rightrotate 9 more to get rightrotate 22
                CA              N9
                TS              RORCNT
                TC              RORN

                # XOR into S0
                TC              XOR

                # A AND B, store in MAJ (use S1's storage for MAJ)
MAJ             EQUALS          MS1
MAJA            EQUALS          MS1A
                CA              MA
                MASK            MB
                TS              MAJ
                CA              MA +1
                MASK            MB +1
                TS              MAJ +1
                CA              MA +2
                MASK            MB +2
                TS              MAJ +2

                # A AND C into TEMP2
                CA              MA
                MASK            MC
                TS              TEMP2
                CA              MA +1
                MASK            MC +1
                TS              TEMP2 +1
                CA              MA +2
                MASK            MC +2
                TS              TEMP2 +2

                # XOR into MAJ
                CAF             MAJA
                TS              MPAC
                CAF             TEMP2A
                TS              MPAC +1

                # B AND C into TEMP2
                CA              MB
                MASK            MC
                TS              TEMP2
                CA              MB +1
                MASK            MC +1
                TS              TEMP2 +1
                CA              MB +2
                MASK            MC +2
                TS              TEMP2 +2

                # XOR TEMP2 into MAJ
                TC              XOR

                # TEMP2 = S0 + MAJ
                # First TEMP2 = S0
                CA              MS0
                TS              TEMP2
                CA              MS0 +1
                TS              TEMP2 +1
                CA              MS0 +2
                TS              TEMP2 +2

                # Now add MAJ
                CA              TEMP2A
                TS              MPAC
                CA              MAJA
                TS              MPAC +1
                TC              ADD

                # Move A..G to B..H, i.e. move 21 words
                # Need to start at H and work down
                CAF             N20
UPDATE          TS              MCNT
                INDEX           MCNT
                CA              MA
                INDEX           MCNT
                TS              MA +3
                CCS             MCNT
                TC              UPDATE

                # E = D + TEMP1, so add TEMP1 to E (which received D above)
                CA              MEA
                TS              MPAC
                CA              TEMP1A
                TS              MPAC +1
                TC              ADD


                # A = TEMP1 + TEMP2. First add TEMP1 to TEMP2.
                CA              TEMP2A
                TS              MPAC
                TC              ADD
                # Now copy to A
                CA              TEMP2
                TS              MA
                CA              TEMP2 +1
                TS              MA +1
                CA              TEMP2 +2
                TS              MA +2
                
                # End of main loop, loop back.
                CA              MCNT         # MCNT += 3
                AD              N3
                TS              MCNT
                AD              NM141             # loop while MCNT <= 141 (i.e. i <= 63)
                EXTEND
                BZMF            MAINLOOP

                # Add compressed chunk into hash
                # Loop 8 times
                CAF             N0
                TS              MCNT         # MCNT = 0 to 21 by 3

                CAF             MH0A
                AD              MCNT
                TS              MPAC            # H0[cnt] += A[cnt]
                CAF             MAA
                AD              MCNT
                TS              MPAC +1
                TC              ADD

                CA              MCNT         # MCNT += 3
                AD              N3
                TS              MCNT
                AD              NM21             # loop while MCNT <= 21
                EXTEND
                BZMF            MAINLOOP
                

                # Would loop here if multiple chunks

                CCS             NEWJOB          # See if any jobs pending
                TC              CHANG1

                # Display
                CA              MS0A
                TC              DISPLAY3

                # Done

MQUIT        TC              FREEDSP         # Free the display and exit

                TC              ENDOFJOB


# Display 3 octal values on display
# Pass address in A

DISPLAY3        EXTEND
                QXCH            DISPRET          # Remember return address
                TS              MPAC +5         # Store address (A) in MPAC +5
                INDEX           MPAC +5
                CA              0
                TS              MPAC +3

                INDEX           MPAC +5
                CA              1
                TS              MPAC +4

                INDEX           MPAC +5
                CA              2
                TS              MPAC +5

                # Display with V05N01

                CAF             MPADR1
                TS              MPAC    +2
                CAF             V5N1
                TC              NVSUB
                TC              MQUIT
                TC              +2
                TC              +1

                # Wait for proceed

                TC              FLASHON
                TC              ENDIDLE
                TC              +3        # Terminate return from ENDIDLE
                TC              +2              # Proceed return from ENDIDLE
                TC              +1        # Data in return from ENDIDLE

                EXTEND
                QXCH            DISPRET
                RETURN

RORCNT          EQUALS          MPAC +2
RORBUF          EQUALS          MPAC +3 # to MPAC+5
DISPRET         EQUALS          TEMP1
DCNT            EQUALS          TEMP1 +1
DISP8RET        EQUALS          TEMP1 +2
# Display 8 octal 3-words on display
# Pass address in A
# Clobbers TEMP1
DISPLAY8        EXTEND
                QXCH            DISP8RET          # Remember return address
                TS              MPAC +5         # Remember data address

                CAF             N0
                TS              DCNT            # DCNT = 0

D8LOOP          TC              DISPLAY3        # Display a triple

                CA              DCNT            # DCNT increment
                AD              N1
                TS              MCNT
                CA              MPAC +5         # Increment MPAC+5 pointer by 3
                AD              N3
                TS              MPAC +5
                AD              NM21             # loop while DCNT <= 7
                EXTEND
                BZMF            D8LOOP

                EXTEND
                QXCH            DISP8RET
                RETURN

# XOR value pointed to by MPAC+1 into value pointed to by MPAC
XOR             INDEX           MPAC +1
                CA              0
                TS              L
                INDEX           MPAC
                CA              0
                EXTEND
                RXOR            L
                INDEX           MPAC
                TS              0

                INDEX           MPAC +1
                CA              1
                TS              L
                INDEX           MPAC
                CA              1
                EXTEND
                RXOR            L
                INDEX           MPAC
                TS              1

                INDEX           MPAC +1
                CA              2
                TS              L
                INDEX           MPAC
                CA              2
                EXTEND
                RXOR            L
                INDEX           MPAC
                TS              2
                RETURN

# ADD value pointed to by MPAC+1 into value pointed to by MPAC
# These are three-word values. Result truncated to 32 bits
ADD             TS              A       # Clean up any overflow
                TS              A
                TS              A
                INDEX           MPAC +1
                CA              2       # Second argument, word 2
                INDEX           MPAC
                AD              2       # Add first argument, word 2
                INDEX           MPAC
                TS              0       # Store back to first argument TODO
                CAF             N6      # Skipped if overflow

                INDEX           MPAC    # Test: store carry in word 1
                TS              1
                RETURN

                # A will be 0 (no overflow) or 1 (overflow)
                # Add to second word of both arguments
                INDEX           MPAC +1
                AD              1       # Add second argument
                INDEX           MPAC
                AD              1       # Add first argument
                INDEX           MPAC
                TS              1       # Store back to first argument
                CAF             N0      # Skipped if overflow

                # A will be 0 (no overflow) or 1 (overflow)
                # Add to top word (2 bits) of both arguments
                INDEX           MPAC +1
                AD              0       # Add second argument
                INDEX           MPAC
                AD              0       # Add first argument
                INDEX           MPAC
                MASK            N3      # Want just 2 bits
                TS              0       # Store back to first argument
                RETURN                  # First return could be skipped
                RETURN

# Rotate right N bits
# 32-bit value is stored as 2 bits, 15 bits, 15 bits
# Value is in ROR, ROR + 1, ROR + 2.
# Uses MPAC + 4, MPAC + 5 for storing bottom bits

# The idea is to test each bottom bit and set aside either 04000 or 0000, to put it
# in the top bit of the next word.
# Then shift right through SR.
# Finally, add in the shifted-in bit from the previous word.

RORN            EXTEND
                QXCH            DISPRET         # Save return addr
                CA              RORCNT
                EXTEND
                DIM             A          # Decrement counter

RORN1           TS              RORCNT
                CA              RORBUF         # A = top two bits
                TS              SR              # Store in shift-right register
                MASK            N1              # Test bottom bit of original value
                EXTEND
                BZF             +2
                CAF             TOPBIT
                TS              MPAC + 4        # Remember shifted-out bit in top pos
                CA              SR
                TS              RORBUF         # Write back shifted value
                
                CA              RORBUF +1       # A = next 15 bits
                TS              SR              # Store in shift-right register
                MASK            N1              # Test bottom bit
                EXTEND
                BZF             +2
                CAF             TOPBIT
                TS              MPAC +5         # Remember shifted-out bit in top pos
                CA              SR              # Read shifted value
                MASK            NOTTOP          # Mask off top bit
                AD              MPAC +4         # Add in shifed-in bit from previous word
                TS              RORBUF +1        # Write back shifted value

                CA              RORBUF +2         # A = bottom 15 bits
                TS              SR
                MASK            N1              # Test bottom bit
                DOUBLE                          # Shift bottom bit left
                AD              RORBUF            # Add to original word (wrapped bit)
                TS              RORBUF
                CAF             TOPBIT
                CA              SR              # Read shifted value
                MASK            NOTTOP          # Mask off top bit
                AD              MPAC +5         # Add in shifed-in bit from previous word
                TS              RORBUF +2        # Write back shifted value

                CCS             RORCNT
                TC              RORN1
                EXTEND
                QXCH            DISPRET
                RETURN

# MPAC usage
# MPAC 2-5 used by display
# MPAC 0 used by display3 for ret, MPAC 3 to pass address
# MPAC 1 used by display8 counter
# MPAC, MPAC +1 used by XOR and ADD
# MPAC 2-5 used by ROR



# Address definitions
H0CADR          CADR            H0INIT
MS0A            ADRES           MS0
MS1A            ADRES           MS1
MWA1            ADRES           MW +3       # Word 1 of MW
RORBUFA         ADRES           RORBUF
MPACA           ADRES           MPAC
MPADR1          ADRES           MPAC    +3
MH0A            ADRES           MH0
MAA             ADRES           MA
MEA             ADRES           ME
MKA             ADRES           MK
MWA             ADRES           MW
TEMP1A          ADRES           TEMP1
TEMP2A          ADRES           TEMP2
MW27A           ADRES           MW +27D
MW48A           ADRES           MW +48D

MBK             ECADR           MH0

# Constants

V5N1            OCT             00501

N0              DEC             0
N1              DEC             1
N2              DEC             2
N3              DEC             3
N4              DEC             4
N5              DEC             5
N6              DEC             6
N7              DEC             7
N9              DEC             9
N10             DEC             10
N11             DEC             11
N14             DEC             14
N20             DEC             20
N23             DEC             23
N42             DEC             42
N43             DEC             43
N44             DEC             44
N47             DEC             47
N48             DEC             48
N127            DEC             127
NM21            DEC             -21
NM141           DEC             -141
NOTTOP          OCT             37777           # Mask off top bit
TOPBIT          OCT             40000           # Top bit set
N77777          OCT             77777
MINUSONE        DEC             -1

# SHA-256 data

H0INIT          OCT             1
                OCT             52023
                OCT             63147
H1INIT          OCT             2
                OCT             73317
                OCT             27205
H2INIT          OCT             0
                OCT             74335
                OCT             71562
H3INIT          OCT             2
                OCT             45237
                OCT             72472
H4INIT          OCT             1
                OCT             21034
                OCT             51177
H5INIT          OCT             2
                OCT             33012
                OCT             64214
H6INIT          OCT             0
                OCT             37407
                OCT             54653
H7INIT          OCT             1
                OCT             33701
                OCT             46431
MK              OCT             1
                OCT             2424
                OCT             27630
                OCT             1
                OCT             61156
                OCT             42221
                OCT             2
                OCT             65601
                OCT             75717
                OCT             3
                OCT             51553
                OCT             55645
                OCT             0
                OCT             71255
                OCT             41133
                OCT             1
                OCT             31742
                OCT             10761
                OCT             2
                OCT             22177
                OCT             1244
                OCT             2
                OCT             53070
                OCT             57325
                OCT             3
                OCT             30017
                OCT             25230
                OCT             0
                OCT             22406
                OCT             55401
                OCT             0
                OCT             44143
                OCT             2676
                OCT             1
                OCT             25030
                OCT             76703
                OCT             1
                OCT             62574
                OCT             56564
                OCT             2
                OCT             675
                OCT             30776
                OCT             2
                OCT             33670
                OCT             3247
                OCT             3
                OCT             1467
                OCT             70564
                OCT             3
                OCT             44466
                OCT             64701
                OCT             3
                OCT             57574
                OCT             43606
                OCT             0
                OCT             17603
                OCT             16706
                OCT             0
                OCT             44031
                OCT             20714
                OCT             0
                OCT             55722
                OCT             26157
                OCT             1
                OCT             12351
                OCT             2252
                OCT             1
                OCT             34541
                OCT             24734
                OCT             1
                OCT             66763
                OCT             4332
                OCT             2
                OCT             30174
                OCT             50522
                OCT             2
                OCT             50143
                OCT             43155
                OCT             2
                OCT             60006
                OCT             23710
                OCT             2
                OCT             77262
                OCT             77707
                OCT             3
                OCT             6700
                OCT             5763
                OCT             3
                OCT             25517
                OCT             10507
                OCT             0
                OCT             6624
                OCT             61521
                OCT             0
                OCT             24122
                OCT             24547
                OCT             0
                OCT             47556
                OCT             5205
                OCT             0
                OCT             56066
                OCT             20470
                OCT             1
                OCT             15130
                OCT             66774
                OCT             1
                OCT             23160
                OCT             6423
                OCT             1
                OCT             45024
                OCT             71524
                OCT             1
                OCT             66324
                OCT             5273
                OCT             2
                OCT             1605
                OCT             44456
                OCT             2
                OCT             22344
                OCT             26205
                OCT             2
                OCT             42577
                OCT             64241
                OCT             2
                OCT             50064
                OCT             63113
                OCT             3
                OCT             2227
                OCT             5560
                OCT             3
                OCT             7330
                OCT             50643
                OCT             3
                OCT             21445
                OCT             64031
                OCT             3
                OCT             26462
                OCT             3044
                OCT             3
                OCT             64034
                OCT             32605
                OCT             0
                OCT             20325
                OCT             20160
                OCT             0
                OCT             31511
                OCT             40426
                OCT             0
                OCT             36156
                OCT             66010
                OCT             0
                OCT             47220
                OCT             73514
                OCT             0
                OCT             64541
                OCT             36265
                OCT             0
                OCT             71070
                OCT             6263
                OCT             1
                OCT             16661
                OCT             25112
                OCT             1
                OCT             33471
                OCT             45117
                OCT             1
                OCT             50134
                OCT             67763
                OCT             1
                OCT             64437
                OCT             1356
                OCT             1
                OCT             70512
                OCT             61557
                OCT             2
                OCT             4620
                OCT             74024
                OCT             2
                OCT             14616
                OCT             1010
                OCT             2
                OCT             20575
                OCT             77772
                OCT             2
                OCT             44240
                OCT             66353
                OCT             2
                OCT             76763
                OCT             21767
                OCT             3
                OCT             6342
                OCT             74362

# Input chunk to hash

INPUT           OCT             1
                OCT             74044
                OCT             25606
                OCT             0
                OCT             50364
                OCT             37367
                OCT             3
                OCT             52604
                OCT             43740
                OCT             2
                OCT             55306
                OCT             70221
                OCT             3
                OCT             14775
                OCT             45770
                OCT             1
                OCT             37304
                OCT             11403
                OCT             0
                OCT             15470
                OCT             17611
                OCT             1
                OCT             25053
                OCT             54746
                OCT             2               # Padding
                OCT             0
                OCT             0
                OCT             0
                OCT             0
                OCT             0
                OCT             0
                OCT             0
                OCT             0
                OCT             0
                OCT             0
                OCT             0
                OCT             0
                OCT             0
                OCT             0
                OCT             0
                OCT             0
                OCT             0
                OCT             0
                OCT             0
                OCT             0
                OCT             0
                OCT             0
                OCT             400
