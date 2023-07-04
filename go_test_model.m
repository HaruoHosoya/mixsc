function bnd=go_test_model(bnd,cdata,cparams,cdata1d,cdata1d_noface,cparams1d)


bnd.netf_mix=freiwald_analyze_responses(bnd.netf,cdata,cparams,cdata1d,cdata1d_noface,cparams1d,'mode','mix');
bnd.netf_sc=freiwald_analyze_responses(bnd.netf,cdata,cparams,cdata1d,cdata1d_noface,cparams1d,'mode','sc');
bnd.netf_ff=freiwald_analyze_responses(bnd.netf,cdata,cparams,cdata1d,cdata1d_noface,cparams1d,'mode','ff');





end

