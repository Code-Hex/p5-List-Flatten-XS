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

PROTOTYPES: ENABLE

void *
_flatten(...)
PROTOTYPE: @
PPCODE:
{
    if (!items) XSRETURN_EMPTY;

    I32 i;
    SV **argv = &PL_stack_base[ax];
    AV *args = (AV *)sv_2mortal( (SV *)newAV() );

    for (i = 0; i < items; i++)
        av_push(args, argv[i]);
    
    I32 len;
    SV *val;
    AV *result = newAV();

    while (av_len(args) + 1) {
        val = av_shift(args);
        if (SvROK(val) && SvTYPE(SvRV(val)) == SVt_PVAV) {
            AV *ary = (AV *)SvRV(val); // dereference
            len = av_len(ary) + 1;
            av_unshift(args, len);
            for (i = 0; i < len; i++)
                av_store(args, i, *av_fetch(ary, i, FALSE));
        } else {
            av_push(result, val);
        }
    }
    
    if (GIMME_V == G_ARRAY) {
        len = av_len(result) + 1;
        for (i = 0; i < len; i++)
            ST(i) = *av_fetch(result, i, FALSE);
        XSRETURN(len);
    }

    ST(0) = sv_2mortal( newRV_inc((SV*)result) );
    XSRETURN(1);
}