function nose = nose( center,nose_base,nose_altitude,RF_size)
%--------------------------------------------------------------------------
% [usage]
%   Create a cartoon face outline with the hair and the nose. 
%
% [input]
%   center[x,y]    : <required> the center coordinates
%   nose_base      : <required> size of triangle bottom
%   nose_altitude  : <required> size of triangle height
%   RF_size        : <required> the size of reception field
%
% [output]
%   nose           : return the values of nose.
%
% [note]
%   
% [history]
%   2015-10-01 (Song) initial version
%--------------------------------------------------------------------------
% define
LC=0.65*RF_size;

% ------------ nose ------------
line_width=0.0;

[XL,YL,XB,YB]=noseTriangle( nose_altitude, nose_base);
XR=-XL;
YR=YL; 
triangle_BWL=poly2mask(LC*(XL+center(1)+0.5*nose_base+line_width),...
                       LC*(YL+center(2)+nose_altitude),RF_size,RF_size);
triangle_BWR=poly2mask(LC*(XR+center(1)-0.5*nose_base+line_width),...
                       LC*(YR+center(2)+nose_altitude),RF_size,RF_size);
triangle_BWB=poly2mask(LC*(XB+center(1)+line_width),...
                       LC*(YB+center(2)+2*nose_altitude),RF_size,RF_size);

triangle_BW=triangle_BWR+triangle_BWL+triangle_BWB;
triangle_BW(triangle_BW>1)=1;
nose=triangle_BW;
end


