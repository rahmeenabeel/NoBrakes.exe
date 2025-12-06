; Racing Game Phase 1 - VGA Graphics Mode
; WINDSHIELDS = BLACK, SHORTER & NATURAL-LOOKING
; Compile: nasm -f bin rapt.asm -o rapt.com
; Run: dosbox rapt.com
org 100h
section .data
    playerRow   db 20
    playerCol   db 36
    obstacleRow db 5
    obstacleCol db 20
section .text
start:
    mov ax, 0013h
    int 10h
    call randomObstacle
    call drawBackground
    call drawPlayerCar
    call drawObstacleCar
    mov ah, 00h
    int 16h
    mov ax, 0003h
    int 10h
    mov ax, 4C00h
    int 21h

randomObstacle:
    mov ah, 2Ch
    int 21h
    mov al, dl
    mov ah, 0
    mov bl, 10
    div bl
    add ah, 3
    mov [obstacleRow], ah
    mov al, dl
    add al, dh
    mov ah, 0
    mov bl, 3
    div bl
    cmp ah, 0
    je .l0
    cmp ah, 1
    je .l1
    mov byte [obstacleCol], 52
    ret
.l0: mov byte [obstacleCol], 20
    ret
.l1: mov byte [obstacleCol], 36
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
    mov cx, 192
    mov al, 8
    rep stosb
    pop cx
    push cx
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
    xor cx, cx
.laneLoop:
    push cx
    mov ax, cx
    and ax, 0Fh
    cmp ax, 10
    jge .skip
    mov ax, cx
    mov dx, 320
    mul dx
    add ax, 119
    mov di, ax
    mov byte [es:di], 15
    mov byte [es:di+1], 8
    mov byte [es:di+2], 15
    mov ax, cx
    mov dx, 320
    mul dx
    add ax, 183
    mov di, ax
    mov byte [es:di], 15
    mov byte [es:di+1], 8
    mov byte [es:di+2], 15
.skip:
    pop cx
    inc cx
    cmp cx, 200
    jl .laneLoop
    ret

; RED CAR: BLACK WINDSHIELD (SHORTER = 10px, framed)
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
    mov al, 4          ; DARK RED frame
    mov cx, 3
    rep stosb
    mov al, 0          ; BLACK glass
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

; BLUE CAR: BLACK WINDSHIELD (SHORTER = 10px, framed)
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
    mov al, 1          ; DARK BLUE frame
    mov cx, 3
    rep stosb
    mov al, 0          ; BLACK glass
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