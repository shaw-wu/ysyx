#include <readline/readline.h>
#include <readline/history.h>
#include <macro.h>
#include <stdlib.h>
#include <stdint.h>
#include <debug.h>
#include <vaddr.h>
#include <paddr.h>

static int is_batch_mode = false;
extern int end_sim;

void init_regex();
//void init_wp_pool();

void exec_once(uint32_t n);
extern void isa_reg_display();

word_t expr(char *e, bool *success, uint32_t *result);

static char* rl_gets() {
  static char *line_read = NULL;

  if (line_read) {
    free(line_read);
    line_read = NULL;
  }

  line_read = readline("(npc) ");/*读命令行输入  wxz*/

  if (line_read && *line_read) {
    add_history(line_read);
  }

  return line_read;
}

static int cmd_c(char *args) {
  exec_once(-1);	
  return 0;
}
//
//
static int cmd_q(char *args) {
//	nemu_state.state = NEMU_QUIT;//quit
  end_sim = 1;
  return -1;
}

static int cmd_si(char *args);/*wxz*/

static int cmd_info(char *args);/*wxz*/

static int cmd_x(char *args);/*wxz*/

static int cmd_p(char *args);/*wxz*/

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
  { "p", "Expression test.", cmd_p},/*wxz*/
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

static int cmd_si(char *args) {
	char* arg = strtok(NULL," ");//only first argument available.
  int i;

  if(arg == NULL) {
		cmd_help(args);
		return 0;
	}
	int n;
	sscanf(arg, "%d", &n);
	exec_once(n);
	return 0;
}

static int cmd_info(char *args) {
	char* sub_cmd = strtok(NULL," ");//only first argument available.

  if(sub_cmd == NULL) {
		printf("Error: No arguments provided.\n");
		cmd_help(args);
		return 0;
	}
  if (strcmp(sub_cmd, "r") == 0) {
		isa_reg_display();
	}
	else if(strcmp(sub_cmd, "w") == 0){
		//对监视点操作宏包装
#ifndef CONFIG_WATCHPOINT
		printf("Please config watchpoint option\n");
		return 0;
#endif
//		//先检查监视点池里有没有工作中的监视点
//		if (!head){
//			printf("No watchpoints\n");
//		}
//		else{
//		//遍历打印的操作
//			char* space = " ";
//			char* noh = "noh";
//			printf("Num%12sType%15sDisp%2sEnb%3sAddress%12sWhat%2s\n", space, space, space, space, space, space);
//			WP *p = head;
//			while(p){
//				printf("%-15d%-19s%-6s%-6s0x%-19x%-6s\n"\
//						, p->NO \
//						, noh \
//						, noh \
//						, noh \
//						, p->result \
//						, p->expr);
//				p = p->next;
//			}
//		}
//	}
//	else {
//    printf("%s - %s\n", cmd_table[4].name, cmd_table[4].description);
	} else {
		cmd_help(args);
	}
	return 0;
}

static int cmd_x(char *args) {
	char *arg1 = strtok(NULL," ");
	char *arg2 = args + strlen(arg1) + 1;

  if(arg1 == NULL || arg2 == NULL) {
		printf("Error: No arguments or too few arguments provided.\n");
		cmd_help(args);
		return 0;
	}

	//对参数涉及的变量初始化操作,表达式求值
  int len;
	char e[65536] = {};
	memset(e, '\0', 65536);
	sscanf(arg1, "%d", &len);
	strcpy(e, arg2);
	vaddr_t Addr ;
	bool suc = true;
	expr(e, &suc, &Addr); 
	if(!suc) {
		return 1;
	}

	//检查地址是否溢出,访存并打印内容
  if(in_pmem(Addr)) {	
	  for(int i = 0; i < len; i++){
			if(i){
				printf("%13s","");
			}
			word_t w;
			for(int j = 3; j >= 0; j--){
				w = vaddr_read(Addr + i * 4 + j, 1);
				if(w <= 0x0f) {
					printf("0%x ", w);
				} 
				else {
					printf("%x ", w);
				} 		
			}
			printf("\n");
		}
	} else {
		out_of_bound(Addr);
  }	

	return 0;
}

static int cmd_p(char *args) {
	char *arg = args;

  if(arg == NULL) {
		printf("Error: No arguments provided.\n");
		cmd_help(args);
		return 0;
	}

	char ex[65536] = {};
	memset(ex, '\0',  65536);
	strcpy(ex, arg);
	uint32_t result;
	bool suc = true;
	expr(ex, &suc, &result);
	if(!suc) {
		return 1;
	}
	printf("%s = 0x%x\n", ex, result);

	return 0;
}
       
static int cmd_et(char *args) {
//	//打开测试集和测试日志
//	bool suc = true;
//	FILE *fp = fopen("/home/shaw/ysyx-workbench/nemu/tools/gen-expr/gen-expr.log", "r");
//	FILE *log = fopen("/home/shaw/ysyx-workbench/nemu/tools/gen-expr/test.log", "w");
//	assert(fp);
//	assert(log);
//	//对测试集所在文件按行测试
//	char line[65536 + 16] = {};
//	while(fgets(line, sizeof(line), fp)){
//	  char ex[65536] = {};
//		char* result = strtok(line, " ");
//		int re_len = strlen(result);
//		strcpy(ex, line + re_len + 1);
//		ex[strlen(ex) - 1] = '\0'; //换行符替换成终止符
//		uint32_t rt,rp;
//		sscanf(result, "%u", &rt);
//		expr(ex, &suc, &rp);
//		if(!suc) {
//			return 1;
//		}
//		if(rp == rt){
//			fprintf(log, "%u = %s\n", rp, ex);
//		}
//		else{
//			fprintf(log, "%u != %s(=%u)\n", rp, ex, rt);
//			assert(0);
//		}
//	}
//	fclose(fp);
//	fclose(log);
//
	return 0;
}

static int cmd_d(char *args) {
//#ifndef CONFIG_WATCHPOINT
//		printf("Please config watchpoint option\n");
//		return 0;
//#endif
//  //访问监视点池,遍历链表
//	char* arg = strtok(NULL," ");
//	int num;
//	sscanf(arg, "%d", &num);
//  WP *p = head;
//	//无监视点
//	if(!p){
//		printf("No Watchpoints\n");
//		return 1;
//	}
//	while(p){
//		if(p->NO == num) break;
//		p = p->next;
//	}
//	//找不到监视点
//	if(!p){
//		printf("Can't find watchpoint %d.\n", num);
//		return 1;
//	}
//	//删除监视点
//	free_wp(p);
//	
	return 0;
}

static int cmd_w(char *args) {
//#ifndef CONFIG_WATCHPOINT
//		printf("Please config watchpoint option\n");
//		return 1;
//#endif
//	if(args == NULL){
//		printf("Error: No expression provided.\n");
//		return 1;
//	}
//	//从空闲池中取出监视点为其赋值
//	char *arg = args;
//	char ex[65536] = {};
//	memset(ex, '\0',  65536);
//	strcpy(ex, arg);
//	WP *wp = new_wp();
//	if(!wp){
//		return 1;
//	}
//
//	strcpy(wp->expr, ex);
//	uint32_t rp;
//	bool suc = true;
//	expr(ex, &suc, &rp);
//	//printf("%d\n",suc);
//	if(!suc) {
//		return 1;
//	}
//	wp->result = rp;
//
//	wp = NULL;
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

    char *cmd = strtok(str, " ");
    if (cmd == NULL) { continue; }

    char *args = cmd + strlen(cmd) + 1;
    if (args >= str_end) {
      args = NULL;
    }

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
  //init_wp_pool();
}
