function shape_data = cartoonStimuli( feature_value,...
                                      RF_size,...
                                      face_inner,...
                                      show_controller,...
                                      varargin)
%--------------------------------------------------------------------------
% [usage]
%   Create cartoon stimulus by giving the 19 feature dimensions. 
%
% [input]
%   feature_value : <required> matrix of 19 dimensions's feature values
%            1  Face aspect ratio,
%            2  Face direction, 
%            3  Height of feature assembly, 
%            4  Hair length, 
%            5  Hair thickness, 
%            6  Eyebrow slant, 
%            7  Eyebrow width,
%            8  Eyebrow Height,
%            9  Inter-eye distance,
%            10 Eye eccentricity,
%            11 Eye size,
%            12 Iris size,
%            13 Gaze direction,
%            14 Nose base,
%            15 Nose altitude,
%            16 Mouth-nose distance 
%            17 Mouth size,
%            18 Mouth top, (distance from the mouth midline to the bottom's center point)
%            19 Mouth bottom (distance from upper to lower lip)
%   RF_size       : <required> the size of reception field
%   face_inner    : <required> the flag of turning face_inner
%   show_controller  : <required> the flag group of show parts or not
%            [1:face 
%             2:hair 
%             3:eyebrows 
%             4:eyes 
%             5:nose 
%             6:mouth 
%             7:iris]
%
% [output]
%   shape_data    : return cartoon stimuli.
%
% [note]
%   shape=cartoonStimuli([0,0,0, 0,0, 0,0,0,0, 0,0,0,0, 0,0, 0,0,0,0],200,...
%                         true,[true true true true true true true]);
%
% [history]
%   2015-10-01 (Song) initial version
%--------------------------------------------------------------------------
%make parser obj
p=inputParser;

%required
addRequired(p,'feature_value',@isnumeric);
addRequired(p,'RF_size',@isnumeric);
addRequired(p,'face_inner',@islogical);
addRequired(p,'show_controller',@islogical);

p.KeepUnmatched=true;
parse(p,feature_value,RF_size,face_inner,show_controller,varargin{:});

if ~isempty(fieldnames(p.Unmatched))
   disp('Extra inputs:')
   disp(p.Unmatched)
end
%------------------end inputParser-----------------------------------------
% ini
X=0.77;
Y=0.85;
center=[X,Y]; % face ellipse's center point
dimension_num=19;
index=size(feature_value);
shape_data=zeros(RF_size,RF_size,index(1));
empty_mask=zeros(RF_size,RF_size);

if(index(2)~=dimension_num)
    warning('Please check the number of feature values.')
end

for line_num=1:index(1)
    % layout
    if (feature_value(line_num,1)>0)
        face_aspect_ratio=0.75-0.025*feature_value(line_num,1);
    elseif(feature_value(line_num,1)==0)
        face_aspect_ratio=0.75;
     else
        face_aspect_ratio=0.75-0.05*feature_value(line_num,1);
    end
    face_direction=0.016*feature_value(line_num,2);
    face_height=0.015*feature_value(line_num,3);
    % hair
    hair_length=0.33+0.050*feature_value(line_num,4);
    hair_thinckness=0.49+0.018*feature_value(line_num,5);
    % eye
    eye_eccentricity=5.1+feature_value(line_num,10);
    eye_size=0.028*feature_value(line_num,11);
    iris_a=(0.04+0.006*feature_value(line_num,12))/1.68;
    iris_b=(0.03+0.66*feature_value(line_num,12)*0.005)/1.68;
    gaze_direction=1*feature_value(line_num,13);
    % eyebrow
    slant=0.028*feature_value(line_num,6)*pi;
    eyebrow_width=0.20+0.0085*feature_value(line_num,7);
    eyebrow_height=0.75-0.06*eye_size+...
                   -0.0038*eye_eccentricity+...
                   0.0085*feature_value(line_num,8);
    eye_distance=0.18+0.016*(-0.6+feature_value(line_num,9));
    
    % nose
    nose_base=0.14+0.015*feature_value(line_num,14);
    nose_altitude=0.16+0.005*feature_value(line_num,15);
    % mouth  
    mouth_nose_distance=0.10+0.005*feature_value(line_num,16);
    mouth_size=0.12+0.005*feature_value(line_num,17);   
    mouth_top=0.1*feature_value(line_num,18); 
    % mouth_bottom (1~11)
    mouth_bottom=0.3*(feature_value(line_num,19)+6.0);
    
    if(face_inner==true)
        % Layout
        face_outline=faceOutline(center,face_aspect_ratio,RF_size);
        if (show_controller(2)==true) 
            % Hair
            hair_data=hair(center,hair_thinckness,hair_length,face_aspect_ratio,RF_size);
        else
            hair_data=empty_mask;
        end
        face=(face_outline+hair_data);       
        center_inner=[(center(1)+face_direction),(center(2)+face_height)];
        if (show_controller(1)==false)
             % hair:-0.5
            face(face==1)=-0.5;
            face(face==1.5)=0.0;
            face(face==0.5)=0.0;
        end
    else
        center=[(center(1)-face_direction),(center(2)-face_height)];
        % Layout
        face_outline=faceOutline(center,face_aspect_ratio,RF_size);
        if (show_controller(2)==true) 
            % Hair 
            hair_data=hair(center,hair_thinckness,hair_length,face_aspect_ratio,RF_size);
        else
            hair_data=empty_mask;
        end
        face=(face_outline+hair_data);
        if (show_controller(1)==false)
             % hair:-0.5
            face(face==1)=-0.5;
            face(face==1.5)=0.0;
            face(face==0.5)=0.0;
        end
        % Keep the ini values
        center_inner=[X,Y];
    end
    % hair:-0.5
    face(face==1)=-0.5;
    % face: 1
    face(face==1.5)=1;
    face(face==0.5)=1;
    
    if (show_controller(3)==true) 
        % EyeBrows 
        eyebrow_data=eyebrow(center_inner,slant,eyebrow_width,eyebrow_height,eye_distance,face_aspect_ratio,RF_size);    
    else
        eyebrow_data=empty_mask;
    end
    
    % Eyes (4) & iris (7)
    eye_data=eyeAndIris(eye_eccentricity,eye_size,eye_distance,...
             [iris_a,iris_b],gaze_direction,center_inner,RF_size,[show_controller(4) show_controller(7)]);    
        
    if (show_controller(5)==true)
        % Nose
        nose_data=nose( center_inner,nose_base,nose_altitude,RF_size);
    else
        nose_data=empty_mask;
    end
    
    if (show_controller(6)==true) 
        % Mouth
        mouth_data=mouth(center_inner,mouth_size,mouth_top,mouth_bottom,...
                        (mouth_nose_distance+nose_altitude),face_height,...
                        face_aspect_ratio, RF_size);
    else
        mouth_data=empty_mask;
    end
    face_inner_parts=eye_data+nose_data+eyebrow_data+mouth_data;
    if (show_controller(1)==false)
        face_inner_parts(face_inner_parts>=1)=-1;
    else
        face_inner_parts(face_inner_parts>=1)=-2;
    end
    face_shape=face+face_inner_parts;
    if (show_controller(2)==false)
        % keep part value
        face_shape(face_shape<-1)=-1;
    else
        % reset to hair's value
        face_shape(face_shape<-1)=-0.5;
    end

    shape_data(:,:,line_num)=face_shape;  
    % reset the center
    center=[X,Y];
    
end


