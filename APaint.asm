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
;-------------------------------

.MODEL SMALL

.STACK 64

.DATA
    MESSAGE1      DB  '***** WELCOME *******$'
    MESSAGE2      DB  'Press Key To Start Application$'

    WHITE         EQU  0FH
    BLUE          EQU  09H
    GREEN         EQU  0AH
    RED           EQU  0CH
    BLACK         EQU  00H
    PAINT_COLOR   DB  WHITE   

    POS_X1        DW  ?
    POS_Y1        DW  ?
    POS_X2        DW  ?
    POS_Y2        DW  ?
    DELTA_X       DW  ?
    DELTA_Y       DW  ? 
    X_DIR         DW  ?
    Y_DIR         DW  ?
    DECISION      DW  ?

.CODE

    MAIN  PROC  FAR
        MOV     AX, @DATA
        MOV     DS, AX
    
        CLEAR_SCREEN
        SET_CURSOR  9, 24
        DISPLAY_MESSAGE MESSAGE1
        SET_CURSOR  20, 28
        DISPLAY_MESSAGE 
        
    CHECK_KEY:        
        MOV   AH, 01
        INT   16H
        JZ    CHECK_KEY

    CLEAR_SCREEN

;Video Mode
    MOV   AH, 0                   
    MOV   AL, 13H
    INT   10H      

    DRAW_COLOR_BOX  WHITE, 0,  20
    DRAW_COLOR_BOX  BLUE,  20, 40
    DRAW_COLOR_BOX  GREEN, 40, 60
    DRAW_COLOR_BOX  RED,   60, 80

;Mouse Init
    MOV   AX, 00H  
    INT   33H 
    CMP   AX, 00H        
    JE    EXIT 
    MOV   AX, 01H    
    INT   33H

    PAINT_LOOP:
    
        MOV   AX, 03H      
        INT   33H
        AND   BX, 03H     
        JZ    PAINT_LOOP  
        
        ;Video Mode For 320*200
        SHR   CX, 1

        ;Switch To Target Color
        CMP   CX, 0FH
        JA    HANDLE_CLICK
        CMP   DX, 81
        JB    SELECT_COLOR     

    HANDLE_CLICK:
        ;Check Left Click
        CMP   BX, 01H
        JE    RIGHT_CLICK
            
        ;Check Right Click
        CMP   BX, 02H
        JE    LEFT_CLICK

    SELECT_COLOR:

        CHOSE_COLOR
        JMP  PAINT_LOOP

    RIGHT_CLICK:

        ;Store Mouse Pos
        MOV   [POS_X1], CX
        MOV   [POS_Y1], DX

    WAIT_RELEASE:

        ;Checking For button release
        MOV   AX, 3
        INT   33H
        CMP   BX, 01H
        JE    WAIT_RELEASE

        SHR   CX, 1

        MOV   [POS_X2], CX
        MOV   [POS_Y2], DX

        CALL  DRAW_LINE
        JMP   PAINT_LOOP

    LEFT_CLICK:

        CALL  ERASER
        JMP   PAINT_LOOP

    EXIT:

        MOV   AH, 00H
        MOV   AL, 03H
        INT   10H

        MOV   AH, 4CH
        INT   21H
MAIN    ENDP

;Earaser Section
;-------------------------------
ERASER  PROC  NEAR
        
        FILL_PIXEL  BLACK
        INC         CX
        FILL_PIXEL  BLACK
        INC         DX
        FILL_PIXEL  BLACK
        DEC         DX 
        DEC         DX         
        FILL_PIXEL  BLACK
        DEC         CX
        FILL_PIXEL  BLACK
        DEC         CX
        FILL_PIXEL  BLACK
        INC         DX         
        FILL_PIXEL  BLACK
        INC         DX         
        FILL_PIXEL  BLACK
        INC         CX         
        FILL_PIXEL  BLACK

        RET 
ERASER  ENDP

;Draw Line Section
;-------------------------------
DRAW_LINE  PROC  NEAR
        ; Save all registers
        PUSHA               

        ; Calculate absolute deltas
        MOV AX, [POS_X2]
        SUB AX, [POS_X1]
        JNC CALC_DELTA_X
        NEG AX
    CALC_DELTA_X:
        MOV [DELTA_X], AX

        MOV AX, [POS_Y2]
        SUB AX, [POS_Y1]
        JNC CALC_DELTA_Y
        NEG AX
    CALC_DELTA_Y:
        MOV [DELTA_Y], AX

        ; Choose algorithm based on slope
        MOV AX, [DELTA_X]
        CMP AX, [DELTA_Y]
        JG DRAW_HORIZONTAL

        CALL DRAW_VERTICAL
        JMP DRAW_EXIT

    DRAW_HORIZONTAL:
        CALL DRAW_HLINE

    DRAW_EXIT:
        ; Restore all registers
        POPA         

        RET
DRAW_LINE ENDP
