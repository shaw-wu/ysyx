/***************************************************************************************
* Copyright (c) 2014-2022 Zihao Yu, Nanjing University *
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
#include <memory/vaddr.h>

/* We use the POSIX regex functions to process regular expressions.
 * Type 'man regex' for more information about POSIX regex functions.
 */
#include <regex.h>

/*wxz*/
enum {
  TK_HEX = 256, TK_REG, TK_NOTYPE, TK_LPARENT, TK_RPARENT, TK_EQ, TK_INEQ, TK_LAND, TK_DIG,

  /* TODO: Add more token types */

};

static struct rule {
  const char *regex;
  int token_type;
} rules[] = {

  /* TODO: Add more rules.
   * Pay attention to the precedence level of different rules.
   */

  /*wxz*/
	{"0x[a-f0-9A-F]+", TK_HEX},
	{"\\$[a-zA-Z][a-zA-Z0-9]*", TK_REG},
  {" +"  , TK_NOTYPE},   // spaces
  {"\\(" , TK_LPARENT},   // left brackets
  {"\\)" , TK_RPARENT},   // right brackets
  {"\\*" , '*'},         // multiple
  {"\\/"   , '/'},         // division
  {"\\+" , '+'},         // plus
  {"\\-"   , '-'},         // minus
  {"=="  , TK_EQ},       // equal
  {"!="  , TK_INEQ},       // inequal
  {"\\&\\&"  , TK_LAND},       // logic and
  {"[[:digit:]]+" , TK_DIG},      // digital 
};

#define NR_REGEX ARRLEN(rules)

static regex_t re[NR_REGEX] = {};

/* Rules are used for many times.
 * Therefore we compile them only once before any usage.
 */
void init_regex() {
  int i;
  char error_msg[128];
  int ret;

	/*编译rules中的表达式, 将rules匹配的表达式信息相应放在re[i]中 wxz*/
  for (i = 0; i < NR_REGEX; i ++) {
    ret = regcomp(&re[i], rules[i].regex, REG_EXTENDED);
    if (ret != 0) {
      regerror(ret, &re[i], error_msg, 128);
      panic("regex compilation failed: %s\n%s", error_msg, rules[i].regex);
    }
  }
}

typedef struct token {
  int type;
  char str[32];
} Token;

static Token tokens[65536] __attribute__((used)) = {};/*__attribute__((used)) 提示编译器不要优化 wxz*/
static int nr_token __attribute__((used))  = 0;

