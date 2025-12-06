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
    ; BACKGROUND MUSIC DATA
    ; =============================================================
    ; Frequencies (Divisor = 1193180 / Hz)
    music_notes dw 3619,    0, 4831, 4063, 3619,    0, 3043, 3619 
                dw 4063, 4831, 3619,    0, 5423, 4831, 4063, 4831 
                dw 3619, 3619, 2711, 2711, 2415, 2415, 2711, 3043 
                dw 3619,    0, 3043,    0, 2711,    0, 2415,    0 
    
    music_len   equ ($ - music_notes) / 2

    ; Note Durations
    music_durations dw 4, 1, 2, 2, 4, 1, 2, 2
                    dw 2, 2, 4, 1, 2, 2, 2, 2
                    dw 2, 2, 2, 2, 2, 2, 2, 2
                    dw 3, 1, 3, 1, 3, 1, 3, 1

    music_idx       dw 0      
    music_tick      dw 1      
    old_int1c_off   dw 0      
    old_int1c_seg   dw 0      
    music_on        db 0      

    ; =============================================================
    ; START SCREEN DATA
    ; =============================================================
    car_x       dw 140          
    car_y       dw 138        
    car_dx      dw 2          
    car_prev_x  dw 140        
    loading_w   dw 0          

    txt_load      db 'LOADING GAME$'
    
    intro_title   db 'NOBRAKES.EXE$'
    intro_btn     db 'START THE GAME$' 
    
    intro_dev_h   db 'DEVELOPED BY:$'
    intro_name1   db 'Rahmeen Nabeel$'
    intro_name2   db 'Eliza Nadeem$'
    
    sprite_w equ 32
    sprite_h equ 14

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
    ; GAME VARIABLES & DATA
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
    obstacleRow    db 0
    obstacleCol    db 0
    fuelLevel      dw 3600
    fuelMax        dw 3600
    fuelBarColor   db 14
    playerRow      db 20
    playerCol      db 36
    gameStarted    db 0
    isPaused       db 0
    gameOver       db 0
    score          dw 0
    
    coinCount      dw 0
    coinStr        db '00000$'
    dollarSign     db '$'
    
    obstacle1Row     db 0
    obstacle1Col     db 37
    obstacle1Active  db 0
    obstacle2Row     db 0
    obstacle2Col     db 37
    obstacle2Active  db 0
    obstacle3Row     db 0
    obstacle3Col     db 37
    obstacle3Active  db 0
    
    coin1Row       db 5
    coin1Col       db 21
    coin1Active    db 1
    coin2Row       db 15
    coin2Col       db 53
    coin2Active    db 1
    
    fuelCanRow       db 0
    fuelCanCol       db 0
    fuelCanActive    db 0
    fuelSpawnTimer   db 0
    
    roadOffset     dw 0
    lastSecond     db 0
    spawnCounter   db 0
    frameCounter   db 0
    
    pauseMsg       db 'QUIT? (y/n)$'
    gameOverMsg    db 'GAME OVER: FUEL ENDED!$'

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
    ; START MUSIC ENGINE
    ; ==========================================
    call setup_music

    ; ==========================================
    ; 1. ANIMATED START SCREEN
    ; ==========================================
    
    ; --- A. LOADING ANIMATION ---
loading_state:
    call intro_clear_screen
    
    call intro_draw_stars
    
    mov dh, 10
    mov dl, 14
    lea si, [txt_load]
    mov bl, 0Fh 
    call intro_print_string_at

    mov ax, 60
    mov bx, 100
    mov cx, 200
    mov dx, 10
    mov di, 8 
    call intro_draw_rect_fill

