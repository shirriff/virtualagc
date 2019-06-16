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

                CCS             NEWJOB          # See if any jobs pending so we
                TC              CHANG1          # don't crash into the Moon

                CAF             N47
INLOOP          TS              MCNT        # Copy 48 words (16 32words) from INPUT to MW
                INDEX           A
                CAF             INPUT
                INDEX           MCNT
                TS              MW
                CCS             MCNT
                TC              INLOOP

                # Loop to initialize W 16-63
		# Instead of looping i from 16 to 63, we loop from 0 to 47.
		# But we step by 3 since the elements are 3 words each.
		# So MCNT = (i-16) * 3
                CAF             N0
                TS              MCNT

INITLOOP        INDEX           MCNT
                CA              MW +3D      # W[i-15] to ROR
                TS              RORBUF
                INDEX           MCNT
                CA              MW +4D
                TS              RORBUF +1
                INDEX           MCNT
                CA              MW +5D
                TS              RORBUF +2

                CCS             NEWJOB          # See if any jobs pending
                TC              CHANG1          # Don't crash into the moon

                # Rotate 3
                CA              N3
                TS              RORCNT
                TC              RORN            # rightrotate 3

                # S0 = W[i-15] rightshift 3. Zero top 3 bits for shift instead of rotate
                CA              RORBUF
                MASK            N1              # Zero 3 bits, keep 1 bit
                TS              MS0
                CA              RORBUF +1
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

                # Now compute S1

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

                # Rightrotate 10
                CA              N10
                TS              RORCNT
                TC              RORN            # rightrotate

                # Mask to get rightshift 10 and store in S1
                # Remove 4 bits from first word, top 6 from second word
                CA              N0
                TS              MS1             # Top 4 bits 0
                CA              RORBUF +1
                MASK            N255          # Leave 8 bits in next word
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
                CAF             MW48A
                AD              MCNT
                TS              MPAC
                CAF             MS0A
                TS              MPAC +1
                TC              ADD

                # Add W[i-7] (i.e. MCNT + (16-7)*3 = 27)
                CAF             MW27A
                AD              MCNT
                TS              MPAC +1
                TC              ADD

                # Add S1
                CAF             MS1A
                TS              MPAC +1
                TC              ADD

                # End of init loop, loop back.
                CA              MCNT         # MCNT += 3
                AD              N3
                TS              MCNT
                AD              NM141             # loop while MCNT <= 141 (i.e. i <= 63)
                EXTEND
                BZMF            INITLOOP




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
                TS              MCNT

MAINLOOP        CCS             NEWJOB          # See if any jobs pending
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
                TS              MS1
                CA              RORBUF +1
                TS              MS1 +1
                CA              RORBUF +2
                TS              MS1 +2

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

                CCS             NEWJOB          # See if any jobs pending
                TC              CHANG1

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
                TS              MCH +2

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

                # Add W{i] yielding final TEMP1
                CAF             MWA
                AD              MCNT
                TS              MPAC +1
                TC              ADD

                # Compute S0
                # Load A into RORBUF
                CA              MA
                TS              RORBUF
                CA              MA +1
                TS              RORBUF +1
                CA              MA +2
                TS              RORBUF +2
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
                CA              RORBUFA
                TS              MPAC +1
                TC              XOR

                # rightrotate 9 more to get rightrotate 22
                CA              N9
                TS              RORCNT
                TC              RORN

                # XOR into S0
                TC              XOR

                CCS             NEWJOB          # See if any jobs pending
                TC              CHANG1

                # Compute MAJ
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
                TC              XOR

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

                # XOR TEMP2 into MAJ, yielding final MAJ value
                TC              XOR

                # Compute TEMP2 = S0 + MAJ
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
                # Need to start at H and work down. Use MPAC as loop counter.
                CAF             N20
UPDATE          TS              MPAC
                INDEX           MPAC
                CA              MA
                INDEX           MPAC
                TS              MA +3
                CCS             MPAC
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
                AD              NM189             # loop while MCNT <= 189 (i.e. i <= 63)
                EXTEND
                BZMF            MAINLOOP

                # Add compressed chunk into hash
                # Loop 8 times
                CAF             N0
                TS              MCNT         # MCNT = 0 to 21 by 3

ADDLOOP         CAF             MH0A
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
                BZMF            ADDLOOP


                # Would loop here if multiple chunks

                CCS             NEWJOB          # See if any jobs pending
                TC              CHANG1

                # Check result: want last 6 words of hash MH0 to be 0.
                CAF             N5
CHECK           TS              MCNT
                INDEX           MCNT
                CA              MH0 + 18D # Check word
                EXTEND
                BZF             OKAY
                TC              BAD             # If nonzero, bad
