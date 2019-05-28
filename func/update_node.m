function [node] = update_node(node, dx)

% position is just an addition
node.state(1) = node.state(1) + dx(1);
node.state(2) = node.state(2) + dx(2);

% add theta, then enforce it is within -pi to pi
node.state(3) = wrap2pi(node.state(3) + dx(3));


end