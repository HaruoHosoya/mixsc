function eyebrow_data = eyebrow( center,...
                                 eyebrow_slant,...
                                 eyebrow_width,...
                                 eyebrow_height,...
                                 inter_eye_distance,...
                                 face_aspect_ratio,...
                                 RF_size)
%--------------------------------------------------------------------------
% [usage]
%   Create the eyebrow part of the cartoon face. 
%
% [input]
%   center[x,y]        : <required> the center coordinates
%   eyebrow_slant      : <required> eyebrow slant with seven feature values
%   eyebrow_width      : <required> eyebrow widtht with seven feature values
%   eyebrow_height     : <required> eyebrow height with seven feature values
%   inter-eye_distance : <required> inter-eye distance with seven feature values
%   face_aspect_ratio  : <required> the aspect ratio of face ellipse
%   RF_size            : <required> the size of reception field
%
% [output]
%   eyebrow_data       : return the values of eyebrow.
%
% [note]
%   
% [history]
%   2015-10-01 (Song) initial version
%--------------------------------------------------------------------------
% define
LC=0.65*RF_size;
if(face_aspect_ratio>0.75)
    % 0 ~ -5 change eyebrow_width 
    offset_width =eyebrow_width*face_aspect_ratio/0.75;
else
    offset_width =eyebrow_width;
end

if(face_aspect_ratio<0.75)
    % 0 ~ +5 change eyebrow_height 
    offset_height=(eyebrow_height*face_aspect_ratio)/0.75;
else
    offset_height=eyebrow_height;
end
% ------------ eyebrow ------------
% a rotation matrix with an angle  
RM=[cos(eyebrow_slant) -sin(eyebrow_slant); sin(eyebrow_slant) cos(eyebrow_slant)];
RMS=[cos(-eyebrow_slant) -sin(-eyebrow_slant); sin(-eyebrow_slant) cos(-eyebrow_slant)];
[barXY(:,1),barXY(:,2)]=baseBar(offset_width, 0.018);
height=offset_height-0.88-0.07*abs(eyebrow_slant);
distance=inter_eye_distance;
eyebrow_rotate=barXY*RM;
eyebrow_rotateS=barXY*RMS;
eyebrow_L=poly2mask(LC*(eyebrow_rotate(:,1)+center(1)-distance),...
                    LC*(eyebrow_rotate(:,2)+center(2)+height),RF_size,RF_size );                
eyebrow_R=poly2mask(LC*(eyebrow_rotateS(:,1)+center(1)+distance),...
                    LC*(eyebrow_rotateS(:,2)+center(2)+height),RF_size,RF_size );
eyebrow_data=eyebrow_L+eyebrow_R;
end


