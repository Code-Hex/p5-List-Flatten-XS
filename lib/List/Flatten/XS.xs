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

static AV *
_fast_flatten(SV *ref)
{
    I32 i, len;
    AV *args = (AV *)SvRV( ref );
    AV *result = (AV *)sv_2mortal((SV *)newAV());

    while (av_len(args) + 1) {
        SV *tmp = av_shift(args);
        if (SvROK(tmp) && SvTYPE(SvRV(tmp)) == SVt_PVAV) {
            AV *ary = (AV *)SvRV(tmp);
            len = av_len(ary) + 1;
            av_unshift(args, len);
            for (i = 0; i < len; i++)
                av_store(args, i, *av_fetch(ary, i, FALSE));
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
       result = _fast_flatten( sv_mortalcopy(ref) );

    if (GIMME_V == G_ARRAY) {
        I32 len = av_len(result) + 1;
        for (I32 i = 0; i < len; i++)
            XPUSHs( *av_fetch(result, i, FALSE) );
    } else {
        XPUSHs( sv_2mortal( newRV_inc((SV *)result) ) );
    }
    PUTBACK;
}