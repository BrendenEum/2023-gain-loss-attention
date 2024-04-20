function centers = generateCenters(expdata,container)
% GENERATECENTERS
% Purpose: This function will generate 100 center coordinates for the Ball Stimuli, and outputs them into a 100x2 matrix
%          Ensuring that the balls will not overlap AND remain within a container Circle.  
%           
% Usage: generateCenters(expdata,container)
%
% Required input:
% expdata       -->     experiment data structure 
% container     -->     Container that balls will be plotted in (MUST BE 1 OR 2)
%                       (1 == LEFT Circle Container)
%                       (2 == RIGHT Circle Container)
%
% Output: 
% 'centers'     -->     100x2 matrix containing randomly generated X & Y coordinates 
%                        to use as centers to be used for the ball stimuli


    if container == 1 % Left Circle Container
        
        centers = []; % Initialize empty variable
        D = [];       % Initialize empty variable  
        D_2 = [];     % Initialize empty variable
        
        
        % Assign the Circle container center coordinates as the first value for the 'centers' matrix
        centers(1,1:2) = [expdata.leftCircleCenterX expdata.leftCircleCenterY];

        
        for ii = 2:100
            %% Sample and Assign Coordinates
            
            % Randomly sample X & Y coordinates within the range of the Circle Container
            x = randsample(expdata.leftCircleRangeX(1):expdata.leftCircleRangeX(2),1); 
            y = randsample(expdata.leftCircleRangeY(1):expdata.leftCircleRangeY(2),1);

            centers(ii,1:2) = [x y]; % Assign randomly generated coordinates to the 'centers' matrix

            %% Calculate Distances
            
            % Calculate the Distance of newly randomly generated coordinate
            %   from every coordinate in the 'centers' matrix
            D = sqrt((x - centers(:,1)).^2 + (y - centers(:,2)).^2);
            
            % Calculate the Distance of all the coordinates in the 'centers' matrix
            %   from the center of the Circle Container
            D_2 = sqrt((centers(:,1) - expdata.leftCircleCenterX).^2 + (centers(:,2) - expdata.leftCircleCenterY).^2);

            %% Distence check
            % Re-generate a new X/Y coordinate IF 
            % The new ball coordinate means the new ball overlaps an existing ball OR
            % The new ball coordinate place the ball outside the boundary of the Circle Container
            
            while any(D(1:ii-1) < expdata.ballBuffer) || any(D_2(2:ii) > expdata.containterBoundary)
                x = randsample(expdata.leftCircleRangeX(1):expdata.leftCircleRangeX(2),1); % Re-sample
                y = randsample(expdata.leftCircleRangeY(1):expdata.leftCircleRangeY(2),1); % Re-sample

                centers(ii,1:2) = [x y]; % Re-assign

                D = sqrt((x - centers(:,1)).^2 + (y - centers(:,2)).^2); % Re-Check Distance for Ball Buffer
                D_2 = sqrt((centers(:,1) - expdata.leftCircleCenterX).^2 + (centers(:,2) - expdata.leftCircleCenterY).^2); % Re-Check Distance for Container Boundary
            end
        end
    elseif container == 2 % Right Circle Container
        
        centers = []; % Initialize empty variable
        D = [];       % Initialize empty variable  
        D_2 = [];     % Initialize empty variable  
        
        % Assign the Circle container center coordinates as the first value for the 'centers' matrix
        centers(1,1:2) = [expdata.rightCircleCenterX expdata.rightCircleCenterY];


        for ii = 2:100
            %% Sample and Assign Coordinates
            
            % Randomly sample X & Y coordinates within the range of the Circle Container
            x = randsample(expdata.rightCircleRangeX(1):expdata.rightCircleRangeX(2),1); 
            y = randsample(expdata.rightCircleRangeY(1):expdata.rightCircleRangeY(2),1);

            centers(ii,1:2) = [x y]; % Assign randomly generated coordinates to the 'centers' matrix
            
            %% Calculate Distances
            
            % Calculate the Distance of newly randomly generated coordinate
            %   from every coordinate in the 'centers' matrix
            D = sqrt((x - centers(:,1)).^2 + (y - centers(:,2)).^2);
            
            % Calculate the Distance of all the coordinates in the 'centers' matrix
            %   from the center of the Circle Container
            D_2 = sqrt((centers(:,1) - expdata.rightCircleCenterX).^2 + (centers(:,2) - expdata.rightCircleCenterY).^2);
            
            %% Distence check
            % Re-generate a new X/Y coordinate IF 
            % The new ball coordinate means the new ball overlaps an existing ball OR
            % The new ball coordinate place the ball outside the boundary of the Circle Container
            while any(D(1:ii-1) < expdata.ballBuffer) || any(D_2(2:ii) > expdata.containterBoundary)
                x = randsample(expdata.rightCircleRangeX(1):expdata.rightCircleRangeX(2),1); % Re-sample
                y = randsample(expdata.rightCircleRangeY(1):expdata.rightCircleRangeY(2),1); % Re-sample

                centers(ii,1:2) = [x y]; % Re-assign

                D = sqrt((x - centers(:,1)).^2 + (y - centers(:,2)).^2); % Re-Check Distance for Ball Buffer
                D_2 = sqrt((centers(:,1) - expdata.rightCircleCenterX).^2 + (centers(:,2) - expdata.rightCircleCenterY).^2); % Re-Check Distance for Container Boundary
            end
        end 
    end
end