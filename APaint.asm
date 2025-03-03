;===============================
;APaint Assembly Final Project
;Seyed Amir Mohammad Mousavi
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

DISPLAY_MESSAGE  MACRO   MESSAGE
        MOV   DX, OFFSET MESSAGE
        MOV   AH, 09H
        INT   21H
ENDM
; Filling pixel with chosen color
FILL_PIXEL  MACRO  COLOR
        MOV   AL, COLOR
        MOV   AH, 0CH
        INT   10H
ENDM

SET_CURSOR  MACRO  ROW COL
        MOV   AH, 02H
        MOV   BH, 0   
        MOV   DH, ROW 
        MOV   DL, COL 
        INT   10H     
ENDM
;Draw Color box from START_ROW To END_ROW
COLOR_BOX  MACRO  COLOR, START_ROW, END_ROW
        LOCAL   ROW_LOOP, COL_LOOP
        MOV     DX, START_ROW
    ROW_LOOP:
        MOV     CX, 16           
    COL_LOOP:
        FILL_PIXEL  COLOR                         
        LOOP    COL_LOOP       
        INC     DX             
        CMP     DX, END_ROW     
        JB      ROW_LOOP        
ENDM
;Macro For Switch Between Colors Between 4 Color
SWITCH_COLOR   MACRO
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
    MESSAGE1      DB  '******* WELCOME *******$'
    MESSAGE2      DB  'Press Key To Start Application$'

    POSITION_X1   DW  ?
    POSITION_Y1   DW  ?
    POSITION_X2   DW  ?
    POSITION_Y2   DW  ?
    X_DIRECTION   DW  ?
    Y_DIRECTION   DW  ?
    DELTA_X       DW  ?
    DELTA_Y       DW  ? 
    DECISION      DW  ?

    WHITE         EQU  0FH
    BLUE          EQU  09H
    GREEN         EQU  0AH
    RED           EQU  0CH
    BLACK         EQU  00H
    PAINT_COLOR   DB   WHITE   

.CODE

    MAIN  PROC  FAR
        MOV   AX, @DATA
        MOV   DS, AX
    
        CLEAR_SCREEN
        SET_CURSOR  9, 24
        DISPLAY_MESSAGE MESSAGE1
        SET_CURSOR  20, 28
        DISPLAY_MESSAGE MESSAGE2
    
    ;Check for clicking any button in start menu    
    PRESS_KEY: 

        MOV   AH, 01
        INT   16H
        JZ    PRESS_KEY

    CLEAR_SCREEN

    ;Video Mode
    MOV   AH, 0                   
    MOV   AL, 13H
    INT   10H      

    COLOR_BOX  WHITE, 0,  20
    COLOR_BOX  BLUE,  20, 40
    COLOR_BOX  GREEN, 40, 60
    COLOR_BOX  RED,   60, 80

    ;Mouse Init
    MOV   AX, 00H  
    INT   33H 
    CMP   AX, 00H        
    JE    EXIT 
    MOV   AX, 01H    
    INT   33H

    FILL_PAINT:
        ;Mouse Button Status
        MOV   AX, 03H      
        INT   33H
        AND   BX, 03H     
        JZ    FILL_PAINT  
        
        ;Video Mode For 320*200
        SHR   CX, 1

        ;Switch To Target Color In Menu
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

        SWITCH_COLOR
        JMP   FILL_PAINT

    RIGHT_CLICK:

        ;Store Mouse Pos
        MOV   [POSITION_X1], CX
        MOV   [POSITION_Y1], DX

    WAIT_RELEASE:

        ;Checking For button release
        MOV   AX, 3
        INT   33H
        CMP   BX, 01H
        JE    WAIT_RELEASE

        ;Video Mode For 320*200
        SHR   CX, 1

        MOV   [POSITION_X2], CX
        MOV   [POSITION_Y2], DX

        CALL  DRAW_LINE
        JMP   FILL_PAINT

    LEFT_CLICK:

        CALL  ERASER
        JMP   FILL_PAINT

    EXIT:

        MOV   AH, 00H
        MOV   AL, 03H
        INT   10H

        MOV   AH, 4CH
        INT   21H
MAIN    ENDP

;Eraser Section
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
        ;Save Registers
        PUSHA               

        ;Calculate Delta's
        MOV   AX, [POSITION_X2]
        SUB   AX, [POSITION_X1]
        JNC   CALC_DELTA_X
        NEG   AX

    CALC_DELTA_X:

        MOV   [DELTA_X], AX
        MOV   AX, [POSITION_Y2]
        SUB   AX, [POSITION_Y1]
        JNC   CALC_DELTA_Y
        NEG   AX

    CALC_DELTA_Y:

        MOV   [DELTA_Y], AX
        ;Choose algorithm based on slope
        MOV   AX, [DELTA_X]
        CMP   AX, [DELTA_Y]
        JG    DRAW_HORIZONTAL

        CALL  DRAW_VERTICAL
        JMP   DRAW_EXIT

    DRAW_HORIZONTAL:

        CALL  DRAW_HLINE

    DRAW_EXIT:

        ;Restore Registers
        POPA         

        RET
