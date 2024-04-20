function [response, responseTimestamp, reactionTime, keyCode] = ...
    KbWaitForKeys(keys, waitTime)

response = false;
reactionTime = 0.0;
startTime = GetSecs();

while GetSecs() - startTime < waitTime
    %pause(0); % let srl update
    [keyIsDown, responseTimestamp, keyCode, ~] = KbCheck;
    if keyIsDown && any(keyCode(keys))
        reactionTime = responseTimestamp - startTime;
        response = true;
        break;
    end
end

end
