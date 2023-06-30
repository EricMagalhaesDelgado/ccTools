function [winWidth,  winHeight] = winSize(comp, msg, p)

    winWidth  = str2double(extractBefore(p.winWidth,  'px'));
    winHeight = str2double(extractBefore(p.winHeight, 'px'));

    % The window size will be adjustable, depending on the text content, 
    % only if the parameters winWidth and winHeight are not configured.
    if isequal([winWidth, winHeight], [302, 162])
        winSize     = comp.Position(3:4); % Figure

        iconWidth   = str2double(extractBefore(p.iconWidth,    'px'));
        btnHeight   = str2double(extractBefore(p.buttonHeight, 'px'));        
        msgFontSize = str2double(extractBefore(p.msgFontSize,  'px'));

        % Number of characters supported in a single line (winColSize) and 
        % number of lines (winRowSize), considering the initial window size
        % (302x106 pixels).
        winColSize  = floor((winWidth-iconWidth-30)  / (0.67*msgFontSize));
        winRowSize  = floor((winHeight-btnHeight-30) / (1.25*msgFontSize));
        
        % Splitting the text content into lines (msgSplit), identifying the 
        % number of characters in the line with the most characters (msgColumns).
        msgSplit    = cellfun(@(x) regexprep(x, '<.*?>', ''), splitlines(msg), 'UniformOutput', false);
        msgColumns  = max(cellfun(@(x) numel(x), msgSplit));
        if msgColumns > winColSize
            % New width of the window.
            winWidth = min([.5*winSize(1), 0.67*msgFontSize*msgColumns+iconWidth+30]);
            if winWidth < 302
                winWidth = 302;
            end
            % Updates the number of characters supported in a single line.
            winColSize  = floor((winWidth-iconWidth-30)  / (0.67*msgFontSize));
        end
        
        % Number of lines required to display the information on the screen.
        msgRows = sum(round(cellfun(@(x) numel(x), msgSplit) / winColSize));
        if msgRows > winRowSize
            % New height of the window.
            winHeight = min([.8*winSize(2), 1.231*msgFontSize*msgRows+btnHeight+30]);
            if winHeight < 162
                winHeight = 162;
            end
        end
    end

    winWidth  = sprintf('%.0fpx', winWidth);
    winHeight = sprintf('%.0fpx', winHeight);
end