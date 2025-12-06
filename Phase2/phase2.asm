
org 100h
section .data
    playerRow   db 20
    playerCol   db 36
    
    ; Obstacle array - 5 obstacles max (ALL START INACTIVE)
    obstacle1Row db 0
    obstacle1Col db 37
    obstacle1Active db 0
    
    obstacle2Row db 0
    obstacle2Col db 37
    obstacle2Active db 0
    
    obstacle3Row db 0
    obstacle3Col db 37
    obstacle3Active db 0
    
    ; Coins and fuel (columns adjusted to stay on road)
    coin1Row     db 5
    coin1Col     db 21
    coin1Active  db 1
    
    coin2Row     db 8
    coin2Col     db 37
    coin2Active  db 1
    
    fuel1Row     db 12
    fuel1Col     db 53
    fuel1Active  db 1
    
    fuel2Row     db 18
    fuel2Col     db 21
    fuel2Active  db 1
    
    ; Animation variables
    roadOffset   dw 0
    lastSecond   db 0
    lastMinute   db 0
    spawnCounter db 0
    frameCounter db 0
    score        dw 0
    backgroundDrawn db 0
    
section .text
start:
    mov ax, 0013h
    int 10h
    
    ; Draw static background once
    call drawBackground
    mov byte [backgroundDrawn], 1
    
    ; Initialize timer
    call initTimer
    
    ; Main game loop
gameLoop:
    call checkTimer
    call checkCollisions  ; NEW: Check for collisions with coins and fuel
    call drawCoins
    call drawFuel
    call drawAllObstacles
    call drawPlayerCar
    call waitRetrace  ; Wait for vertical retrace to prevent flicker
    
    ; Check for keyboard input (non-blocking)
    mov ah, 01h
    int 16h
    jz gameLoop
    
    mov ah, 00h
    int 16h
    cmp al, 27  ; ESC
    je exitGame
    jmp gameLoop
    
exitGame:
    mov ax, 0003h
    int 10h
    mov ax, 4C00h
    int 21h

; NEW: Check collisions between player car and coins/fuel
checkCollisions:
    ; Check coin 1
    cmp byte [coin1Active], 1
    jne .checkCoin2
    
    mov al, [coin1Row]
    mov bl, [playerRow]
    sub al, bl
    ; Check if row difference is within collision range (0-3 rows)
    cmp al, 0
    jl .checkCoin2
    cmp al, 3
    jg .checkCoin2
    
    ; Check column collision
    mov al, [coin1Col]
    mov bl, [playerCol]
    sub al, bl
    ; Check if column difference is within range (-4 to +4)
    cmp al, -4
    jl .checkCoin2
    cmp al, 4
    jg .checkCoin2
    
    ; Collision detected! Deactivate coin
    mov byte [coin1Active], 0
    mov al, [coin1Row]
    mov bl, [coin1Col]
    call clearCoin
    add word [score], 10  ; Add bonus score
    
.checkCoin2:
    cmp byte [coin2Active], 1
    jne .checkFuel1
    
    mov al, [coin2Row]
    mov bl, [playerRow]
    sub al, bl
    cmp al, 0
    jl .checkFuel1
    cmp al, 3
    jg .checkFuel1
    
    mov al, [coin2Col]
    mov bl, [playerCol]
    sub al, bl
    cmp al, -4
    jl .checkFuel1
    cmp al, 4
    jg .checkFuel1
    
    mov byte [coin2Active], 0
    mov al, [coin2Row]
    mov bl, [coin2Col]
    call clearCoin
    add word [score], 10
    
.checkFuel1:
    cmp byte [fuel1Active], 1
    jne .checkFuel2
    
    mov al, [fuel1Row]
    mov bl, [playerRow]
    sub al, bl
    cmp al, 0
    jl .checkFuel2
    cmp al, 3
    jg .checkFuel2
    
    mov al, [fuel1Col]
    mov bl, [playerCol]
    sub al, bl
    cmp al, -4
    jl .checkFuel2
    cmp al, 4
    jg .checkFuel2
    
    mov byte [fuel1Active], 0
    mov al, [fuel1Row]
    mov bl, [fuel1Col]
    call clearFuel
    add word [score], 20
    
