.686     
.model flat, stdcall
 ExitProcess PROTO STDCALL :DWORD
 includelib  kernel32.lib  ; ExitProcess 在 kernel32.lib中实现
 printf          PROTO C :VARARG
 clock          PROTO C
 includelib  libcmt.lib
 ;includelib  msvcrt.lib
 includelib  legacy_stdio_definitions.lib
;以下是一个数据结构，每个数据结构占6+4*4 = 22个字节
SAMPLES  STRUCT
    SAMID  DB 6 DUP(0)   ;每组数据的流水号
    SDA   DD  0    ;状态信息a
    SDB   DD  0      ;状态信息b
    SDC   DD  0      ;状态信息c
    SF    DD  0        ;处理结果f
SAMPLES  ENDS   ;数据结构结束
.DATA
    lpmFt db '%s', 0ah, 0dh, 0
    lpmFt1 db '%d', 0ah, 0dh, 0
    string db '所耗时钟周期数为：',0
    hint db '数据溢出！', 0
    input   SAMPLES  <'1',321,432,10,?>
            SAMPLES  <'2',12654,544,342,?>
            SAMPLES  <'3',32100654,432,10,?>
            SAMPLES  197 dup(<>)

    midf_point dd 0 ;三个数组的下标
    highf_point dd 0
    lowf_point dd 0
    MIDF dd 200*22 dup(0)
    HIGHF dd 200*22 dup(0)
    LOWF dd 200*22 dup(0)
    ;chengshu dd 5
    cnt dd 200*22;存储数组上限，用于判断是否溢出
    ;chushu dd 128
    loop_cnt dd 200001
.STACK 200
.CODE
main proc c

    invoke clock    ;结果存储在eax中
    push eax
OUTLOOP:
    dec loop_cnt
    jz ENDING ;edx不等于0继续（外）循环
    mov midf_point, 0
    mov highf_point, 0
    mov lowf_point, 0
    mov ecx, 0
    mov ebx, 0  ;往数组赋值的过程中，存储数组的下标
    mov esi, 0  ;buf数组的下标（*22）
    mov edi,200  ;(内)循环次数

R:
    mov eax, dword ptr input[esi + 6]
    imul eax, 5
    ;mul eax, 5 ;无符号乘法 
;第二种乘法
    ;sal eax, 2
    ;add eax,eax
 
    add eax, dword ptr input[esi + 10]
    sub eax, dword ptr input[esi + 14]
    add eax, 100
    sar eax, 7  ;除以128（算术右移操作，符号位保持不变）
;普通除法
    ;mov ecx, 128
    ;xor edx, edx    ;清空高32位寄存器
    ;idiv ecx

    ;shr eax, 7（逻辑右移操作，当作无符号数除法）
    mov  dword ptr input[esi + 18], eax
    cmp eax, 100
    jg G    ;如果大了
    jl L    ;如果小了 
    ;复制数据到MIDF
    mov ebx, midf_point
;复制方法一
    mov eax, 0
    mov ax, word ptr input[esi]
    mov word ptr MIDF[ebx], ax
    mov eax, dword ptr input[esi + 2]
    mov dword ptr MIDF[ebx + 2], eax
    mov eax, dword ptr input[esi + 6]
    mov dword ptr MIDF[ebx + 6], eax
    mov eax, dword ptr input[esi + 10]
    mov dword ptr MIDF[ebx + 10], eax
    mov eax, dword ptr input[esi + 14]
    mov dword ptr MIDF[ebx + 14], eax
    mov eax, dword ptr input[esi + 18]
    mov dword ptr MIDF[ebx + 18], eax
;复制方法二
    ;mov ecx, 0 ;计数器
;COPY1:
    ;mov eax, 0
    ;mov al, byte ptr input[esi+ecx]
    ;mov byte ptr MIDF[ebx+ecx], al
    ;inc ecx
    ;cmp ecx, 22
    ;jl COPY1

    add ebx, 22
    mov midf_point, ebx ;将更新后的数组下标放回内存中
    jmp J
G:
    ;复制数据到HIGHF
    mov ebx, highf_point
;复制方法一
    mov eax, 0
    mov ax, word ptr input[esi]
    mov word ptr HIGHF[ebx], ax
    mov eax, dword ptr input[esi + 2]
    mov dword ptr HIGHF[ebx + 2], eax
    mov eax, dword ptr input[esi + 6]
    mov dword ptr HIGHF[ebx + 6], eax
    mov eax, dword ptr input[esi + 10]
    mov dword ptr HIGHF[ebx + 10], eax
    mov eax, dword ptr input[esi + 14]
    mov dword ptr HIGHF[ebx + 14], eax
    mov eax, dword ptr input[esi + 18]
    mov dword ptr HIGHF[ebx + 18], eax
;复制方法二
    ;mov ecx, 0 ;计数器
;COPY2:
    ;mov eax, 0
    ;mov al, byte ptr input[esi+ecx]
    ;mov byte ptr HIGHF[ebx+ecx], al
    ;inc ecx
    ;cmp ecx, 22
    ;jl COPY2

    add ebx, 22
    mov highf_point, ebx
    jmp J
L:
    ;复制数据到LOWF
    mov ebx, lowf_point
;复制方法一
    mov eax, 0
    mov ax, word ptr input[esi]
    mov word ptr LOWF[ebx], ax
    mov eax, dword ptr input[esi + 2]
    mov dword ptr LOWF[ebx + 2], eax
    mov eax, dword ptr input[esi + 6]
    mov dword ptr LOWF[ebx + 6], eax
    mov eax, dword ptr input[esi + 10]
    mov dword ptr LOWF[ebx + 10], eax
    mov eax, dword ptr input[esi + 14]
    mov dword ptr LOWF[ebx + 14], eax
    mov eax, dword ptr input[esi + 18]
    mov dword ptr LOWF[ebx + 18], eax
;复制方法二
    ;mov ecx, 0 ;计数器
;COPY3:
    ;mov eax, 0
    ;mov al, byte ptr input[esi+ecx]
    ;mov byte ptr LOWF[ebx+ecx], al
    ;inc ecx
    ;cmp ecx, 22
    ;jl COPY3

    add ebx, 22
    mov lowf_point, ebx
J:;判断循环是否终止
    add esi, 22
    ;cmp esi, cnt
    ;jg OVER
    dec edi
    jnz R   ;edi不等于0则继续(内)循环

    jmp OUTLOOP
 
;OVER:
    ;invoke printf, offset lpmFt, offset hint
ENDING:
    ;RDTSC
    invoke clock    ;结果存储在eax中
    pop ecx
    sub eax, ecx
    invoke printf, offset lpmFt1, eax
    invoke ExitProcess, 0
main endp
END