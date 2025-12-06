org 100h

section .data
    ; --- Global Variables (Must be at top) ---
    obstacleRow  db 0
    obstacleCol  db 0
    
    ; --- Player Variables ---
    playerRow    db 20
    playerCol    db 36
    
    ; --- Game State ---
    gameStarted  db 0
    isPaused     db 0

    ; --- Obstacle array ---
    obstacle1Row db 0
    obstacle1Col db 37
    obstacle1Active db 0
    
    obstacle2Row db 0
    obstacle2Col db 37
    obstacle2Active db 0
    
    obstacle3Row db 0
    obstacle3Col db 37
    obstacle3Active db 0
    
    ; --- Coins and Fuel ---
    coin1Row     db 5
    coin1Col     db 21
    coin1Active  db 1
    
    coin2Row     db 12
    coin2Col     db 53
    coin2Active  db 1
    
    fuel1Row     db 8
    fuel1Col     db 37
    fuel1Active  db 1
    
    fuel2Row     db 18
    fuel2Col     db 21
    fuel2Active  db 1
    
    ; --- Animation ---
    roadOffset   dw 0
    lastSecond   db 0
    lastMinute   db 0
    spawnCounter db 0
    frameCounter db 0
    score        dw 0
    
    ; --- Strings ---
    startMsg     db 'PRESS ANY KEY TO START$'
    pauseMsg     db 'QUIT? (y/n)$'

section .text
start:
    ; Set Video Mode 13h
    mov ax, 0013h
    int 10h
    
    call initTimer
    
    ; Initial Draw
    call drawBackground
    call drawCoins
    call drawFuel
    call drawPlayerCar
    
    ; --- Start Screen ---
    mov ah, 02h         ; Set cursor
    mov bh, 00h
    mov dh, 12          ; Row
    mov dl, 10          ; Column
    int 10h
    
    mov ah, 09h         ; Print String
    mov dx, startMsg
    int 21h
    
wait_for_start:
    mov ah, 00h         ; Wait for key
    int 16h
    
    call drawBackground
    mov byte [gameStarted], 1

    ; --- Main Game Loop ---
gameLoop:
    ; If paused, skip game logic, just check pause input
    cmp byte [isPaused], 1
    je .paused_state
    
    ; Normal Gameplay
    call checkTimer
    call checkInput
    call checkCollisions
    
    call drawCoins
    call drawFuel
    call drawAllObstacles
    call drawPlayerCar
    call fixTopRightGrass
    call waitRetrace
    
    jmp gameLoop

.paused_state:
    ; While paused, we only check for specific keys
    call checkPauseInput
    jmp gameLoop

exitGame:
    mov ax, 0003h       ; Text Mode
    int 10h
    mov ax, 4C00h       ; Exit
    int 21h

; ---------------------------------------------------------
; PAUSE MENU & LOGIC
; ---------------------------------------------------------
showPauseMenu:
    mov byte [isPaused], 1
    
    ; 1. Draw Blue Box (Software Interrupt INT 10h / AH=0Ch)
    ; Box coords: x=100 to 220, y=80 to 110
    mov cx, 100         ; Start X
    mov dx, 80          ; Start Y
    mov al, 1           ; Color Blue
    
.drawBoxRow:
    mov cx, 100         ; Reset X
.drawBoxCol:
    mov ah, 0Ch         ; Write Pixel
    int 10h
    inc cx
    cmp cx, 220
    jl .drawBoxCol
    
    inc dx
    cmp dx, 110
    jl .drawBoxRow

    ; 2. Print Text
    mov ah, 02h         ; Set cursor
    mov bh, 00h
    mov dh, 12          ; Row (approx middle)
    mov dl, 14          ; Column
    int 10h
    
    mov ah, 09h         ; DOS Print String
    mov dx, pauseMsg
    int 21h
    ret

checkPauseInput:
    mov ah, 00h         ; Blocking Wait (Game is paused anyway)
    int 16h
    
    cmp al, 'y'
    je .do_quit
    cmp al, 'Y'
    je .do_quit
    
    cmp al, 'n'
    je .do_resume
    cmp al, 'N'
    je .do_resume
    cmp al, 27          ; ESC to resume
    je .do_resume
    
    ret                 ; Ignore other keys

.do_quit:
    jmp exitGame

.do_resume:
    mov byte [isPaused], 0
    ; FIX: Force redraw of background to wipe the blue box
    call drawBackground
    ret

; ---------------------------------------------------------
; INPUT HANDLING (Normal Game)
; ---------------------------------------------------------
checkInput:
    mov ah, 01h         ; Check if key pressed
    int 16h
    jnz .has_key
    ret

.has_key:
    mov ah, 00h         ; Get key
    int 16h
    
    cmp al, 27          ; ESC pressed
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

; ---------------------------------------------------------
; GAME LOGIC
; ---------------------------------------------------------
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
.skipSpawn:
    
    call moveObstacles
    call moveCoins
    call moveFuel
    
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
    call moveFuel

.done:
    ret

spawnNewObstacle:
    mov ah, 2Ch
    int 21h
    mov al, dl
    and al, 1
    
    cmp al, 0
    je .lane1
    mov bl, 53      ; Right Lane
    jmp .checkSpace
.lane1:
    mov bl, 21      ; Left Lane

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

; --- MOVEMENT ---
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

