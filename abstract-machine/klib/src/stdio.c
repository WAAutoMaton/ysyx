#include <am.h>
#include <klib.h>
#include <klib-macros.h>
#include <stdarg.h>

#if !defined(__ISA_NATIVE__) || defined(__NATIVE_USE_KLIB__)

int printf(const char *fmt, ...) {
  panic("Not implemented");
}

int vsprintf(char *out, const char *fmt, va_list ap) {
  panic("Not implemented");
}

int sprintf(char *out, const char *fmt, ...) {
  va_list args;
  va_start(args, fmt);
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
        }
      } else {
        assert(*p=='d');
        int v = va_arg(args, int);
        if (v==0) {
          *out++ = '0';
          written++;
        } else {
          if (v<0) {
            *out++ = '-';
            written++;
            v = -v;
          }
          char *i_buf=out;
          int len=0;
          while(v>0) {
            len++;
            *out++ = '0' + v%10;
            v /= 10;
            written++;
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
    }
    p++;
  }
  *out='\0';
  va_end(args);
  return written;
}

int snprintf(char *out, size_t n, const char *fmt, ...) {
  panic("Not implemented");
}

int vsnprintf(char *out, size_t n, const char *fmt, va_list ap) {
  panic("Not implemented");
}

#endif
