function [trees,total]=add_counts(trees,annot,indir)

trees=add_individual_counts(trees);
[trees,counts]=add_counts(trees);
total=sum(counts);

    function trees=add_individual_counts(trees)
        for J=1:length(trees)
            id=sprintf('n%08d',trees{J}.id);
            if isfield(annot,id) && exist(sprintf('%s/%s.tar',indir,id))==2
                trees{J}.ind_count=length(fieldnames(getfield(annot,id)));
            else
                trees{J}.ind_count=0;
            end;
            trees{J}.subtrees=add_individual_counts(trees{J}.subtrees);
        end;        
    end

    function [trees,counts]=add_counts(trees)
        counts=zeros(length(trees),1);
        for J=1:length(trees)
            [trees{J}.subtrees,sub_counts]=add_counts(trees{J}.subtrees);
            trees{J}.count=sum(sub_counts)+trees{J}.ind_count;
            counts(J)=trees{J}.count;
        end;        
    end


end

