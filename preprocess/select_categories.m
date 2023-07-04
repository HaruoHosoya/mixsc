function classes=select_categories(trees,mincount)

subtrees={}; SI=1; top_classes=[];
select_subtrees(trees);

classes={}; 
for I=1:length(subtrees)
    classes{I}=unique(add_categories(subtrees{I}));
end;

total=sum(cellfun(@(x)x.count,trees));
used=sum(cellfun(@(x)x.count,subtrees'));
nclass=length(classes);
fprintf('used: %d (%d classes), total: %d\n',used,nclass,total);

    function select_subtrees(trees)
        for J=1:length(trees)
            if trees{J}.count>=mincount && all(cellfun(@(x)x.count<mincount,trees{J}.subtrees)) && ~ismember(trees{J}.id,top_classes)
                subtrees{SI}=trees{J};
                top_classes(SI)=trees{J}.id;
                SI=SI+1;
            else
                select_subtrees(trees{J}.subtrees);
            end;
        end;
    end

    function cla=add_categories(tree)
        cla=[];
        traverse(tree);
        
        function traverse(tree)
            if tree.ind_count>0
                cla=[cla;tree.id];
            end;
            for K=1:length(tree.subtrees)
                traverse(tree.subtrees{K});
            end;
        end
    end
        
end

