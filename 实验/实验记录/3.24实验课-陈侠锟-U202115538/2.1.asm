.686     
.model flat, stdcall
 ExitProcess PROTO STDCALL :DWORD
 includelib  kernel32.lib  ; ExitProcess �� kernel32.lib��ʵ��
 printf          PROTO C :VARARG
 clock          PROTO C
 includelib  libcmt.lib
 ;includelib  msvcrt.lib
 includelib  legacy_stdio_definitions.lib
;������һ�����ݽṹ��ÿ�����ݽṹռ6+4*4 = 22���ֽ�
SAMPLES  STRUCT
    SAMID  DB 6 DUP(0)   ;ÿ�����ݵ���ˮ��
    SDA   DD  0    ;״̬��Ϣa
    SDB   DD  0      ;״̬��Ϣb
    SDC   DD  0      ;״̬��Ϣc
    SF    DD  0        ;������f
SAMPLES  ENDS   ;���ݽṹ����
.DATA
    lpmFt db '%s', 0ah, 0dh, 0
    lpmFt1 db '%d', 0ah, 0dh, 0
    string db '����ʱ��������Ϊ��',0
    hint db '���������', 0
    input   SAMPLES  <'1',321,432,10,?>
            SAMPLES  <'2',12654,544,342,?>
            SAMPLES  <'3',32100654,432,10,?>
            SAMPLES  197 dup(<>)

    midf_point dd 0 ;����������±�
    highf_point dd 0
    lowf_point dd 0
    MIDF dd 200*22 dup(0)
    HIGHF dd 200*22 dup(0)
    LOWF dd 200*22 dup(0)
    ;chengshu dd 5
    cnt dd 200*22;�洢�������ޣ������ж��Ƿ����
    ;chushu dd 128
    loop_cnt dd 200001
.STACK 200
.CODE
main proc c

    invoke clock    ;����洢��eax��
    push eax
OUTLOOP:
    dec loop_cnt
    jz ENDING ;edx������0�������⣩ѭ��
    mov midf_point, 0
    mov highf_point, 0
    mov lowf_point, 0
    mov ecx, 0
    mov ebx, 0  ;�����鸳ֵ�Ĺ����У��洢������±�
    mov esi, 0  ;buf������±꣨*22��
    mov edi,200  ;(��)ѭ������

R:
    mov eax, dword ptr input[esi + 6]
    imul eax, 5
    ;mul eax, 5 ;�޷��ų˷� 
;�ڶ��ֳ˷�
    ;sal eax, 2
    ;add eax,eax
 
    add eax, dword ptr input[esi + 10]
    sub eax, dword ptr input[esi + 14]
    add eax, 100
    sar eax, 7  ;����128���������Ʋ���������λ���ֲ��䣩
;��ͨ����
    ;mov ecx, 128
    ;xor edx, edx    ;��ո�32λ�Ĵ���
    ;idiv ecx

    ;shr eax, 7���߼����Ʋ����������޷�����������
    mov  dword ptr input[esi + 18], eax
    cmp eax, 100
    jg G    ;�������
    jl L    ;���С�� 
    ;�������ݵ�MIDF
    mov ebx, midf_point
;���Ʒ���һ
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
;���Ʒ�����
    ;mov ecx, 0 ;������
;COPY1:
    ;mov eax, 0
    ;mov al, byte ptr input[esi+ecx]
    ;mov byte ptr MIDF[ebx+ecx], al
    ;inc ecx
    ;cmp ecx, 22
    ;jl COPY1

    add ebx, 22
    mov midf_point, ebx ;�����º�������±�Ż��ڴ���
    jmp J
G:
    ;�������ݵ�HIGHF
    mov ebx, highf_point
;���Ʒ���һ
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
;���Ʒ�����
    ;mov ecx, 0 ;������
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
    ;�������ݵ�LOWF
    mov ebx, lowf_point
;���Ʒ���һ
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
;���Ʒ�����
    ;mov ecx, 0 ;������
;COPY3:
    ;mov eax, 0
    ;mov al, byte ptr input[esi+ecx]
    ;mov byte ptr LOWF[ebx+ecx], al
    ;inc ecx
    ;cmp ecx, 22
    ;jl COPY3

    add ebx, 22
    mov lowf_point, ebx
J:;�ж�ѭ���Ƿ���ֹ
    add esi, 22
    ;cmp esi, cnt
    ;jg OVER
    dec edi
    jnz R   ;edi������0�����(��)ѭ��

    jmp OUTLOOP
 
;OVER:
    ;invoke printf, offset lpmFt, offset hint
ENDING:
    ;RDTSC
    invoke clock    ;����洢��eax��
    pop ecx
    sub eax, ecx
    invoke printf, offset lpmFt1, eax
    invoke ExitProcess, 0
main endp
END