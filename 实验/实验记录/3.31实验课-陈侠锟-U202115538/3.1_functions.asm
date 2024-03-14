;author:chenxiakun      func:copy_to_HIGHF  copy_to_MIDF    copy_to_LOWF    cal_f
.686     
.model flat, stdcall
 ExitProcess PROTO STDCALL :DWORD
 includelib  kernel32.lib  ; ExitProcess �� kernel32.lib��ʵ��
 printf          PROTO C :VARARG
 scanf           PROTO C :VARARG
 includelib  libcmt.lib
 includelib  legacy_stdio_definitions.lib

;������һ�����ݽṹ��ÿ�����ݽṹռ6+4*4 = 22���ֽ�
SAMPLES  STRUCT
    SAMID  DB 6 DUP(0)   ;ÿ�����ݵ���ˮ��
    SDA   DD  0    ;״̬��Ϣa
    SDB   DD  0      ;״̬��Ϣb
    SDC   DD  0      ;״̬��Ϣc
    SF    DD  0        ;������f
SAMPLES  ENDS   ;���ݽṹ����

 EXTERN data_buf: SAMPLES
 EXTERN MIDF: SAMPLES
 EXTERN LOWF: SAMPLES
 EXTERN HIGHF: SAMPLES
 EXTERN buf_point: dword
.DATA


.CODE
copy_to_HIGHF proc point:dword
    ;�������ݵ�HIGHF
    mov ebx, point
    mov eax, 0
    mov ax, word ptr data_buf[esi]  ;esiʼ�մ洢buf_point
    mov word ptr HIGHF[ebx], ax
    mov eax, dword ptr data_buf[esi + 2]
    mov dword ptr HIGHF[ebx + 2], eax
    mov eax, dword ptr data_buf[esi + 6]
    mov dword ptr HIGHF[ebx + 6], eax
    mov eax, dword ptr data_buf[esi + 10]
    mov dword ptr HIGHF[ebx + 10], eax
    mov eax, dword ptr data_buf[esi + 14]
    mov dword ptr HIGHF[ebx + 14], eax
    mov eax, dword ptr data_buf[esi + 18]
    mov dword ptr HIGHF[ebx + 18], eax
    add ebx, 22
    ;mov point, ebx
    ret
copy_to_HIGHF endp

copy_to_MIDF proc point:dword
    ;�������ݵ�MIDF
    mov ebx, point
    mov eax, 0
    mov ax, word ptr data_buf[esi]
    mov word ptr MIDF[ebx], ax
    mov eax, dword ptr data_buf[esi + 2]
    mov dword ptr MIDF[ebx + 2], eax
    mov eax, dword ptr data_buf[esi + 6]
    mov dword ptr MIDF[ebx + 6], eax
    mov eax, dword ptr data_buf[esi + 10]
    mov dword ptr MIDF[ebx + 10], eax
    mov eax, dword ptr data_buf[esi + 14]
    mov dword ptr MIDF[ebx + 14], eax
    mov eax, dword ptr data_buf[esi + 18]
    mov dword ptr MIDF[ebx + 18], eax
    add ebx, 22
    ret
copy_to_MIDF endp

copy_to_LOWF proc point:dword
    ;�������ݵ�LOWF
    mov ebx, point
    mov eax, 0
    mov ax, word ptr data_buf[esi]
    mov word ptr LOWF[ebx], ax
    mov eax, dword ptr data_buf[esi + 2]
    mov dword ptr LOWF[ebx + 2], eax
    mov eax, dword ptr data_buf[esi + 6]
    mov dword ptr LOWF[ebx + 6], eax
    mov eax, dword ptr data_buf[esi + 10]
    mov dword ptr LOWF[ebx + 10], eax
    mov eax, dword ptr data_buf[esi + 14]
    mov dword ptr LOWF[ebx + 14], eax
    mov eax, dword ptr data_buf[esi + 18]
    mov dword ptr LOWF[ebx + 18], eax
    add ebx, 22
    ret
copy_to_LOWF endp

;�ӳ��򣺼���f
cal_f proc
    push esi
    push edx
    mov esi, buf_point
    mov edx, dword ptr data_buf[esi + 6]
    imul edx, 5
    add edx, dword ptr data_buf[esi + 10]
    sub edx, dword ptr data_buf[esi + 14]
    add edx, 100
    sar edx, 7  ;����128���������Ʋ���������λ���ֲ��䣩
    mov  dword ptr data_buf[esi + 18], edx 
    pop edx
    pop esi
    ret
cal_f endp


 END