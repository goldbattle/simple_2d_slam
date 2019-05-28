%% setup the workspace

% clear and close
close all;
clear all;

% add our paths for helper functions
addpath('func');


% create the figure
fh1 = figure(1);
fontsize = 20;
set(gcf,'Color','w');
set(gcf,'PaperPositionMode','auto');
set(gcf,'defaultuicontrolfontsize',fontsize);
set(gcf,'defaultuicontrolfontname','Bitstream Charter');
set(gcf,'DefaultAxesFontSize',fontsize);
set(gcf,'DefaultAxesFontName','Bitstream Charter');
set(gcf,'DefaultTextFontSize',fontsize);
set(gcf,'DefaultTextFontname','Bitstream Charter');
set(gcf,'Position',[0 0 800 800])




%% start loading our data in


% load our data
disp('loading data...');
[nodes,edges] = load_2d_g2o('data/input_INTEL_g2o.g2o');
%[nodes,edges] = load_2d_g2o('data/input_M3500_g2o.g2o');
%[nodes,edges] = load_2d_g2o('data/input_MITb_g2o.g2o');


% plot the before
disp('plotting initial trajectory...');
plot_2d_graph(fh1,nodes,'b');




%% now lets make the optimization problem

disp('creating optimization problem...');

% first ensure our orientations are bounded between -pi and pi
for i=1:length(nodes)
   nodes{i} = update_node(nodes{i},[0 0 0]); 
end


% we will stop when our update is small
disp('solving optimization problem...');
dx_norm = 99999;
iteration = 0;
while dx_norm > 1e-2

    % our matrices for Hx=-b
    H = zeros(3*length(nodes),3*length(nodes));
    b = zeros(3*length(nodes),1);

    % loop through each edge
    for i=1:length(edges)

        % our edge
        edge = edges{i};

        % get the nodes (and thus our linearization points)
        node1 = get_node(nodes, edge.id1);
        node2 = get_node(nodes, edge.id2);

        % orientation error
        R_1toG = rot2(node1.state(3));
        R_2toG = rot2(node2.state(3));
        R_2to1 = rot2(edge.meas(3));
        %err_theta = log2(R_2to1'*R_1toG'*R_2toG);
        err_theta = wrap2pi(edge.meas(3) - wrap2pi(node2.state(3)-node1.state(3)));
        

        % position error
        p_1inG = node1.state(1:2)';
        p_2inG = node2.state(1:2)';
        p_2in1 = edge.meas(1:2)';
        err_pos = p_2in1 - R_1toG'*(p_2inG - p_1inG);

        % Jacobian of current relative in respect to NODE 1
        dx1_dtheta1 = -sin(node1.state(3))*(node2.state(1)-node1.state(1)) + cos(node1.state(3))*(node2.state(2)-node1.state(2));
        dy1_dtheta1 = -cos(node1.state(3))*(node2.state(1)-node1.state(1)) - sin(node1.state(3))*(node2.state(2)-node1.state(2));
        Aij = [-cos(node1.state(3)) -sin(node1.state(3)) dx1_dtheta1;
                sin(node1.state(3)) -cos(node1.state(3)) dy1_dtheta1;
                0 0 -1];

        % Jacobian of current relative in respect to NODE 2
        Bij = [cos(node1.state(3)) sin(node1.state(3)) 0;
              -sin(node1.state(3)) cos(node1.state(3)) 0;
               0 0 1];

        % update our information
        id1 = edge.id1;
        id2 = edge.id2;
        H(3*id1+1:3*id1+3,3*id1+1:3*id1+3) = H(3*id1+1:3*id1+3,3*id1+1:3*id1+3) + Aij'*edge.info*Aij;
        H(3*id1+1:3*id1+3,3*id2+1:3*id2+3) = H(3*id1+1:3*id1+3,3*id2+1:3*id2+3) + Aij'*edge.info*Bij;
        H(3*id2+1:3*id2+3,3*id1+1:3*id1+3) = H(3*id2+1:3*id2+3,3*id1+1:3*id1+3) + Bij'*edge.info*Aij;
        H(3*id2+1:3*id2+3,3*id2+1:3*id2+3) = H(3*id2+1:3*id2+3,3*id2+1:3*id2+3) + Bij'*edge.info*Bij;

        % update our error terms
        b(3*id1+1:3*id1+3,1) = b(3*id1+1:3*id1+3,1) + Aij'*edge.info*[err_pos; err_theta];
        b(3*id2+1:3*id2+3,1) = b(3*id2+1:3*id2+3,1) + Bij'*edge.info*[err_pos; err_theta];


    end
    
    % fix the first node to be known
    H(1:3,1:3) = H(1:3,1:3) + 1e6*eye(3);

    % solve the linear system
    x = H\b;
    dx_norm = norm(x);
    iteration = iteration + 1;
    fprintf('  + iter %d with delta = %.4f\n',iteration,dx_norm);

    % update our nodes
    for i=1:length(nodes)
       nodes{i} = update_node(nodes{i},x(3*(i-1)+1:3*(i-1)+3,1)); 
    end


end


% plot after update
disp('plotting after update...');
plot_2d_graph(fh1,nodes,'r');



