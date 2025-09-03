#include <stdint.h>
#include <stdbool.h>
#include <isa.h>
#include <stdio.h>
#include <string.h>
#include <assert.h>
#include <stdlib.h>

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

char* elf_file = "/home/shaw/ysyx-workbench/am-kernels/tests/cpu-tests/build/min3-riscv32e-nemu.elf";
bool have_img = false;
bool is_call = false;
bool is_ret = false;
vaddr_t dnpc = 0;

Elf32_Sym* symtab = NULL; 
char **sym_name = NULL;
int sym_count = 0; 

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

void init_ftrace(){
	if(elf_file == NULL) {
		Log("No elf is given");
		return ;
	}

	Elf32_Ehdr head = {};
	long str_offset = 0;
	long sym_offset = 0;
	uint32_t sym_size = 0;
	uint32_t sym_entsize = 0;

	FILE *fp = fopen(elf_file, "rb");
	Assert(fp, "Can not open '%s'", elf_file);

  fseek(fp, 0, SEEK_END);
  long size = ftell(fp);

  Log("The elf is %s, size = %ld", elf_file, size);

  fseek(fp, 0, SEEK_SET);
  int ret = fread(&head, sizeof(head), 1, fp);
  assert(ret == 1);

	str_offset = check_Sh(fp, head.e_shoff, head.e_shentsize, head.e_shnum, head.e_shstrndx, &sym_offset, &sym_size, &sym_entsize);
	
	sym_count = (int)(sym_size / sym_entsize);
	symtab = (Elf32_Sym*)malloc(sym_count * sizeof(Elf32_Sym));
	assert(symtab != NULL);

	sym_name = (char**)malloc(sym_count * sizeof(char*));
	assert(sym_name != NULL);
	
	for (int i = 0; i < sym_count; i++) {
		sym_name[i] = (char*)malloc(64); // 为每个名字分配 64 字节空间
		assert(sym_name[i] != NULL);
		memset(sym_name[i], 0, 64);
	  fseek(fp, sym_offset + i * sizeof(Elf32_Sym), SEEK_SET);
	  ret = fread(&symtab[i], sizeof(Elf32_Sym), 1, fp);
	  assert(ret == 1);
	
	  fseek(fp, str_offset + symtab[i].st_name, SEEK_SET);
	  fread(sym_name[i], 1, 63, fp); // 最多读取63字节
	  sym_name[i][63] = '\0'; // 防止溢出
	}
}



//int main(){
//	init_ftrace();
//	for(int i = 0; i < sym_count; i++){
//		printf("Symbol %d: name = %s, addr = 0x%x, size = %d\n",
//						i, sym_name[i], symtab[i].st_value, symtab[i].st_size);
//	}
//	return 0;
//}
