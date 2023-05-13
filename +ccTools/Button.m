classdef Button < matlab.ui.componentcontainer.ComponentContainer

    % Author.: Eric Magalhães Delgado
    % Date...: May 13, 2023
    % Version: 1.00

    %% PROPERTIES
    properties (Access = private, Transient, NonCopyable, UsedInUpdate = false, AbortSet)
        Grid matlab.ui.container.GridLayout
        HTML matlab.ui.control.HTML
    end

    properties (AbortSet)
        Model           (1,1) ccTools.enum.ButtonModel                                                     = ccTools.enum.ButtonModel.IconPlusText

        Text            (1,:) char   {ccTools.validators.mustBeScalarText}                                 = 'Button'
        Description     (1,:) char   {ccTools.validators.mustBeScalarText}                                 = 'Description'
        Icon            (1,:) char   {ccTools.validators.mustBeScalarText}                                 = ''

        IconAlignment   (1,1) ccTools.enum.IconAlign                                                       = ccTools.enum.IconAlign.top
        HorizontalAlign (1,1) ccTools.enum.HorizontalAlign                                                 = ccTools.enum.HorizontalAlign.right
        VerticalAlign   (1,1) ccTools.enum.VerticalAlign                                                   = ccTools.enum.VerticalAlign.center

        ColumnSpacing   (1,1) double {ccTools.validators.mustBeUnsignedNumber}                             = 5
        RowSpacing      (1,1) double {ccTools.validators.mustBeUnsignedNumber}                             = 0
        RowTextSpacing  (1,1) double {ccTools.validators.mustBeUnsignedNumber}                             = 0

        BorderWidth     (1,1) double {ccTools.validators.mustBeUnsignedNumber}                             = 1
        BorderColor     (1,:) char   {ccTools.validators.mustBeColor}                                      = '#808080'
        BorderRadius    (1,:) char   {ccTools.validators.mustBeCSSProperty(BorderRadius, 'border-radius')} = '5px'
        BorderPadding   (1,1) double {ccTools.validators.mustBeUnsignedNumber}                             = 5
            
        IconWidth       (1,1) double {ccTools.validators.mustBeUnsignedNumber(IconWidth,  'nonZero')}      = 18 % pixels
        IconHeight      (1,1) double {ccTools.validators.mustBeUnsignedNumber(IconHeight, 'nonZero')}      = 18 % pixels

        FontFamily      (1,1) ccTools.enum.FontFamily                                                      = ccTools.enum.FontFamily.Helvetica
        tFontWeight     (1,1) ccTools.enum.FontWeight                                                      = ccTools.enum.FontWeight.bold
        tFontSize       (1,1) double {ccTools.validators.mustBeUnsignedNumber(tFontSize, 'nonZero')}       = 12
        tFontColor      (1,:) char   {ccTools.validators.mustBeColor}                                      = 'black'
        dFontSize       (1,1) double {ccTools.validators.mustBeUnsignedNumber(dFontSize, 'nonZero')}       = 10
        dFontColor      (1,:) char   {ccTools.validators.mustBeColor}                                      = '#808080'

        Enable          (1,1) logical                                                                      = true
        DisabledOpacity (1,1) double {ccTools.validators.mustBeNumberInRange(DisabledOpacity, .10, .90)}   = .35 % Matlab default value (uibutton R2021b)
    end

    properties (Access = protected, UsedInUpdate = false)
        Startup         (1,1) logical = true
        pathToMFILE     (1,:) char    = ''
        
        PreviousEnable  (1,1) logical = true
    end


    %% EVENTS
    events (HasCallbackProperty, NotifyAccess = private)
        ButtonPushed
    end


    %% MAIN METHODS: SETUP & UPDATE
    methods (Access = protected)
        function setup(comp)
            comp.pathToMFILE = fileparts(mfilename('fullpath'));

            comp.Position = [1 1 180 70];
            comp.BackgroundColor = "#f5f5f5"; % Matlab default value (uibutton)

            comp.Grid = uigridlayout(comp);
            comp.Grid.ColumnWidth = {'1x'};
            comp.Grid.RowHeight = {'1x'};
            comp.Grid.Padding = [0 0 0 0];
            comp.Grid.BackgroundColor = [1 1 1];

            comp.HTML = uihtml(comp.Grid);
            comp.HTML.Data = '';
            comp.HTML.DataChangedFcn = matlab.apps.createCallbackFcn(comp, @HTMLDataChanged, true);
            comp.HTML.Layout.Row = 1;
            comp.HTML.Layout.Column = 1;
        end


        function update(comp)
            if comp.Startup
                comp.Startup = false;

                comp.PreviousEnable = comp.Enable;
                comp.HTML.HTMLSource = htmlConstructor(comp);

                if isprop(comp.Parent, 'BackgroundColor'); comp.Grid.BackgroundColor = comp.Parent.BackgroundColor;
                else;                                      comp.Grid.BackgroundColor = "#f0f0f0"; % Matlab default background color (canvas/uigrid)
                end
            else    
                if ~isequal(comp.Enable, comp.PreviousEnable)
                    comp.PreviousEnable = comp.Enable;                
                    if comp.Enable; comp.HTML.Data = 'ButtonEnabled';
                    else;           comp.HTML.Data = 'ButtonDisabled';
                    end
                else
                    comp.HTML.HTMLSource = htmlConstructor(comp);
                end
            end
        end


        % JS >> MATLAB EVENTS
        function HTMLDataChanged(comp, event)
            if strcmp(event.Data, 'ButtonPushed')
                comp.HTML.Data = '';
                notify(comp, 'ButtonPushed')
            end
        end
    end

    
    %% HTML SOURCE CODE CONSTRUCTOR
    methods (Access = protected)
        function htmlCode = htmlConstructor(comp)
            htmlGrid   = htmlGridLayout(comp);

            htmlStyle  = htmlStyleTemplate(comp, htmlGrid);
            htmlBody   = htmlBodyTemplate(comp);
            htmlScript = htmlScriptTemplate(comp);

            if comp.Enable; buttonStatus = '';
            else;           buttonStatus = ' disabled';
            end

            htmlCode   = sprintf(['<!DOCTYPE html>\n<html>\n<head>\n<style type="text/css">\n%s\n</style>\n</head>\n\n'       ...
                                  '<body>\n\t<button id="ccButton"%s>\n\t\t<div class="Grid">\n%s\n\t\t</div>\n\t</button>\n' ...
                                  '<script type="text/javascript">\n%s\n</script>\n</body>\n</html>'], htmlStyle, buttonStatus, htmlBody, htmlScript);
        end


        function htmlGrid = htmlGridLayout(comp)
            switch comp.Model
                case 'IconPlusText'
                    switch comp.IconAlignment
                        case 'top'
                            ColumnWidth = '1fr';
                            switch comp.VerticalAlign
                                case 'top';    RowHeight = 'auto 1fr';   iconVerticalAlign = 'center';     textVerticalAlign = 'flex-start';
                                case 'center'; RowHeight = '1fr 1fr';    iconVerticalAlign = 'flex-end';   textVerticalAlign = 'flex-start';
                                case 'bottom'; RowHeight = '1fr auto';   iconVerticalAlign = 'flex-end';   textVerticalAlign = 'center';
                            end
                            iconHorizontalAlign = comp.HorizontalAlign;
                            textHorizontalAlign = comp.HorizontalAlign;

                        case 'bottom'
                            ColumnWidth = '1fr';
                            switch comp.VerticalAlign
                                case 'top';    RowHeight = 'auto 1fr';   iconVerticalAlign = 'flex-start'; textVerticalAlign = 'center';
                                case 'center'; RowHeight = '1fr 1fr';    iconVerticalAlign = 'flex-start'; textVerticalAlign = 'flex-end';
                                case 'bottom'; RowHeight = '1fr auto';   iconVerticalAlign = 'center';     textVerticalAlign = 'flex-end';
                            end
                            iconHorizontalAlign = comp.HorizontalAlign;
                            textHorizontalAlign = comp.HorizontalAlign;

                        case 'left'
                            RowHeight = '1fr';                            
                            switch comp.HorizontalAlign
                                case 'left';   ColumnWidth = 'auto 1fr'; iconHorizontalAlign = 'center';   textHorizontalAlign = 'left';
                                case 'center'; ColumnWidth = '1fr 1fr';  iconHorizontalAlign = 'right';    textHorizontalAlign = 'left';
                                case 'right';  ColumnWidth = '1fr auto'; iconHorizontalAlign = 'right';    textHorizontalAlign = 'left';
                            end
                            iconVerticalAlign = htmlGridLayout_Aux(comp);
                            textVerticalAlign = iconVerticalAlign;

                        case 'right'
                            RowHeight = '1fr';                            
                            switch comp.HorizontalAlign
                                case 'left';   ColumnWidth = 'auto 1fr'; iconHorizontalAlign = 'left';     textHorizontalAlign = 'right';
                                case 'center'; ColumnWidth = '1fr 1fr';  iconHorizontalAlign = 'left';     textHorizontalAlign = 'right';
                                case 'right';  ColumnWidth = '1fr auto'; iconHorizontalAlign = 'center';   textHorizontalAlign = 'right';
                            end
                            iconVerticalAlign = htmlGridLayout_Aux(comp);
                            textVerticalAlign = iconVerticalAlign;
                    end

                case {'Icon', 'Text'}
                    RowHeight   = '1fr';
                    ColumnWidth = '1fr';

                    iconHorizontalAlign = comp.HorizontalAlign;
                    textHorizontalAlign = iconHorizontalAlign;
                    
                    iconVerticalAlign   = htmlGridLayout_Aux(comp);
                    textVerticalAlign   = iconVerticalAlign;
            end
            
            htmlGrid = struct('RowHeight',   RowHeight, 'ColumnWidth', ColumnWidth,   ...
                              'Icon', struct('VerticalAlign',   iconVerticalAlign,    ...
                                             'HorizontalAlign', iconHorizontalAlign), ...
                              'Text', struct('VerticalAlign',   textVerticalAlign,    ...
                                             'HorizontalAlign', textHorizontalAlign));
        end


        function iconVerticalAlign = htmlGridLayout_Aux(comp)
            switch comp.VerticalAlign
                case 'top';    iconVerticalAlign = 'flex-start';
                case 'center'; iconVerticalAlign = 'center';
                case 'bottom'; iconVerticalAlign = 'flex-end';
            end
        end


        function htmlStyle = htmlStyleTemplate(comp, htmlGrid)
            BackGroundColor     = uint8(255*comp.BackgroundColor);
            htmlBackGroundColor = sprintf('rgb(%d, %d, %d)',   BackGroundColor(1), BackGroundColor(2), BackGroundColor(3));
            htmlHoverColor      = htmlRGBColor(comp, 'hover',  BackGroundColor);
            htmlActiveColor     = htmlRGBColor(comp, 'active', BackGroundColor);

            htmlStyle = sprintf(fileread(fullfile(comp.pathToMFILE, 'css&js', 'ccButton.css')), comp.BorderPadding,            comp.BorderWidth,              ...
                                                                                                 comp.RowSpacing,               comp.IconHeight,               ...
                                                                                                 htmlBackGroundColor,           comp.BorderColor,              ...
                                                                                                 comp.BorderRadius,             htmlHoverColor,                ...
                                                                                                 comp.DisabledOpacity,          htmlActiveColor,               ...
                                                                                                 comp.RowTextSpacing,           htmlGrid.RowHeight,            ...
                                                                                                 htmlGrid.ColumnWidth,          comp.ColumnSpacing,            ...
                                                                                                 htmlGrid.Icon.HorizontalAlign, htmlGrid.Icon.VerticalAlign,   ...
                                                                                                 comp.IconWidth,                htmlGrid.Text.HorizontalAlign, ...
                                                                                                 htmlGrid.Text.HorizontalAlign, htmlGrid.Text.VerticalAlign,   ...
                                                                                                 comp.FontFamily,               comp.tFontWeight,              ...
                                                                                                 comp.tFontSize,                comp.tFontColor,               ...
                                                                                                 comp.dFontSize,                comp.dFontColor);
        end


        function htmlRGB = htmlRGBColor(comp, Type, BackgroundColor)
            HSL = ccTools.fcn.rgb2hsl(BackgroundColor);
            switch Type
                case 'hover'  % down S component (10%) and up L component (10%)
                    HSL(2) = HSL(2)-.1; HSL(2) = max([0, HSL(2)]);
                    HSL(3) = HSL(3)+.1; HSL(3) = min([1, HSL(3)]);
                case 'active' % down L component (10%)
                    HSL(3) = HSL(3)-.1; HSL(3) = max([0, HSL(3)]);
            end
            RGB = ccTools.fcn.hsl2rgb(HSL);
            htmlRGB = sprintf('rgb(%d, %d, %d)', RGB(1), RGB(2), RGB(3));
        end


        function htmlBody = htmlBodyTemplate(comp)
            editedText        = replace(comp.Text,    '|', '<br>');
            editedDescription = replace(comp.Description, '|', '<br>');

            switch comp.Model
                case {'IconPlusText', 'Icon'}
                    [imgFormat, imgBase64] = ccTools.fcn.img2base64(comp.Icon);
                    htmlIcon = htmlBodyTemplate_Aux(comp, 'Icon', {imgFormat, imgBase64});
    
                    switch comp.Model
                        case 'IconPlusText'
                            htmlText = htmlBodyTemplate_Aux(comp, 'Text', {editedText, editedDescription});
                            if ismember(comp.IconAlignment, {'top', 'left'}); htmlBody = strjoin({htmlIcon, htmlText}, '\n');
                            else;                                             htmlBody = strjoin({htmlText, htmlIcon}, '\n'); % 'bottom' | 'right'
                            end    
                        otherwise
                            htmlBody = htmlIcon;
                    end

                case 'Text'
                    htmlBody = htmlBodyTemplate_Aux(comp, 'Text', {editedText, editedDescription});
            end
        end


        function htmlTemplate = htmlBodyTemplate_Aux(comp, Type, Parameters)
            switch Type
                case 'Icon'; htmlTemplate = sprintf('\t\t\t<div class="Image"><img src="data:image/%s;base64,%s"></div>',                               Parameters{1}, Parameters{2});
                case 'Text'; htmlTemplate = sprintf('\t\t\t<div class="Text">%s<br class="TextRowSpacing"><span class="Description">%s</span></div>\n', Parameters{1}, Parameters{2});
            end
        end


        function htmlScript = htmlScriptTemplate(comp)
            htmlScript = fileread(fullfile(comp.pathToMFILE, 'css&js', 'ccButton.js'));
        end
    end
end