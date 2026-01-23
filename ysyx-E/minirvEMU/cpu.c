#include<stdint.h>
#include<stdio.h>
#include<string.h>
#include<stdbool.h>
#include<assert.h>

#define MEM_SIZE 0xf0000 

#define RS1_ST 15 
#define RS2_ST 20
#define RD_ST 7
#define FUNCT3_ST 12 
#define FUNCT7_ST 25
#define OPCODE_ST 0

typedef struct {
        uint32_t pc,
        uint32_t gpr[16]
} cpu;
        

char *img_file = "/home/shaw/ysyx/ysyx-E/minirvEMU/img/sum.bin";
char *diff_file = "/home/shaw/ysyx/ysyx-E/minirvEMU/sum_diff";
cpu ref_cpu;
FILE *dif = NULL;
uint32_t PC = 0x00000000;
uint32_t R[16] = {};
uint8_t M[MEM_SIZE] = {};
bool done = false;
int ebreak = 0;

long load_img(){
      assert(img_file);
      
      FILE *fp = fopen(img_file, "rb");
      assert(fp);

      fseek(fp, 0, SEEK_END);
      long size = ftell(fp);
      printf("The image size = %ld\n", size);

      fseek(fp, 0, SEEK_SET);
      int ret = fread(M, size, 1, fp);
      assert(ret == 1);

      fclose(fp);
      return size;
} 

void read_dif(FILE *fp, char *read){
    char buf[256];
    fgets(buf, sizeof(buf), fp); // 读第 1 行
    memcpy(read, buf, sizeof(buf));
}

void jmp_fp(FILE* fp, int n){
    for(int i = 0; i < n; i++){
        int c;
        while ((c = fgetc(fp)) != EOF) {
            if (c == '\n')
                break;
        }
    }
}

int read_mem(uint32_t *rdata, uint32_t addr, uint8_t len){
        //for(int i = 0; i < 10; i++){
        //        printf("M[%d] = 0x%02x\n", addr + i, M[addr + i]);
        //}
        *rdata = len == 1 ? (uint32_t)M[addr]        :
                 len == 2 ? (uint32_t)M[addr] | (uint32_t)(M[addr+1] << 8) :
                 len == 4 ? (uint32_t)M[addr] | (uint32_t)(M[addr+1] << 8) | (uint32_t)(M[addr+2] << 16) | (uint32_t)(M[addr+3] << 24) : (uint32_t)0;
        return len > 4;
} 

int write_mem(uint32_t wdata, uint32_t addr, uint8_t len){
        if(len == 1){
                M[addr] = (uint8_t)wdata;
        } else if(len == 2){
                M[addr] = (uint8_t)((uint32_t)(wdata << 24) >> 24);
                M[addr+1] = (uint8_t)((uint32_t)(wdata << 16) >> 24);
        } else if(len == 4){
                M[addr  ] = (uint8_t)((uint32_t)(wdata << 24) >> 24);
                M[addr+1] = (uint8_t)((uint32_t)(wdata << 16) >> 24);
                M[addr+2] = (uint8_t)((uint32_t)(wdata << 8 ) >> 24);
                M[addr+3] = (uint8_t)((uint32_t)(wdata      ) >> 24);
        } else{
                return 1;
        }
        return 0;
} 
      

