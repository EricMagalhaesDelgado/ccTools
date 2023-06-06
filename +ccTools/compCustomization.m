function [status, errorMsg] = compCustomization(comp, varargin)

    arguments
        comp {ccTools.validators.mustBeBuiltInComponent}
    end

    arguments (Repeating)
        varargin
    end

    warning('off', 'MATLAB:structOnObject')
    warning('off', 'MATLAB:ui:javaframe:PropertyToBeRemoved')

    status   = true;
    errorMsg = '';

    fHandle  = ancestor(comp, 'figure');
    fWebWin  = struct(struct(struct(fHandle).Controller).PlatformHost).CEF;

    compTag  = struct(struct(struct(comp).Controller)).ViewModel.Id;

    % nargin validation
    if nargin == 1
        error('At least one Name-Value parameters must be passed to the function.')
    elseif mod(nargin-1, 2)
        error('Name-value parameters must be in pairs.')
    end

    % customizations...
    switch class(comp)
    %------------------------- UIFIGURE ----------------------------------%
        case 'matlab.ui.Figure' % OK
            propStruct = InputParser({'windowMinSize'}, varargin{:});

            for ii = 1:numel(propStruct)
                switch propStruct(ii).name
                    case 'windowMinSize'
                        fWebWin.setMinSize(propStruct(ii).value)
                end
            end


    %------------------------ CONTAINERS ---------------------------------%
        case {'matlab.ui.container.ButtonGroup'    ... % OK
              'matlab.ui.container.Panel'          ... % OK
              'matlab.ui.container.CheckBoxTree'   ... % OK
              'matlab.ui.container.Tree'}              % OK
            propStruct = InputParser({'backgroundColor', ...
                                      'borderRadius', 'borderWidth', 'borderColor'}, varargin{:});

            jsCommand = '';
            for ii = 1:numel(propStruct)
                switch propStruct(ii).name
                    case 'backgroundColor'
                        jsCommand = sprintf(['%sdocument.querySelector(''div[data-tag="%s"]'').style.backgroundColor = "transparent";\n' ...
                                               'document.querySelector(''div[data-tag="%s"]'').children[0].style.backgroundColor = "%s";\n'], jsCommand, compTag, compTag, propStruct(ii).value);
                    otherwise
                        jsCommand = sprintf('%sdocument.querySelector(''div[data-tag="%s"]'').children[0].style.%s = "%s";\n', jsCommand, compTag, propStruct(ii).name, propStruct(ii).value);
                end
            end


    %---------------------------------------------------------------------%
        case 'matlab.ui.container.GridLayout' % OK
            propStruct = InputParser({'backgroundColor'}, varargin{:});

            jsCommand = '';
            for ii = 1:numel(propStruct)
                switch propStruct(ii).name
                    case 'backgroundColor'
                        jsCommand = sprintf('%sdocument.querySelector(''div[data-tag="%s"]'').style.backgroundColor = "%s";\n', jsCommand, compTag, propStruct(ii).value);
                end
            end


    %---------------------------------------------------------------------%
        case 'matlab.ui.container.TabGroup' % OK
            propStruct = InputParser({'backgroundColor', 'backgroundHeaderColor',   ...
                                      'borderRadius', 'borderWidth', 'borderColor', ...
                                      'fontFamily', 'fontStyle', 'fontWeight', 'fontSize', 'color'}, varargin{:});

            jsCommand = '';
            for ii = 1:numel(propStruct)
                switch propStruct(ii).name
                    case 'backgroundColor'
                        jsCommand = sprintf('%sdocument.querySelector(''div[data-tag="%s"]'').style.backgroundColor = "transparent";\n', jsCommand, compTag);
                        for jj = 1:numel(comp.Children)
                            compChildrenTag = struct(struct(struct(comp.Children(jj)).Controller)).ViewModel.Id;
                            jsCommand = sprintf('%sdocument.querySelector(''div[data-tag="%s"]'').style.backgroundColor = "%s";\n', jsCommand, compChildrenTag, propStruct(ii).value);
                        end

                    case 'backgroundHeaderColor'
                        jsCommand = sprintf(['%sdocument.querySelector(''div[data-tag="%s"]'').style.backgroundColor = "transparent";\n' ...
                                               'document.querySelector(''div[data-tag="%s"]'').children[1].style.backgroundColor = "%s";\n'], jsCommand, compTag, compTag, propStruct(ii).value);

                    case {'borderRadius', 'borderWidth', 'borderColor'}
                        jsCommand = sprintf('%sdocument.querySelector(''div[data-tag="%s"]'').style.%s = "%s";\n', jsCommand, compTag, propStruct(ii).name, propStruct(ii).value);
                end
            end

            % Font Properties (iterative process, going through all the tabs)
            idx = find(cellfun(@(x) ~isempty(x), cellfun(@(x) find(strcmp({'fontFamily', 'fontStyle', 'fontWeight', 'fontSize', 'color'}, x), 1), {propStruct.name}, 'UniformOutput', false)));
            if ~isempty(idx)
                jsCommand = sprintf(['%svar elements = document.querySelector(''div[data-tag="%s"]'').getElementsByClassName("mwTabLabel");\n' ...
                                       'for (let ii = 1; ii < elements.length; ii++) {\n'], jsCommand, compTag);
                for ll = idx
                    jsCommand = sprintf('%selements[ii].style.%s = "%s";\n', jsCommand, propStruct(ll).name, propStruct(ll).value);
                end
                jsCommand = sprintf('%s}\nelements = undefined;\n', jsCommand);
            end


    %---------------------------------------------------------------------%
        case 'matlab.ui.container.Tab' % OK
            propStruct = InputParser({'backgroundColor'}, varargin{:});

            compParentTag = struct(struct(struct(comp.Parent).Controller)).ViewModel.Id;
            jsCommand = '';
            for ii = 1:numel(propStruct)
                jsCommand = sprintf(['%sdocument.querySelector(''div[data-tag="%s"]'').style.backgroundColor = "transparent";\n', ...
                                       'document.querySelector(''div[data-tag="%s"]'').style.backgroundColor = "%s";\n'], jsCommand, compParentTag, compTag, propStruct(ii).value);
            end


    %-------------------------- CONTROLS ---------------------------------%
        case {'matlab.ui.control.Button'  ...  % OK              
              'matlab.ui.control.ListBox' ...  % OK
              'matlab.ui.control.StateButton'} % OK
            propStruct = InputParser({'backgroundColor', ...
                                      'borderRadius', 'borderWidth', 'borderColor', ...
                                      'fontFamily', 'fontStyle', 'fontWeight', 'fontSize', 'color'}, varargin{:});

            jsCommand = '';
            for ii = 1:numel(propStruct)
                switch propStruct(ii).name
                    case 'backgroundColor'
                        jsCommand = sprintf(['%sdocument.querySelector(''div[data-tag="%s"]'').style.backgroundColor = "transparent";\n' ...
                                               'document.querySelector(''div[data-tag="%s"]'').children[0].style.backgroundColor = "%s";\n'], jsCommand, compTag, compTag, propStruct(ii).value);
                    otherwise
                        jsCommand = sprintf('%sdocument.querySelector(''div[data-tag="%s"]'').children[0].style.%s = "%s";\n', jsCommand, compTag, propStruct(ii).name, propStruct(ii).value);
                end
            end


    %---------------------------------------------------------------------%
        case {'matlab.ui.control.DropDown', ...     % OK
              'matlab.ui.control.EditField' ...     % OK
              'matlab.ui.control.NumericEditField'} % OK
            propStruct = InputParser({'backgroundColor', ...
                                      'borderRadius', 'borderWidth', 'borderColor'}, varargin{:});

            jsCommand = '';
            for ii = 1:numel(propStruct)
                switch propStruct(ii).name
                    case 'backgroundColor'
                        jsCommand = sprintf(['%sdocument.querySelector(''div[data-tag="%s"]'').style.backgroundColor = "transparent";\n' ...
                                               'document.querySelector(''div[data-tag="%s"]'').children[0].style.backgroundColor = "%s";\n'], jsCommand, compTag, compTag, propStruct(ii).value);
                    otherwise
                        jsCommand = sprintf('%sdocument.querySelector(''div[data-tag="%s"]'').children[0].style.%s = "%s";\n', jsCommand, compTag, propStruct(ii).name, propStruct(ii).value);
                end
            end


    %---------------------------------------------------------------------%
        case 'matlab.ui.control.TextArea' % OK
            propStruct = InputParser({'backgroundColor', ...
                                      'borderRadius', 'borderWidth', 'borderColor', ...
                                      'fontFamily', 'fontStyle', 'fontWeight', 'fontSize', 'color', 'textAlign'}, varargin{:});

            jsCommand = '';
            for ii = 1:numel(propStruct)
                switch propStruct(ii).name
                    case 'backgroundColor'
                        jsCommand = sprintf(['%sdocument.querySelector(''div[data-tag="%s"]'').style.backgroundColor = "transparent";\n' ...
                                               'document.querySelector(''div[data-tag="%s"]'').children[0].style.backgroundColor = "%s";\n'], jsCommand, compTag, compTag, propStruct(ii).value);
                    case {'fontFamily', 'fontStyle', 'fontWeight', 'fontSize', 'color', 'textAlign'}
                        jsCommand = sprintf('%sdocument.querySelector(''div[data-tag="%s"]'').getElementsByTagName("textarea")[0].style.%s = "%s";\n', jsCommand, compTag, propStruct(ii).name, propStruct(ii).value);
                    otherwise
                        jsCommand = sprintf('%sdocument.querySelector(''div[data-tag="%s"]'').children[0].style.%s = "%s";\n', jsCommand, compTag, propStruct(ii).name, propStruct(ii).value);
                end
            end


    %---------------------------------------------------------------------%
        case 'matlab.ui.control.Table' % PENDENTE BACKGROUNDCOLOR, BORDERRADIUS, BORDERWIDTH & BORDERCOLOR
            propStruct = InputParser({'backgroundColor', 'backgroundHeaderColor',   ...
                                      'borderRadius', 'borderWidth', 'borderColor', ...
                                      'fontFamily', 'fontStyle', 'fontWeight', 'fontSize', 'color'}, varargin{:});

            jsCommand = '';
            for ii = 1:numel(propStruct)
                switch propStruct(ii).name
                    case 'backgoundColor'
                        jsCommand = sprintf('%sdocument.querySelector(''div[data-tag="%s"]'').children[0].style.backgroundColor = "%s";\n', jsCommand, compTag, propStruct(ii).value);

                    case 'backgroundHeaderColor'
                        jsCommand = sprintf('%sdocument.querySelector(''div[data-tag="%s"]'').getElementsByClassName("mw-table-flex-dynamic-item")[0].style.backgroundColor = "%s";\n', jsCommand, compTag, propStruct(ii).value);

                    case {'borderRadius', 'borderWidth', 'borderColor'}
                        jsCommand = sprintf('%sdocument.querySelector(''div[data-tag="%s"]'').children[0].children[0].style.%s = "%s";\n', jsCommand, compTag, propStruct(ii).name, propStruct(ii).value);
                end
            end

            % Font Properties (iterative process, going through all the columns)
            idx = find(cellfun(@(x) ~isempty(x), cellfun(@(x) find(strcmp({'fontFamily', 'fontStyle', 'fontWeight', 'fontSize', 'color'}, x), 1), {propStruct.name}, 'UniformOutput', false)));
            if ~isempty(idx)
                jsCommand = sprintf(['%svar elements = document.querySelector(''div[data-tag="%s"]'').getElementsByClassName("mw-default-header-cell");\n' ...
                                       'for (let ii = 0; ii < elements.length; ii++) {\n'], jsCommand, compTag);
                for ll = idx
                    jsCommand = sprintf('%selements[ii].style.%s = "%s";\n', jsCommand, propStruct(ll).name, propStruct(ll).value);
                end
                jsCommand = sprintf('%s}\nelements = undefined;\n', jsCommand);
            end


    %---------------------------------------------------------------------%
        case 'matlab.ui.control.CheckBox' % OK
            propStruct = InputParser({'backgroundColor', ...
                                      'borderRadius', 'borderWidth', 'borderColor'}, varargin{:});

            jsCommand = '';
            for ii = 1:numel(propStruct)
                jsCommand = sprintf('%sdocument.querySelector(''div[data-tag="%s"]'').getElementsByClassName("mwCheckBoxRadioIconNode")[0].style.%s = "%s";\n', jsCommand, compTag, propStruct(ii).name, propStruct(ii).value);
            end


    %---------------------------------------------------------------------%
        case 'matlab.ui.control.Slider' % OK
            propStruct = InputParser({'backgroundColor', ...
                                      'trackHeight', 'thumbRotate', 'thumbHeight'}, varargin{:});

            jsCommand = '';
            for ii = 1:numel(propStruct)
                switch propStruct(ii).name
                    case 'backgroundColor'
                        jsCommand = sprintf('%sdocument.querySelector(''div[data-tag="%s"]'').getElementsByClassName("mwSliderTrack")[0].style.backgroundColor = "%s";\n', jsCommand, compTag, propStruct(ii).value);
                    case 'trackHeight'
                        jsCommand = sprintf('%sdocument.querySelector(''div[data-tag="%s"]'').getElementsByClassName("mwSliderTrack")[0].style.height = "%s";\n', jsCommand, compTag, propStruct(ii).value);
                    case 'thumbRotate'
                        jsCommand = sprintf('%sdocument.querySelector(''div[data-tag="%s"]'').getElementsByClassName("mwSliderThumb")[0].style.rotate = "%s";\n', jsCommand, compTag, propStruct(ii).value);
                    case 'thumbHeight'
                        jsCommand = sprintf('%sdocument.querySelector(''div[data-tag="%s"]'').getElementsByClassName("mwSliderThumb")[0].style.height = "%s";\n', jsCommand, compTag, propStruct(ii).value);
                end
            end


    %---------------------------------------------------------------------%
        otherwise
            error('ccTools does not cover the customization of ''%s'' class properties.', class(comp))
    end


    % JS
    try
        if exist('jsCommand', 'var')
            pause(.001)
            fWebWin.executeJS(jsCommand);
        end
        
    catch ME
        status   = false;
        errorMsg = getReport(ME);
    end
