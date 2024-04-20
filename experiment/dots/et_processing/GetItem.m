function item = GetItem(xPos, yPos, data, isFirstFix)
% GETITEM
% Purpose: Classify Eye-Fixations into distinct items
%
% Usage: item = Getitem(xPos,yPos,data,isFirstFix)
%
% Required input: 
% xPos                -->    X-Position of Eye Fixation
% yPos                -->    Y-Position of Eye Fixation
% data                -->    experiment data sctructure
% isFirstFix          -->    Logical TRUE/FALSE statement to prioritize Fixation Cross Assignment
%
% Output: 
% item                -->    Itemized Fixation
%                               (1 == LEFT Circle Container)
%                               (2 == RIGHT Circle Container)
%                               (3 == Fixation Cross)
%                               (4 == None/Blank)
%



    %Using the Distance Formula, Calculate the distance between 
        %the Position of the Eye and the the Center of each stimuli
    dist_L = sqrt((xPos - data.leftCircleCenterX)^2 + (yPos - data.leftCircleCenterY)^2);   %Distance between the Center of the LEFT Circle and Eye Position
    dist_R = sqrt((xPos - data.rightCircleCenterX)^2 + (yPos - data.rightCircleCenterY)^2); %Distance between the Center of the RIGHT Circle and Eye Position
    
    
    if dist_L < data.circleRadius + data.circleBuffer || dist_L == data.circleRadius + data.circleBuffer
        %On/Inside Left Circle
        item = 1; %1 for LEFT
        
    elseif dist_R < data.circleRadius + data.circleBuffer || dist_R == data.circleRadius + data.circleBuffer
        %On/Inside Right Circl
        item = 2; %2 for RIGHT
        
    elseif xPos > data.screenCenter(1)-90 && ...
            xPos < data.screenCenter(1)+90 && ...
            yPos > data.screenCenter(2)-90 && ...
            yPos < data.screenCenter(2)+90
        %On Crosshair
        item = 3; %3 for Fixation Cross
        
    elseif dist_L > data.circleRadius + data.circleBuffer && dist_R > data.circleRadius + data.circleBuffer
        %Outside both Circles
        item = 4; % None/Blank
        
    end  
    
    %If first fixation, allow priority for fixation cross fixation assignment
    if isFirstFix
        if xPos > data.screenCenter(1)-90 && ...
            xPos < data.screenCenter(1)+90 && ...
            yPos > data.screenCenter(2)-90 && ...
            yPos < data.screenCenter(2)+90
        
        item = 3; %3 for Fixation Cross
        end
    end
    
end