OKAY            CCS             MCNT            # Otherwise okay for now
                TC              CHECK

                # Display success message
                #CA              GOODMSGA
                #TC              DISPLAY3

                # Display final hash: Loop 8 times
                CAF             N21
                TS              MCNT         # MCNT = 21 to 0 by -3
DISPLOOP        CAF             MH0A
                AD              MCNT
                TC              DISPLAY3
                CA              MCNT         # MCNT -= 3
                AD              NM3
                TS              MCNT
                AD              N3             # loop while MCNT >= 0
                EXTEND
                BZMF            BAD
                TC              DISPLOOP

                # Fall through to indicate end of data

                # Display bad message
BAD             CA              BADMSGA
                TC              DISPLAY3


                # Done

MQUIT           TC              FREEDSP         # Free the display and exit

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

#The plan is that MPAC+0, MPAC+1 are used by XOR, ADD
# MPAC+2, +3, +4 are used by ROR to hold the value and MPAC+5, MPAC+6 are used for temps
# These are also used by DISPLAY3, so beware.
# TEMP1 and TEMP2 are values used in the main SHA loop.
# TEMP1 is also used by DISPLAY3.
RORBUF          EQUALS          MPAC +2 # to MPAC+4, ROR uses MPAC+5, MPAC+6 for temps
DISPRET         EQUALS          TEMP1
DCNT            EQUALS          TEMP1 +1


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
ADD             INDEX           MPAC +1
                CA              2       # Second argument, word 2
                INDEX           MPAC
                AD              2       # Add first argument, word 2
                INDEX           MPAC
                TS              2       # Store back to first argument, word 2
                CAF             N0      # Skipped if overflow

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
                MASK            N15      # Want bottom 4 bits
                INDEX           MPAC
                TS              0       # Store back to first argument
                RETURN                  # First return could be skipped?
                RETURN

# Rotate right N bits
# 32-bit value is stored as 4 bits, 14 bits, 14 bits
# Value is in ROR, ROR + 1, ROR + 2.
# Uses MPAC + 4, MPAC + 5 for storing bottom bits

# The idea is to test each bottom bit and set aside either 02000 or 0, to put it
# in the top bit of the next word.
# Then shift right through SR.
# Finally, add in the shifted-in bit from the previous word.

RORN            EXTEND
                QXCH            RORRET         # Save return addr
                CA              RORCNT
                EXTEND
                DIM             A          # Decrement counter

RORN1           TS              RORCNT
                CA              RORBUF         # A = top four bits
                TS              SR              # Store in shift-right register
                MASK            N1              # Test bottom bit of original value
                EXTEND
                BZF             +2
                CAF             TOPBIT
                TS              MPAC + 5        # Remember shifted-out bit in top pos
                CA              SR
                TS              RORBUF         # Write back shifted value

                CA              RORBUF +1       # A = next 14 bits
                TS              SR              # Store in shift-right register
                MASK            N1              # Test bottom bit
                EXTEND
                BZF             +2
                CAF             TOPBIT
                TS              MPAC +6         # Remember shifted-out bit in top pos
                CA              SR              # Read shifted value
                MASK            NOTTOP          # Mask off top bit
                AD              MPAC +5         # Add in shifed-in bit from previous word
                TS              RORBUF +1        # Write back shifted value

                CA              RORBUF +2         # A = bottom 14 bits
                TS              SR
                MASK            N1              # Test bottom bit
                DOUBLE                          # Shift bottom bit left 3 positions
                DOUBLE
                DOUBLE
                AD              RORBUF            # Add to original word (wrapped bit)
                TS              RORBUF
                CAF             TOPBIT
                CA              SR              # Read shifted value
                MASK            NOTTOP          # Mask off top bit
                AD              MPAC +6         # Add in shifed-in bit from previous word
                TS              RORBUF +2        # Write back shifted value

                CCS             RORCNT
                TC              RORN1
                EXTEND
                QXCH            RORRET
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
BADMSGA         ADRES           BADMSG
GOODMSGA        ADRES           GOODMSG

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
N15             DEC             15
N20             DEC             20
N21             DEC             21
N23             DEC             23
N42             DEC             42
N43             DEC             43
N44             DEC             44
N47             DEC             47
N48             DEC             48
N255            DEC             255
NM3             DEC             -3
NM21            DEC             -21		# -7*3
NM141           DEC             -141		# -(63-16)*3
NM189           DEC             -189		# -63*3
NOTTOP          OCT             17777           # Mask off top bit of 14-bit segment
TOPBIT          OCT             20000           # Top bit set in 14-bit segment
N37777          OCT             37777
MINUSONE        DEC             -1
BADMSG          OCT             11111
                OCT             11111
                OCT             11111
GOODMSG         OCT             0
                OCT             0
                OCT             0


# SHA-256 data

