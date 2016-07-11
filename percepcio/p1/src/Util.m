classdef Util
    % Util class, contains the common functions
    
    methods(Static)
        
        %% defaultQuestion() function
        % Show a default question dialog to continue the scrip execution.
        function choice = defaultQuestion()
            choice = questdlg('Would you like continue execution?', ...
                '', ...
                'Yes','No','Yes');
            waitfor(choice);
        end
        
        %% customQuestion() function
        % Show a question dialog with custom title and message.
        % @params
        % title: string
        % msg: string
        function choice = customQuestion(title, msg)
            choice = questdlg(msg, ...
                title, ...
                'Yes','No','Yes');
            waitfor(choice);
        end
        
    end
end

