;===============================
;APaint Assembly Final Project
;===============================

;General Marco Section
;-------------------------------
CLEAR_SCREEN  MACRO 
        MOV   AH, 07H         
        MOV   DH, 25          
        MOV   DL, 40          
        MOV   AL, 00H         
        INT   10H   
ENDM

DISPLAY_MESSAGE MACRO   MESSAGE
        MOV   DX, OFFSET MESSAGE
        MOV   AH, 09H
        INT   21H
ENDM

SET_CURSOR  MACRO   ROW COL
        MOV   AH, 02H
        MOV   BH, 0   
        MOV   DH, ROW 
        MOV   DL, COL 
        INT   10H     
ENDM

FILL_PIXEL  MACRO   COLOR
        MOV   AL, COLOR
        MOV   AH, 0CH
        INT   10H
ENDM

DRAW_COLOR_BOX  MACRO   COLOR, START_ROW, END_ROW
        LOCAL   ROW_LOOP, COL_LOOP
        MOV     DX, START_ROW
    ROW_LOOP:
        MOV     CX, 16           
    COL_LOOP:
        FILL_PIXEL  COLOR                         
        LOOP      COL_LOOP       
        INC     DX             
        CMP     DX, END_ROW     
        JB      ROW_LOOP        
ENDM

CHOSE_COLOR    MACRO
        LOCAL  Case1, Case2, Case3, Case4, Done

        CMP    DX, 20          
        JB     Case1
        CMP    DX, 40          
        JB     Case2
        CMP    DX, 60          
        JB     Case3
        CMP    DX, 80          
        JB     Case4
        JMP    Done      

    Case1:
        MOV    PAINT_COLOR, WHITE
        JMP    Done
    Case2:
        MOV    PAINT_COLOR, BLUE
        JMP    Done
    Case3:
        MOV    PAINT_COLOR, GREEN
        JMP    Done
    Case4:
        MOV    PAINT_COLOR, RED
    Done:
ENDM