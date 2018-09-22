EESchema Schematic File Version 4
LIBS:module-cache
EELAYER 26 0
EELAYER END
$Descr E 44000 34000
encoding utf-8
Sheet 1 3
Title ""
Date ""
Rev ""
Comp ""
Comment1 ""
Comment2 ""
Comment3 ""
Comment4 ""
$EndDescr
$Sheet
S 15250 11550 5450 8975
U 5B8E7731
F0 "1" 140
F1 "2005265A-p1of2.sch" 140
F2 "0VDCA" U R 20700 17550 140
F3 "+4SW" U R 20700 16425 140
F4 "FAP" U R 20700 15375 140
$EndSheet
$Sheet
S 25125 11550 5450 8975
U 5B8E7796
F0 "2" 140
F1 "2005265A-p2of2.sch" 140
F2 "0VDCA" U L 25125 17550 140
F3 "+4SW" U L 25125 16425 140
F4 "FAP" U L 25125 15375 140
$EndSheet
Wire Wire Line
	20700 15375 22900 15375
Wire Wire Line
	20700 16425 22900 16425
Wire Wire Line
	20700 17550 22900 17550
$Comp
L AGC_DSKY:PWR_FLAG #FLG0103
U 1 1 61A08F95
P 22900 17550
F 0 "#FLG0103" H 22900 18075 50  0001 C CNN
F 1 "PWR_FLAG" H 22910 18010 50  0001 C CNN
F 2 "" H 22900 17550 50  0001 C CNN
F 3 "~" H 22900 17550 50  0001 C CNN
	1    22900 17550
	1    0    0    -1  
$EndComp
Connection ~ 22900 17550
Wire Wire Line
	22900 17550 25125 17550
$Comp
L AGC_DSKY:PWR_FLAG #FLG0102
U 1 1 61A08FB9
P 22900 16425
F 0 "#FLG0102" H 22900 16950 50  0001 C CNN
F 1 "PWR_FLAG" H 22910 16885 50  0001 C CNN
F 2 "" H 22900 16425 50  0001 C CNN
F 3 "~" H 22900 16425 50  0001 C CNN
	1    22900 16425
	1    0    0    -1  
$EndComp
Connection ~ 22900 16425
Wire Wire Line
	22900 16425 25125 16425
$Comp
L AGC_DSKY:PWR_FLAG #FLG0101
U 1 1 61A08FDD
P 22900 15375
F 0 "#FLG0101" H 22900 15900 50  0001 C CNN
F 1 "PWR_FLAG" H 22910 15835 50  0001 C CNN
F 2 "" H 22900 15375 50  0001 C CNN
F 3 "~" H 22900 15375 50  0001 C CNN
	1    22900 15375
	1    0    0    -1  
$EndComp
Connection ~ 22900 15375
Wire Wire Line
	22900 15375 25125 15375
Text Notes 38925 31800 0    250  ~ 50
LOGIC FLOW DIAGRAM
Text Notes 40875 33100 0    250  ~ 50
2005265
Text Notes 38250 33100 0    250  ~ 50
80230
Text Notes 39775 32125 0    200  ~ 40
MODULE NO. A15
Text Notes 39775 32425 0    200  ~ 40
RUPT SERVICE
Text Notes 38875 33450 0    140  ~ 28
NONE
Wire Notes Line width 6 style solid
	36839 983  36839 1300
Wire Notes Line width 6 style solid
	36461 1300 43500 1300
Wire Notes Line width 6 style solid
	36461 983  36461 1300
Wire Notes Line width 6 style solid
	37350 982  37350 1299
Wire Notes Line width 6 style solid
	40831 983  40831 1300
Wire Notes Line width 6 style solid
	41331 983  41331 1300
Wire Notes Line width 6 style solid
	41831 983  41831 1300
Wire Notes Line width 6 style solid
	42480 983  42480 1300
Text Notes 36550 1250 0    160  ~ 32
A      REVISED PER TDRR 30754
$EndSCHEMATC
