### FILE="Main.annotation"
## Copyright:	Public domain.
## Filename:	P12.agc
## Purpose:	A section of the reconstructed source code for Luminary 130.
##		This was the original program released for the Apollo 13 LM,
##		although several more revisions would follow. It has been
##		reconstructed from a listing of Luminary 131, from which it
##		differs on only two lines in P70-P71. The difference is
##		described in detail in Luminary memo #129, which was used
##		to perform the reconstruction. This file is intended to be a
##		faithful reconstruction, except that the code format has been
##		changed to conform to the requirements of the yaYUL assembler
##		rather than the original YUL assembler.
## Reference:	pp. 831-835
## Contact:	Ron Burkey <info@sandroid.org>.
## Website:	www.ibiblio.org/apollo/index.html
## Mod history:	05/26/03 RSB.	Began transcribing.
##		05/14/05 RSB	Corrected website reference above.
##		2017-01-06 RSB	Page numbers now agree with those on the
##				original harcopy, as opposed to the PDF page
##				numbers in 1701.pdf.
##		2017-01-28 RSB	Proofed comment text using octopus/prooferComments
##				and fixed errors found.
##		2017-02-26 RSB	Proofed comment text using octopus/ProoferComments.
##		2017-03-13 RSB	Comment-text fixes noted in proofing Luminary 116.
##		2017-08-26 MAS	Fixed a comment-text error found while transcribing
##				Zerlina 56.
##		2018-09-04 MAS	Copied from Luminary 131 for Luminary 130.

## Page 831
		BANK	24
		SETLOC	P12
		BANK

		EBANK=	DVCNTR
		COUNT*	$$/P12

P12LM		TC	PHASCHNG
		OCT	04024

		TC	BANKCALL
		CADR	R02BOTH		# CHECK THE STATUS OF THE IMU.
		TC	CLRADMOD	# INITIALIZE RADMODES FOR R29.
		CAF	THRESH2		# INITIALIZE DVMON
		TS	DVTHRUSH
		CAF	FOUR
		TS	DVCNTR

		CA	ZERO
		TS	TRKMKCNT	# SHOW THAT R29 DOWNLINK DATA IS NOT READY

		CAF	V06N33A
		TC	BANKCALL	# FLASH TIG
		CADR	GOFLASH
		TCF	GOTOPOOH
		TCF	+2		# PROCEED
		TCF	-5		# ENTER

		TC	PHASCHNG
		OCT	04024

		TC	INTPRET
		SET	SET
			MUNFLAG
			ACC4-2FL
		SET	CLEAR
			R10FLAG
			RNDVZFLG
		SET	SET
			FLPI
			FLVR
		CALL			# INITIALIZE WM AND /LAND/
			GUIDINIT
		CALL
			P12INIT
P12LMB		DLOAD
			(TGO)A		# SET TGO TO AN INITIAL NOMINAL VALUE.
		STODL	TGO
## Page 832
			TIG
		STCALL	TDEC1
			LEMPREC		# ROTATE THE STATE VECTORS TO THE
		VLOAD	MXV		# IGNITION TIME.
			VATT
			REFSMMAT
		VSL1
		STOVL	V1S		# COMPUTE V1S = VEL(TIG)*2(-7) M/CS.
			RATT
		MXV	VSL6
			REFSMMAT
		STCALL	R		# COMPUTE R = POS(TIG)*2(-24) M.
			MUNGRAV		# COMPUTE GDT1/2(TIG)*2(-7)M/CS.
		VLOAD	UNIT
			R
		STCALL	UNIT/R/		# COMPUTE UNIT/R/ FOR YCOMP.
			YCOMP
		SR	DCOMP
			5D
		STODL	XRANGE		# INITIALIZE XRANGE FOR NOUN 76.
			VINJNOM
		STODL	ZDOTD
			RDOTDNOM
		STORE	RDOTD
		EXIT

		TC	PHASCHNG
		OCT	04024

NEWLOAD		CAF	V06N76		# FLASH CROSS-RANGE AND APOLUNE VALUES.
		TC	BANKCALL
		CADR	GOFLASH
		TCF	GOTOPOOH
		TCF	+2		# PROCEED
		TCF	NEWLOAD		# ENTER NEW DATA.

		CAF	P12ADRES
		TS	WHICH

		TC	PHASCHNG
		OCT	04024

		TC	INTPRET
		DLOAD	SL
			XRANGE
			5D
		DAD
			Y
		STOVL	YCO
			UNIT/R/
## Page 833
		VXSC	VAD
			49FPS
			V1S
		STORE	V		# V(TIPOVER) = V(IGN) + 57FPS (UNIT/R/)
		DOT	SL1
			UNIT/R/
		STOVL	RDOT		# RDOT * 2(-7)
			UNIT/R/
		VXV	UNIT
			QAXIS
		STCALL	ZAXIS1
			ASCENT
P12RET		DLOAD
			ATP		# ATP(2)*2(18)
		DSQ	PDDL
			ATY		# ATY(2)*2(18)
		DSQ	DAD
		BZE	SQRT
			YAWDUN
		SL1	BDDV
			ATY
		ARCSIN
YAWDUN		STOVL	YAW
			UNFC/2
		UNIT	DOT
			UNIT/R/
		SL1	ARCCOS
		DCOMP
		STORE	PITCH
		EXIT
		TC	PHASCHNG
		OCT	04024

		INHINT
		TC	IBNKCALL
		CADR	PFLITEDB
		TC	DOWNFLAG
		ADRES	FLPI

		TC	POSTJUMP
		CADR	BURNBABY

P12INIT		DLOAD			# INITIALIZE ENGINE DATA.  USED FOR P12 AND
			(1/DV)A		# P71.
		STORE	1/DV3
		STORE	1/DV2
		STODL	1/DV1
			(AT)A
		STODL	AT
			(TBUP)A
## Page 834
		STODL	TBUP
			ATDECAY
		DCOMP	SL
			11D
		STORE	TTO
		SLOAD	DCOMP
			APSVEX
		SR2
		STORE	VE
		BOFF	RVQ
			FLAP
			COMMINIT
COMMINIT	DLOAD	DAD		# INITIALIZE TARGET DATA.  USED BY P12, P70
			HINJECT		# AND P71 IF IT DOES NOT FOLLOW P70.
			/LAND/
		STODL	RCO
			HI6ZEROS
		STORE	TXO
		STORE	YCO
		STOVL	YDOTD
			VRECTCSM
		VXV	MXV
			RRECTCSM
			REFSMMAT
		UNIT
		STORE	QAXIS
		RVQ

P12ADRES	REMADR	P12TABLE

		SETLOC	ASENT8
		BANK
		COUNT*	$$/P12

GUIDINIT	STQ	SETPD
			TEMPR60
			0D
		VLOAD	PUSH
			UNITZ
		RTB	PUSH
			LOADTIME
		CALL
			RP-TO-R
		MXV	VXSC
			REFSMMAT
			MOONRATE
		STOVL	WM
			RLS
		ABVAL	SL3
		STCALL	/LAND/
## Page 835
			TEMPR60

49FPS		2DEC	.149352 B-6	# EXPECTED RDOT AT TIPOVER
VINJNOM		2DEC	16.7924 B-7	# 5509.5 FPS(APO=30NM WITH RDOT=19.5FPS)
RDOTDNOM	2DEC	.059436 B-7	# 19.5 FPS


