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
"#include <stdint.h>\n"
"int main() { "
"  uint32_t result = %s; "
"  printf(\"%%u\", result); "
"  return 0; "
"}";

static void gen_rand_expr() {
	uint32_t rand1 = rand() % 8;
	int ind_st1, ind_st2;
	int i;
	//生成表达式,为了控制表达式长度和有效信息,将比例调至: 数字:括号:符号 = 5:1:2
	switch(rand1){
		case 0 :
		case 1 :
		case 2 :
		case 3 :
		case 4 :
			uint32_t d = rand() % 2 + 1;
			//只生成2位整数
			for(i = 0; i < d; i++){
				if(i == 0){
					buf[buf_i] = (char)(rand() % 9 + 1 + 48);//首位不为0
				}
				else{
					buf[buf_i] = (char)(rand() % 10 + 48);
				}
				buf_i++;
			}
			buf[buf_i] = '\0';
			break;
		case 5 :
			int single = 0;
			buf[buf_i] = '(';	
			buf_i++;
			ind_st1 = buf_i;
			do{
				gen_rand_expr();
				buf[buf_i] = ')';	
				//检查括号内是否没有符号(纯数字或者纯括号)
				for(i = buf_i - 1; i >= ind_st1; i--){
					if(buf[i] == '+' || buf[i] == '-' || buf[i] == '*' || buf[i] == '/'){
						break;
					}
					else{
						continue;
					}
				}
				if(i == ind_st1 - 1){
					buf_i = ind_st1;
					single = 1;
				}
				else{
					buf_i++;
					single = 0;
				}
				buf[buf_i] = '\0';
			}while(single);
			break;
		default :
			gen_rand_expr();
			int devision = 0;
			int Zero = 0;
			uint32_t rand2 = rand() % 4;
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
					devision = 1;
					break;
			}
			
			ind_st1 = buf_i;
			//除0检测
			do{
				char sub_expr[65536] = {};
				gen_rand_expr();
				//除号后面子表达式若结果为0,则重新生成一遍
				if(devision == 1){
					//子表达式第一个元素为'(',则将这个括号内的值提出来检测是否为0
					if(buf[ind_st1] == '('){
						int ac = 1;
						for(i = ind_st1 + 1; i < buf_i; i++){
							if(ac == 0) break;
							if(buf[i] == '('){
								ac++;
							}
							else if(buf[i] == ')'){
								ac--;
							}
						}
					}
					//子表达式第一个元素为数字,则只检测第一个数字tokens
					else if(buf[ind_st1] >= 48 && buf[ind_st1] <= 57){
						i = ind_st1; 
						do{ i++; }while(buf[i] >= 48 && buf[i] <= 57);
					}
					//子表达式
					strncpy(sub_expr, buf + ind_st1, i - ind_st1);
					sub_expr[i - ind_st1] = '\0';
      		
					//使用和main函数一样的求值代码框架进行求值检测
					sprintf(code_buf, code_format, sub_expr);		
					FILE *fp = fopen("/tmp/.code.c", "w");  
					assert(fp != NULL);
					fputs(code_buf, fp);
					fclose(fp);

					int ret = system("gcc /tmp/.code.c -o /tmp/.expr");  
					if (ret != 0) continue;

					fp = popen("/tmp/.expr", "r");											
					assert(fp != NULL);

					uint32_t result;
					ret = fscanf(fp, "%u", &result);										
					pclose(fp);

					//为0
					if(result == 0){
						buf_i = ind_st1;
						Zero = 1;
					}
					//不为0
					else{
						Zero = 0;
					}
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

    uint32_t result;
    ret = fscanf(fp, "%u", &result);										 /*读取程序结果*/
    pclose(fp);

    printf("%u %s\n", result, buf);
  }
  return 0;
}
