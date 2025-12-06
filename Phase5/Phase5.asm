org 100h
jmp start

; --- CONSTANTS ---
SCREEN_WIDTH      EQU 320
SCREEN_HEIGHT     EQU 200
VGA_SEGMENT       EQU 0A000h

; =================================================================
; DATA SECTION
; =================================================================
section .data

    ; =============================================================
    ; [NEW] START SCREEN DATA
    ; =============================================================
    ; --- Animation Vars ---
    car_x       dw 140         
    car_y       dw 138       ; Car centered on road
    car_dx      dw 2         ; Speed
    car_prev_x  dw 140         
    loading_w   dw 0           

    ; --- Strings ---
    txt_load      db 'LOADING GAME$'
    
    ; Menu Strings
    intro_title   db 'NOBRAKES.EXE$'
    intro_btn     db 'START THE GAME$' 
    
    ; Developers
    intro_dev_h   db 'DEVELOPED BY:$'
    intro_name1   db 'Rahmeen Nabeel$'
    intro_name2   db 'Eliza Nadeem$'
    
    ; --- SPRITE CONFIG ---
    sprite_w equ 32
    sprite_h equ 14

    ; --- SYMMETRIC CAR SPRITE ---
    car_sprite:
    db 0,0,0,0,0,0,0,0,0,0,0,0,0,40,40,40,40,40,40,0,0,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,0,0,40,40,42,42,42,42,42,42,40,40,0,0,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,0,40,40,42,42,42,42,42,42,42,42,42,40,40,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,0,0,40,42,42,42,42,42,42,42,42,42,42,42,42,40,0,0,0,0,0,0,0,0,0
    db 0,0,0,0,0,0,40,40,42,42,42, 1, 1, 1, 1, 1, 1,42,42,42,42,42,40,40,0,0,0,0,0,0,0
    db 0,0,0,0,40,40,42,42,42,42, 1, 1, 1, 1, 1, 1, 1, 1,42,42,42,42,42,40,40,0,0,0,0,0,0
    db 0,0,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,0,0,0,0,0
    db 40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,0,0,0
    db 40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,40,0,0,0
    db 40,40, 0, 0, 0, 0, 0,40,40,40,40,40,40,40,40,40,40,40,40,40,40, 0, 0, 0, 0, 0,40,40,40,40,0,0
    db 40, 0, 8, 8, 8, 8, 8, 0,40,40,40,40,40,40,40,40,40,40,40, 0, 8, 8, 8, 8, 8, 0,40,40,40,0,0
    db 0, 8, 8,15,15, 8, 8, 8, 0,40,40,40,40,40,40,40,40,40, 0, 8, 8,15,15, 8, 8, 8, 0,40,0,0,0
    db 0, 8, 8,15,15, 8, 8, 8, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 8, 8,15,15, 8, 8, 8, 0, 0,0,0,0,0
    db 0, 0, 8, 8, 8, 8, 8, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 8, 8, 8, 8, 8, 0, 0, 0,0,0,0,0

    ; =============================================================
    ; [EXISTING] GAME VARIABLES & DATA
    ; =============================================================
    txtTitle      db 'NoBrakes!'
    lenTitle      equ $ - txtTitle
    
    txtDev1       db 'By: 24L-0655 Eliza Nadeem'
    lenDev1       equ $ - txtDev1
    
    txtDev2       db '24L-0868 Rahmeen Nabeel'
    lenDev2       equ $ - txtDev2
    
    txtPrompt     db 'PRESS ANY KEY to Continue...'
    lenPrompt     equ $ - txtPrompt

    ; --- INPUT SCREEN STRINGS ---
    txtInputTitle db 'ENTER PLAYER DETAILS'
    lenInputTitle equ $ - txtInputTitle
    txtNamePrompt db 'Name: '
    lenNamePrompt equ $ - txtNamePrompt
    txtRollPrompt db 'Roll No: '
    lenRollPrompt equ $ - txtRollPrompt

    playerName    times 20 db ' '
                  db '$'            
                  
    playerRoll    times 15 db ' '
                  db '$'            

    ; --- INSTRUCTION SCREEN STRINGS ---
    txtInstrTitle db 'INSTRUCTION SCREEN'
    lenInstrTitle equ $ - txtInstrTitle
    
    txtInstr1     db '1. Movement of Car :'
    lenInstr1     equ $ - txtInstr1
    txtInstr1a    db '<- for left,'
    lenInstr1a    equ $ - txtInstr1a
    txtInstr1b    db '-> for right'
    lenInstr1b    equ $ - txtInstr1b
    txtInstr1c    db "'up' for forward"
    lenInstr1c    equ $ - txtInstr1c
    txtInstr1d    db "'down' for backwards"
    lenInstr1d    equ $ - txtInstr1d
    
    txtInstr2     db '2. Your Fuel is displayed above,'
    lenInstr2     equ $ - txtInstr2
    txtInstr2a    db 'collect Fuel Cans to drive longer'
    lenInstr2a    equ $ - txtInstr2a
    
    txtInstr3     db "3. Press 'Esc' to Pause the game"
    lenInstr3     equ $ - txtInstr3
    
    txtInstrPlay  db 'PRESS ANY KEY TO START GAME...'
    lenInstrPlay  equ $ - txtInstrPlay

    ; --- GAME OVER ---
    txtGameOverBox db 'GAME OVER$'
    txtReasonFuel  db 'Reason: Out of Fuel!$'
    txtReasonQuit  db 'Reason: You Quit.$'
    txtReasonCrash db 'Reason: Car Crashed!$'
    
    txtEndScore    db 'Score: $'
    txtRestartMsg  db 'SPACE: Restart  ESC: Exit$'
    
    gameOverReason db 0  
    txtConfirm     db 'Do you want to exit? (y/n)$'

    ; --- GAME VARIABLES ---
    obstacleRow   db 0
    obstacleCol   db 0
    fuelLevel     dw 3600
    fuelMax       dw 3600
    fuelBarColor  db 14
    playerRow     db 20
    playerCol     db 36
    gameStarted   db 0
    isPaused      db 0
    gameOver      db 0
    score         dw 0
    
    coinCount     dw 0
    coinStr       db '00000$'
    dollarSign    db '$'
    
    obstacle1Row     db 0
    obstacle1Col     db 37
    obstacle1Active  db 0
    obstacle2Row     db 0
    obstacle2Col     db 37
    obstacle2Active  db 0
    obstacle3Row     db 0
    obstacle3Col     db 37
    obstacle3Active  db 0
    
    coin1Row      db 5
    coin1Col      db 21
    coin1Active   db 1
    coin2Row      db 15
    coin2Col      db 53
    coin2Active   db 1
    
    fuelCanRow       db 0
    fuelCanCol       db 0
    fuelCanActive    db 0
    fuelSpawnTimer   db 0
    
    roadOffset    dw 0
    lastSecond    db 0
    spawnCounter  db 0
    frameCounter  db 0
    
    pauseMsg      db 'QUIT? (y/n)$'
    gameOverMsg   db 'GAME OVER: FUEL ENDED!$'

; =================================================================
; CODE SECTION
; =================================================================
section .text
start:
    mov ax, 0013h
    int 10h
    mov ax, 0A000h
    mov es, ax
    cld

    ; ==========================================
    ; 1. ANIMATED START SCREEN
    ; ==========================================
    
    ; --- A. LOADING ANIMATION ---
loading_state:
    call intro_clear_screen
    
    ; [NEW] Draw Stars on Loading Screen
    call intro_draw_stars
    
    mov dh, 10
    mov dl, 14
    lea si, [txt_load]
    mov bl, 0Fh ; White
    call intro_print_string_at

    ; Bar Background (Dark Grey)
    mov ax, 60
    mov bx, 100
    mov cx, 200
    mov dx, 10
    mov di, 8 
    call intro_draw_rect_fill

