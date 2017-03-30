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

#define AV_PUSH(dest, val)                                           \
    av_push(dest, SvROK(val) ? SvREFCNT_inc(sv_2mortal(val)) : val)  \


#define AV_UNSHIFT_ARRAYREF(dest, src)                        \
({                                                            \
    AV *ary = (AV *)SvRV(src);                                \
    IV l = av_len(ary) + 1;                                   \
    av_unshift(dest, l);                                      \
    SV *val;                                                  \
    for (IV i = 0; i < l; i++) {                              \
        val = *av_fetch(ary, i, FALSE);                       \
        if (SvROK(val))                                       \
            av_store(dest, i, SvREFCNT_inc(sv_2mortal(val))); \
        else                                                  \
            av_store(dest, i, val);                           \
    }                                                         \
})

static SV *
_fast_flatten(SV *ref)
{
    AV *args = (AV *)SvRV(ref);
    AV *dest = (AV *)sv_2mortal((SV *)newAV());

    IV len = av_len(args) + 1;
    for (IV i = 0; i < len; i++) {
        SV *val = *av_fetch(args, i, FALSE);
        if (val != NULL) {
            AV_PUSH(dest, val);
        } else {
            croak("Could not fetch $_[0]->[%ld]", i);
        }
    }

    AV *result = (AV *)sv_2mortal((SV *)newAV());

    while (av_len(dest) + 1) {
        SV *tmp = av_shift(dest);
        if (SvROK(tmp) && SvTYPE(SvRV(tmp)) == SVt_PVAV) {
            AV_UNSHIFT_ARRAYREF(dest, tmp);
        } else {
            AV_PUSH(result, tmp);
        }
    }
    return newRV_inc((SV*)result);
}

static SV *
_flatten_per_level(SV *ref, IV level)
{
    AV *stack = (AV *)sv_2mortal((SV *)newAV());
    AV *result = (AV *)sv_2mortal((SV *)newAV());

    IV i = 0;
    SV *tmp;
    AV *ary = (AV *)SvRV(ref);
    while (1) {
        while (i < av_len(ary) + 1) {
            if ((tmp = *av_fetch(ary, i++, FALSE)) == NULL)
                croak("Could not fetch ary->[%ld]", i - 1);

            if (level >= 0 && (av_len(stack) + 1) / 2 >= level) {
                AV_PUSH(result, tmp);
                continue;
            }

            if (SvROK(tmp) && SvTYPE(SvRV(tmp)) == SVt_PVAV) {
                AV_PUSH(stack, (SV *)ary);
                AV_PUSH(stack, sv_2mortal(newSViv(i)));
                ary = (AV *)SvRV(tmp);
                i = 0;
            } else {
                AV_PUSH(result, tmp);
            }
        }

        if (av_len(stack) + 1 == 0) break;
        
        SV *idx = av_pop(stack);
        i = SvIV(idx);
        SV *poped = av_pop(stack);
        ary = (AV *)poped; // Already done SvRV(SV *)
    }

    return newRV_inc((SV*)result);
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
    
    IV level = SvIV(svlevel);
    SV *result = (level < 0) ? _fast_flatten(ref)
                    : _flatten_per_level(ref, level);

    if (GIMME_V == G_ARRAY) {
        AV *av_result = (AV *)SvRV(result);
        IV len = av_len(av_result) + 1;
        for (IV i = 0; i < len; i++)
            XPUSHs( *av_fetch(av_result, i, FALSE) );
    } else {
        XPUSHs(result);
    }
    PUTBACK;
}