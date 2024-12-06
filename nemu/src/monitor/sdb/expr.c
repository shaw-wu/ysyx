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
  TK_NOTYPE = 256, TK_LBRKET, TK_RBRKET, TK_EQ, TK_DIG,

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
  {"\\(" , TK_LBRKET},   // left brackets
  {"\\)" , TK_RBRKET},   // right brackets
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

static Token tokens[32] __attribute__((used)) = {};/*__attribute__((used)) 提示编译器不要优化 wxz*/
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
				char* end_flag = '\000';
        switch (rules[i].token_type) {
          case TK_NOTYPE: 
						break;
          case TK_LBRKET : 
						tokens[nr_token].type = TK_LBRKET;
						assert(substr_len < 32);
					  strncpy(tokens[nr_token].str, substr_start, substr_len);
					  strcat(end_flag, tokens[nr_token].str+substr_len); 
						nr_token++;
						break;
          case TK_RBRKET : 
						tokens[nr_token].type = TK_RBRKET;
						assert(substr_len < 32);
					  strncpy(tokens[nr_token].str, substr_start, substr_len);
						nr_token++;
						break;
          case '*'      : 
						tokens[nr_token].type = '*';
						assert(substr_len < 32);
					  strncpy(tokens[nr_token].str, substr_start, substr_len);
						nr_token++;
						break;
          case '/'      : 
						tokens[nr_token].type = '/';
						assert(substr_len < 32);
					  strncpy(tokens[nr_token].str, substr_start, substr_len);
						nr_token++;
						break;
          case '+'      : 
						tokens[nr_token].type = '+';
						assert(substr_len < 32);
					  strncpy(tokens[nr_token].str, substr_start, substr_len);
						nr_token++;
						break;
          case '-'      : 
						tokens[nr_token].type = '-';
						assert(substr_len < 32);
					  strncpy(tokens[nr_token].str, substr_start, substr_len);
						nr_token++;
						break;
          case TK_EQ    : 
						tokens[nr_token].type = TK_EQ;
						assert(substr_len < 32);
					  strncpy(tokens[nr_token].str, substr_start, substr_len);
						nr_token++;
						break;
          case TK_DIG   : 
						tokens[nr_token].type = TK_DIG;
						assert(substr_len < 32);
					  strncpy(tokens[nr_token].str, substr_start, substr_len);
						nr_token++;
						break;
          default: TODO();
        }

        break;
      }
    }

    if (i == NR_REGEX) {
      printf("no match at position %d\n%s\n%*.s^\n", position, e, position, "");
      return false;
    }
  }

	printf("nr_token: %d\n",nr_token);
	printf("position: %d\n",position);
	for(int k = 0; k < nr_token; k++){
		printf("%s",tokens[k].str);
	}
	printf("\n");
	for(int k = 0; k < nr_token; k++){
		printf("(%d)",tokens[k].type);
	}
	printf("\n");

  return true;
}


word_t expr(char *e, bool *success) {
  if (!make_token(e)) {
    *success = false;
    return 0;
  }

  /* TODO: Insert codes to evaluate the expression. */
  //TODO();

  return 0;
}
