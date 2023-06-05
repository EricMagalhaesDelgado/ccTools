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

    % varargin number validation
    if nargin == 1
        error('At least one Name-Value parameters must be passed to the function.')
    elseif mod(nargin-1, 2)
        error('Name-value parameters must be in pairs.')
    end


    switch class(comp)
    %------------------------ CONTAINERS ---------------------------------%
        case {'matlab.ui.container.ButtonGroup'    ...
              'matlab.ui.container.Panel'          ...
              'matlab.ui.container.CheckBoxTree'   ...
              'matlab.ui.container.Tree'}
            [p, propertyName] = InputParser({'backgroundColor', 'borderRadius', 'borderWidth', 'borderColor'}, varargin{:});

            jsCommand = '';
            for ii = 1:numel(propertyName)
                    switch propertyName{ii}
                        case 'backgroundColor'
                            jsCommand = sprintf(['%sdocument.querySelector(''div[data-tag="%s"]'').style.backgroundColor = "transparent";\n' ...
                                                   'document.querySelector(''div[data-tag="%s"]'').children[0].style.backgroundColor = "%s";\n'], jsCommand, compTag, compTag, p.Results.(propertyName{ii}));
                        otherwise
                            jsCommand = sprintf('%sdocument.querySelector(''div[data-tag="%s"]'').children[0].style.%s = "%s";\n', jsCommand, compTag, propertyName{ii}, p.Results.(propertyName{ii}));
                    end
            end


    %---------------------------------------------------------------------%
        case 'matlab.ui.container.GridLayout'
            [p, propertyName] = InputParser({'backgroundColor'}, varargin{:});

            jsCommand = '';
            for ii = 1:numel(propertyName)
                jsCommand = sprintf('%sdocument.querySelector(''div[data-tag="%s"]'').style.backgroundColor = "%s";\n', jsCommand, compTag, p.Results.(propertyName{ii}));
            end


    %---------------------------------------------------------------------%
        case 'matlab.ui.container.TabGroup'
            [p, propertyName] = InputParser({'backgroundColor', 'backgroundHeaderColor', 'borderRadius', 'borderWidth', 'borderColor', 'fontFamily', 'fontSize', 'fontWeight', 'color'}, varargin{:});

            jsCommand = '';
            for ii = 1:numel(propertyName)
                switch propertyName{ii}
                    case 'backgroundColor'
                        jsCommand = sprintf('%sdocument.querySelector(''div[data-tag="%s"]'').style.backgroundColor = "transparent";\n', jsCommand, compTag);
                        for jj = 1:numel(comp.Children)
                            compChildrenTag = struct(struct(struct(comp.Children(jj)).Controller)).ViewModel.Id;
                            jsCommand = sprintf('%sdocument.querySelector(''div[data-tag="%s"]'').style.backgroundColor = "%s";\n', jsCommand, compChildrenTag, p.Results.(propertyName{ii}));
                        end

                    case 'backgroundHeaderColor'
                        jsCommand = sprintf('%sdocument.querySelector(''div[data-tag="%s"]'').children[1].style.backgroundColor = "%s";\n', jsCommand, compTag, p.Results.(propertyName{ii}));

                    case {'borderRadius', 'borderWidth', 'borderColor'}
                        jsCommand = sprintf('%sdocument.querySelector(''div[data-tag="%s"]'').style.%s = "%s";\n', jsCommand, compTag, propertyName{ii}, p.Results.(propertyName{ii}));
                end
            end

            % Font Properties (iterative process, going through all the tabs)
            idx = find(cellfun(@(x) ~isempty(x), cellfun(@(x) find(strcmp({'fontFamily', 'fontWeight', 'fontSize', 'color'}, x), 1), propertyName, 'UniformOutput', false)));
            if ~isempty(idx)
                jsCommand = sprintf(['%svar elements = document.querySelector(''div[data-tag="%s"]'').getElementsByClassName("mwTabLabel");\n' ...
                                       'for (let ii = 1; ii < elements.length; ii++) {\n'], jsCommand, compTag);
                for ii = idx
                    jsCommand = sprintf('%selements[ii].style.%s = "%s";\n', jsCommand, propertyName{ii}, p.Results.(propertyName{ii}));
                end
                jsCommand = sprintf('%s}\nelements = undefined;\n', jsCommand);
            end


    %---------------------------------------------------------------------%
        case 'matlab.ui.container.Tab'
            [p, propertyName] = InputParser({'backgroundColor'}, varargin{:});

            compParentTag = struct(struct(struct(comp.Parent).Controller)).ViewModel.Id;

            jsCommand = '';
            for ii = 1:numel(propertyName)
                jsCommand = sprintf(['%sdocument.querySelector(''div[data-tag="%s"]'').style.backgroundColor = "transparent";\n', ...
                                       'document.querySelector(''div[data-tag="%s"]'').style.backgroundColor = "%s";\n'], jsCommand, compParentTag, compTag, p.Results.(propertyName{ii}));
            end


    %-------------------------- CONTROLS ---------------------------------%
        case {'matlab.ui.control.Button'           ...
              'matlab.ui.control.DropDown'         ...
              'matlab.ui.control.EditField'        ...
              'matlab.ui.control.ListBox'          ...
              'matlab.ui.control.NumericEditField' ...
              'matlab.ui.control.StateButton'      ...
              'matlab.ui.control.TextArea'}
            [p, propertyName] = InputParser({'backgroundColor', 'borderRadius', 'borderWidth', 'borderColor', 'text-align', 'fontFamily', 'fontSize', 'fontWeight', 'color'}, varargin{:});

            jsCommand = '';
            for ii = 1:numel(propertyName)
                switch propertyName{ii}
                    case 'backgroundColor'
                        jsCommand = sprintf(['%sdocument.querySelector(''div[data-tag="%s"]'').style.backgroundColor = "transparent";\n' ...
                                               'document.querySelector(''div[data-tag="%s"]'').children[0].style.backgroundColor = "%s";\n'], jsCommand, compTag, compTag, p.Results.(propertyName{ii}));
                    otherwise
                        jsCommand = sprintf('%sdocument.querySelector(''div[data-tag="%s"]'').children[0].style.%s = "%s";\n', jsCommand, compTag, propertyName{ii}, p.Results.(propertyName{ii}));
                end
            end


    %---------------------------------------------------------------------%
        case 'matlab.ui.control.Table'
            [p, propertyName] = InputParser({'backgroundColor', 'backgroundHeaderColor', 'borderRadius', 'borderWidth', 'borderColor', 'fontFamily', 'fontSize', 'fontWeight', 'color'}, varargin{:});

            jsCommand = '';
            for ii = 1:numel(propertyName)
                switch propertyName{ii}
                    case 'backgoundColor'
                        jsCommand = sprintf('%sdocument.querySelector(''div[data-tag="%s"]'').children[0].style.backgroundColor = "%s";\n', jsCommand, compTag, p.Results.(propertyName{ii}));

                    case 'backgroundHeaderColor'
                        jsCommand = sprintf('%sdocument.querySelector(''div[data-tag="%s"]'').getElementsByClassName("mw-table-flex-dynamic-item")[0].style.backgroundColor = "%s";\n', jsCommand, compTag, p.Results.(propertyName{ii}));

                    case {'borderRadius', 'borderWidth', 'borderColor'}
                        jsCommand = sprintf('%sdocument.querySelector(''div[data-tag="%s"]'').children[0].children[0].style.%s = "%s";\n', jsCommand, compTag, propertyName{ii}, p.Results.(propertyName{ii}));
                end
            end

            % Font Properties (iterative process, going through all the columns)
            idx = find(cellfun(@(x) ~isempty(x), cellfun(@(x) find(strcmp({'fontFamily', 'fontWeight', 'fontSize', 'color'}, x), 1), propertyName, 'UniformOutput', false)));
            if ~isempty(idx)
                jsCommand = sprintf(['%svar elements = document.querySelector(''div[data-tag="%s"]'').getElementsByClassName("mw-default-header-cell");\n' ...
                                       'for (let ii = 0; ii < elements.length; ii++) {\n'], jsCommand, compTag);
                for ii = idx
                    jsCommand = sprintf('%selements[ii].style.%s = "%s";\n', jsCommand, propertyName{ii}, p.Results.(propertyName{ii}));
                end
                jsCommand = sprintf('%s}\nelements = undefined;\n', jsCommand);
            end


    %---------------------------------------------------------------------%
        case 'matlab.ui.control.CheckBox'
            [p, propertyName] = InputParser({'backgroundColor', 'borderRadius', 'borderWidth', 'borderColor'}, varargin{:});

            jsCommand = '';
            for ii = 1:numel(propertyName)
                jsCommand = sprintf('%sdocument.querySelector(''div[data-tag="%s"]'').getElementsByClassName("mwCheckBoxRadioIconNode")[0].style.%s = "%s";\n', jsCommand, compTag, propertyName{ii}, p.Results.(propertyName{ii}));
            end


    %---------------------------------------------------------------------%
        case 'matlab.ui.control.Slider'
            [p, propertyName] = InputParser({'backgroundColor', 'sliderRotate', 'sliderHeight'}, varargin{:});

            jsCommand = '';
            for ii = 1:numel(propertyName)
                switch propertyName{ii}
                    case 'backgoundColor'
                        jsCommand = sprintf('%sdocument.querySelector(''div[data-tag="%s"]'').getElementsByClassName("mwSliderTrack")[0].style.backgroundColor = "%s";\n', jsCommand, compTag, p.Results.(propertyName{ii}));
                    case 'trackHeight'
                        jsCommand = sprintf('%sdocument.querySelector(''div[data-tag="%s"]'').getElementsByClassName("mwSliderTrack")[0].style.height = "%s";\n', jsCommand, compTag, p.Results.(propertyName{ii}));
                    case 'thumbRotate'
                        jsCommand = sprintf('%sdocument.querySelector(''div[data-tag="%s"]'').getElementsByClassName("mwSliderThumb")[0].style.rotate = "%s";\n', jsCommand, compTag, p.Results.(propertyName{ii}));
                    case 'thumbHeight'
                        jsCommand = sprintf('%sdocument.querySelector(''div[data-tag="%s"]'').getElementsByClassName("mwSliderThumb")[0].style.height = "%s";\n', jsCommand, compTag, p.Results.(propertyName{ii}));
                end
            end


    %---------------------------------------------------------------------%
        otherwise
            error('ccTools does not cover the customization of ''%s'' class properties.', class(comp))
    end


    % JS
    try
        jsCommand
        fWebWin.executeJS(jsCommand);
        
    catch ME
        status   = false;
        errorMsg = getReport(ME);
    end