.anim_loop:
    ; Draw Progress (Green)
    mov ax, 60
    mov bx, 100
    mov cx, [loading_w]
    mov dx, 10
    mov di, 0Ah ; Light Green
    call intro_draw_rect_fill

    inc word [loading_w]
    inc word [loading_w]
    
    mov cx, 0
    mov dx, 2000h 
    mov ah, 86h
    int 15h

    cmp word [loading_w], 200
    jl .anim_loop

    ; --- B. MENU INITIALIZATION ---
menu_init:
    call intro_clear_screen

    ; 1. BACKGROUND (Black)
    mov ax, 0
    mov bx, 0
    mov cx, 320
    mov dx, 200
    mov di, 0
    call intro_draw_rect_fill

    ; Draw Stars
    call intro_draw_stars

    ; 2. Title
    mov dh, 3
    mov dl, 14
    lea si, [intro_title]
    mov bl, 0Eh ; Yellow
    call intro_print_string_at

    ; 3. The Button
    mov ax, 92
    mov bx, 82
    mov cx, 140
    mov dx, 25
    mov di, 8 
    call intro_draw_rect_fill

    mov ax, 90
    mov bx, 80
    mov cx, 140
    mov dx, 25
    mov di, 1 
    call intro_draw_rect_fill

    mov ax, 90
    mov bx, 80
    mov cx, 140
    mov dx, 2
    mov di, 3 
    call intro_draw_rect_fill

    mov ax, 90
    mov bx, 80
    mov cx, 2
    mov dx, 25
    mov di, 3 
    call intro_draw_rect_fill

    mov dh, 11
    mov dl, 13
    lea si, [intro_btn]
    mov bl, 0Fh 
    call intro_print_string_at

    ; 4. THE ROAD
    mov ax, 0
    mov bx, 126
    mov cx, 320
    mov dx, 2
    mov di, 05h ; Purple Horizon
    call intro_draw_rect_fill

    mov ax, 0
    mov bx, 128
    mov cx, 320
    mov dx, 2
    mov di, 0Fh 
    call intro_draw_rect_fill

    mov ax, 0
    mov bx, 130
    mov cx, 320
    mov dx, 30
    mov di, 8 ; Grey Road
    call intro_draw_rect_fill

    mov ax, 0
    mov bx, 160
    mov cx, 320
    mov dx, 2
    mov di, 0Fh
    call intro_draw_rect_fill

    call intro_draw_lane_markers

    ; 5. Developers (USING NEW ISOLATED VARIABLES)
    mov dh, 22
    mov dl, 2
    lea si, [intro_dev_h]
    mov bl, 03h 
    call intro_print_string_at
    
    lea si, [intro_name1] 
    mov dh, 22
    mov dl, 16
    mov bl, 0Ah 
    call intro_print_string_at
    
    lea si, [intro_name2]
    mov dh, 23
    mov dl, 16
    mov bl, 0Ah 
    call intro_print_string_at

    ; --- C. MENU LOOP ---
menu_loop:
    mov dx, 3DAh
.v1: in al, dx
    test al, 8
    jz .v1
.v2: in al, dx
    test al, 8
    jnz .v2

    ; Erase with Grey
    mov ax, [car_prev_x]
    mov bx, [car_y]
    mov cx, sprite_w
    mov dx, sprite_h
    mov di, 8 
    call intro_draw_rect_fill

    call intro_draw_lane_markers

    ; Update Position
    mov ax, [car_x]
    add ax, [car_dx]
    mov [car_x], ax

    ; Bounce
    cmp ax, 0
    jle .bounce
    cmp ax, 288
    jge .bounce
    jmp .draw

.bounce:
    neg word [car_dx]

.draw:
    mov ax, [car_x]
    mov [car_prev_x], ax
    mov bx, [car_y]
    lea si, [car_sprite]
    call intro_draw_sprite

    ; --- CHECK INPUT: ANY KEY START ---
    mov ah, 01h
    int 16h
    jz menu_loop ; Loop if no key
    
    mov ah, 00h ; Consume the key
    int 16h
    
    ; JUMP TO ORIGINAL GAME FLOW (Input Screen)
    jmp input_screen_entry

    ; ==========================================
    ; 1.5 INPUT SCREEN (Requirement 6)
    ; ==========================================
input_screen_entry:
    call intro_clear_screen
    
    ; [NEW] Draw Starry Background for consistency
    call intro_draw_stars
    
    ; [NEW] Sophisticated Header Line
    mov ax, 60
    mov bx, 42
    mov cx, 200
    mov dx, 2
    mov di, 03h ; Cyan underline
    call intro_draw_rect_fill
    
    mov bp, txtInputTitle
    mov cx, lenInputTitle
    mov bl, 11 ; Light Cyan
    mov dh, 4
    mov dl, 10
    call printString
    
    ; Prompt Name
    mov bp, txtNamePrompt
    mov cx, lenNamePrompt
    mov bl, 15 ; White
    mov dh, 8
    mov dl, 5
    call printString
    
    ; Get Name Input
    mov di, playerName
    mov dx, 080Bh  ; Row 8, Col 11
    call getStringInput

    ; Prompt Roll No
    mov bp, txtRollPrompt
    mov cx, lenRollPrompt
    mov bl, 15
    mov dh, 10
    mov dl, 5
    call printString
    
    ; Get Roll Input
    mov di, playerRoll
    mov dx, 0A0Eh  ; Row 10, Col 14
    call getStringInput

    ; ==========================================
    ; 2. INSTRUCTION SCREEN (Requirement 2)
    ; ==========================================
    call intro_clear_screen
    
    ; [NEW] Draw Starry Background
    call intro_draw_stars
    
    ; [NEW] Sophisticated Header Line
    mov ax, 60
    mov bx, 26
    mov cx, 200
    mov dx, 2
    mov di, 03h ; Cyan underline
    call intro_draw_rect_fill
    
    mov bp, txtInstrTitle
    mov cx, lenInstrTitle
    mov bl, 15
    mov dh, 2
    mov dl, 11
    call printString
    
    mov bp, txtInstr1
    mov cx, lenInstr1
    mov bl, 15
    mov dh, 5
    mov dl, 2
    call printString
    
    mov bp, txtInstr1a
    mov cx, lenInstr1a
    mov bl, 15
    mov dh, 6
    mov dl, 6
    call printString
    
    mov bp, txtInstr1b
    mov cx, lenInstr1b
    mov bl, 15
    mov dh, 7
    mov dl, 6
    call printString
    
    mov bp, txtInstr1c
    mov cx, lenInstr1c
    mov bl, 15
    mov dh, 8
    mov dl, 6
    call printString
    
    mov bp, txtInstr1d
    mov cx, lenInstr1d
    mov bl, 15
    mov dh, 9
    mov dl, 6
    call printString
    
    mov bp, txtInstr2
    mov cx, lenInstr2
    mov bl, 15
    mov dh, 12
    mov dl, 2
    call printString
    
    mov bp, txtInstr2a
    mov cx, lenInstr2a
    mov bl, 15
    mov dh, 13
    mov dl, 6
    call printString
    
    mov bp, txtInstr3
    mov cx, lenInstr3
    mov bl, 15
    mov dh, 17
    mov dl, 2
    call printString
    
    mov bp, txtInstrPlay
    mov cx, lenInstrPlay
    mov bl, 10 ; Green
    mov dh, 21
    mov dl, 7
    call printString
    
    ; Global ESC Check
    call waitKeyWithGlobalEsc

    ; ==========================================
    ; 3. START GAME INITIALIZATION
    ; ==========================================
    ; Reset variables for Restart Capability
    mov word [fuelLevel], 3600
    mov word [score], 0
    mov word [coinCount], 0
    mov byte [gameOver], 0
    mov byte [isPaused], 0
    mov byte [gameStarted], 1
    
    ; Reset positions
    mov byte [playerCol], 36
    mov byte [playerRow], 20
    mov byte [obstacle1Active], 0
    mov byte [obstacle2Active], 0
    mov byte [obstacle3Active], 0
    
    call initTimer
    call drawBackground

