function [node] = get_node(nodes, id)


for i=1:length(nodes)
    if nodes{i}.id==id
        node = nodes{i};
        return
    end
end


error(['get_node: Cannot find node ' id]);

