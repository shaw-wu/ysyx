/***************************************************************************************
* Copyright (c) 2014-2022 Zihao Yu, Nanjing University
*
* NEMU is licensed under Mulan PSL v2.
* You can use this software according to the terms and conditions of the Mulan PSL v2.
* You may obtain a copy of Mulan PSL v2 at:
*          http://license.coscl.org.cn/MulanPSL2
*
* THIS SOFTWARE IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
* EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
* MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
*
* See the Mulan PSL v2 for more details.
***************************************************************************************/

#include <isa.h>
#include <cpu/cpu.h>
#include <readline/readline.h>
#include <readline/history.h>
#include <memory/vaddr.h>
#include "sdb.h"

static int is_batch_mode = false;

void init_regex();
void init_wp_pool();

/* We use the `readline' library to provide more flexibility to read from stdin. */
static char* rl_gets() {
  static char *line_read = NULL;

  if (line_read) {
    free(line_read);
    line_read = NULL;
  }

  line_read = readline("(nemu) ");/*读命令行输入  wxz*/

  if (line_read && *line_read) {
    add_history(line_read);
  }

  return line_read;
}

static int cmd_c(char *args) {
  cpu_exec(-1);/*uint64_t 无符号数,-1溢出,实际为0xffffffffffffffff wxz*/
  return 0;
}


static int cmd_q(char *args) {
  return -1;
}

static int cmd_si(char *args);/*wxz*/

static int cmd_info(char *args);/*wxz*/

static int cmd_x(char *args);/*wxz*/

static int cmd_etn(char *args);/*wxz*/

static int cmd_et(char *args);/*wxz*/

static int cmd_d(char *args);/*wxz*/

static int cmd_w(char *args);

static int cmd_help(char *args);

static struct {
  const char *name;
  const char *description;
  int (*handler) (char *);
} cmd_table [] = {
  { "help", "Display information about all supported commands", cmd_help },
  { "c", "Continue the execution of the program", cmd_c },
  { "q", "Exit NEMU", cmd_q },
  { "si", "Single Excute", cmd_si },/*wxz*/
  { "info", "Print information of regs(with sub-cmd r) or watch(with sub-cmd w).", cmd_info },/*wxz*/
  { "x", "Constantly print N of 4 bytes,start address is value of expression.", cmd_x},/*wxz*/
  { "etn", "Expression test.", cmd_etn},/*wxz*/
  { "et", "Expression test.", cmd_et},/*wxz*/
  { "d", "Delete watchpoint.", cmd_d},/*wxz*/
  { "w", "watchpoit.", cmd_w},/*wxz*/

  /* TODO: Add more commands */

};

#define NR_CMD ARRLEN(cmd_table)

static int cmd_help(char *args) {
  /* extract the first argument */
  char *arg = strtok(NULL, " ");
  int i;

  if (arg == NULL) {
    /* no argument given */
    for (i = 0; i < NR_CMD; i ++) {
      printf("%s - %s\n", cmd_table[i].name, cmd_table[i].description);
    }
  }
  else {
    for (i = 0; i < NR_CMD; i ++) {
      if (strcmp(arg, cmd_table[i].name) == 0) {
        printf("%s - %s\n", cmd_table[i].name, cmd_table[i].description);
        return 0;
      }
    }
    printf("Unknown command '%s'\n", arg);
  }
  return 0;
}

/*wxz*/
static int cmd_si(char *args) {
	char* arg = strtok(NULL," ");//only first argument available.
  int i;

  if(arg == NULL) {
		for (i = 0; i < NR_CMD; i++) {
			printf("%s - %s\n", cmd_table[i].name, cmd_table[i].description);
		}
	}
	else {
		cpu_exec((uint64_t)*arg - 48);//0 - ASCII 48 
	}
	return 0;
}

/*wxz*/
static int cmd_info(char *args) {
	char* sub_cmd = strtok(NULL," ");//only first argument available.

  if (strcmp(sub_cmd, "r") == 0) {
		isa_reg_display();
	}
	else if(strcmp(sub_cmd, "w") == 0){
#ifndef CONFIG_WATCHPOINT
		printf("Please config watchpoint option\n");
		return 0;
#endif
		if (!head){
			printf("No watchpoints\n");
		}
		else{
			char* space = " ";
			char* noh = "noh";
			printf("Num%12sType%15sDisp%2sEnb%3sAddress%12sWhat%2s\n", space, space, space, space, space, space);
			WP *p = head;
			while(p){
				printf("%-15d%-19s%-6s%-6s%-19x%-6s\n"\
						, p->NO \
						, noh \
						, noh \
						, noh \
						, p->result \
						, p->expr);
				p = p->next;
			}
		}
	}
	else {
    printf("%s - %s\n", cmd_table[4].name, cmd_table[4].description);
	}
	return 0;
}