static bool make_token(char *e) {
  int position = 0;
  int i;
  regmatch_t pmatch;/*匹配的信息,pmatch.rm_so:start offset,pmatch.eo:end offset wxz*/

  nr_token = 0;

  while (e[position] != '\0') {
    /* Try all rules one by one. */
    for (i = 0; i < NR_REGEX; i ++) {
      if (regexec(&re[i], e + position, 1, &pmatch, 0) == 0 && pmatch.rm_so == 0) {
        char *substr_start = e + position;
        int substr_len = pmatch.rm_eo;/*end offset 相对start位置的偏移量 wxz*/

        Log("match rules[%d] = \"%s\" at position %d with len %d: %.*s",
            i, rules[i].regex, position, substr_len, substr_len, substr_start);

        position += substr_len;

        /* TODO: Now a new token is recognized with rules[i]. Add codes
         * to record the token in the array `tokens'. For certain types
         * of tokens, some extra actions should be performed.
         */
				/*wxz*/
        switch (rules[i].token_type) {
          case TK_NOTYPE: 
						break;
          case TK_LPARENT : 
						//类型
						tokens[nr_token].type = TK_LPARENT;
						if(substr_len >= 32){
							printf("Illegal expression: Token of position %d is overflow\n", position - substr_len);
							return false;
						}
						//assert(substr_len < 32);
						//字符串
					  strncpy(tokens[nr_token].str, substr_start, substr_len);
						tokens[nr_token].str[substr_len] = '\0';
						//更新下标
						nr_token++;
						break;
          case TK_RPARENT : 
						tokens[nr_token].type = TK_RPARENT;
						if(substr_len >= 32){
							printf("Illegal expression: Token of position %d is overflow\n", position - substr_len);
							return false;
						}
						//assert(substr_len < 32);
					  strncpy(tokens[nr_token].str, substr_start, substr_len);
						tokens[nr_token].str[substr_len] = '\0';
						nr_token++;
						break;
          case '*'      : 
						tokens[nr_token].type = '*';
						if(substr_len >= 32){
							printf("Illegal expression: Token of position %d is overflow\n", position - substr_len);
							return false;
						}
						//assert(substr_len < 32);
					  strncpy(tokens[nr_token].str, substr_start, substr_len);
						tokens[nr_token].str[substr_len] = '\0';
						nr_token++;
						break;
          case '/'      : 
						tokens[nr_token].type = '/';
						if(substr_len >= 32){
							printf("Illegal expression: Token of position %d is overflow\n", position - substr_len);
							return false;
						}
						//assert(substr_len < 32);
					  strncpy(tokens[nr_token].str, substr_start, substr_len);
						tokens[nr_token].str[substr_len] = '\0';
						nr_token++;
						break;
          case '+'      : 
						tokens[nr_token].type = '+';
						if(substr_len >= 32){
							printf("Illegal expression: Token of position %d is overflow\n", position - substr_len);
							return false;
						}
						//assert(substr_len < 32);
					  strncpy(tokens[nr_token].str, substr_start, substr_len);
						tokens[nr_token].str[substr_len] = '\0';
						nr_token++;
						break;
          case '-'      : 
						tokens[nr_token].type = '-';
						if(substr_len >= 32){
							printf("Illegal expression: Token of position %d is overflow\n", position - substr_len);
							return false;
						}
						//assert(substr_len < 32);
					  strncpy(tokens[nr_token].str, substr_start, substr_len);
						tokens[nr_token].str[substr_len] = '\0';
						nr_token++;
						break;
          case TK_EQ    : 
						tokens[nr_token].type = TK_EQ;
						if(substr_len >= 32){
							printf("Illegal expression: Token of position %d is overflow\n", position - substr_len);
							return false;
						}
						//assert(substr_len < 32);
					  strncpy(tokens[nr_token].str, substr_start, substr_len);
						tokens[nr_token].str[substr_len] = '\0';
						nr_token++;
						break;
          case TK_DIG   : 
						tokens[nr_token].type = TK_DIG;
						if(substr_len >= 32){
							printf("Illegal expression: Token of position %d is overflow\n", position - substr_len);
							return false;
						}
						//assert(substr_len < 32);
					  strncpy(tokens[nr_token].str, substr_start, substr_len);
						tokens[nr_token].str[substr_len] = '\0';
						nr_token++;
						break;
					case TK_HEX   :
						tokens[nr_token].type = TK_HEX;
						if(substr_len >= 32){
							printf("Illegal expression: Token of position %d is overflow\n", position - substr_len);
							return false;
						}
						//assert(substr_len < 32);
					  strncpy(tokens[nr_token].str, substr_start, substr_len);
						tokens[nr_token].str[substr_len] = '\0';
						nr_token++;
						break;
					case TK_REG   :
						tokens[nr_token].type = TK_REG;
						if(substr_len >= 32){
							printf("Illegal expression: Token of position %d is overflow\n", position - substr_len);
							return false;
						}
						//assert(substr_len < 32);
					  strncpy(tokens[nr_token].str, substr_start, substr_len);
						tokens[nr_token].str[substr_len] = '\0';
						nr_token++;
						break;
					case TK_INEQ  :
						tokens[nr_token].type = TK_INEQ;
						if(substr_len >= 32){
							printf("Illegal expression: Token of position %d is overflow\n", position - substr_len);
							return false;
						}
						//assert(substr_len < 32);
					  strncpy(tokens[nr_token].str, substr_start, substr_len);
						tokens[nr_token].str[substr_len] = '\0';
						nr_token++;
						break;
					case TK_LAND  :
						tokens[nr_token].type = TK_LAND;
						if(substr_len >= 32){
							printf("Illegal expression: Token of position %d is overflow\n", position - substr_len);
							return false;
						}
						//assert(substr_len < 32);
					  strncpy(tokens[nr_token].str, substr_start, substr_len);
						tokens[nr_token].str[substr_len] = '\0';
						nr_token++;
						break;
          default: break; 
        }

        break;
      }
    }

		//匹配失败
    if (i == NR_REGEX) {
      printf("no match at position %d\n%s\n%*.s^\n", position, e, position, "");
      return false;
    }
  }

  return true;
}
static bool check_parentheses(int st, int en, bool* illegal);

