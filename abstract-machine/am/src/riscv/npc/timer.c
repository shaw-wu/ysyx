#include <am.h>
#include <npc.h>

void __am_timer_init() {
}

void __am_timer_uptime(AM_TIMER_UPTIME_T *uptime) {
	uint32_t mcycle, mcycleh;
	__asm__ volatile ("csrr %0, mcycle" : "=r" (mcycle));
	__asm__ volatile ("csrr %0, mcycleh" : "=r" (mcycleh));
	uint64_t cycle = ((uint64_t)mcycle) | ((uint64_t)mcycleh << 32);
	//uint32_t uptime_l, uptime_h;
	//uptime_h = inl(RTC_ADDR+4);
	//uptime_l = inl(RTC_ADDR);
	uptime->us = (cycle * 1000000) / FREQ;
	if((uptime->us % 100000000 == 0) && uptime->us >= 100000000) putch('w');
}

void __am_timer_rtc(AM_TIMER_RTC_T *rtc) {
  rtc->second = 0;
  rtc->minute = 0;
  rtc->hour   = 0;
  rtc->day    = 0;
  rtc->month  = 0;
  rtc->year   = 1900;
}
