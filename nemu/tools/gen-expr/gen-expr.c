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

#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <assert.h>
#include <string.h>

// this should be enough
static char buf[65536] = {};
static int buf_i = 0; /*wxz*/
static char code_buf[65536 + 128] = {}; // a little larger than `buf`
static char *code_format =
"#include <stdio.h>\n"
"int main() { "
"  unsigned int result = %s; "
"  printf(\"%%u\", result); "
"  return 0; "
"}";

static char zero_buf[65536 + 512] = {};
static char *check_zero =
"#include <stdio.h>\n"
"#include <stdlib.h>\n"
"#include <assert.h>\n"
"int main() {\n"
"  FILE* fp = fopen(\"/home/shaw/ysyx-workbench/nemu/tools/gen-expr/.zero.log\", \"w\");\n"
"	 assert(fp != NULL);\n"
"  unsigned int result = %s;\n"
"  int arr[2] = {0, 1};\n"
"  if(result == 0){\n"
"	   fwrite(arr + 1, sizeof(int), 1, fp);\n"
"  }\n"
"  else{\n"
"	   fwrite(arr, sizeof(int), 1, fp);\n"
"  }\n"
"	 fclose(fp);\n"
"  return 0;\n"
"}";

static void gen_rand_expr() {
	unsigned int rand1 = rand() % 5;
	//括号内不能单独出现数字
	if(buf_i != 0 && (rand1 == 0 || rand1 == 1)){
		int ind_t = buf_i-1;
		int jdg = 0;
		do{
			switch(buf[ind_t]){
				case ' ':
					if(ind_t == 0){
						jdg = 0;
					}
					else{
						ind_t--;
					}
					jdg = 1;
					break;
				case '+':
				case '-':
				case '*':
				case '/':
					jdg = 0;
					break;
				case '(':
				case ')':
					do{
						rand1 = rand() % 5;
					}while(rand1 == 0 || rand1 == 1);
					break;
				default : break;
			}
		}while(jdg);
	}
	switch(rand1){
		case 0 :
		case 1 :
			int d = rand() % 2 + 1;
			for(int i = 0; i < d; i++){
				if(i == 0){
					buf[buf_i] = (char)(rand() % 9 + 1 + 48);
				}
				else{
					buf[buf_i] = (char)(rand() % 10 + 48);
				}
				buf_i++;
			}
			buf[buf_i] = '\0';
			break;
		case 2 :
			buf[buf_i] = '(';	
			buf_i++;
			gen_rand_expr();
			buf[buf_i] = ')';	
			buf_i++;
			buf[buf_i] = '\0';
			break;
		default :
			int ind_st1 = buf_i;
			int Zero = 0;
			do{
				int devide = 0;
				gen_rand_expr();
				unsigned int rand2 = rand() % 4;
				switch(rand2){
					case 0 : 
						buf[buf_i] = '+';
						buf_i++;
						break;
					case 1 : 
						buf[buf_i] = '-';
						buf_i++;
						break;
					case 2 : 
						buf[buf_i] = '*';
						buf_i++;
						break;
					default : 
						buf[buf_i] = '/';
						buf_i++;
						devide = 1; //除法:检测后面是否为0
						break;
				}
				int ind_st2 = buf_i;
				gen_rand_expr();

				if(devide == 1){
					sprintf(zero_buf, check_zero, buf + ind_st2);		
					FILE *fp = fopen("/tmp/.code_zero.c", "w");  
					assert(fp != NULL);
					fputs(zero_buf, fp);
					fclose(fp);

					int ret = system("gcc /tmp/.code_zero.c -o /tmp/.zero");
					if(ret != 0){
						perror("system() : gen_rand_expr()");
					}
					ret = system("/tmp/.zero");
					if(ret != 0){
						perror("system() : gen_rand_expr()");
					}

					fp = fopen("/home/shaw/ysyx-workbench/nemu/tools/gen-expr/.zero.log", "r");  
					assert(fp != NULL);
					size_t res = fread(&Zero, sizeof(int), 1, fp);
					if(res != 1){
						perror("Error reading file");
					}
					else{
						if(Zero == 1){
							buf_i = ind_st1;
							buf[buf_i] = '\0';
						}
						else if(Zero == 0){
							break;
						}
						else{
							perror("unknown statu : gen_rand_expr():Zero ");
						}
					}
					fclose(fp);
				}
			}while(Zero);
			break;
	}
}

int main(int argc, char *argv[]) {
  int seed = time(0);		/*根据时间戳设置种子*/
  srand(seed);					/*为rand()设置种子*/
  int loop = 1;					/*设置循环数次(生成几个表达式)*/
  if (argc > 1) {
    sscanf(argv[1], "%d", &loop);
  }
  int i;
  for (i = 0; i < loop; i ++) {
		buf[0] = '\0';
		buf_i = 0;
    gen_rand_expr();
		if(buf_i < 10){
			i--;
			continue;
		}
    sprintf(code_buf, code_format, buf);		/*将buf中的测试填进代码框架,并缓冲到代码缓冲区*/

    FILE *fp = fopen("/tmp/.code.c", "w");  /*打开文件,将缓冲代码加载到文件中*/
    assert(fp != NULL);
    fputs(code_buf, fp);
    fclose(fp);

    int ret = system("gcc /tmp/.code.c -o /tmp/.expr");  /*编译命令 system()--使用bash程序(在linux环境下)*/
    if (ret != 0) continue;

    fp = popen("/tmp/.expr", "r");											 /*打开进程*/
    assert(fp != NULL);

    int result;
    ret = fscanf(fp, "%d", &result);										 /*读取程序结果*/
    pclose(fp);

    printf("%u %s\n", result, buf);
  }
  return 0;
}