//负数处理,检测到的负号为单数时系数coe=-1,否则为coe=0
static int negative(int* coe, int st, int en){
	int k = st;
	if(tokens[st].type == '-'){
		int neg = 1;
		if(st == en){
			return 2;
		}
		//是负号的情况
		for(k = st + 1; k <= en; k++){
			if(tokens[k].type == '+' || \
				 tokens[k].type == '*' || \
				 tokens[k].type == '/' || \
				 tokens[k].type == TK_RPARENT){
				assert(0);
				return 2;
			}
			else if(tokens[k].type == '-'){
				neg++;
			}
			else{
				break;
			}
		}
		if(neg % 2){
			*coe = -1;;
		}
		else{
			*coe = 1;
		}
	}
	else{
		*coe = 1;
	}
	return k;
}

// 运算(处理)优先级 : 
// 数字/十六进制数/寄存器引用 -> 负数/解引用 -> 括号 -> 乘除 -> 加减 -> 比较符(等于/不等于) -> 逻辑与
// 函数入栈顺序与优先级相反
static int eval(int st, int en, bool* illegal){
	if(*illegal == true){
		printf("Illegal expression: [0]Haven't identify any element!\n");
		return 1;
	}
	if(st > en){
		*illegal = true;
		printf("Illegal expression: [1]Haven't identify any element!\n");
		return 1;
	}
	//数字
	else if(st == en){
		int num;
		//数字
		if(tokens[en].type == TK_DIG){
			sscanf(tokens[en].str,"%d",&num);
		}
		//ox
		else if(tokens[en].type == TK_HEX){
			sscanf(tokens[en].str + 2, "%x", &num);
		}
		//$
		else if(tokens[en].type == TK_REG){
			bool suc = true;
			num = isa_reg_str2val(tokens[en].str + 1, &suc);
			if(!suc){
				printf("Error: Can't search reg \"%s\"\n", tokens[en].str + 1);
			}
		}
		
		return num;
	}
	//括号
	else if(check_parentheses(st, en, illegal) == true){
		return eval(st + 1, en - 1, illegal);
	}
	//其他
	else{
		int *symbol = (int*)malloc((en - st + 1) * sizeof(int));
		int ind = 0;
		int i;
		//遍历记录所有运算符,存储在symbol中
		for(i = st; i <= en; i++){
			if(i == st || i == en){
				continue;
			}
			switch(tokens[i].type){
				case '+' :
					symbol[ind] = i;
					ind++;
					break;	
				case '-' : 
					//筛选负号,只有'-'前的符号为')','$','0x',解引用'*'和[:digital:]时才是减号
					if(tokens[i-1].type == TK_RPARENT || tokens[i-1].type == TK_DIG || tokens[i-1].type == TK_REG || tokens[i-1].type == TK_HEX || (tokens[i-1].type == '*' && strlen(tokens[i-1].str) > 1)){ 
						symbol[ind] = i;
						ind++;
					}
					break;	
				case '*' : 
					//筛选乘号,只有'-'前的符号为')','$','0x',解引用'*'和[:digital:]时才是乘号
					if(tokens[i-1].type == TK_RPARENT || tokens[i-1].type == TK_DIG || tokens[i-1].type == TK_REG || tokens[i-1].type == TK_HEX || (tokens[i-1].type == '*' && strlen(tokens[i-1].str) > 1)){ 
						symbol[ind] = i;
						ind++;
					}
					break;	
				case '/' : 
					symbol[ind] = i;
					ind++;
					break;	
				case TK_EQ : 
					symbol[ind] = i;
					ind++;
					break;	
				case TK_INEQ : 
					symbol[ind] = i;
					ind++;
					break;	
				case TK_LAND : 
					symbol[ind] = i;
					ind++;
					break;	
				default : break;
			}
		}	
		//检查运算符是否在括号内,在括号内则不能作为主运算符
		//这里默认check_parentheses()功能正常,主表达式不会有括号括起来
		//具体逻辑是遍历符号数组symbol,过程中使用count计数记录括号,遇到左括号加1,右括号减1
		for(i = 0; i < ind; i++){				
			int j = symbol[i];
			int count = 0;
			do{
				if(j < st){
					break;
				}
				if(tokens[j].type == TK_RPARENT){
					count++;
				}
				else if(tokens[j].type == TK_LPARENT){
					count--;
				}
				j--;
			}while(count != -1);
			if(count == -1){
				symbol[i] = -1;
			}
		}

		int op = -1; 	
		int op_temp = -1;
		for(i = ind - 1; i >= 0; i--){						/*搜索主运算符 : 从右到左*/
			int p = symbol[i]; 
			if(p == -1){
				continue;
			}
			//优先级最低,逻辑与,遇到即为主运算符
			else if(tokens[p].type == TK_LAND){
				op = p;
				break;
			}
			//比较符,遇到多个比较符只将最右边的作为主运算符
			else if(tokens[p].type == TK_EQ || tokens[p].type == TK_INEQ){
				if(op_temp == TK_EQ || op_temp == TK_INEQ){
					continue;
				}
				op = p;
				op_temp = tokens[p].type;
			}
			//加减,与比较符类似,并且遇到过比较符后不再将此作为主运算符
			else if(tokens[p].type == '+' || tokens[p].type == '-'){
				if(op_temp == TK_EQ || op_temp == TK_INEQ || \
					 op_temp == '+' || op_temp == '-'){
					continue;
				}
				op = p;
				op_temp = tokens[p].type;
			}
			//乘除,与加减类似
			else if(tokens[p].type == '*' || tokens[p].type == '/'){
				if(op_temp == TK_EQ || op_temp == TK_INEQ || \
					 op_temp == '+' || op_temp == '-' || \
					 op_temp == '*' || op_temp == '/'){
					continue;
				}
				op = p;
				op_temp = tokens[p].type;
			}
			else{																		/*防御性编程 : 我也不知道会不会有这种情况*/
				*illegal = true;
				printf("Illegal expression: [2]Haven't identify any element!\n");
				free(symbol);
				return 1;
			}
		}
		free(symbol);
		
		//有主运算符
		if(op != -1){

			int val1 = eval(st, op - 1, illegal);
			int val2 = eval(op + 1, en, illegal);
			switch(tokens[op].type){
				case '+' : return val1 + val2;
				case '-' : return val1 - val2;
				case '*' : return val1 * val2;
				case '/' : 
					//除零时终止
				  if(!val2){
						*illegal = true;
						printf("Illegal expression : Divise 0!\n");
						return 1;
						//assert(val2);
					}
			    return val1 / val2;	
				case TK_EQ : return val1 == val2;
				case TK_INEQ : return val1 != val2; 
				case TK_LAND : return val1 && val2; 
				default : 
					*illegal = true;
					printf("Illegal expression: [3]Haven't identify any element!\n");
					return 1;
			}
		}
		//没有运算符:考虑负数与解引用情况
		else{
			if(tokens[st].type != '-' && tokens[st].type != '*'){
				*illegal = true;
				printf("Illegal expression: [4]Haven't identify any element!\n");
				return 1;
			}
			if(tokens[st].type == '-'){
				int coe0 = 1;
				//负数处理
				int st0 = negative(&coe0, st, en);
				if(st0 == 2){
					*illegal = true;
					printf("Illegal expression: Negative sign is illegal!\n");
					return 1;
				}
				return coe0 * eval(st0, en, illegal);
			}
			else{
				//访存
				vaddr_t Addr = eval(st + 1, en, illegal);
				if(Addr < 0x80000000 || Addr > 0x87ffffff){
					*illegal = true;
					printf("Address overflow.[0x80000000, 0x87ffffff]\n");
					return 1;
				}
				return vaddr_read(Addr, 1);
			}
		}
	}
}

//检查表达式是否被括号包着
static bool check_parentheses(int st, int en, bool* illegal){
	if(tokens[st].type != TK_LPARENT || tokens[en].type != TK_RPARENT){
		return false;
	}
	int i = st + 1;
	int count = 1;
	do{
		if(i > en){
			break;
		}
		if(tokens[i].type == TK_LPARENT){
			count++;
		}
		else if(tokens[i].type == TK_RPARENT){
			count--;
		}
		i++;
	}while(count != 0);
	if(!count && i == en + 1){
		return true;
	}
	if(count != 0){
		perror("parentheses not match!\n");
	}
	
	return false;

}

word_t expr(char *e, bool *success, uint32_t *result) {
  if (!make_token(e)) {
    *success = false;
    return 0;
  }

  /* TODO: Insert codes to evaluate the expression. */
	bool illegal = false;
  int re = eval(0, nr_token - 1, &illegal);
	if (illegal){
		*success = false;
	}
	//有符号数转换为无符号数
	*result = 0x100000000 + re;

  return 0;
}
