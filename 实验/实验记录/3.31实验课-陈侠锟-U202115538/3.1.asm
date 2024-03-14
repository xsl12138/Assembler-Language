;author:chenxiakun      func:main   show_MIDF
.686     
.model flat, stdcall
 ExitProcess PROTO STDCALL :DWORD
 includelib  kernel32.lib  ; ExitProcess 在 kernel32.lib中实现
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
;以下是一个数据结构，每个数据结构占6+4*4 = 22个字节
SAMPLES  STRUCT
    SAMID  DB 6 DUP(0)   ;每组数据的流水号
    SDA   DD  0    ;状态信息a
    SDB   DD  0      ;状态信息b
    SDC   DD  0      ;状态信息c
    SF    DD  0        ;处理结果f
SAMPLES  ENDS   ;数据结构结束

;实现字符串比较的宏定义
string_compare macro username, username_input, len_username, code, code_input, len_code   ;str1是既设定用户名/密码，len1是str1的长度
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
    mov al,username[edx]   ;字节比较
    cmp al,username_input[edx] ;字节比较
    jne INCORRECT
    jmp LO  ;相等则循环
OK: ;继续比较密码
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
    invoke printf, offset lpFmt, offset res1   ;输入正确
    mov judge, 1
    jmp E
INCORRECT:
    invoke printf,offset lpFmt,offset res2    ;Incorrect  
    dec input_cnt
E:
    pop eax
    pop edx
endm    ;宏定义结束

.DATA
    lpFmt db '%s', 0;输入和输出用
    lpFmtc db '%c', 0   ;输出用
    lpFmtd db '%d', 0 ;输出用
    username db 'cxk', 0
    len_username dd $ - username - 1
    code db '123', 0
    len_code dd $ - code - 1
    username_input db 12 dup(0)
    code_input db 12 dup(0)
    input1 db '请输入用户名：', 0
    input2 db '请输入密码：', 0
    input3 db '输入‘r’重新执行数据处理，输入‘q’退出：', 0
    input4 db '请输入r或q，其它输入无效：',0
    ;计算公式：f=(5a+b-c+100)/128
    data_buf    SAMPLES  <'000001',32100,43200,10,?> ;HIGHF
                SAMPLES  <'000002',2547,20,55,?>;MIDF
                SAMPLES  <'000003',3600,2500,7800,?>;MIDF
                SAMPLES  <'000004',3200,421,3721,?>;MIDF
                SAMPLES  <'000005',1998,200,50,?>;LOWF
    buf_point dd 0  ;data_buf的下标
    MIDF SAMPLES 10 dup(<>)
    HIGHF SAMPLES 10 dup(<>)
    LOWF SAMPLES 10 dup(<>)
    res1 db '输入正确', 0aH, 0dH, 0
    res2 db '输入错误！',0aH, 0dH, 0
    error_hint db '三次输入错误，程序退出！',0aH, 0dH, 0
    ;samid db 'SAMID:%s', 0aH, 0dH, 0
    samid db 'SAMID:', 0
    sda db 'SDA:%d', 0aH, 0dH, 0
    sdb db 'SDB:%d', 0aH, 0dH, 0
    sdc db 'SDC:%d', 0aH, 0dH, 0
    sf db 'SF:%d', 0aH, 0dH, 0
    judge db 0  ;判断输入用户名密码是否正确//1表示正确
    input_cnt db 3    ;最大输入次数
    choice db ? ;显示MIDF后的选择，r重新执行数据处理，q退出程序
.STACK 200
.CODE

main proc c
    local midf_point: dword  ;三个存储数组的下标
    local highf_point: dword
    local lowf_point: dword 
REINPUT:
    invoke printf,offset lpFmt, offset input1
    invoke scanf, offset lpFmt, offset username_input   ;scanf用的lpFmt，不能有0aH和0dH，不然会出现错误

    invoke printf, offset lpFmt, offset input2
    invoke scanf, offset lpFmt, offset code_input
    string_compare username, username_input, len_username, code, code_input, len_code
    cmp input_cnt, 0
    je ENDING
    cmp judge, 1
    jne REINPUT
;以上为输入用户名/密码模块
REDEAL_DATA:
    mov midf_point, 0
    mov highf_point, 0
    mov lowf_point, 0
    mov buf_point, 0
    mov ecx,5  ;循环次数
R:
    call cal_f  ;计算f
    mov esi, buf_point
    mov edx, dword ptr data_buf[esi + 18]
    cmp edx, 100
    jg G    ;如果大了
    jl L    ;如果小了 
  ;放到MIDF数组中
    invoke copy_to_MIDF, midf_point
    mov midf_point, ebx ;将更新后的数组下标放回内存中
    jmp J
G:;放到HIGHF数组中
    invoke copy_to_HIGHF, highf_point
    mov highf_point, ebx
    jmp J
L:;放到LOWF数组中
    invoke copy_to_LOWF, lowf_point
    mov lowf_point, ebx
J:;判断循环是否终止
    add esi, 22
    mov buf_point, esi
    dec ecx
    jnz R   ;ecx不等于0则继续(内)循环
;分组复制结束
;显示MIDF区域存储的内容
    invoke show_MIDF, midf_point
;等待输入
    ;invoke fflush, stdin
    invoke printf, offset lpFmt, offset input3
WAITING_INPUT:
    invoke scanf, offset lpFmtc, offset choice  ;读回车
    invoke scanf, offset lpFmtc, offset choice  ;读选择（q或r）
    cmp choice, 'q' ;如果choice == 'q'
    je NORMAL_ENDING
    cmp choice, 'r' ;如果choice == 'r'
    je REDEAL_DATA
    INVOKE printf, offset lpFmt, offset input4
    jmp WAITING_INPUT
ENDING:
    invoke printf, offset lpFmt, offset error_hint
NORMAL_ENDING:
    invoke ExitProcess, 0
main endp

show_MIDF proc MIDF_point: dword    ;MIDF是main中的局部变量，在该子函数中用作tem_point的上界，即在输出完所有内容后终止输出功能的循环
    local tem_point: dword   ;MIDF的临时指针
    local tem_cnt: dword    ;做输出流水号过程中的计数器用
    push edx
    push ebx
    mov tem_point, 0
    ;mov edx, offset MIDF
;输出流水号
NEXT_PRINT:
    invoke printf, offset lpFmt, offset samid
    mov tem_cnt, 0
    mov ebx, tem_point
PRINT_SAMID:
    mov edx, tem_cnt
    invoke printf, offset lpFmtc, MIDF[ebx + edx] ;调用printf之后可能会改变edx的值//不能使用tem_point进行寻址，（推测可能是由于局部变量占内存导致寻址异常）
    inc tem_cnt
    cmp tem_cnt, 6
    JNE PRINT_SAMID
    invoke printf, offset lpFmtc, 0aH    ;输出一个换行
    ;invoke printf, offset samid, MIDF
;输出剩余内容（4个字节一个内容）
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