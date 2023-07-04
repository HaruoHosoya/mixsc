function [X,Y] = baseBar( bar_length, bar_width )
%--------------------------------------------------------------------------
% [usage]
%   Create a base bar.
%
% [input]
%   bar_length : <required> set value of bar length
%   bar_width  : <required> set value of bar width
%
% [output]
%   X          : value of x-axis
%   Y          : value of y-axis
%
% [note]
%   
% [history]
%   2015-09-26 (Song) initial version
%--------------------------------------------------------------------------
% draw a rectangle with 4 points
X =[-0.5*bar_length,-0.5*bar_length,0.5*bar_length,0.5*bar_length];%X
Y =[0.5*bar_width,-0.5*bar_width,-0.5*bar_width,0.5*bar_width];%Y

end