; =================================================================
; MAIN GAME LOOP
; =================================================================
gameLoop:
    cmp byte [gameOver], 1
    jne .check_pause
    jmp .gameOver_state

.check_pause:
    cmp byte [isPaused], 1
    jne .run_game
    jmp .paused_state
    
.run_game:
    call checkTimer
    call checkInput
    
    ; --- [NEW] CAR COLLISION CHECK IMPLEMENTED HERE ---
    call checkCarCrash 
    ; --------------------------------------------------
    
    call checkCollisions
    call decrementFuel
    call drawFuelBar
    
    call drawCoins
    call drawFuelCan
    call drawAllObstacles
    call drawPlayerCar
    
    call fixTopRightGrass
    call drawCoinUI
    call waitRetrace
    
    jmp gameLoop

.paused_state:
    call checkPauseInput
    jmp gameLoop

.gameOver_state: 
    ; Requirement 5: Show Ending Screen
    call showEndScreen
    jmp start ; If they choose restart, go to start

exitGame:
    ; Requirement 7: Stack managed, return to DOS cleanly
    mov ax, 0003h
    int 10h
    mov ax, 4C00h
    int 21h

; =================================================================
; PROCEDURES (ORIGINAL GAME)
; =================================================================

; --- [NEW] CAR COLLISION LOGIC ---
checkCarCrash:
    ; Check Obstacle 1
    cmp byte [obstacle1Active], 1
    jne .chk2
    mov al, [obstacle1Col]
    cmp al, [playerCol]
    jne .chk2 ; Not in same lane
    
    ; Same lane, check row distance
    mov al, [obstacle1Row]
    sub al, [playerRow]
    ; Simple absolute diff check
    cmp al, 0
    jge .diff1
    neg al
.diff1:
    cmp al, 4 ; Collision threshold (height overlap)
    jge .chk2
    jmp .do_crash

.chk2:
    ; Check Obstacle 2
    cmp byte [obstacle2Active], 1
    jne .chk3
    mov al, [obstacle2Col]
    cmp al, [playerCol]
    jne .chk3
    
    mov al, [obstacle2Row]
    sub al, [playerRow]
    cmp al, 0
    jge .diff2
    neg al
.diff2:
    cmp al, 4
    jge .chk3
    jmp .do_crash

.chk3:
    ; Check Obstacle 3
    cmp byte [obstacle3Active], 1
    jne .ret_crash
    mov al, [obstacle3Col]
    cmp al, [playerCol]
    jne .ret_crash
    
    mov al, [obstacle3Row]
    sub al, [playerRow]
    cmp al, 0
    jge .diff3
    neg al
.diff3:
    cmp al, 4
    jge .ret_crash
    jmp .do_crash

.ret_crash:
    ret

.do_crash:
    ; Collision detected!
    call drawCollisionSpark ; Show yellow spark
    
    ; --- DELAY FIX TO SHOW SPARK (0.5 SEC) ---
    ; Wait for approx 0.5 seconds (500,000 microseconds)
    mov cx, 07h
    mov dx, 0A120h
    mov ah, 86h
    int 15h
    ; -----------------------------------------
    
    mov byte [gameOverReason], 2 ; 2 = Car Crashed
    call triggerGameOver
    ret

; --- [NEW] ORIGINAL SPARK DRAWING FUNCTION (Scattered) ---
drawCollisionSpark:
    pusha
    mov ax, 0A000h
    mov es, ax
    
    ; Calculate Center Position of Player Car
    mov al, [playerRow]
    mov ah, 0
    mov bl, 8
    mul bl
    add ax, 4 ; Offset Y center slightly
    mov dx, 320
    mul dx
    mov di, ax ; DI = Y offset
    
    mov al, [playerCol]
    mov ah, 0
    mov bl, 4
    mul bl
    add ax, 6 ; Offset X center slightly
    add di, ax ; DI = Screen Address
    
    ; Draw Random Spark Pattern (Yellow/Red pixels)
    mov byte [es:di], 14 ; Yellow
    mov byte [es:di+1], 4 ; Red
    mov byte [es:di-1], 14
    mov byte [es:di+320], 14
    mov byte [es:di-320], 4
    mov byte [es:di+322], 14
    mov byte [es:di-318], 14
    
    ; Expand slightly
    mov byte [es:di+2], 14
    mov byte [es:di-2], 14
    mov byte [es:di+640], 14
    mov byte [es:di-640], 14
    
    popa
    ret

; --- NEW: GLOBAL ESCAPE HANDLER (Requirement 7) ---
waitKeyWithGlobalEsc:
    mov ah, 00h
    int 16h
    cmp al, 27 ; ESC
    je .confirm_exit
    ret
.confirm_exit:
    call showGlobalConfirm
    ; If we returned, user said 'n', so return to caller
    ret

showGlobalConfirm:
    ; Draw a simple box in center
    mov cx, 80
    mov dx, 80
    mov al, 4 ; Red box for alert
.gc_row:
    mov cx, 80
.gc_col:
    mov ah, 0Ch
    int 10h
    inc cx
    cmp cx, 240
    jl .gc_col
    inc dx
    cmp dx, 120
    jl .gc_row
    
    ; Print Text
    push cs
    pop es
    mov bp, txtConfirm
    mov cx, 23 ; Len
    mov bl, 15
    mov dh, 12
    mov dl, 11
    call printString
    
.gc_wait:
    mov ah, 00h
    int 16h
    cmp al, 'y'
    je exitGame
    cmp al, 'Y'
    je exitGame
    cmp al, 'n'
    je .gc_resume
    cmp al, 'N'
    je .gc_resume
    jmp .gc_wait
.gc_resume:
    ; Redraw full screen to clear box (Context dependent, but for Intro/Instr simple clear is ok)
    ; Note: Since this happens on static screens, we just return. 
    ; The user might see a red box artifact until they press a key.
    ; Ideally, we redraw the current screen, but for simplicity, we return.
    ret

; --- NEW: INPUT PROCEDURE (Requirement 6) ---
getStringInput:
    ; Inputs: DI = Buffer Address, DX = Cursor Row/Col
    mov cx, 0 ; Char count
.input_loop:
    mov ah, 02h
    mov bh, 00h
    int 10h
    
    mov ah, 00h
    int 16h
    
    ; CHECK ESCAPE (Req 7)
    cmp al, 27
    je .trigger_esc
    
    cmp al, 13  ; Enter
    je .input_done
    
    cmp al, 8   ; Backspace
    je .handle_backspace
    
    cmp cx, 14  ; Max len
    jge .input_loop
    
    mov [di], al
    inc di
    inc cx
    inc dl      ; Move cursor
    
    mov ah, 0Eh
    mov bl, 15
    int 10h
    jmp .input_loop

.trigger_esc:
    call showGlobalConfirm
    ; If returned (User pressed N), redraw cursor and continue
    jmp .input_loop

.handle_backspace:
    cmp cx, 0
    je .input_loop
    dec di
    dec cx
    dec dl
    mov ah, 02h
    int 10h
    mov ah, 0Eh
    mov al, ' '
    int 10h
    mov ah, 02h
    int 10h
    jmp .input_loop

.input_done:
    mov byte [di], '$'
    ret