.checkFuel2:
    cmp byte [fuel2Active], 1
    jne .done
    
    mov al, [fuel2Row]
    mov bl, [playerRow]
    sub al, bl
    cmp al, 0
    jl .done
    cmp al, 3
    jg .done
    
    mov al, [fuel2Col]
    mov bl, [playerCol]
    sub al, bl
    cmp al, -4
    jl .done
    cmp al, 4
    jg .done
    
    mov byte [fuel2Active], 0
    mov al, [fuel2Row]
    mov bl, [fuel2Col]
    call clearFuel
    add word [score], 20
    
.done:
    ret

initTimer:
    ; Get current second (BCD format)
    mov al, 00h
    out 70h, al
    nop
    in al, 71h
    mov [lastSecond], al
    
    ; Get current minute (BCD format)
    mov al, 02h
    out 70h, al
    nop
    in al, 71h
    mov [lastMinute], al
    ret

checkTimer:
    ; Get current second (BCD format)
    mov al, 00h
    out 70h, al
    nop
    in al, 71h
    
    ; Compare with last second
    cmp al, [lastSecond]
    je .checkFrame
    
    ; Second changed
    mov [lastSecond], al
    
    ; Increment road offset (faster animation - 3 units per second)
    add word [roadOffset], 3
    
    ; Update lane markers animation
    call updateLaneMarkers
    
    ; Spawn obstacles every 2 seconds
    inc byte [spawnCounter]
    cmp byte [spawnCounter], 3  ; Changed to 3 seconds for MORE DELAY
    jl .skipSpawn
    mov byte [spawnCounter], 0
    call spawnNewObstacle
.skipSpawn:
    
    ; Move all obstacles down (3 rows per second for faster movement)
    call moveObstacles
    call moveObstacles
    call moveObstacles
    
    ; Move coins down
    call moveCoins
    call moveCoins
    
    ; Move fuel down
    call moveFuel
    call moveFuel
    
    ; Increment score
    inc word [score]
    jmp .done
    
.checkFrame:
    ; Additional frame-based updates for smoother animation
    inc byte [frameCounter]
    cmp byte [frameCounter], 30
    jl .done
    mov byte [frameCounter], 0
    
    ; Update lane markers more frequently
    inc word [roadOffset]
    call updateLaneMarkers
    
.done:
    ret

waitRetrace:
    ; Wait for vertical retrace to reduce flicker
    mov dx, 03DAh
.wait1:
    in al, dx
    test al, 8
    jnz .wait1
.wait2:
    in al, dx
    test al, 8
    jz .wait2
    ret

spawnNewObstacle:
    ; CRITICAL: NEVER spawn in center lane (37)
    ; Get random lane (left=21 or right=53 ONLY)
    call getRandomLane
    mov bl, al  ; Save random lane in bl
    
    ; FORCE: If center lane, switch to left
    cmp bl, 37
    jne .notCenter
    mov bl, 21  ; Force to left lane
    
.notCenter:
    ; Additional safety: If somehow still center, abort
    cmp bl, 37
    je .abort
    
    ; Now check if same as player (secondary check)
    mov al, [playerCol]
    cmp bl, al
    jne .differentLane
    
    ; Same as player! Switch to the other non-center lane
    cmp bl, 21
    je .switchToRight
    ; Must be 53, switch to left
    mov bl, 21
    jmp .differentLane
    
.switchToRight:
    mov bl, 53
    
.differentLane:
    ; Triple-check: ensure NOT center lane
    cmp bl, 37
    je .abort
    
    ; VALIDATE: Make sure column is valid (21 or 53 ONLY)
    cmp bl, 21
    je .validLane
    cmp bl, 53
    je .validLane
.abort:
    ; Invalid lane or same as player, don't spawn
    ret
    
.validLane:
    ; Check if ANY obstacle is in top 12 rows (need big gap)
    cmp byte [obstacle1Active], 1
    jne .checkSlot1
    mov al, [obstacle1Row]
    cmp al, 12
    jl .abort  ; Too close, abort
    
    cmp byte [obstacle2Active], 1
    jne .checkSlot1
    mov al, [obstacle2Row]
    cmp al, 12
    jl .abort  ; Too close, abort
    
    cmp byte [obstacle3Active], 1
    jne .checkSlot1
    mov al, [obstacle3Row]
    cmp al, 12
    jl .abort  ; Too close, abort
    
.checkSlot1:
    ; Try to spawn in obstacle1
    cmp byte [obstacle1Active], 0
    jne .try2
    mov byte [obstacle1Active], 1
    mov byte [obstacle1Row], 0
    mov [obstacle1Col], bl
    ret
    
