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
        uint32_t pc;
        uint32_t gpr[16];
} cpu;

char *gpr_name[16] = {"$0", "ra", "sp", "gp", "tp", "t0", "t1", "t2", "s0", "s1", "a0", "a1", "a2", "a3", "a4", "a5"};
        

//#define HALT_ADDR 0x224 //sum
//char *img_file = "/home/shaw/ysyx/ysyx-E/minirvEMU/img/sum.bin";
//char *diff_file = "/home/shaw/ysyx/ysyx-E/minirvEMU/sum_diff";

#define HALT_ADDR 0x1218 //mem
char *img_file = "/home/shaw/ysyx/ysyx-E/minirvEMU/img/mem.bin";
char *diff_file = "/home/shaw/ysyx/ysyx-E/minirvEMU/mem_diff";
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
      M[HALT_ADDR] = 0x73;
      M[HALT_ADDR+1] = 0x00;
      M[HALT_ADDR+2] = 0x10;
      M[HALT_ADDR+3] = 0x00;

      fclose(fp);
      return size;
} 

//void read_dif(FILE **fp, char *read){
//    FILE *f = *fp;
//    char buf[256];
//    fgets(buf, sizeof(buf), f); // 读第 1 行
//    memcpy(read, buf, sizeof(buf));
//    *fp = f;
//}

void jmp_fp(FILE **fp, int n){
    FILE *f = *fp;
    for(int i = 0; i < n; i++){
        int c;
        while ((c = fgetc(f)) != EOF) {
            if (c == '\n')
                break;
        }
    }
    *fp = f;
}

void diff_out(uint32_t pc, uint32_t inst){
        printf("inst = 0x%08x\n", inst);
        printf("dut :\n");
        printf("pc = 0x%08x\n", pc);
        for(int i = 0; i < 16; i ++){
                printf("%-3s = 0x%08x  ", gpr_name[i], R[i]);
                if(i % 4 == 0 && i != 0) printf("\n");
        }
        printf("\n");
        printf("ref :\n");
        printf("pc = 0x%08x\n", ref_cpu.pc);
        for(int i = 0; i < 16; i ++){
                printf("%-3s = 0x%08x  ", gpr_name[i], ref_cpu.gpr[i]);
                if(i % 4 == 0 && i != 0) printf("\n");
        }
        printf("\n");
}

void difftest_step(FILE **fp, uint32_t pc, uint32_t inst){
        FILE *f = *fp;
        cpu dut_cpu;
        dut_cpu.pc = pc;
        char line[256] = {};
        for(int i = 0; i < 16; i++){
                dut_cpu.gpr[i] = R[i];
        }
        for(int i = 0; i < 16; i++){
                fgets(line, sizeof(line), f);
                uint32_t value;
                char *p = strstr(line, "0x");
                assert(p);
                sscanf(p, "0x%08x", &value);
                ref_cpu.gpr[i] = value;
        }
        jmp_fp(&f, 16);
        fgets(line, sizeof(line), f);
        uint32_t value;
        char *p = strstr(line, "0x");
        assert(p);
        sscanf(p, "0x%08x", &value);
        ref_cpu.pc = value;
        *fp = f;

        if(ref_cpu.pc != dut_cpu.pc){
                diff_out(pc, inst);
                assert(0);
        }
        for(int i = 0; i < 16; i++){
                if(ref_cpu.gpr[i] != dut_cpu.gpr[i]){
                        diff_out(pc, inst);
                        assert(0);
                 }
        }
        return;
}

