.686     
.model flat, stdcall
 ExitProcess PROTO STDCALL :DWORD
 includelib  kernel32.lib  ; ExitProcess 在 kernel32.lib中实现
 printf          PROTO C :VARARG
 includelib  libcmt.lib
 includelib  legacy_stdio_definitions.lib

.DATA
    lpmFt db '%s', 0
    hint db '数据溢出！', 0
    ;以下是一个数据结构，每个数据结构占6*4*4 = 22个字节
    ;SAMID   DB '000001' ;每组数据的流水号
    ;;以下都是有符号双字整形
    ;SDA DD  256809      ;状态信息a
    ;SDB DD  -1023       ;状态信息b
    ;SDC DD   1265       ;状态信息c
    ;SF  DD   0          ;处理结果f
    buf db  '000001'    ;占6个字节
        dd  256809, -1023, 1265, 0
        db  '000002'
        dd  112586, -1204, 1563, 0
        db  '000003'
        dd  3586, -12256, 2451, 0
        db  '000004'
        dd  2520, -600, -700, 0
        ;db  '000005'
        ;dd  354687, 2002, 3569, 0

    MIDF dd 110 dup(0)
    HIGHF dd 110 dup(0)
    LOWF dd 110 dup(0)
    ;chengshu dd 5
    cnt dd 5*22;存储数组上限，用于判断是否溢出
    chushu dd 128
.STACK 200
.CODE
main proc c
    mov ebx, 0  ;MIDF数组的下标（*22）
    mov ecx, 0  ;HIGHF数组的下标（*22）
    mov edx, 0  ;LOWF数组的下标（*22）
    mov esi, 0  ;buf数组的下标（*22）
    mov edi, 6  ;循环次数

R:
    mov eax, dword ptr buf[esi + 6]
    ;imul chengshu
    imul eax, 5
    ;mul eax, 5 ;无符号乘法 
    add eax, dword ptr buf[esi + 10]
    sub eax, dword ptr buf[esi + 14]
    add eax, 100
    sar eax, 7  ;除以128（算术右移操作，符号位保持不变）
    ;shr eax, 7（逻辑右移操作，当作无符号数除法）
    mov  dword ptr buf[esi + 18], eax
    cmp eax, 100
    jg G    ;如果大了
    jl L    ;如果小了 
    ;复制数据到MIDF
    mov eax, 0
    mov ax, word ptr buf[esi]
    mov word ptr MIDF[ebx], ax
    mov eax, dword ptr buf[esi + 2]
    mov dword ptr MIDF[ebx + 2], eax
    mov eax, dword ptr buf[esi + 6]
    mov dword ptr MIDF[ebx + 6], eax
    mov eax, dword ptr buf[esi + 10]
    mov dword ptr MIDF[ebx + 10], eax
    mov eax, dword ptr buf[esi + 14]
    mov dword ptr MIDF[ebx + 14], eax
    mov eax, dword ptr buf[esi + 18]
    mov dword ptr MIDF[ebx + 18], eax
    add ebx, 22
    jmp J
G:
    ;复制数据到HIGHF
    mov eax, 0
    mov ax, word ptr buf[esi]
    mov word ptr HIGHF[ecx], ax
    mov eax, dword ptr buf[esi + 2]
    mov dword ptr HIGHF[ecx + 2], eax
    mov eax, dword ptr buf[esi + 6]
    mov dword ptr HIGHF[ecx + 6], eax
    mov eax, dword ptr buf[esi + 10]
    mov dword ptr HIGHF[ecx + 10], eax
    mov eax, dword ptr buf[esi + 14]
    mov dword ptr HIGHF[ecx + 14], eax
    mov eax, dword ptr buf[esi + 18]
    mov dword ptr HIGHF[ecx + 18], eax
    add ecx, 22
    jmp J
L:
    ;复制数据到LOWF
    mov eax, 0
    mov ax, word ptr buf[esi]
    mov word ptr LOWF[edx], ax
    mov eax, dword ptr buf[esi + 2]
    mov dword ptr LOWF[edx + 2], eax
    mov eax, dword ptr buf[esi + 6]
    mov dword ptr LOWF[edx + 6], eax
    mov eax, dword ptr buf[esi + 10]
    mov dword ptr LOWF[edx + 10], eax
    mov eax, dword ptr buf[esi + 14]
    mov dword ptr LOWF[edx + 14], eax
    mov eax, dword ptr buf[esi + 18]
    mov dword ptr LOWF[edx + 18], eax
    add edx, 22
J:;判断循环是否终止
    add esi, 22
    cmp esi, cnt
    jge OVER
    dec edi
    jnz R   ;edi不等于0则继续循环
    jmp ENDING
OVER:
    invoke printf, offset lpmFt, offset hint
ENDING:
    invoke ExitProcess, 0
main endp
END