#include<stdint.h>
#include<stdio.h>
#include<stdbool.h>

#define RS1_ST 2
#define RS1_EN 3
#define RS2_ST 0
#define RS2_EN 1
#define RD_ST 4
#define RD_EN 5
#define IMM_ST 0
#define IMM_EN 3
#define ADDR_ST 2
#define ADDR_EN 5
#define OP_ST 6
#define OP_EN 7

#define ADD 0x0
#define OUT 0x1
#define LI 0x2
#define BNER0 0x3

uint8_t PC = 0;
uint8_t R[4] = {0x00, 0x00, 0x00, 0x00};
uint8_t M[16] = {
        0x8a,/*10001010*/
        0x90,/*10010000*/
        0xa0,/*10100000*/
        0xb1,/*10110001*/
        0x17,/*00010111*/
        0x29,/*00101001*/
        0xd1,/*11010001*/
        0x48,/*01001000*/
        0xdf,/*11011111*/ };
bool done = false;

void decode_exec(uint8_t inst, bool *regwr, bool *memwr, uint8_t *wdata, uint8_t *mem_wdata, uint8_t *rd, uint8_t *addr){
        uint8_t src1, src2, imm, opcode;
        src1 = R[(inst >> RS1_ST) & 0x03];
        src2 = R[(inst >> RS2_ST) & 0x03];
        *rd = (uint8_t)((inst >> RD_ST) & 0x03);
        imm = (uint8_t)((inst >> IMM_ST) & 0x0f);
        opcode = (uint8_t)((inst >> OP_ST) & 0x03);
            switch(opcode){
                    case ADD :
                            *regwr = true;
                            *memwr = false;
                            *wdata = src1 + src2; 
                            *addr = PC + 1;
                            break;
                    case OUT :
                            *regwr = false;
                            *memwr = true;
                            *mem_wdata = src1;
                            *addr = PC + 1;
                            break;
                    case LI :
                            *regwr = true;
                            *memwr = false;
                            *wdata = imm; 
                            *addr = PC + 1;
                            break;
                    case BNER0 :
                            *regwr = false;
                            *memwr = false;
                            *addr = (R[0] != src2) ? (uint8_t)((inst >> ADDR_ST) & 0x0f) : PC + 1;
                            break;
                    default : *regwr = false; break;
            }
        //printf("inst = 0x%02x, src1 = 0x%02x, src2 = 0x%02x, rd = 0x%1x, wdata = 0x%02x, imm = 0x%08x, opcode = 0x%08x\n", inst, src1, src2, *rd, *wdata, imm, opcode);
        //printf("regwr = %s\n", *regwr ? "true" : "false");
       return;
}

void inst_cycle(){
        bool regwr, memwr;
        uint8_t wdata, mem_wdata, addr, rd;
        decode_exec(M[PC], &regwr, &memwr, &wdata, &mem_wdata, &rd, &addr);
        if(memwr) printf("0x%02x\n", mem_wdata);
        if(regwr) R[rd] = wdata;
        if(M[PC] == 0xdf) done = true ;
        PC = addr;
}

void R_out(){
        for(int i = 0; i < 4; i++){
                printf("R[%d] = 0x%02x   ", i, R[i]);
        }
        printf("\n");
}

int main(){
        while(1){
                //printf("=============================\n");
                inst_cycle();
                //R_out();
                //printf("done = %s\n", done? "true" : "false");
                if(done) break;
                //break;
        }
        return 0;
}

