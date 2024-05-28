#include <am.h>
#include <klib.h>
#include <klib-macros.h>
#include <stdarg.h>

#if !defined(__ISA_NATIVE__) || defined(__NATIVE_USE_KLIB__)

int printf(const char *fmt, ...) {
  char buf[1024];
  va_list args;
  va_start(args, fmt);
  int written = vsnprintf(buf, 1024, fmt, args);
  va_end(args);
  for(int i=0; i<written; i++) {
    putch(buf[i]);
  }
  return written;
}

int vsprintf(char *out, const char *fmt, va_list ap) {
  return vsnprintf(out, 0x1fffffff, fmt, ap);
}

int sprintf(char *out, const char *fmt, ...) {
  va_list args;
  va_start(args, fmt);
  int written = vsprintf(out, fmt, args);
  va_end(args);
  return written;
}

int snprintf(char *out, size_t n, const char *fmt, ...) {
  va_list args;
  va_start(args, fmt);
  int written = vsnprintf(out, n, fmt, args);
  va_end(args);
  return written;
}

#define CHECK_AND_RETURN do { \
  if (written>=n) { \
    return written; \
  } \
} while(0)
int vsnprintf(char *out, size_t n, const char *fmt, va_list args) {
  int written = 0;
  const char* p = fmt;
  while (*p!='\0') {
    if (*p=='%' && (*(p+1)=='s' || *(p+1)=='d')) {
      p++;
      if (*p=='s') {
        const char *str = va_arg(args, const char *);
        while (*str) {
            *out++ = *str++;
            written++;
            CHECK_AND_RETURN;
        }
      } else {
        assert(*p=='d');
        int v = va_arg(args, int);
        if (v==0) {
          *out++ = '0';
          written++;
          CHECK_AND_RETURN;
        } else {
          if (v<0) {
            *out++ = '-';
            written++;
            CHECK_AND_RETURN;
            v = -v;
          }
          char *i_buf=out;
          int len=0;
          while(v>0) {
            len++;
            *out++ = '0' + v%10;
            v /= 10;
            written++;
            CHECK_AND_RETURN;
          }
          for(int i=0; i<len/2; i++) {
            char t=i_buf[len-i-1];
            i_buf[len-i-1]=i_buf[i];
            i_buf[i]=t;
          }
        }
      }
    } else {
      *out++ = *p;
      written++;
      CHECK_AND_RETURN;
    }
    p++;
  }
  *out='\0';
  return written;
}

#endif
