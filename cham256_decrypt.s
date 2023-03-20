	.global cham256_decrypt
	.type cham256_decrypt, @function

	//암호문이 128비트이므로 총 16개의 레지스터가 평문 연산에 필요
	#define Y00 R18 
	#define Y01 R19
	#define Y02 R20 
	#define Y03 R21
	#define Y10 R22 
	#define Y11 R23
	#define Y12 R24 
	#define Y13 R25

	#define Y20 R8 
	#define Y21 R9
	#define Y22 R10 
	#define Y23 R11
	#define Y30 R12 
	#define Y31 R13
	#define Y32 R14 
	#define Y33 R15

	//32비트단위의 연산이므로 연산에 필요할 레지스터 4개 필요
	#define TM0 R2
	#define TM1 R3
	#define TM2 R26
	#define TM3 R27

	#define RC R17 
	#define RK R0

	#define CNT R16

	cham256_decrypt:
	
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

	MOVW R28, R24   // derypted ypointer
	MOVW R26, R22   // ct xpointer
	MOVW R30, R20   // rks zpointer

	LD Y00, X+   //xpointer를 이용하여 복호화할 암호문 로드
	LD Y01, X+
	LD Y02, X+
	LD Y03, X+
	LD Y10, X+
	LD Y11, X+
	LD Y12, X+
	LD Y13, X+
	LD Y20, X+
	LD Y21, X+
	LD Y22, X+
	LD Y23, X+
	LD Y30, X+
	LD Y31, X+
	LD Y32, X+
	LD Y33, X+

	PUSH R26
	PUSH R27

	LDI RC, 120 //120라운드
	CLR CNT
	LOOP:
	//rk = (rk == (const uint32_t*) rks) ? rk + 8 : rk - 8
	ANDI R30, 63
	SUBI R30, -32
	//ROUND 1
	MOVW TM0, Y00 //0번째 블록을 워드단위로 옮김 (32비트임으로 총 두번)
	MOVW TM2, Y02
	
	LD RK, -Z     //ROL8 안했으므로 위치 고려하여 연산 (3,2,1,0->2,1,0,3순서)
	EOR TM2, RK
	LD RK, -Z
	EOR TM1, RK
	LD RK, -Z 
	EOR TM0, RK
	LD RK, -Z
	EOR TM3, RK

	//ROR1
	BST Y30, 0
	LSR Y33
	ROR Y32
	ROR Y31 
	ROR Y30
	BLD Y33, 7

	//SUB, ROL8 안했으므로 위치 고려하여 연산 (3,2,1,0->2,1,0,3순서)
	SUB Y30, TM3
	SBC Y31, TM0  
	SBC Y32, TM1
	SBC Y33, TM2

	DEC RC
	EOR Y30, RC 

	//ROUND 2
	MOVW TM0, Y30  //3번째 블록을 워드단위로 옮김 (32비트임으로 총 두번)
	MOVW TM2, Y32

	//ROL1
	LSL TM0
	ROL TM1
	ROL TM2
	ROL TM3
	ADC TM0, R1

	//RK XOR 
	LD RK, -Z
	EOR TM3, RK
	LD RK, -Z
	EOR TM2, RK
	LD RK, -Z 
	EOR TM1, RK
	LD RK, -Z
	EOR TM0, RK

    //ROR8 생략

    //SUB, ROR 8을 생략하였으므로 위치 고려하여 연산(3,2,1,0 -> 0,3,2,1)
	SUB Y21, TM0
	SBC Y22, TM1  
	SBC Y23, TM2
	SBC Y20, TM3

	//RC XOR 
	DEC RC
	EOR Y21, RC    //ROR 8을 생략하였으므로 위치 고려하여 연산(3,2,1,0 -> 0,3,2,1)

	//ROUND 3
	//전(2) 라운드에서 ROR8 생략했으므로 ROL8도 생략가능
	MOVW TM0, Y20  //2번째 블록을 워드단위로 옮김 (32비트임으로 총 두번)
	MOVW TM2, Y22

	//RK XOR
	LD RK, -Z 
	EOR TM3, RK
	LD RK, -Z
	EOR TM2, RK
	LD RK, -Z 
	EOR TM1, RK
	LD RK, -Z
	EOR TM0, RK
	
	//ROR1
	BST Y10, 0
	LSR Y13
	ROR Y12
	ROR Y11 
	ROR Y10
	BLD Y13, 7

	//SUB
	SUB Y10, TM0 
	SBC Y11, TM1  
	SBC Y12, TM2
	SBC Y13, TM3

	DEC RC
	EOR Y10, RC

	//ROUND 4
	MOVW TM0, Y10  //1번째 블록을 워드단위로 옮김 (32비트임으로 총 두번)
	MOVW TM2, Y12

	//ROL1
	LSL TM0
	ROL TM1
	ROL TM2
	ROL TM3
	ADC TM0, R1

	//RK XOR 
	LD RK, -Z
	EOR TM3, RK
	LD RK, -Z
	EOR TM2, RK
	LD RK, -Z 
	EOR TM1, RK
	LD RK, -Z
	EOR TM0, RK

	//ROR8 생략

	//SUB, ROR 8을 생략하였으므로 위치 고려하여 연산(3,2,1,0 -> 0,3,2,1)
	SUB Y01, TM0
	SBC Y02, TM1
	SBC Y03, TM2
	SBC Y00, TM3

	DEC RC
	EOR Y01, RC  //ROR 8을 생략하였으므로 위치 고려하여 연산(3,2,1,0 -> 0,3,2,1)

	//ROUND 5 
	//전 라운드에서 ROR8 생략했으므로 ROL8도 생략가능
	MOVW TM0, Y00 //0번째 블록을 워드단위로 옮김 (32비트임으로 총 두번)
	MOVW TM2, Y02

	//RK XOR
	LD RK, -Z 
	EOR TM3, RK
	LD RK, -Z
	EOR TM2, RK
	LD RK, -Z 
	EOR TM1, RK
	LD RK, -Z
	EOR TM0, RK

	//ROR1
	BST Y30, 0
	LSR Y33
	ROR Y32
	ROR Y31 
	ROR Y30
	BLD Y33, 7

	//SUB 연산
	SUB Y30, TM0
	SBC Y31, TM1
	SBC Y32, TM2
	SBC Y33, TM3

	DEC RC
	EOR Y30, RC

	//ROUND 6
	MOVW TM0, Y30  //3번째 블록을 워드단위로 옮김 (32비트임으로 총 두번)
	MOVW TM2, Y32

	//ROL1
	LSL TM0
	ROL TM1
	ROL TM2
	ROL TM3
	ADC TM0, R1

	//RK XOR 
	LD RK, -Z
	EOR TM3, RK
	LD RK, -Z
	EOR TM2, RK
	LD RK, -Z 
	EOR TM1, RK
	LD RK, -Z
	EOR TM0, RK

	//ROR8 생략

	//전(2) 라운드에서도 ROL8안했으므로 상하위 반전 상태, 위치 고려하여 연산(3,2,1,0 -> 1,0,3,2)
	SUB Y22, TM0
	SBC Y23, TM1
	SBC Y20, TM2
	SBC Y21, TM3

	//전 라운드에서 안해준 ROR8과 이번 라운드 ROR8을 합춰 워드단위로 ROR8 수행
	MOVW TM0, Y22
	MOVW Y22, Y20
	MOVW Y20, TM0

	DEC RC
	EOR Y20, RC

	//ROUND 7
	//ROL 8
	MOV TM0, Y23 //2번째 블록을 옮김
	MOV TM1, Y20
	MOV TM2, Y21
	MOV TM3, Y22

	//RK XOR 
	LD RK, -Z
	EOR TM3, RK
	LD RK, -Z
	EOR TM2, RK
	LD RK, -Z 
	EOR TM1, RK
	LD RK, -Z
	EOR TM0, RK

	//ROR1
	BST Y10, 0
	LSR Y13
	ROR Y12
	ROR Y11 
	ROR Y10
	BLD Y13, 7

	//SUB 연산
	SUB Y10, TM0
	SBC Y11, TM1
	SBC Y12, TM2
	SBC Y13, TM3

	//RC XOR
	DEC RC
	EOR Y10, RC

	//ROUND 8
	MOVW TM0, Y10   //1번째 블록을 워드단위로 옮김 (32비트임으로 총 두번)
	MOVW TM2, Y12

	//ROL1
	LSL TM0
	ROL TM1
	ROL TM2
	ROL TM3
	ADC TM0, R1

	//RK XOR 
	LD RK, -Z
	EOR TM3, RK
	LD RK, -Z
	EOR TM2, RK
	LD RK, -Z 
	EOR TM1, RK
	LD RK, -Z
	EOR TM0, RK

	//SUB,전(4) 라운드에서도 ROL8안했으므로 상하위 반전 상태, 위치 고려하여 연산(3,2,1,0 -> 1,0,3,2)
	SUB Y02, TM0
	SBC Y03, TM1
	SBC Y00, TM2
	SBC Y01, TM3

	//전 라운드에서 안해준 ROR8과 이번 라운드 ROR8을 합춰 워드단위로 ROR8 수행
	MOVW TM0, Y02
	MOVW Y02, Y00
	MOVW Y00, TM0

	DEC RC
	EOR Y00, RC  
	SUBI R30, -32  //처음 포인터로 돌아옴

	CPSE RC,CNT //120라운드 다 돌았는지 확인,RC와 CNT(0) 비교해서 같지않으면 LOOP로 점프, 같다면 RJMP 패스
	RJMP LOOP

	//스택에 저장된 레지스터 pop , push순서 거꾸로
	POP R27
	POP R26

	ST Y+, Y00  //Ypointer로 복호문 저장
	ST Y+, Y01
	ST Y+, Y02
	ST Y+, Y03
	ST Y+, Y10
	ST Y+, Y11
	ST Y+, Y12
	ST Y+, Y13
	ST Y+, Y20
	ST Y+, Y21
	ST Y+, Y22
	ST Y+, Y23
	ST Y+, Y30
	ST Y+, Y31
	ST Y+, Y32
	ST Y+, Y33

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
	POP R3
	POP R2

	RET