function [X_top,Y_top,X_bottom,Y_bottom] = mouthEllipse( center, size, distance, points)
%--------------------------------------------------------------------------
% [usage]
%   Create a mouth with two half ellipses. 
%
% [input]
%   center[x,y]       : <required> the center coordinates
%   size[x,y]         : <required> value for set mouth size
%   distance [t,b]    : <required> mouth top and mouth bottom 
%    points           : <required> approximate half ellips with specified points
% [output]
%   X_top,Y_top       : values of top half ellipse (axis)
%   X_bottom,Y_bottom : values of bottom half ellipse (axis)
%
% [note]
%   
% [history]
%   2015-09-28 (Song) initial version
%--------------------------------------------------------------------------

t_top = linspace(pi,2*pi, points);%approximate half ellips with 300 points
t_bottom = linspace(0,pi, points);

%size of mouth
X_top= size(1)*cos(t_top)+center(1);
Y_top= size(2)*distance(1)*sin(t_top)+center(2);

X_bottom= size(1)*cos(t_bottom)+center(1);
Y_bottom= size(2)*distance(2)*sin(t_bottom)+center(2);

end