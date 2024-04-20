function my_square(scr,color,x,y,l,penWidth)
% draws the outline of a square of side length l centered on coords (x,y)
% other args:
%   scr: screen to draw on
%   color: color of square outline
%   penWidth: width of square outline - defaults to 1 if not specified
    r = l/2; % makes the next few lines less ugly
    if nargin == 5  % default to penWidth = 1
        Screen('FrameRect',scr,color,[(x-r) (y-r) (x+r) (y+r)],1);
    elseif nargin == 6 % penWidth specified
        Screen('FrameRect',scr,color,[(x-r) (y-r) (x+r) (y+r)],penWidth);
    else
        disp('my_square: wrong # of args')
end