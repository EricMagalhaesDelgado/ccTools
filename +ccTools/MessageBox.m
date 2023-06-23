function MessageBox(comp, msg, varargin)

    arguments
        comp matlab.ui.Figure
        msg  {ccTools.validators.mustBeScalarText}
    end

    arguments (Repeating)
        varargin
    end
    
    % compatibility warning
    if ~ismember(version('-release'), {'2021b', '2022a', '2022b', '2023a'})
        warning('ccTools.uiprogressdlg was tested only in three MATLAB releases (R2021b, R2022b and R2023a).')
    end

    % nargin validation
    if mod(nargin-2, 2)
        error('Name-value parameters must be in pairs.')
    end

    warning('off', 'MATLAB:structOnObject')
    warning('off', 'MATLAB:ui:javaframe:PropertyToBeRemoved')
    
    % main variables
    pathToMFILE = fileparts(mfilename('fullpath'));
    [webWin, compTag] = ccTools.fcn.componentInfo(comp);

    % MessageBox model
    p = ccTools.fcn.InputParser({'winWidth', 'winHeight', 'winBackgroundColor', ...
        'iconFullFile', 'iconWidth', 'iconHeight',                              ...
        'msgFontFamily', 'msgFontSize', 'msgFontColor', 'msgTextAlign',         ...
        'buttonWidth', 'buttonHeight', 'buttonBackgroundColor', 'buttonBorderRadius', 'buttonBorderWidth', 'buttonBorderColor', 'buttonFontFamily', 'buttonFontSize', 'buttonFontColor', 'buttonTextAlign'}, varargin{:});

    dataTag      = char(matlab.lang.internal.uuid());
    uniqueSuffix = datestr(now, '_THHMMSSFFF');
    [imgFormat, imgBase64] = ccTools.fcn.img2base64(p.iconFullFile, 'ccTools.MessageBox');
    
    jsCodeOnCreation = sprintf(replace(fileread(fullfile(pathToMFILE, 'css&js', 'MessageBox.js')), '<uniqueSuffix>', uniqueSuffix),                               ...
        dataTag, dataTag, dataTag, p.winWidth, p.winHeight, p.winBackgroundColor, p.iconWidth, p.buttonWidth, p.iconHeight, p.buttonHeight, imgFormat, imgBase64, ...
        p.winBackgroundColor, p.msgFontFamily, p.msgFontSize, p.msgFontColor, p.msgTextAlign, replace(msg, newline, '<br>'), p.buttonBackgroundColor, p.buttonBorderRadius,                 ...
        p.buttonBorderWidth, p.buttonBorderColor, p.buttonFontFamily, p.buttonFontSize, p.buttonFontColor, p.buttonTextAlign);

    jsCodeOnCleanup = '';

    % JS
    pause(.001)
    try
        ccTools.class.modalDialog('MessageBox', webWin, compTag, dataTag, jsCodeOnCreation, jsCodeOnCleanup, pathToMFILE);
    catch
    end
end