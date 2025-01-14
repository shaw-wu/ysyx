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

//初始化监视点池
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

//创建监视点,从free_链表拿监视点成员出来,从free_头取出,从head头添加
WP* new_wp(){
	if(!free_){
		printf("Error: Empty pointer free_\n");
		return NULL;
	}
	
	WP *p = free_;
	free_ = p->next;
	p->next = head;
	head = p;

	return p;
}

//释放监视点,从head链表取出监视点放回free_池,放回free_头
void free_wp(WP *wp){
	int no = wp->NO;
	WP *p, *s;
	s = head;
	if(!head){
		printf("Error: Empty pointer head\n");
		return;
	}
	p = s;

	//遍历查找
	while(p){
		if(p->NO == no) break;
		s = p;
		p = s->next;		
	}
	if(!p){
		Log("Can't find watchpoint %d", no);
	}
	//清除wp的内容
	memset(p->expr, '\0', 65536);
	p->result = 0;
	//这里head不能算是链表的一部分,只是一个指向表头的指针
	if(s == p){
		head = p->next;
	}
	else{
		s->next = p->next;
	}
	p->next = free_;
	free_ = p;
	return;
}
