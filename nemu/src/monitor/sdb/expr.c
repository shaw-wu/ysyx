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

/* We use the POSIX regex functions to process regular expressions.
 * Type 'man regex' for more information about POSIX regex functions.
 */
#include <regex.h>

/*wxz*/
enum {
  TK_NOTYPE = 256, TK_LPARENT, TK_RPARENT, TK_EQ, TK_DIG,

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
  {" +"  , TK_NOTYPE},   // spaces
  {"\\(" , TK_LPARENT},   // left brackets
  {"\\)" , TK_RPARENT},   // right brackets
  {"\\*" , '*'},         // multiple
  {"\\/"   , '/'},         // division
  {"\\+" , '+'},         // plus
  {"\\-"   , '-'},         // minus
  {"=="  , TK_EQ},       // equal
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
						tokens[nr_token].type = TK_LPARENT;
						assert(substr_len < 32);
					  strncpy(tokens[nr_token].str, substr_start, substr_len);
						tokens[nr_token].str[substr_len] = '\0';
						nr_token++;
						break;
          case TK_RPARENT : 
						tokens[nr_token].type = TK_RPARENT;
						assert(substr_len < 32);
					  strncpy(tokens[nr_token].str, substr_start, substr_len);
						tokens[nr_token].str[substr_len] = '\0';
						nr_token++;
						break;
          case '*'      : 
						tokens[nr_token].type = '*';
						assert(substr_len < 32);
					  strncpy(tokens[nr_token].str, substr_start, substr_len);
						tokens[nr_token].str[substr_len] = '\0';
						nr_token++;
						break;
          case '/'      : 
						tokens[nr_token].type = '/';
						assert(substr_len < 32);
					  strncpy(tokens[nr_token].str, substr_start, substr_len);
						tokens[nr_token].str[substr_len] = '\0';
						nr_token++;
						break;
          case '+'      : 
						tokens[nr_token].type = '+';
						assert(substr_len < 32);
					  strncpy(tokens[nr_token].str, substr_start, substr_len);
						tokens[nr_token].str[substr_len] = '\0';
						nr_token++;
						break;
          case '-'      : 
						tokens[nr_token].type = '-';
						assert(substr_len < 32);
					  strncpy(tokens[nr_token].str, substr_start, substr_len);
						tokens[nr_token].str[substr_len] = '\0';
						nr_token++;
						break;
          case TK_EQ    : 
						tokens[nr_token].type = TK_EQ;
						assert(substr_len < 32);
					  strncpy(tokens[nr_token].str, substr_start, substr_len);
						tokens[nr_token].str[substr_len] = '\0';
						nr_token++;
						break;
          case TK_DIG   : 
						tokens[nr_token].type = TK_DIG;
						assert(substr_len < 32);
					  strncpy(tokens[nr_token].str, substr_start, substr_len);
						tokens[nr_token].str[substr_len] = '\0';
						nr_token++;
						break;
          default: break; 
        }

        break;
      }
    }

    if (i == NR_REGEX) {
      printf("no match at position %d\n%s\n%*.s^\n", position, e, position, "");
      return false;
    }
  }

  return true;
}
static bool check_parentheses(int st, int en, bool* illegal);

static int negative(int* coe, int st, int en){
	int k = st;
	if(tokens[st].type == '-'){
		int neg = 1;
		if(st == en){
		  Log("Illegal expration:negative sign");
		  assert(NULL);
		}
		for(k = st + 1; k <= en; k++){
			if(tokens[k].type == '+' || \
				 tokens[k].type == '*' || \
				 tokens[k].type == '/' || \
				 tokens[k].type == TK_RPARENT){
				Log("Illegal expration:negative sign");
				assert(NULL);
			}
			if(tokens[k].type == '-'){
				neg++;
			}
			else{
				if(neg % 2){
					*coe = -1;;
					break;
				}
				else{
					*coe = 1;
					break;
				}
			}
		}
	}
	else{
		*coe = 1;
	}
	return k;
}

static int eval(int st, int en, bool* illegal){
	if(*illegal == true){
		return 1;
	}
	if(st > en){
		*illegal = true;
		return 1;
	}
	//数字
	else if(st == en){
		int num;
		sscanf(tokens[en].str,"%d",&num);
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
		//遍历记录所有运算符
		for(i = st; i <= en; i++){
			if(i == 0 || i == nr_token - 1){
				continue;
			}
			switch(tokens[i].type){
				case '+' :
					symbol[ind] = i;
					ind++;
					break;	
				case '-' : 
					//筛选负号,只有'-'前的符号为')'和[:digital:]时才是减号
					if(tokens[i-1].type == TK_RPARENT || tokens[i-1].type == TK_DIG){ 
						symbol[ind] = i;
						ind++;
					}
					break;	
				case '*' : 
					symbol[ind] = i;
					ind++;
					break;	
				case '/' : 
					symbol[ind] = i;
					ind++;
					break;	
				default : break;
			}
		}	
		//检查运算符是否在括号内,在括号内则不能作为主运算符
		//这里默认check_parentheses()功能正常,主表达式不会有括号括起来
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
			else if(tokens[p].type == '+' || tokens[p].type == '-'){
				op = p;
				break;
			}
			else if(op_temp != -1){
				continue;
			}
			else if(tokens[p].type == '*' || tokens[p].type == '/'){
				op_temp = p;
				continue;
			}
			else{																		/*防御性编程 : 我也不知道会不会有这种情况*/
				*illegal = true;
				free(symbol);
				return 1;
			}
		}
		free(symbol);
		if(op == -1 && ind != 0){
			if(op_temp != -1){
				op = op_temp;
			}
			else {
				*illegal = true;
				return 1;
			}
		}
		
		if(op != -1){
			int coe1 = 1;//系数,用于处理负号
		  int	coe2 = 1;
			int st1 = negative(&coe1, st, op - 1);
			int st2 = negative(&coe2, op + 1, en);
			
			int val1 = coe1 * eval(st1, op - 1, illegal);
			int val2 = coe2 * eval(st2, en, illegal);
			switch(tokens[op].type){
				case '+' : return val1 + val2;
				case '-' : return val1 - val2;
				case '*' : return val1 * val2;
				case '/' : 
				  if(!val2){
						assert(val2);
					}
			    return val1 / val2;	
				default : 
					*illegal = true;
					return 1;
			}
		}
		else{
			if(tokens[st].type != '-'){
				*illegal = true;
				return 1;
			}
			int k = st + 1;
			for(; k <= en; k++){
				if(tokens[k].type != '-'){
					break;
				}
			}
			int coe0 = 1;
			negative(&coe0, st, en);
			return coe0 * eval(k, en, illegal);
			
		}
	}
}

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
  //TODO();
	bool illegal;
  int re = eval(0, nr_token - 1, &illegal);
	*result = 0x100000000 + re;

  return 0;
}
