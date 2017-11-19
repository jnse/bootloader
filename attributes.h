/**
 * Compiler specific attribute macros.
 */
#ifndef ATTRIBUTES_H_INCLUDE
#define ATTRIBUTES_H_INCLUDE

// Just gcc macros for now.
#define NOINLINE __attribute__((noinline))
#define REGPARM __attribute__ ((regparm(3)))
#define NORETURN __attribute__((noreturn))
#define FASTCALL __attribute__((fastcall))
#define THISCALL __attribute__((thiscall)) 
#define PACKED __attribute__((packed))

#endif
