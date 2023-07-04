function hair = hair( center,hair_width,hair_length,face_aspect_ratio,RF_size)
%--------------------------------------------------------------------------
% [usage]
%   Create a the hair of cartoon face. 
%
% [input]
%   center[x,y]      : <required> the center coordinates
%   hair_width       : <required> hair width
%   hair_length      : <required> hair length
%   face_aspect_ratio: <required> the aspect ratio of face ellipse
%   RF_size          : <required> the size of reception field
%
% [output]
%   hair             : return the values of hair.
%
% [note]
%   
% [history]
%   2015-10-01 (Song) initial version
%--------------------------------------------------------------------------
% define
LC=0.65*RF_size;

% ------------ hair ------------
shift_y=0;
baseC=0.1;
base=sqrt(baseC*face_aspect_ratio);

top=base+hair_width-0.26;
side_width=top-base;

base_circle=baseEllipse( center, [base, base/face_aspect_ratio],[pi,2*pi],100);
top_circle=baseEllipse( center, [top, top/face_aspect_ratio],[pi,2*pi],100);

base_circle_BW=poly2mask(LC*base_circle(:,1), ...
                  LC*(base_circle(:,2)-shift_y),RF_size,RF_size );
base_top_BW=poly2mask(LC*top_circle(:,1), ...
                  LC*(top_circle(:,2)-shift_y),RF_size,RF_size );
base_hair=and(base_top_BW,not( base_circle_BW));
[barX,barY]=baseBar( side_width, hair_length);
bar_BWL=poly2mask(LC*(barX+center(1)-(base+0.5*side_width)),...
                  LC*(barY+center(2)+0.5*hair_length-shift_y),RF_size,RF_size);
bar_BWR=poly2mask(LC*(barX+center(1)+(base+0.5*side_width)),...
                  LC*(barY+center(2)+0.5*hair_length-shift_y),RF_size,RF_size);
hair=bar_BWL+base_hair+bar_BWR;

end


