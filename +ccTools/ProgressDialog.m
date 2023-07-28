function d = ProgressDialog(comp, varargin)

    arguments
        comp {ccTools.validators.mustBeBuiltInComponent}
    end

    arguments (Repeating)
        varargin
    end
    
    % compatibility warning
    if ~ismember(version('-release'), {'2021b', '2022a', '2022b', '2023a'})
        warning('ccTools.ProgressDialog was tested only in three MATLAB releases (R2021b, R2022b and R2023a).')
    end

    % nargin validation
    if mod(nargin-1, 2)
        error('Name-value parameters must be in pairs.')
    end

    warning('off', 'MATLAB:structOnObject')
    warning('off', 'MATLAB:ui:javaframe:PropertyToBeRemoved')
    
    % main variables
    pathToMFILE = fileparts(mfilename('fullpath'));
    [webWin, compTag] = ccTools.fcn.componentInfo(comp);

    % ProgressDialog model
    p = ccTools.fcn.InputParser({'size', 'color'}, varargin{:});

    dataTag      = char(matlab.lang.internal.uuid());
    uniqueSuffix = datestr(now, '_THHMMSSFFF');
    
    switch class(comp)
        case {'matlab.ui.container.internal.AppContainer', 'matlab.ui.Figure'}
            jsSetParent = sprintf(['document.body.appendChild(u%s);\n' ...
                                   'document.body.appendChild(w%s);'], uniqueSuffix, uniqueSuffix);
        otherwise
            jsSetParent = sprintf(['document.querySelector(''[data-tag="%s"]'').appendChild(u%s);\n' ...
                                   'document.querySelector(''[data-tag="%s"]'').appendChild(w%s);'], compTag, uniqueSuffix, compTag, uniqueSuffix);
    end
    jsCodeOnCreation = sprintf(replace(fileread(fullfile(pathToMFILE, 'css&js', 'ProgressDialog_onCreation.js')), '<uniqueSuffix>', uniqueSuffix), jsSetParent, dataTag, dataTag, dataTag, p.size, p.color);
    jsCodeOnCleanup  = replace(fileread(fullfile(pathToMFILE, 'css&js', 'ProgressDialog_onCleanup.js')),  '<uniqueSuffix>', uniqueSuffix);

    % JS
    pause(.001)
    try
        d = ccTools.class.modalDialog('ProgressDialog', webWin, compTag, dataTag, jsCodeOnCreation, jsCodeOnCleanup, pathToMFILE);
    catch
    end
end