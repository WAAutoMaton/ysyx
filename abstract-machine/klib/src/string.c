#include <klib.h>
#include <klib-macros.h>
#include <stdint.h>

#if !defined(__ISA_NATIVE__) || defined(__NATIVE_USE_KLIB__)

size_t strlen(const char *s) {
  int l=0;
  while(*s!='\0') {
    l++;
    s++;
  }
  return l;
}

char *strcpy(char *dst, const char *src) {
  char *result=dst;
  while(*src!='\0') {
    *dst=*src;
    src++;
    dst++;
  }
  *dst='\0';
  return result;
}

char *strncpy(char *dst, const char *src, size_t n) {
  char *result=dst;
  int c=0;
  while(*src!='\0') {
    if (c>=n) {
      break;
    }
    c++;
    *dst=*src;
    src++;
    dst++;
  }
  while(c<=n) {
    c++;
    *dst='\0';
    dst++;
  }
  return result;
}

char *strcat(char *dst, const char *src) {
  char *result=dst;
  while(*dst!='\0') {
    dst++;
  }
  while(*src!='\0') {
    *dst=*src;
    src++;
    dst++;
  }
  return result;
}

int strcmp(const char *s1, const char *s2) {
  while(*s1!='\0' && *s2!='\0') {
    if (*s1!=*s2) {
      return *s1-*s2;
    }
    s1++;
    s2++;
  }
  if (*s1!='\0') {
    return 1;
  } else if (*s2!='\0') {
    return -1;
  } else {
    return 0;
  }
}

int strncmp(const char *s1, const char *s2, size_t n) {
  int c=0;
  while(*s1!='\0' && *s2!='\0' && c<n) {
    c++;
    if (*s1!=*s2) {
      return *s1-*s2;
    }
    s1++;
    s2++;
  }
  if (*s1!='\0' && *s2=='\0') {
    return 1;
  } else if (*s2!='\0' && *s1=='\0') {
    return -1;
  } else {
    return 0;
  }
}

void *memset(void *s, int c, size_t n) {
  for(int i=0; i<n; i++) {
    ((uint8_t*)s)[i]=c;
  }
  return s;
}

void *memmove(void *dest, const void *src, size_t n) {
  uint8_t* from = (uint8_t*) src;
	uint8_t* to = (uint8_t*) dest;

	if (from == to || n == 0)
		return dest;
	if (to > from && to-from < (int)n) {
		/* to overlaps with from */
		/*  <from......>         */
		/*         <to........>  */
		/* copy in reverse, to avoid overwriting from */
		int i;
		for(i=n-1; i>=0; i--)
			to[i] = from[i];
		return dest;
	}
	if (from > to && from-to < (int)n) {
		/* to overlaps with from */
		/*        <from......>   */
		/*  <to........>         */
		/* copy forwards, to avoid overwriting from */
		size_t i;
		for(i=0; i<n; i++)
			to[i] = from[i];
		return dest;
	}
	memcpy(dest, src, n);
	return dest;
}

void *memcpy(void *out, const void *in, size_t n) {
  for(int i=0; i<n; i++) {
    ((char*)out)[i]=((char*)in)[i];
  }
  return out;
}

int memcmp(const void *s1, const void *s2, size_t n) {
  for(int i=0; i<n; i++) {
    if (((uint8_t*)s1)[i]!=((uint8_t*)s2)[i]) {
      return ((uint8_t*)s1)[i]-((uint8_t*)s2)[i];
    }
  }
  return 0;
}

#endif
