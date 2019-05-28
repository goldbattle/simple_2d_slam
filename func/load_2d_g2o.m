function [nodes,edges] = load_2d_g2o(filename)


% open the file
fid = fopen(filename);
if fid < 0
    error(['load_g2o: Cannot open file ' filename]);
end


% scan all lines into a cell array
columns=textscan(fid,'%s','delimiter','\n');
fclose(fid);
lines=columns{1};

% create our return variables
n=size(lines,1);
nodes={};
edges={};


% go through each line and load it
for i=1:n
    line_i=lines{i};
    if strcmp('VERTEX_SE2',line_i(1:10))
        v = textscan(line_i,'%s %d %f %f %f',1);
        node.id = v{2};
        node.state = [v{3} v{4} v{5}]; %x, y, theta
        nodes{length(nodes)+1} = node; 
    elseif strcmp('EDGE_SE2',line_i(1:8))
        e = textscan(line_i,'%s %d %d %f %f %f %f %f %f %f %f %f',1);
        edge.id1 = e{2}; %idout
        edge.id2 = e{3}; %idin
        edge.meas = [e{4} e{5} e{6}]; %dx, dy, dtheta
        %7   8   9   10  11  12
        %I11 I12 I13 I22 I23 I33
        edge.info = [e{7} e{8} e{9};
            e{8} e{10} e{11};
            e{9} e{11} e{12}];
        edges{length(edges)+1} = edge;
    end
end














