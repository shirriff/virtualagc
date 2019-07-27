### FILE="Main.annotation"
## Copyright:   Public domain.
## Filename:    INTERRUPT_LEAD_INS.agc
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
## Reference:   pp. 168-169
## Assembler:   yaYUL
## Contact:     Ron Burkey <info@sandroid.org>.
## Website:     www.ibiblio.org/apollo/index.html
## Mod history: 2019-07-27 MAS  Created from Luminary 69.

## Page 168
                SETLOC          4000 
                        
                COUNT*          $$/RUPTS                # FIX-FIX LEAD INS
                INHINT                                  # GO
                CAF             GOBB    
                XCH             BBANK   
                TCF             GOPROG  
                                
                DXCH            ARUPT                   # T6RUPT
                EXTEND          
                DCA             T6ADR   
                DTCB            
                                
                DXCH            ARUPT                   # T5RUPT - AUTOPILOT
                EXTEND          
                DCA             T5ADR   
                DTCB            
                                
                DXCH            ARUPT                   # T3RUPT
                CAF             T3RPTBB 
                XCH             BBANK   
                TCF             T3RUPT  
                                
                DXCH            ARUPT                   # T4RUPT
                CAF             T4RPTBB 
                XCH             BBANK   
                TCF             T4RUPT  
                                
                DXCH            ARUPT                   # KEYRUPT1
                CAF             KEYRPTBB        
                XCH             BBANK   
                TCF             KEYRUPT1        
                                
                DXCH            ARUPT                   # KEYRUPT2
                CAF             MKRUPTBB        
                XCH             BBANK   
                TCF             MARKRUPT        
                                
                DXCH            ARUPT                   # UPRUPT
                CAF             UPRPTBB 
                XCH             BBANK   
                TCF             UPRUPT  
                                
                DXCH            ARUPT                   # DOWNRUPT
                CAF             DWNRPTBB        
                XCH             BBANK   
                TCF             DODOWNTM        
                                
                DXCH            ARUPT                   # RADAR RUPT
                CAF             RDRPTBB 
                
## Page 169
                XCH             BBANK   
                TCF             RADAREAD        
                                
                DXCH            ARUPT                   # RUPT10 IS USED ONLY BY LANDING GUIDANCE
                CA              RUPT10BB        
                XCH             BBANK   
                TCF             PITFALL 
                
                
                EBANK=          LST1                    # RESTART USES E0, E3
GOBB            BBCON           GOPROG  
                
                EBANK=          PERROR  
T6ADR           2CADR           DOT6RUPT        
                
                EBANK=          LST1    
T3RPTBB         BBCON           T3RUPT  
                
                EBANK=          KEYTEMP1        
KEYRPTBB        BBCON           KEYRUPT1        
                
                EBANK=          AOTAZ   
MKRUPTBB        BBCON           MARKRUPT        
                
UPRPTBB         =               KEYRPTBB        
                
                EBANK=          DNTMBUFF        
DWNRPTBB        BBCON           DODOWNTM        
                
                EBANK=          RADMODES        
RDRPTBB         BBCON           RADAREAD        
                
                EBANK=          M11     
T4RPTBB         BBCON           T4RUPT  
                
                EBANK=          ELVIRA  
RUPT10BB        BBCON           PITFALL 
                                        
        