/*wxz*/
static int cmd_x(char *args) {
	printf("%s\n",args);
	char *arg1 = strtok(NULL," ");
	char *arg2 = args + strlen(arg1) + 1;
	printf("%s\n",arg2);

  int len;
	char e[65536] = {};
	memset(e, '\0', 65536);
	sscanf(arg1, "%d", &len);
	printf("%s\n",arg2);
	sscanf(arg2, "%s", e);
	printf("%s\n",e);
	vaddr_t Addr ;
	bool suc = true;
	expr(e, &suc, &Addr); 
	assert(suc);

  if(Addr >= 0x80000000 && Addr <= 0x87ffffff) {	
		printf("0x%x : ", Addr);
	  for(int i = 0; i < len; i++){
			if(i){
				printf("%6s","");
			}
			word_t w;
			for(int j = 3; j >= 0; j--){
				w = vaddr_read(Addr + j, 1);
				if(w <= 0x0f) {
					printf("0%x ", w);
				} 
				else {
					printf("%x ", w);
				} 		
			}
			printf("\n");
		}
	} 
	else{
		printf("Address overflow.[0x80000000, ox87ffffff]\n");
	}

	return 0;
}

/*wxz*/
static int cmd_etn(char *args) {
	//char* arg = strtok(NULL," ");
	if(args == NULL){
		printf("Error: No expression provided.\n");
		return 1;
	}
	char *arg = args;
	char ex[65536] = {};
	memset(ex, '\0',  65536);
	strcpy(ex, arg);
	uint32_t result;
	bool suc = true;
	expr(ex, &suc, &result);
	printf("%u = %s\n", result, ex);

	return 0;
}
/*wxz*/
static int cmd_et(char *args) {
	bool suc = true;
	FILE *fp = fopen("/home/shaw/ysyx-workbench/nemu/tools/gen-expr/gen-expr.log", "r");
	FILE *log = fopen("/home/shaw/ysyx-workbench/nemu/tools/gen-expr/test.log", "w");
	assert(fp != NULL);
	char line[65536 + 16] = {};
	while(fgets(line, sizeof(line), fp) != NULL){
	  char ex[65536] = {};
		//memset(ex, '\0', 65536);
		char* result = strtok(line, " ");
		int re_len = strlen(result);
		strcpy(ex, line + re_len + 1);
		ex[strlen(ex) - 1] = '\0';
		uint32_t rt,rp;
		sscanf(result, "%u", &rt);
		expr(ex, &suc, &rp);
		if(rp == rt){
			fprintf(log, "%u = %s\n", rp, ex);
		}
		else{
			fprintf(log, "%u != %s(=%u)\n", rp, ex, rt);
		}
	}
	fclose(fp);
	fclose(log);

	return 0;
}

static int cmd_d(char *args) {
#ifndef CONFIG_WATCHPOINT
		printf("Please config watchpoint option\n");
		return 0;
#endif
	char* arg = strtok(NULL," ");
	int num;
	sscanf(arg, "%d", &num);
  WP *p = head;
	if(!p){
		Log("No Watchpoints");
		return 1;
	}
	while(p){
		if(p->NO == num) break;
		p = p->next;
	}
	if(!p){
		Log("Can't find watchpoint %d.", num);
		return 1;
	}
	free_wp(p);
	return 0;
}

static int cmd_w(char *args) {
#ifndef CONFIG_WATCHPOINT
		printf("Please config watchpoint option\n");
		return 0;
#endif
	char* arg = strtok(NULL," ");
	char ex[65536] = {};
	memset(ex, '\0',  65536);
	strcpy(ex, arg);
	WP *wp = new_wp();

	strcpy(wp->expr, ex);
	uint32_t rp;
	bool suc = true;
	expr(ex, &suc, &rp);
	assert(suc);
	wp->result = rp;

	wp = NULL;
	return 0;
}

void sdb_set_batch_mode() {
  is_batch_mode = true;
}

void sdb_mainloop() {
  if (is_batch_mode) {
    cmd_c(NULL);
    return;
  }

  for (char *str; (str = rl_gets()) != NULL; ) {
    char *str_end = str + strlen(str);

    /* extract the first token as the command */
    char *cmd = strtok(str, " ");
    if (cmd == NULL) { continue; }

    /* treat the remaining string as the arguments,
     * which may need further parsing
     */
    char *args = cmd + strlen(cmd) + 1;
    if (args >= str_end) {
      args = NULL;
    }

#ifdef CONFIG_DEVICE
    extern void sdl_clear_event_queue();
    sdl_clear_event_queue();
#endif

    int i;
    for (i = 0; i < NR_CMD; i ++) {
      if (strcmp(cmd, cmd_table[i].name) == 0) {
        if (cmd_table[i].handler(args) < 0) { return; }
        break;
      }
    }

    if (i == NR_CMD) { printf("Unknown command '%s'\n", cmd); }
  }
}

void init_sdb() {
  /* Compile the regular expressions. */
  init_regex();

  /* Initialize the watchpoint pool. */
  init_wp_pool();
}
