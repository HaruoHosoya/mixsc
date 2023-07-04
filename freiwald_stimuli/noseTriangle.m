function [X,Y,XB,YB] = noseTriangle( nose_height, nose_width)
%--------------------------------------------------------------------------
% [usage]
%   Create a triangle of cartoon nose.
%
% [input]
%   nose_height : <required> the height of nose from center.
%   nose_width  : <required> the width of nose  
%
% [output]
%   X,Y         : side value of Triangle(axis)
%   XB,YB       : base line  value of Triangle(axis)
%
% [note]
%   
% [history]
%   2015-09-28 (Song) initial version
%--------------------------------------------------------------------------
line_width = 0.02;
cosx=nose_height/sqrt(nose_height.^2+nose_width.^2); 
siny=(0.5*nose_width)/sqrt(nose_height.^2+nose_width.^2); 

% side lines
X =[cosx*0.5*line_width-0.5*nose_width,-cosx*0.5*line_width-0.5*nose_width,...
    -cosx*0.5*line_width,cosx*0.5*line_width];%X
Y =[-siny*0.5*line_width-nose_height,siny*0.5*line_width-nose_height,...
    siny*0.5*line_width,-siny*0.5*line_width];%Y

% bottom line
XB =[-0.5*nose_width,0.5*nose_width,...
    0.5*nose_width,-0.5*nose_width];%X
YB =[-0.5*line_width-nose_height,-0.5*line_width-nose_height,...
    0.5*line_width-nose_height,0.5*line_width-nose_height];%Y

end

