.686     
.model flat, stdcall
 ExitProcess PROTO STDCALL :DWORD
 includelib  kernel32.lib  ; ExitProcess 在 kernel32.lib中实现
 scanf           PROTO C :VARARG
 printf          PROTO C :VARARG
 includelib  libcmt.lib
 includelib  legacy_stdio_definitions.lib
.DATA
;lpFmt	db	"%s",0ah, 0dh, 0    ;0ah代表换行，0dh代表回车
  lpFmt  db "%s", 0     ;输出用
  pFmt   db "%s", 0     ;输入用
  res1   db  'OK!',0
  res2   db  'Incorrect Password!',0
  key    db  'abcdefghi', 2 dup(0);地址中低位存a，高位存j      ;字比较时，若密码串位数为偶数，则一定准确，若串数为计数，很容易误判
  len1   dd  $ - key - 2    ;key的长度
  array  db 12 DUP(0)
.STACK 200
.CODE
main proc c
  invoke scanf, offset pFmt, offset array   ;向数组中输入密码，地址中低位存先输入的字符，高位存后输入的字符
  mov edx, len1
  mov ecx, 0
  ;判断字符串长度
  cmp array[edx-1], 0   ;设定密码长度len1（存储在edx中），array[edx - 1] = 0说明输入的串长度比len1小
  je INCORRECT
  cmp array[edx], 0     ;array[edx] != 0说明输入的串长度比len1大
  jne INCORRECT

L:
  inc ecx
  inc ecx   ;字节比较多加一条
  dec edx   ;计数器（循环次数）
  jz  O
  dec edx   ;字节比较多加一条
  jz  O ;判断终止
  ;mov al,key[ecx]   ;字节比较
  mov ax,word ptr key[ecx]  ;字比较
  ;cmp al,array[ecx] ;字节比较
  cmp ax, word ptr array[ecx]   ;字比较
  jz L  ;相等则循环
INCORRECT:
  invoke printf,offset lpFmt,offset res2    ;Incorrect
  jmp E
O:
  invoke printf,offset lpFmt,offset res1    ;OK
E:
  invoke ExitProcess, 0
main endp
END