.anim_loop:
    mov ax, 60
    mov bx, 100
    mov cx, [loading_w]
    mov dx, 10
    mov di, 0Ah 
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

    mov ax, 0
    mov bx, 0
    mov cx, 320
    mov dx, 200
    mov di, 0
    call intro_draw_rect_fill

    call intro_draw_stars

    mov dh, 3
    mov dl, 14
    lea si, [intro_title]
    mov bl, 0Eh 
    call intro_print_string_at

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

    mov ax, 0
    mov bx, 126
    mov cx, 320
    mov dx, 2
    mov di, 05h 
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
    mov di, 8 
    call intro_draw_rect_fill

    mov ax, 0
    mov bx, 160
    mov cx, 320
    mov dx, 2
    mov di, 0Fh
    call intro_draw_rect_fill

    call intro_draw_lane_markers

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
    jz .v2

    mov ax, [car_prev_x]
    mov bx, [car_y]
    mov cx, sprite_w
    mov dx, sprite_h
    mov di, 8 
    call intro_draw_rect_fill

    call intro_draw_lane_markers

    mov ax, [car_x]
    add ax, [car_dx]
    mov [car_x], ax

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

    mov ah, 01h
    int 16h
    jz menu_loop 
    
    mov ah, 00h 
    int 16h
    
    jmp input_screen_entry

    ; ==========================================
    ; 1.5 INPUT SCREEN
    ; ==========================================
input_screen_entry:
    call intro_clear_screen
    
    call intro_draw_stars
    
    mov ax, 60
    mov bx, 42
    mov cx, 200
    mov dx, 2
    mov di, 03h 
    call intro_draw_rect_fill
    
    mov bp, txtInputTitle
    mov cx, lenInputTitle
    mov bl, 11 
    mov dh, 4
    mov dl, 10
    call printString
    
    mov bp, txtNamePrompt
    mov cx, lenNamePrompt
    mov bl, 15 
    mov dh, 8
    mov dl, 5
    call printString
    
    mov di, playerName
    mov dx, 080Bh  
    call getStringInput

    mov bp, txtRollPrompt
    mov cx, lenRollPrompt
    mov bl, 15
    mov dh, 10
    mov dl, 5
    call printString
    
    mov di, playerRoll
    mov dx, 0A0Eh 
    call getStringInput

    ; ==========================================
    ; 2. INSTRUCTION SCREEN
    ; ==========================================
    call intro_clear_screen
    
    call intro_draw_stars
    
    mov ax, 60
    mov bx, 26
    mov cx, 200
    mov dx, 2
    mov di, 03h 
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
    mov bl, 10 
    mov dh, 21
    mov dl, 7
    call printString
    
    call waitKeyWithGlobalEsc

    ; ==========================================
    ; 3. START GAME INITIALIZATION
    ; ==========================================
    mov word [fuelLevel], 3600
    mov word [score], 0
    mov word [coinCount], 0
    mov byte [gameOver], 0
    mov byte [isPaused], 0
    mov byte [gameStarted], 1
    
    mov byte [playerCol], 36
    mov byte [playerRow], 20
    mov byte [obstacle1Active], 0
    mov byte [obstacle2Active], 0
    mov byte [obstacle3Active], 0
    
    ; [FIX] RESET FUEL VARIABLES SO CANS APPEAR
    mov byte [fuelCanActive], 0
    mov byte [fuelSpawnTimer], 0
    
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
    call showEndScreen
    jmp start 

exitGame:
    call cleanup_music

    mov ax, 0003h
    int 10h
    mov ax, 4C00h
    int 21h

; =================================================================
; MUSIC PROCEDURES
; =================================================================

setup_music:
    pusha
    push es
    
    cmp byte [music_on], 1
    je .done_setup

    xor ax, ax
    mov es, ax
    mov ax, [es:1Ch * 4]
    mov [old_int1c_off], ax
    mov ax, [es:1Ch * 4 + 2]
    mov [old_int1c_seg], ax

    cli 
    mov word [es:1Ch * 4], new_timer_isr
    mov [es:1Ch * 4 + 2], cs
    sti 
    
    mov byte [music_on], 1

.done_setup:
    pop es
    popa
    ret

cleanup_music:
    pusha
    push es
    
    cmp byte [music_on], 0
    je .done_cleanup

    in al, 61h
    and al, 0FCh
    out 61h, al

    xor ax, ax
    mov es, ax
    cli
    mov ax, [old_int1c_off]
    mov [es:1Ch * 4], ax
    mov ax, [old_int1c_seg]
    mov [es:1Ch * 4 + 2], ax
    sti

    mov byte [music_on], 0