int read_mem(uint32_t *rdata, uint32_t addr, uint8_t len){
        //for(int i = 0; i < 10; i++){
        //        printf("M[%d] = 0x%02x\n", addr + i, M[addr + i]);
        //}
        *rdata = len == 1 ? (uint32_t)M[addr] & 0x000000ff:
                 len == 2 ? ((uint32_t)M[addr] & 0x000000ff) | (((uint32_t)M[addr+1] & 0x000000ff) << 8) :
                 len == 4 ?  ((uint32_t)M[addr  ] & 0x000000ff) | 
                            (((uint32_t)M[addr+1] & 0x000000ff) << 8 ) |
                            (((uint32_t)M[addr+2] & 0x000000ff) << 16) |
                            (((uint32_t)M[addr+3] & 0x000000ff) << 24)    : 0;
        //printf("len = %d\n", len);
        //printf("mem_rdata = 0x%08x\n", *rdata);
        //printf("M[%d] = 0x%08x\n", addr, M[addr]);
        //printf("M[%d] = 0x%08x\n", addr+1, M[addr+1]);
        //printf("M[%d] = 0x%08x\n", addr+2, M[addr+2]);
        //printf("M[%d] = 0x%08x\n", addr+3, M[addr+3]);
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
                *reg_wdata = (uint32_t)((int32_t)src1 + (int32_t)src2);
                *mem_wdata = 0;
                *npc = PC + 4;
        } else if(opcode == 0b0010011 && funct3 == 0b000){
                addi = true;
                imm = (int32_t)inst >> 20;
                *regwr = true;
                *memwr = false;
                *reg_wdata = (uint32_t)((int32_t)src1 + (int32_t)imm);
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
                imm = (int32_t)inst >> 20;
                *regwr = true;
                *memwr = false;
                read_mem(&rdata, (uint32_t)((int32_t)src1 + (int32_t)imm), 4);
                *reg_wdata = rdata;
                *mem_wdata = 0;
                *npc = PC + 4;
        } else if(opcode == 0b0000011 && funct3 == 0b100){
                lbu = true;
                imm = (int32_t)inst >> 20;
                *regwr = true;
                *memwr = false;
                read_mem(&rdata, (uint32_t)((int32_t)src1 + (int32_t)imm), 1);
                *reg_wdata = rdata;
                *mem_wdata = 0;
                *npc = PC + 4;
        } else if(opcode == 0b0100011 && funct3 == 0b000){
                sb = true;
                imm = (uint32_t)(((inst >> 7) & 0x0000001f) | (((int32_t)inst >> 20) & 0xffffffe0));
                *regwr = false;
                *memwr = true;
                *mem_waddr = (uint32_t)((int32_t)imm + (int32_t)src1);
                *len = 1;
                *reg_wdata = 0;
                *mem_wdata = (uint32_t)((src2 << 24) >> 24);
                *npc = PC + 4;
        } else if(opcode == 0b0100011 && funct3 == 0b010){
                sw = true;
                imm = (uint32_t)(((inst >> 7) & 0x0000001f) | (((int32_t)inst >> 20) & 0xffffffe0));
                *regwr = false;
                *memwr = true;
                *mem_waddr = (uint32_t)((int32_t)imm + (int32_t)src1);
                *len = 4;
                *reg_wdata = 0;
                *mem_wdata = src2;
                *npc = PC + 4;
        } else if(opcode == 0b1100111 && funct3 == 0b000){
                jalr= true;
                imm = (int32_t)inst >> 20;
                *regwr = true;
                *memwr = false;
                *reg_wdata = PC + 4;
                *mem_wdata = 0;
                *npc = (uint32_t)(((int32_t)src1 + (int32_t)imm) & 0xfffffffe);
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

uint32_t inst_cycle(uint32_t *ins){
        bool regwr, memwr;
        uint32_t reg_wdata, mem_wdata, mem_waddr, npc, rd;
        uint32_t inst;
        uint8_t len;
        read_mem(&inst, PC, 4); 
        //printf("pc = 0x%08x, inst = 0x%08x\n", PC, inst);
        decode_exec(inst, &regwr, &memwr, &reg_wdata, &mem_wdata, &mem_waddr, &len, &rd, &npc);
        if(regwr) R[rd] = reg_wdata;
        R[0] = 0;
        if(memwr) write_mem(mem_wdata, mem_waddr, len);
        if(ebreak) done = true ;
        uint32_t t = PC;
        PC = npc;
        *ins = inst;
        return t;
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
        FILE *diff = fopen(diff_file, "rb");
        while(1){
                uint32_t inst;
                char dif_buf[256] = {};
                //printf("=============================\n");
                uint32_t temp_pc = inst_cycle(&inst);
                if(!ebreak)difftest_step(&diff, temp_pc, inst);
                //R_out();
                if(done) printf("done\n");
                if(done) break;
                //break;
        }
        fclose(diff);
        return 0;
}

