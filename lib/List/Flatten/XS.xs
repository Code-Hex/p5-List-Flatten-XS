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
flatten(...)
PROTOTYPE: @
PPCODE:
{
    // my @args = @_ > 1 ? @_ : @{$_[0]};
    I32 i;
    AV *args = newAV();
    sv_2mortal((SV*)args);
    SV **argv = &PL_stack_base[ax];
    
    if (!items) croak("Please give me arguments");

    if (items > 1) {
        for (i = 0; i < items; i++)
            av_push(args, argv[i]);
    } else {
        if (!SvROK( argv[0] )) croak("ref(array) expected");
        AV *deref = (AV *)SvRV( argv[0] );
        for (i = 0; i < av_len(deref) + 1; i++) {
            SV **fetch = av_fetch(deref, i, FALSE);
            if (!fetch) croak("deref[%d] is null", i);
            av_push(args, *fetch);
        }
    }
    
    SV *val;
    I32 len;
    AV *ary;
    AV *result = newAV();

    while (av_len(args) + 1) {
        val = av_shift(args);
        if (SvROK(val) && SvTYPE(SvRV(val)) == SVt_PVAV) {
            ary = (AV *)SvRV(val);
            len = av_len(ary) + 1;
            av_unshift(args, len);
            for (i = 0; i < len; i++) {
                SV **fetch = av_fetch(ary, i, FALSE);
                if (!fetch) croak("ary[%d] is null", i);
                av_store(args, i, *fetch);
            }
        } else {
            av_push(result, val);
        }
    }

    if (GIMME_V == G_ARRAY) {
        len = av_len(result) + 1;
        for (i = 0; i < len; i++) {
            SV **fetch = av_fetch(result, i, FALSE);
            if (!fetch) croak("result[%d] is null", i);
            ST(i) = *fetch;
        }
        XSRETURN(len);
    } else {
        ST(0) = sv_2mortal( newRV_inc((SV*)result) );
        XSRETURN(1);
    }
}