; --- FIXED: ENDING SCREEN (Corrected Text Lengths) ---
showEndScreen:
    ; 1. Set ES to Video Memory
    mov ax, 0A000h
    mov es, ax

    ; 2. Clear Screen & Draw Stars
    call intro_clear_screen
    call intro_draw_stars

    ; 3. Draw Cyan Header Line
    mov ax, 60       ; X pos
    mov bx, 50       ; Y pos
    mov cx, 200      ; Width
    mov dx, 2        ; Height
    mov di, 03h      ; Cyan
    call intro_draw_rect_fill

    ; 4. Print Game Over Title (Yellow)
    mov bp, txtGameOverBox
    mov cx, 9
    mov bl, 0Eh      ; Yellow
    mov dh, 5        ; Row
    mov dl, 15       ; Col
    call printString

    ; 5. Print Reason (White)
    cmp byte [gameOverReason], 0
    je ES_ReasonFuel
    cmp byte [gameOverReason], 1
    je ES_ReasonQuit
    
    ; Else Crash
    mov bp, txtReasonCrash
    mov cx, 20 
    jmp ES_PrintReason
    
ES_ReasonFuel:
    mov bp, txtReasonFuel
    mov cx, 20
    jmp ES_PrintReason
    
ES_ReasonQuit:
    mov bp, txtReasonQuit
    mov cx, 17       ; <--- FIXED: Changed from 19 to 17 (removes "Re")

ES_PrintReason:
    mov bl, 15       ; White
    mov dh, 8        ; Row
    mov dl, 8        ; Col
    call printString

    ; 6. Print Name (Calculated Length)
    mov di, playerName
    xor cx, cx       ; Reset counter
    
ES_CalcNameLen:
    cmp byte [di], '$'
    je ES_CheckName
    inc cx
    inc di
    jmp ES_CalcNameLen

ES_CheckName:
    cmp cx, 0
    je ES_RollLogic  ; Skip if empty
    
    mov bp, playerName
    mov dh, 11       ; Row 
    mov dl, 11       ; Col 
    call printString
    
ES_RollLogic:
    ; 7. Print Roll (Calculated Length)
    mov di, playerRoll
    xor cx, cx       ; Reset counter
    
ES_CalcRollLen:
    cmp byte [di], '$'
    je ES_CheckRoll
    inc cx
    inc di
    jmp ES_CalcRollLen

ES_CheckRoll:
    cmp cx, 0
    je ES_ScoreLogic ; Skip if empty
    
    mov bp, playerRoll
    mov dh, 11       ; Row 11
    mov dl, 19      ; Col 22
    call printString

ES_ScoreLogic:
    ; 8. Print Score
    mov bp, txtEndScore
    mov cx, 7
    mov dh, 14
    mov dl, 12
    call printString
    
    mov ax, [score]
    call numberToStringBuffer 
    mov bp, coinStr
    mov cx, 5
    mov dh, 14
    mov dl, 18
    call printString

    ; 9. Instructions (Green)
    mov bp, txtRestartMsg
    mov cx, 25
    mov bl, 0Ah      ; Light Green
    mov dh, 18
    mov dl, 7
    call printString

    ; 10. Input Loop
ES_WaitLoop:
    mov ah, 00h
    int 16h
    cmp al, 32       ; Space -> Restart
    je ES_DoRestart
    cmp al, 27       ; ESC -> Exit
    je ES_DoExit
    jmp ES_WaitLoop

ES_DoRestart:
    ret              ; Return to start
ES_DoExit:
    jmp exitGame     ; Exit to DOS


; --- UTILS ---
clearScreen:
    mov ax, 0A000h
    mov es, ax
    xor di, di
    mov cx, 320*200
    mov al, 0
    rep stosb
    push cs
    pop es
    ret

numberToStringBuffer:
    ; Converts AX to string in coinStr
    mov si, coinStr + 4
    mov byte [si], '$' 
    dec si
    mov cx, 5
.clean_buff:
    mov byte [si], ' '
    dec si
    loop .clean_buff
    
    mov si, coinStr + 4
    dec si
    
    cmp ax, 0
    jne .conv
    mov byte [si], '0'
    ret
.conv:
    mov dx, 0
    mov bx, 10
    div bx
    add dl, '0'
    mov [si], dl
    dec si
    cmp ax, 0
    jne .conv
    ret

; --- FIXED PRINT STRING FUNCTION ---
printString:
    push es         ; Save current ES
    push cs
    pop es          ; Set ES = CS (Data Segment)
    mov ax, 1301h        
    mov bh, 00h
    int 10h
    pop es          ; Restore previous ES (Video Segment)
    ret

triggerGameOver:
    mov byte [gameOver], 1
    ret

checkGameOverInput:
    mov ah, 00h
    int 16h
    jmp exitGame

;
showPauseMenu:
    pusha
    
    ; 1. Draw Cyan Border
    mov cx, 98        ; Start X
    mov dx, 78        ; Start Y
    mov al, 3         ; Color = Cyan
PauseBox_OuterY:
    push cx
PauseBox_OuterX:
    mov ah, 0Ch
    int 10h
    inc cx
    cmp cx, 222       ; End X
    jl PauseBox_OuterX
    pop cx
    inc dx
    cmp dx, 112       ; End Y
    jl PauseBox_OuterY

    ; 2. Draw Black Inner Box
    mov cx, 100       ; Start X
    mov dx, 80        ; Start Y
    mov al, 0         ; Color = Black
PauseBox_InnerY:
    push cx
PauseBox_InnerX:
    mov ah, 0Ch
    int 10h
    inc cx
    cmp cx, 220       ; End X
    jl PauseBox_InnerX
    pop cx
    inc dx
    cmp dx, 110       ; End Y
    jl PauseBox_InnerY

    ; 3. Print Text
    push cs
    pop es
    mov bp, pauseMsg
    mov cx, 11
    mov bl, 0Eh       ; Yellow
    mov dh, 12        ; Row
    mov dl, 14        ; Col
    call printString
    
    ; 4. BLOCKING WAIT LOOP
PauseBox_Wait:
    mov ah, 00h
    int 16h
    
    cmp al, 'y'
    je PauseBox_Quit
    cmp al, 'Y'
    je PauseBox_Quit
    
    cmp al, 'n'
    je PauseBox_Resume
    cmp al, 'N'
    je PauseBox_Resume
    
    cmp al, 27        ; ESC to Resume
    je PauseBox_Resume
    
    jmp PauseBox_Wait

PauseBox_Quit:
    popa
    mov byte [gameOverReason], 1 ; Quit Reason
    call triggerGameOver
    ret

PauseBox_Resume:
    ; --- NEW: ERASE THE BOX BEFORE RETURNING ---
    ; We draw a GREY rectangle over the box to hide it
    ; because the game doesn't redraw the road every frame.
    
    mov cx, 98        ; Start X (Same as border)
    mov dx, 78        ; Start Y (Same as border)
    mov al, 8         ; Color = Grey (Road Color)

EraseBox_Y:
    push cx
EraseBox_X:
    mov ah, 0Ch
    int 10h
    inc cx
    cmp cx, 222       ; End X
    jl EraseBox_X
    pop cx
    inc dx
    cmp dx, 112       ; End Y
    jl EraseBox_Y

    popa
    mov byte [isPaused], 0 ; Unpause logic
    ret


checkPauseInput:
    mov ah, 00h
    int 16h
    cmp al, 'y'
    je .do_quit
    cmp al, 'Y'
    je .do_quit
    cmp al, 'n'
    je .do_resume
    cmp al, 'N'
    je .do_resume
    cmp al, 27
    je .do_resume
    ret
.do_quit:
    mov byte [gameOverReason], 1 ; Quit
    call triggerGameOver
    ret
