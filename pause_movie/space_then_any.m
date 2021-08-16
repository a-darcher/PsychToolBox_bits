function space_then_any(moviename, windowedMode)
%   Pause the movie using SPACEBAR, unpause using any other key. 
%
%   Based on SimpleMovieDemo from PTB. 
%
%   windowedMode: useful for troubleshooting. Defaults to 1/True -- screen will only
%                 be displayed in a small segment of the screen. 



AssertOpenGL;
Screen('Preference', 'SkipSyncTests', 1);
if nargin < 1 || isempty(moviename)
    % No moviename given: Use our default movie:
    moviename = [ PsychtoolboxRoot 'PsychDemos/MovieDemos/DualDiscs.mov' ];
end

if ~exist('windowedMode')
      windowedMode = true; % set to true for debugging
      Screen('Preference', 'SkipSyncTests', 1); 
end

% Wait until user releases keys on keyboard:
KbReleaseWait;

  KbName('UnifyKeyNames');

  % Setup key mapping:
  space=KbName('Space');
  shift=KbName('RightShift');

  % Parameter Set-Up
    
  screen = max(Screen('Screens'));
  if windowedMode
    [win, windowrect] = Screen(screen, 'OpenWindow', [0.5, 0.5, 0.5], [0, 0, 800, 600]); 	% Limit screen to just a window in the top left screen corner. 
  else
    [win, windowrect] = Screen('OpenWindow', screen, 0);
  endif

% Select screen for display of movie:
screenid = max(Screen('Screens'));

try
    % Open 'windowrect' sized window on screen, with black [0] background color:
    win = Screen('OpenWindow', screenid, 0, windowrect);
    
    % Open movie file:
    movie = Screen('OpenMovie', win, moviename);
    
    % Start playback engine:
    Screen('PlayMovie', movie, 1);
    
    % Playback loop: Runs until end of movie or keypress:
    while 1
       
       
      %%%%%% PAUSE CODE %%%%%%%
      [keyIsDown,secs,keyCode]=KbCheck;
      if (keyIsDown==1 && keyCode(space))
        pausePoint = Screen('GetMovieTimeIndex', movie);
        Screen('PlayMovie', movie, 0);
        KbWait([], 2);
        Screen('PlayMovie', movie, rate, 1, 1.0);
        Screen('SetMovieTimeIndex', movie, pausePoint);
      endif

      % Wait for next movie frame, retrieve texture handle to it
      tex = Screen('GetMovieImage', win, movie);
          
      % Valid texture returned? A negative value means end of movie reached:
      if tex<=0
        % We're done, break out of loop:
        break;
      end
          
      % Draw the new texture immediately to screen:
      Screen('DrawTexture', win, tex);
          
      % Update display:
      Screen('Flip', win);
          
      % Release texture:
      Screen('Close', tex);
    end
    
    % Stop playback:
    Screen('PlayMovie', movie, 0);
    
    % Close movie:
    Screen('CloseMovie', movie);
    
    % Close Screen, we're done:
    sca;
    
catch %#ok<CTCH>
    sca;
    psychrethrow(psychlasterror);
end

return