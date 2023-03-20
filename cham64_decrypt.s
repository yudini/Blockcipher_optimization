	.global cham64_decrypt
	.type cham64_decrypt, @function

	//암호문이 64비트이므로 총 8개의 레지스터가 평문 연산에 필요
	#define Y00 R18 
	#define Y01 R19
	#define Y10 R20 
	#define Y11 R21
	#define Y20 R22 
	#define Y21 R23
	#define Y30 R24 
	#define Y31 R25

	//16비트단위의 연산이므로 연산에 필요할 레지스터 2개 필요
	#define TM0 R26
	#define TM1 R27

	#define RC R17
	#define RK R0

	#define CNT R16

	cham64_decrypt:

	//callee saved 레지스터 스택에 push
	PUSH R16
	PUSH R17

	PUSH R28
	PUSH R29

	MOVW R28, R24   // derypted ypointer
	MOVW R26, R22   // ct xpointer
	MOVW R30, R20   // rks zpointer

	LD Y00, X+ //xpointer를 이용하여 복호화할 암호문 로드
	LD Y01, X+
	LD Y10, X+
	LD Y11, X+
	LD Y20, X+
	LD Y21, X+
	LD Y30, X+
	LD Y31, X+ 

	PUSH R26
	PUSH R27
	
	LDI RC, 88  //88라운드
	CLR CNT
	LOOP:
	 // rk = (rk == (const uint16_t*) rks) ? rk + 8 : rk - 8
	ANDI R30, 31  
	SUBI R30, -16 

	//ROUND 1
	//ROL 8 생략
	MOV TM0,Y01  // 1번째 블록을 워드단위로 옮김 ROL8생략했으므로 순서 바꿔 mov
	MOV TM1,Y00

	//RK와 XOR
	LD RK, -Z   
	EOR TM1, RK
	LD RK, -Z 
	EOR TM0, RK    
		
	//ROR 1
	BST Y30, 0
	LSR Y31
	ROR Y30
	BLD Y31, 7  

	//SUB 연산
	SUB Y30, TM0
	SBC Y31, TM1

	//--rc와 xor
	DEC RC
	EOR Y30, RC

	//ROUND 2
	MOVW TM0,Y30  // 3번째 블록을 워드단위로 옮김
		 
	//ROL 1
	LSL TM0
	ROL TM1
	ADC TM0, R1

	//rk와 xor
	LD RK, -Z
	EOR TM1, RK
	LD RK, -Z 
	EOR TM0, RK 

	//ROR8 생략

	//SUB 연산,  //ROL8 안했으므로 상하위비트 위치 반전  
	SUB Y21, TM0
	SBC Y20, TM1 

	//--rc xor
	DEC RC
	EOR Y21, RC   //ROL8 안했으므로 상하위비트 위치 반전  

	//ROUND 3
	//ROL 8, 전 라운드에서 ror8생략했으므로 그대로 가져오면 rol8을 하는것과 같음
	MOVW TM0, Y20  // 2번째 블록을 워드단위로 옮김
	
	//RK XOR
	LD RK, -Z
	EOR TM1, RK
	LD RK, -Z 
	EOR TM0, RK    
		
	//ROR 1
	BST Y10, 0
	LSR Y11
	ROR Y10
	BLD Y11, 7  

	//SUB연산
	SUB Y10, TM0
	SBC Y11, TM1

	//--rc xor
	DEC RC
	EOR Y10, RC

	//ROUND 4
	MOVW TM0,Y10  // 1번째 블록을 워드단위로 옮김
		 
	//ROL 1
	LSL TM0
	ROL TM1
	ADC TM0, R1

	//rk와 xor
	LD RK, -Z
	EOR TM1, RK
	LD RK, -Z 
	EOR TM0, RK 

	//ROR8 생략

	//SUB 연산, ROL8 안했으므로 상하위비트 위치 반전  
	SUB Y01, TM0
	SBC Y00, TM1 

	//--rc xor
	DEC RC
	EOR Y01, RC //ROL8 안했으므로 상하위비트 위치 반전  

	//ROUND 5
	//전 라운드에서 ROR8 생략했으므로 ROL8도 생략가능
	MOVW TM0, Y00  // 0번째 블록을 워드단위로 옮김

	//RK XOR
	LD RK, -Z 
	EOR TM1, RK
	LD RK, -Z
	EOR TM0, RK

	//ROR1
	BST Y30, 0
	LSR Y31
	ROR Y30
	BLD Y31, 7  

	//SUB 연산
	SUB Y30, TM0
	SBC Y31, TM1

	//--RC XOR
	DEC RC
	EOR Y30, RC

	//ROUND 6
	MOVW TM0, Y30  // 3번째 블록을 워드단위로 옮김

	//ROL1
	LSL TM0
	ROL TM1
	ADC TM0, R1

	//RK XOR 
	LD RK, -Z 
	EOR TM1, RK
	LD RK, -Z
	EOR TM0, RK

	//ROR 8 생략

	//2라운드에서 ROR8 생략했으므로 그대로 SUB 연산
	SUB Y20, TM0
	SBC Y21, TM1

	DEC RC
	EOR Y20, RC

	//ROUND 7
	//ROL 8 
	MOV TM0, Y21 // 2번째 블록을 워드단위로 옮김 ROL8생략했으므로 순서 바꿔 mov
	MOV TM1, Y20

	//RK XOR 
	LD RK, -Z 
	EOR TM1, RK
	LD RK, -Z
	EOR TM0, RK

	//ROR1
	BST Y10, 0
	ROR Y11 
	ROR Y10
	BLD Y11, 7

	//SUB 연산
	SUB Y10, TM0
	SBC Y11, TM1

	//--RC XOR
	DEC RC
	EOR Y10, RC

	//ROUND 8
	MOVW TM0, Y10  // 1번째 블록을 워드단위로 옮김

	//ROL1
	LSL TM0
	ROL TM1
	ADC TM0, R1

	//RK XOR 
	LD RK, -Z 
	EOR TM1, RK
	LD RK, -Z
	EOR TM0, RK

	//ROR 생략

	//ROR8 대신 위치 맞춰 연산
	SUB Y00, TM0
	SBC Y01, TM1

	DEC RC
	EOR Y00, RC  

	SUBI R30, -16  //처음 포인터로 돌아옴

	CPSE RC,CNT   //88라운드 다 돌았는지 확인,RC와 CNT(0) 비교해서 같지않으면 LOOP로 점프, 같다면 RJMP 패스
	RJMP LOOP

	//스택에 저장된 레지스터 pop , push순서 거꾸로
	POP R27
	POP R26

	ST Y+, Y00  //Ypointer로 복호문 저장
	ST Y+, Y01
	ST Y+, Y10
	ST Y+, Y11
	ST Y+, Y20
	ST Y+, Y21
	ST Y+, Y30
	ST Y+, Y31

	//스택에 저장된 레지스터 pop , push순서 거꾸로
	POP R29
	POP R28
	
	POP R17
	POP R16

	RET