.do_resume:
    mov byte [isPaused], 0
    call drawBackground
    ret

checkInput:
    mov ah, 01h
    int 16h
    jnz .has_key
    ret
.has_key:
    mov ah, 00h
    int 16h
    cmp al, 27
    je .trigger_pause
    cmp ah, 4Bh
    je .moveLeft
    cmp ah, 4Dh
    je .moveRight
    cmp ah, 48h
    je .moveUp
    cmp ah, 50h
    je .moveDown
    ret
.trigger_pause:
    call showPauseMenu
    ret
.moveLeft:
    mov al, [playerCol]
    cmp al, 50
    jg .goMid
    cmp al, 30
    jg .goLeft
    ret
.goMid:
    call clearPlayerCar
    mov byte [playerCol], 36
    ret
.goLeft:
    call clearPlayerCar
    mov byte [playerCol], 21
    ret
.moveRight:
    mov al, [playerCol]
    cmp al, 30
    jl .goMidR
    cmp al, 45
    jl .goRight
    ret
.goMidR:
    call clearPlayerCar
    mov byte [playerCol], 36
    ret
.goRight:
    call clearPlayerCar
    mov byte [playerCol], 53
    ret
.moveUp:
    mov al, [playerRow]
    cmp al, 1
    jle .ret_inp
    call clearPlayerCar
    dec byte [playerRow]
    ret
.moveDown:
    mov al, [playerRow]
    cmp al, 21
    jge .ret_inp
    call clearPlayerCar
    inc byte [playerRow]
    ret
.ret_inp:
    ret

initTimer:
    mov al, 00h
    out 70h, al
    nop
    in al, 71h
    mov [lastSecond], al
    ret

checkTimer:
    mov al, 00h
    out 70h, al
    nop
    in al, 71h
    cmp al, [lastSecond]
    je .checkFrame
    mov [lastSecond], al
    add word [roadOffset], 3
    call updateLaneMarkers
    inc byte [spawnCounter]
    cmp byte [spawnCounter], 2
    jl .skipSpawn
    mov byte [spawnCounter], 0
    call spawnNewObstacle
    
    inc byte [fuelSpawnTimer]
    cmp byte [fuelSpawnTimer], 4
    jl .skipFuelSpawn
    mov byte [fuelSpawnTimer], 0
    call spawnFuelCan
.skipFuelSpawn:
    
.skipSpawn:
    call moveObstacles
    call moveCoins
    call moveFuelCan
    inc word [score]
    jmp .done
.checkFrame:
    inc byte [frameCounter]
    cmp byte [frameCounter], 10
    jl .done
    mov byte [frameCounter], 0
    inc word [roadOffset]
    call updateLaneMarkers
    call moveObstacles
    call moveCoins
    call moveFuelCan
.done:
    ret

decrementFuel:
    cmp word [fuelLevel], 0
    je .no_fuel
    dec word [fuelLevel] 
    cmp word [fuelLevel], 0
    jle .no_fuel
    mov ax, [fuelLevel]
    cmp ax, 600 
    jg .not_low
    mov byte [fuelBarColor], 4
    jmp .done
.not_low:
    mov byte [fuelBarColor], 14
    jmp .done
.no_fuel:
    mov word [fuelLevel], 0
    mov byte [gameOverReason], 0 ; Fuel End
    call triggerGameOver
.done:
    ret

spawnNewObstacle:
    mov ah, 2Ch
    int 21h
    mov al, dl
    and al, 1
    cmp al, 0
    je .lane1
    mov bl, 53
    jmp .checkSpace
.lane1:
    mov bl, 21
.checkSpace:
    cmp byte [obstacle1Active], 1
    jne .chk2
    mov al, [obstacle1Row]
    cmp al, 8
    jl .abort
.chk2:
    cmp byte [obstacle2Active], 1
    jne .chk3
    mov al, [obstacle2Row]
    cmp al, 8
    jl .abort
.chk3:
    cmp byte [obstacle3Active], 1
    jne .findSlot
    mov al, [obstacle3Row]
    cmp al, 8
    jl .abort
.findSlot:
    cmp byte [obstacle1Active], 0
    je .spawn1
    cmp byte [obstacle2Active], 0
    je .spawn2
    cmp byte [obstacle3Active], 0
    je .spawn3
    ret
.spawn1:
    mov byte [obstacle1Active], 1
    mov byte [obstacle1Row], 0
    mov [obstacle1Col], bl
    ret
.spawn2:
    mov byte [obstacle2Active], 1
    mov byte [obstacle2Row], 0
    mov [obstacle2Col], bl
    ret
.spawn3:
    mov byte [obstacle3Active], 1
    mov byte [obstacle3Row], 0
    mov [obstacle3Col], bl
    ret
.abort:
    ret

spawnFuelCan:
    cmp byte [fuelCanActive], 1
    je .fs_done
    mov byte [fuelCanRow], 0
    call getRandomLane
    mov [fuelCanCol], al
    mov byte [fuelCanActive], 1
.fs_done:
    ret

moveObstacles:
    cmp byte [obstacle1Active], 1
    jne .mo2_tramp
    mov al, [obstacle1Row]
    mov [obstacleRow], al
    mov al, [obstacle1Col]
    mov [obstacleCol], al
    call clearObstacleCar
    inc byte [obstacle1Row]
    mov al, [obstacle1Row]
    cmp al, 25
    jl .mo2_tramp
    mov byte [obstacle1Active], 0
.mo2_tramp:
    jmp .mo2
.mo2:
    cmp byte [obstacle2Active], 1
    jne .mo3_tramp
    mov al, [obstacle2Row]
    mov [obstacleRow], al
    mov al, [obstacle2Col]
    mov [obstacleCol], al
    call clearObstacleCar
    inc byte [obstacle2Row]
    mov al, [obstacle2Row]
    cmp al, 25
    jl .mo3_tramp
    mov byte [obstacle2Active], 0
.mo3_tramp:
    jmp .mo3
.mo3:
    cmp byte [obstacle3Active], 1
    jne .moDone
    mov al, [obstacle3Row]
    mov [obstacleRow], al
    mov al, [obstacle3Col]
    mov [obstacleCol], al
    call clearObstacleCar
    inc byte [obstacle3Row]
    mov al, [obstacle3Row]
    cmp al, 25
    jl .moDone
    mov byte [obstacle3Active], 0
.moDone:
    ret

moveCoins:
    cmp byte [coin1Active], 1
    je .moveC1
    
    cmp byte [coin2Row], 8
    jl .checkC2_tramp 
    
    mov byte [coin1Row], 0
    call getRandomLane
    mov [coin1Col], al
    mov byte [coin1Active], 1
    jmp .checkC2_tramp

.moveC1:
    mov al, [coin1Row]
    mov bl, [coin1Col]
    call clearCoin
    inc byte [coin1Row]
    cmp byte [coin1Row], 25
    jl .checkC2_tramp
    mov byte [coin1Row], 0
    call getRandomLane
    mov [coin1Col], al

.checkC2_tramp:
    jmp .checkC2

.checkC2:
    cmp byte [coin2Active], 1
    je .moveC2
    
    cmp byte [coin1Row], 8
    jl .doneC 
    
    mov byte [coin2Row], 0
    call getRandomLane
    mov [coin2Col], al
    mov byte [coin2Active], 1
    ret

.moveC2:
    mov al, [coin2Row]
    mov bl, [coin2Col]
    call clearCoin
    inc byte [coin2Row]
    cmp byte [coin2Row], 25
    jl .doneC
    mov byte [coin2Row], 0
    call getRandomLane
    mov [coin2Col], al
.doneC:
    ret

