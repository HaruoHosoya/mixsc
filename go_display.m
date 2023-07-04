function go_display(bnd,ndata,odata,cdatap,cmasksp,mode,tuning)

figure; 
show_bases(bnd.netb,'units',[1:32],'disp_width',8)

switch(mode)
    case 'mix'
        face_selectivity(bnd.netf,ndata,odata,'linear',false,'mode','mix');
        freiwald_show_tuning(bnd.netf_mix,1:10,'tuning',tuning);
        freiwald_show_stat(bnd.netf_mix,'tuning',tuning);
        freiwald_show_stat2(bnd.netf_mix);
        freiwald_show_stat3(bnd.netf_mix);
        freiwald_analyze_responses2(bnd.netf_mix,cdatap,cmasksp,1:4,'mode','mix');

    case 'sc'
        face_selectivity(bnd.netf,ndata,odata,'linear',false,'mode','sc');
        freiwald_show_tuning(bnd.netf_sc,1:10,'tuning',tuning);
        freiwald_show_stat(bnd.netf_sc,'tuning',tuning);
        freiwald_show_stat2(bnd.netf_sc);
        freiwald_show_stat3(bnd.netf_sc);
        freiwald_analyze_responses2(bnd.netf_sc,cdatap,cmasksp,1:4,'mode','sc');

    case 'ff'
        face_selectivity(bnd.netf,ndata,odata,'linear',false,'mode','ff');
        freiwald_show_tuning(bnd.netf_ff,1:10,'tuning',tuning);
        freiwald_show_stat(bnd.netf_ff,'tuning',tuning);
        freiwald_show_stat2(bnd.netf_ff);
        freiwald_show_stat3(bnd.netf_ff);
        freiwald_analyze_responses2(bnd.netf_ff,cdatap,cmasksp,1:4,'mode','ff');

end;


end


