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

;设置新的中断点8
NEW08H  PROC FAR
	PUSHF
	CALL DWORD PTR CS:OLD_INT
	DEC CS:COUNT
	JZ DISP       ;每18次显示一次时间
	IRET
DISP:	MOV CS:COUNT,18  ;恢复count为18
	STI
	PUSHA
	PUSH DS
	PUSH ES
	MOV AX,CS
	MOV DS,AX
	MOV ES,AX
	CALL GET_TIME  ;获取时间
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
	INT 10H         ;修改光标的位置和字符的属性
	MOV BH,0
	MOV DX,CURSOR
	MOV AH,2
	INT 10H         ;将光标改为原来的样子
	POP ES
	POP DS
	POPA
	IRET
NEW08H ENDP
;获取时间的函数
GET_TIME PROC
	MOV AL,4         ;小时所在的偏移地址
	OUT 70H,AL
	JMP $+2
	IN AL,71H   
	MOV AH,AL         ;分开两个BCD码
	AND AL,0FH
	SHR AH,4
	ADD AX,3030H      ;转换成ASCII码
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

; 初始化（中断处理程序的安装）及主程序
BEGIN:
	PUSH CS
	POP DS
SHURU:
	LEA DX,TIP1
	MOV AH,9
	INT 21H		;输出DX中的字符串
	MOV AH,1
	INT 21H		;等待输入
	CMP AL,'q'
	JE EXIT
	CMP AL,'s'
	JNE SHURU
	MOV AX,3508H
	INT 21H		;获取原08H的中断向量
	MOV OLD_INT,BX	;保存中断向量
	MOV OLD_INT+2,ES
	MOV DX,OFFSET NEW08H
	CMP DX,OLD_INT	;在不关DOSBOX的情况下，安装的新中断程序是不会变的
	;只要已经存在的08H中断程序和NEW08H的地址相同，就是已经安装过了
	JE HAVE_INSTALLED
	MOV AX,2508H
	INT 21H		;设置新的08H中断向量
NEXT:
	LEA DX,TIP3
	MOV AH,9
	INT 21H		;输出DX中的字符串
	MOV AH,1
	INT 21H		;等待输入
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
	INT 21H		;输出DX中的字符串
EXIT:
	LEA DX,TIP2
	MOV AH,9
	INT 21H		;输出DX中的字符串
	;驻留并退出程序（需要把主程序之前的部分驻留在内存当中）
	MOV DX,OFFSET BEGIN+15 ; 计算中断处理程序占用的字节数,+15是为了在计算节数时能向上取整
	MOV CL,4
	SHR DX,CL   ; 把字节数换算成节数（每节代表16个字节）
	ADD DX,30H  ;（30个节：480个字节）; 驻留的长度还需包括程序段前缀（LINK之后）的内容
	MOV AL,0    ; 退出码为0
	MOV AH,31H
	INT 21H		;结束并驻留，AL = 返回码， DX = 驻留区大小（单位：节）
CODE ENDS
	END BEGIN
