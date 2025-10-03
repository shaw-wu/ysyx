#include <klib.h>
#include <klib-macros.h>
#include <stdint.h>

#if !defined(__ISA_NATIVE__) || defined(__NATIVE_USE_KLIB__)

size_t strlen(const char *s) {
	size_t len = 0;
	while(s[len] != '\0') len++;
	return len;
}

char *strcpy(char *dst, const char *src) {
  char *ret = dst;
  while ((*dst++ = *src++) != '\0');
  return ret;
}

char *strncpy(char *dst, const char *src, size_t n) {
  char *ret = dst;
  size_t i = 0;
  while (i < n && src[i] != '\0') {
    dst[i] = src[i];
    i++;
  }
  while (i < n) {
    dst[i++] = '\0';
  }
  return ret;
}

char *strcat(char *dst, const char *src) {
	char *ret = dst;
	while(*dst) dst++;
	while((*dst++ = *src++));
	return ret;
}

int strcmp(const char *s1, const char *s2) {
  while (*s1 && (*s1 == *s2)) {
    s1++;
    s2++;
  }
  return (unsigned char)(*s1) - (unsigned char)(*s2);
}

int strncmp(const char *s1, const char *s2, size_t n) {
  size_t i = 0;
  if (n == 0) return 0; 

  while (i < n && s1[i] && (s1[i] == s2[i])) {
    i++;
  }

  if (i == n) return 0; 
  return (unsigned char)s1[i] - (unsigned char)s2[i];
}

void *memset(void *s, int c, size_t n) {
	unsigned char *tmp = (unsigned char *)s;
	while(n--) *tmp++ = (unsigned char)c;
	return s;
}

void *memmove(void *dest, const void *src, size_t n) {
  unsigned char *d = (unsigned char *)dest;
  const unsigned char *s = (const unsigned char *)src;

  if (d < s) {
		while (n--) *d++ = *s++;
  } else if (d > s) {
    d += n;
    s += n;
    while (n--) *(--d) = *(--s);
  }
  return dest;
}

void *memcpy(void *out, const void *in, size_t n) {
  unsigned char *o = (unsigned char *)out;
  const unsigned char *i = (const unsigned char *)in;
  while (n--) {
		*o++ = *i++;
  }
  return out;
}

int memcmp(const void *s1, const void *s2, size_t n) {
  const unsigned char *p1 = (const unsigned char *)s1;
  const unsigned char *p2 = (const unsigned char *)s2;

  while (n--) {
    if (*p1 != *p2)
      return *p1 - *p2; 
    p1++;
    p2++;
  }

  return 0; 
}

#endif
