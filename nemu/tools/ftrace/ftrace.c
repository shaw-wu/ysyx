#include <stdint.h>
#include <stdbool.h>
#include <isa.h>
#include <stdio.h>
#include <string.h>
#include <assert.h>
#include <stdlib.h>

#define FTMEM_SIZE 256

typedef struct {
  unsigned char e_ident[16];     // 0x00
  uint16_t e_type;               // 0x10
  uint16_t e_machine;            // 0x12
  uint32_t e_version;            // 0x14
  uint32_t e_entry;              // 0x18
  uint32_t e_phoff;              // 0x1C
  uint32_t e_shoff;              // 0x20 
  uint32_t e_flags;              // 0x24
  uint16_t e_ehsize;             // 0x28
  uint16_t e_phentsize;          // 0x2A
  uint16_t e_phnum;              // 0x2C
  uint16_t e_shentsize;          // 0x2E
  uint16_t e_shnum;              // 0x30 
  uint16_t e_shstrndx;           // 0x32 
} Elf32_Ehdr;

typedef struct {
  uint32_t sh_name;       // 名称在 .shstrtab 中的偏移
  uint32_t sh_type;
  uint32_t sh_flags;
  uint32_t sh_addr;
  uint32_t sh_offset;     // 文件中数据偏移
  uint32_t sh_size;       // 大小
  uint32_t sh_link;       // 对于 .symtab，这里是 .strtab 的节区索引
  uint32_t sh_info;
  uint32_t sh_addralign;
  uint32_t sh_entsize;    // 每个表项大小（如符号大小）
} Elf32_Shdr;

typedef struct {
  uint32_t st_name;  // 在 .strtab 中的偏移
  uint32_t st_value;
  uint32_t st_size;
  uint8_t  st_info;
  uint8_t  st_other;
  uint16_t st_shndx;
} Elf32_Sym;

typedef struct {
	uint32_t addr;
	uint32_t target;
	char str[64];
	bool iscall;
	bool isret;
} ft;
ft Ft_mem[FTMEM_SIZE] = {};
int ft_ind = 0;
int ft_num = 0;

char* elf_file = NULL;
bool have_img = false;

Elf32_Sym* symtab = NULL; 
char **sym_name = NULL;
int func_count = -1; 

long check_Sh(FILE* elf, uint32_t shoff, uint16_t shentsize, uint16_t shnum, uint16_t shstrndx, long* sym_offset, uint32_t* sym_size, uint32_t* sym_entsize) {
  long offset = (long)shoff;
  Elf32_Shdr Shtmp = {};
	Elf32_Shdr symtab = {};
	Elf32_Shdr strtab = {};
	Elf32_Shdr shstrtab = {};
  char sh_strname[64] = {};
	memset(sh_strname, '\0', sizeof(sh_strname));

  //定位并读取 shstrtab 节头
  fseek(elf, offset + (long)shentsize * (long)shstrndx, SEEK_SET);
  int ret = fread(&shstrtab, sizeof(shstrtab), 1, elf);
  assert(ret == 1);

  long shstr_offset = (long)shstrtab.sh_offset;

  //遍历所有节头，查找名字为".symtab"的节
  for (int i = 0; i < (int)shnum; i++) {
    fseek(elf, offset + (long)shentsize * i, SEEK_SET);
    ret = fread(&Shtmp, sizeof(Shtmp), 1, elf);
    assert(ret == 1);

    //读取该节名称字符串（从 shstrtab 中）
    long sh_name = (long)Shtmp.sh_name;
    fseek(elf, shstr_offset + sh_name, SEEK_SET);
    ret = fread(sh_strname, 1, sizeof(sh_strname) - 1, elf); // 读取不超过 63 字节

    // 判断是否为 .symtab
    if (strcmp(sh_strname, ".symtab") == 0) {
      symtab = Shtmp;
			*sym_offset = (long)symtab.sh_offset;
			*sym_size = symtab.sh_size;
			*sym_entsize = symtab.sh_entsize;

      // 获取 strtab 节头，symtab.sh_link 指向 strtab 的索引
      fseek(elf, offset + (long)shentsize * (long)symtab.sh_link, SEEK_SET);
      ret = fread(&strtab, sizeof(strtab), 1, elf);
      assert(ret == 1);

      return (long)strtab.sh_offset;
    }
  }

  // 如果找不到 .symtab
  fprintf(stderr, "找不到 .symtab 节！\n");
  return -1;
}

