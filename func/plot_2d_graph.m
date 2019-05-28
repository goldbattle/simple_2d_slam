function [] = plot_2d_graph(fh, nodes, color)


% set current figure
set(0, 'CurrentFigure', fh)


% loop through each node
for i=1:length(nodes)
   
   if i==1
       node = nodes{i};
       plot(node.state(1),node.state(2),'sg','MarkerSize',5,'MarkerFaceColor','g'); hold on;
   elseif i==length(nodes)
       node = nodes{i};
       plot(node.state(1),node.state(2),'dg','MarkerSize',5,'MarkerFaceColor','g'); hold on;
   else
       % get current and last node
       node1 = nodes{i-1};
       node2 = nodes{i};
       plot([node1.state(1) node2.state(1)],[node1.state(2) node2.state(2)],['.-',color],'LineWidth',1.5); hold on;
   end
  
   
end













