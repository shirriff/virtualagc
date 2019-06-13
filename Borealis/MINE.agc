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

                # Display the values copied
                CA              MINEH0       
                TS              MPAC    +3
                CA              MINEH0 + 1
                TS              MPAC    +4
                CA              MINEH0 + 2
                TS              MPAC    +5

                CAF             MPADR
                TS              MPAC    +2
                CAF             VERVNCON
                TC              NVSUB
                TC              MINEQUIT
                TC              +2
                TC              +1

                TC              FLASHON
                TC              ENDIDLE
                TC              +3        # Terminate return from ENDIDLE
                TC              +2              # Proceed return from ENDIDLE
                TC              +1        # Data in return from ENDIDLE

                CA              MINEH7       
                TS              MPAC    +3
                CA              MINEH7 + 1
                TS              MPAC    +4
                CA              MINEH7 + 2
                TS              MPAC    +5

                CAF             MPADR
                TS              MPAC    +2
                CAF             VERVNCON
                TC              NVSUB
                TC              MINEQUIT
                TC              +2
                TC              +1

                TC              FLASHON
                TC              ENDIDLE
                TC              +3        # Terminate return from ENDIDLE
                TC              +2              # Proceed return from ENDIDLE
                TC              +1        # Data in return from ENDIDLE

MINEQUIT        TC              FREEDSP         # Free the display and exit

                TC              ENDOFJOB


VERVNCON        OCT             00501
MPADR           ADRES           MPAC    +3
N23             DEC             23

MINEBK          ECADR           MINEH0

ENDVCHK         EQUALS
H0INIT          OCT             152
                OCT             236
                OCT             3147
H1INIT          OCT             273
                OCT             3172
                OCT             7205
H2INIT          OCT             74
                OCT             3357
                OCT             1562
H3INIT          OCT             245
                OCT             2377
                OCT             2472
H4INIT          OCT             121
                OCT             345
                OCT             1177
H5INIT          OCT             233
                OCT             126
                OCT             4214
H6INIT          OCT             37
                OCT             4075
                OCT             4653
H7INIT          OCT             133
                OCT             7014
                OCT             6431
MINEK           OCT             102
                OCT             4242
                OCT             7630
                OCT             161
                OCT             1564
                OCT             2221
                OCT             265
                OCT             6017
                OCT             5717
                OCT             351
                OCT             5535
                OCT             5645
                OCT             71
                OCT             2554
                OCT             1133
                OCT             131
                OCT             7421
                OCT             761
                OCT             222
                OCT             1770
                OCT             1244
                OCT             253
                OCT             705
                OCT             7325
                OCT             330
                OCT             172
                OCT             5230
                OCT             22
                OCT             4065
                OCT             5401
                OCT             44
                OCT             1430
                OCT             2676
                OCT             125
                OCT             307
                OCT             6703
                OCT             162
                OCT             5745
                OCT             6564
                OCT             200
                OCT             6753
                OCT             776
                OCT             233
                OCT             6700
                OCT             3247
                OCT             301
                OCT             4677
                OCT             564
                OCT             344
                OCT             4666
                OCT             4701
                OCT             357
                OCT             5744
                OCT             3606
                OCT             17
                OCT             6031
                OCT             6706
                OCT             44
                OCT             312
                OCT             714
                OCT             55
                OCT             7222
                OCT             6157
                OCT             112
                OCT             3510
                OCT             2252
                OCT             134
                OCT             5412
                OCT             4734
                OCT             166
                OCT             7630
                OCT             4332
                OCT             230
                OCT             1745
                OCT             522
                OCT             250
                OCT             1434
                OCT             3155
                OCT             260
                OCT             62
                OCT             3710
                OCT             277
                OCT             2627
                OCT             7707
                OCT             306
                OCT             7000
                OCT             5763
                OCT             325
                OCT             5171
                OCT             507
                OCT             6
                OCT             6246
                OCT             1521
                OCT             24
                OCT             1222
                OCT             4547
                OCT             47
                OCT             5560
                OCT             5205
                OCT             56
                OCT             662
                OCT             470
                OCT             115
                OCT             1306
                OCT             6774
                OCT             123
                OCT             1600
                OCT             6423
                OCT             145
                OCT             247
                OCT             1524
                OCT             166
                OCT             3240
                OCT             5273
                OCT             201
                OCT             6054
                OCT             4456
                OCT             222
                OCT             3442
                OCT             6205
                OCT             242
                OCT             5776
                OCT             4241
                OCT             250
                OCT             646
                OCT             3113
                OCT             302
                OCT             2270
                OCT             5560
                OCT             307
                OCT             3305
                OCT             643
                OCT             321
                OCT             4456
                OCT             4031
                OCT             326
                OCT             4620
                OCT             3044
                OCT             364
                OCT             343
                OCT             2605
                OCT             20
                OCT             3252
                OCT             160
                OCT             31
                OCT             5114
                OCT             426
                OCT             36
                OCT             1566
                OCT             6010
                OCT             47
                OCT             2207
                OCT             3514
                OCT             64
                OCT             5413
                OCT             6265
                OCT             71
                OCT             700
                OCT             6263
                OCT             116
                OCT             6612
                OCT             5112
                OCT             133
                OCT             4714
                OCT             5117
                OCT             150
                OCT             1346
                OCT             7763
                OCT             164
                OCT             4370
                OCT             1356
                OCT             170
                OCT             5126
                OCT             1557
                OCT             204
                OCT             6207
                OCT             4024
                OCT             214
                OCT             6160
                OCT             1010
                OCT             220
                OCT             5757
                OCT             7772
                OCT             244
                OCT             2406
                OCT             6353
                OCT             276
                OCT             7632
                OCT             1767
                OCT             306
                OCT             3427
                OCT             4362