moveFuel:
    cmp byte [fuel1Active], 1
    je .moveF1
    mov byte [fuel1Row], 0
    call getRandomLane
    mov [fuel1Col], al
    mov byte [fuel1Active], 1
    jmp .checkF2_tramp
.moveF1:
    mov al, [fuel1Row]
    mov bl, [fuel1Col]
    call clearFuel
    inc byte [fuel1Row]
    cmp byte [fuel1Row], 25
    jl .checkF2_tramp
    mov byte [fuel1Row], 0
    call getRandomLane
    mov [fuel1Col], al

.checkF2_tramp:
    jmp .checkF2

.checkF2:
    cmp byte [fuel2Active], 1
    je .moveF2
    mov byte [fuel2Row], 0
    call getRandomLane
    mov [fuel2Col], al
    mov byte [fuel2Active], 1
    ret
.moveF2:
    mov al, [fuel2Row]
    mov bl, [fuel2Col]
    call clearFuel
    inc byte [fuel2Row]
    cmp byte [fuel2Row], 25
    jl .doneF
    mov byte [fuel2Row], 0
    call getRandomLane
    mov [fuel2Col], al
.doneF:
    ret

; --- COLLISION DETECTION ---
checkCollisions:
    cmp byte [coin1Active], 1
    jne .ckCoin2_tramp
    
    mov al, [coin1Row]
    mov bl, [playerRow]
    sub al, bl
    cmp al, 0
    jl .ckCoin2_tramp
    cmp al, 3
    jg .ckCoin2_tramp
    
    mov al, [coin1Col]
    mov bl, [playerCol]
    sub al, bl
    cmp al, -4
    jl .ckCoin2_tramp
    cmp al, 4
    jg .ckCoin2_tramp
    
    mov byte [coin1Active], 0
    mov al, [coin1Row]
    mov bl, [coin1Col]
    call clearCoin
    add word [score], 10

.ckCoin2_tramp:
    jmp .ckCoin2

.ckCoin2:
    cmp byte [coin2Active], 1
    jne .ckFuel1_tramp
    mov al, [coin2Row]
    mov bl, [playerRow]
    sub al, bl
    cmp al, 0
    jl .ckFuel1_tramp
    cmp al, 3
    jg .ckFuel1_tramp
    mov al, [coin2Col]
    mov bl, [playerCol]
    sub al, bl
    cmp al, -4
    jl .ckFuel1_tramp
    cmp al, 4
    jg .ckFuel1_tramp
    mov byte [coin2Active], 0
    mov al, [coin2Row]
    mov bl, [coin2Col]
    call clearCoin
    add word [score], 10

.ckFuel1_tramp:
    jmp .ckFuel1

.ckFuel1:
    cmp byte [fuel1Active], 1
    jne .ckFuel2_tramp
    mov al, [fuel1Row]
    mov bl, [playerRow]
    sub al, bl
    cmp al, 0
    jl .ckFuel2_tramp
    cmp al, 3
    jg .ckFuel2_tramp
    mov al, [fuel1Col]
    mov bl, [playerCol]
    sub al, bl
    cmp al, -4
    jl .ckFuel2_tramp
    cmp al, 4
    jg .ckFuel2_tramp
    mov byte [fuel1Active], 0
    mov al, [fuel1Row]
    mov bl, [fuel1Col]
    call clearFuel
    add word [score], 20

.ckFuel2_tramp:
    jmp .ckFuel2

.ckFuel2:
    cmp byte [fuel2Active], 1
    jne .ckDone
    mov al, [fuel2Row]
    mov bl, [playerRow]
    sub al, bl
    cmp al, 0
    jl .ckDone
    cmp al, 3
    jg .ckDone
    mov al, [fuel2Col]
    mov bl, [playerCol]
    sub al, bl
    cmp al, -4
    jl .ckDone
    cmp al, 4
    jg .ckDone
    mov byte [fuel2Active], 0
    mov al, [fuel2Row]
    mov bl, [fuel2Col]
    call clearFuel
    add word [score], 20
.ckDone:
    ret

; --- UTILS & DRAWING ---

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

; FIXED: Matches background pattern (shr 1, and 1)
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

clearFuel:
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
    cmp bx, 10
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

drawFuel:
    cmp byte [fuel1Active], 0
    je .skF1
    mov al, [fuel1Row]
    mov bl, [fuel1Col]
    call drawFuelCan
.skF1:
    cmp byte [fuel2Active], 0
    je .dDF
    mov al, [fuel2Row]
    mov bl, [fuel2Col]
    call drawFuelCan
.dDF:
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
.fl:
    cmp bx, 10
    jge .fd
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
    je .cr
    cmp bx, 1
    je .cr
    cmp bx, 2
    je .nr
    cmp bx, 3
    jge .bs
.cr:
    add di, 2
    mov al, 14
    mov cx, 4
    rep stosb
    inc bx
    jmp .fl
.nr:
    add di, 2
    mov al, 4
    mov cx, 4
    rep stosb
    inc bx
    jmp .fl
.bs:
    cmp bx, 9
    je .br
    mov al, 12
    stosb
    mov al, 4
    mov cx, 6
    rep stosb
    mov al, 12
    stosb
    inc bx
    jmp .fl
.br:
    inc di
    mov al, 4
    mov cx, 6
    rep stosb
    inc bx
    jmp .fl
.fd:
    pop bx
    pop ax
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