DRAW_LINE ENDP


;Draw Horizontal Line Section
;-------------------------------
DRAW_HLINE  PROC  NEAR
        PUSHA

        ;Swap Points Condition
        MOV   AX, [POSITION_X1]
        CMP   AX, [POSITION_X2]
        JL    NO_SWAP_X
        XCHG  AX, [POSITION_X2]
        MOV   [POSITION_X1], AX
        MOV   AX, [POSITION_Y1]
        XCHG  AX, [POSITION_Y2]
        MOV   [POSITION_Y1], AX

    NO_SWAP_X:
    
        MOV   AX, [POSITION_X2]
        SUB   AX, [POSITION_X1]
        MOV   [DELTA_X], AX
        
        MOV   AX, [POSITION_Y2]
        SUB   AX, [POSITION_Y1]
        MOV   [DELTA_Y], AX

        ;Determine Y Direction
        MOV   BX, 1
        CMP   AX, 0
        JGE   Y_POSITIVE
        NEG   BX
        NEG   AX

    Y_POSITIVE:

        MOV   [Y_DIRECTION], BX
        MOV   [DELTA_Y], AX

        ;Initialize Decision
        MOV   AX, [DELTA_Y]
        SHL   AX, 1
        SUB   AX, [DELTA_X]
        MOV   [DECISION], AX

        ;Initialize Positions
        MOV   CX, [POSITION_X1]
        MOV   DX, [POSITION_Y1]

    DRAW_LOOP_H:

        FILL_PIXEL PAINT_COLOR

        ;End Condition
        CMP   CX, [POSITION_X2]
        JE    END_HLINE

        ;Update Decision
        MOV   AX, [DECISION]
        CMP   AX, 0
        JL    UPDATE_X

        ;Move Y Direction
        ADD   DX, [Y_DIRECTION]
        SUB   AX, [DELTA_X]
        SUB   AX, [DELTA_X]
        MOV   [DECISION], AX

    UPDATE_X:
    
        ;Move X Direction
        INC   CX
        ADD   AX, [DELTA_Y]
        ADD   AX, [DELTA_Y]
        MOV   [DECISION], AX
        JMP   DRAW_LOOP_H

    END_HLINE:

        POPA

        RET
DRAW_HLINE ENDP

;Draw Vertical Line Section
;-------------------------------
DRAW_VERTICAL PROC NEAR
        PUSHA

        MOV   AX, [POSITION_Y1]
        CMP   AX, [POSITION_Y2]
        JL    NO_SWAP_Y
        XCHG  AX, [POSITION_Y2]
        MOV   [POSITION_Y1], AX
        MOV   AX, [POSITION_X1]
        XCHG  AX, [POSITION_X2]
        MOV   [POSITION_X1], AX

    NO_SWAP_Y:

        ;Calculate DX And DY
        MOV   AX, [POSITION_Y2]
        SUB   AX, [POSITION_Y1]
        MOV   [DELTA_Y], AX
        
        MOV   AX, [POSITION_X2]
        SUB   AX, [POSITION_X1]
        MOV   [DELTA_X], AX

        ;Determine X Direction
        MOV   BX, 1
        CMP   AX, 0
        JGE   X_POSITIVE
        NEG   BX
        NEG   AX

    X_POSITIVE:

        MOV   [X_DIRECTION], BX
        MOV   [DELTA_X], AX

        ;Init Decision
        MOV   AX, [DELTA_X]
        SHL   AX, 1
        SUB   AX, [DELTA_Y]
        MOV   [DECISION], AX

        ;Init Positions
        MOV   CX, [POSITION_X1]
        MOV   DX, [POSITION_Y1]

    DRAW_LOOP_V:

        FILL_PIXEL PAINT_COLOR

        ;End Condition
        CMP   DX, [POSITION_Y2]
        JE    END_VLINE

        ;Update Decision
        MOV   AX, [DECISION]
        CMP   AX, 0
        JL    UPDATE_Y

        ;Move X Direction
        ADD    CX, [X_DIRECTION]
        SUB    AX, [DELTA_Y]
        SUB    AX, [DELTA_Y]
        MOV    [DECISION], AX

    UPDATE_Y:

        ;Move Y Direction
        INC    DX
        ADD    AX, [DELTA_X]
        ADD    AX, [DELTA_X]
        MOV    [DECISION], AX
        JMP    DRAW_LOOP_V

    END_VLINE:

        POPA

        RET
DRAW_VERTICAL ENDP