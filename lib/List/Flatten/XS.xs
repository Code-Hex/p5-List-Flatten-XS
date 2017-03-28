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

#define AV_PUSH(dest, val)              \
({                                      \
    if (SvROK(val)) av_push(dest, val); \
    else av_push(dest, newSVsv(val));   \
})

#define AV_UNSHIFT_ARRAYREF(dest, src)          \
({                                              \
    AV *ary = (AV *)SvRV(src);                  \
    I32 l = av_len(ary) + 1;                    \
    av_unshift(dest, l);                        \
    SV *val;                                    \
    for (I32 i = 0; i < l; i++) {               \
        val = *av_fetch(ary, i, FALSE);         \
        if (SvROK(val)) av_store(dest, i, val); \
        else av_store(dest, i, newSVsv(val));   \
    }                                           \
})

static AV *
_fast_flatten(SV *ref)
{
    AV *args = (AV *)SvRV( ref );
    AV *dest = (AV *)sv_2mortal((SV *)newAV());

    I32 len = av_len(args) + 1;
    for (I32 i = 0; i < len; i++) {
        SV *val = *av_fetch(args, i, FALSE);
        if (val != NULL) {
            AV_PUSH(dest, val);
        } else {
            croak("Could not fetch $_[0]->[%d]", i);
        }
    }

    AV *result = (AV *)sv_2mortal((SV *)newAV());

    while (av_len(dest) + 1) {
        SV *tmp = av_shift(dest);
        if (SvROK(tmp) && SvTYPE(SvRV(tmp)) == SVt_PVAV) {
            AV_UNSHIFT_ARRAYREF(dest, tmp);
        } else {
            av_push(result, tmp);
        }
    }
    return result;
}

MODULE = List::Flatten::XS    PACKAGE = List::Flatten::XS
PROTOTYPES: DISABLE

void *
flatten(ref, svlevel = sv_2mortal(newSViv(-1)))
    SV *ref;
    SV *svlevel;
PPCODE:
{
    if (!SvROK(ref) || SvTYPE(SvRV(ref)) != SVt_PVAV)
        croak("Please pass an array reference to the first argument");
    
    I32 level = SvIV(svlevel);
    AV *result;
    if (level < 0)
       result = _fast_flatten( ref );

    if (GIMME_V == G_ARRAY) {
        I32 len = av_len(result) + 1;
        for (I32 i = 0; i < len; i++)
            XPUSHs( *av_fetch(result, i, FALSE) );
    } else {
        XPUSHs( sv_2mortal( newRV_inc((SV *)result) ) );
    }
    PUTBACK;
}