.done_cleanup:
    pop es
    popa
    ret

new_timer_isr:
    pusha           
    push ds         
    push es
    
    push cs         
    pop ds

    dec word [music_tick]
    jnz .play_current       

    mov si, [music_idx]
    
    mov bx, [music_notes + si]
    
    mov cx, [music_durations + si]
    mov [music_tick], cx
    
    cmp bx, 0
    je .silence
    
    mov al, 0B6h
    out 43h, al
    mov ax, bx
    out 42h, al
    mov al, ah
    out 42h, al
    
    in al, 61h
    or al, 3
    out 61h, al
    jmp .next_note

.silence:
    in al, 61h
    and al, 0FCh
    out 61h, al

.next_note:
    add word [music_idx], 2
    cmp word [music_idx], music_len * 2
    jl .play_current
    mov word [music_idx], 0  

.play_current:
    pop es
    pop ds
    popa
    
    pushf
    call far [cs:old_int1c_off] 
    iret

; =================================================================
; PROCEDURES (ORIGINAL GAME)
; =================================================================

waitKeyWithGlobalEsc:
    mov ah, 00h
    int 16h
    cmp al, 27 ; ESC
    je .confirm_exit
    ret
.confirm_exit:
    call showGlobalConfirm
    ret

showGlobalConfirm:
    mov cx, 80
    mov dx, 80
    mov al, 4 
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
    
    push cs
    pop es
    mov bp, txtConfirm
    mov cx, 23 
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
    ret

getStringInput:
    mov cx, 0 
.input_loop:
    mov ah, 02h
    mov bh, 00h
    int 10h
    
    mov ah, 00h
    int 16h
    
    cmp al, 27
    je .trigger_esc
    
    cmp al, 13  
    je .input_done
    
    cmp al, 8   
    je .handle_backspace
    
    cmp cx, 14  
    jge .input_loop
    
    mov [di], al
    inc di
    inc cx
    inc dl      
    
    mov ah, 0Eh
    mov bl, 15
    int 10h
    jmp .input_loop

.trigger_esc:
    call showGlobalConfirm
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

showEndScreen:
    mov ax, 0A000h
    mov es, ax

    call intro_clear_screen
    call intro_draw_stars

    mov ax, 60        
    mov bx, 50        
    mov cx, 200       
    mov dx, 2         
    mov di, 03h       
    call intro_draw_rect_fill

    mov bp, txtGameOverBox
    mov cx, 9
    mov bl, 0Eh       
    mov dh, 5         
    mov dl, 15        
    call printString

    cmp byte [gameOverReason], 0
    je ES_ReasonFuel
    cmp byte [gameOverReason], 1
    je ES_ReasonQuit
    
    mov bp, txtReasonCrash
    mov cx, 20 
    jmp ES_PrintReason
    
ES_ReasonFuel:
    mov bp, txtReasonFuel
    mov cx, 20
    jmp ES_PrintReason
    
ES_ReasonQuit:
    mov bp, txtReasonQuit
    mov cx, 17        

ES_PrintReason:
    mov bl, 15        
    mov dh, 8         
    mov dl, 8         
    call printString

    mov di, playerName
    xor cx, cx        
    
ES_CalcNameLen:
    cmp byte [di], '$'
    je ES_CheckName
    inc cx
    inc di
    jmp ES_CalcNameLen

ES_CheckName:
    cmp cx, 0
    je ES_RollLogic  
    
    mov bp, playerName
    mov dh, 11        
    mov dl, 11        
    call printString
    
ES_RollLogic:
    mov di, playerRoll
    xor cx, cx        
    
ES_CalcRollLen:
    cmp byte [di], '$'
    je ES_CheckRoll
    inc cx
    inc di
    jmp ES_CalcRollLen

ES_CheckRoll:
    cmp cx, 0
    je ES_ScoreLogic 
    
    mov bp, playerRoll
    mov dh, 11        
    mov dl, 19       
    call printString

ES_ScoreLogic:
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

    mov bp, txtRestartMsg
    mov cx, 25
    mov bl, 0Ah       
    mov dh, 18
    mov dl, 7
    call printString

