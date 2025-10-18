#include <am.h>
#include <klib.h>
#include <klib-macros.h>
#include <stdarg.h>

#if !defined(__ISA_NATIVE__) || defined(__NATIVE_USE_KLIB__)

int uint2str(uint32_t value, char *buf) {
  char *p = buf;

  int i = 0;
  do {
    p[i++] = '0' + (value % 10);
    value /= 10;
  } while (value > 0);

  for (int j = 0; j < i / 2; j++) {
    char tmp = p[j];
    p[j] = p[i - 1 - j];
    p[i - 1 - j] = tmp;
  }
  p[i] = '\0';
  return i;
}

int int2str(int value, char *buf) {
  char *p = buf;
  int is_negative = 0;

  if (value < 0) {
    is_negative = 1;
    value = -value;
  }

  int i = 0;
  do {
    p[i++] = '0' + (value % 10);
    value /= 10;
  } while (value > 0);

  if (is_negative) p[i++] = '-';

  for (int j = 0; j < i / 2; j++) {
    char tmp = p[j];
    p[j] = p[i - 1 - j];
    p[i - 1 - j] = tmp;
  }
  p[i] = '\0';
  return i;
}

int x2str(uint32_t value, char *buf) {
  char *p = buf;
  int i = 0;
	uint32_t mod;
  do {
		mod = value % 16;
    if(mod < 10) p[i++] = '0' + mod;
		else         p[i++] = 'a' + mod - 10;
    value /= 16;
  } while (value > 0);

  for (int j = 0; j < i / 2; j++) {
    char tmp = p[j];
    p[j] = p[i - 1 - j];
    p[i - 1 - j] = tmp;
  }
  p[i] = '\0';
  return i;
}

int printf(const char *fmt, ...) {
  int len = 0;
  va_list args;
  va_start(args, fmt);

  for (const char *f = fmt; *f; f++) {
    if (*f != '%') {
      putch(*f);
      len++;
      continue;
    }

    f++; // skip '%'
    int preNum = ' ';
    int Nwidth = 0;
    if (*f == '0') { preNum = '0'; f++; }
    while (*f >= '0' && *f <= '9') {
      Nwidth = Nwidth * 10 + (*f - '0');
      f++;
    }

    char buf[32];
    int l = 0;
    int pad = 0;

    switch (*f) {
      case 'd': {
        int val = va_arg(args, int);
        l = int2str(val, buf);
        pad = (l < Nwidth) ? Nwidth - l : 0;
        for (int i = 0; i < pad; i++) putch(preNum);
        for (int i = 0; i < l; i++) putch(buf[i]);
        len += l + pad;
        break;
      }
      case 'u': {
        uint32_t val = va_arg(args, uint32_t);
        l = uint2str(val, buf);
        pad = (l < Nwidth) ? Nwidth - l : 0;
        for (int i = 0; i < pad; i++) putch(preNum);
        for (int i = 0; i < l; i++) putch(buf[i]);
        len += l + pad;
        break;
      }
      case 'x': {
        uint32_t val = va_arg(args, uint32_t);
        l = x2str(val, buf);
        pad = (l < Nwidth) ? Nwidth - l : 0;
        for (int i = 0; i < pad; i++) putch(preNum);
        for (int i = 0; i < l; i++) putch(buf[i]);
        len += l + pad;
        break;
      }
      case 's': {
        const char *s = va_arg(args, const char *);
        while (*s) { putch(*s++); len++; }
        break;
      }
      case 'c': {
        char c = (char)va_arg(args, int);
        putch(c); len++; break;
      }
      default:
        putch('%'); putch(*f);
        len += 2; break;
    }
  }

  va_end(args);
  return len;
}

//int printf(const char *fmt, ...) {
//	int len = 0;
//  va_list args;
//  va_start(args, fmt);
//
//  for (const char *f = fmt; *f != '\0'; f++) {
//    if (*f != '%') {
//			putch(*f);
//			len++;
//    } else {
//      f++;  // skip '%'
//			int preNum = ' ';
//			int Nwidth = 0;
//			if (*f >= '0' && *f <= '9') {
//				Nwidth = 0;
//				if(*f == '0'){
//					preNum = '0'; 
//					f++;
//				} 
//				while (*f >= '0' && *f <= '9') {
//					Nwidth = Nwidth * 10 + (*f - '0');
//					f++;
//				}
//			}
//      if (*f == 'd') {
//        int val = va_arg(args, int);
//        char buf[20];
//        int l = int2str(val, buf);
//				if(l < Nwidth){
//					for(int j = 0; j < Nwidth-l; j++){
//						putch((char)preNum);
//					}
//				}
//        for (int i = 0; i < l; i++) {
//					putch(buf[i]);
//				}
//				len += l;
//      } else if (*f == 's') {
//        const char *s = va_arg(args, const char *);
//        while (*s) {
//					putch(*s++);
//					len++;
//				}
//      } else if (*f == 'x') {
//        uint32_t val = va_arg(args, uint32_t);
//        char buf[20];
//        int l = x2str(val, buf);
//				if(l < Nwidth){
//					for(int j = 0; j < Nwidth-l; j++){
//						putch((char)preNum);
//					}
//				}
//        for (int i = 0; i < l; i++) {
//					putch(buf[i]);
//				}
//				len += l;
//			} else if (*f == 'c') {
//				const char c = (char)va_arg(args, int);
//				putch(c);
//				len++;
//			} else if (*f == 'u') {
//        uint32_t val = va_arg(args, uint32_t);
//        char buf[20];
//        int l = uint2str(val, buf);
//				if(l < Nwidth){
//					for(int j = 0; j < Nwidth-l; j++){
//						putch((char)preNum);
//					}
//				}
//        for (int i = 0; i < l; i++) {
//					putch(buf[i]);
//				}
//				len += l;
//      } else {
//        putch('%');
//        putch(*f);
//				len++;
//      }
//    }
//  }
//
//  putch('\0');  // 结尾 '\0'
//  va_end(args);
//  return len;  // 返回写入长度
//}

int vsprintf(char *out, const char *fmt, va_list ap) {
  panic("Not implemented");
}

int sprintf(char *out, const char *fmt, ...) {
  va_list args;
  va_start(args, fmt);

  char *p = out;
  for (const char *f = fmt; *f != '\0'; f++) {
    if (*f != '%') {
      *p++ = *f;
    } else {
      f++;  // skip '%'
      if (*f == 'd') {
        int val = va_arg(args, int);
        char buf[20];
        int len = int2str(val, buf);
        for (int i = 0; i < len; i++) *p++ = buf[i];
      } else if (*f == 's') {
        const char *s = va_arg(args, const char *);
        while (*s) *p++ = *s++;
      } else if (*f == 'x') {
        int val = va_arg(args, uint32_t);
        char buf[20];
        int len = x2str(val, buf);
        for (int i = 0; i < len; i++) *p++ = buf[i];
      } else if (*f == 'c') {
				const char c = (char)va_arg(args, int);
				*p++ = c;
			} else if (*f == 'u') {
        int val = va_arg(args, uint32_t);
        char buf[20];
        int len = uint2str(val, buf);
        for (int i = 0; i < len; i++) *p++ = buf[i];
      } else {
        *p++ = '%';
        *p++ = *f;
      }
    }
  }

  *p = '\0';  // 结尾 '\0'
  va_end(args);
  return p - out;  // 返回写入长度
}

int snprintf(char *out, size_t n, const char *fmt, ...) {
  panic("Not implemented");
}

int vsnprintf(char *out, size_t n, const char *fmt, va_list ap) {
  panic("Not implemented");
}

#endif
