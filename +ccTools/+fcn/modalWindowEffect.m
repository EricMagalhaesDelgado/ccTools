function modalWindowEffect(fig, opacityType)
%MODALWINDOWEFFECT
% For use with modal windows, trying to create the same visual aspect 
% created by uialert, uiconfirm and uiprogressdlg.

% Author.: Eric Magalhães Delgado
% Date...: May 12, 2023
% Version: 1.00

    arguments
        fig
        opacityType {mustBeMember(opacityType, {'modalWindow', 'none'})}
    end

    if ~isa(fig, 'matlab.ui.Figure')
        fig = ancestor(fig, 'figure');
    end

    if ~isempty(fig)
        h = findobj(fig, 'Tag', 'StandByMode');
        
        switch opacityType
            case 'modalWindow'
                if isempty(h)
                    matRelease = char(regexp(version, 'R\d{4}[ab]{1}', 'match'));
                    switch matRelease
                        case 'R2021b'; BackgroundColor = 'rgba(0, 0, 0, .64)';
                        case 'R2023a'; BackgroundColor = 'rgba(255, 255, 255, .64)';
                        otherwise;     BackgroundColor = 'rgba(255, 255, 255, .64)'; % Pendente olhar outras versões...
                    end
        
                     uihtml(fig, 'HTMLSource', sprintf('<!DOCTYPE html>\n<html>\n<body style="background-color: %s;"></body>\n</html>', BackgroundColor), ...
                                 'Tag',        'StandByMode',                                  ...
                                 'UserData',   struct('ID', char(java.rmi.server.UID),         ...
                                                      'WindowResize', char(fig.Resize)), ...
                                 'Position',   [1, 1, fig.Position(3:4)]);
                    fig.Resize = 'off';
                end
    
            case 'none'            
                if ~isempty(h)
                    if strcmp(h(1).UserData.WindowResize, 'on')
                        fig.Resize = 'on';
                    end
                    delete(h)
                end
        end
        drawnow nocallbacks
    end
end