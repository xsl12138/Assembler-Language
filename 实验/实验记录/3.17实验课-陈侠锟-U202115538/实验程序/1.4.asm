.686     
.model flat, stdcall
 ExitProcess PROTO STDCALL :DWORD
 includelib  kernel32.lib  ; ExitProcess �� kernel32.lib��ʵ��
 printf          PROTO C :VARARG
 includelib  libcmt.lib
 includelib  legacy_stdio_definitions.lib

.DATA
    lpmFt db '%s', 0
    hint db '���������', 0
    ;������һ�����ݽṹ��ÿ�����ݽṹռ6*4*4 = 22���ֽ�
    ;SAMID   DB '000001' ;ÿ�����ݵ���ˮ��
    ;;���¶����з���˫������
    ;SDA DD  256809      ;״̬��Ϣa
    ;SDB DD  -1023       ;״̬��Ϣb
    ;SDC DD   1265       ;״̬��Ϣc
    ;SF  DD   0          ;������f
    buf db  '000001'    ;ռ6���ֽ�
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
    cnt dd 5*22;�洢�������ޣ������ж��Ƿ����
    chushu dd 128
.STACK 200
.CODE
main proc c
    mov ebx, 0  ;MIDF������±꣨*22��
    mov ecx, 0  ;HIGHF������±꣨*22��
    mov edx, 0  ;LOWF������±꣨*22��
    mov esi, 0  ;buf������±꣨*22��
    mov edi, 6  ;ѭ������

R:
    mov eax, dword ptr buf[esi + 6]
    ;imul chengshu
    imul eax, 5
    ;mul eax, 5 ;�޷��ų˷� 
    add eax, dword ptr buf[esi + 10]
    sub eax, dword ptr buf[esi + 14]
    add eax, 100
    sar eax, 7  ;����128���������Ʋ���������λ���ֲ��䣩
    ;shr eax, 7���߼����Ʋ����������޷�����������
    mov  dword ptr buf[esi + 18], eax
    cmp eax, 100
    jg G    ;�������
    jl L    ;���С�� 
    ;�������ݵ�MIDF
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
    ;�������ݵ�HIGHF
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
    ;�������ݵ�LOWF
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
J:;�ж�ѭ���Ƿ���ֹ
    add esi, 22
    cmp esi, cnt
    jge OVER
    dec edi
    jnz R   ;edi������0�����ѭ��
    jmp ENDING
OVER:
    invoke printf, offset lpmFt, offset hint
ENDING:
    invoke ExitProcess, 0
main endp
END