.686     
.model flat, stdcall
 ExitProcess PROTO STDCALL :DWORD
 includelib  kernel32.lib  ; ExitProcess �� kernel32.lib��ʵ��
 scanf           PROTO C :VARARG
 printf          PROTO C :VARARG
 includelib  libcmt.lib
 includelib  legacy_stdio_definitions.lib
.DATA
;lpFmt	db	"%s",0ah, 0dh, 0    ;0ah�����У�0dh����س�
  lpFmt  db "%s", 0     ;�����
  pFmt   db "%s", 0     ;������
  res1   db  'OK!',0
  res2   db  'Incorrect Password!',0
  key    db  'abcdefghi', 2 dup(0);��ַ�е�λ��a����λ��j      ;�ֱȽ�ʱ�������봮λ��Ϊż������һ��׼ȷ��������Ϊ����������������
  len1   dd  $ - key - 2    ;key�ĳ���
  array  db 12 DUP(0)
.STACK 200
.CODE
main proc c
  invoke scanf, offset pFmt, offset array   ;���������������룬��ַ�е�λ����������ַ�����λ���������ַ�
  mov edx, len1
  mov ecx, 0
  ;�ж��ַ�������
  cmp array[edx-1], 0   ;�趨���볤��len1���洢��edx�У���array[edx - 1] = 0˵������Ĵ����ȱ�len1С
  je INCORRECT
  cmp array[edx], 0     ;array[edx] != 0˵������Ĵ����ȱ�len1��
  jne INCORRECT

L:
  inc ecx
  inc ecx   ;�ֽڱȽ϶��һ��
  dec edx   ;��������ѭ��������
  jz  O
  dec edx   ;�ֽڱȽ϶��һ��
  jz  O ;�ж���ֹ
  ;mov al,key[ecx]   ;�ֽڱȽ�
  mov ax,word ptr key[ecx]  ;�ֱȽ�
  ;cmp al,array[ecx] ;�ֽڱȽ�
  cmp ax, word ptr array[ecx]   ;�ֱȽ�
  jz L  ;�����ѭ��
INCORRECT:
  invoke printf,offset lpFmt,offset res2    ;Incorrect
  jmp E
O:
  invoke printf,offset lpFmt,offset res1    ;OK
E:
  invoke ExitProcess, 0
main endp
END