H0INIT          OCT             6
                OCT             24047
                OCT             23147
H1INIT          OCT             13
                OCT             26636
                OCT             27205
H2INIT          OCT             3
                OCT             30673
                OCT             31562
H3INIT          OCT             12
                OCT             12477
                OCT             32472
H4INIT          OCT             5
                OCT             2071
                OCT             11177
H5INIT          OCT             11
                OCT             26025
                OCT             24214
H6INIT          OCT             1
                OCT             37017
                OCT             14653
H7INIT          OCT             5
                OCT             27603
                OCT             6431
MK              OCT             4
                OCT             5050
                OCT             27630
                OCT             7
                OCT             2335
                OCT             2221
                OCT             13
                OCT             13403
                OCT             35717
                OCT             16
                OCT             23327
                OCT             15645
                OCT             3
                OCT             22533
                OCT             1133
                OCT             5
                OCT             23704
                OCT             10761
                OCT             11
                OCT             4376
                OCT             1244
                OCT             12
                OCT             26161
                OCT             17325
                OCT             15
                OCT             20036
                OCT             25230
                OCT             1
                OCT             5015
                OCT             15401
                OCT             2
                OCT             10306
                OCT             2676
                OCT             5
                OCT             12061
                OCT             36703
                OCT             7
                OCT             5371
                OCT             16564
                OCT             10
                OCT             1572
                OCT             30776
                OCT             11
                OCT             27560
                OCT             3247
                OCT             14
                OCT             3157
                OCT             30564
                OCT             16
                OCT             11155
                OCT             24701
                OCT             16
                OCT             37371
                OCT             3606
                OCT             0
                OCT             37406
                OCT             16706
                OCT             2
                OCT             10062
                OCT             20714
                OCT             2
                OCT             33644
                OCT             26157
                OCT             4
                OCT             24722
                OCT             2252
                OCT             5
                OCT             31302
                OCT             24734
                OCT             7
                OCT             15746
                OCT             4332
                OCT             11
                OCT             20371
                OCT             10522
                OCT             12
                OCT             20307
                OCT             3155
                OCT             13
                OCT             14
                OCT             23710
                OCT             13
                OCT             36545
                OCT             37707
                OCT             14
                OCT             15600
                OCT             5763
                OCT             15
                OCT             13236
                OCT             10507
                OCT             0
                OCT             15451
                OCT             21521
                OCT             1
                OCT             10244
                OCT             24547
                OCT             2
                OCT             17334
                OCT             5205
                OCT             2
                OCT             34154
                OCT             20470
                OCT             4
                OCT             32261
                OCT             26774
                OCT             5
                OCT             6340
                OCT             6423
                OCT             6
                OCT             12051
                OCT             31524
                OCT             7
                OCT             14650
                OCT             5273
                OCT             10
                OCT             3413
                OCT             4456
                OCT             11
                OCT             4710
                OCT             26205
                OCT             12
                OCT             5377
                OCT             24241
                OCT             12
                OCT             20151
                OCT             23113
                OCT             14
                OCT             4456
                OCT             5560
                OCT             14
                OCT             16661
                OCT             10643
                OCT             15
                OCT             3113
                OCT             24031
                OCT             15
                OCT             15144
                OCT             3044
                OCT             17
                OCT             10070
                OCT             32605
                OCT             1
                OCT             652
                OCT             20160
                OCT             1
                OCT             23223
                OCT             426
                OCT             1
                OCT             34335
                OCT             26010
                OCT             2
                OCT             16441
                OCT             33514
                OCT             3
                OCT             11302
                OCT             36265
                OCT             3
                OCT             22160
                OCT             6263
                OCT             4
                OCT             35542
                OCT             25112
                OCT             5
                OCT             27163
                OCT             5117
                OCT             6
                OCT             20271
                OCT             27763
                OCT             7
                OCT             11076
                OCT             1356
                OCT             7
                OCT             21225
                OCT             21557
                OCT             10
                OCT             11441
                OCT             34024
                OCT             10
                OCT             31434
                OCT             1010
                OCT             11
                OCT             1373
                OCT             37772
                OCT             12
                OCT             10501
                OCT             26353
                OCT             13
                OCT             35746
                OCT             21767
                OCT             14
                OCT             14705
                OCT             34362
INPUT           OCT             7
                OCT             30110
                OCT             25606
                OCT             2
                OCT             20750
                OCT             37367
                OCT             16
                OCT             25411
                OCT             3740
                OCT             12
                OCT             32615
                OCT             30221
                OCT             14
                OCT             31773
                OCT             5770
                OCT             5
                OCT             36610
                OCT             11403
                OCT             0
                OCT             33160
                OCT             17611
                OCT             5
                OCT             12127
                OCT             14746
                OCT             10
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
