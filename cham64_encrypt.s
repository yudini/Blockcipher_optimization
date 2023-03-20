	.global cham64_encrypt
	.type cham64_encrypt, @function

	//평문이 64비트이므로 총 8개의 레지스터가 평문 연산에 필요
	#define X00 R18 
	#define X01 R19
	#define X10 R20 
	#define X11 R21
	#define X20 R22 
	#define X21 R23
	#define X30 R24 
	#define X31 R25

	//16비트단위의 연산이므로 연산에 필요할 레지스터 2개 필요
	#define TM0 R26
	#define TM1 R27

	#define RC R17
	#define RK R0

	#define CNT R16

	cham64_encrypt:

	//callee saved 레지스터 스택에 push
	PUSH R16 
	PUSH R17

	PUSH R28
	PUSH R29

	MOVW R28, R24   // encrypted ypointer
	MOVW R26, R22   // pt xpointer
	MOVW R30, R20   // rks zpointer

	LD X00, X+   //xpointer를 이용하여 암호화할 평문 로드
	LD X01, X+
	LD X10, X+
	LD X11, X+
	LD X20, X+
	LD X21, X+
	LD X30, X+
	LD X31, X+

	PUSH R26
	PUSH R27

	CLR RC 
	LDI CNT, 88  //88라운드 

	LOOP:
	ANDI R30, 31   //연산할 키가 마지막 포인터에서 다시 처음으로 돌아오게 해주는 연산
	              // 8비트 32개이므로 ANDI 31 해줌
	//ROUND1	
	MOVW TM0,X10   //1번째 블록을 워드단위로 옮김

	//ROL 1
	LSL TM0
	ROL TM1
	ADC TM0, R1

	//RK XOR (16비트)
	LD RK, Z+ 
	EOR TM0, RK
	LD RK, Z+
	EOR TM1, RK
		
	//RC xor
	EOR X00, RC

	//ADD
	ADD X00, TM0
	ADC X01, TM1

    INC RC

	//ROUND2
	MOVW TM0, X20   //2번째 블록을 워드단위로 옮김

	//RK xor  
	LD RK, Z+  
	EOR TM1, RK  //ROL8 안했으므로 상하위비트 위치 반전  
	LD RK, Z+   
	EOR TM0, RK
		
	//RC xor
	EOR X10, RC  
		 
	//ADD 연산
	ADD X10, TM1   //ROL8 안했으므로 상하위비트 위치 반전  
	ADC X11, TM0

	//ROL1
	LSL X10
	ROL X11
	ADC X10, R1

	INC RC

	//ROUND3	
	MOVW TM0,X30  //3번째 블록을 워드단위로 옮김

	//ROL 1
	LSL TM0
	ROL TM1
	ADC TM0, R1

	//RK XOR
	LD RK, Z+ 
	EOR TM0, RK
	LD RK, Z+
	EOR TM1, RK
		
	//RC xor
	EOR X20, RC

	//ADD
	ADD X20, TM0
	ADC X21, TM1

    INC RC

	//ROUND4
	//전 라운드에서 ROL8안했으므로 ROL8생략가능 
	MOVW TM0, X00   //0번째 블록을 워드단위로 옮김

	//RK xor  
	LD RK, Z+  
	EOR TM0, RK 
	LD RK, Z+   
	EOR TM1, RK
		
	//RC xor
	EOR X30, RC  
		 
	//ADD 연산
	ADD X30, TM0 
	ADC X31, TM1

	//ROL1
	LSL X30
	ROL X31
	ADC X30, R1

	INC RC

	//ROUND5	
	MOVW TM0, X10 //1번째 블록을 워드단위로 옮김

	//ROL 1
	LSL TM0
	ROL TM1
	ADC TM0, R1

	//RK XOR
	LD RK, Z+ 
	EOR TM0, RK
	LD RK, Z+
	EOR TM1, RK
		
	//RC xor,위에서 ROL8 생략하였으므로 위치 고려하여 연산
	EOR X01, RC

	//ADD, 
	ADD X01, TM0 //ROL8 안했으므로 상하위비트 위치 반전  
	ADC X00, TM1

    INC RC

	//ROUND6
	//전 라운드에서 ROL8안했으므로 ROL8생략가능, (ROL16= 그대로이므로)
	MOVW TM0, X20  //2번째 블록을 워드단위로 옮김

	//RK xor  
	LD RK, Z+  
	EOR TM0, RK 
	LD RK, Z+   
	EOR TM1, RK
		
	//RC xor
	EOR X10, RC  
		 
	//ADD 연산
	ADD X10, TM0 
	ADC X11, TM1

	//ROL1
	LSL X10
	ROL X11
	ADC X10, R1

	INC RC

	//ROUND7
	MOVW TM0,X30  //3번째 블록을 워드단위로 옮김

	//ROL 1
	LSL TM0
	ROL TM1
	ADC TM0, R1

	//RK XOR
	LD RK, Z+ 
	EOR TM0, RK
	LD RK, Z+
	EOR TM1, RK
		
	//RC xor,위에서 ROL8 생략하였으므로 위치 고려하여 연산(상위 8비트가 원래 하위8비트임)
	EOR X21, RC  

	//ADD
	ADD X21, TM0  //ROL8 안했으므로 상하위비트 위치 반전   
	ADC X20, TM1

    INC RC

	//ROUND8
	//전 라운드에서 ROL8안했으므로 ROL8생략가능 
	MOVW TM0, X00   //0번째 블록을 워드단위로 옮김

	//RK xor  
	LD RK, Z+  
	EOR TM1, RK    //ROL8 안했으므로 상하위비트 위치 반전  
	LD RK, Z+   
	EOR TM0, RK
		
	//RC xor
	EOR X30, RC  
		 
	//ADD 연산
	ADD X30, TM1 //ROL8 안했으므로 상하위비트 위치 반전  
	ADC X31, TM0

	//ROL1
	LSL X30
	ROL X31
	ADC X30, R1

	INC RC

	CPSE RC,CNT   //RC와 CNT(88) 비교해서 같지않으면 LOOP로 점프, 같다면 RJMP 패스
	RJMP LOOP

	 //스택에 저장된 레지스터 pop , push순서 거꾸로
	POP R27
	POP R26

	ST Y+, X00  //Ypointer로 암호문 저장
	ST Y+, X01
	ST Y+, X10
	ST Y+, X11 
	ST Y+, X20
	ST Y+, X21
	ST Y+, X30
	ST Y+, X31

	 //스택에 저장된 레지스터 pop , push순서 거꾸로
	POP R29 
	POP R28
	
	POP R17
	POP R16


	RET