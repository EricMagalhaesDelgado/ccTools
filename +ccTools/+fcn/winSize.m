function [winWidth,  winHeight] = winSize(comp, msg, p)

    winWidth    = str2double(extractBefore(p.winWidth,    'px'));
    winHeight   = str2double(extractBefore(p.winHeight,   'px'));
    msgFontSize = str2double(extractBefore(p.msgFontSize, 'px'));

    if isequal([winWidth, winHeight], [302, 162])
        winSize    = comp.Position(3:4); % Figure

        winColSize = floor(winWidth  / msgFontSize);
        winRowSize = floor(winHeight / (1.231*msgFontSize));
        
        msgSplit   = splitlines(msg);

        msgColumns = max(sum(cellfun(@(x) numel(x), msgSplit)));
        if msgColumns > winColSize
            winWidth = min([.5*winSize(1), msgFontSize*msgColumns]);
            if winWidth < 302
                winWidth = 302;
            end
            winColSize = floor(winWidth / msgFontSize);
        end
        
        msgRows    = ceil(sum(cellfun(@(x) numel(x), msgSplit) / winColSize));
        if msgRows > winRowSize
            winHeight = min([.8*winSize(2), 1.231*msgFontSize*msgRows]);
            if winHeight < 162
                winHeight = 162;
            end
        end
    end

    winWidth  = sprintf('%.0fpx', winWidth);
    winHeight = sprintf('%.0fpx', winHeight);
end