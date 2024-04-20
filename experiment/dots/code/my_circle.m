function  my_circle(scr,color,x,y,r,colorWidth,penWidth)
% ----------------------------------------------------------------------
% my_circle(scr,color,x,y,r,[colorWidth],[penWidth])
% ----------------------------------------------------------------------
% Goal of the function :
% Draw a colored (color) circle or oval in position (x,y) with radius
% (r) and with a colored contour (colorWidth) and width (penwidth).
% ----------------------------------------------------------------------
% Input(s) :
% scr = window Pointer ex : w
% color = color of the circle in RBG or RGBA ex :[0 0 0]
% x = position x of the center ex : x = 550
% y = position y of the center ex : y = 330
% r = radius for X (in pixel) ex : r = 25
% colorWidth = color of the contour of the circle ex :[255 0 0]
% penWidth = size of the contour of the circle ex : 10
% ----------------------------------------------------------------------
% Output(s):
% none
% ----------------------------------------------------------------------
% Function created by Martin SZINTE (martin.szinte@gmail.com)
% Last edit : 06 / 01 / 2014
% Project : Programming course
% Version : -
% ----------------------------------------------------------------------
% if there isn't colorWidth argument the function will draw a filled circle
if nargin < 6
 % DrawDots makes nicer dots however it can only draw small dots (< 30pix)
 if r>30
 Screen('FillOval',scr,color,[(x-r) (y-r) (x+r) (y+r)]);
 else
 Screen('DrawDots', scr,[x,y],r*2,color,[],2);
 end

% if there is colorWidth argument the function will draw a framed circle
else
 Screen('FrameOval',scr,colorWidth,[(x-r) (y-r) (x+r) (y+r)],penWidth);
end
end