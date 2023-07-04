function roots=make_word_tree(fname)

tbl=readtable(fname,'Delimiter',' ','ReadVariableNames',false);

src=arrayfun(@(x)getid(x{1}),tbl{:,1});
dst=arrayfun(@(x)getid(x{1}),tbl{:,2});

root_nodes=setdiff(unique([src;dst]),unique(dst));

roots=make_subtrees(root_nodes);


    function subtrees=make_subtrees(nodes)
        subtrees={};
        for I=1:length(nodes)
            subtrees{I}.id=nodes(I);
            idx=find(nodes(I)==src);
            subnodes=dst(idx);
            if length(subnodes)~=length(unique(subnodes))
                fprintf('duplicated destination found\n');
            end;
            subtrees{I}.subtrees=make_subtrees(subnodes);
        end;
    end

end

function id=getid(str)

s=textscan(str,'n%d');
id=s{1};

end