.try2:
    cmp byte [obstacle2Active], 0
    jne .try3
    
    ; Check LARGE distance from obstacle1 (minimum 12 rows gap)
    mov al, [obstacle1Row]
    cmp al, 12
    jl .done  ; Too close to obstacle1
    
    ; Make sure obstacle1 is not in same lane
    mov al, [obstacle1Col]
    cmp al, bl
    je .done  ; Same lane as obstacle1
    
    mov byte [obstacle2Active], 1
    mov byte [obstacle2Row], 0
    mov [obstacle2Col], bl
    ret
    
.try3:
    cmp byte [obstacle3Active], 0
    jne .done
    
    ; Check LARGE distance from obstacle1 and obstacle2 (minimum 12 rows)
    mov al, [obstacle1Row]
    cmp al, 12
    jl .done
    mov al, [obstacle2Row]
    cmp al, 12
    jl .done
    
    ; Make sure not in same lane as other obstacles
    mov al, [obstacle1Col]
    cmp al, bl
    je .done
    mov al, [obstacle2Col]
    cmp al, bl
    je .done
    
    mov byte [obstacle3Active], 1
    mov byte [obstacle3Row], 0
    mov [obstacle3Col], bl
.done:
    ret

getRandomLane:
    mov ah, 2Ch
    int 21h
    mov al, dh
    xor ah, ah
    mov cl, 2  ; Changed to 2 for only 2 lanes (left and right)
    div cl
    cmp ah, 0
    je .l0
    ; ah is 1, so right lane
    mov al, 53  ; Right lane
    ret
.l0:
    mov al, 21  ; Left lane
    ret
.l1:
    ; This should never be reached now
    mov al, 21  ; Safety: default to left
    ret

moveObstacles:
    ; Move obstacle 1
    cmp byte [obstacle1Active], 1
    jne .check2
    
    ; VALIDATE position before clearing
    mov al, [obstacle1Col]
    cmp al, 21
    je .validCol1
    cmp al, 37
    je .validCol1
    cmp al, 53
    je .validCol1
    ; Invalid position - deactivate and skip
    mov byte [obstacle1Active], 0
    jmp .check2
    
.validCol1:
    ; Clear old position
    mov al, [obstacle1Row]
    mov [obstacleRow], al
    mov al, [obstacle1Col]
    mov [obstacleCol], al
    call clearObstacleCar
    
    ; Update position
    mov al, [obstacle1Row]
    inc al
    cmp al, 25
    jl .update1
    mov byte [obstacle1Active], 0
    jmp .check2
.update1:
    mov [obstacle1Row], al
    
.check2:
    ; Move obstacle 2
    cmp byte [obstacle2Active], 1
    jne .check3
    
    ; VALIDATE position before clearing
    mov al, [obstacle2Col]
    cmp al, 21
    je .validCol2
    cmp al, 37
    je .validCol2
    cmp al, 53
    je .validCol2
    ; Invalid position - deactivate and skip
    mov byte [obstacle2Active], 0
    jmp .check3
    
.validCol2:
    ; Clear old position
    mov al, [obstacle2Row]
    mov [obstacleRow], al
    mov al, [obstacle2Col]
    mov [obstacleCol], al
    call clearObstacleCar
    
    ; Update position
    mov al, [obstacle2Row]
    inc al
    cmp al, 25
    jl .update2
    mov byte [obstacle2Active], 0
    jmp .check3
.update2:
    mov [obstacle2Row], al
    
.check3:
    ; Move obstacle 3
    cmp byte [obstacle3Active], 1
    jne .done
    
    ; VALIDATE position before clearing
    mov al, [obstacle3Col]
    cmp al, 21
    je .validCol3
    cmp al, 37
    je .validCol3
    cmp al, 53
    je .validCol3
    ; Invalid position - deactivate and skip
    mov byte [obstacle3Active], 0
    ret
    
.validCol3:
    ; Clear old position
    mov al, [obstacle3Row]
    mov [obstacleRow], al
    mov al, [obstacle3Col]
    mov [obstacleCol], al
    call clearObstacleCar
    
    ; Update position
    mov al, [obstacle3Row]
    inc al
    cmp al, 25
    jl .update3
    mov byte [obstacle3Active], 0
    ret
.update3:
    mov [obstacle3Row], al
