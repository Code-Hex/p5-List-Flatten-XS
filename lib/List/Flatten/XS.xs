#ifdef __cplusplus
extern "C" {
#endif

#define PERL_NO_GET_CONTEXT /* we want efficiency */
#include <EXTERN.h>
#include <perl.h>
#include <XSUB.h>

#ifdef __cplusplus
} /* extern "C" */
#endif

#define NEED_newSVpvn_flags
#include "ppport.h"

MODULE = List::Flatten::XS    PACKAGE = List::Flatten::XS

PROTOTYPES: DISABLE

AV *
flatten(...)
CODE:
    AV *args;
    if (items > 1) {
        args = (AV*)sv_2mortal((SV*)newAV());
        for (I32 i = 0; i < items; i++)
            av_push(args, newSVsv(ST(i)));
    } else {
        if (!SvROK(ST(0)))
            croak("ref(array) expected");
        args = (AV *)SvRV(ST(0));
    }
    
    SV *val;
    I32 len;
    AV *ary;
    AV *result = (AV*)sv_2mortal((SV*)newAV());

    while(av_len(args) + 1) {
        val = av_shift(args);
        if (SvROK(val) && SvTYPE(SvRV(val)) == SVt_PVAV) {
            ary = (AV *)SvRV(val);
            len = av_len(ary) + 1;
            av_unshift(args, len);
            for (I32 i = 0; i < len; i++) {
                SV** val_ptr = av_fetch(ary, i, FALSE);
                SV* sv = val_ptr ? *val_ptr : &PL_sv_undef;
                av_store(args, i, sv);
            }
        } else {
            av_push(result, val);
        }
    }

    RETVAL = result;
OUTPUT:
    RETVAL
