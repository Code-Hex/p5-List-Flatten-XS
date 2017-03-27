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
PROTOTYPE: $;$
PPCODE:
{
    I32 i, level;
    SV *ref;
    SV **argv = &PL_stack_base[ax];

    if (!items) XSRETURN_EMPTY;

    ref = sv_mortalcopy(argv[0]);
    if (!SvROK(ref) || SvTYPE(SvRV(ref)) != SVt_PVAV)
        croak("Please pass an array reference to the first argument");
    
    AV *args = (AV *)SvRV(ref);
    if (items == 2)
        level = (I32)SvIV(argv[1]);
    
    I32 len;
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

    ST(0) = sv_2mortal( newRV_inc((SV *)result) );
    XSRETURN(1);
}

/*
sub flat {
    my $list = shift;
    my $level = shift // -1;
    my @args = @{$list};
    my @result;
    while (@args) {
        my $a = shift @args;
        if (ref $a eq 'ARRAY') {
            unshift @args, @{$a};
        } else {
            push @result, $a;
        }
    }
    return @result;
}
*/