ES_WaitLoop:
    mov ah, 00h
    int 16h
    cmp al, 32        
    je ES_DoRestart
    cmp al, 27        
    je ES_DoExit
    jmp ES_WaitLoop

ES_DoRestart:
    ret              
ES_DoExit:
    jmp exitGame     


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

printString:
    push es         
    push cs
    pop es          
    mov ax, 1301h       
    mov bh, 00h
    int 10h
    pop es          
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
    
    mov cx, 98        
    mov dx, 78        
    mov al, 3         
PauseBox_OuterY:
    push cx
PauseBox_OuterX:
    mov ah, 0Ch
    int 10h
    inc cx
    cmp cx, 222       
    jl PauseBox_OuterX
    pop cx
    inc dx
    cmp dx, 112       
    jl PauseBox_OuterY

    mov cx, 100       
    mov dx, 80        
    mov al, 0         
PauseBox_InnerY:
    push cx
PauseBox_InnerX:
    mov ah, 0Ch
    int 10h
    inc cx
    cmp cx, 220       
    jl PauseBox_InnerX
    pop cx
    inc dx
    cmp dx, 110       
    jl PauseBox_InnerY

    push cs
    pop es
    mov bp, pauseMsg
    mov cx, 11
    mov bl, 0Eh       
    mov dh, 12        
    mov dl, 14        
    call printString
    
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
    
    cmp al, 27        
    je PauseBox_Resume
    
    jmp PauseBox_Wait

PauseBox_Quit:
    popa
    mov byte [gameOverReason], 1 
    call triggerGameOver
    ret

PauseBox_Resume:
    
    mov cx, 98        
    mov dx, 78        
    mov al, 8         

EraseBox_Y:
    push cx
EraseBox_X:
    mov ah, 0Ch
    int 10h
    inc cx
    cmp cx, 222       
    jl EraseBox_X
    pop cx
    inc dx
    cmp dx, 112       
    jl EraseBox_Y

    popa
    mov byte [isPaused], 0 
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
    mov byte [gameOverReason], 1 
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
    
    ; [FIX] INCREASED SPAWN RATE (Changed from 4 to 2)
    inc byte [fuelSpawnTimer]
    cmp byte [fuelSpawnTimer], 2 
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
    mov byte [gameOverReason], 0 
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
    ; --- OBSTACLE 1 CHECK ---
    cmp byte [obstacle1Active], 1
    jne .chk_obs2
    mov al, [obstacle1Row]
    mov bl, [playerRow]
    sub al, bl              ; al = obstacleRow - playerRow
    
    ; Check Vertical Overlap (Height approx 3-4 units)
    cmp al, -3
    jl .chk_obs2            ; Obstacle too high above player
    cmp al, 3
    jg .chk_obs2            ; Obstacle too low below player (already passed)

    ; Check Horizontal Overlap (Width approx 4-5 units)
    mov al, [obstacle1Col]
    mov bl, [playerCol]
    sub al, bl
    cmp al, -4
    jl .chk_obs2
    cmp al, 4
    jg .chk_obs2
    
    ; COLLISION DETECTED
    mov byte [gameOverReason], 2 ; 2 = Crash
    
    ; *** SOUND CALL ***
    call playCrashSound
    
    call triggerGameOver
    ret

.chk_obs2:
    ; --- OBSTACLE 2 CHECK ---
    cmp byte [obstacle2Active], 1
    jne .chk_obs3
    mov al, [obstacle2Row]
    mov bl, [playerRow]
    sub al, bl
    cmp al, -3
    jl .chk_obs3
    cmp al, 3
    jg .chk_obs3

    mov al, [obstacle2Col]
    mov bl, [playerCol]
    sub al, bl
    cmp al, -4
    jl .chk_obs3
    cmp al, 4
    jg .chk_obs3

    mov byte [gameOverReason], 2
    
    ; *** SOUND CALL ***
    call playCrashSound
    
    call triggerGameOver
    ret