end


function [p, propertyName] = InputParser(propertyList, varargin)
    
    p = inputParser;
    d = struct();

    for ii = 1:numel(propertyList)
        switch(propertyList{ii})
            % BackgroundColor
            case 'backgroundColor';       d.backgroundColor = '#f0f0f0';   addParameter(p, 'backgroundColor',       d.backgroundColor, @(x) ccTools.validators.mustBeColor(x, 'hex'))
            case 'backgroundHeaderColor'; d.backgroundColor = '#f0f0f0';   addParameter(p, 'backgroundHeaderColor', d.backgroundColor, @(x) ccTools.validators.mustBeColor(x, 'hex'))

            % Border
            case 'borderRadius';          d.borderRadius    = '0px';       addParameter(p, 'borderRadius',          d.borderRadius,    @(x) ccTools.validators.mustBeCSSProperty(x, 'border-radius'))
            case 'borderWidth';           d.borderWidth     = '1px';       addParameter(p, 'borderWidth',           d.borderWidth,     @(x) ccTools.validators.mustBeCSSProperty(x, 'border-width'))
            case 'borderColor';           d.borderColor     = '#d7d7d7';   addParameter(p, 'borderColor',           d.borderColor,     @(x) ccTools.validators.mustBeColor(x, 'hex'))

            % Font
            case 'textAlign';             d.textAlign       = 'left';      addParameter(p, 'textAlign',             d.textAlign,       @(x) ccTools.validators.mustBeCSSProperty(x, 'text-align'))
            case 'fontFamily';            d.fontFamily      = 'Helvetica'; addParameter(p, 'fontFamily',            d.fontFamily,      @(x) ccTools.validators.mustBeCSSProperty(x, 'font-family'))
            case 'fontWeight';            d.fontWeight      = 'normal';    addParameter(p, 'fontWeight',            d.fontWeight,      @(x) ccTools.validators.mustBeCSSProperty(x, 'font-weight'))
            case 'fontSize';              d.fontSize        = '12px';      addParameter(p, 'fontSize',              d.fontSize,        @(x) ccTools.validators.mustBeCSSProperty(x, 'font-size'))
            case 'color';                 d.color           = "#000000";   addParameter(p, 'color',                 d.color,           @(x) ccTools.validators.mustBeColor(x, 'hex'))

            % Track and thumb (Slider)
            case 'trackHeight';          d.trackHeight      = '3px';       addParameter(p, 'trackHeight',           d.trackHeight,      @(x) ccTools.validators.mustBeCSSProperty(x, 'height'))
            case 'thumbRotate';          d.thumbRotate      = '0deg';      addParameter(p, 'thumbRotate',           d.thumbRotate,      @(x) ccTools.validators.mustBeCSSProperty(x, 'rotate'))
            case 'thumbHeight';          d.thumbHeight      = '15px';      addParameter(p, 'thumbHeight',           d.thumbHeight,      @(x) ccTools.validators.mustBeCSSProperty(x, 'height'))
        end
    end
            
    parse(p, varargin{:});
    propertyName = setdiff(p.Parameters, p.UsingDefaults);

end