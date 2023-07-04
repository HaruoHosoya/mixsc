function face_outline = faceOutline( center,aspect_ratio,RF_size)
%--------------------------------------------------------------------------
% [usage]
%   Create a cartoon face outline with a base ellipse. 
%
% [input]
%   center[x,y]    : <required> the center coordinates
%   aspect_ratio   : <required> the aspect ratio of face ellipse
%   RF_size        : <required> the size of reception field
%
% [output]
%   face_outline   : return the values of face_outline.
%
% [note]
%   
% [history]
%   2015-10-01 (Song) initial version
%--------------------------------------------------------------------------
% define
LC=0.65*RF_size;
faceC=0.235;
width=sqrt(faceC*aspect_ratio);
% ------------ face outline ------------ 
base_c=baseEllipse( center, [width, width/aspect_ratio],[0,2*pi],300);
base_face_BW=poly2mask(LC*base_c(:,1), LC*base_c(:,2),RF_size,RF_size);
base_face=ones(RF_size,RF_size).*base_face_BW;
base_face(base_face==1)=0.5;
face_outline=base_face;
end


