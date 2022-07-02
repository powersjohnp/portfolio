function ROSEF(subNum, orderNum, otherName, runNum)

% Using PsychToolBox package in MATLAB to present a research task to participants.
% The function takes various features of the research experiment as inputs,
% and outputs log files that contain responses made by the participant and
% other details from the task.

%%%%%%%%%%%%%%%%%%%%%%
% basic setup
%%%%%%%%%%%%%%%%%%%%%%

% controls code throughout that will be modified depending
% on whether the script is being run on PC (set to 1) or Mac (set to 0)
computer = 1;

% controls code throughout that will be modified depending
% on whether the script is being run at the MRI scanner (set to 1) or testing room (set to 0) 
scanner = 1;


% ... CODE OMITTED


% throwing errors for inappropriate function arguments
% check if all needed parameters given
if nargin < 4
    error('Must provide a subject number, order number (1 or 2), OTHER name, and run number (1-6). Example: ROSEF(12, 2, "Name", 2)');
end

% check that order number is between 1 and 2
if ~any(orderNum == 1:2)
    error('Must provide order number of 1 or 2');
end


% ... CODE OMITTED


% preparing log files
% define filename of data file
if computer == 0
    datafilename = strcat('ROSEF_data_', num2str(subNum), '_', num2str(orderNum), '_', num2str(runNum), '.txt');
else
    datafilename = strcat(pwd, '\ROSEF_data_', num2str(subNum), '_', num2str(orderNum), '_', num2str(runNum), '.txt');
end

% check for existing data file with the same filename to prevent 
% accidentally overwriting previous files (except for subject numbers > 99)
if subNum < 99 && fopen(datafilename, 'rt') ~= -1
    fclose('all');
    error('Data file already exists. Check input arguments or delete the old files to replace.');
else
    datafid = fopen(datafilename, 'wt'); % open ASCII file for writing
end

% print column headings to data file
fprintf(datafid, '%s %s %s %s %s %s %s\n', 'SUBJ', 'TRIAL', ... 
    'AFFECT', 'DIFFICULTY', 'STIM_NAME', 'STIM_TYPE', 'CUE_TYPE');

%%%%%%%%%%%%%%%%%%%%%%
% experiment
%%%%%%%%%%%%%%%%%%%%%%

% If anything goes wrong inside the 'try' block (matlab error), 
% then the 'catch' block is executed to properly close everything 
try


    % ... CODE OMITTED
	
	
    % define variables for durations of various screens (in seconds)
    duration_stim = 7.000;
    duration_rate = 3.000;
    
    % define variables for other messages
    if scanner == 0
        break_message = 'Press the space bar when you are ready to continue.';
    else
        break_message = 'The task is about to begin.';
    end
    self_message = 'For this group, follow instructions for\n\nYou';
    other_message = strcat('For this group, follow instructions for\n\n', otherName); 
    intertrial_message = 'RELAX';
    thank_you_message = 'Thank you';
    
    % define allowed keyboard responses (strange button-to-number mapping of 
	% scanner button boxes needs to be remapped to correspond with task rating scales)
    if scanner == 0
        seven_responses = {'1', '2', '3', '4', '5', '6', '7'};
    else
        seven_responses = {'1', '2', '3', '6', '7', '8', '9'};
        rate_map = {'5', '6', '7', '', '', '4', '3', '2', '1'};
    end
    continue_key = KbName('space');
    scanner_trigger = KbName('5%');
    
	
    % ... CODE OMITTED
        
		
	% drawing and presenting screens to participant
    % loop through full list of trial_nums
    for trial = 1:24
            
		
        % ... CODE OMITTED
        
		
            % collect a rating
			% prepare difficulty rating screen for display
            imdata = imread('difficulty.jpg');
            tex = Screen('MakeTexture', w, imdata);
            Screen('DrawTexture', w, tex, [], centeredRect2);

            % update display to show difficulty rating screen
            % record time of display in start_time
            [~, start_time] = Screen('Flip', w);
            difficulty_on = GetSecs;

            % check for difficulty responses for length of duration_rate
            while (GetSecs-start_time) <= duration_rate

                % check keyboard for a response, ~'s used as dummy placeholders
                [~, ~, keyCode] = KbCheck;

                % translate keyCode into a string (subject pressed only 1 key) 
                % or cell array of strings (happens whenever multiple keys
                % pressed simultaneously)
                keyName = KbName(keyCode);

                % in the case of multiple simultaneous keys, reduce to first
                % key press to a string, the QWERTY numbers come before letters in
                % the keynames mapping, so a number and letter will yield a
                % number, 2 numbers will yield the smaller number
                if iscell(keyName)
                    keyName = keyName{1};
                end

                % QWERTY number names consist of numeral and symbol (ex. "5%")
                % as long as keyName is not a null array, just take the first
                % character
                if ~isempty(keyName)
                    resp = keyName(1);
                    if scanner == 1
                        if ~strcmp(resp, '5')
                            difficulty_rt = GetSecs-difficulty_on;
                        end
                    else
                        difficulty_rt = GetSecs-difficulty_on;
                    end
                end


				% ... CODE OMITTED


                % wait 1 ms before checking the keyboard again to prevent
                % overload of the machine at elevated Priority()
                WaitSecs(0.001);
            end
            Screen('Close');
            affect_on = zero_time;
            
        end
        
        % write a line to data file with trial info and subject responses
        if block_type == 1
            fprintf(datafid, '%i %i %i %i %s %i %i\n', ...
                    subNum, ...
                    total_trial_num, ...
                    affect_resp, ...
                    difficulty_resp, ...
                    other_order{1}{trial_num}, ...
                    other_order{2}(trial_num), ...
                    other_order{3}(trial_num));
        else
            fprintf(datafid, '%i %i %i %i %s %i %i\n', ...
                    subNum, ...
                    total_trial_num, ...
                    affect_resp, ...
                    difficulty_resp, ...
                    self_order{1}{trial_num}, ...
                    self_order{2}(trial_num), ...
                    self_order{3}(trial_num));
        end
        
		
        % ... CODE OMITTED
        
   
% catch error: this is executed in case something goes wrong in the
% 'try' section due to error etc.
catch
    
    % do same cleanup as above
    Screen('CloseAll');
    ShowCursor;
    fclose('all');
    Priority(0);
    
    % output the error message that describes the error
    psychrethrow(psychlasterror);
    
    % end the experiment
    return;
end % try ... catch %