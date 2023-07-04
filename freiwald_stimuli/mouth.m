function mouth_data = mouth( center,...
                             mouth_size,...
                             mouth_top,...
                             mouth_bottom,...
                             mouth_nose_distance,...
                             face_height,...
                             face_aspect_ratio,...
                             RF_size)
%--------------------------------------------------------------------------
% [usage]
%   Create the  mouth of the cartoon face.
%
% [input]
%   center[x,y]  : <required> the center coordinates
%   mouth_size   : <required> the width of the mouth
%   mouth_top    : <required> expression of the mouth
%   mouth_bottom : <required> height of the mouth
%   mouth_nose_distance: <required> the distance to nose(triangle bottom)
%   face_height  : <required> height of the face
%   RF_size      : <required> the size of reception field
%
% [output]
%   mouth_data   : return the mouth values .
%
% [note]
%   
% [history]
%   2015-10-01 (Song) initial version
%--------------------------------------------------------------------------
% define
LC=0.65*RF_size;

% ------------ mouthÅ@------------
if mouth_top<0
     top_distance=-0.5+mouth_top-0.05*mouth_bottom;        
     bottom_distance=0.40+abs(mouth_top)-0.25*mouth_bottom;
elseif mouth_top>0  
     top_distance=0.5+mouth_top+0.05*mouth_bottom;     
     bottom_distance=-0.38-mouth_top+0.25*mouth_bottom;
else
     top_distance=0.048+0.14*mouth_bottom;
     bottom_distance=top_distance;
end   
y_size=0.1;

if(face_aspect_ratio<0.75)
    % 0 ~ +5 change eyebrow_height 
    mouth_height=(mouth_nose_distance*0.75)/face_aspect_ratio;
else
    if(top_distance<0)
        mouth_height=mouth_nose_distance+0.001*top_distance;
    else
        mouth_height=mouth_nose_distance+0.05*top_distance;
    end
end

center_y=center(2)+mouth_height+0.02-0.6*abs(face_height);
[XT,YT,XB,YB]=mouthEllipse([center(1),center_y],...
              [mouth_size, y_size],...
              [top_distance, bottom_distance],200);
base_top=[XT;YT]';
base_bottom=[XB;YB]';
base_top_BW=poly2mask(LC*(base_top(:,1)),...
                      LC*(base_top(:,2)),RF_size,RF_size);
base_bottom_BW=poly2mask(LC*(base_bottom(:,1)), ...
                         LC*(base_bottom(:,2)),RF_size,RF_size);

if top_distance<0

    if bottom_distance<0
        base_mouth=base_top_BW + base_bottom_BW;
    else
        if(abs(top_distance)>abs(bottom_distance))
            base_mouth=and(not(base_bottom_BW),base_top_BW);
        else
            base_mouth=and(not(base_top_BW),base_bottom_BW);
        end
    end
else
    if bottom_distance<0
        if(abs(top_distance)>abs(bottom_distance))
            base_mouth=and(not(base_bottom_BW),base_top_BW);
        else
            base_mouth=and(not(base_top_BW),base_bottom_BW);
        end
    else
        if(top_distance>0 && bottom_distance>0)
            base_mouth=base_top_BW + base_bottom_BW;            
        elseif(abs(top_distance)>abs(bottom_distance))
            base_mouth=and(not(base_bottom_BW),base_top_BW);
        else
            base_mouth=and(not(base_top_BW),base_bottom_BW);
        end
    end
end
mouth_data=base_mouth;

end