.done:
    ret

moveCoins:
    ; Move coin 1
    cmp byte [coin1Active], 1
    jne .check2
    
    ; Clear old position
    mov al, [coin1Row]
    mov bl, [coin1Col]
    call clearCoin
    
    mov al, [coin1Row]
    inc al
    cmp al, 25
    jl .update1
    ; Respawn at top
    mov byte [coin1Row], 2
    call getRandomLane
    mov [coin1Col], al
    mov byte [coin1Active], 1  ; Reactivate
    jmp .check2
.update1:
    mov [coin1Row], al
    
.check2:
    ; Move coin 2
    cmp byte [coin2Active], 1
    jne .done
    
    ; Clear old position
    mov al, [coin2Row]
    mov bl, [coin2Col]
    call clearCoin
    
    mov al, [coin2Row]
    inc al
    cmp al, 25
    jl .update2
    ; Respawn at top
    mov byte [coin2Row], 2
    call getRandomLane
    mov [coin2Col], al
    mov byte [coin2Active], 1  ; Reactivate
    ret
.update2:
    mov [coin2Row], al
.done:
    ret

moveFuel:
    ; Move fuel 1
    cmp byte [fuel1Active], 1
    jne .check2
    
    ; Clear old position
    mov al, [fuel1Row]
    mov bl, [fuel1Col]
    call clearFuel
    
    mov al, [fuel1Row]
    inc al
    cmp al, 25
    jl .update1
    ; Respawn at top
    mov byte [fuel1Row], 2
    call getRandomLane
    mov [fuel1Col], al
    mov byte [fuel1Active], 1  ; Reactivate
    jmp .check2
.update1:
    mov [fuel1Row], al
    
.check2:
    ; Move fuel 2
    cmp byte [fuel2Active], 1
    jne .done
    
    ; Clear old position
    mov al, [fuel2Row]
    mov bl, [fuel2Col]
    call clearFuel
    
    mov al, [fuel2Row]
    inc al
    cmp al, 25
    jl .update2
    ; Respawn at top
    mov byte [fuel2Row], 2
    call getRandomLane
    mov [fuel2Col], al
    mov byte [fuel2Active], 1  ; Reactivate
    ret
.update2:
    mov [fuel2Row], al
.done:
    ret


clearCoin:
    ; al = row, bl = col
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
.loop:
    cmp bx, 8
    jge .done
    mov ax, dx
    add ax, bx
    push dx
    mov dx, 320
    mul dx
    pop dx
    add ax, si
    add ax, 4
    mov di, ax
    
    mov al, 8  ; Road color
    mov cx, 8
    rep stosb
    inc bx
    jmp .loop
.done:
    pop bx
    pop ax
    ret

clearFuel:
    ; al = row, bl = col
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
.loop:
    cmp bx, 10
    jge .done
    mov ax, dx
    add ax, bx
    push dx
    mov dx, 320
    mul dx
    pop dx
    add ax, si
    add ax, 4
    mov di, ax
    
    mov al, 8  ; Road color
    mov cx, 8
    rep stosb
    inc bx
    jmp .loop
.done:
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
.carLoop:
    cmp bx, 24
    jge .done
    mov ax, dx
    add ax, bx
    push dx
    mov dx, 320
    mul dx
    pop dx
    add ax, si
    mov di, ax
    
    mov al, 8  ; Road color
    mov cx, 16
    rep stosb
    inc bx
    jmp .carLoop
.done:
    ret

drawBackground:
    mov ax, 0A000h
    mov es, ax
    xor cx, cx
.rowLoop:
    push cx
    mov ax, cx
    mov dx, 320
    mul dx
    mov di, ax
    
    ; Left grass - alternating pattern
    mov ax, cx
    shr ax, 1
    and ax, 1
    test ax, ax
    jnz .lgLight
    mov cx, 60
    mov al, 2
    rep stosb
    jmp .lgDone
.lgLight:
    mov cx, 60
    mov al, 10
    rep stosb
.lgDone:
    
    pop cx
    push cx
    
    ; Left shoulder - alternating yellow/black
    mov ax, cx
    shr ax, 1
    and ax, 1
    test ax, ax
    jnz .lsLight
    mov al, 0
    stosb
    mov al, 0
    stosb
    mov al, 14
    stosb
    mov al, 14
    stosb
    jmp .lsDone
