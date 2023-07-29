#ifndef _GNU_SOURCE
#define _GNU_SOURCE
#endif
#include <stdio.h>
#include <dlfcn.h>
#include "svdpi.h"

#ifdef __cplusplus
extern "C" {
#endif

/* VCS error reporting routine */
extern void vcsMsgReport1(const char *, const char *, int, void *, void*, const char *);

#ifndef _VC_TYPES_
#define _VC_TYPES_
/* common definitions shared with DirectC.h */

typedef unsigned int U;
typedef unsigned char UB;
typedef unsigned char scalar;
typedef struct { U c; U d;} vec32;

#define scalar_0 0
#define scalar_1 1
#define scalar_z 2
#define scalar_x 3

extern long long int ConvUP2LLI(U* a);
extern void ConvLLI2UP(long long int a1, U* a2);
extern long long int GetLLIresult();
extern void StoreLLIresult(const unsigned int* data);
typedef struct VeriC_Descriptor *vc_handle;

#ifndef SV_3_COMPATIBILITY
#define SV_STRING const char*
#else
#define SV_STRING char*
#endif

#endif /* _VC_TYPES_ */

#ifndef __VCS_IMPORT_DPI_STUB_jtagdpi_create
#define __VCS_IMPORT_DPI_STUB_jtagdpi_create
__attribute__((weak)) void* jtagdpi_create(/* INPUT */const char* A_1, /* INPUT */int A_2)
{
    static int _vcs_dpi_stub_initialized_ = 0;
    static void* (*_vcs_dpi_fp_)(/* INPUT */const char* A_1, /* INPUT */int A_2) = NULL;
    if (!_vcs_dpi_stub_initialized_) {
        _vcs_dpi_fp_ = (void* (*)(const char* A_1, int A_2)) dlsym(RTLD_NEXT, "jtagdpi_create");
        _vcs_dpi_stub_initialized_ = 1;
    }
    if (_vcs_dpi_fp_) {
        return _vcs_dpi_fp_(A_1, A_2);
    } else {
        const char *fileName;
        int lineNumber;
        svGetCallerInfo(&fileName, &lineNumber);
        vcsMsgReport1("DPI-DIFNF", fileName, lineNumber, 0, 0, "jtagdpi_create");
        return 0;
    }
}
#endif /* __VCS_IMPORT_DPI_STUB_jtagdpi_create */

#ifndef __VCS_IMPORT_DPI_STUB_jtagdpi_tick
#define __VCS_IMPORT_DPI_STUB_jtagdpi_tick
__attribute__((weak)) void jtagdpi_tick(/* INPUT */void* A_1, /* OUTPUT */unsigned char *A_2, /* OUTPUT */unsigned char *A_3, /* OUTPUT */unsigned char *A_4, /* OUTPUT */unsigned char *A_5, /* OUTPUT */unsigned char *A_6, /* INPUT */unsigned char A_7)
{
    static int _vcs_dpi_stub_initialized_ = 0;
    static void (*_vcs_dpi_fp_)(/* INPUT */void* A_1, /* OUTPUT */unsigned char *A_2, /* OUTPUT */unsigned char *A_3, /* OUTPUT */unsigned char *A_4, /* OUTPUT */unsigned char *A_5, /* OUTPUT */unsigned char *A_6, /* INPUT */unsigned char A_7) = NULL;
    if (!_vcs_dpi_stub_initialized_) {
        _vcs_dpi_fp_ = (void (*)(void* A_1, unsigned char* A_2, unsigned char* A_3, unsigned char* A_4, unsigned char* A_5, unsigned char* A_6, unsigned char A_7)) dlsym(RTLD_NEXT, "jtagdpi_tick");
        _vcs_dpi_stub_initialized_ = 1;
    }
    if (_vcs_dpi_fp_) {
        _vcs_dpi_fp_(A_1, A_2, A_3, A_4, A_5, A_6, A_7);
    } else {
        const char *fileName;
        int lineNumber;
        svGetCallerInfo(&fileName, &lineNumber);
        vcsMsgReport1("DPI-DIFNF", fileName, lineNumber, 0, 0, "jtagdpi_tick");
    }
}
#endif /* __VCS_IMPORT_DPI_STUB_jtagdpi_tick */

#ifndef __VCS_IMPORT_DPI_STUB_jtagdpi_close
#define __VCS_IMPORT_DPI_STUB_jtagdpi_close
__attribute__((weak)) void jtagdpi_close(/* INPUT */void* A_1)
{
    static int _vcs_dpi_stub_initialized_ = 0;
    static void (*_vcs_dpi_fp_)(/* INPUT */void* A_1) = NULL;
    if (!_vcs_dpi_stub_initialized_) {
        _vcs_dpi_fp_ = (void (*)(void* A_1)) dlsym(RTLD_NEXT, "jtagdpi_close");
        _vcs_dpi_stub_initialized_ = 1;
    }
    if (_vcs_dpi_fp_) {
        _vcs_dpi_fp_(A_1);
    } else {
        const char *fileName;
        int lineNumber;
        svGetCallerInfo(&fileName, &lineNumber);
        vcsMsgReport1("DPI-DIFNF", fileName, lineNumber, 0, 0, "jtagdpi_close");
    }
}
#endif /* __VCS_IMPORT_DPI_STUB_jtagdpi_close */


#ifdef __cplusplus
}
#endif