end


function propStruct = InputParser(propList, varargin)
    
    p = inputParser;
    d = struct();

    for ii = 1:numel(propList)
        switch(propList{ii})
            % Window
            case 'windowMinSize';         d.windowMinSize   = []; addParameter(p, 'windowMinSize',         d.windowMinSize,   @(x) ccTools.validators.mustBeNumericArray(x, 2, 'NonNegativeInteger'))

            % BackgroundColor
            case 'backgroundColor';       d.backgroundColor = []; addParameter(p, 'backgroundColor',       d.backgroundColor, @(x) ccTools.validators.mustBeColor(x, 'all'))
            case 'backgroundHeaderColor'; d.backgroundColor = []; addParameter(p, 'backgroundHeaderColor', d.backgroundColor, @(x) ccTools.validators.mustBeColor(x, 'all'))

            % Border
            case 'borderRadius';          d.borderRadius    = []; addParameter(p, 'borderRadius',          d.borderRadius,    @(x) ccTools.validators.mustBeCSSProperty(x, 'border-radius'))
            case 'borderWidth';           d.borderWidth     = []; addParameter(p, 'borderWidth',           d.borderWidth,     @(x) ccTools.validators.mustBeCSSProperty(x, 'border-width'))
            case 'borderColor';           d.borderColor     = []; addParameter(p, 'borderColor',           d.borderColor,     @(x) ccTools.validators.mustBeColor(x, 'all'))

            % Font
            case 'textAlign';             d.textAlign       = []; addParameter(p, 'textAlign',             d.textAlign,       @(x) ccTools.validators.mustBeCSSProperty(x, 'text-align'))
            case 'fontFamily';            d.fontFamily      = []; addParameter(p, 'fontFamily',            d.fontFamily,      @(x) ccTools.validators.mustBeCSSProperty(x, 'font-family'))
            case 'fontStyle';             d.fontStyle       = []; addParameter(p, 'fontStyle',             d.fontStyle,       @(x) ccTools.validators.mustBeCSSProperty(x, 'font-style'))
            case 'fontWeight';            d.fontWeight      = []; addParameter(p, 'fontWeight',            d.fontWeight,      @(x) ccTools.validators.mustBeCSSProperty(x, 'font-weight'))
            case 'fontSize';              d.fontSize        = []; addParameter(p, 'fontSize',              d.fontSize,        @(x) ccTools.validators.mustBeCSSProperty(x, 'font-size'))
            case 'color';                 d.color           = []; addParameter(p, 'color',                 d.color,           @(x) ccTools.validators.mustBeColor(x, 'all'))

            % Track and thumb (Slider)
            case 'trackHeight';           d.trackHeight     = []; addParameter(p, 'trackHeight',           d.trackHeight,     @(x) ccTools.validators.mustBeCSSProperty(x, 'height'))
            case 'thumbRotate';           d.thumbRotate     = []; addParameter(p, 'thumbRotate',           d.thumbRotate,     @(x) ccTools.validators.mustBeCSSProperty(x, 'rotate'))
            case 'thumbHeight';           d.thumbHeight     = []; addParameter(p, 'thumbHeight',           d.thumbHeight,     @(x) ccTools.validators.mustBeCSSProperty(x, 'height'))
        end
    end
            
    parse(p, varargin{:});

    propStruct = struct('name', {}, 'value', {});
    propName   = setdiff(p.Parameters, p.UsingDefaults);

    for ll = 1:numel(propName)
        propValue = p.Results.(propName{ll});

        if ismember(propName{ll}, {'backgroundColor', 'backgroundHeaderColor', 'borderColor', 'color'})
            if isnumeric(p.Results.(propName{ll}))
                propValue = ccTools.fcn.rgb2hex(propValue);
            else
                propValue = char(propValue);
            end
        end

        propStruct(ll) = struct('name',  propName{ll}, ...
                                'value', propValue);
    end

end