.lsLight:
    mov al, 14
    stosb
    mov al, 14
    stosb
    mov al, 0
    stosb
    mov al, 0
    stosb
.lsDone:
    
    ; Road (solid gray)
    mov cx, 192
    mov al, 8
    rep stosb
    
    pop cx
    push cx
    
    ; Right shoulder - alternating yellow/black
    mov ax, cx
    shr ax, 1
    and ax, 1
    test ax, ax
    jnz .rsLight
    mov al, 0
    stosb
    mov al, 0
    stosb
    mov al, 14
    stosb
    mov al, 14
    stosb
    jmp .rsDone
.rsLight:
    mov al, 14
    stosb
    mov al, 14
    stosb
    mov al, 0
    stosb
    mov al, 0
    stosb
.rsDone:
    
    pop cx
    push cx
    
    ; Right grass - alternating pattern
    mov ax, cx
    shr ax, 1
    and ax, 1
    test ax, ax
    jnz .rgLight
    mov cx, 60
    mov al, 2
    rep stosb
    jmp .rgDone
.rgLight:
    mov cx, 60
    mov al, 10
    rep stosb
.rgDone:
    
    pop cx
    inc cx
    cmp cx, 200
    jl .rowLoop
    
    ; Draw initial lane markers
    call updateLaneMarkers
    ret

updateLaneMarkers:
    mov ax, 0A000h
    mov es, ax
    
    mov ax, [roadOffset]
    and ax, 0Fh
    mov dx, ax
    
    xor cx, cx
.laneLoop:
    push cx
    mov ax, cx
    add ax, dx
    and ax, 0Fh
    cmp ax, 10
    jge .clearMarker
    
    ; Draw marker
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
    jmp .skip
    
.clearMarker:
    ; Clear marker with road color
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
    
.skip:
    pop cx
    inc cx
    cmp cx, 200
    jl .laneLoop
    ret

drawAllObstacles:
    ; Draw obstacle 1 - ONLY if active AND on valid road position
    cmp byte [obstacle1Active], 1
    jne .skip1
    mov al, [obstacle1Col]
    cmp al, 21  ; Check if in left lane
    je .draw1
    cmp al, 37  ; Check if in middle lane
    je .draw1
    cmp al, 53  ; Check if in right lane
    je .draw1
    ; Invalid position, deactivate it
    mov byte [obstacle1Active], 0
    jmp .skip1
.draw1:
    mov al, [obstacle1Row]
    mov [obstacleRow], al
    mov al, [obstacle1Col]
    mov [obstacleCol], al
    call drawObstacleCar
.skip1:
    
    ; Draw obstacle 2 - ONLY if active AND on valid road position
    cmp byte [obstacle2Active], 1
    jne .skip2
    mov al, [obstacle2Col]
    cmp al, 21
    je .draw2
    cmp al, 37
    je .draw2
    cmp al, 53
    je .draw2
    ; Invalid position, deactivate it
    mov byte [obstacle2Active], 0
    jmp .skip2
.draw2:
    mov al, [obstacle2Row]
    mov [obstacleRow], al
    mov al, [obstacle2Col]
    mov [obstacleCol], al
    call drawObstacleCar
.skip2:
    
    ; Draw obstacle 3 - ONLY if active AND on valid road position
    cmp byte [obstacle3Active], 1
    jne .skip3
    mov al, [obstacle3Col]
    cmp al, 21
    je .draw3
    cmp al, 37
    je .draw3
    cmp al, 53
    je .draw3
    ; Invalid position, deactivate it
    mov byte [obstacle3Active], 0
    jmp .skip3
.draw3:
    mov al, [obstacle3Row]
    mov [obstacleRow], al
    mov al, [obstacle3Col]
    mov [obstacleCol], al
    call drawObstacleCar
.skip3:
    ret

obstacleRow db 0
obstacleCol db 0

drawCoins:
    ; Draw coin 1
    cmp byte [coin1Active], 0
    je .skip1
    mov al, [coin1Row]
    mov bl, [coin1Col]
    call drawPrettyCoin
.skip1:
    
    ; Draw coin 2
    cmp byte [coin2Active], 0
    je .done
    mov al, [coin2Row]
    mov bl, [coin2Col]
    call drawPrettyCoin
.done:
    ret

