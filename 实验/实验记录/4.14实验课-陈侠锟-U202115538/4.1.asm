.386
STACK SEGMENT USE16 STACK
	DB 200 DUP(0)
STACK ENDS

CODE SEGMENT USE16
	ASSUME CS:CODE,DS:CODE,SS:STACK
	
	COUNT DB 18
	HOUR DB ?,?,':'
	MIN DB ?,?,':'
	SEC DB ?,?
	BUF_LEN=$-HOUR
	CURSOR DW ?
	OLD_INT DW ?,?
	TIP1 DB  "Press 's' to display time in the top right corner or press 'q' to exit procedure",0ah,0dh,'$'
	TIP2 DB 0ah,0dh,"Exit",0ah,0dh,'$'
	TIP3 DB 0ah,0dh,"Press 'q' to stop ",0ah,0dh,'$'
	TIP4 DB 0ah,0dh,"The procedure have installed",0ah,0dh,'$'
	NUMBER=8

;�����µ��жϵ�8
NEW08H  PROC FAR
	PUSHF
	CALL DWORD PTR CS:OLD_INT
	DEC CS:COUNT
	JZ DISP       ;ÿ18����ʾһ��ʱ��
	IRET
DISP:	MOV CS:COUNT,18  ;�ָ�countΪ18
	STI
	PUSHA
	PUSH DS
	PUSH ES
	MOV AX,CS
	MOV DS,AX
	MOV ES,AX
	CALL GET_TIME  ;��ȡʱ��
	MOV BH,0
	MOV AH,3
	INT 10H
	MOV CURSOR,DX
	MOV BP,OFFSET HOUR
	MOV BH,0
	MOV DH,0
	MOV DL,80-BUF_LEN
	MOV BL,07H
	MOV CX,BUF_LEN
	MOV AL,0
	MOV AH,13H
	INT 10H         ;�޸Ĺ���λ�ú��ַ�������
	MOV BH,0
	MOV DX,CURSOR
	MOV AH,2
	INT 10H         ;������Ϊԭ��������
	POP ES
	POP DS
	POPA
	IRET
NEW08H ENDP
;��ȡʱ��ĺ���
GET_TIME PROC
	MOV AL,4         ;Сʱ���ڵ�ƫ�Ƶ�ַ
	OUT 70H,AL
	JMP $+2
	IN AL,71H   
	MOV AH,AL         ;�ֿ�����BCD��
	AND AL,0FH
	SHR AH,4
	ADD AX,3030H      ;ת����ASCII��
	XCHG AH,AL
	MOV WORD PTR HOUR,AX
	MOV AL,2
	OUT 70H,AL
	JMP $+2
	IN AL,71H
	MOV AH,AL
	AND AL,0FH
	SHR AH,4
	ADD AX,3030H
	XCHG AH,AL
	MOV WORD PTR MIN,AX
	MOV AL,0
	OUT 70H,AL
	JMP $+2
	IN AL,71H
	MOV AH,AL
	AND AL,0FH
	SHR AH,4
	ADD AX,3030H
	XCHG AH,AL
	MOV WORD PTR SEC,AX
	RET
GET_TIME ENDP

; ��ʼ�����жϴ������İ�װ����������
BEGIN:
	PUSH CS
	POP DS
SHURU:
	LEA DX,TIP1
	MOV AH,9
	INT 21H		;���DX�е��ַ���
	MOV AH,1
	INT 21H		;�ȴ�����
	CMP AL,'q'
	JE EXIT
	CMP AL,'s'
	JNE SHURU
	MOV AX,3508H
	INT 21H		;��ȡԭ08H���ж�����
	MOV OLD_INT,BX	;�����ж�����
	MOV OLD_INT+2,ES
	MOV DX,OFFSET NEW08H
	CMP DX,OLD_INT	;�ڲ���DOSBOX������£���װ�����жϳ����ǲ�����
	;ֻҪ�Ѿ����ڵ�08H�жϳ����NEW08H�ĵ�ַ��ͬ�������Ѿ���װ����
	JE HAVE_INSTALLED
	MOV AX,2508H
	INT 21H		;�����µ�08H�ж�����
NEXT:
	LEA DX,TIP3
	MOV AH,9
	INT 21H		;���DX�е��ַ���
	MOV AH,1
	INT 21H		;�ȴ�����
	CMP AL,'q'
	JNE NEXT
	;LDS DX,DWORD PTR OLD_INT	;
	;MOV AX,2508H
	;INT 21H
	;MOV AH,4CH
	;INT 27H
	JMP EXIT
HAVE_INSTALLED:
	LEA DX,TIP4
	MOV AH,9	
	INT 21H		;���DX�е��ַ���
EXIT:
	LEA DX,TIP2
	MOV AH,9
	INT 21H		;���DX�е��ַ���
	;פ�����˳�������Ҫ��������֮ǰ�Ĳ���פ�����ڴ浱�У�
	MOV DX,OFFSET BEGIN+15 ; �����жϴ������ռ�õ��ֽ���,+15��Ϊ���ڼ������ʱ������ȡ��
	MOV CL,4
	SHR DX,CL   ; ���ֽ�������ɽ�����ÿ�ڴ���16���ֽڣ�
	ADD DX,30H  ;��30���ڣ�480���ֽڣ�; פ���ĳ��Ȼ�����������ǰ׺��LINK֮�󣩵�����
	MOV AL,0    ; �˳���Ϊ0
	MOV AH,31H
	INT 21H		;������פ����AL = �����룬 DX = פ������С����λ���ڣ�
CODE ENDS
	END BEGIN
