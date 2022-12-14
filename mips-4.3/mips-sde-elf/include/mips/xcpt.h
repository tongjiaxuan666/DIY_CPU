/*
 * Copyright (c) 1996-2007 MIPS Technologies, Inc.
 * Copyright (C) 2008 CodeSourcery, Inc.
 * 
 * All rights reserved.
 * 
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 
 *      * Redistributions of source code must retain the above copyright
 *        notice, this list of conditions and the following disclaimer.
 *      * Redistributions in binary form must reproduce the above
 *      copyright
 *        notice, this list of conditions and the following disclaimer
 *        in the documentation and/or other materials provided with
 *        the distribution.
 *      * Neither the name of MIPS Technologies Inc. nor the names of its
 *        contributors may be used to endorse or promote products derived
 *        from this software without specific prior written permission.
 * 
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
 * A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
 * OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
 * LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 * DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
 * THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

/*
 * xcpt.h: include appropriate SDE xception handling definitions
 */


#ifndef _XCPT_H_
#define _XCPT_H_
#include "cpu.h"

#ifdef __cplusplus
extern "C" {
#endif

/* Exception class bitfields */
#define XCPC_CLASS	0x0ff	/* exception class number */
#define XCPC_USRSTACK	0x100	/* xcptcontext is on user stack */

/* Saved register size */
#ifndef XCP_RSIZE
# if __mips64
#  define XCP_RSIZE	8
# else
#  define XCP_RSIZE	4
# endif
#endif

/* xcptjmpbuf layout and size */
#define XJB_S0		0
#define XJB_S1		1
#define XJB_S2		2
#define XJB_S3		3
#define XJB_S4		4
#define XJB_S5		5
#define XJB_S6		6
#define XJB_S7		7
#define XJB_SP		8
#define XJB_S8		9
#define XJB_RA		10
#define XJB_SR		11
#define XJB_SIZE	(12*XCP_RSIZE)

#ifndef __ASSEMBLER__

/* Define exception classes. */
#define XCPCDEF(NAME, CLASS, SIG, DESC) NAME = CLASS ,
enum xcptclass {
#include "xcptcpu.h"
    XCPC_LAST
};

#undef XCPCDEF

/* Define exception codes. */
#define XCPTDEF(NAME, CODE, SIG, BRIEF, DESC) NAME = CODE ,
enum xcptcode {
#include "xcptcpu.h"
    XCPT_LAST
};
#undef XCPTDEF

/* The standard exception context stack frame. */
struct xcptcontext {
    reg_t		sr;		/* CP0 Status register */
    reg_t		cr;		/* CP0 Cause register */
    reg_t		epc;		/* CP0 EPC register */
    reg_t		vaddr;		/* CP0 BadVaddr register */

    reg_t		regs[32];	/* General registers */
    reg_t		mdlo;		/* Multiply/Divide LO */
    reg_t		mdhi;		/* Multiply/Divide HI */
    reg_t		mdex;		/* Multiply/Divide ACX */

    struct xcptcontext	*prev;		/* Previous exception context */
    unsigned int	xclass;		/* Exception class and other flags */
    unsigned int	signo;		/* Signal generated by this exception */

#ifdef _xcptcontext_cpu
    _xcptcontext_cpu			/* CPU-specific extras */
#endif
};


/* Commonly used general purpose register names */
#define XCP_ZERO	0
#define XCP_AT		1
#define XCP_V0		2
#define XCP_V1		3
#define XCP_A0		4
#define XCP_A1		5
#define XCP_A2		6
#define XCP_A3		7
#define XCP_S0		16
#define XCP_S1		17
#define XCP_K0		26
#define XCP_K1		27
#define XCP_GP		28
#define XCP_SP		29
#define XCP_S8		30
#define XCP_RA		31

/* Return bottom 32 bits of CP0 Status */
#define XCP_STATUS(xcp)		((unsigned int)(xcp)->sr)

/* Return bottom 32 bits of CP0 Cause */
#define XCP_CAUSE(xcp)		((unsigned int)(xcp)->cr)

/* Return the exception number */
#define XCP_CODE(xcp)		(enum xcptcode)((XCP_CAUSE(xcp) & CR_XMASK) >> 2)

/* Return the exception class */
#define XCP_CLASS(xcp)		((xcp)->xclass & XCPC_CLASS)

/* Return true if context on user stack */
#define XCP_USRSTACK(xcp)	((xcp)->xclass & XCPC_USRSTACK)

#ifdef XCPC_CACHEERR
/* Cache Error Exception Context */
struct cxcptcontext {
    reg_t	cacheerr;	/* CP0 CacheErr register */
    reg_t	errpc;		/* CP0 ErrPC register */
    reg_t	taglo;		/* CP0 TagLo register */
    reg_t	taghi;		/* CP0 TagHi register */
    reg_t	ecc;		/* CP0 ECC register */
    reg_t	config;		/* CP0 Config0 register */
#ifdef _cxcptcontext_cpu
    _cxcptcontext_cpu
#endif
};
#endif

extern const char *const _sys_xcptlist[];

#ifdef __STDC__
typedef int (*xcpt_t)(int, struct xcptcontext *);
#else
typedef int (*xcpt_t)();
#endif

typedef reg_t xcptjmp_buf[XJB_SIZE/sizeof(reg_t)];

/*
 * Structure used to define low-level xception handler.
 */
struct xcptaction {
    xcpt_t	xa_handler;
    unsigned 	xa_flags;	/* must be zero */
};

/* Bitmap of interrupts (max 64) */
typedef unsigned long long intrset_t;

/*
 * Structure used to define mid-level interrupt handler.
 */
struct intraction {
    xcpt_t	ia_handler;	/* handler function */
    int		ia_arg;		/* passed to handler */
#ifdef NEWINTRUPT
    intrset_t	ia_mask;	/* new mask to apply */
#else
    unsigned	ia_ipl;
#endif
    unsigned 	ia_flags;	/* see below */
};

/* interrupt configuration for intrsettype() */
typedef struct {
    enum {
	INTRTYPE_LEVEL_LO,
	INTRTYPE_LEVEL_HI,
	INTRTYPE_PULSE_LO,
	INTRTYPE_PULSE_HI,
	INTRTYPE_EDGE_FALLING,
	INTRTYPE_EDGE_RISING
    } mode;
    /* other add useful could be added here */
} intrtype_t;


#define XCPT_DFL	(xcpt_t)0
#define XCPT_ERR	(xcpt_t)-1

/* states returned from xcptstackinfo */
enum  XcptStackTraceStates {
    XcptStackTracePC,		/* Valid PC */
    XcptStackTraceLast,		/* Stacktrace completed */
    XcptStackTraceLoop,		/* Stacktrace completed - loop detected */
    XcptStackTraceBadPC,	/* Stacktrace completed - bad PC */
    XcptStackTraceNA,		/* Not available */
};


/* install exception handlers */
extern int xcptaction (enum xcptcode, struct xcptaction *, struct xcptaction *);
extern xcpt_t xcption (enum xcptcode, xcpt_t);

/* setjmp/longjmp free of floating-point, but with interrupt mask */
#if __GNUC__ >= 4
extern int xcptsetjmp (xcptjmp_buf) __attribute__ ((returns_twice));
#else
extern int xcptsetjmp (xcptjmp_buf);
#endif
extern void xcptlongjmp (xcptjmp_buf, int) __attribute__ ((noreturn));

/* return to a different exception context */
extern void xcptrestore (struct xcptcontext *xcp) __attribute__ ((noreturn));

/* display an exception context */
extern void xcpt_show (struct xcptcontext *);
extern void xcpt_showmin (struct xcptcontext *);

/* display a stack backtrace */
extern enum XcptStackTraceStates xcptstackinfo (struct xcptcontext *xcp,
						int atdepth, void **vap);
extern void xcptstacktrace (struct xcptcontext *);
extern void _xcptstackinfo_load (void);	/* install full code */

/* similar routines for interrupt handling */
extern int intraction (unsigned int, const struct intraction *, 
		       struct intraction *);
extern xcpt_t intrupt (unsigned int, xcpt_t, int);

/* test for pending interrupts */
#ifdef NEWINTRUPT
extern int intrpending (intrset_t *);
#else
extern int intrpending (unsigned int);
#endif

/* manipulate interrupt mask */
extern int intrprocmask (int, const intrset_t *, intrset_t *);

/* configure interrupt pin */
extern int intrtype (int, const intrtype_t *, intrtype_t *);

/* set priority level (*nix style) */
#ifndef _KERNEL
extern unsigned int spln (unsigned int);
extern unsigned int splx (unsigned int);
#endif

/* software interrupt (0/1) on/off */
extern void siron (unsigned int);
extern void siroff (unsigned int);

#else /* __ASSEMBLER__ */

/* Define exception classes. */
#define XCPCDEF(NAME, CLASS, SIG, DESC) .equ NAME, CLASS
#include "xcptcpu.h"
#undef XCPCDEF

/* Define exception numbers. */
#define XCPTDEF(NAME, CODE, SIG, BRIEF, DESC) .equ NAME, CODE
#include "xcptcpu.h"
#undef XCPTDEF

#if XCP_RSIZE == 8
#define xcpreg	.dword 0
#else
#define xcpreg	.word 0
#endif

/* The exception context stack frame (assembler version). */
	.struct 0
XCP_SR:		xcpreg
XCP_CR:		xcpreg
XCP_EPC:	xcpreg
XCP_VADDR:	xcpreg
XCP_R0:		xcpreg
XCP_R1:		xcpreg
XCP_R2:		xcpreg
XCP_R3:		xcpreg
XCP_R4:		xcpreg
XCP_R5:		xcpreg
XCP_R6:		xcpreg
XCP_R7:		xcpreg
XCP_R8:		xcpreg
XCP_R9:		xcpreg
XCP_R10:	xcpreg
XCP_R11:	xcpreg
XCP_R12:	xcpreg
XCP_R13:	xcpreg
XCP_R14:	xcpreg
XCP_R15:	xcpreg
XCP_R16:	xcpreg
XCP_R17:	xcpreg
XCP_R18:	xcpreg
XCP_R19:	xcpreg
XCP_R20:	xcpreg
XCP_R21:	xcpreg
XCP_R22:	xcpreg
XCP_R23:	xcpreg
XCP_R24:	xcpreg
XCP_R25:	xcpreg
XCP_R26:	xcpreg
XCP_R27:	xcpreg
XCP_R28:	xcpreg
XCP_R29:	xcpreg
XCP_R30:	xcpreg
XCP_R31:	xcpreg
XCP_MDLO:	xcpreg
XCP_MDHI:	xcpreg
XCP_MDEX:	xcpreg
XCP_PREV:	PTR 0
XCP_XCLASS:	.word 0
XCP_SIGNO:	.word 0
#ifdef _xcptcontext_cpu_asm
_xcptcontext_cpu_asm
#endif
XCP_SIZE:	
	.previous

/* Commonly used general purpose register names in context */
#define XCP_ZERO	XCP_R0
#define XCP_AT		XCP_R1
#define XCP_V0		XCP_R2
#define XCP_V1		XCP_R3
#define XCP_A0		XCP_R4
#define XCP_A1		XCP_R5
#define XCP_A2		XCP_R6
#define XCP_A3		XCP_R7
#define XCP_S0		XCP_R16
#define XCP_S1		XCP_R17
#define XCP_K0		XCP_R26
#define XCP_K1		XCP_R27
#define XCP_GP		XCP_R28
#define XCP_SP		XCP_R29
#define XCP_S8		XCP_R30
#define XCP_RA		XCP_R31

#ifdef C0_CACHEERR
/* Cache Exception Context */
	.struct 0
CXCP_CACHEERR:	xcpreg
CXCP_ERRPC:	xcpreg
CXCP_TAGLO:	xcpreg
CXCP_TAGHI:	xcpreg
CXCP_ECC:	xcpreg
CXCP_CONFIG:	xcpreg
#ifdef _cxcptcontext_cpu_asm
    _cxcptcontext_cpu_asm
#endif
CXCP_SIZE:
	.previous
#endif /* C0_CACHEERR */

#undef xcpreg

#endif /* __ASSEMBLER__ */

/* macros for interrupt mask manipulation */
#define	intraddset(set, intrno)	(*(set) |= 1ULL << ((intrno)-1), 0)
#define	intrdelset(set, intrno)	(*(set) &= ~(1ULL << ((intrno)-1)), 0)
#define	intremptyset(set)	(*(set) = 0, 0)
#define	intrfillset(set)	(*(set) = ~(intrset_t)0, 0)
#define	intrismember(set, intrno) ((*(set) & (1ULL << ((intrno)-1))) != 0)

/* how argument for intrprocmask() */
#define	INTR_DISABLE	1	/* disable specified interrupt set */
#define	INTR_ENABLE	2	/* enable specified interrupt set */
#define	INTR_SETMASK	3	/* set specified interrupt enables */

/* xcptaction/intraction flags */
#define XA_SHORT	0x01	/* no 's' regs in xcptcontext */
#define XA_NO_SREG	0x01	/* no 's' regs in xcptcontext */
#define XA_ASM		0x02	/* assembler-level handler */

#ifdef __cplusplus
}
#endif
#endif /*_XCPT_H_*/
