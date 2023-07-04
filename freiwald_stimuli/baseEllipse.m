
function data = baseEllipse( center, zoom, angle, points )
%--------------------------------------------------------------------------
% [usage]
%   Create a base ellipse to constituting the face outline.
%
% [input]
%   center[x,y] : <required> the center coordinates
%   zoom [w,h]  : <required> for adjust size of ellipse 
%   angle[s,e]  : <required> the angle from start to end 
%   points      : <required> approximate circle with specified points
% [output]
%   data        : value of return axis
%
% [note]
%  
% [history]
%   2015-09-26 (Song) initial version
%--------------------------------------------------------------------------

t = linspace(angle(1),angle(2), points);%approximate circle with specified points

%For adjust size of circle
X= zoom(1)*cos(t)+center(1);
Y= zoom(2)*sin(t)+center(2);

data = [X;Y]';

end