moveFuelCan:
    cmp byte [fuelCanActive], 1
    jne .mf_done
    mov al, [fuelCanRow]
    mov bl, [fuelCanCol]
    call clearFuelCan
    inc byte [fuelCanRow]
    mov al, [fuelCanRow]
    cmp al, 25
    jl .mf_done
    mov byte [fuelCanActive], 0
.mf_done:
    ret

checkCollisions:
    cmp byte [coin1Active], 1
    jne .ckCoin2
    mov al, [coin1Row]
    mov bl, [playerRow]
    sub al, bl
    cmp al, 0
    jl .ckCoin2
    cmp al, 3
    jg .ckCoin2
    mov al, [coin1Col]
    mov bl, [playerCol]
    sub al, bl
    cmp al, -4
    jl .ckCoin2
    cmp al, 4
    jg .ckCoin2
    mov byte [coin1Active], 0
    mov al, [coin1Row]
    mov bl, [coin1Col]
    call clearCoin
    add word [score], 10
    inc word [coinCount]

.ckCoin2:
    cmp byte [coin2Active], 1
    jne .ckFuel
    mov al, [coin2Row]
    mov bl, [playerRow]
    sub al, bl
    cmp al, 0
    jl .ckFuel
    cmp al, 3
    jg .ckFuel
    mov al, [coin2Col]
    mov bl, [playerCol]
    sub al, bl
    cmp al, -4
    jl .ckFuel
    cmp al, 4
    jg .ckFuel
    mov byte [coin2Active], 0
    mov al, [coin2Row]
    mov bl, [coin2Col]
    call clearCoin
    add word [score], 10
    inc word [coinCount]

.ckFuel:
    cmp byte [fuelCanActive], 1
    jne .ckDone
    mov al, [fuelCanRow]
    mov bl, [playerRow]
    sub al, bl
    cmp al, 0
    jl .ckDone
    cmp al, 3
    jg .ckDone
    mov al, [fuelCanCol]
    mov bl, [playerCol]
    sub al, bl
    cmp al, -4
    jl .ckDone
    cmp al, 4
    jg .ckDone
    mov byte [fuelCanActive], 0
    mov al, [fuelCanRow]
    mov bl, [fuelCanCol]
    call clearFuelCan
    add word [fuelLevel], 900
    mov ax, [fuelMax]
    cmp [fuelLevel], ax
    jle .ckDone
    mov [fuelLevel], ax

.ckDone:
    ret

getRandomLane:
    mov ah, 2Ch
    int 21h
    mov al, dh
    xor ah, ah
    mov cl, 3
    div cl
    cmp ah, 0
    je .l0
    cmp ah, 1
    je .l1
    mov al, 53
    ret
.l0:
    mov al, 21
    ret
.l1:
    mov al, 37
    ret

waitRetrace:
    mov dx, 03DAh
.w1: in al, dx
    test al, 8
    jnz .w1
.w2: in al, dx
    test al, 8
    jz .w2
    ret

fixTopRightGrass:
    mov ax, 0A000h
    mov es, ax
    mov bx, 0
.fixLoop:
    cmp bx, 15
    jge .fixDone
    mov ax, bx
    mov dx, 320
    mul dx
    add ax, 260
    mov di, ax
    mov ax, bx
    shr ax, 1
    and ax, 1
    test ax, ax
    jnz .light
    mov al, 2
    jmp .draw
.light:
    mov al, 10
.draw:
    mov cx, 60
    rep stosb
    inc bx
    jmp .fixLoop
.fixDone:
    ret

clearPlayerCar:
    push ax
    push bx
    push cx
    push dx
    push si
    push di
    push es
    mov ax, 0A000h
    mov es, ax
    mov al, [playerRow]
    mov ah, 0
    mov bl, 8
    mul bl
    mov dx, ax
    mov al, [playerCol]
    mov ah, 0
    mov bl, 4
    mul bl
    mov si, ax
    xor bx, bx
.cpl:
    cmp bx, 24
    jge .cpd
    mov ax, dx
    add ax, bx
    push dx
    mov dx, 320
    mul dx
    pop dx
    add ax, si
    mov di, ax
    mov al, 8
    mov cx, 16
    rep stosb
    inc bx
    jmp .cpl
.cpd:
    pop es
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret

clearObstacleCar:
    mov ax, 0A000h
    mov es, ax
    mov al, [obstacleRow]
    mov ah, 0
    mov bl, 8
    mul bl
    mov dx, ax
    mov al, [obstacleCol]
    mov ah, 0
    mov bl, 4
    mul bl
    mov si, ax
    xor bx, bx
.cl:
    cmp bx, 24
    jge .cd
    mov ax, dx
    add ax, bx
    push dx
    mov dx, 320
    mul dx
    pop dx
    add ax, si
    mov di, ax
    mov al, 8
    mov cx, 16
    rep stosb
    inc bx
    jmp .cl
.cd:
    ret

clearCoin:
    push ax
    push bx
    mov ah, 0
    mov cl, 8
    mul cl
    mov dx, ax
    mov al, bl
    mov ah, 0
    mov cl, 4
    mul cl
    mov si, ax
    mov ax, 0A000h
    mov es, ax
    xor bx, bx
.cl:
    cmp bx, 8
    jge .cd
    mov ax, dx
    add ax, bx
    push dx
    mov dx, 320
    mul dx
    pop dx
    add ax, si
    add ax, 4
    mov di, ax
    mov al, 8
    mov cx, 8
    rep stosb
    inc bx
    jmp .cl
.cd:
    pop bx
    pop ax
    ret

clearFuelCan:
    push ax
    push bx
    mov ah, 0
    mov cl, 8
    mul cl
    mov dx, ax
    mov al, bl
    mov ah, 0
    mov cl, 4
    mul cl
    mov si, ax
    mov ax, 0A000h
    mov es, ax
    xor bx, bx
.cl:
    cmp bx, 8
    jge .cd
    mov ax, dx
    add ax, bx
    push dx
    mov dx, 320
    mul dx
    pop dx
    add ax, si
    add ax, 4
    mov di, ax
    mov al, 8
    mov cx, 8
    rep stosb
    inc bx
    jmp .cl
.cd:
    pop bx
    pop ax
    ret

drawFuelBar:
    pusha
    mov ax, [fuelLevel]
    mov dx, 0               
    mov cx, 100             
    mul cx                  
    mov bx, [fuelMax]       
    div bx
    mov di, ax
    mov ax, 0A000h
    mov es, ax
    mov al, 2
    mov ah, 0
    mov bx, 320
    mul bx
    mov si, ax
    add si, 2
    mov bx, 0
.draw_empty_loop:
    cmp bx, 100
    jge .draw_full_loop
    mov al, 7
    mov byte [es:si + bx], al
    inc bx
    jmp .draw_empty_loop
.draw_full_loop:
    mov bl, [fuelBarColor]
    mov al, bl
    mov bx, 0
.draw_fill_loop:
    cmp bx, di
    jge .done_drawing
    mov byte [es:si + bx], al
    mov byte [es:si + bx + 320], al
    inc bx
    jmp .draw_fill_loop
.done_drawing:
    popa
    ret

drawPlayerCar:
    mov ax, 0A000h
    mov es, ax
    mov al, [playerRow]
    mov ah, 0
    mov bl, 8
    mul bl
    mov dx, ax
    mov al, [playerCol]
    mov ah, 0
    mov bl, 4
    mul bl
    mov si, ax
    xor bx, bx
.cl:
    cmp bx, 24
    jge .cd
    mov ax, dx
    add ax, bx
    push dx
    mov dx, 320
    mul dx
    pop dx
    add ax, si
    mov di, ax
    cmp bx, 4
    jl .fr
    cmp bx, 8
    jl .ws
    cmp bx, 18
    jl .bd
    jmp .wh
