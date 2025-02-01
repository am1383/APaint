;===============================
;APaint Assembly Final Project
;===============================

;General Marco Section
;-------------------------------
DISPLAY_MESSAGE MACRO   MESSAGE
        MOV     DX, OFFSET MESSAGE
        MOV     AH, 09H
        INT     21H
ENDM

SET_CURSOR  MACRO   ROW COL
        MOV     AH, 02H
        MOV     BH, 0   
        MOV     DH, ROW 
        MOV     DL, COL 
        INT     10H     
ENDM

CLEAR_SCREEN    MACRO 
        MOV     AH, 07H         
        MOV     DH, 25          
        MOV     DL, 40          
        MOV     AL, 00H         
        INT     10H   
ENDM