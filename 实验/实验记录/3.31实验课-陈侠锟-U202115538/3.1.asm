;author:chenxiakun      func:main   show_MIDF
.686     
.model flat, stdcall
 ExitProcess PROTO STDCALL :DWORD
 includelib  kernel32.lib  ; ExitProcess �� kernel32.lib��ʵ��
 printf          PROTO C :VARARG
 scanf           PROTO C :VARARG
 includelib  libcmt.lib
 includelib  legacy_stdio_definitions.lib
 public data_buf
 public MIDF
 public HIGHF
 public LOWF
 public buf_point

 show_MIDF      PROTO : dword
 copy_to_HIGHF  PROTO : dword
 copy_to_MIDF   PROTO : dword
 copy_to_LOWF   PROTO : dword
 cal_f          PROTO
;������һ�����ݽṹ��ÿ�����ݽṹռ6+4*4 = 22���ֽ�
SAMPLES  STRUCT
    SAMID  DB 6 DUP(0)   ;ÿ�����ݵ���ˮ��
    SDA   DD  0    ;״̬��Ϣa
    SDB   DD  0      ;״̬��Ϣb
    SDC   DD  0      ;״̬��Ϣc
    SF    DD  0        ;������f
SAMPLES  ENDS   ;���ݽṹ����

;ʵ���ַ����Ƚϵĺ궨��
string_compare macro username, username_input, len_username, code, code_input, len_code   ;str1�Ǽ��趨�û���/���룬len1��str1�ĳ���
    push edx
    push eax
    mov edx, len_username
    cmp username_input[edx - 1], 0
    je INCORRECT
    cmp username_input[edx], 0
    jne INCORRECT
LO:
    cmp edx, 0
    je  OK
    dec edx
    mov al,username[edx]   ;�ֽڱȽ�
    cmp al,username_input[edx] ;�ֽڱȽ�
    jne INCORRECT
    jmp LO  ;�����ѭ��
OK: ;�����Ƚ�����
    mov edx, len_code
    cmp code_input[edx - 1], 0
    je INCORRECT
    cmp code_input[edx], 0
    jne INCORRECT
LO2:
    cmp edx, 0
    je OK2
    dec edx
    mov al,code[edx]
    cmp al,code_input[edx]
    jne INCORRECT
    jmp LO2
OK2:
    invoke printf, offset lpFmt, offset res1   ;������ȷ
    mov judge, 1
    jmp E
INCORRECT:
    invoke printf,offset lpFmt,offset res2    ;Incorrect  
    dec input_cnt
E:
    pop eax
    pop edx
endm    ;�궨�����

.DATA
    lpFmt db '%s', 0;����������
    lpFmtc db '%c', 0   ;�����
    lpFmtd db '%d', 0 ;�����
    username db 'cxk', 0
    len_username dd $ - username - 1
    code db '123', 0
    len_code dd $ - code - 1
    username_input db 12 dup(0)
    code_input db 12 dup(0)
    input1 db '�������û�����', 0
    input2 db '���������룺', 0
    input3 db '���롮r������ִ�����ݴ������롮q���˳���', 0
    input4 db '������r��q������������Ч��',0
    ;���㹫ʽ��f=(5a+b-c+100)/128
    data_buf    SAMPLES  <'000001',32100,43200,10,?> ;HIGHF
                SAMPLES  <'000002',2547,20,55,?>;MIDF
                SAMPLES  <'000003',3600,2500,7800,?>;MIDF
                SAMPLES  <'000004',3200,421,3721,?>;MIDF
                SAMPLES  <'000005',1998,200,50,?>;LOWF
    buf_point dd 0  ;data_buf���±�
    MIDF SAMPLES 10 dup(<>)
    HIGHF SAMPLES 10 dup(<>)
    LOWF SAMPLES 10 dup(<>)
    res1 db '������ȷ', 0aH, 0dH, 0
    res2 db '�������',0aH, 0dH, 0
    error_hint db '����������󣬳����˳���',0aH, 0dH, 0
    ;samid db 'SAMID:%s', 0aH, 0dH, 0
    samid db 'SAMID:', 0
    sda db 'SDA:%d', 0aH, 0dH, 0
    sdb db 'SDB:%d', 0aH, 0dH, 0
    sdc db 'SDC:%d', 0aH, 0dH, 0
    sf db 'SF:%d', 0aH, 0dH, 0
    judge db 0  ;�ж������û��������Ƿ���ȷ//1��ʾ��ȷ
    input_cnt db 3    ;����������
    choice db ? ;��ʾMIDF���ѡ��r����ִ�����ݴ���q�˳�����
.STACK 200
.CODE

main proc c
    local midf_point: dword  ;�����洢������±�
    local highf_point: dword
    local lowf_point: dword 
REINPUT:
    invoke printf,offset lpFmt, offset input1
    invoke scanf, offset lpFmt, offset username_input   ;scanf�õ�lpFmt��������0aH��0dH����Ȼ����ִ���

    invoke printf, offset lpFmt, offset input2
    invoke scanf, offset lpFmt, offset code_input
    string_compare username, username_input, len_username, code, code_input, len_code
    cmp input_cnt, 0
    je ENDING
    cmp judge, 1
    jne REINPUT
;����Ϊ�����û���/����ģ��
REDEAL_DATA:
    mov midf_point, 0
    mov highf_point, 0
    mov lowf_point, 0
    mov buf_point, 0
    mov ecx,5  ;ѭ������
R:
    call cal_f  ;����f
    mov esi, buf_point
    mov edx, dword ptr data_buf[esi + 18]
    cmp edx, 100
    jg G    ;�������
    jl L    ;���С�� 
  ;�ŵ�MIDF������
    invoke copy_to_MIDF, midf_point
    mov midf_point, ebx ;�����º�������±�Ż��ڴ���
    jmp J
G:;�ŵ�HIGHF������
    invoke copy_to_HIGHF, highf_point
    mov highf_point, ebx
    jmp J
L:;�ŵ�LOWF������
    invoke copy_to_LOWF, lowf_point
    mov lowf_point, ebx
J:;�ж�ѭ���Ƿ���ֹ
    add esi, 22
    mov buf_point, esi
    dec ecx
    jnz R   ;ecx������0�����(��)ѭ��
;���鸴�ƽ���
;��ʾMIDF����洢������
    invoke show_MIDF, midf_point
;�ȴ�����
    ;invoke fflush, stdin
    invoke printf, offset lpFmt, offset input3
WAITING_INPUT:
    invoke scanf, offset lpFmtc, offset choice  ;���س�
    invoke scanf, offset lpFmtc, offset choice  ;��ѡ��q��r��
    cmp choice, 'q' ;���choice == 'q'
    je NORMAL_ENDING
    cmp choice, 'r' ;���choice == 'r'
    je REDEAL_DATA
    INVOKE printf, offset lpFmt, offset input4
    jmp WAITING_INPUT
ENDING:
    invoke printf, offset lpFmt, offset error_hint
NORMAL_ENDING:
    invoke ExitProcess, 0
main endp

show_MIDF proc MIDF_point: dword    ;MIDF��main�еľֲ��������ڸ��Ӻ���������tem_point���Ͻ磬����������������ݺ���ֹ������ܵ�ѭ��
    local tem_point: dword   ;MIDF����ʱָ��
    local tem_cnt: dword    ;�������ˮ�Ź����еļ�������
    push edx
    push ebx
    mov tem_point, 0
    ;mov edx, offset MIDF
;�����ˮ��
NEXT_PRINT:
    invoke printf, offset lpFmt, offset samid
    mov tem_cnt, 0
    mov ebx, tem_point
PRINT_SAMID:
    mov edx, tem_cnt
    invoke printf, offset lpFmtc, MIDF[ebx + edx] ;����printf֮����ܻ�ı�edx��ֵ//����ʹ��tem_point����Ѱַ�����Ʋ���������ھֲ�����ռ�ڴ浼��Ѱַ�쳣��
    inc tem_cnt
    cmp tem_cnt, 6
    JNE PRINT_SAMID
    invoke printf, offset lpFmtc, 0aH    ;���һ������
    ;invoke printf, offset samid, MIDF
;���ʣ�����ݣ�4���ֽ�һ�����ݣ�
    invoke printf, offset sda, MIDF[ebx].SDA
    invoke printf, offset sdb, MIDF[ebx].SDB
    invoke printf, offset sdc, MIDF[ebx].SDC
    invoke printf, offset sf, MIDF[ebx].SF
    add tem_point, 22
    ;add edx, 22
    invoke printf, offset lpFmtc, 0aH
    mov ebx, tem_point
    cmp ebx, MIDF_point
    jb NEXT_PRINT
    pop ebx
    pop edx
    ret
show_MIDF endp
END