.fr:
    mov al, 8
    mov cx, 3
    rep stosb
    mov al, 12
    mov cx, 10
    rep stosb
    mov al, 8
    mov cx, 3
    rep stosb
    inc bx
    jmp .cl
.ws:
    mov al, 4
    mov cx, 3
    rep stosb
    mov al, 0
    mov cx, 10
    rep stosb
    mov al, 4
    mov cx, 3
    rep stosb
    inc bx
    jmp .cl
.bd:
    mov al, 12
    stosb
    mov al, 4
    mov cx, 14
    rep stosb
    mov al, 12
    stosb
    inc bx
    jmp .cl
.wh:
    mov al, 0
    mov cx, 3
    rep stosb
    mov al, 4
    mov cx, 10
    rep stosb
    mov al, 0
    mov cx, 3
    rep stosb
    inc bx
    jmp .cl
.cd:
    ret

drawObstacleCar:
    mov ax, 0A000h
    mov es, ax
    mov al, [obstacleRow]
    mov ah, 0
    mov bl, 8
    mul bl
    mov dx, ax
    mov al, [obstacleCol]
    mov ah, 0
    mov bl, 4
    mul bl
    mov si, ax
    xor bx, bx
.cl:
    cmp bx, 24
    jge .cd
    mov ax, dx
    add ax, bx
    push dx
    mov dx, 320
    mul dx
    pop dx
    add ax, si
    mov di, ax
    cmp bx, 4
    jl .fr
    cmp bx, 8
    jl .ws
    cmp bx, 18
    jl .bd
    jmp .wh
.fr:
    mov al, 8
    mov cx, 3
    rep stosb
    mov al, 9
    mov cx, 10
    rep stosb
    mov al, 8
    mov cx, 3
    rep stosb
    inc bx
    jmp .cl
.ws:
    mov al, 1
    mov cx, 3
    rep stosb
    mov al, 0
    mov cx, 10
    rep stosb
    mov al, 1
    mov cx, 3
    rep stosb
    inc bx
    jmp .cl
.bd:
    mov al, 9
    stosb
    mov al, 1
    mov cx, 14
    rep stosb
    mov al, 9
    stosb
    inc bx
    jmp .cl
.wh:
    mov al, 0
    mov cx, 3
    rep stosb
    mov al, 1
    mov cx, 10
    rep stosb
    mov al, 0
    mov cx, 3
    rep stosb
    inc bx
    jmp .cl
.cd:
    ret

drawCoins:
    cmp byte [coin1Active], 0
    je .skC1
    mov al, [coin1Row]
    mov bl, [coin1Col]
    call drawPrettyCoin
.skC1:
    cmp byte [coin2Active], 0
    je .dDC
    mov al, [coin2Row]
    mov bl, [coin2Col]
    call drawPrettyCoin
.dDC:
    ret

drawPrettyCoin:
    push ax
    push bx
    mov ah, 0
    mov cl, 8
    mul cl
    mov dx, ax
    mov al, bl
    mov ah, 0
    mov cl, 4
    mul cl
    mov si, ax
    mov ax, 0A000h
    mov es, ax
    xor bx, bx
.cl:
    cmp bx, 8
    jge .cd
    mov ax, dx
    add ax, bx
    push dx
    mov dx, 320
    mul dx
    pop dx
    add ax, si
    add ax, 4
    mov di, ax
    cmp bx, 0
    je .r0
    cmp bx, 1
    je .r1
    cmp bx, 6
    je .r6
    cmp bx, 7
    je .r7
    mov al, 15
    stosb
    mov al, 14
    mov cx, 6
    rep stosb
    mov al, 6
    stosb
    inc bx
    jmp .cl
.r0:
.r7:
    mov al, 8
    stosb
    stosb
    mov al, 14
    mov cx, 4
    rep stosb
    mov al, 8
    stosb
    stosb
    inc bx
    jmp .cl
.r1:
.r6:
    mov al, 8
    stosb
    mov al, 14
    mov cx, 6
    rep stosb
    mov al, 8
    stosb
    inc bx
    jmp .cl
.cd:
    pop bx
    pop ax
    ret

drawFuelCan:
    cmp byte [fuelCanActive], 0
    je .dF_done
    
    mov al, [fuelCanRow]
    mov bl, [fuelCanCol]
    
    push ax
    push bx
    mov ah, 0
    mov cl, 8
    mul cl
    mov dx, ax
    mov al, bl
    mov ah, 0
    mov cl, 4
    mul cl
    mov si, ax
    mov ax, 0A000h
    mov es, ax
    xor bx, bx
.cl:
    cmp bx, 8
    jge .cd
    mov ax, dx
    add ax, bx
    push dx
    mov dx, 320
    mul dx
    pop dx
    add ax, si
    add ax, 4
    mov di, ax
    
    ; Draw Handle (Grey)
    cmp bx, 2
    jl .dF_handle
    
    ; Draw Body (Red)
    mov al, 4   ; Red
    mov cx, 6
    rep stosb
    mov al, 0
    stosb
    stosb
    jmp .dF_next

.dF_handle:
    mov al, 0
    stosb
    mov al, 7   ; Grey
    mov cx, 4
    rep stosb
    mov al, 0
    stosb
    stosb
    stosb

.dF_next:
    inc bx
    jmp .cl
.cd:
    pop bx
    pop ax
.dF_done:
    ret

drawBackground:
    mov ax, 0A000h
    mov es, ax
    xor cx, cx
.rl:
    push cx
    mov ax, cx
    mov dx, 320
    mul dx
    mov di, ax
    mov ax, cx
    shr ax, 1
    and ax, 1
    test ax, ax
    jnz .lgl
    mov cx, 60
    mov al, 2
    rep stosb
    jmp .lgd
.lgl:
    mov cx, 60
    mov al, 10
    rep stosb
.lgd:
    pop cx
    push cx
    mov ax, cx
    shr ax, 1
    and ax, 1
    test ax, ax
    jnz .lsl
    mov al, 0
    stosb
    mov al, 0
    stosb
    mov al, 14
    stosb
    mov al, 14
    stosb
    jmp .lsd
.lsl:
    mov al, 14
    stosb
    mov al, 14
    stosb
    mov al, 0
    stosb
    mov al, 0
    stosb
.lsd:
    mov cx, 192
    mov al, 8
    rep stosb
    pop cx
    push cx
    mov ax, cx
    shr ax, 1
    and ax, 1
    test ax, ax
    jnz .rsl
    mov al, 0
    stosb
    mov al, 0
    stosb
    mov al, 14
    stosb
    mov al, 14
    stosb
    jmp .rsd
.rsl:
    mov al, 14
    stosb
    mov al, 14
    stosb
    mov al, 0
    stosb
    mov al, 0
    stosb
.rsd:
    pop cx
    push cx
    mov ax, cx
    shr ax, 1
    and ax, 1
    test ax, ax
    jnz .rgl
    mov cx, 60
    mov al, 2
    rep stosb
    jmp .rgd
.rgl:
    mov cx, 60
    mov al, 10
    rep stosb
.rgd:
    pop cx
    inc cx
    cmp cx, 200
    jl .rl
    call updateLaneMarkers
    ret

updateLaneMarkers:
    mov ax, 0A000h
    mov es, ax
    mov ax, [roadOffset]
    and ax, 0Fh
    mov dx, ax
    xor cx, cx
