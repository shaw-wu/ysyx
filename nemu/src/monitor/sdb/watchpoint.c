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

#include "sdb.h"

#define NR_WP 32

/*wxz*/
static WP wp_pool[NR_WP] = {};
WP *head = NULL, *free_ = NULL;

void init_wp_pool() {
  int i;
  for (i = 0; i < NR_WP; i ++) {
    wp_pool[i].NO = i;
    wp_pool[i].next = (i == NR_WP - 1 ? NULL : &wp_pool[i + 1]);
		memset(wp_pool[i].expr, '\0', 65536);
		wp_pool[i].result = 0;
  }

  head = NULL;
  free_ = wp_pool;
}

/* TODO: Implement the functionality of watchpoint */
WP* new_wp(){
	assert(free_);
	
	WP *p = free_;
	free_ = p->next;
	p->next = head;
	head = p;

	return p;
}

void free_wp(WP *wp){
	int no = wp->NO;
	WP *p, *s;
	s = head;
	assert(head);
	p = s;

	while(p->NO != no){
		assert(p->next);
		s = p;
		p = s->next;	
	}
	memset(p->expr, '\0', 65536);//清除wp的内容
	p->result = 0;
	head = p->next;
	p->next = free_;
	free_ = p;
	return;
}