void init_ftmem(){
	if(elf_file == NULL) {
		Log("No elf is given");
		return ;
	}
	memset(Ft_mem, 0, sizeof(Ft_mem[0])*FTMEM_SIZE);

	Elf32_Ehdr head = {};
	long str_offset = 0;
	long sym_offset = 0;
	uint32_t sym_size = 0;
	uint32_t sym_entsize = 0;

	printf("%s\n", elf_file);
	FILE *fp = fopen(elf_file, "rb");
	Assert(fp, "Can not open '%s'", elf_file);

  fseek(fp, 0, SEEK_END);
  long size = ftell(fp);

  Log("The elf is %s, size = %ld", elf_file, size);

  fseek(fp, 0, SEEK_SET);
  int ret = fread(&head, sizeof(head), 1, fp);
  assert(ret == 1);

	str_offset = check_Sh(fp, head.e_shoff, head.e_shentsize, head.e_shnum, head.e_shstrndx, &sym_offset, &sym_size, &sym_entsize);
	
	int sym_count = (int)(sym_size / sym_entsize);
	symtab = (Elf32_Sym*)malloc(sym_count * sizeof(Elf32_Sym));
	assert(symtab != NULL);

	sym_name = (char**)malloc(sym_count * sizeof(char*));
	assert(sym_name != NULL);
	
	int ind = 0;	
	for (int i = 0; i < sym_count; i++) {
	  fseek(fp, sym_offset + i * sizeof(Elf32_Sym), SEEK_SET);
	  ret = fread(&symtab[ind], sizeof(Elf32_Sym), 1, fp);
	  assert(ret == 1);
		if((symtab[ind].st_info & 0x0f) != 2) continue;
		else {
			sym_name[ind] = (char*)malloc(64); // 为每个名字分配 64 字节空间
			assert(sym_name[ind] != NULL);
			memset(sym_name[ind], 0, 64);
			fseek(fp, str_offset + symtab[ind].st_name, SEEK_SET);
	  	ret = fread(sym_name[ind], 63, 1, fp); // 最多读取63字节
			//printf("str_offset:0x%ld, st_name:%d, sym_name:%s\n",str_offset, symtab[ind].st_name, sym_name[ind]);
			assert(ret == 1);
	  	sym_name[ind][63] = '\0'; // 防止溢出
			ind ++;
			func_count++;
		}
	}
}

void update_ftmem(uint32_t addr, uint32_t target, bool is_ret, bool is_call){
	memset(Ft_mem+ft_ind, 0, sizeof(Ft_mem[0]));
	Ft_mem[ft_ind].addr = addr;
	Ft_mem[ft_ind].target = target;
	Ft_mem[ft_ind].isret = is_ret;
	Ft_mem[ft_ind].iscall = is_call;
	int i;
	if(is_call){
		for(i = 0; i < func_count; i++){
			//printf("sym_name:%s\n",sym_name[i]);
			if(target == symtab[i].st_value){
				strcpy(Ft_mem[ft_ind].str, sym_name[i]);
				//printf("str:%s, sym_name:%s\n",Ft_mem[ft_ind].str,sym_name[i]);
				break;
			} 
		}
		if(i == func_count) strcpy(Ft_mem[ft_ind].str, "???");
	}
	if(is_ret){
		for(i = 0; i < func_count; i++){
			printf("addr: 0x%08x, size: 0x%08x, value: 0x%08x, sym_name:%s\n",addr, symtab[i].st_size, symtab[i].st_value,sym_name[i]);
			if(addr >= symtab[i].st_value && addr < (symtab[i].st_value + symtab[i].st_size)){
				strcpy(Ft_mem[ft_ind].str, sym_name[i]);
			}
		}
		if(i == func_count) strcpy(Ft_mem[ft_ind].str, "???");
	}
	if(ft_ind == FTMEM_SIZE-1) ft_ind = 0;
	else							ft_ind++;
	if(ft_num != FTMEM_SIZE) ft_num++;
	return;
}

void output_ftmem(){
	int call_count = 0;
	int i = ft_ind != ft_num ? ft_ind : 0;
	while(1){
		if(Ft_mem[i].iscall){
			printf("0x%08x: ",Ft_mem[i].addr);
			for(int j = 0; j < call_count; j++){
				printf(" ");
			}
			printf("call [%s@0x%08x]\n",Ft_mem[i].str, Ft_mem[i].target);
			call_count++;
		}
		if(Ft_mem[i].isret){
			printf("0x%08x: ",Ft_mem[i].addr);
			for(int j = 0; j < call_count-1; j++){
				printf(" ");
			}
			printf("ret  [%s@0x%08x]\n",Ft_mem[i].str, Ft_mem[i].target);
			call_count--;
		}
		if(i == ft_ind - 1) break;
		if(i == FTMEM_SIZE-1) i = 0;
		else				 i++;
	}
}

void free_ft(){
	for(int i = 0; i < func_count; i++){
		free(sym_name[i]);
	}
	free(sym_name);
	free(symtab);
}