void decode_exec(uint32_t inst, bool *regwr, bool *memwr, uint32_t *reg_wdata, uint32_t *mem_wdata, uint32_t *mem_waddr, uint8_t *len, uint32_t *rd, uint32_t *npc){
        uint32_t rdata = 0;
        uint32_t src1, src2, imm;
        uint32_t opcode, funct3, funct7;
        src1 = R[(inst >> RS1_ST) & 0x0000001f];
        src2 = R[(inst >> RS2_ST) & 0x0000001f];
        *rd = (uint32_t)((inst >> RD_ST) & 0x0000001f);
        opcode = (uint32_t)((inst >> OPCODE_ST) & 0x0000007f);
        funct3 = (uint32_t)((inst >> FUNCT3_ST) & 0x00000007);
        funct7 = (uint32_t)((inst >> FUNCT7_ST) & 0x0000007f);
        bool add, addi, lui, lw, lbu, sb, sw, jalr = false;
        if(opcode == 0b0110011 && funct3 == 0b000 && funct7 == 0b0000000){
                add = true;
                imm = 0; 
                *regwr = true;
                *memwr = false;
                *reg_wdata = src1 + src2;
                *mem_wdata = 0;
                *npc = PC + 4;
        } else if(opcode == 0b0010011 && funct3 == 0b000){
                addi = true;
                imm = (uint32_t)((inst >> 20) & 0x00000fff);
                *regwr = true;
                *memwr = false;
                *reg_wdata = src1 + imm;
                *mem_wdata = 0;
                *npc = PC + 4;
        } else if(opcode == 0b0110111){
                lui = true;
                imm = (uint32_t)(inst & 0xfffff000);
                *regwr = true;
                *memwr = false;
                *reg_wdata = imm;
                *mem_wdata = 0;
                *npc = PC + 4;
        } else if(opcode == 0b0000011 && funct3 == 0b010){
                lw = true;
                imm = (uint32_t)((inst >> 20) & 0x00000fff);
                *regwr = true;
                *memwr = false;
                read_mem(&rdata, src1 + imm, 4);
                *reg_wdata = rdata;
                *mem_wdata = 0;
                *npc = PC + 4;
        } else if(opcode == 0b0000011 && funct3 == 0b100){
                lbu = true;
                imm = (uint32_t)((inst >> 20) & 0x00000fff);
                *regwr = true;
                *memwr = false;
                read_mem(&rdata, src1 + imm, 1);
                *reg_wdata = rdata;
                *mem_wdata = 0;
                *npc = PC + 4;
        } else if(opcode == 0b0100011 && funct3 == 0b000){
                sb = true;
                imm = (uint32_t)(((inst >> 6) & 0x0000001f) | ((inst >> 20) & 0x0000007f));
                *regwr = false;
                *memwr = true;
                *mem_waddr = imm + src1;
                *len = 1;
                *reg_wdata = 0;
                *mem_wdata = (uint32_t)((src2 << 24) >> 24);
                *npc = PC + 4;
        } else if(opcode == 0b0100011 && funct3 == 0b010){
                sw = true;
                imm = (uint32_t)(((inst >> 6) & 0x0000001f) | ((inst >> 20) & 0x0000007f));
                *regwr = false;
                *memwr = true;
                *mem_waddr = imm + src1;
                *len = 4;
                *reg_wdata = 0;
                *mem_wdata = src2;
                *npc = PC + 4;
        } else if(opcode == 0b1100111 && funct3 == 0b000){
                jalr= true;
                imm = (uint32_t)((inst >> 20) & 0x0000000fff);
                *regwr = true;
                *memwr = false;
                *reg_wdata = PC + 4;
                *mem_wdata = 0;
                *npc = (src1 + imm) & 0xfffffffe;
        } else if(inst == 0x00100073){
                ebreak = 1;
                *regwr = false;
                *memwr = false;
        } else{
                printf("undecode inst : 0x%08x\n", inst);
                assert(0);
                return;
        }
        //printf("inst = 0x%02x, src1 = 0x%02x, src2 = 0x%02x, rd = 0x%1x, wdata = 0x%02x, imm = 0x%08x, opcode = 0x%08x\n", inst, src1, src2, *rd, *wdata, imm, opcode);
        //printf("regwr = %s\n", *regwr ? "true" : "false");
       return;
}

void inst_cycle(){
        bool regwr, memwr;
        uint32_t reg_wdata, mem_wdata, mem_waddr, npc, rd;
        uint32_t inst;
        uint8_t len;
        read_mem(&inst, PC, 4); 
        printf("pc = 0x%08x, inst = 0x%08x\n", PC, inst);
        decode_exec(inst, &regwr, &memwr, &reg_wdata, &mem_wdata, &mem_waddr, &len, &rd, &npc);
        if(regwr) R[rd] = reg_wdata;
        R[0] = 0;
        if(memwr) write_mem(mem_wdata, mem_waddr, len);
        if(ebreak) done = true ;
        PC = npc;
}

void R_out(){
        for(int i = 0; i < 16; i++){
                printf("R[%d] = 0x%08x   ", i, R[i]);
        }
        printf("\n");
}

int main(){
        memset(M, 0, sizeof(M));
        memset(R, 0, sizeof(R));
        load_img();
        while(1){
                //printf("=============================\n");
                inst_cycle();
                //R_out();
                if(done) printf("done\n");
                if(done) break;
                //break;
        }
        return 0;
}

