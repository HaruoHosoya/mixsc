function eye_iris = eyeAndIris( eye_eccentricity,...
                                eye_size,...
                                inter_eye_distance,...
                                iris_size,...
                                gaze_direction,...
                                center,...
                                RF_size,...
                                show_flag)
%--------------------------------------------------------------------------
% [usage]
%   Create the eye and iris part of the cartoon face. 
%
% [input]
%   eye_eccentricity   : <required> eye_eccentricity`s feature values
%   eye_size           : <required> Lateral width of the eye
%   inter-eye_distance : <required> inter-eye distance with seven feature values
%   iris_size          : <required> size of iris
%   gaze_direction     : <required> gaze direction (-4~4)
%   center[x,y]        : <required> the center coordinates
%   RF_size            : <required> the size of reception field
%   show_flag          : <required> the flag of show eyes and iris or not
%
% [output]
%   eye_iris           : return the values of eye and iris.
%
% [note]
%   
% [history]
%   2015-10-01 (Song) initial version
%--------------------------------------------------------------------------
% define
LC=0.65*RF_size;

% ------------ eyes and irisÅ@------------
eye_distance=inter_eye_distance;
aspect_ratio=0.3+eye_eccentricity*0.014;

base_eye1=baseEllipse( [center(1),(center(2)-0.05)], ...
                       [0.08*(1+eye_size), (0.09*aspect_ratio*(1+eye_size))],...
                       [0,2*pi],200); 

base_eye2=baseEllipse( [center(1),(center(2)-0.05)],...
                       [0.1*(1+eye_size), (0.125*aspect_ratio*(1+eye_size))],...
                       [0,2*pi],200);
                   
if(gaze_direction==-4)||(gaze_direction==-3)||(gaze_direction==-2)
    if(eye_size<=0)
        y=-0.014+0.04*aspect_ratio*eye_size+0.3*iris_size(2);
    else
        y=-0.004-0.14*aspect_ratio*eye_size;
    end
elseif(gaze_direction==2)||(gaze_direction==3)||(gaze_direction==4)
    if(eye_size<=0)
        y=0.014+0.10*aspect_ratio*eye_size-0.3*iris_size(2);
    else
        y=-0.004+0.22*aspect_ratio*eye_size;
    end
else
    y=0;
end

if(gaze_direction==-4)||(gaze_direction==-1)||(gaze_direction==2)
    if(eye_size<=0)
        x=-0.035+0.04*eye_size*eye_size;
    else
        x=-0.018-1.4*eye_size*eye_size;
    end
elseif(gaze_direction==-2)||(gaze_direction==1)||(gaze_direction==4)
    if(eye_size<=0)
        x=0.035-0.04*eye_size*eye_size;
    else
        x=-0.018+2.6*eye_size*eye_size;
    end
else
    x=0;
end

base_iris=baseEllipse( [center(1),(center(2)-0.048)], iris_size,[0,2*pi],100);
eye_left1=poly2mask(LC*(base_eye1(:,1)-eye_distance),...
                   LC*base_eye1(:,2),RF_size,RF_size);
eye_right1=poly2mask(LC*(base_eye1(:,1)+eye_distance),...
                   LC*base_eye1(:,2),RF_size,RF_size);
eye_left2=poly2mask(LC*(base_eye2(:,1)-eye_distance),...
                   LC*base_eye2(:,2),RF_size,RF_size);
eye_right2=poly2mask(LC*(base_eye2(:,1)+eye_distance),...
                   LC*base_eye2(:,2),RF_size,RF_size);
iris_left=poly2mask(LC*(base_iris(:,1)-eye_distance+x),...
                   LC*(base_iris(:,2)+y),RF_size,RF_size );
iris_right=poly2mask(LC*(base_iris(:,1)+eye_distance+x),...
                   LC*(base_iris(:,2)+y),RF_size,RF_size );

base_eye_BW=eye_left2-eye_left1+eye_right2-eye_right1;
base_iris_BW=iris_left + iris_right;

% show flag
if show_flag(1)==true
    if show_flag(2)==true
        eye_iris=base_eye_BW+base_iris_BW;
    else
        eye_iris=base_eye_BW;
    end
else
    if show_flag(2)==true
        eye_iris=base_iris_BW;
    else
        eye_iris=zeros(RF_size,RF_size);
    end
end
end