.ll:
    push cx
    mov ax, cx
    add ax, dx
    and ax, 0Fh
    cmp ax, 10
    jge .clr
    mov ax, cx
    mov bx, 320
    mul bx
    add ax, 119
    mov di, ax
    mov byte [es:di], 15
    mov byte [es:di+1], 8
    mov byte [es:di+2], 15
    mov ax, cx
    mov bx, 320
    mul bx
    add ax, 183
    mov di, ax
    mov byte [es:di], 15
    mov byte [es:di+1], 8
    mov byte [es:di+2], 15
    jmp .skp
.clr:
    mov ax, cx
    mov bx, 320
    mul bx
    add ax, 119
    mov di, ax
    mov byte [es:di], 8
    mov byte [es:di+1], 8
    mov byte [es:di+2], 8
    mov ax, cx
    mov bx, 320
    mul bx
    add ax, 183
    mov di, ax
    mov byte [es:di], 8
    mov byte [es:di+1], 8
    mov byte [es:di+2], 8
.skp:
    pop cx
    inc cx
    cmp cx, 200
    jl .ll
    ret

drawAllObstacles:
    cmp byte [obstacle1Active], 1
    jne .s1
    mov al, [obstacle1Col]
    cmp al, 21
    je .d1
    cmp al, 53
    je .d1
    mov byte [obstacle1Active], 0
    jmp .s1
.d1:
    mov al, [obstacle1Row]
    mov [obstacleRow], al
    mov al, [obstacle1Col]
    mov [obstacleCol], al
    call drawObstacleCar
.s1:
    cmp byte [obstacle2Active], 1
    jne .s2
    mov al, [obstacle2Col]
    cmp al, 21
    je .d2
    cmp al, 53
    je .d2
    mov byte [obstacle2Active], 0
    jmp .s2
.d2:
    mov al, [obstacle2Row]
    mov [obstacleRow], al
    mov al, [obstacle2Col]
    mov [obstacleCol], al
    call drawObstacleCar
.s2:
    cmp byte [obstacle3Active], 1
    jne .s3
    mov al, [obstacle3Col]
    cmp al, 21
    je .d3
    cmp al, 53
    je .d3
    mov byte [obstacle3Active], 0
    jmp .s3
.d3:
    mov al, [obstacle3Row]
    mov [obstacleRow], al
    mov al, [obstacle3Col]
    mov [obstacleCol], al
    call drawObstacleCar
.s3:
    ret

drawCoinUI:
    ; 1. Print Dollar Sign ($) - Yellow
    push cs
    pop es
    mov bp, dollarSign
    mov cx, 1
    mov bl, 14           
    mov dh, 1             
    mov dl, 35            
    mov ax, 1301h
    mov bh, 00h
    int 10h

    ; 2. Convert Coin Count
    mov ax, [coinCount]
    mov si, coinStr + 4
    mov byte [si], 0    
    dec si
    
    cmp ax, 0
    jne .convert
    mov byte [si], '0'
    dec si
    jmp .print_num

.convert:
    mov dx, 0
    mov bx, 10
    div bx
    add dl, '0'
    mov [si], dl
    dec si
    cmp ax, 0
    jne .convert

.print_num:
    inc si               
    mov bp, si
    
    ; Calculate Length
    mov ax, coinStr + 4
    sub ax, si
    mov cx, ax
    
    ; 3. Print Number - White
    mov bl, 15           
    mov dh, 1             
    mov dl, 37            
    mov ax, 1301h
    mov bh, 00h
    int 10h
    
    ret

; =================================================================
; [NEW] START SCREEN PROCEDURES
; =================================================================

intro_draw_rect_fill:
    push ax
    push bx
    push cx
    push dx
    push di
    push es
    push si
    push dx      
    push ax      
    mov ax, 320
    mul bx       
    pop bx       
    add ax, bx   
    mov bx, ax   
    pop dx       
    mov ax, di   
    mov si, dx   
    mov dx, cx   
.row_loop:
    mov di, bx   
    mov cx, dx   
    rep stosb    
    add bx, 320  
    dec si       
    jnz .row_loop
    pop si
    pop es
    pop di
    pop dx
    pop cx
    pop bx
    pop ax
    ret

intro_clear_screen:
    xor di, di
    xor ax, ax
    mov cx, 320*200
    rep stosb
    ret

intro_print_string_at:
    push ax
    push bx
    push cx
    push dx
    push bp
    push es
    push di
    push ds
    pop es
    mov bp, si
    xor cx, cx
    mov di, si
.len: cmp byte [di], '$'
    je .pr
    inc cx
    inc di
    jmp .len
.pr: mov ah, 13h
    mov al, 01h
    xor bh, bh
    int 10h
    pop di
    pop es
    pop bp
    pop dx
    pop cx
    pop bx
    pop ax
    ret

intro_draw_sprite:
    mov di, ax
    mov ax, 320
    mul bx
    add di, ax
    mov dx, sprite_h
.r: push di
    mov cx, sprite_w
.p: lodsb
    cmp al, 0 
    je .skip
    stosb
    jmp .next
.skip:
    inc di
.next:
    loop .p
    pop di
    add di, 320
    dec dx
    jnz .r
    ret

intro_draw_stars:
    push ax
    push bx
    push cx
    push dx
    push di

    mov dx, 1 ; Height 1
    mov di, 0Fh ; White (Bright Stars)

    ; Top Area
    mov ax, 20
    mov bx, 10
    mov cx, 1
    call intro_draw_rect_fill

    mov ax, 60
    mov bx, 30
    mov cx, 1
    call intro_draw_rect_fill
    
    mov ax, 90
    mov bx, 15
    mov cx, 1
    call intro_draw_rect_fill

    mov ax, 130
    mov bx, 45
    mov cx, 1
    call intro_draw_rect_fill

    mov ax, 170
    mov bx, 10
    mov cx, 1
    call intro_draw_rect_fill
    
    mov ax, 220
    mov bx, 35
    mov cx, 1
    call intro_draw_rect_fill

    mov ax, 260
    mov bx, 15
    mov cx, 1
    call intro_draw_rect_fill

    mov ax, 300
    mov bx, 50
    mov cx, 1
    call intro_draw_rect_fill

    ; Middle-ish Area
    mov ax, 40
    mov bx, 60
    mov cx, 1
    call intro_draw_rect_fill

    mov ax, 110
    mov bx, 70
    mov cx, 1
    call intro_draw_rect_fill

    mov ax, 290
    mov bx, 80
    mov cx, 1
    call intro_draw_rect_fill

    ; Dimmer Stars (Grey/Cyan)
    mov di, 08h ; Grey
    
    mov ax, 35
    mov bx, 20
    mov cx, 1
    call intro_draw_rect_fill

    mov ax, 150
    mov bx, 60
    mov cx, 1
    call intro_draw_rect_fill

    mov ax, 200
    mov bx, 25
    mov cx, 1
    call intro_draw_rect_fill
    
    mov ax, 250
    mov bx, 65
    mov cx, 1
    call intro_draw_rect_fill

    mov di, 03h ; Cyan
    mov ax, 100
    mov bx, 40
    mov cx, 1
    call intro_draw_rect_fill

    mov ax, 280
    mov bx, 10
    mov cx, 1
    call intro_draw_rect_fill

    pop di
    pop dx
    pop cx
    pop bx
    pop ax
    ret

intro_draw_lane_markers:
    push ax
    push bx
    push cx
    push dx
    push di
    
    mov ax, 10      ; Start X
    mov bx, 144     ; Y position
    mov dx, 2       ; Height
    mov di, 0Fh     ; White Color

.lane_loop:
    mov cx, 12      ; Width (Short dashes)
    call intro_draw_rect_fill
    
    add ax, 32      ; Move X forward (Dash Width + Gap)
    cmp ax, 310     ; Check if we reached end of screen
    jl .lane_loop   ; If not, draw next dash

    pop di
    pop dx
    pop cx
    pop bx
    pop ax
    ret