.chk_obs3:
    ; --- OBSTACLE 3 CHECK ---
    cmp byte [obstacle3Active], 1
    jne .chk_coins_start
    mov al, [obstacle3Row]
    mov bl, [playerRow]
    sub al, bl
    cmp al, -3
    jl .chk_coins_start
    cmp al, 3
    jg .chk_coins_start

    mov al, [obstacle3Col]
    mov bl, [playerCol]
    sub al, bl
    cmp al, -4
    jl .chk_coins_start
    cmp al, 4
    jg .chk_coins_start

    mov byte [gameOverReason], 2
    
    ; *** SOUND CALL ***
    call playCrashSound
    
    call triggerGameOver
    ret

.chk_coins_start:
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
    
    ; COIN 1 COLLECTED
    mov byte [coin1Active], 0
    mov al, [coin1Row]
    mov bl, [coin1Col]
    call clearCoin
    add word [score], 10
    inc word [coinCount]
    
    ; *** PLAY PICKUP SOUND ***
    call playFuelSound

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
    
    ; COIN 2 COLLECTED
    mov byte [coin2Active], 0
    mov al, [coin2Row]
    mov bl, [coin2Col]
    call clearCoin
    add word [score], 10
    inc word [coinCount]
    
    ; *** PLAY PICKUP SOUND ***
    call playFuelSound

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
    
    ; FUEL COLLECTED
    mov byte [fuelCanActive], 0
    mov al, [fuelCanRow]
    mov bl, [fuelCanCol]
    call clearFuelCan
    add word [fuelLevel], 900
    mov ax, [fuelMax]
    cmp [fuelLevel], ax
    jle .doSound
    mov [fuelLevel], ax

.doSound:
    ; *** PLAY PICKUP SOUND ***
    call playFuelSound

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
    
    ; Draw Handle (White - 15, Fixed visibility)
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
    mov al, 15  ; White (Visible on Grey road)
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

; =================================================================
; [NEW] CRASH SOUND EFFECT (Fixed to be louder/slower)
; =================================================================
playCrashSound:
    pusha
    
    ; 1. Stop background music interrupt first
    call cleanup_music

    ; 2. Generate "Noise" by random frequency switching
    mov cx, 100      ; Loop 100 times for duration
    
.noise_loop:
    push cx
    
    ; Pseudo-random freq based on CX
    mov ax, cx
    mov bl, 5
    mul bl
    add ax, 500
    mov bx, ax       ; Freq
    
    ; Send Freq
    mov al, 0B6h
    out 43h, al
    mov ax, bx
    out 42h, al
    mov al, ah
    out 42h, al
    
    ; Speaker ON
    in al, 61h
    or al, 3
    out 61h, al
    
    ; HEAVY DELAY so you can hear it
    mov cx, 4000
.waste_time:
    loop .waste_time
    
    ; Speaker OFF (creates choppy noise effect)
    in al, 61h
    and al, 0FCh
    out 61h, al
    
    pop cx
    loop .noise_loop

    popa
    ret

; =================================================================
; [NEW] FUEL/COIN SOUND EFFECT (Power Up)
; =================================================================
playFuelSound:
    pusha

    ; 1. Disable interrupts so background music doesn't fight us
    cli

    ; 2. Sound Logic: High pitched sweep up
    ; Start Freq Divisor: 2000 (High pitch)
    ; End Freq Divisor: 1000 (Very High pitch)
    mov bx, 2000    ; Starting Divisor

.sweep_loop:
    ; Send frequency to PIT
    mov al, 0B6h
    out 43h, al
    mov ax, bx
    out 42h, al
    mov al, ah
    out 42h, al

    ; Turn Speaker ON
    in al, 61h
    or al, 3
    out 61h, al

    ; Short Delay (duration of this pitch)
    mov cx, 5000     ; Very short wait
.wait:
    loop .wait

    ; Change Pitch (Decrease divisor = Higher Pitch)
    sub bx, 100      ; Step size
    cmp bx, 1000    ; Limit
    jg .sweep_loop

    ; 3. Turn Speaker OFF immediately
    in al, 61h
    and al, 0FCh
    out 61h, al

    ; 4. Re-enable interrupts (Music resumes automatically)
    sti

    popa
    ret