
#include "CHAM.h"

extern void cham64_ctr(uint8_t* dst ,const uint8_t* iv, const uint8_t* rks, const uint8_t* table);
extern void cham64_pre_cal(uint8_t* dst, const uint8_t* iv, const uint8_t* rks);

static inline uint16_t rol16(uint16_t value, size_t rot)
{
	return (value << rot) | (value >> (16 - rot));
}

static inline uint16_t ror16(uint16_t value, size_t rot)
{
	return (value >> rot) | (value << (16 - rot));
}

static inline uint32_t rol32(uint32_t value, size_t rot)
{
	return (value << rot) | (value >> (32 - rot));
}

static inline uint32_t ror32(uint32_t value, size_t rot)
{
	return (value >> rot) | (value << (32 - rot));
}

void cham64_keygen(uint8_t* rks, const uint8_t* mk)
{
	const uint16_t* key = (uint16_t*) mk;
	uint16_t* rk = (uint16_t*) rks;

	for (size_t i = 0; i < 8; ++i) {
		rk[i] = key[i] ^ rol16(key[i], 1);
		rk[(i+8)^(0x1)] = rk[i] ^ rol16(key[i], 11);
		rk[i] ^= rol16(key[i], 8);
	}
	
}

void cham64_ctr_encrypt(uint8_t* dst, const uint8_t* src, const uint16_t src_len, const uint8_t* iv, const uint8_t* rks)
{
	uint8_t temp_input[8];
	uint8_t temp_output[8]={0};
	memcpy(temp_input,iv,8);
	
	uint16_t* temp_count=(uint16_t*)temp_input;
	
	for(int i=0;i<src_len/8;i++){
		cham64_encrypt(temp_output,temp_input,rks);   //iv를 encrypt
		
		for(int j=0;j<8;j++){
			dst[i*8+j] = temp_output[j]^src[i*8+j]; //encrypt 거친 iv와 pt xor
		}
		
		temp_count[0]++;            //counter 값 증가
	}
}

void cham128_keygen(uint8_t* rks, const uint8_t* mk)
{
	const uint32_t* key = (uint32_t*) mk;
	uint32_t* rk = (uint32_t*) rks;

	for (size_t i = 0; i < 4; ++i) {
		rk[i] = key[i] ^ rol32(key[i], 1);
		rk[(i+4)^(0x1)] = rk[i] ^ rol32(key[i], 11);
		rk[i] ^= rol32(key[i], 8);
	}
}

void cham128_ctr_encrypt(uint8_t* dst, const uint8_t* src, const uint16_t src_len, const uint8_t* iv, const uint8_t* rks)
{
	uint8_t temp_input[16];
	uint8_t temp_output[16]={0};
	memcpy(temp_input,iv,16);
	
	uint16_t* temp_count=(uint16_t*)temp_input;
	
	for(int i=0;i<src_len/16;i++){
		cham128_encrypt(temp_output,temp_input,rks);  //iv를 encrypt
		
		for(int j=0;j<16;j++){
			dst[i*16+j] = temp_output[j]^src[i*16+j]; //encrypt 거친 iv와 pt xor
		}
		
		temp_count[0]++;  //counter 값 증가
	}
}


void cham256_keygen(uint8_t* rks, const uint8_t* mk)
{
	const uint32_t* key = (uint32_t*) mk;
	uint32_t* rk = (uint32_t*) rks;

	for (size_t i = 0; i < 8; ++i) {
		rk[i] = key[i] ^ rol32(key[i], 1);
		rk[(i+8)^(0x1)] = rk[i] ^ rol32(key[i], 11);
		rk[i] ^= rol32(key[i], 8);
	}
	
}

void cham256_ctr_encrypt(uint8_t* dst, const uint8_t* src, const uint16_t src_len, const uint8_t* iv, const uint8_t* rks)
{
	uint8_t temp_input[16];
	uint8_t temp_output[16]={0};
	memcpy(temp_input,iv,16);
	
	uint16_t* temp_count=(uint16_t*)temp_input;
	
	for(int i=0;i<src_len/16;i++){
		cham256_encrypt(temp_output,temp_input,rks);   //iv를 encrypt
		
		for(int j=0;j<16;j++){
			dst[i*16+j] = temp_output[j]^src[i*16+j];   //encrypt 거친 iv와 pt xor
		}
		
		temp_count[0]++;  //counter 값 증가
	}
}

// EOF

