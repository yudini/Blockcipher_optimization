	.global cham256_encrypt
	.type cham256_encrypt, @function

	//평문이 128비트이므로 총 16개의 레지스터가 평문 연산에 필요
	#define X00 R18 
	#define X01 R19
	#define X02 R20 
	#define X03 R21
	#define X10 R22 
	#define X11 R23
	#define X12 R24 
	#define X13 R25

	#define X20 R8 
	#define X21 R9
	#define X22 R10 
	#define X23 R11
	#define X30 R12 
	#define X31 R13
	#define X32 R14 
	#define X33 R15

	//32비트단위의 연산이므로 연산에 필요할 레지스터 4개 필요
	#define TM0 R2
	#define TM1 R3
	#define TM2 R26
	#define TM3 R27

	#define RC R17
	#define RK R0

	#define CNT R16

	cham256_encrypt:

	//callee saved 레지스터 스택에 push
	PUSH R2
	PUSH R3
	PUSH R8
	PUSH R9
	PUSH R10
	PUSH R11
	PUSH R12
	PUSH R13
	PUSH R14
	PUSH R15
	PUSH R16
	PUSH R17
	PUSH R28
	PUSH R29

	MOVW R28, R24   // encrypted ypointer
	MOVW R26, R22   // pt xpointer
	MOVW R30, R20   // rks zpointer

	LD X00, X+ //xpointer를 이용하여 암호화할 평문 로드
	LD X01, X+
	LD X02, X+
	LD X03, X+
	LD X10, X+
	LD X11, X+
	LD X12, X+
	LD X13, X+	
	LD X20, X+
	LD X21, X+
	LD X22, X+
	LD X23, X+
	LD X30, X+
	LD X31, X+
	LD X32, X+
	LD X33, X+

	PUSH R26
	PUSH R27

	CLR RC 
	LDI CNT, 120 //120라운드

	LOOP:
	ANDI R30, 63 //연산할 키가 마지막 포인터에서 다시 처음으로 돌아오게 해주는 연산
				 // 8비트 64개이므로 ANDI 31 해줌
	//ROUND1	
	MOVW TM0, X10  //1번째 블록을 워드단위로 옮김 (32비트임으로 총 두번)
	MOVW TM2, X12

	//ROL 1
	LSL TM0
	ROL TM1
	ROL TM2
	ROL TM3
	ADC TM0, R1

	//RK XOR
	LD RK, Z+ 
	EOR TM0, RK
	LD RK, Z+
	EOR TM1, RK
	LD RK, Z+ 
	EOR TM2, RK
	LD RK, Z+
	EOR TM3, RK
		
	//RC xor
	EOR X00, RC

	//ADD
	ADD X00, TM0
	ADC X01, TM1
	ADC X02, TM2
	ADC X03, TM3

	//ROL8 생략 

    INC RC

	//ROUND2
	MOVW TM0, X20  //2번째 블록을 워드단위로 옮김 (32비트임으로 총 두번)
	MOVW TM2, X22 

	// ROL8생략

	//RK xor  
	LD RK, Z+  
	EOR TM3, RK  //ROL8 안했으므로 위치 고려하여 연산 (3,2,1,0->2,1,0,3순서)
	LD RK, Z+   
	EOR TM0, RK
	LD RK, Z+   
	EOR TM1, RK
	LD RK, Z+   
	EOR TM2, RK

	//RC xor
	EOR X10, RC  
		 
	//ADD 연산
	ADD X10, TM3   //ROL8 안했으므로 위치 고려하여 연산  (3,2,1,0->2,1,0,3순서)
	ADC X11, TM0
	ADC X12, TM1
	ADC X13, TM2

	//ROL1
	LSL X10
	ROL X11
	ROL X12
	ROL X13
	ADC X10, R1

	INC RC

	//ROUND3	
	MOVW TM0, X30  //3번째 블록을 워드단위로 옮김 (32비트임으로 총 두번)
	MOVW TM2, X32 

	//ROL 1
	LSL TM0
	ROL TM1
	ROL TM2
	ROL TM3
	ADC TM0, R1

	//RK XOR
	LD RK, Z+ 
	EOR TM0, RK
	LD RK, Z+
	EOR TM1, RK
	LD RK, Z+ 
	EOR TM2, RK
	LD RK, Z+
	EOR TM3, RK
		
	//RC xor
	EOR X20, RC

	//ADD
	ADD X20, TM0
	ADC X21, TM1
	ADC X22, TM2
	ADC X23, TM3

    INC RC

	//ROUND4
	MOVW TM0, X00   //0번째 블록을 워드단위로 옮김 (32비트임으로 총 두번)
	MOVW TM2, X02

	//RK xor  
	LD RK, Z+  //전(1) 라운드에서도 ROL8안했으므로 16비트 상하위 반전  //(3,2,1,0-> 1,0,3,2순서)
	EOR TM2, RK 
	LD RK, Z+   
	EOR TM3, RK
	LD RK, Z+  
	EOR TM0, RK 
	LD RK, Z+   
	EOR TM1, RK
		
	//RC xor
	EOR X30, RC  
		 
	//ADD 연산,전 라운드에서도 ROL8안했으므로 16비트 상하위 반전 //(3,2,1,0-> 1,0,3,2순서)
	ADD X30, TM2    
	ADC X31, TM3
	ADC X32, TM0
	ADC X33, TM1

	//ROL1
	LSL X30
	ROL X31
	ROL X32
	ROL X33
	ADC X30, R1

	INC RC

	//ROUND5
	MOVW TM0, X10   //1번째 블록을 워드단위로 옮김 (32비트임으로 총 두번)
	MOVW TM2, X12

	//ROL 1
	LSL TM0
	ROL TM1
	ROL TM2
	ROL TM3
	ADC TM0, R1

	//RK XOR
	LD RK, Z+ 
	EOR TM0, RK
	LD RK, Z+
	EOR TM1, RK
	LD RK, Z+ 
	EOR TM2, RK
	LD RK, Z+
	EOR TM3, RK
		
	//RC xor
	EOR X03, RC   //1라운드에서 ROL8 생략한 상태 (3,2,1,0)->(2,1,0,3)

	//ADD
	ADD X03, TM0 //1라운드에서 ROL8 생략한 상태,위치 고려하여 연산 (3,2,1,0)->(2,1,0,3)
	ADC X00, TM1
	ADC X01, TM2
	ADC X02, TM3

	MOVW TM0, X00   //1 라운드 ROL8과 합쳐 16비트 상하위 이동 
	MOVW X00, X02
	MOVW X02, TM0

    INC RC

	//ROUND6
	MOVW TM0, X20 //2번째 블록을 워드단위로 옮김 (32비트임으로 총 두번)
	MOVW TM2, X22 

	//ROL8생략

	//RK xor  
	LD RK, Z+  
	EOR TM2, RK  //전(2) 라운드에서도 ROL8안했으므로 16비트 상하위 반전  (3,2,1,0->1,0,3,2) 
	LD RK, Z+   
	EOR TM3, RK
	LD RK, Z+   
	EOR TM0, RK
	LD RK, Z+   
	EOR TM1, RK

	//RC xor
	EOR X10, RC  
		 
	//ADD 연산
	ADD X10, TM2  //전(2) 라운드에서도 ROL8안했으므로 16비트 상하위 반전  (3,2,1,0->1,0,3,2) 
	ADC X11, TM3
	ADC X12, TM0
	ADC X13, TM1

	//ROL1
	LSL X10
	ROL X11
	ROL X12
	ROL X13
	ADC X10, R1

	INC RC

	//ROUND7	
	MOVW TM0, X30  //3번째 블록을 워드단위로 옮김 (32비트임으로 총 두번)
	MOVW TM2, X32 

	//ROL 1
	LSL TM0
	ROL TM1
	ROL TM2
	ROL TM3
	ADC TM0, R1

	//RK XOR
	LD RK, Z+ 
	EOR TM0, RK
	LD RK, Z+
	EOR TM1, RK
	LD RK, Z+ 
	EOR TM2, RK
	LD RK, Z+
	EOR TM3, RK
	
	//RC xor
	EOR X23, RC  //전(2) 라운드에서도 ROL8안했으므로 고려하여 연산 (3,2,1,0->2,1,0,3)

	//ADD
	ADD X23, TM0  //전(2) 라운드에서도 ROL8안했으므로 고려하여 연산 (3,2,1,0->2,1,0,3)
	ADC X20, TM1
	ADC X21, TM2
	ADC X22, TM3

	MOVW TM0, X20  //2라운드에서 생략된 ROL8합쳐 16비트 상하위 ROL
	MOVW X20, X22
	MOVW X22, TM0

    INC RC

	//ROUND8
	MOVW TM0, X00    //0번째 블록을 워드단위로 옮김 (32비트임으로 총 두번)
	MOVW TM2, X02

	//ROL8 생략
	
	//RK xor  
	LD RK, Z+   
	EOR TM3, RK   //ROL8안했으므로 고려하여 연산(3,2,1,0->2,1,0,3)
	LD RK, Z+   
	EOR TM0, RK
	LD RK, Z+  
	EOR TM1, RK 
	LD RK, Z+   
	EOR TM2, RK
		
	//RC xor
	EOR X30, RC  
		 
	//ADD 연산, ROL8안했으므로 고려하여 연산(3,2,1,0->2,1,0,3) 
	ADD X30, TM3   
	ADC X31, TM0
	ADC X32, TM1
	ADC X33, TM2

	//ROL1
	LSL X30
	ROL X31
	ROL X32
	ROL X33
	ADC X30, R1

	INC RC

	CPSE RC,CNT   //RC와 CNT(120) 비교해서 같지않으면 LOOP로 점프, 같다면 RJMP 패스
	RJMP LOOP

	POP R27
	POP R26

	ST Y+, X00 //Ypointer로 암호문 저장
	ST Y+, X01
	ST Y+, X02
	ST Y+, X03
	ST Y+, X10
	ST Y+, X11
	ST Y+, X12
	ST Y+, X13
	ST Y+, X20
	ST Y+, X21
	ST Y+, X22
	ST Y+, X23
	ST Y+, X30
	ST Y+, X31
	ST Y+, X32
	ST Y+, X33

	  //스택에 저장된 레지스터 pop , push순서 거꾸로
	POP R29
	POP R28
	POP R17
	POP R16
	POP R15
	POP R14
	POP R13
	POP R12
	POP R11
	POP R10
	POP R9
	POP R8
	POP R2
	POP R3


	RET
