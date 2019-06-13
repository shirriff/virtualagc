### FILE="Main.annotation"
## Copyright:   Public domain.
## Filename:    AGC_VERSION_CHECK.agc
## Purpose:     Hack to mine bitcoin.
## Assembler:   yaYUL
## Contact:     Ken Shirriff <ken.shirriff@gmail.com>.
## Website:     www.ibiblio.org/apollo/index.html
## Mod history: 2019-06-13 KWS  Created.

                BANK            11

                EBANK=          MINEH0
AGCVER          CAF             MINEBK
                TS              EBANK

                CAF             N23
MLOOP1          TS              MINECNT        # Copy 24 words from H0INIT to MINEH0
                INDEX           A
                CAF             H0INIT
                INDEX           MINECNT
                TS              MINEH0
                CCS             MINECNT
                TC              MLOOP1

                # Copy MINEH0 to ROR
                CA              MINEH0       
                TS              RORBUF
                CA              MINEH0 + 1
                TS              RORBUF + 1
                CA              MINEH0 + 2
                TS              RORBUF + 2

                # Display
                CA              RORBUFA
                TS              MPAC +5
                TC              DISPLAY3

                # Display
                CA              RORBUFA
                TS              MPAC +5
                TC              DISPLAY3

                # Rotate
                TC              ROR

                # Display
                CA              RORBUFA
                TS              MPAC +5
                TC              DISPLAY3

                # Rotate
                TC              ROR

                # Display
                CA              RORBUFA
                TS              MPAC +5
                TC              DISPLAY3

                # Rotate
                TC              ROR

                # Display
                CA              RORBUFA
                TS              MPAC +5
                TC              DISPLAY3

                # Rotate
                TC              ROR

                # Display
                CA              RORBUFA
                TS              MPAC +5
                TC              DISPLAY3

                # Done

MINEQUIT        TC              FREEDSP         # Free the display and exit

                TC              ENDOFJOB


# Display 3 octal values on display
# Pass address in MPAC +5

DISPLAY3        EXTEND
                QXCH            DISPRET          # Remember return address
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

                CAF             MPADR
                TS              MPAC    +2
                CAF             VERVNCON
                TC              NVSUB
                TC              MINEQUIT
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


# Rotate right 1 bit
# 32-bit value is stored as 2 bits, 15 bits, 15 bits
# Value is in ROR, ROR + 1, ROR + 2.
# Uses MPAC + 4, MPAC + 5 for storing bottom bits

# The idea is to test each bottom bit and set aside either 04000 or 0000, to put it
# in the top bit of the next word.
# Then shift right through SR.
# Finally, add in the shifted-in bit from the previous word.

ROR             CA              RORBUF         # A = top two bits
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
                RETURN

VERVNCON        OCT             00501
RORBUFA         ADRES           RORBUF
MPADR           ADRES           MPAC    +3
N0              DEC             0
N1              DEC             1
N2              DEC             2
N23             DEC             23
NOTTOP          OCT             37777           # Mask off top bit
TOPBIT          OCT             40000           # Top bit set

MINEBK          ECADR           MINEH0

MINEH0A         ADRES           MINEH0

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
MINEK           OCT             1
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

                BANK            12

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