; NEW: Draw pretty yellow coin with enhanced design
drawPrettyCoin:
    ; al = row, bl = col
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
.coinLoop:
    cmp bx, 8
    jge .done
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
    je .row0
    cmp bx, 1
    je .row1
    cmp bx, 6
    je .row6
    cmp bx, 7
    je .row7
    
    ; Rows 2-5: Full coin with shine effect
    mov al, 15  ; White shine on left
    stosb
    mov al, 14  ; Bright yellow
    mov cx, 6
    rep stosb
    mov al, 6   ; Brown edge on right
    stosb
    inc bx
    jmp .coinLoop
    
.row0:
.row7:
    ; Top and bottom: rounded edges
    mov al, 8   ; Road color
    stosb
    stosb
    mov al, 14  ; Yellow
    mov cx, 4
    rep stosb
    mov al, 8
    stosb
    stosb
    inc bx
    jmp .coinLoop
    
.row1:
.row6:
    ; Near top/bottom: wider
    mov al, 8
    stosb
    mov al, 14  ; Yellow
    mov cx, 6
    rep stosb
    mov al, 8
    stosb
    inc bx
    jmp .coinLoop
    
.done:
    pop bx
    pop ax
    ret

drawFuel:
    ; Draw fuel 1
    cmp byte [fuel1Active], 0
    je .skip1
    mov al, [fuel1Row]
    mov bl, [fuel1Col]
    call drawFuelCan
.skip1:
    
    ; Draw fuel 2
    cmp byte [fuel2Active], 0
    je .done
    mov al, [fuel2Row]
    mov bl, [fuel2Col]
    call drawFuelCan
.done:
    ret

; IMPROVED: Enhanced fuel can design
drawFuelCan:
    ; al = row, bl = col
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
.fuelLoop:
    cmp bx, 10
    jge .done
    mov ax, dx
    add ax, bx
    push dx
    mov dx, 320
    mul dx
    pop dx
    add ax, si
    add ax, 4
    mov di, ax
    
    ; Row 0-1: Cap (yellow)
    cmp bx, 0
    je .capRow
    cmp bx, 1
    je .capRow
    ; Row 2: Neck (dark red)
    cmp bx, 2
    je .neckRow
    ; Row 3-8: Body (red with highlight)
    cmp bx, 3
    jge .bodyStart
    
.capRow:
    add di, 2
    mov al, 14  ; Yellow cap
    mov cx, 4
    rep stosb
    inc bx
    jmp .fuelLoop
    
.neckRow:
    add di, 2
    mov al, 4  ; Dark red
    mov cx, 4
    rep stosb
    inc bx
    jmp .fuelLoop
    
.bodyStart:
    cmp bx, 9
    je .bottomRow
    
    ; Body with highlight on left side
    mov al, 12  ; Bright red
    stosb
    mov al, 4   ; Dark red (body)
    mov cx, 6
    rep stosb
    mov al, 12  ; Bright red
    stosb
    inc bx
    jmp .fuelLoop
    
.bottomRow:
    inc di
    mov al, 4  ; Dark red bottom
    mov cx, 6
    rep stosb
    inc bx
    jmp .fuelLoop
    
.done:
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
.carLoop:
    cmp bx, 24
    jge .done
    mov ax, dx
    add ax, bx
    push dx
    mov dx, 320
    mul dx
    pop dx
    add ax, si
    mov di, ax
    cmp bx, 4
    jl .front
    cmp bx, 8
    jl .windshield
    cmp bx, 18
    jl .body
    jmp .wheels
.front:
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
    jmp .carLoop
.windshield:
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
    jmp .carLoop
.body:
    mov al, 12
    stosb
    mov al, 4
    mov cx, 14
    rep stosb
    mov al, 12
    stosb
    inc bx
    jmp .carLoop
.wheels:
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
    jmp .carLoop
.done:
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
.carLoop:
    cmp bx, 24
    jge .done
    mov ax, dx
    add ax, bx
    push dx
    mov dx, 320
    mul dx
    pop dx
    add ax, si
    mov di, ax
    cmp bx, 4
    jl .front
    cmp bx, 8
    jl .windshield
    cmp bx, 18
    jl .body
    jmp .wheels
.front:
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
    jmp .carLoop
.windshield:
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
    jmp .carLoop
.body:
    mov al, 9
    stosb
    mov al, 1
    mov cx, 14
    rep stosb
    mov al, 9
    stosb
    inc bx
    jmp .carLoop
.wheels:
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
    jmp .carLoop
.done:
    ret