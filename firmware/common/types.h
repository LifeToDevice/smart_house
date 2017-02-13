#ifndef _COMMON_TYPES_H_
#define _COMMON_TYPES_H_

#ifdef WIN32   // Windows
        
typedef unsigned char  uchar;   // 1
typedef unsigned short ushort;  // 2
typedef unsigned long  ulong;   // 4

#else          // PIC18

#define NULL   (void *)0

#define TRUE   1
#define FALSE  0

typedef unsigned char  uchar;   // 1
typedef unsigned int   ushort;  // 2
typedef unsigned long  ulong;   // 4

#endif

#endif