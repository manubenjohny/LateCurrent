function varargout = SCLate(varargin)

if nargin==0
    InitializeGUI;
elseif ischar(varargin{1}) % INVOKE NAMED SUBFUNCTION OR CALLBACK
    try
        if (nargout)
            [varargout{1:nargout}] = feval(varargin{:}); % FEVAL switchyard
        else
            feval(varargin{:}); % FEVAL switchyard
        end
    catch
        rethrow(lasterror);
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% InitializeGUI
    function InitializeGUI

        clear global SCSTEPLATE;
        global SCSTEPLATE;
        
        % set up params
        SCSTEPLATE.Unitary.UniSet = false;
    
        newfile
        filename = SCSTEPLATE.datafile;
        SCSTEPLATE.MBJHack.TempList  = [];
        
        %Size constants (in normalized units)
        LH = 0.035;  %height per line
        S  = 0.005;  %spacer
        ST = 0.005;
        SS = 0.02;
        AxW = 1;  % 0.8
        BW  = .08;  %(1-AxW)/3
        AxB = 0.2;
        AH2 = 0.1;
        
        %make the figure window
        fig = figure( 'Name', ['SCSTEPLATE - ' filename],...
            'NumberTitle', 'off', ...
            'HandleVisibility', 'on', ...
            'IntegerHandle', 'on', ...
            'units', 'normalized', ...
            'Position', [.1 .1 .8 .8], ...
            'UserData', zeros(4,30), ... 
            'KeyPressFcn', @KeyPresser, ...
            'color', [1 1 1]);			

        %make the menus
        uimenu(fig, 'label', '>>');
        ToolMenu = uimenu(fig, 'label', 'SCSTools');
        SCSTEPLATE.FreezeX = [];
        SCSTEPLATE.FreezeY = [];
        SCSTEPLATE.DisplayGrid = [];
        uimenu(ToolMenu, 'Label', 'Zoom X...',  'Callback', 'SCLate(''Zoom_Callback'',1,0)', 'separator', 'off');
        uimenu(ToolMenu, 'Label', 'Zoom Y...',  'Callback', 'SCLate(''Zoom_Callback'',0,1)', 'separator', 'off');
        uimenu(ToolMenu, 'Label', 'Zoom XY...',  'Callback', 'SCLate(''Zoom_Callback'',1,1)', 'separator', 'off');
        uimenu(ToolMenu, 'Label', 'Select Pulse', 'Callback', 'SCLate(''SelectPulse'')', 'separator', 'off');
        uimenu(ToolMenu, 'Label', 'lateZoom', 'Callback', 'SCLate(''lateZoom'')', 'separator', 'off');
        uimenu(ToolMenu, 'Label', 'peakZoom', 'Callback', 'SCLate(''peakZoom'')', 'separator', 'off');
        
        SCSTEPLATE.MenuFreezeX = uimenu(ToolMenu, 'Label', 'FreezeX', 'Callback', 'SCLate(''Menu_FreezeX'')', 'checked', 'off', 'separator', 'on');
        SCSTEPLATE.MenuFreezeY = uimenu(ToolMenu, 'Label', 'FreezeY', 'Callback', 'SCLate(''Menu_FreezeY'')', 'checked', 'off');
        uimenu(ToolMenu, 'Label', 'FreezeXY', 'Callback', 'SCLate(''Menu_FreezeXY'')', 'checked', 'off');
        SCSTEPLATE.DisplayGrid = uimenu(ToolMenu, 'Label', 'DisplayGrid', 'Callback', 'SCLate(''Menu_DisplayGrid'')','checked', 'off', 'separator', 'on');
        uimenu(ToolMenu, 'Label', 'UnselectBadSweeps', 'Callback', 'SCLate(''Menu_UnselectBadSweeps'')', 'separator', 'on');
        uimenu(ToolMenu, 'Label', 'UnselectBlankSweeps', 'Callback', 'SCLate(''Menu_UnselectBlankSweeps'')', 'separator', 'on');
        uimenu(ToolMenu, 'Label', 'UnselectRamps', 'Callback', 'SCLate(''Menu_UnselectRamps'')', 'separator', 'off');
        uimenu(ToolMenu, 'Label', 'CopySweepsToClipboard', 'Callback', 'SCLate(''CopySweepsToClipboard'')', 'separator', 'on');
        SCSTEPLATE.DG = [];
        
        FitMenu = uimenu(fig, 'label', 'FitTools');
        uimenu(FitMenu, 'Label', 'AdjSwOffset', 'Callback', 'SCLate(''Menu_AdjSwOffset'')', 'separator', 'off');
        uimenu(FitMenu, 'Label', 'AdjLkOffset', 'Callback', 'SCLate(''Menu_AdjLkOffset'')', 'separator', 'off');
        uimenu(FitMenu, 'Label', 'CopyFit', 'Callback', 'SCLate(''Menu_CopyFit'')', 'separator', 'on');
        uimenu(FitMenu, 'Label', 'PasteFit', 'Callback', 'SCLate(''Menu_PasteFit'')', 'separator', 'of');
        uimenu(FitMenu, 'Label', 'ResetFit', 'Callback', 'SCLate(''Menu_ResetFit'')', 'separator', 'on');
        uimenu(FitMenu, 'Label', 'ResetAtool', 'Callback', 'SCLate(''Menu_ResetAtool'')', 'separator', 'off');
           
        %Axes
        SCSTEPLATE.AxI = axes('Units', 'normalized', 'FontSize', 7, 'Position', [S+SS S+SS+AxB AxW-2*S-SS 1-3*S-SS-AxB]);               
   
        %General Buttons
        RP = [2 1];
        SF = 0.48;
        %legacy params
        %Selectable protocols and information
        RP = [1 1];
        MakeButtonGroup('FirstLatency',      [S+(RP(2)-1)*BW AxB-RP(1)*LH  SF*BW  LH-S]);
        MakeButtonGroup('CalcPoo',      [S+(RP(2)-1)*BW+0.5*BW   AxB-RP(1)*LH  SF*BW  LH-S]);
        RP = [1 2];
        SCSTEPLATE.VStep     = MakeTextEditGroup('VStep',     'left', 'left', [S+(RP(2)-1)*BW  AxB-RP(1)*LH  .3*BW-0.5*S  LH-S-ST], [S+(RP(2)-1)*BW+0.3*BW  AxB-RP(1)*LH  0.7*BW-S  LH-S]);
        
        %General Buttons
        RP = [2 1];
        SF = 0.48;
        %MakeButtonGroup('AutoExpFit',      [S+(RP(2)-1)*BW AxB-RP(1)*LH  SF*BW  LH-S]);
        MakeButtonGroup('Export',     [S+(RP(2)-1)*BW AxB-RP(1)*LH  .5*BW  LH-S]);
        %MakeButtonGroup('AmpHist',     [S+(RP(2)-1)*BW AxB-RP(1)*LH  .5*BW  LH-S]);
        %MakeButtonGroup('TempList',     [S+(RP(2)-1)*BW+0.5*BW   AxB-RP(1)*LH  .5*BW  LH-S]);
        MakeButtonGroup('Atool',      [S+(RP(2)-1)*BW+0.5*BW   AxB-RP(1)*LH  SF*BW  LH-S]);
        
        RP = [2 2];
 
        MakeButtonGroup('GoodBad',      [S+(RP(2)-1)*BW AxB-RP(1)*LH  SF*BW  LH-S]);
        MakeButtonGroup('FinalFit',      [S+(RP(2)-1)*BW+0.5*BW   AxB-RP(1)*LH  SF*BW  LH-S]);
       
        RP = [2 3];
        MakeButtonGroup('iAmpHist',      [S+(RP(2)-1)*BW AxB-RP(1)*LH  SF*BW  LH-S]);
        MakeButtonGroup('setupUnitary',      [S+(RP(2)-1)*BW+0.5*BW   AxB-RP(1)*LH  SF*BW  LH-S]);
       
        RP = [2 4];
        MakeButtonGroup('CopyAverage',      [S+(RP(2)-1)*BW AxB-RP(1)*LH  SF*BW  LH-S]);
        MakeButtonGroup('ComputeLateCurrent',      [S+(RP(2)-1)*BW+0.5*BW   AxB-RP(1)*LH  SF*BW  LH-S]);
       
        RP = [3 1];
        MakeButtonGroup('MeanVar',      [S+(RP(2)-1)*BW AxB-RP(1)*LH  SF*BW  LH-S]);
        %MakeButtonGroup('AmpHist',      [S+(RP(2)-1)*BW+0.5*BW   AxB-RP(1)*LH  SF*BW  LH-S]);
        %MakeButtonGroup('openTime',      [S+(RP(2)-1)*BW+0.5*BW   AxB-RP(1)*LH  SF*BW  LH-S]);
        MakeButtonGroup('numOpenings',      [S+(RP(2)-1)*BW+0.5*BW   AxB-RP(1)*LH  SF*BW  LH-S]);
        %MakeButtonGroup('ComputePo',      [S+(RP(2)-1)*BW+0.5*BW   AxB-RP(1)*LH  SF*BW  LH-S]);
        RP = [3 2];
        MakeButtonGroup('BinoFit',      [S+(RP(2)-1)*BW AxB-RP(1)*LH  SF*BW  LH-S]);
        MakeButtonGroup('ComputePo',      [S+(RP(2)-1)*BW+0.5*BW   AxB-RP(1)*LH  SF*BW  LH-S]);
        %MakeButtonGroup('FirstLatency',      [S+(RP(2)-1)*BW+0.5*BW   AxB-RP(1)*LH  SF*BW  LH-S]);
        %Parameters for autoexpfit
        RP = [4 1];
        SCSTEPLATE.FitToUse    = MakeTextEditGroup('FitForAnalysis',    'left', 'left', [S+(RP(2)-1)*BW  AxB-RP(1)*LH  .6*BW-0.5*S  LH-S-ST], [S+(RP(2)-1)*BW+0.6*BW  AxB-RP(1)*LH  0.4*BW-S  LH-S]);
        set(SCSTEPLATE.FitToUse.Edit, 'value', 0, 'string', 'AutoFit');
        RP = [4 2];
        SCSTEPLATE.Lambda    = MakeTextEditGroup('lambda',    'left', 'left', [S+(RP(2)-1)*BW  AxB-RP(1)*LH  .6*BW-0.5*S  LH-S-ST], [S+(RP(2)-1)*BW+0.6*BW  AxB-RP(1)*LH  0.4*BW-S  LH-S]);
        set(SCSTEPLATE.Lambda.Edit, 'value', 0.25, 'string', 0.25);
        %SCSTEPLATE.AutoFitThres  = MakeTextEditGroup('AutoFitThres',  'left', 'left', [S+(RP(2)-1)*BW  AxB-RP(1)*LH  .6*BW-0.5*S  LH-S-ST], [S+(RP(2)-1)*BW+0.6*BW  AxB-RP(1)*LH  0.4*BW-S  LH-S]);
        %set(SCSTEPLATE.AutoFitThres.Edit, 'value', 0, 'string', 0);
        RP = [5 1];     
        SCSTEPLATE.AutoFitAtoolWind = MakeTextEditGroup('AtoolWindow',  'left', 'left', [S+(RP(2)-1)*BW  AxB-RP(1)*LH  .6*BW-0.5*S  LH-S-ST], [S+(RP(2)-1)*BW+0.6*BW  AxB-RP(1)*LH  0.4*BW-S  LH-S]);
        set(SCSTEPLATE.AutoFitAtoolWind.Edit, 'value', 10, 'string', 10);
        RP = [5 2];     
        SCSTEPLATE.AutoFitOffset  = MakeTextEditGroup('AutoFitOffset',  'left', 'left', [S+(RP(2)-1)*BW  AxB-RP(1)*LH  .6*BW-0.5*S  LH-S-ST], [S+(RP(2)-1)*BW+0.6*BW  AxB-RP(1)*LH  0.4*BW-S  LH-S]);
        set(SCSTEPLATE.AutoFitOffset.Edit, 'value', 0, 'string', 0);
        %Sweep parameters
        RP = [1 3];
        %SCSTEPLATE.CellNum  = MakeTextEditGroup('NumCell',  'left', 'left', [S+(RP(2)-1)*BW  AxB-RP(1)*LH  .6*BW-0.5*S  LH-S-ST], [S+(RP(2)-1)*BW+0.6*BW  AxB-RP(1)*LH  0.4*BW-S  LH-S]);
        SF = 0.48;
        MakeButtonGroup('SaveFit',      [S+(RP(2)-1)*BW AxB-RP(1)*LH  SF*BW  LH-S]);
        MakeButtonGroup('EditParam',      [S+(RP(2)-1)*BW+0.5*BW   AxB-RP(1)*LH  SF*BW  LH-S]);

        RP = [1 4];       
        SCSTEPLATE.NumCh  = MakeTextEditGroup('NumCh',  'left', 'left', [S+(RP(2)-1)*BW  AxB-RP(1)*LH  .6*BW-0.5*S  LH-S-ST], [S+(RP(2)-1)*BW+0.6*BW  AxB-RP(1)*LH  0.4*BW-S  LH-S]);
        
        RP = [3 3];
        sf = 0.5;
        SCSTEPLATE.DispAutoFit = MakeCheckBox('DisAuto', [S+(RP(2)-1)*BW AxB-RP(1)*LH  sf*BW-0.5*S  LH-S] , 0);
        SCSTEPLATE.DispManFit = MakeCheckBox('DisMan',[S+(RP(2)-1)*BW+sf*BW AxB-RP(1)*LH  sf*BW-0.5*S  LH-S], 0);
        SCSTEPLATE.DispLk = MakeCheckBox('DisLk', [S+(RP(2)-1)*BW+2*sf*BW AxB-RP(1)*LH  sf*BW-0.5*S  LH-S], 0);
        SCSTEPLATE.DispData = MakeCheckBox('DisData', [S+(RP(2)-1)*BW+3*sf*BW AxB-RP(1)*LH  sf*BW-0.5*S  LH-S], 1); 
        RP = [4 3];
        SCSTEPLATE.AutoManual = MakeDropDownGroup('Use auto fit|Use manual fit', 'left', [S+(RP(2)-1)*BW  AxB-RP(1)*LH  (.3*BW-0.5*S + 0.75*BW-S)  LH-S-ST]);
        RP = [4 4];
        %SCSTEPLATE.SmoothLk = MakeCheckBox('SmoothLk', [S+(RP(2)-1)*BW AxB-RP(1)*LH  BW  LH-S], 0);
        SCSTEPLATE.SmoothLk = MakeCheckBox('SmLk', [S+(RP(2)-1)*BW AxB-RP(1)*LH  sf*BW-0.5*S  LH-S] , 0);
        SCSTEPLATE.FinalLk = MakeCheckBox('FinalLk',[S+(RP(2)-1)*BW+sf*BW AxB-RP(1)*LH  sf*BW-0.5*S  LH-S], 0);

        RP = [5 3];  
        SCSTEPLATE.AutoFitLk = MakeCheckBox('AutoFitLk', [S+(RP(2)-1)*BW AxB-RP(1)*LH  BW  LH-S], 0);
        RP = [5 4];      
        SCSTEPLATE.NoUpdate = MakeCheckBox('NoGraphUpdate', [S+(RP(2)-1)*BW AxB-RP(1)*LH  BW  LH-S], 0);

        %Sweep-level parameters  
        SF = 6;
        RP = [1 5];        
        SCSTEPLATE.XMin    = MakeTextEditGroup('XMin',    'left', 'left', [S+(RP(2)-1)*BW  AxB-RP(1)*LH  .5*BW-0.5*S  LH-S-ST], [S+(RP(2)-1)*BW+0.5*BW  AxB-RP(1)*LH  0.5*BW+SF*BW-S  LH-S]);
        RP = [2 5];        
        SCSTEPLATE.XMax    = MakeTextEditGroup('XMax',    'left', 'left', [S+(RP(2)-1)*BW  AxB-RP(1)*LH  .5*BW-0.5*S  LH-S-ST], [S+(RP(2)-1)*BW+0.5*BW  AxB-RP(1)*LH  0.5*BW+SF*BW-S  LH-S]);
        RP = [3 5];        
        SCSTEPLATE.Tau    = MakeTextEditGroup('Tau',    'left', 'left', [S+(RP(2)-1)*BW  AxB-RP(1)*LH  .5*BW-0.5*S  LH-S-ST], [S+(RP(2)-1)*BW+0.5*BW  AxB-RP(1)*LH  0.5*BW+SF*BW-S  LH-S]);
        RP = [4 5];        
        SCSTEPLATE.Amp    = MakeTextEditGroup('Amp',    'left', 'left', [S+(RP(2)-1)*BW  AxB-RP(1)*LH  .5*BW-0.5*S  LH-S-ST], [S+(RP(2)-1)*BW+0.5*BW  AxB-RP(1)*LH  0.5*BW+SF*BW-S  LH-S]);
        RP = [5 5];        
        SCSTEPLATE.Delay    = MakeTextEditGroup('Delay',    'left', 'left', [S+(RP(2)-1)*BW  AxB-RP(1)*LH  .5*BW-0.5*S  LH-S-ST], [S+(RP(2)-1)*BW+0.5*BW  AxB-RP(1)*LH  0.5*BW+SF*BW-S  LH-S]);
        %Listbox        
        RP = [1 12];                        
        SCSTEPLATE.Box = uicontrol('Style', 'Listbox', 'String', '', 'Callback', 'SCLate(''UpdateGraphics'')', 'units', 'normalized', 'Position', [S+(RP(2)-1)*BW S 1.4*BW AxB], 'backgroundcolor', [1 1 1], 'Max', 2);

        UpdateBox;
        
        
        function KeyPresser(varargin)
            global SCSTEPLATE
            KeyVal = varargin{2};            
            if isempty(KeyVal.Modifier)
                KeyNum = str2double(KeyVal.Key);
                if ~isempty(KeyNum) && ~isnan(KeyNum)
                    SelectPulseNum(KeyNum)
                else
                    switch KeyVal.Key
                        case 'uparrow'
                            nSel = get(SCSTEPLATE.Box, 'value');
                            if nSel>1
                                set(SCSTEPLATE.Box, 'value',nSel-1)
                                UpdateGraphics
                            end                            
                        case 'downarrow'
                            nSel = get(SCSTEPLATE.Box, 'value');
                            NumSelections = length(get(SCSTEPLATE.Box,'string'));
                            if nSel<NumSelections
                                set(SCSTEPLATE.Box,'value', nSel+1)
                                UpdateGraphics
                            end
                        case 'e'
                                AutoExpFit(0, 0);
                        case 'r'
                                AutoExpFit(1, 0);
                        case 'w'
                                AutoExpFit(1, 1);
                        case 'p'
                                SCLate('peakZoom');                                
                        case 'l'
                                SCLate('lateZoom');
                    end
                    
                end                
                
            else
                Modifier = KeyVal.Modifier;
                switch Modifier{1}
                    case 'control'
                        switch KeyVal.Key
                            case 'c'
                                Menu_CopyFit        
                                disp('Copied Fit')
                            case 'v'
                                Menu_PasteFit
                                disp('Paste Fit')
                        end                            
                end
            end
           
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function S = MakeDropDownGroup(UIGroupName, AlignText, PosTxt)
            %Callback strings are generic
            S = uicontrol('Style', 'popup', 'String', UIGroupName, 'HorizontalAlignment', AlignText, 'units', 'normalized', 'Position', PosTxt, 'Callback', ['SCLate(''Edit_Callback'',''' UIGroupName ''')']);  
            
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%                
        function S = MakeTextEditGroup(UIGroupName, AlignText, AlignEdit, PosTxt, PosBox)
            %Callback strings are generic
            S.Text = uicontrol('Style', 'text', 'String', UIGroupName, 'HorizontalAlignment', AlignText, 'units', 'normalized', 'Position', PosTxt);
            S.Edit = uicontrol('Style', 'edit', 'String', '', 'BackgroundColor', [1 1 1], 'Callback', ['SCLate(''Edit_Callback'',''' UIGroupName ''')'], 'HorizontalAlignment', AlignEdit, 'units', 'normalized', 'Position', PosBox);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function S = MakeButtonGroup(ButtonName, Pos)
            S = uicontrol('Style', 'pushbutton', 'String', ButtonName, 'Callback', ['SCLate(''' ButtonName ''')'], 'HorizontalAlignment', 'left', 'units', 'normalized', 'Position', Pos);
            
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function S = MakeCheckBox(ButtonName, Pos, val)
            S = uicontrol('Style', 'check', 'String', ButtonName, 'Callback', 'SCLate(''UpdateGraphics'')', 'HorizontalAlignment', 'center',....
                'units', 'normalized', 'Position', Pos, 'value', val);
            
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%      
   %% Edit Callback

        function Edit_Callback(UIGroupName)
            global SCSTEPLATE

            switch UIGroupName

                %Non-edit parameters read in from data file
               case {'CellNum', 'Construct', 'RI', 'VStep', 'lambda', 'AutoFitThres', 'AtoolWindow', 'Family Step|Step|Ramp', 'FitToUse', 'Use auto fit|Use manual fit'}
                    UpdateGraphics;
                    set(gcf, 'pointer', 'arrow');
               
               case {'UniCurrent'}
                    
                   
               %cell level parameters identical for all runs within a cell
               case {'NumCh' 'g' 'Vs'}
                    set(gcf, 'pointer', 'watch'); drawnow;
                    nSel = get(SCSTEPLATE.Box, 'value');
                    for k=1:length(nSel);
                    DATA = LoadData(SCSTEPLATE.datafile, SCSTEPLATE.RunSwp{(nSel(k))});
                    CellNumString = ['Cell',num2str(DATA(1).DBParams.CellNum),'']; %note that loaddata already puts in the run, swp num
                    S.(CellNumString).NumCh = str2num(get(SCSTEPLATE.NumCh.Edit, 'string'));
                    S.(CellNumString).g = str2num(get(SCSTEPLATE.g.Edit, 'string'));
                    %S.(CellNumString).Vs = str2num(get(SCSTEPLATE.Vs.Edit, 'string'));
                    SCSTEPLATE.Vs.Edit = 0;
                    save(SCSTEPLATE.AnalysisFile, '-struct', 'S', '-append');
                    end
                    UpdateGraphics;
                    set(gcf, 'pointer', 'arrow');

               % sweep level parameters - editable for each sweep
                case {'FiltHz'} % note, anything that may be empty or a matrix must use str2num not str2double to avoid NaN being retured
                    set(gcf, 'pointer', 'watch'); drawnow;
                    nSel = get(SCSTEPLATE.Box, 'value');
                    for k=1:length(nSel)
                    ANALYSIS = load(SCSTEPLATE.AnalysisFile, '-mat');
                    S.(SCSTEPLATE.RunSwp{(nSel(k))})= ANALYSIS.(SCSTEPLATE.RunSwp{nSel(k)});
                    S.(SCSTEPLATE.RunSwp{(nSel(k))}).FiltHz = str2num(get(SCSTEPLATE.FiltHz.Edit, 'string'));                  
                    save(SCSTEPLATE.AnalysisFile, '-struct', 'S', '-append');
                    end
                     UpdateGraphics;
                     set(gcf, 'pointer', 'arrow');
                case {'Tau', 'Amp', 'XMax','XMin', 'm', 'b','Delay'} % note, anything that may be empty or a matrix must use str2num not str2double to avoid NaN being retured
                    set(gcf, 'pointer', 'watch'); drawnow;
                    nSel = get(SCSTEPLATE.Box, 'value');
                    for k = 1:length(nSel);
                        ANALYSIS = load(SCSTEPLATE.AnalysisFile, '-mat');
                        S.(SCSTEPLATE.RunSwp{(nSel(k))})= ANALYSIS.(SCSTEPLATE.RunSwp{nSel(k)});
                        S.(SCSTEPLATE.RunSwp{(nSel(k))}).Amp = str2num(get(SCSTEPLATE.Amp.Edit, 'string'));
                        S.(SCSTEPLATE.RunSwp{(nSel(k))}).Tau = str2num(get(SCSTEPLATE.Tau.Edit, 'string'));
                        S.(SCSTEPLATE.RunSwp{(nSel(k))}).XMax = str2num(get(SCSTEPLATE.XMax.Edit, 'string'));
                        S.(SCSTEPLATE.RunSwp{(nSel(k))}).XMin = str2num(get(SCSTEPLATE.XMin.Edit, 'string'));
                        S.(SCSTEPLATE.RunSwp{(nSel(k))}).Delay = str2num(get(SCSTEPLATE.Delay.Edit, 'string'));
                        save(SCSTEPLATE.AnalysisFile, '-struct', 'S', '-append');
                        % BK Edit 08/13/2014
                        % After each change a new leak fit is calculated and
                        % stored into SCSTEPLATE.FitData.ManualFit
                        swANALYSIS = ANALYSIS.(SCSTEPLATE.RunSwp{nSel(k)});
                        AMin = swANALYSIS.AMin;
                        AMax = swANALYSIS.AMax;
                        updateManualFitMatrix(nSel(k), S.(SCSTEPLATE.RunSwp{(nSel(k))}).Amp, S.(SCSTEPLATE.RunSwp{(nSel(k))}).Tau, ...
                            S.(SCSTEPLATE.RunSwp{(nSel(k))}).XMax,  S.(SCSTEPLATE.RunSwp{(nSel(k))}).XMin, ...
                            S.(SCSTEPLATE.RunSwp{(nSel(k))}).Delay, AMin, AMax);
                        
                    end
                    UpdateGraphics;
                    set(gcf, 'pointer', 'arrow');
                case {'AutoFitOffset'}
                    % BK revision 08/14/2014 
                    % add an autofitoffset so auto fit can be adjusted by a
                    % dc change
                    nSel = get(SCSTEPLATE.Box, 'value');
                    for k = 1:length(nSel)
                        % store current offset number
                        prevOffset = get(SCSTEPLATE.AutoFitOffset.Edit, 'value');
                        set(SCSTEPLATE.AutoFitOffset.Edit, 'value', str2num(get(SCSTEPLATE.AutoFitOffset.Edit, 'string')));
                        offset = get(SCSTEPLATE.AutoFitOffset.Edit, 'value');

                        %find out when to change the offset
                        DATA = LoadData(SCSTEPLATE.datafile, SCSTEPLATE.RunSwp{k});
                        input = DATA(1).StimWaveform;
                        idx_start = find( (diff(input) ~= 0) ) + 1;
                        wind = get(SCSTEPLATE.AutoFitAtoolWind.Edit, 'value');
                        idx_exact = idx_start + (0:wind);        
                        idx_s = idx_exact(end);
                        % take off the previous offset and add the new one
                        SCSTEPLATE.FitData.AutoFitOffset(nSel(k)) = offset;
                        SCSTEPLATE.FitData.AutoFit(idx_s:end, nSel(k)) = SCSTEPLATE.FitData.AutoFit(idx_s:end, nSel) + offset - prevOffset;
                    end
                    UpdateGraphics;
                case {'Good|Bad'}
                    set(gcf, 'pointer', 'watch'); drawnow;
                    nSel = get(SCSTEPLATE.Box, 'value');
                    indicator = -1;
                    switch get(SCSTEPLATE.GBInd, 'value')
                        case 1 %set to good
                            indicator = 1;
                        case 2 %set to bad
                            indicator = 0;
                        otherwise
                            disp('Invalid selection in good/bad');
                            indicator = 1;
                    end

                    for k=1:length(nSel)
                        ANALYSIS = load(SCSTEPLATE.AnalysisFile, '-mat');
                        S.(SCSTEPLATE.RunSwp{(nSel(k))})= ANALYSIS.(SCSTEPLATE.RunSwp{nSel(k)});
                        S.(SCSTEPLATE.RunSwp{(nSel(k))}).GoodBad = indicator;
                        % BK Edit 08/14/2014
                        % Use a global GoodBad vector instead of saving
                        SCSTEPLATE.FitData.GoodBad(nSel(k)) = indicator;

                    end
                    save(SCSTEPLATE.AnalysisFile, '-struct', 'S', '-append');
                    set(gcf, 'pointer', 'arrow');
                    UpdateGraphics;
                otherwise
                    waitfor(errordlg(['There is a bug in the code -- need to write Edit_Callback routine for ' UIGroupName]));
            end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %% Update manual fit function
        function updateManualFitMatrix(k, Amp, Tau, XMax, XMin, Delay, AMin, AMax)

            % BK 08/13/2014
            % function to calculate leak waveform and store
            global SCSTEPLATE;

            t = SCSTEPLATE.FitData.Time; %time vector
            iRaw = SCSTEPLATE.FitData.RawData(:, k);
            manualFitLeak = zeros(length(t), 1);

            %calculate waveform
            try
               for n = 1:length(XMin)
                   ilk = Amp(n)*exp(-(Tau(n))*(t-Delay(n)));
                   ilk(t < Delay(n)) = 0;
                   ilk(t<XMin(n))=0;
                   ilk(t>XMax(n))=0;
                   manualFitLeak = manualFitLeak + ilk;
               end
            end
            try
                    for n=1:(length(AMin));
                        alk = iRaw-manualFitLeak;
                        alk(t<AMin(n))=0;
                        alk(t>AMax(n))=0;
                        manualFitLeak = manualFitLeak + alk;
                    end
            end   
            %store into matrix
            SCSTEPLATE.FitData.ManualFit(:, k) = manualFitLeak;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                

%% Tool Menu Functions

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            function SelectPulse
                global SCSTEPLATE
                nSel = get(SCSTEPLATE.Box, 'value');
                DATA = LoadData(SCSTEPLATE.datafile, SCSTEPLATE.RunSwp{nSel(1)});
                if strfind(DATA(1).StimName, 'Step')                    
                    StimParameters = DATA.StimParams;
                    DStep  = StimParameters.Dstep;                    
                    NumPulses = length(DStep);                                       
                    PNum = listdlg('PromptString', 'Select Pulse', 'SelectionMode', 'single', 'ListString', num2str([1:NumPulses]'));                    
                    SelectPulseNum(PNum)
                end
                
            function lateZoom
                global SCSTEPLATE
                nSel = get(SCSTEPLATE.Box, 'value');
                nSel = nSel(find(SCSTEPLATE.FitData.GoodBad(nSel)));
                Data = SCSTEPLATE.FitData.RawData(:,nSel)-SCSTEPLATE.FitData.ManualFit(:,nSel);
                t = SCSTEPLATE.FitData.Time;
                mask = t>40;
                LIMIT(1) = 1.5*min(min(Data(mask,:))); 
                LIMIT(2) = 1.5*max(max(Data(mask,:)));
                set(SCSTEPLATE.AxI,'YLim',LIMIT);
                
                
            function peakZoom
                global SCSTEPLATE
                nSel = get(SCSTEPLATE.Box, 'value');
                nSel = nSel(find(SCSTEPLATE.FitData.GoodBad(nSel)));
                Data = SCSTEPLATE.FitData.RawData(:,nSel)-SCSTEPLATE.FitData.ManualFit(:,nSel);
                t = SCSTEPLATE.FitData.Time;
                mask = t<40;
                LIMIT(1) = 1.2*min(min(Data(mask,:))); 
                LIMIT(2) = 1.2*max(max(Data(mask,:)));
                set(SCSTEPLATE.AxI,'YLim',LIMIT);
                
                
            function SelectPulseNum(PNum)
                global SCSTEPLATE
                nSel = get(SCSTEPLATE.Box, 'value');
                DATA = LoadData(SCSTEPLATE.datafile, SCSTEPLATE.RunSwp{nSel(1)});
                if strfind(DATA(1).StimName, 'Step')                    
                    StimParameters = DATA.StimParams;
                    DStep  = StimParameters.Dstep;                    
                    NumPulses = length(DStep); 
                    if PNum<NumPulses+1
                        TBegin = cumsum([0 DStep]);
                        TEnd = cumsum(DStep);                    
                        MinX = max([0, TBegin(PNum)-15]);
                        MaxX = TEnd(PNum);
                        SCSTEPLATE.FreezeX = [MinX  MaxX];
                        set(SCSTEPLATE.MenuFreezeX, 'checked', 'on');                                        
                        UpdateGraphics
                    end
                end
                
                                
            function Zoom_Callback( bX, bY)
            global SCSTEPLATE;

            %now draw . .
            AxRect = DrawRectOnAx;

            %save values
            if bX
                SCSTEPLATE.FreezeX = [AxRect(1)  AxRect(1)+AxRect(3)];
                set(SCSTEPLATE.MenuFreezeX, 'checked', 'on');
            end
            if bY
                SCSTEPLATE.FreezeY = [AxRect(2)  AxRect(2)+AxRect(4)];
                set(SCSTEPLATE.MenuFreezeY, 'checked', 'on');
            end

            UpdateGraphics;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function Menu_FreezeX
            global SCSTEPLATE;

            if isempty(SCSTEPLATE.FreezeX)
                SCSTEPLATE.FreezeX = get(gca, 'xlim');
                set(SCSTEPLATE.MenuFreezeX, 'checked', 'on');
            else
                SCSTEPLATE.FreezeX = [];
                set(SCSTEPLATE.MenuFreezeX, 'checked', 'off');
            end
            
            UpdateGraphics;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function Menu_FreezeY
            global SCSTEPLATE;

            if isempty(SCSTEPLATE.FreezeY)
                SCSTEPLATE.FreezeY = get(gca, 'ylim');
                set(SCSTEPLATE.MenuFreezeY, 'checked', 'on');
            else
                SCSTEPLATE.FreezeY = [];
                set(SCSTEPLATE.MenuFreezeY, 'checked', 'off');
            end
            UpdateGraphics;
                
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function Menu_FreezeXY
            Menu_FreezeX;
            Menu_FreezeY;
            UpdateGraphics;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function Menu_DisplayGrid
            global SCSTEPLATE;

            if isempty(SCSTEPLATE.DG)
                set(gca, 'YGrid', 'on', 'XGrid','on')
                set(SCSTEPLATE.DisplayGrid, 'checked', 'on');
                SCSTEPLATE.DG = 1;
            else
                set(gca, 'YGrid', 'off', 'XGrid','off')
                set(SCSTEPLATE.DisplayGrid, 'checked', 'off');
                SCSTEPLATE.DG = [];
            end
            UpdateGraphics;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function Menu_UnselectBadSweeps
            global SCSTEPLATE;
            nSel = get(SCSTEPLATE.Box, 'value');

            for k=1:length(nSel)
                ANALYSIS = load(SCSTEPLATE.AnalysisFile, '-mat');
                swANALYSIS = ANALYSIS.(SCSTEPLATE.RunSwp{nSel(k)});
                Good(k) = [swANALYSIS.GoodBad];
            end

            nSel = nSel(Good==1);

            set(SCSTEPLATE.Box, 'value', nSel);
            UpdateGraphics;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function Menu_UnselectBlankSweeps
            global SCSTEPLATE;
            nSel = get(SCSTEPLATE.Box, 'value');

            for k=1:length(nSel)
                ANALYSIS = load(SCSTEPLATE.AnalysisFile, '-mat');
                swANALYSIS = ANALYSIS.(SCSTEPLATE.RunSwp{nSel(k)});
                Blank(k) = [swANALYSIS.Blank];
            end

            nSel = nSel(Blank==0);

            set(SCSTEPLATE.Box, 'value', nSel);
            UpdateGraphics;
            
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function Menu_UnselectRamps
            global SCSTEPLATE;
            nSel = get(SCSTEPLATE.Box, 'value');

            for k=1:length(nSel)
                DATA = LoadData(SCSTEPLATE.datafile, SCSTEPLATE.RunSwp{nSel(k)});
                %(findstr(DATA(1).StimName, 'Ramp'))
                if (findstr(DATA(1).StimName, 'Ramp'))
                Good(k) = 0;
                else
                    Good(k) = 1;
                end
            end

            nSel = nSel(Good==1);

            set(SCSTEPLATE.Box, 'value', nSel);
            UpdateGraphics;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
           
%% Fit Menu
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Menu_AdjLkOffset 
    %note that for leaks, b.c. offset is originally the avg of the 1st pts,
    %the leak offset must be used before mult by the scale factor

    global SCSTEPLATE;
    set(gcf,'Pointer','fullcross');
    nSel = get(SCSTEPLATE.Box, 'value');
    Message = text(.7, .9,'select zero', 'Units', 'normalized', 'FontSize', 18, 'Color', 'r');
        [x y] = ginput(1);
        delete(Message);
        SCSTEPLATE.lkOffset = SCSTEPLATE.lkOffset + y/SCSTEPLATE.SF;
        SaveSwParams;
        UpdateGraphics
                 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Menu_AdjSwOffset
    
    global SCSTEPLATE;
   
    set(gcf,'Pointer','fullcross');
    nSel = get(SCSTEPLATE.Box, 'value');
    
    Message = text(.7, .9,'select zero', 'Units', 'normalized', 'FontSize', 18, 'Color', 'r');

    [x y] = ginput(1);
    delete(Message);
    SCSTEPLATE.swOffset = SCSTEPLATE.swOffset + y;
    SaveSwParams;
    UpdateGraphics

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Menu_CopyFit
global SCSTEPLATE;

nSel = get(SCSTEPLATE.Box, 'value');
if length(nSel) > 1
    waitfor(errordlg('CopyFit can only be done if a single sweep is selected'));
    return;
end

%get leak data - don't take the offset data
    ANALYSIS = load(SCSTEPLATE.AnalysisFile, '-mat');
    swANALYSIS = ANALYSIS.(SCSTEPLATE.RunSwp{nSel});
    FitParams.Amp=swANALYSIS.Amp;
    FitParams.Tau=swANALYSIS.Tau;
    FitParams.XMin=swANALYSIS.XMin;
    FitParams.XMax=swANALYSIS.XMax;
    try
        FitParams.Delay=swANALYSIS.Delay;
    catch
    end
    FitParams.m=swANALYSIS.m;
    FitParams.b=swANALYSIS.b; 
    FitParams.AMin=swANALYSIS.AMin;
    FitParams.AMax=swANALYSIS.AMax;
                            
SCSTEPLATE.FitClipboard = FitParams;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Menu_PasteFit
global SCSTEPLATE;

set(gcf, 'pointer', 'watch'); drawnow;
nSel = get(SCSTEPLATE.Box, 'value'); 

ANALYSIS = load(SCSTEPLATE.AnalysisFile, '-mat');
    for k=1:length(nSel)     
        S.(SCSTEPLATE.RunSwp{(nSel(k))})= ANALYSIS.(SCSTEPLATE.RunSwp{nSel(k)});
        S.(SCSTEPLATE.RunSwp{(nSel(k))}).Amp = SCSTEPLATE.FitClipboard.Amp;
        S.(SCSTEPLATE.RunSwp{(nSel(k))}).Tau = SCSTEPLATE.FitClipboard.Tau;
        try
        S.(SCSTEPLATE.RunSwp{(nSel(k))}).Delay = SCSTEPLATE.FitClipboard.Delay;
        end
        S.(SCSTEPLATE.RunSwp{(nSel(k))}).XMax = SCSTEPLATE.FitClipboard.XMax;
        S.(SCSTEPLATE.RunSwp{(nSel(k))}).XMin = SCSTEPLATE.FitClipboard.XMin;
        S.(SCSTEPLATE.RunSwp{(nSel(k))}).m = SCSTEPLATE.FitClipboard.m;
        S.(SCSTEPLATE.RunSwp{(nSel(k))}).b = SCSTEPLATE.FitClipboard.b;
        S.(SCSTEPLATE.RunSwp{(nSel(k))}).AMin = SCSTEPLATE.FitClipboard.AMin;
        S.(SCSTEPLATE.RunSwp{(nSel(k))}).AMax = SCSTEPLATE.FitClipboard.AMax;
        % BK Edit 08/13/2014
        % After each change a new leak fit is calculated and
        % stored into SCSTEPLATE.FitData.ManualFit
        swANALYSIS = ANALYSIS.(SCSTEPLATE.RunSwp{nSel(k)});
        AMin = swANALYSIS.AMin;
        AMax = swANALYSIS.AMax;
        updateManualFitMatrix(nSel(k), S.(SCSTEPLATE.RunSwp{(nSel(k))}).Amp, S.(SCSTEPLATE.RunSwp{(nSel(k))}).Tau, ...
            S.(SCSTEPLATE.RunSwp{(nSel(k))}).XMax,  S.(SCSTEPLATE.RunSwp{(nSel(k))}).XMin, ...
            S.(SCSTEPLATE.RunSwp{(nSel(k))}).Delay, AMin, AMax);

    end
  save(SCSTEPLATE.AnalysisFile, '-struct', 'S', '-append');
UpdateGraphics;

set(gcf, 'pointer', 'arrow'); drawnow;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function Menu_ResetFit   % reset all exponential and linear coefficients to zero
global SCSTEPLATE;

set(gcf, 'pointer', 'watch'); drawnow;
nSel = get(SCSTEPLATE.Box, 'value');
  
ANALYSIS = load(SCSTEPLATE.AnalysisFile, '-mat');
  for k=1:length(nSel)
        S.(SCSTEPLATE.RunSwp{(nSel(k))})= ANALYSIS.(SCSTEPLATE.RunSwp{nSel(k)});
        S.(SCSTEPLATE.RunSwp{(nSel(k))}).Amp = [];
        S.(SCSTEPLATE.RunSwp{(nSel(k))}).Tau = [];
        S.(SCSTEPLATE.RunSwp{(nSel(k))}).Delay = [];
        S.(SCSTEPLATE.RunSwp{(nSel(k))}).XMax = [];
        S.(SCSTEPLATE.RunSwp{(nSel(k))}).XMin = [];
        S.(SCSTEPLATE.RunSwp{(nSel(k))}).m = [];
        S.(SCSTEPLATE.RunSwp{(nSel(k))}).b = [];
        S.(SCSTEPLATE.RunSwp{(nSel(k))}).AMin = [];
        S.(SCSTEPLATE.RunSwp{(nSel(k))}).AMax = [];           
    end
  save(SCSTEPLATE.AnalysisFile, '-struct', 'S', '-append');

UpdateGraphics;

set(gcf, 'pointer', 'arrow'); drawnow;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function Menu_ResetAtool
        global SCSTEPLATE;
        set(gcf, 'pointer', 'watch'); drawnow;
        nSel = get(SCSTEPLATE.Box, 'value');

        for k=1:length(nSel)
            ANALYSIS = load(SCSTEPLATE.AnalysisFile, '-mat');
            S.(SCSTEPLATE.RunSwp{(nSel(k))})= ANALYSIS.(SCSTEPLATE.RunSwp{nSel(k)});
            S.(SCSTEPLATE.RunSwp{(nSel(k))}).AMin = []; 
            S.(SCSTEPLATE.RunSwp{(nSel(k))}).AMax = []; 
            updateManualFitMatrix(nSel(k), str2num(get(SCSTEPLATE.Amp.Edit, 'string')), str2num(get(SCSTEPLATE.Tau.Edit, 'string')), ...
                str2num(get(SCSTEPLATE.XMax.Edit, 'string')),  str2num(get(SCSTEPLATE.XMin.Edit, 'string')), ...
                S.(SCSTEPLATE.RunSwp{(nSel(k))}).Delay, S.(SCSTEPLATE.RunSwp{(nSel(k))}).AMin, S.(SCSTEPLATE.RunSwp{(nSel(k))}).AMax);
        end
        save(SCSTEPLATE.AnalysisFile, '-struct', 'S', '-append');
        AutoExpFit(0, 0);
        set(gcf, 'pointer', 'arrow');
        UpdateGraphics;
                                
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Noise Analysis Functions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function MeanVar
        global SCSTEPLATE;
        % Separate the different data
        DATA = Export(2);
        numVt = length(fieldnames(DATA));
        
        % this part needs to be massively fixed to correctly identify
        % number of voltage pulses, right now this is basically unusable.

        % Determine if rundown is serious
        
        rundownPlot = figure; 
        for j = 1:numVt
            VString = ['TestVoltage' num2str(j)];
            vData = DATA.(VString);
            subplot(numVt, 1, j);
            plot(mean(vData), 'k-');
            title(['Average current of sweep vs sweep (' num2str(SCSTEPLATE.FitData.FamVoltage(j)) ')']);
        end
        % Get input from user
        prompt={'Enter Sweep Window Low:',...
            'Enter Sweep Window High:',...
            'Enter Time Window Low:',...
            'Enter Time Window High:',...
            'Enter Instrument Window Low:',...
            'Enter Instrument Window High:'};
        
        name='Parameters';
        numlines=1;
        
        % Update default answer from prev saved parameters
        defaultanswer = {num2str(SCSTEPLATE.DataAnalysisParams.SwpWind(1)), num2str(SCSTEPLATE.DataAnalysisParams.SwpWind(2)), ...
            num2str(SCSTEPLATE.DataAnalysisParams.TimeWind(1)), num2str(SCSTEPLATE.DataAnalysisParams.TimeWind(2)), ...
            num2str(SCSTEPLATE.DataAnalysisParams.InstruWind(1)), num2str(SCSTEPLATE.DataAnalysisParams.InstruWind(2))};
        
        %defaultanswer={'1', '200', '3.2', '20', '2.5', '3'};
        
        answer = inputdlg(prompt,name,numlines,defaultanswer);
%         SwpWind = [str2num(answer{1}) str2num(answer{2});...
%             str2num(answer{1}) str2num(answer{2});...
%             str2num(answer{1}) str2num(answer{2})];
        SwpWind = ones(numVt, 1) * [str2num(answer{1}) str2num(answer{2})]; 
        Twindow = [str2num(answer{3}) str2num(answer{4})];
        TwindowInstru = [str2num(answer{5}) str2num(answer{6})];
        
        % Update analysis param
        SCSTEPLATE.DataAnalysisParams.SwpWind = SwpWind(1,:);
        SCSTEPLATE.DataAnalysisParams.TimeWind = Twindow;
        SCSTEPLATE.DataAnalysisParams.InstruWind = TwindowInstru;
        
        for i = 1:size(SwpWind, 1)
            OutputString = ['TestVoltage' num2str(i)];
            SwpWind(i,2) = min(SwpWind(i,2), size(DATA.(OutputString),2));
        end
        t = SCSTEPLATE.FitData.Time;
        delete(rundownPlot);
        figure;
        Mask = (t>Twindow(1))& (t<Twindow(2));
        tNew = t(Mask);
        varianceInstru = zeros(1, numVt);
        meanVal = zeros(numVt, length(tNew));
        variance = zeros(numVt, length(tNew));
        for k = 1:numVt
           VString = ['TestVoltage' num2str(k)];
           % First apply the swpwind mask and instruments mask
           vData = DATA.(VString);
           vData = vData(:, SwpWind(k,1):SwpWind(k,2));
           InstruMask = (t>TwindowInstru(1))& (t<TwindowInstru(2));
           
           
           InstruDATA = reshape(vData(InstruMask, :),[],1);
           varianceInstru(k) = std(InstruDATA).^2;
           SubDATA = vData(Mask, :);
           variance(k, :) = std(SubDATA', 0, 1).^2 - varianceInstru(k);
           meanVal(k, :) = mean(SubDATA',1);
                   
           subplot(numVt, 3, 3*k-2);
           plot(tNew, meanVal(k, :), 'k-');
           xlim(Twindow);
           title(['Mean vs. Time (' num2str(SCSTEPLATE.FitData.FamVoltage(k)) 'mV)']);
           %ylim([max(meanVal) + 0.1*max(meanVal), min(meanVal) - 0.5*min(meanVal)]);
           
           subplot(numVt, 3, 3*k - 1);
           plot(tNew, variance(k, :), 'k-');
           title(['Variance vs. Time (' num2str(SCSTEPLATE.FitData.FamVoltage(k)) 'mV)']);
           xlim(Twindow);
           
           subplot(numVt, 3, 3*k);
           plot( meanVal(k, :), variance(k, :), 'k-');
           title(['Mean vs. Variance (' num2str(SCSTEPLATE.FitData.FamVoltage(k)) 'mV)']);
           xlim([min(meanVal(k, :)) + 0.5*min(meanVal(k, :)), 0]);
        end
        SCSTEPLATE.FitData.Mean = meanVal';
        SCSTEPLATE.FitData.Variance = variance';
%         FORMATTED_MATRIX = [-100   0  varianceInstru(1)  0   varianceInstru(2)   0   varianceInstru(3)];
%         FORMATTED_MATRIX = [FORMATTED_MATRIX; tNew meanVal(1,:)' variance(1,:)' meanVal(2,:)' variance(2,:)' meanVal(3,:)' variance(3,:)'];
        
        FM1 = -100;
        FM2 = tNew;
        for i = 1:numVt
            FM1 = [FM1, 0, varianceInstru(i)];
            FM2 = [FM2, meanVal(i, :)' , variance(i,:)'];
        end
        
        FORMATTED_MATRIX = [FM1; FM2];
        CopyToClipboard(FORMATTED_MATRIX, {},{});

    function AmpHist
        global SCSTEPLATE;
        % Separate the different data
        DATA = Export(1);
        numVt = length(fieldnames(DATA));

        % Get input from user
        prompt={'Enter Sweep Window Low:',...
            'Enter Sweep Window High:',...
            'Enter Time Window Low:',...
            'Enter Time Window High:',...
            'Enter Current Bin Low (pA):',...
            'Enter Current Bin High (pA):'};

        name='Parameters';
        numlines=1;
        
        % Update default answers
        defaultanswer = {num2str(SCSTEPLATE.DataAnalysisParams.SwpWind(1)), num2str(SCSTEPLATE.DataAnalysisParams.SwpWind(2)), ...
            num2str(SCSTEPLATE.DataAnalysisParams.TimeWind(1)), num2str(SCSTEPLATE.DataAnalysisParams.TimeWind(2)), ...
            num2str(SCSTEPLATE.DataAnalysisParams.AmpHistCurrentBin(1)), num2str(SCSTEPLATE.DataAnalysisParams.AmpHistCurrentBin(2))};

        
        %defaultanswer={'1', '200', '3.2', '20', '-10', '2'};
        answer = inputdlg(prompt,name,numlines,defaultanswer);
%         SwpWind = [str2num(answer{1}) str2num(answer{2});...
%             str2num(answer{1}) str2num(answer{2});...
%             str2num(answer{1}) str2num(answer{2})];
        SwpWind = ones(numVt, 1) * [str2num(answer{1}) str2num(answer{2})]; 
        Twindow = [str2num(answer{3}) str2num(answer{4})];
        I = (str2num(answer{5})):0.1:(str2num(answer{6}));
        for i = 1:size(SwpWind, 1)
            OutputString = ['TestVoltage' num2str(i)];
            SwpWind(i,2) = min(SwpWind(i,2), size(DATA.(OutputString),2));
        end
        
        % Update analysis param
        SCSTEPLATE.DataAnalysisParams.SwpWind = SwpWind(1,:);
        SCSTEPLATE.DataAnalysisParams.TimeWind = Twindow;
        SCSTEPLATE.DataAnalysisParams.AmpHistCurrentBin = [str2num(answer{5}) str2num(answer{6})];
        
        t = SCSTEPLATE.FitData.Time;
        Count = zeros(length(I), numVt);
        figure;
        for k = 1:numVt
           VString = ['TestVoltage' num2str(k)];
           % First apply the swpwind mask and instruments mask
           vData = DATA.(VString);
           vData = vData(:, SwpWind(k,1):SwpWind(k,2));
           Mask = (t>Twindow(1))& (t<Twindow(2));
           tNew = t(Mask);
           SubDATA = vData(Mask, :);
           SubDATA = SubDATA';
           SubDATA = reshape(SubDATA, [], 1);
           [Count(:,i), INew] = hist(SubDATA, I); 

           subplot(2, numVt, k);
           plot(t, vData, 'k-');
           xlim(Twindow);
           title(['All sweeps vs. Time (' num2str(SCSTEPLATE.FitData.FamVoltage(k)) 'mV)']);

           subplot(2, numVt, k+3);
           bar(I', Count(:,i), 1);
           title(['Amp Hist (' num2str(SCSTEPLATE.FitData.FamVoltage(k)) 'mV)']);
           xlim([min(I) max(I)])
        end
        
        FORMATTED_DATA = [];
        for i = 1:numVt
            FORMATTED_DATA = [FORMATTED_DATA I(end:-1:1)' Count(end:-1:1,i)  Count(end:-1:1,i)/sum(Count(:,i))];
        end
        CopyToClipboard(FORMATTED_DATA,{},{});

    function BinoFit
        global SCSTEPLATE;
        clc;
        DATA = Export(1);
        numVt = length(fieldnames(DATA));
        % Determine if rundown is serious
        
        % Get input from user
        prompt={'Enter Sweep Window Low:',...
            'Enter Sweep Window High:',...
            'Enter Time Window Low:',...
            'Enter Time Window High:',...
            'Enter Num Channel to Test Low:',...
            'Enter Num Channel to Test High:',...
            'Enter Start Time Window Low:',...
            'Enter Start Time Window High:', ...
            'Enter Unitary Current (sep. by spaces):'};
        
        name='Parameters';
        numlines=1;
        %defaultanswer={'1', '200', '3.2', '20', '1', '30', '3.2', '3.8', ''};
       
        % Update defaultanswer
        defaultanswer = {num2str(SCSTEPLATE.DataAnalysisParams.SwpWind(1)), num2str(SCSTEPLATE.DataAnalysisParams.SwpWind(2)), ...
            num2str(SCSTEPLATE.DataAnalysisParams.TimeWind(1)), num2str(SCSTEPLATE.DataAnalysisParams.TimeWind(2)), ...
            num2str(SCSTEPLATE.DataAnalysisParams.BinoFitChRange(1)), num2str(SCSTEPLATE.DataAnalysisParams.BinoFitChRange(2)), ...
            num2str(SCSTEPLATE.DataAnalysisParams.BinoFitStTime(1)), num2str(SCSTEPLATE.DataAnalysisParams.BinoFitStTime(2)), ...
            num2str(SCSTEPLATE.DataAnalysisParams.UnitaryCurrent)};

        
        answer = inputdlg(prompt,name,numlines,defaultanswer);
%         SwpWind = [str2num(answer{1}) str2num(answer{2});...
%             str2num(answer{1}) str2num(answer{2});...
%             str2num(answer{1}) str2num(answer{2})];
        SwpWind = ones(numVt, 1) * [str2num(answer{1}) str2num(answer{2})]; 
        Twindow = [str2num(answer{3}) str2num(answer{4})];
        NumCh = (str2num(answer{5})):(str2num(answer{6}));
        TwinStart = (str2num(answer{7})):0.1:(str2num(answer{8}));
        I = str2num(answer{9});
        disp('Fitting number of channels using binomial statistics...');

        % Check if unicurrent input is correct
        if length(I) ~= numVt
            waitfor(errordlg('Number of unitary current input does not match number of Vtest'));
            return;
        end
        
        % Update analysis param
        SCSTEPLATE.DataAnalysisParams.SwpWind = SwpWind(1,:);
        SCSTEPLATE.DataAnalysisParams.TimeWind = Twindow;
        SCSTEPLATE.DataAnalysisParams.BinoFitChRange = [NumCh(1) NumCh(end)];
        SCSTEPLATE.DataAnalysisParams.BinoFitStTime = [TwinStart(1) TwinStart(end)];
        SCSTEPLATE.DataAnalysisParams.UnitaryCurrent = I;

        Twindow(1) = TwinStart(1);
        Error = zeros(numVt, length(NumCh), length(TwinStart));
        numChEst = zeros(1, length(TwinStart));
        for i = 1:size(SwpWind, 1)
            OutputString = ['TestVoltage' num2str(i)];
            SwpWind(i,2) = min(SwpWind(i,2), size(DATA.(OutputString),2));
        end
        t = SCSTEPLATE.FitData.Time;

        figure;
        hold on;
        for j = 1:length(TwinStart)
            Twindow = [TwinStart(j) 20];
            ErrorTemp = zeros(3, length(NumCh));
            
            % Create the vectors
            for i = 1:length(NumCh)
                ErrorTemp(:,i) = ComputeStackingHistogram(DATA, SwpWind, Twindow, I, NumCh(i));
            end
            Error(:,:,j) = ErrorTemp;
            %plot(NumCh, Error(3,:,j), 'o-');
            plot(NumCh, sum(Error(:,:,j)), 'k.-', 'MarkerSize', 20);
            %plot(NumCh, sum(Error(2:3,:,j)), 'o-');

            minE_index = find(sum(Error(:,:,j)) == min(sum(Error(:,:,j))));
            %minE_index = find(sum(Error(2:3,:,j)) == min(sum(Error(2:3,:,j))));

            numChEst(j) = minE_index;
            
            plot(minE_index, sum(Error(:, minE_index, j)), '.', 'Color', 'r','MarkerSize', 20);
            %plot(minE_index, sum(Error(2:3, minE_index, j)), 'o', 'Color', 'r');
        end
        hold off;
        xlabel('Num Channel', 'FontSize', 12);
        ylabel('Sum of Error', 'FontSize', 12);
        set(gca, 'color', 'none');
        titlestr = ['Sum of Errors, Average NumCh Est: ' num2str(mean(numChEst))];
        title(titlestr);
        xlim([NumCh(1) NumCh(end)]);
        disp('Fitting Complete.');
        
    function FORMATTED_DATA = ComputeStackingHistogram(DATA, SwpWind, Twindow, UnitaryCurrent, NumChannels)
        global SCSTEPLATE;
        FORMATTED_DATA = [];
        numVt = length(fieldnames(DATA));
        t = SCSTEPLATE.FitData.Time;
        for i = 1:numVt
           VString = ['TestVoltage' num2str(i)];
           % First apply the swpwind mask and instruments mask
           vData = DATA.(VString);
           vData = vData(:, SwpWind(i,1):SwpWind(i,2));
           Mask = (t>Twindow(1))& (t<Twindow(2));
           tNew = t(Mask);
           SubData = vData(Mask, :);
           SubData= SubData';
           SubData = SubData.*(SubData<0);
           SubData = round(SubData/UnitaryCurrent(i));
           %Calculate histogram
           %NumMaxStacking = max(max(SubData));
           StackData = zeros(NumChannels + 1, size(SubData,2));
           for stackNum = 0:NumChannels
               tallyCount = sum(SubData == stackNum);
               StackData(stackNum + 1, :) = tallyCount;
           end

           StackDataProb = StackData ./ size(SubData,1);


           MeanCurrent = mean(SubData);
           PO = MeanCurrent/NumChannels;

           %Create a vector for nchoosek
           nchoosekVector= zeros(1, NumChannels + 1);
           kVector = zeros(1, NumChannels + 1);
           for k = 0:NumChannels
               nchoosekVector(k+1) = nchoosek(NumChannels, k);
               kVector(k+1) = k;
           end

           nchoosekMatrix = nchoosekVector'*ones(1, size(SubData, 2));
           kMatrix = kVector'*ones(1,size(SubData,2));
           PoMat = ones(size(kMatrix,1), 1)*PO;
           BinopdfMat = nchoosekMatrix.*(PoMat.^kMatrix).*((1-PoMat).^(NumChannels - kMatrix));

           %sum(sum((BinopdfMat - StackDataProb).^2))

           %FORMATTED_DATA = [FORMATTED_DATA tTemp' MeanCurrent' PO'];   
           FORMATTED_DATA = [FORMATTED_DATA; sum(sum((BinopdfMat - StackDataProb).^2))];

        end
            
    function ComputePo
        global SCSTEPLATE;
        DATA = Export(1);
        numVt = length(fieldnames(DATA));


        % Get input from user
        prompt={'Enter Sweep Window Low:',...
            'Enter Sweep Window High:',...
            'Enter Number of Channels:',...
            'Enter Unitary Current (sep. by spaces):'};

        name='Parameters';
        numlines=1;
        
        %defaultanswer={'1', '200', '2', '-2 -1.7 -1.4'};
        % Update defaultanswer
        defaultanswer = {num2str(SCSTEPLATE.DataAnalysisParams.SwpWind(1)), num2str(SCSTEPLATE.DataAnalysisParams.SwpWind(2)), ...
            num2str(SCSTEPLATE.DataAnalysisParams.NumCh), num2str(SCSTEPLATE.DataAnalysisParams.UnitaryCurrent)};
        
        answer = inputdlg(prompt,name,numlines,defaultanswer);
%         SwpWind = [str2num(answer{1}) str2num(answer{2});...
%             str2num(answer{1}) str2num(answer{2});...
%             str2num(answer{1}) str2num(answer{2})];
        SwpWind = ones(numVt, 1) * [str2num(answer{1}) str2num(answer{2})]; 
        NumChannels = str2num(answer{3});
        UnitaryCurrent = str2num(answer{4});
        if length(UnitaryCurrent) ~= numVt
            waitfor(errordlg('Number of unitary current input does not match number of Vtest'));
            return;
        end
        
        for i = 1:size(SwpWind, 1)
            OutputString = ['TestVoltage' num2str(i)];
            SwpWind(i,2) = min(SwpWind(i,2), size(DATA.(OutputString),2));
        end
        
        % Update analysis param
        SCSTEPLATE.DataAnalysisParams.SwpWind = SwpWind(1,:);
        SCSTEPLATE.DataAnalysisParams.NumCh = NumChannels;
        SCSTEPLATE.DataAnalysisParams.UnitaryCurrent = UnitaryCurrent;
        
        t = SCSTEPLATE.FitData.Time;
        FORMATTED_DATA = [];
        figure;

        for k = 1:numVt
           VString = ['TestVoltage' num2str(k)];
           % First apply the swpwind mask and instruments mask
           vData = DATA.(VString);
           vData = vData(:, SwpWind(k,1):SwpWind(k,2));
           %Mask = (t>Twindow(1))& (t<Twindow(2));

           %SubDATA = vData(Mask, :);
           SubData = vData';
           %meanVal = mean(SubDATA',1);
           %tNew = t(Mask);

           % Idealize
           SubData = round(SubData/UnitaryCurrent(k));
           % Restrict openings
           SubData = min(SubData, zeros(size(SubData,1), size(SubData,2)) + NumChannels);
           SubData = SubData.*(SubData>0)*UnitaryCurrent(k);
           % Hack to 0 current before pulse
           SubData(:, 1:find(t == SCSTEPLATE.FitData.tStart(1))) = 0;

           % Calculate mean and PO
           MeanCurrent = mean(SubData);
           PO = MeanCurrent/UnitaryCurrent(k)/NumChannels;

           %Plot
           subplot(3,numVt,k)
                plot(t, SubData,'Color',[0.5 0.5 0.5])
                hold on
                plot(t, MeanCurrent,'Color',[0 0 0])
                hold off
                xlim([min(t) max(t)])
                title(['Sweep average (' num2str(SCSTEPLATE.FitData.FamVoltage(k)) 'mV)']);
                box off
%            subplot(3, numVt, k + numVt); 
%                 plot(SCSTEPLATE.FitData.Mean(:, k), SCSTEPLATE.FitData.Variance(:,k), '.k');
%                 hold on;
%                 meanTheory = NumChannels*UnitaryCurrent(k):0.1:0;
%                 varTheory = UnitaryCurrent(k).*meanTheory - meanTheory.^2 ./ NumChannels;
%                 plot(meanTheory, varTheory, 'r-');
%                 hold off;
%                 xlim([min(meanTheory).*1.1 0]);
%                 ylim([0 max(max(varTheory), max(SCSTEPLATE.FitData.Variance(:,k))).*1.1]);
%                 title(['Mean vs. Variance (' num2str(SCSTEPLATE.FitData.FamVoltage(k)) 'mV) i = ' num2str(UnitaryCurrent(k)) 'pA N = ' num2str(NumChannels)]);
%                 box off   
           subplot(3,numVt,k + 2*numVt)
                plot(t, PO,'Color',[0 0 0])
                xlim([min(t) max(t)])
                ylim([0 0.7])
                title(['PO vs. time (' num2str(SCSTEPLATE.FitData.FamVoltage(k)) 'mV) Max PO: ' num2str(max(PO), 4)]);
                box off    

           FORMATTED_DATA = [FORMATTED_DATA t MeanCurrent' PO']; 
        end       
        CopyToClipboard(FORMATTED_DATA,{},{});
   
  function CalcCov
        
        % calculate Prob{open at t | open at tau) 
        % use noise analysis technique, recall
        % p11(t2 | t1) = C(t1, t2)/(n*i^2*p1(t1)) + I(t2)/(N*i)
        % where C(t1, t2) is the covariance, n is number of channels, i is
        % unitary conductance, and I(t2) is the mean current at t2
        
        global SCSTEPLATE;
        
        % Retrieve data
        DATA = Export(1);
        numVt = length(fieldnames(DATA));

        % Get input from user
        prompt={'Enter Sweep Window Low:',...
            'Enter Sweep Window High:',...
            'Enter Time Window Low:',...
            'Enter Time Window High:',...
            'Enter Number of Channels:',...
            'Enter Unitary Current (sep. by spaces):'};

        name='Parameters';
        numlines=1;
        
        % Update defaultanswer
        defaultanswer = {num2str(SCSTEPLATE.DataAnalysisParams.SwpWind(1)), num2str(SCSTEPLATE.DataAnalysisParams.SwpWind(2)), ...
            num2str(SCSTEPLATE.DataAnalysisParams.TimeWind(1)), num2str(SCSTEPLATE.DataAnalysisParams.TimeWind(2)), ...
            num2str(SCSTEPLATE.DataAnalysisParams.NumCh), num2str(SCSTEPLATE.DataAnalysisParams.UnitaryCurrent)};
        
        answer = inputdlg(prompt,name,numlines,defaultanswer);
        SwpWind = ones(numVt, 1) * [str2num(answer{1}) str2num(answer{2})]; 
        Twindow = [str2num(answer{3}) str2num(answer{4})];
        NumChannels = str2num(answer{5});
        UnitaryCurrent = str2num(answer{6});
        
        if length(UnitaryCurrent) ~= numVt
            waitfor(errordlg('Number of unitary current input does not match number of Vtest'));
            return;
        end
        
        for i = 1:size(SwpWind, 1)
            OutputString = ['TestVoltage' num2str(i)];
            SwpWind(i,2) = min(SwpWind(i,2), size(DATA.(OutputString),2));
        end
        
        % Update analysis param
        SCSTEPLATE.DataAnalysisParams.SwpWind = SwpWind(1,:);
        SCSTEPLATE.DataAnalysisParams.NumCh = NumChannels;
        SCSTEPLATE.DataAnalysisParams.UnitaryCurrent = UnitaryCurrent;
        SCSTEPLATE.DataAnalysisParams.TimeWind = Twindow;
        
        t = SCSTEPLATE.FitData.Time;
        Mask = (t>Twindow(1))& (t<Twindow(2));
        tNew = t(Mask);
        FORMATTED_DATA = [];
        figure;
        tStart = SCSTEPLATE.FitData.tStart;

        meanVal = SCSTEPLATE.FitData.Mean;
        variance = SCSTEPLATE.FitData.Variance;

        for k = 1:numVt
           VString = ['TestVoltage' num2str(k)];
           % First apply the swpwind mask and instruments mask
           vData = DATA.(VString);
           vData = vData .* (ones(size(vData,2), 1) * (t'>tStart(k)))';
           vData = vData(:, SwpWind(k,1):SwpWind(k,2));

           % Idealize
           SubData = transpose(vData(Mask,:));
           SubData = round(SubData/UnitaryCurrent(k));
           % Restrict openings
           SubData = min(SubData, zeros(size(SubData,1), size(SubData,2)) + NumChannels);
           SubData = SubData.*(SubData>0)*UnitaryCurrent(k);
           % Hack to 0 current before pulse
           SubData(:, 1:find(t == SCSTEPLATE.FitData.tStart(1))) = 0;

           % calculate mean and variance
           
           
           % calculate covariance
           autocov = cov(SubData);
           
           % calculate Poo
           Poo = zeros(size(autocov, 1), size(autocov, 2));
    
           mean_i = meanVal(:,k) * ones(1,length(tNew));
           Poo = autocov ./ (UnitaryCurrent(k) .* mean_i) + transpose(mean_i) ./ (NumChannels * UnitaryCurrent(k));
           
           %Plot
           subplot(1,numVt, k)
                plot(t, fLatency','Color',[0 0 0])
                xlim([min(t) max(t)])
                title(['First Latency (' num2str(SCSTEPLATE.FitData.FamVoltage(k)) 'mV)']);
                box off
                ylim([0, 1]);

           FORMATTED_DATA = [FORMATTED_DATA t fLatency']; 
        end       
        CopyToClipboard(FORMATTED_DATA,{},{});

function openTime
        global SCSTEPLATE;
        DATA = Export(1);
        numVt = length(fieldnames(DATA));

        % Get input from user
        prompt={'Enter Sweep Window Low:',...
            'Enter Sweep Window High:',...
            'Enter Number of Channels:',...
            'Enter Unitary Current (sep. by spaces):', ...
            'Enter bin width (ms):'};

        name='Parameters';
        numlines=1;

        % Update defaultanswer
        defaultanswer = {num2str(SCSTEPLATE.DataAnalysisParams.SwpWind(1)), num2str(SCSTEPLATE.DataAnalysisParams.SwpWind(2)), ...
            num2str(SCSTEPLATE.DataAnalysisParams.NumCh), num2str(SCSTEPLATE.DataAnalysisParams.UnitaryCurrent), num2str(0.01)};
        
        answer = inputdlg(prompt,name,numlines,defaultanswer);
        SwpWind = ones(numVt, 1) * [str2num(answer{1}) str2num(answer{2})]; 
        NumChannels = str2num(answer{3});
        UnitaryCurrent = str2num(answer{4});
        binWidth = str2num(answer{5});

        
        if length(UnitaryCurrent) ~= numVt
            waitfor(errordlg('Number of unitary current input does not match number of Vtest'));
            return;
        end
        
        for i = 1:size(SwpWind, 1)
            OutputString = ['TestVoltage' num2str(i)];
            SwpWind(i,2) = min(SwpWind(i,2), size(DATA.(OutputString),2));
        end
        
        % Update analysis param
        SCSTEPLATE.DataAnalysisParams.SwpWind = SwpWind(1,:);
        SCSTEPLATE.DataAnalysisParams.NumCh = NumChannels;
        SCSTEPLATE.DataAnalysisParams.UnitaryCurrent = UnitaryCurrent;
        
        t = SCSTEPLATE.FitData.Time;
        tStart = SCSTEPLATE.FitData.tStart;
        FORMATTED_DATA = [];
        figure;

        for k = 1:numVt
           VString = ['TestVoltage' num2str(k)];
           % First apply the swpwind mask and instruments mask
           vData = DATA.(VString);
           vData = vData .* (ones(size(vData,2), 1) * (t'>tStart(k)))';
           vData = vData(:, SwpWind(k,1):SwpWind(k,2));

           %SubDATA = vData(Mask, :);
           SubData = vData';
           %meanVal = mean(SubDATA',1);
           %tNew = t(Mask);

           % Idealize
           SubData = round(SubData/UnitaryCurrent(k));
           SubData = SubData.*(SubData>0.5);
           %SubData = min(SubData, zeros(size(SubData,1), size(SubData,2)) + NumChannels);
           %SubData = SubData.*(SubData>0)*UnitaryCurrent(k);
           
           DURATION = [];
           
           for sweepNum = 1:size(SubData,1)
               % Collapse all openings into single openings, and determine
               % where the openings are regardless of whether or not they
               % are multi or single openings
               collapseOpenings = SubData(sweepNum, :);
               collapseOpenings(collapseOpenings > 1) = 1;
               transitions = diff(collapseOpenings);
               upStrokes = find(transitions > 0);
               downStrokes = find(transitions < 0);
               if(size(upStrokes,2) ~= size(downStrokes,2))
                   %disp('Error with opening calculation');
               else
                   % Check each openings to see if any are multi-openings,
                   % store only the single openings.
                   for transNum = 1:length(upStrokes)
                       if sum(SubData(sweepNum, upStrokes(transNum):downStrokes(transNum)) >= 2) == 0
                           % Valid opening, accept
                           DURATION = [DURATION, downStrokes(transNum)-upStrokes(transNum)];
                       end
                   end    
               end

           end
              
           % Need to look at the sampling rate, but here I'm hardcoding
           % assuming each interval is 0.01 ms (100 KHz sampling) to convert open duration to
           % ms
           
           DURATION = DURATION * 0.01;
           
           %Plot
           subplot(1,numVt, k)
                x = 0:binWidth:23;
                [binCounts, center] = hist(DURATION, x);
                binCounts = 1 - cumsum(binCounts)/sum(binCounts); 
                bar(x, binCounts);
%                 options = optimset('TolFun',1e-9,'Display','off');
%                 params_fit = lsqcurvefit(@(x,binCounts) expFit(x,binCounts), ...
%                        2,x,binCounts,0,100, options);
                hold on;
%                 plot(x, expFit(params_fit, x), 'r--', 'linewidth', 2);
                hold off;
                %hist(DURATION, 0:binWidth:23);
                %xlim([0 max(DURATION)*1.5])
                xlim([0 5]);
                title(['Open Duration (' num2str(SCSTEPLATE.FitData.FamVoltage(k)) 'mV)']);
                box off
                %ylim([0, 1]);
%            [binCounts, ind] = histc(DURATION, 0:binWidth:23);
           FORMATTED_DATA = [FORMATTED_DATA transpose(0:binWidth:23) binCounts']; 
        end       
        CopyToClipboard(FORMATTED_DATA,{},{});   
          clipboard('copy', sprintf('%5.4f\n',DURATION));
        
        
function numOpenings
        global SCSTEPLATE;
        DATA = Export(1);
        numVt = length(fieldnames(DATA));

        % Get input from user
        prompt={'Enter Sweep Window Low:',...
            'Enter Sweep Window High:',...
            'Enter Number of Channels:',...
            'Enter Unitary Current (sep. by spaces):', ...
            'Enter bin width (ms):'};

        name='Parameters';
        numlines=1;

        % Update defaultanswer
        defaultanswer = {num2str(SCSTEPLATE.DataAnalysisParams.SwpWind(1)), num2str(SCSTEPLATE.DataAnalysisParams.SwpWind(2)), ...
            num2str(SCSTEPLATE.DataAnalysisParams.NumCh), num2str(SCSTEPLATE.DataAnalysisParams.UnitaryCurrent), num2str(1)};
        
        answer = inputdlg(prompt,name,numlines,defaultanswer);
        SwpWind = ones(numVt, 1) * [str2num(answer{1}) str2num(answer{2})]; 
        NumChannels = str2num(answer{3});
        UnitaryCurrent = str2num(answer{4});
        binWidth = str2num(answer{5});

        
        if length(UnitaryCurrent) ~= numVt
            waitfor(errordlg('Number of unitary current input does not match number of Vtest'));
            return;
        end
        
        for i = 1:size(SwpWind, 1)
            OutputString = ['TestVoltage' num2str(i)];
            SwpWind(i,2) = min(SwpWind(i,2), size(DATA.(OutputString),2));
        end
        
        % Update analysis param
        SCSTEPLATE.DataAnalysisParams.SwpWind = SwpWind(1,:);
        SCSTEPLATE.DataAnalysisParams.NumCh = NumChannels;
        SCSTEPLATE.DataAnalysisParams.UnitaryCurrent = UnitaryCurrent;
        
        t = SCSTEPLATE.FitData.Time;
        tStart = SCSTEPLATE.FitData.tStart;
        FORMATTED_DATA = [];
        figure;

        for k = 1:numVt
           VString = ['TestVoltage' num2str(k)];
           % First apply the swpwind mask and instruments mask
           vData = DATA.(VString);
           vData = vData .* (ones(size(vData,2), 1) * (t'>tStart(k)))';
           vData = vData(:, SwpWind(k,1):SwpWind(k,2));

           %SubDATA = vData(Mask, :);
           SubData = vData';
           %meanVal = mean(SubDATA',1);
           %tNew = t(Mask);

           % Idealize
           SubData = round(SubData/UnitaryCurrent(k));
           SubData = SubData.*(SubData>0.5);
           %SubData = min(SubData, zeros(size(SubData,1), size(SubData,2)) + NumChannels);
           %SubData = SubData.*(SubData>0)*UnitaryCurrent(k);
           
           NUM_OPENINGS = [];
           
           for sweepNum = 1:size(SubData,1)
               % Collapse all openings into single openings, and determine
               % where the openings are regardless of whether or not they
               % are multi or single openings
               collapseOpenings = SubData(sweepNum, :);
               collapseOpenings(collapseOpenings > 1) = 1;
               transitions = diff(collapseOpenings);
               upStrokes = find(transitions > 0);
               downStrokes = find(transitions < 0);
               if(size(upStrokes,2) ~= size(downStrokes,2))
                   %disp('Error with opening calculation');
               else
                   NUM_OPENINGS = [NUM_OPENINGS, size(upStrokes,2)];                    
               end

           end
              

           %Plot
           subplot(1,numVt, k)
                x = 0:binWidth:max(NUM_OPENINGS);
                [binCounts, center] = hist(NUM_OPENINGS, x);
                %binCounts = 1 - cumsum(binCounts)/sum(binCounts); 
                bar(x, binCounts);
%                 options = optimset('TolFun',1e-9,'Display','off');
%                 params_fit = lsqcurvefit(@(x,binCounts) expFit(x,binCounts), ...
%                        2,x,binCounts,0,100, options);
                hold on;
%                 plot(x, expFit(params_fit, x), 'r--', 'linewidth', 2);
                hold off;
                %hist(DURATION, 0:binWidth:23);
                %xlim([0 max(DURATION)*1.5])
                xlim([0 5]);
                title(['Open Duration (' num2str(SCSTEPLATE.FitData.FamVoltage(k)) 'mV)']);
                box off
                %ylim([0, 1]);
           [binCounts, ind] = histc(NUM_OPENINGS, 0:binWidth:max(NUM_OPENINGS));
           FORMATTED_DATA(1:numel(transpose(0:binWidth:max(NUM_OPENINGS))), 2*k-1) = transpose(0:binWidth:max(NUM_OPENINGS));
           FORMATTED_DATA(1:numel(binCounts'), 2*k) = binCounts';
        end       
        CopyToClipboard(FORMATTED_DATA,{},{});
        
    function CalcPoo
        global SCSTEPLATE;
        DATA = Export(1);
        numVt = length(fieldnames(DATA));

        % Get input from user
        prompt={'Enter Sweep Window Low:',...
            'Enter Sweep Window High:',...
            'Enter Number of Channels:',...
            'Enter Unitary Current (sep. by spaces):', ...
            'Enter Window Width (ms):', ...
            'Enter Window Starting Point from beginning of test pulse (ms):'};

        name='Parameters';
        numlines=1;

        % Update defaultanswer
        defaultanswer = {num2str(SCSTEPLATE.DataAnalysisParams.SwpWind(1)), num2str(SCSTEPLATE.DataAnalysisParams.SwpWind(2)), ...
            num2str(SCSTEPLATE.DataAnalysisParams.NumCh), num2str(SCSTEPLATE.DataAnalysisParams.UnitaryCurrent), num2str(20), num2str(0)};
        
        answer = inputdlg(prompt,name,numlines,defaultanswer);
        SwpWind = ones(numVt, 1) * [str2num(answer{1}) str2num(answer{2})]; 
        NumChannels = str2num(answer{3});
        UnitaryCurrent = str2num(answer{4});
        WindowWidth = str2num(answer{5});
        WindowStart = str2num(answer{6});
        
        if length(UnitaryCurrent) ~= numVt
            waitfor(errordlg('Number of unitary current input does not match number of Vtest'));
            return;
        end
        
        for i = 1:size(SwpWind, 1)
            OutputString = ['TestVoltage' num2str(i)];
            SwpWind(i,2) = min(SwpWind(i,2), size(DATA.(OutputString),2));
        end
        
        % Update analysis param
        SCSTEPLATE.DataAnalysisParams.SwpWind = SwpWind(1,:);
        SCSTEPLATE.DataAnalysisParams.NumCh = NumChannels;
        SCSTEPLATE.DataAnalysisParams.UnitaryCurrent = UnitaryCurrent;
        
        t = SCSTEPLATE.FitData.Time;
        tStart = SCSTEPLATE.FitData.tStart;
        windowStartIndex = find((t-tStart(1)) >= WindowStart, 1, 'first');
        windowEndIndex = find((t-tStart(1)) <= WindowWidth, 1, 'last');
        midIndex = round((windowEndIndex - windowStartIndex)/2 + windowStartIndex);
        FORMATTED_DATA = [];
        figure;

        for k = 1:numVt
           VString = ['TestVoltage' num2str(k)];
           % First apply the swpwind mask and instruments mask
           vData = DATA.(VString);
           vData = vData .* (ones(size(vData,2), 1) * (t'>tStart(k)))';
           vData = vData(:, SwpWind(k,1):SwpWind(k,2));

           %SubDATA = vData(Mask, :);
           SubData = vData';
           %meanVal = mean(SubDATA',1);
           %tNew = t(Mask);

           % Idealize
           SubData = round(SubData/UnitaryCurrent(k));
           SubData = SubData.*(SubData>0.5);
           %SubData = min(SubData, zeros(size(SubData,1), size(SubData,2)) + NumChannels);
           %SubData = SubData.*(SubData>0)*UnitaryCurrent(k);

           % Find position at which channel first opens within the sweeps
           % within the specified time window
           fOpenFirst = cumsum(SubData(:, windowStartIndex:windowEndIndex),2)>0.5;
           
           % nonBlankSweep is 0 if sweep is 0, else 1; fOpenFirstind is the
           % index of first opening. Filter for blank sweeps and sort the
           % sweeps by open time, the first row will be the sweep with
           % latest opening. 
           [nonBlankSweep, fOpenFirstInd] = max(fOpenFirst ~= 0, [], 2);
           fOpenFirstInd = fOpenFirstInd.*nonBlankSweep;
           sortedSubData = sortrows([fOpenFirstInd, SubData], -1); % sort by descending order according to first opening
           blankInd = sortedSubData(:,1) == 0;
           sortedSubData(blankInd, :) = []; % filter blank sweeps
           sortedSubData = sortedSubData(:, 2:end); % cut off the sorting column
           
           % Calculate Po(t | O up to first opening) and make r_adj
           % according to r_adj = r - (N-1)*i*Po(t | O up to first opening)
           cumsum_data = cumsum(sortedSubData); 
           numSweepNormalization = 0:size(sortedSubData,1) - 1;
           
           fOpenFirst = cumsum(sortedSubData(:, windowStartIndex:windowEndIndex),2)>0.5;
           [nonBlankSweep, fOpenFirstInd] = max(fOpenFirst ~= 0, [], 2);
           
           d = find(~diff(fOpenFirstInd));
           for j=1:length(d)
               cumsum_data(d(j),:) = cumsum_data(d(j),:) - sortedSubData(d(j),:);
               numSweepNormalization(d(j)+1) = numSweepNormalization(d(j)+1) - 1;
               i = 1;
               if j>i
                   while d(j)==d(j-i)+i
                       cumsum_data(d(j),:) = cumsum_data(d(j),:) - sortedSubData(d(j-i),:);
                       numSweepNormalization(d(j)+1) = numSweepNormalization(d(j)+1) - 1;
                       i = i+1; if j==i, break; end
                   end
               end
           end
           
           numSweepNormalization = numSweepNormalization'*ones(1, size(sortedSubData,2));
           sweep_adj = sortedSubData;
           sweep_adj(2:end, :) = sweep_adj(2:end, :) - cumsum_data(1:end-1, :) ./ (numSweepNormalization(2:end, :)).*(NumChannels - 1)./(NumChannels); 
           
           
           % Align the sweeps to the middle of the time window
           
           sweeps_aligned = zeros(size(sweep_adj)); % create an n x m matrix where n is number of nonblank sweeps, m is total time points
           fOpenFirst = cumsum(sweep_adj,2)>0.5; % re-determine position of first openings
           [nonBlankSweep, fOpenFirstInd] = max(fOpenFirst ~= 0, [], 2);
           if ~all(nonBlankSweep)
               disp('Error with filtering');
           end
           
           for sNum = 1:size(sweep_adj, 1)
               indFOpen = fOpenFirstInd(sNum);
               sweeps_aligned(sNum, max(midIndex - indFOpen, 0) + 1:size(sweep_adj,2)-max(indFOpen - midIndex,0)) = sweep_adj(sNum, max(indFOpen - midIndex,0) + 1:size(sweep_adj,2) - max(midIndex - indFOpen,0));
           end
           
           POO = mean(sweeps_aligned);
           
           %Plot
           subplot(1,numVt, k)
                plot(t, POO','Color',[0 0 0])
                xlim([min(t) max(t)])
                title(['POO (' num2str(SCSTEPLATE.FitData.FamVoltage(k)) 'mV)']);
                box off
                %ylim([0, 1]);

           FORMATTED_DATA = [FORMATTED_DATA t POO']; 
        end       
        CopyToClipboard(FORMATTED_DATA,{},{});
        
    function FirstLatency
        global SCSTEPLATE;
        DATA = Export(1);
        numVt = length(fieldnames(DATA));


        % Get input from user
        prompt={'Enter Sweep Window Low:',...
            'Enter Sweep Window High:',...
            'Enter Number of Channels:',...
            'Enter Unitary Current (sep. by spaces):'};

        name='Parameters';
        numlines=1;
        
        %defaultanswer={'1', '200', '2', '-2 -1.7 -1.4'};
        % Update defaultanswer
        defaultanswer = {num2str(SCSTEPLATE.DataAnalysisParams.SwpWind(1)), num2str(SCSTEPLATE.DataAnalysisParams.SwpWind(2)), ...
            num2str(SCSTEPLATE.DataAnalysisParams.NumCh), num2str(SCSTEPLATE.DataAnalysisParams.UnitaryCurrent)};
        
        answer = inputdlg(prompt,name,numlines,defaultanswer);
%         SwpWind = [str2num(answer{1}) str2num(answer{2});...
%             str2num(answer{1}) str2num(answer{2});...
%             str2num(answer{1}) str2num(answer{2})];
        SwpWind = ones(numVt, 1) * [str2num(answer{1}) str2num(answer{2})]; 
        NumChannels = str2num(answer{3});
        UnitaryCurrent = str2num(answer{4});
        if length(UnitaryCurrent) ~= numVt
            waitfor(errordlg('Number of unitary current input does not match number of Vtest'));
            return;
        end
        
        for i = 1:size(SwpWind, 1)
            OutputString = ['TestVoltage' num2str(i)];
            SwpWind(i,2) = min(SwpWind(i,2), size(DATA.(OutputString),2));
        end
        
        % Update analysis param
        SCSTEPLATE.DataAnalysisParams.SwpWind = SwpWind(1,:);
        SCSTEPLATE.DataAnalysisParams.NumCh = NumChannels;
        SCSTEPLATE.DataAnalysisParams.UnitaryCurrent = UnitaryCurrent;
        
        t = SCSTEPLATE.FitData.Time;
        tStart = SCSTEPLATE.FitData.tStart;
        FORMATTED_DATA = [];
        options = optimset('TolFun',1e-9,'Display','off');
        figure; 
        fit_params = zeros(numVt, 9);

        for k = 1:numVt
           VString = ['TestVoltage' num2str(k)];
           % First apply the swpwind mask and instruments mask
           vData = DATA.(VString);
           vData = vData .* (ones(size(vData,2), 1) * (t'>tStart(k)))';
           vData = vData(:, SwpWind(k,1):SwpWind(k,2));
           %Mask = (t>Twindow(1))& (t<Twindow(2));

           %SubDATA = vData(Mask, :);
           SubData = vData';
           %meanVal = mean(SubDATA',1);
           %tNew = t(Mask);

           % Idealize
           SubData = round(SubData/UnitaryCurrent(k));
           SubData = SubData.*(SubData>0.5);
           %SubData = min(SubData, zeros(size(SubData,1), size(SubData,2)) + NumChannels);
           %SubData = SubData.*(SubData>0)*UnitaryCurrent(k);      

           % Calculate first latency
           fOpenFirst = mean(cumsum(SubData,2)>0.5, 1);
           fLatency = transpose(1-(1-fOpenFirst).^(1/NumChannels));  
           params_FLfit = lsqcurvefit(@(t,fLatency) FL_exp_fit(t,fLatency), ...
           [.5 0.5 0 3   .5 10 0 3],t,fLatency, ...
           [0 0 0 2.5 0 0 0 2.5],[1 5 .1 3.5 1 50 .1 3.5],options);
           
           fit_params(k, :) = [SCSTEPLATE.FitData.FamVoltage(k) params_FLfit];
           
           %Plot
           subplot(1,numVt, k)
                plot(t, fLatency,'Color',[0 0 0], 'linewidth', 3)
                hold on;
                plot(t, FL_exp_fit(params_FLfit, t), 'r--', 'linewidth', 2);
                xlim([min(t) max(t)])
                title(['First Latency (' num2str(SCSTEPLATE.FitData.FamVoltage(k)) 'mV)']);
                box off
                ylim([0, 1]);

           FORMATTED_DATA = [FORMATTED_DATA t fLatency FL_exp_fit(params_FLfit, t)]; 
        end
%         
%         FORMATTED_DATA = [fit_params; FORMATTED_DATA];
        CopyToClipboard(FORMATTED_DATA,{},{});
        
    function F = FL_exp_fit(x2,xdata)
    % Model function to fit for FL
    % x: amplitude, tau, baseline, 0 start
    % x = x2;
    % F = (x(1)*exp(-(xdata-x(4))/x(2))).*(sign(xdata-x(4))+1)/2+x(3);

    F = 0;

    %x2(1) = 1-sum(x2(5:4:end));
    for i = 1:4:length(x2)
        x = x2(i:i+3);
        F = F+x(1)*(1-(exp(-(xdata-x(4))/x(2)))).*(sign(xdata-x(4))+1)/2;
    end

    function h = fitMeanVar
        global SCSTEPLATE;
        h = figure;
        DATA = Export(1);
        numVt = length(fieldnames(DATA));

        
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function Menu_AutoCalcPo
            global SCSTEPLATE;
            set(gcf, 'pointer', 'watch'); drawnow;
            nSel = get(SCSTEPLATE.Box, 'value');
            cla;  xlim('auto');

            [Filename, Pathname] = uigetfile('*.xls', 'Choose the excel spreadsheet'); % user to choose file
            if Filename==0
                return;
            end
            xlsFile = [Pathname  Filename];

            for k=1:length(nSel);
                cla;
               
                DATA = LoadData(SCSTEPLATE.datafile, SCSTEPLATE.RunSwp{nSel(k)});
                ANALYSIS = load(SCSTEPLATE.AnalysisFile, '-mat');
                swANALYSIS = ANALYSIS.(SCSTEPLATE.RunSwp{nSel(k)});
                XMin = swANALYSIS.XMin;
                XMax = swANALYSIS.XMax;
                Tau = swANALYSIS.Tau;
                Amp = swANALYSIS.Amp;
                Delay = swANALYSIS.Delay;
                m = swANALYSIS.m;
                b = swANALYSIS.b;
                SF = DATA(2).StimParams.LeakSF;
                CellNum = DATA(1).CellNum;
                CellNumString = ['Cell',num2str(DATA(1).DBParams.CellNum),''];
                fullfile = SCSTEPLATE.datafile;
                l = findstr(fullfile, '\');
                file = fullfile(l(end)+1:end);
                RunSwp = SCSTEPLATE.RunSwp{nSel};
                freq = DATA(1).SamplingFreqHz;
                RI = DATA(1).StimParams.RI;
                xFect = DATA(1).DBParams.XFect;

                 %if (findstr(DATA(1).StimName, 'Step'));
                
                try
                    NumCh = ANALYSIS.(CellNumString).NumCh;
                    g = ANALYSIS.(CellNumString).g;
                    Vs = ANALYSIS.(CellNumString).Vs;
                catch
                    waitfor(errordlg('you must set the single channel level for this analysis'));
                end

                Dstep = DATA(1).StimParams.Dstep;
                VStep = DATA(1).StimParams.Vstep;
                time    = DATA(1).Time*1000 ;  %time in ms starting from begining of data
                t    = DATA(1).Time*1000 - 1000*DATA(1).StimParams.PrePoints/DATA(1).SamplingFreqHz;  %time in ms where zero is at start of p2
                iRaw = DATA(1).AcqWaveform;
                %iRaw = LowpassFilter(DATA(1).Time, iRaw, FiltHz);
                avgLk  = mean(DATA(2).AcqWaveform,3);
                iRaw = iRaw - SCSTEPLATE.swOffset;
                avgLk = avgLk - SCSTEPLATE.lkOffset;
                avgLk = avgLk*SF;
                smoothleak = 0;
                try
                    for n=1:(length(XMin))
                        ilk = Amp(n)*exp(-(Tau(n))*(t-Delay(n)));
                        
                        %Billy edit 05-29-2014
                                
                        ilk(t < Delay(n)) = 0;
                        ilk(t<XMin(n))=0;
                        ilk(t>XMax(n))=0;
                        smoothleak = smoothleak + ilk;
                    end
                end
                try
                    LinearFit = m*t + b;
                    smoothleak = smoothleak + LinearFit;
                end
                try
                    for n=1:(length(AMin));
                        alk = iRaw-smoothleak;
                        alk(t<AMin(n))=0;
                        alk(t>AMax(n))=0;
                        smoothleak = smoothleak + alk;
                    end
                end
                iRaw = iRaw - smoothleak;
 
                prepts= 1000*DATA(1).StimParams.PrePoints/DATA(1).SamplingFreqHz;
                ST=(prepts)*length(iRaw)/(time(end));
                ET = (Dstep(1)*length(iRaw))/(time(end));
                baseline = iRaw(ST:ET);
                VarianceB = var(baseline);
                AverageBL= mean(baseline);

                ST=(Dstep(1)+prepts+30)/time(end)*length(iRaw);
                ET = (Dstep(1)+Dstep(2)+prepts - 10)*length(iRaw)/time(end);
                step = iRaw(ST:ET);
                Variance = var(step);
                AverageI= mean(step);

                %note - assume step 2 is the pulse and ZF = 12
                v = VStep(2);
                i = -g*(v-Vs)*exp(-(v-Vs)/12)/(1-exp(-(v-Vs)/12));
                Po= 1-(Variance-VarianceB)/AverageI*i;
                N = AverageI/(Po*i);

                strColHeaders = {'xFect' 'Cell' 'file'  'run_swp' 'freq' 'RI' 'V' 'i' 'Var(base)' '<i>base' 'Variance' '<i>' 'Po' 'N'}
                values(k,:) = [{xFect} CellNum {file} {RunSwp} freq RI v i VarianceB AverageBL Variance AverageI Po N];
            end
                 try
            [dum, dum, temp] = xlsread(xlsFile, num2str(CellNum));
            final = [temp; strColHeaders; values];
            catch
                final = [strColHeaders; values];
            end
                      
            xlswrite(xlsFile, final, num2str(CellNum), 'A2');
       
            UpdateGraphics;
          
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function Menu_CalcPo
            global SCSTEPLATE;
            set(gcf, 'pointer', 'watch'); drawnow;
            nSel = get(SCSTEPLATE.Box, 'value');
            cla;  xlim('auto');
            
            for k=1:length(nSel);
            cla;
            
                DATA = LoadData(SCSTEPLATE.datafile, SCSTEPLATE.RunSwp{nSel(k)});
                ANALYSIS = load(SCSTEPLATE.AnalysisFile, '-mat');
                swANALYSIS = ANALYSIS.(SCSTEPLATE.RunSwp{nSel(k)});
                XMin = swANALYSIS.XMin;
                XMax = swANALYSIS.XMax;
                Tau = swANALYSIS.Tau;
                Amp = swANALYSIS.Amp;
                Delay = swANALYSIS.Delay;
                m = swANALYSIS.m;
                b = swANALYSIS.b;
                SF = DATA(2).StimParams.LeakSF;
                CellNum = DATA(1).CellNum;
                CellNumString = ['Cell',num2str(DATA(1).DBParams.CellNum),''];
                fullfile = SCSTEPLATE.datafile;
                l = findstr(fullfile, '\');
                file = fullfile(l(end)+1:end);
                RunSwp = SCSTEPLATE.RunSwp{nSel};
                freq = DATA(1).SamplingFreqHz;
                RI = DATA(1).StimParams.RI;
                xFect = DATA(1).DBParams.XFect;

                try
                    NumCh = ANALYSIS.(CellNumString).NumCh;
                    g = ANALYSIS.(CellNumString).g;
                    Vs = ANALYSIS.(CellNumString).Vs;
                catch
                    waitfor(errordlg('you must set the single channel level for this analysis'));
                end

                Dstep = DATA(1).StimParams.Dstep;
                VStep = DATA(1).StimParams.Vstep;
                time    = DATA(1).Time*1000 ;  %time in ms starting from begining of data
                t    = DATA(1).Time*1000 - 1000*DATA(1).StimParams.PrePoints/DATA(1).SamplingFreqHz;  %time in ms where zero is at start of p2
                iRaw = DATA(1).AcqWaveform;
                %iRaw = LowpassFilter(DATA(1).Time, iRaw, FiltHz);
                avgLk  = mean(DATA(2).AcqWaveform,3);
                iRaw = iRaw - SCSTEPLATE.swOffset;
                avgLk = avgLk - SCSTEPLATE.lkOffset;
                avgLk = avgLk*SF;
                smoothleak = 0;
                try
                    for n=1:(length(XMin))
                        ilk = Amp(n)*exp(-(Tau(n))*(t-Delay(n)));
                        %Billy edit 05-29-2014
                                
                        ilk(t < Delay(n)) = 0;
                        ilk(t<XMin(n))=0;
                        ilk(t>XMax(n))=0;
                        smoothleak = smoothleak + ilk;
                    end
                end
                try
                    LinearFit = m*t + b;
                    smoothleak = smoothleak + LinearFit;
                end
                try
                    for n=1:(length(AMin));
                        alk = iRaw-smoothleak;
                        alk(t<AMin(n))=0;
                        alk(t>AMax(n))=0;
                        smoothleak = smoothleak + alk;
                    end
                end
                iRaw = iRaw - smoothleak;
                plot(time, iRaw,'k-');

                Message = text(.7, .9,'select X range for baseline', 'Units', 'normalized', 'FontSize', 18, 'Color', 'r');
                [xmnb ytemp] = ginput(1);
                [xmxb ytemp] = ginput(1);
                delete(Message);
                ST=xmnb/time(end)*length(iRaw);
                ET = xmxb*length(iRaw)/time(end);
                baseline = iRaw(ST:ET);
                VarianceB = var(baseline);
                AverageBL= mean(baseline);


                Message = text(.7, .9,'select X range for step', 'Units', 'normalized', 'FontSize', 18, 'Color', 'r');
                [xmn ytemp] = ginput(1);
                [xmx ytemp] = ginput(1);
                delete(Message);
                ST=xmn/time(end)*length(iRaw);
                ET = xmx*length(iRaw)/time(end);
                step = iRaw(ST:ET);
                Variance = var(step);
                AverageI= mean(step);
                
                %note - assume step 2 is the pulse and ZF = 12
                v = VStep(2);
                i = -g*(v-Vs)*exp(-(v-Vs)/12)/(1-exp(-(v-Vs)/12));
                Po= 1-(Variance-VarianceB)/AverageI*i;
                N = AverageI/(Po*i);

                if VarianceB > 0.5*Variance
                    Message = text(.5, .9, 'your baseline variance is more than half your step Var', 'Units', 'normalized','FontSize', 18, 'Color', 'r');
                else
                    Message = text(.5, .9, ['Var: ', num2str(Variance), '  Avg: ', num2str(AverageI), '  Po: ', num2str(Po)],'Units', 'normalized', 'FontSize', 18, 'Color', 'r');
                end
                waitforbuttonpress;

                strColHeaders = 'xFect\tCell\tfile\trun_swp\tfreq\tRI\tV\ti\tVar(base)\t<i>base\tVariance\t<i>\tPo\tN'
              % values(k,:) = [xFect '\t' num2str(CellNum) '\t' file '\t' RunSwp '\t' num2str(freq) '\t' num2str(RI) '\t' num2str(v) '\t' num2str(i) '\t' num2str(VarianceB) '\t' num2str(AverageBL) '\t' num2str(Variance) '\t' num2str(AverageI) '\t' num2str(Po) '\t' num2str(N)  ];
                values(k,:) = [{xFect} CellNum {file} {RunSwp} freq RI v i VarianceB AverageBL Variance AverageI Po N];
            end
        
          %xlswrite('temp', values, num2str(CellNum), 'A3');
  
            UpdateGraphics;
%% Step Analysis Menu
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function Menu_AvgTraces
                global SCSTEPLATE;
                set(gcf, 'pointer', 'watch'); drawnow;
                nSel = get(SCSTEPLATE.Box, 'value');
                cla;  xlim('auto');
                %
                %             [Filename, Pathname] = uigetfile('*.xls', 'Choose the excel spreadsheet'); % user to choose file
                %             if Filename==0
                %                 return;
                %             end
                %             xlsFile = [Pathname  Filename];

                iSum = 0;
                iLkSum = 0;
                count = 0;

                for k=1:length(nSel);
%                     cla;
                    k
                    DATA = LoadData(SCSTEPLATE.datafile, SCSTEPLATE.RunSwp{nSel(k)});
                    ANALYSIS = load(SCSTEPLATE.AnalysisFile, '-mat');
                    swANALYSIS = ANALYSIS.(SCSTEPLATE.RunSwp{nSel(k)});
                    Good = [swANALYSIS.GoodBad];
                    Blank = [swANALYSIS.Blank];
                     FiltHz = swANALYSIS.FiltHz;

                    if Good==1 & Blank==0;

                        XMin = swANALYSIS.XMin;
                        XMax = swANALYSIS.XMax;
                        Tau = swANALYSIS.Tau;
                        Amp = swANALYSIS.Amp;
                        Delay = swANALYSIS.Delay;
                        m = swANALYSIS.m;
                        b = swANALYSIS.b;
                        AMin = swANALYSIS.AMin;
                        AMax = swANALYSIS.AMax;
                        swOffset = swANALYSIS.swOffset;
                        lkOffset = swANALYSIS.lkOffset;

                        SF = DATA(2).StimParams.LeakSF;
                        CellNum = DATA(1).CellNum;
                        CellNumString = ['Cell',num2str(DATA(1).DBParams.CellNum),''];
                        fullfile = SCSTEPLATE.datafile;
                        l = findstr(fullfile, '\');
                        file = fullfile(l(end)+1:end);
                        RunSwp = SCSTEPLATE.RunSwp{nSel(k)};
                        freq = DATA(1).SamplingFreqHz;
                        RI = DATA(1).StimParams.RI;
                        xFect = DATA(1).DBParams.XFect;

                        try
                            NumCh = ANALYSIS.(CellNumString).NumCh;
                            g = ANALYSIS.(CellNumString).g;
                            Vs = ANALYSIS.(CellNumString).Vs;
                        catch
                            %                     waitfor(errordlg('you must set the single channel level for this analysis'));
                        end

                        Dstep = DATA(1).StimParams.Dstep;
                        VStep = DATA(1).StimParams.Vstep;
                        time    = DATA(1).Time*1000 ;  %time in ms starting from begining of data
                        t    = DATA(1).Time*1000 - 1000*DATA(1).StimParams.PrePoints/DATA(1).SamplingFreqHz;  %time in ms where zero is at start of p2
                        iRaw = DATA(1).AcqWaveform;
                        iRaw = LowpassFilter(DATA(1).Time, iRaw, FiltHz);
                        avgLk  = mean(DATA(2).AcqWaveform,3);
% 
%                         %zero offset:
%                         if swANALYSIS.swOffset==0
%                             swOffset = mean(iRaw(10:DATA(1).StimParams.PrePoints));
%                         end
%                         if swANALYSIS.lkOffset==0
%                             lkOffset = mean(avgLk(10:DATA(1).StimParams.PrePoints));
%                         end
%                         iRaw = iRaw - swOffset;
%                         avgLk = avgLk - lkOffset;



                       % avgLk  = mean(DATA(2).AcqWaveform,3);
                       % find where the first pulse ends
                       % MBJ
                       EndofPulse1 = find(abs(diff(DATA(1).StimWaveform)),1);
                       %zero offset:
                       if swANALYSIS.swOffset==0
                            swOffset = mean(iRaw(EndofPulse1-DATA(1).StimParams.PrePoints-1:EndofPulse1));
                       end
                       if swANALYSIS.lkOffset==0
                            lkOffset = mean(avgLk(EndofPulse1-DATA(1).StimParams.PrePoints-1:EndofPulse1));
                       end
                       iRaw = iRaw - swOffset;
                       avgLk = avgLk - lkOffset;

                        
%                         iRaw = iRaw - SCSTEPLATE.swOffset;
%                         avgLk = avgLk - SCSTEPLATE.lkOffset;
                        avgLk = avgLk*SF;
                        smoothleak = 0;
                        try
                            for n=1:(length(XMin))
                                ilk = Amp(n)*exp(-(Tau(n))*(t-Delay(n)));
                                %Billy edit 05-29-2014
                                
                                ilk(t < Delay(n)) = 0;
                                ilk(t<XMin(n))=0;
                                ilk(t>XMax(n))=0;
                                smoothleak = smoothleak + real(ilk);
                            end
%                             smoothleak = LowpassFilter(DATA(1).Time, smoothleak, 1500);
                            
                        end
                        try
                            LinearFit = m*t + b;
                            smoothleak = smoothleak + LinearFit;
                        end
                        try
                            for n=1:(length(AMin));
                                alk = iRaw-smoothleak;
                                alk(t<AMin(n))=0;
                                alk(t>AMax(n))=0;
                                smoothleak = smoothleak + alk;
                            end
                        end
                        iRaw = iRaw - smoothleak;

                        prepts= 1000*DATA(1).StimParams.PrePoints/DATA(1).SamplingFreqHz;
                        v = VStep(2);
                        
                        count = 1 + count;
                        iSum = iRaw + iSum;
                        iLkSum = avgLk + iLkSum;
                        
                 end
                end
                iAvg = iSum/count;

                M= zeros(length(t), 3);
                M(:,1) = t;
                M(:,2) = iAvg;
                M(1,3) = count;
                strColHeaders = {'t' 'iAvg' 'number of traces' };

                CopyToClipboard(M, strColHeaders, {});             
                
                plot (t, iAvg,'k-');
                set(gcf, 'pointer', 'arrow');
                
              
    function Menu_FitSteps
%         global SCSTEPLATE
%         set(gcf, 'pointer', 'watch'); drawnow;
%         nSel = get(SCSTEPLATE.Box, 'value');  
%         k = 1;
%         % load data and analysis files
%         if length(nSel)>1
%             nSel = nSel(1);
%             disp('Pick One trace at a time, choosing trace 1');
%         end
%         DATA = LoadData(SCSTEPLATE.datafile, SCSTEPLATE.RunSwp{nSel(k)});
%         ANALYSIS = load(SCSTEPLATE.AnalysisFile, '-mat');
%         swANALYSIS = ANALYSIS.(SCSTEPLATE.RunSwp{nSel(k)});
%         CellNum = DATA(1).CellNum;
%         CellNumString = ['Cell',num2str(DATA(1).DBParams.CellNum),''];
%         GoodLeak = swANALYSIS.GoodLeak;
%         swOffset = swANALYSIS.swOffset;
%         lkOffset = swANALYSIS.lkOffset;
%         Tau = swANALYSIS.Tau;
%         Amp = swANALYSIS.Amp;        
%         if (findstr(DATA(1).StimName, 'Ramp'))
%             waitfor(errordlg('This tool only works for step commands'));
%         end                    
%         SF = DATA(2).StimParams.LeakSF;
%         Dstep = DATA(1).StimParams.Dstep;
%         VStep = DATA(1).StimParams.Vstep;
%         t    = DATA(1).Time*1000 - 1000*DATA(1).StimParams.PrePoints/DATA(1).SamplingFreqHz;  %time in ms
%         iRaw = DATA(1).AcqWaveform;
%         iRaw = LowpassFilter(DATA(1).Time, iRaw, FiltHz);
%         nPulses = length(DATA(1).StimParams.Vstep);
%         for i =1:length(
        
%                       
%                 if isempty(GoodLeak)
%                     GoodLeak =ones(1,length(DATA(2).AcqWaveform(1,1,:)));
%                 end
%                 LkSum = 0;
%                 for n=1:length(GoodLeak);
%                     iLeak(:,n) = DATA(2).AcqWaveform(1,:,n);
%                     if GoodLeak(n)==1;
%                         LkSum = LkSum + iLeak(:,n);
%                     end
%                 end
% 
%                 if isempty(GoodLeak)
%                     avgLk = mean(DATA(2).AcqWaveform,3);
%                 else
%                     avgLk = LkSum/sum(GoodLeak);
%                 end
% 
%                 %zero offset:
%                 if swANALYSIS.swOffset==0
%                     swOffset = mean(iRaw(10:DATA(1).StimParams.PrePoints));
%                 end
%                 if swANALYSIS.lkOffset==0
%                     lkOffset = mean(avgLk(10:DATA(1).StimParams.PrePoints));
%                 end
%                 iRaw = iRaw - swOffset;
%                 avgLk = avgLk - lkOffset;
% 
% 
%                 avgLk = avgLk*SF;
%                 iRawFilt = LowpassFilter(DATA(1).Time, iRaw, 0);
% 
%                 t1 = find(t>0, 1);
%                 t2 = find(t>299, 1);
%                 time = t(t1:t2);
%                 Leak = avgLk(t1:t2);
%                 iRawFit = iRawFilt(t1:t2)';
%                 if get(SCSTEPLATE.FitLeak, 'value')
%                     plot(time, Leak);
%                     y = Leak;
%                 else
%                     plot(time, iRawFit);
%                     y = iRawFit;
%                 end
% 
%                 %autofit(TauGuess, AmpGuess, t, avgLk);
% 
%                 t = time;
%                 %h = plot(t, y, 'r');
% 
%                 if get(SCSTEPLATE.UseGuess, 'value')
%                     start = Tau;
%                 else
%                     start = [6.4053e-005    0.088143     0.41024      3.1947      3.1112  ];
%                 end
% 
%                 % We use an anonymous function to pass additional parameters t, y, h to the
%                 % output function.
% 
% 
% %                 outputFcn = @(x,optimvalues,state) fitoutputfun(x,optimvalues,state,t,y,h);
% %                 options = optimset('OutputFcn',outputFcn,'TolX',0.1);
% %                 estimated_lambda = fminsearch(@(x)fitfun(x,t,y),start,options);
% 
% digits(6);
%                 estimated_lambda = fminsearch(@(x)fitfun(x,t,y),start);
% 
% 
%                 for n=1:length(estimated_lambda)
%                     XMin(n) = 0;
%                     XMax(n) = 300;
%                 end
%                 Tau = round(estimated_lambda/0.0001)*0.0001;
%                 Amp = round(SCSTEPLATE.AmpHold/0.001)*0.001;
%                 
%                 S.(SCSTEPLATE.RunSwp{nSel(k)})= ANALYSIS.(SCSTEPLATE.RunSwp{nSel(k)});
%                 S.(SCSTEPLATE.RunSwp{nSel(k)}).XMin = XMin;
%                 S.(SCSTEPLATE.RunSwp{nSel(k)}).XMax = XMax;
%                 %S.(SCSTEPLATE.RunSwp{nSel(k)}).Tau = estimated_lambda;
%                 S.(SCSTEPLATE.RunSwp{nSel(k)}).Tau = Tau;
%                 %S.(SCSTEPLATE.RunSwp{nSel(k)}).Amp = SCSTEPLATE.AmpHold';
%                 S.(SCSTEPLATE.RunSwp{nSel(k)}).Amp = Amp';
%                 save(SCSTEPLATE.AnalysisFile, '-struct', 'S', '-append');
%             end



            set(gcf, 'pointer', 'arrow');
            UpdateGraphics;
 
    function Menu_Measure
        global SCSTEPLATE;
        ylim('manual');
        xlim('manual');
        axis on;
        set(gcf, 'pointer', 'fullcross'); drawnow;
        nSel = get(SCSTEPLATE.Box, 'value');
        bMeasure = true;
        xlimit = get(gca, 'xlim');
        ylimit = get(gca, 'ylim');
        htext = [];
        while bMeasure
            measurement = ginput(2);
            if ~isempty(measurement)
                fprintf('t= %f   i = %5.4f\n',measurement');
                fprintf('i_LKsub = %5.4f\n -------------\n', measurement(2,2)-measurement(1,2));                                
                if isempty(htext)
                    htext = text(xlimit(1)+diff(xlimit)*0.1, ylimit(2)-(diff(ylimit)*0.9),sprintf('i = %5.4f',measurement(2,2)-measurement(1,2)),'color',[1 0 0],'fontsize',12);
                else 
                    set(htext, 'string', sprintf('i = %5.4f',measurement(2,2)-measurement(1,2)))
                end
            else
                bMeasure =false;
                
            end
        end
        delete(htext)
        set(gcf, 'pointer', 'arrow'); drawnow;       


%% Ramp Analysis Menu
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%            
    function Menu_SCRnew
        
        global SCSTEPLATE;

        set(gcf, 'pointer', 'watch'); drawnow;
        nSel = get(SCSTEPLATE.Box, 'value');
        cla;  hold on;


        %open an excell file to paste into
        [Filename, Pathname] = uigetfile('*.xls', 'Choose the excel spreadsheet'); % user to choose file
        if Filename==0
            return;
        end
        xlsFile = [Pathname  Filename];


        %M = 'File\tRun\tSwp\tGoodTrace\tGain\tFiltHz\tVmin\tVmax\tm\tb\tAmp1\tTau1\tAmp2\tTau2\tAmp3\tTau3\tconstruct\tCellNum\tnotes';
strColHeaders = {'File' 'Run' 'Swp' 'GoodTrace' 'Gain' 'FiltHz' 'Vmin' 'Vmax' 'm' 'b' 'Tau1' 'Amp1' 'Tau2' 'Amp2' 'Tau3' 'Amp3' 'construct'  'CellNum' 'notes' 'XMin' 'XMax' 'ATool' 'calc chan #' 'overide chan #'};

%         M = [M '\n'];
%         Fit = '0\t0\t0\t0\t0\t0\t0\t0';   %default fit

            N = {'NumCh'; 'g';  'Vs'; 'ZF'; 'ActivFiltHz';  'NL'; 'ActVR1'; 'ActVR2'; 'OneCh'; 'TwoCh'; 'ThreeCh'; 'GoodCell'};

       % load data and analysis files
        for k=1:length(nSel)
            DATA = LoadData(SCSTEPLATE.datafile, SCSTEPLATE.RunSwp{nSel(k)});
            ANALYSIS = load(SCSTEPLATE.AnalysisFile, '-mat');
            swANALYSIS = ANALYSIS.(SCSTEPLATE.RunSwp{nSel(k)});
            CellNum = DATA(1).CellNum;
            CellNumString = ['Cell',num2str(DATA(1).DBParams.CellNum),''];
            GoodLeak = swANALYSIS.GoodLeak;
            swOffset = swANALYSIS.swOffset;
            lkOffset = swANALYSIS.lkOffset;
            try
                NumCh = ANALYSIS.(CellNumString).NumCh;
                g = ANALYSIS.(CellNumString).g;
                Vs = ANALYSIS.(CellNumString).Vs;
            catch
                waitfor(errordlg('you need to have your conductance parameters set to do this analysis'));
            end

            FiltHz = swANALYSIS.FiltHz;
            XMin = swANALYSIS.XMin;
            XMax = swANALYSIS.XMax;
            AMin = swANALYSIS.AMin;
            AMax = swANALYSIS.AMax;

            Tau = [ 0 0 0];
            Amp = [0 0 0];
            T = swANALYSIS.Tau;
            A = swANALYSIS.Amp;
            for l=1:length(T)
                Tau(l) = T(l);
                Amp(l) = A(l);
            end
            
            m = swANALYSIS.m;
            b = swANALYSIS.b;
            RunSwp = SCSTEPLATE.RunSwp{nSel(k)};
            Run = RunSwp(4:7);
            Swp = RunSwp(12:15);
            FileTemp = SCSTEPLATE.datafile;
            m = findstr(FileTemp, '\');
            l = m(end)+1;
            %l = findstr(FileTemp, 'IED');
            File = FileTemp(l:end);

            if (findstr(DATA(1).StimName, 'Step'))
                waitfor(errordlg('This tool only works for Ramp commands'));
            end

            %SF = DATA(2).StimParams.LeakSF;
            Dstep = DATA(1).StimParams.Dstep;
            VStep = DATA(1).StimParams.Vstep;
            %t    = DATA(1).Time*1000 - 1000*DATA(1).StimParams.PrePoints/DATA(1).SamplingFreqHz;  %time in ms
            v = DATA.StimWaveform;
            iRaw = DATA(1).AcqWaveform;
            %iRaw = LowpassFilter(DATA(1).Time, iRaw, FiltHz);


            if (findstr(DATA(1).StimName, 'Ramp'))
                %M = [M '\n' File '\t' Run '\t' Swp '\t' SCSTEPLATE.GoodBad '\t' num2str(DATA(1).StimParams.Gain) '\t0\t' '-100' '\t' '100' '\t' m '\t\' b '\t' Amp(1)  '\t' Tau(1)  '\t' Amp(2)  '\t' Tau(2)  '\t' Amp(3)  '\t' Tau(3)  '\t' num2str(DATA(1).DBParams.XFect)  '\t' num2str(DATA(1).DBParams.CellNum)  '\n'];
                M(k,:) = {File  Run  Swp  SCSTEPLATE.GoodBad  num2str(DATA(1).StimParams.Gain) num2str(FiltHz)  '-100' '100' m  b  Tau(1)   Amp(1)   Tau(2)   Amp(2)   Tau(3)   Amp(3)   num2str(DATA(1).DBParams.XFect)   num2str(DATA(1).DBParams.CellNum) ' '  num2str(XMin) num2str(XMax) num2str([AMin AMax]) '0' '0' };
            end

        end

        %these parameters will determine how many channels are counted in
        %each trace - they are given some default values here and can be
        %changed in the excel sheet during analysis
        
        O ={num2str(NumCh); num2str(g); num2str(Vs); '12'; '2'; '0.1'; '-100'; '45'; 'A(1)>.015 && A(2)<.001'; 'A(2)>.001 && A(3)<.001'; 'A(3)>.001 && A(4)<.001'; '1'}  


        %clipboard('copy', sprintf(M));
        xlswrite(xlsFile, strColHeaders,['SwpCell' num2str(CellNum)], 'A9');
        xlswrite(xlsFile, M,['SwpCell' num2str(CellNum)], 'A10');
        xlswrite(xlsFile, N,['FitCell' num2str(CellNum)], 'A10');
xlswrite(xlsFile, O,['FitCell' num2str(CellNum)], 'B10');

        set(gcf, 'pointer', 'arrow');

        waitfor(helpdlg('Data has been copied to your file'));
 
        
        
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [M, g, Vs, ZF, GoodCell] = Menu_SCRCellAvg
global SCSTEPLATE;


% for now this function will read off the excel sheet as mrt originally
% designed

nSel = get(SCSTEPLATE.Box, 'value');
set(gcf, 'pointer', 'watch'); drawnow;

%read the cell-level parameters

[Filename, Pathname] = uigetfile('*.xls', 'Choose the excel spreadsheet where you saved your cell sweep analysis'); % user to choose file
        if Filename==0
            return;
        end
        xlsFile = [Pathname  Filename];
        
        
        
        DATA = LoadData(SCSTEPLATE.datafile, SCSTEPLATE.RunSwp{nSel(1)});
        CellNum = DATA(1).CellNum;
        
        %keep this bit of mrt code for now so that you can be sure you load
        %the correct trace matching the excel sheet
        [mdata, mtxt] = xlsread(xlsFile, ['SwpCell' num2str(CellNum)], 'A9:P10000');
        mtxt = mtxt(2:end, 1);
        SCRAMP.FileRunSwpGood = repmat({'' 0 0 0}, size(mdata,1), 1);
        BoxTxt = repmat({''}, size(mdata,1), 1);
        for k=1:size(mdata,1)
            SCRAMP.FileRunSwpGood(k, :) = {mtxt{k}  mdata(k,1)  mdata(k,2)  mdata(k,3)};
        end

[data, txt] = xlsread(xlsFile, ['FitCell' num2str(CellNum)], 'B10:B21');
NumCh = data(1);
g     = data(2);
Vs    = data(3);
ZF    = data(4);
ActivFiltHz = data(5);
NL          = data(6);
ActVR       = [data(7) data(8)];
GoodCell    = data(12);
if length(data)>=9 && ~isnan(data(9))
    OneCh       = data(9);
else
    OneCh = txt{1};
end
if length(data)>=10 && ~isnan(data(10))
    TwoCh       = data(10);
else
    if ischar(OneCh)
        TwoCh = txt{2};
    else
        TwoCh = txt{1};
    end
end
if length(data)>=11 && ~isnan(data(11))
    ThreeCh     = data(11);
else
    ThreeCh = txt{end};
end

%These cell-level parameters relate to an additional leak fix  %this is not
%currently working
data = xlsread(xlsFile, ['FitCell' num2str(CellNum)], 'H10:H29');
FitEnable =0; % data(end);
FitX = 0; %data(end-1);

%read the sweep-level parameters
LeakData = xlsread(xlsFile, ['SwpCell' num2str(CellNum)], ['E' num2str(10) ':X' num2str(1000)]);
Gain = LeakData(:,1);
FiltHz = LeakData(:,2);
Vmin = LeakData(:,3);
Vmax = LeakData(:,4);
% LeakData = LeakData(:,5:end);
m = LeakData(:,5);
b = LeakData(:,6);
tau1 = LeakData(:,7);
Amp1 = LeakData(:, 8);
tau2 = LeakData(:,9);
Amp2 = LeakData(:,10);
tau3 = LeakData(:,11);
Amp3 = LeakData(:,12);  %note that the older excel files have a typo where amp and tau are labled wrong, but this is the correct read of all sheets, typo is only in the header
%ied addition
%ManChan = xlsread(SCRAMP.xlsFile, ['SwpCell' num2str(SCRAMP.cell)], ['X' num2str(10+1), ':X' num2str(10+size(SCRAMP.FileRunSwpGood,1))]);
ManChan = LeakData(:,20);
% ied addition
% Activity=zeros(length(ManChan),8);  %create a matrix where the "activity" values can be stored later to guide with parameter settings if needed
% 
% Activity(:,2)=[SCRAMP.FileRunSwpGood{:,2}];
% Activity(:,3)=[SCRAMP.FileRunSwpGood{:,3}];

for k=1:size(SCRAMP.FileRunSwpGood,1)

    %     if k==26
    %         'debug'
    %     end

    DATA = LoadDataMRT(SCRAMP.FileRunSwpGood{k, 1:3}, Gain(k));
    v = DATA.StimWaveform;
    iRaw = DATA.AcqWaveform;

    if k==1
        %some temporary variables
        MasterV = v;
        Mean.i = 0*v;
        Mean.n = 0*v;
        if NumCh==1
            SubMean = [];
        else
            for n=1:NumCh
                SubMean(n).i         = 0*v;
                SubMean(n).n         = 0*v;
            end
        end

        %calculate GVT fits
        Unitary = v * 0;  %initialize
        tmpV = v - Vs;
        I = find(abs(tmpV)/ZF>.01);
        Unitary(I)  = -g*tmpV(I).*exp(-tmpV(I)/ZF)./(1 - exp(-tmpV(I)/ZF));  %traditional eqn
        I = find(abs(tmpV)/ZF<=.01);
        Unitary(I)  = -g*tmpV(I).*(1 - tmpV(I)/ZF)./(tmpV(I)/ZF);  %linearized eqn near zero

        %next, create some variables that are useful for activity determination
        I = find( v>=ActVR(1) & v <= ActVR(2) );  %limit our activity threshold over some voltage range
        UnitaryClip = Unitary(I);
        ScaledNoise = -NL./UnitaryClip;

        %         also, the leak-fix
        if FitEnable
            tmp = polyval(data(end-2:-1:1), v);
            tmp(v<FitX) = 0;
            LkFix = tmp;
        else
            LkFix = v*0;;
        end
    elseif length(MasterV) ~= length(v) || any(MasterV ~= v)
        err = 'All sweeps in a cell must have the same voltage range';
        waitfor(errordlg(err));
        error(err);
    end

    %skip if this sweep is marked bad
    if ~SCRAMP.FileRunSwpGood{k, 4}
        continue;
    end

    %     %calculate and subtract leak
    %     P = LeakData(k,:);
    %     P = P(end:-1:1);
    %     P = P(~isnan(P));
    %     iLk = polyval(P, v);
    %     iRaw = iRaw - iLk;
    %     iRaw = LowpassFilter(DATA.Time, iRaw, FiltHz(k));

    %calculate and subtract leak

    iLk = m(k)*v + b(k) + Amp1(k)*exp(-tau1(k)*v)+ Amp2(k)*exp(-tau2(k)*v) + Amp3(k)*exp(-tau3(k)*v);
    iRaw = iRaw - iLk;
    iRaw = LowpassFilter(DATA.Time, iRaw, FiltHz(k));

    %next calculate the "activity" of this sweep, and decide if it has 1,2,3 channels active

    ScaledTrace = iRaw(I)./Unitary(I);
    if ActivFiltHz
        ScaledTrace = LowpassFilter(v(I), ScaledTrace, ActivFiltHz);
    end
    for n=1:NumCh
        %activity at each timepoint is zero if lower than prev level, 1 if higher than current level, and linearly 0 to 1 if between
        Activ = (ScaledTrace-ScaledNoise-n+1);  %first subtract the floor
        Activ(Activ<0) = 0;                     %clean up anything that dropped below the floor
        Activ = Activ./(1-ScaledNoise);       %now scale up the rest
        Activ(Activ>1 | Activ<0) = 1;           %and clean up again, note, the <0 stuff matters after the noise levels cross
        TraceActivity(n) =  mean(Activ);
    end
    A = [TraceActivity 0 0 0 0]; %we create the param "A", and eval the user-given code for each level
    if NumCh>=1
        if ischar(OneCh)
            YesNo(1) = eval(OneCh);
        else
            YesNo(1) = OneCh;
        end
    end
    if NumCh>=2
        if ischar(TwoCh)
            YesNo(2) = eval(TwoCh);
        else
            YesNo(2) = TwoCh;
        end
    end
    if NumCh>=3
        if ischar(ThreeCh)
            YesNo(3) = eval(ThreeCh);
        else
            YesNo(3) = ThreeCh;
        end
    end
    if NumCh>=4
        YesNo(4:NumCh) = 0;
    end
    debugYN(k) = YesNo(1);


    %just add a count of the number of channels

    NumberOfChannels=0;
    for n=1:NumCh
        if YesNo(n);
            NumberOfChannels=n;
        end
    end

    %ied - allow a manual overide of the number of channels - careful, you
    %must have zeroes in column X when this is active
    %disp('new sweep');
    AdjChanNum=0;
    if ManChan(k)~=0
        %disp('manual');
        AdjChanNum=ManChan(k);
    else
        for n=1:NumCh
            %disp([n YesNo(n)])
            if YesNo(n)
                AdjChanNum=n;
            end
        end
    end
    %NumberOfChannels
    if AdjChanNum>=4
        AdjChanNum=0;
    end

    % (ied addition) fill in a matrix to be pasted to exel for
    % troubleshooting purposes
    Activity(k,1)=k; %fill in a matrix with the activity levels for each sweep
    Activity(k,4:7)=A(1:4);
    Activity(k,8)=NumberOfChannels;

    %finally, add this sweep to the running sums, accordingly
    %     for n=1:NumCh
    %         if YesNo(n)
    %             try
    %                 Mean.i(v>=Vmin(k)&v<=Vmax(k))  =  Mean.i(v>=Vmin(k)&v<=Vmax(k))  +  iRaw(v>=Vmin(k)&v<=Vmax(k))/n;
    %                 Mean.n(v>=Vmin(k)&v<=Vmax(k))  =  Mean.n(v>=Vmin(k)&v<=Vmax(k))  +  1;
    %
    %             catch
    %                 waitfor(errordlg(['You probably have sweeps with different sampling intervals -- this is not allowed for the same cell . . .sorry ' lasterr]));
    %                 rethrow(lasterror);
    %             end
    %
    %             if ~isempty(SubMean)
    %                 SubMean(n).i(v>=Vmin(k)&v<=Vmax(k))  =  SubMean(n).i(v>=Vmin(k)&v<=Vmax(k))  +  iRaw(v>=Vmin(k)&v<=Vmax(k))/n;
    %                 SubMean(n).n(v>=Vmin(k)&v<=Vmax(k))  =  SubMean(n).n(v>=Vmin(k)&v<=Vmax(k))  +  1;
    %             end
    %         end
    %     end
    % end

    %ied change
    %finally, add this sweep to the running sums, accordingly
    if AdjChanNum ~=0
        nc=AdjChanNum;
        try
            Mean.i(v>=Vmin(k)&v<=Vmax(k))  =  Mean.i(v>=Vmin(k)&v<=Vmax(k))  +  iRaw(v>=Vmin(k)&v<=Vmax(k))/nc;
            Mean.n(v>=Vmin(k)&v<=Vmax(k))  =  Mean.n(v>=Vmin(k)&v<=Vmax(k))  +  1;

        catch
            waitfor(errordlg(['You probably have sweeps with different sampling intervals -- this is not allowed for the same cell . . .sorry ' lasterr]));
            rethrow(lasterror);
        end

        if ~isempty(SubMean)
            SubMean(nc).i(v>=Vmin(k)&v<=Vmax(k))  =  SubMean(nc).i(v>=Vmin(k)&v<=Vmax(k))  +  iRaw(v>=Vmin(k)&v<=Vmax(k))/nc;
            SubMean(nc).n(v>=Vmin(k)&v<=Vmax(k))  =  SubMean(nc).n(v>=Vmin(k)&v<=Vmax(k))  +  1;
        end
    end
end



%divide by n to get average, also do the LkFix
Mean.i = Mean.i./Mean.n - LkFix;
for n=1:length(SubMean)
    SubMean(n).i = SubMean(n).i./SubMean(n).n - LkFix;
end

%(ied addition) put the activity levels in the clipboard to be pasted into excel if needed
%CopyToClipboard(Activity, {'index' 'run' 'sweep' '1chan'  '2chan'  '3chan'  '4chan'  '# chan'}, []);

%initialize matrix for copy/paste
M = zeros(length(v), 7+3*length(SubMean));
M(:,1) = DATA.Time;
M(:,2) = v;
M(:,3) = Unitary;
M(:,4) = LkFix;
M(:,5) = Mean.n;   %this will hold the average current
M(:,6) = Mean.i;   %this will hold the average current
M(:,7) = Mean.i./Unitary;  %this will hold the Po = AveCurrent/Unitary
for n=1:length(SubMean)
    M(:,8+3*(n-1)) = SubMean(n).n;   %this will hold the average current
    M(:,9+3*(n-1)) = SubMean(n).i;   %this will hold the average current
    M(:,10+3*(n-1)) = SubMean(n).i./Unitary;  %this will hold the Po = AveCurrent/Unitary
end

strColHeaders = {'t' 'v' 'Unitary' 'LkFix' 'n' 'Iave' 'Po'};
for n=1:length(SubMean)
    strColHeaders = [strColHeaders {[num2str(n) 'n'] [num2str(n) 'Iave'] [num2str(n) 'Po']}];
end
xlswrite(xlsFile, strColHeaders, ['FitCell' num2str(CellNum)], 'A30');
xlswrite(xlsFile, M, ['FitCell' num2str(CellNum)], 'A31');

%ied addition: add a column for # channels determined for each trace
NumChanTrace=Activity(:,8);
xlswrite(xlsFile, NumChanTrace, ['SwpCell' num2str(CellNum)],'W10');

set(gcf, 'pointer', 'arrow');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Menu_SCRFinalAvg
global SCSTEPLATE;

Cell = [];
bDone = 0;
k = 0;
h = waitbar(0);

[Filename, Pathname] = uigetfile('*.xls', 'Choose the excel spreadsheet where you saved your cell sweep analysis'); % user to choose file
if Filename==0
    return;
end
xlsFile = [Pathname  Filename];


[typ, desc] = xlsfinfo(xlsFile);
SwpCellIndex = strmatch('FitCell', desc);
for m=1:length(SwpCellIndex);
    SwpCellNum(m) = desc(SwpCellIndex(m));
CellNumTemp(m,:) = char(SwpCellNum(m));
CellNum(m,:) = CellNumTemp(m, 8:end);
end


while ~bDone
    k = k+1; 
    try
        %SCRAMP.cell = k;
        %ied addition: add an if statement so that bad cells are not run
        %through RecalculateCellAverage
        Cell(k).GoodCell = xlsread(xlsFile, ['FitCell' CellNum(k,:)], 'B21');
        %Cell(k).version = xlsread(xlsFile, ['FitCell' CellNum(k,:)], 'B22');
        if Cell(k).GoodCell;
            
            close(h);
            UpdateBox;
            h = waitbar(k/10, ['started analysis of cell # ' num2str(k)]);
%             if Cell(k).version
%                 [M, g, Vs, ZF, GoodCell] = Menu_RecalculateCellAverageMRT;
%             else
%             [M, g, Vs, ZF, GoodCell] = Menu_RecalculateCellAverage;
%             end
Params = xlsread(xlsFile, ['FitCell' CellNum(k,:)], 'B10:B20');
AvgData = xlsread(xlsFile, ['FitCell' CellNum(k,:)], 'A31:F8000');

            Cell(k).t  = AvgData(:,1);
            Cell(k).v  = AvgData(:,2);
            Cell(k).i  = AvgData(:,6);
            Cell(k).g  = Params(2);
            Cell(k).Vs = Params(3);
            Cell(k).ZF = Params(4);
            %Cell(k).GoodCell = GoodCell;
            
        end
    catch
        bDone = 1;
    end
end

% SCRAMP.cell = prevCell;
% UpdateBox;

%NOTE: all cells must have identical v -- i.e. same Vramp and Dramp
v = [];
for k=1:length(Cell)
    if Cell(k).GoodCell 
        if isempty(v)
            v = Cell(k).v;
            t = Cell(k).t;
        elseif ~all(Cell(k).v == v) || ~all(Cell(k).t == t)
            waitfor(errordlg(['All cells must have identical Vramp and Dramp, check cell#' num2str(k)]));
            return;
        end
    end
end
if isempty(v)
    waitfor(errordlg('All cells are marked as bad'));
    return;
end

%Find the average Vs, g, ZF
Vs = 0;
g  = 0;  %these should be the same for all cells, . . but just to be safe
ZF = 0;  %these should be the same for all cells, . . but just to be safe
N  = 0;
minVs = inf;
maxVs = -inf;
for k=1:length(Cell)
    if Cell(k).GoodCell
        minVs = min(minVs, Cell(k).Vs);
        maxVs = max(maxVs, Cell(k).Vs);
        Vs = Vs + Cell(k).Vs;
        g = g  + Cell(k).g;
        ZF = ZF + Cell(k).ZF;
        N = N + 1;
    end
end
Vs = Vs/N;
g  = g/N;
ZF = ZF/N;

%Next we average the current, and we correct for shifts in Vs
i = v*0;
isquare = i;     %dty adds variable for SD calc
n = v*0;
dv = v(2)-v(1);  %sampling interval
Imax = length(v);
for k=1:length(Cell)
    if Cell(k).GoodCell
        deltaI = round((Vs - Cell(k).Vs)/dv);  %#of sample points to shift cell
        Iave  = max(1,1+deltaI):min(Imax,Imax+deltaI);  %ave indices of overlap
        Icell = max(1,1-deltaI):min(Imax,Imax-deltaI);  %cell indices of overlap

        %running sum
        i(Iave) = i(Iave) + Cell(k).i(Icell);
        isquare(Iave) = isquare(Iave) + (Cell(k).i(Icell)).^2;    %dty add for SD calc
        n(Iave) = n(Iave) + 1;
    end
end
i = i./n;  %convert to mean
isquare = isquare./n;  %dty convert to mean var en route to SD
ivariance = isquare - i.^2; %dty convert to mean var en route to SD
iSD = ivariance.^(1/2); %dty convert to mean var en route to SD

%Unitary current - GHK
Unitary = v * 0;  %initialize
tmpV = v - Vs;
I = find(abs(tmpV)/ZF>.01);
Unitary(I)  = -g*tmpV(I).*exp(-tmpV(I)/ZF)./(1 - exp(-tmpV(I)/ZF));  %traditional eqn
I = find(abs(tmpV)/ZF<=.01);
Unitary(I)  = -g*tmpV(I).*(1 - tmpV(I)/ZF)./(tmpV(I)/ZF);  %linearized eqn near zero


%now write data to xls 
M = zeros(length(v), 6);
M(:,1) = t;
M(:,2) = v;
M(:,3) = Unitary;
M(:,4) = n;   %this will hold the average current
M(:,5) = i;   %this will hold the average current
M(:,6) = i./Unitary;  %this will hold the Po = AveCurrent/Unitary
M(:,7) = abs(iSD./Unitary); %dty SD of Po

strColHeaders = {'t' 'v' 'Unitary' 'N' 'Iave' 'Po' 'SD Po'};        %dty adds SD Po dump
xlswrite(xlsFile, strColHeaders, 'FinalFit', 'A30');
xlswrite(xlsFile, M, 'FinalFit', 'A31');
xlswrite(xlsFile, [g; Vs; ZF], 'FinalFit', 'B10:B12');

close(h)
waitfor(helpdlg('Analysis is complete!'));
%% temp
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function [M, g, Vs, ZF, GoodCell] = Menu_ActiveRampCellAvg
        global SCSTEPLATE;


        nSel = get(SCSTEPLATE.Box, 'value');
        set(gcf, 'pointer', 'watch'); drawnow;

        %read the cell-level parameters
        %waitfor(errordlg('This script is not written yet'));

        [Filename, Pathname] = uigetfile('*.xls', 'Choose the excel spreadsheet to save your data'); % user to choose file
        if Filename==0
            return;
        end
        xlsFile = [Pathname  Filename];

    ActivFiltHz = 2; %should make these editable
    NL          = .1;
    ActVR       = [-100 45];
    GoodCell    = 1;
    OneCh = 'A(1)>.015 && A(2)<.001';
    TwoCh =  'A(2)>.001 && A(3)<.001';
    ThreeCh = 'A(3)>.001 && A(4)<.001';

    %read the sweep-level parameters
    

    % LeakData = LeakData(:,5:end);


    %ManChan = LeakData(:,20);

  
    h = waitbar(0,'analyzing cell, please wait');
    for k=1:length(nSel) %should really combine all above into one for loop, but this is okay for now
        DATA = LoadData(SCSTEPLATE.datafile, SCSTEPLATE.RunSwp{nSel(k)});
        ANALYSIS = load(SCSTEPLATE.AnalysisFile, '-mat');
        swANALYSIS = ANALYSIS.(SCSTEPLATE.RunSwp{nSel(k)});
        CellNum = DATA(1).CellNum;
        CellNumString = ['Cell',num2str(DATA(1).DBParams.CellNum),''];
        Gain = num2str(DATA(1).StimParams.Gain);
       waitbar(k/(length(nSel)));

        %read in some parameter values from data and analysis files
        try
            NumCh = ANALYSIS.(CellNumString).NumCh;
            g = ANALYSIS.(CellNumString).g;
            Vs = ANALYSIS.(CellNumString).Vs;
        catch
            NumCh = 1;
            g = 0;
            Vs = 0;
        end
        ZF    = 12;
        Construct = DATA(1).XFect;
        RI = 0;%DATA(1).StimParams.RI;
        VStep = [];
        FiltHz(k) = swANALYSIS.FiltHz;
        XMin = swANALYSIS.XMin;
        XMax = swANALYSIS.XMax;
        Tau = swANALYSIS.Tau;
        Amp = swANALYSIS.Amp;
        m = swANALYSIS.m;
        b = swANALYSIS.b;
        swOffset = swANALYSIS.swOffset;
        lkOffset = swANALYSIS.lkOffset;
        SF = [];
        GoodBad = swANALYSIS.GoodBad;
        Blank = swANALYSIS.Blank;
        AMin = swANALYSIS.AMin;
        AMax = swANALYSIS.AMax;
        GoodLeak = swANALYSIS.GoodLeak;
        

        v = DATA.StimWaveform;
        iRaw = DATA.AcqWaveform;

        if k==1
            %some temporary variables
            MasterV = v;
            Mean.i = 0*v;
            Mean.n = 0*v;
            if NumCh==1
                SubMean = [];
            else
                for n=1:NumCh
                    SubMean(n).i         = 0*v;
                    SubMean(n).n         = 0*v;
                end
            end

            %calculate GVT fits
            Unitary = v * 0;  %initialize
            tmpV = v - Vs;
            I = find(abs(tmpV)/ZF>.01);
            Unitary(I)  = -g*tmpV(I).*exp(-tmpV(I)/ZF)./(1 - exp(-tmpV(I)/ZF));  %traditional eqn
            I = find(abs(tmpV)/ZF<=.01);
            Unitary(I)  = -g*tmpV(I).*(1 - tmpV(I)/ZF)./(tmpV(I)/ZF);  %linearized eqn near zero

            %next, create some variables that are useful for activity determination
            I = find( v>=ActVR(1) & v <= ActVR(2) );  %limit our activity threshold over some voltage range
            UnitaryClip = Unitary(I);
            ScaledNoise = -NL./UnitaryClip;

            %         also, the leak-fix
            %          if FitEnable
            %              tmp = polyval(data(end-2:-1:1), v);
            %              tmp(v<FitX) = 0;
            %              LkFix = tmp;
            %          else
            LkFix = v*0;;
            %          end
        elseif length(MasterV) ~= length(v) || any(MasterV ~= v)
            err = 'All sweeps in a cell must have the same voltage range';
            waitfor(errordlg(err));
            error(err);
        end

        %skip if this sweep is marked bad
        if ~GoodBad
            continue;
        end

        %calculate and subtract leak

        smoothleak = 0;
        for n=1:(length(XMin))
            ilk = Amp(n)*exp(-(Tau(n))*v);
            ilk(v<XMin(n))=0;
            ilk(v>XMax(n))=0;
            smoothleak = smoothleak + ilk;
        end
        try
            LinearFit = m*v + b;
            smoothleak = smoothleak + LinearFit;
        end
        try
            for n=1:(length(AMin));
                alk = iRaw-smoothleak;
                alk(v<AMin(n))=0;
                alk(v>AMax(n))=0;
                smoothleak = smoothleak + alk;
            end
        end


        % iLk = m(k)*v + b(k) + Amp1(k)*exp(-tau1(k)*v)+ Amp2(k)*exp(-tau2(k)*v) + Amp3(k)*exp(-tau3(k)*v);
        iRaw = iRaw - smoothleak;
        iRaw = LowpassFilter(DATA.Time, iRaw, FiltHz(k));

        %next calculate the "activity" of this sweep, and decide if it has 1,2,3 channels active

        ScaledTrace = iRaw(I)./Unitary(I);
        if ActivFiltHz
            ScaledTrace = LowpassFilter(v(I), ScaledTrace, ActivFiltHz);
        end
        for n=1:NumCh
            %activity at each timepoint is zero if lower than prev level, 1 if higher than current level, and linearly 0 to 1 if between
            Activ = (ScaledTrace-ScaledNoise-n+1);  %first subtract the floor
            Activ(Activ<0) = 0;                     %clean up anything that dropped below the floor
            Activ = Activ./(1-ScaledNoise);       %now scale up the rest
            Activ(Activ>1 | Activ<0) = 1;           %and clean up again, note, the <0 stuff matters after the noise levels cross
            TraceActivity(n) =  mean(Activ);
        end
        A = [TraceActivity 0 0 0 0]; %we create the param "A", and eval the user-given code for each level
        if NumCh>=1
            if ischar(OneCh)
                YesNo(1) = eval(OneCh);
            else
                YesNo(1) = OneCh;
            end
        end
        if NumCh>=2
            if ischar(TwoCh)
                YesNo(2) = eval(TwoCh);
            else
                YesNo(2) = TwoCh;
            end
        end
        if NumCh>=3
            if ischar(ThreeCh)
                YesNo(3) = eval(ThreeCh);
            else
                YesNo(3) = ThreeCh;
            end
        end
        if NumCh>=4
            YesNo(4:NumCh) = 0;
        end
        debugYN(k) = YesNo(1);


        %just add a count of the number of channels

        NumberOfChannels=0;
        for n=1:NumCh
            if YesNo(n);
                NumberOfChannels=n;
            end
        end

        %ied - allow a manual overide of the number of channels - careful, you
        %must have zeroes in column X when this is active
        %disp('new sweep');
        AdjChanNum=0;
        %     if ManChan(k)~=0
        %         %disp('manual');
        %         AdjChanNum=ManChan(k);
        %     else
        for n=1:NumCh
            %disp([n YesNo(n)])
            if YesNo(n)
                AdjChanNum=n;
            end
        end
        %     end
        %     %NumberOfChannels
        %     if AdjChanNum>=4
        %         AdjChanNum=0;
        %     end

        % (ied addition) fill in a matrix to be pasted to exel for
        % troubleshooting purposes
        %     Activity(k,1)=k; %fill in a matrix with the activity levels for each sweep
        %     Activity(k,4:7)=A(1:4);
        %     Activity(k,8)=NumberOfChannels;

        %ied change
        %finally, add this sweep to the running sums, accordingly
        Vmin(k) = -100;
        Vmax(k) = 100; %should adjust code below to remove Vmin and max, they are obsolete w/ the a tool
        if AdjChanNum ~=0
            nc=AdjChanNum;
            try
                Mean.i(v>=Vmin(k)&v<=Vmax(k))  =  Mean.i(v>=Vmin(k)&v<=Vmax(k))  +  iRaw(v>=Vmin(k)&v<=Vmax(k))/nc;
                Mean.n(v>=Vmin(k)&v<=Vmax(k))  =  Mean.n(v>=Vmin(k)&v<=Vmax(k))  +  1;

            catch
                waitfor(errordlg(['You probably have sweeps with different sampling intervals -- this is not allowed for the same cell . . .sorry ' lasterr]));
                rethrow(lasterror);
            end

            if ~isempty(SubMean)
                SubMean(nc).i(v>=Vmin(k)&v<=Vmax(k))  =  SubMean(nc).i(v>=Vmin(k)&v<=Vmax(k))  +  iRaw(v>=Vmin(k)&v<=Vmax(k))/nc;
                SubMean(nc).n(v>=Vmin(k)&v<=Vmax(k))  =  SubMean(nc).n(v>=Vmin(k)&v<=Vmax(k))  +  1;
            end
        end
    end

    %divide by n to get average, also do the LkFix
    Mean.i = Mean.i./Mean.n - LkFix;
    for n=1:length(SubMean)
        SubMean(n).i = SubMean(n).i./SubMean(n).n - LkFix;
    end

    %(ied addition) put the activity levels in the clipboard to be pasted into excel if needed
    %CopyToClipboard(Activity, {'index' 'run' 'sweep' '1chan'  '2chan'  '3chan'  '4chan'  '# chan'}, []);

    %initialize matrix for copy/paste
    M = zeros(length(v), 7+3*length(SubMean));
    M(:,1) = DATA.Time;
    M(:,2) = v;
    M(:,3) = Unitary;
    M(:,4) = LkFix;
    M(:,5) = Mean.n;   %this will hold the average current
    M(:,6) = Mean.i;   %this will hold the average current
    M(:,7) = Mean.i./Unitary;  %this will hold the Po = AveCurrent/Unitary
    for n=1:length(SubMean)
        M(:,8+3*(n-1)) = SubMean(n).n;   %this will hold the average current
        M(:,9+3*(n-1)) = SubMean(n).i;   %this will hold the average current
        M(:,10+3*(n-1)) = SubMean(n).i./Unitary;  %this will hold the Po = AveCurrent/Unitary
    end

    strColHeaders = {'t' 'v' 'Unitary' 'LkFix' 'n' 'Iave' 'Po'};
    for n=1:length(SubMean)
        strColHeaders = [strColHeaders {[num2str(n) 'n'] [num2str(n) 'Iave'] [num2str(n) 'Po']}];
    end
    N = {'NumCh'; 'g';  'Vs'; 'ZF'; 'ActivFiltHz';  'NL'; 'ActVR1'; 'ActVR2'; 'OneCh'; 'TwoCh'; 'ThreeCh'; 'GoodCell'};
    %make this real numbers
    O ={num2str(NumCh); num2str(g); num2str(Vs); '12'; '2'; '0.1'; '-100'; '45'; 'A(1)>.015 && A(2)<.001'; 'A(2)>.001 && A(3)<.001'; 'A(3)>.001 && A(4)<.001'; '1'};

    xlswrite(xlsFile, strColHeaders, ['FitCell' num2str(CellNum)], 'A30');
    xlswrite(xlsFile, M, ['FitCell' num2str(CellNum)], 'A31');
    xlswrite(xlsFile, N,['FitCell' num2str(CellNum)], 'A10');
    xlswrite(xlsFile, O,['FitCell' num2str(CellNum)], 'B10');

    %ied addition: add a column for # channels determined for each trace
    % NumChanTrace=Activity(:,8);
    % xlswrite(xlsFile, NumChanTrace, ['SwpCell' num2str(CellNum)],'W11');
close(h);
   % waitfor(helpdlg('Analysis is complete!'));
    set(gcf, 'pointer', 'arrow');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function [M, g, Vs, ZF, GoodCell] = Menu_RampCellAvgBlank
            global SCSTEPLATE;


            nSel = get(SCSTEPLATE.Box, 'value');
            set(gcf, 'pointer', 'watch'); drawnow;

            %read the cell-level parameters
            %waitfor(errordlg('This script is not written yet'));

            [Filename, Pathname] = uigetfile('*.xls', 'Choose the excel spreadsheet to save your data'); % user to choose file
            if Filename==0
                return;
            end
            xlsFile = [Pathname  Filename];

            ActivFiltHz = 2; %should make these editable
            NL          = .1;
            ActVR       = [-100 45];
            GoodCell    = 1;
            OneCh = 'A(1)>.015 && A(2)<.001';
            TwoCh =  'A(2)>.001 && A(3)<.001';
            ThreeCh = 'A(3)>.001 && A(4)<.001';

            %read the sweep-level parameters


            % LeakData = LeakData(:,5:end);


            %ManChan = LeakData(:,20);
            waitfor(helpdlg('Make sure your channel number is set correctly, it will be used for every sweep'));

            h = waitbar(0,'analyzing cell, please wait');
            for k=1:length(nSel) %should really combine all above into one for loop, but this is okay for now
                DATA = LoadData(SCSTEPLATE.datafile, SCSTEPLATE.RunSwp{nSel(k)});
                ANALYSIS = load(SCSTEPLATE.AnalysisFile, '-mat');
                swANALYSIS = ANALYSIS.(SCSTEPLATE.RunSwp{nSel(k)});
                CellNum = DATA(1).CellNum;
                CellNumString = ['Cell',num2str(DATA(1).DBParams.CellNum),''];
                Gain = num2str(DATA(1).StimParams.Gain);
                waitbar((k-1)/(length(nSel)));

                %read in some parameter values from data and analysis files
                try
                    NumCh = ANALYSIS.(CellNumString).NumCh;
                    g = ANALYSIS.(CellNumString).g;
                    Vs = ANALYSIS.(CellNumString).Vs;
                catch
                    NumCh = 1;
                    g = 0;
                    Vs = 0;
                end
                ZF    = 12;
                Construct = DATA(1).XFect;
                RI = 0;%DATA(1).StimParams.RI;
                VStep = [];
                FiltHz(k) = swANALYSIS.FiltHz;
                XMin = swANALYSIS.XMin;
                XMax = swANALYSIS.XMax;
                Tau = swANALYSIS.Tau;
                Amp = swANALYSIS.Amp;
                m = swANALYSIS.m;
                b = swANALYSIS.b;
                swOffset = swANALYSIS.swOffset;
                lkOffset = swANALYSIS.lkOffset;
                SF = [];
                GoodBad = swANALYSIS.GoodBad;
                Blank = swANALYSIS.Blank;
                AMin = swANALYSIS.AMin;
                AMax = swANALYSIS.AMax;
                GoodLeak = swANALYSIS.GoodLeak;


                v = DATA.StimWaveform;
                iRaw = DATA.AcqWaveform;

                if k==1
                    %some temporary variables
                    MasterV = v;
                    Mean.i = 0*v;
                    Mean.n = 0*v;
                    if NumCh==1
                        SubMean = [];
                    else
                        for n=1:NumCh
                            SubMean(n).i         = 0*v;
                            SubMean(n).n         = 0*v;
                        end
                    end

                    % MBJ HACK FOR NOW ... to idealize. 
                    %calculate GVT fits
                    Unitary = v * 0;  %initialize
                    tmpV = v - Vs;
                    I = find(abs(tmpV)/ZF>.01);
                    Unitary(I)  = -g*tmpV(I).*exp(-tmpV(I)/ZF)./(1 - exp(-tmpV(I)/ZF));  %traditional eqn
                    I = find(abs(tmpV)/ZF<=.01);
                    Unitary(I)  = -g*tmpV(I).*(1 - tmpV(I)/ZF)./(tmpV(I)/ZF);  %linearized eqn near zero

                    
                                     
                    %next, create some variables that are useful for activity determination
                    I = find( v>=ActVR(1) & v <= ActVR(2) );  %limit our activity threshold over some voltage range
                    UnitaryClip = Unitary(I);
                    ScaledNoise = -NL./UnitaryClip;

                    %         also, the leak-fix
                    %          if FitEnable
                    %              tmp = polyval(data(end-2:-1:1), v);
                    %              tmp(v<FitX) = 0;
                    %              LkFix = tmp;
                    %          else
                    LkFix = v*0;;
                    %          end
                elseif length(MasterV) ~= length(v) || any(MasterV ~= v)
                    err = 'All sweeps in a cell must have the same voltage range';
                    waitfor(errordlg(err));
                    error(err);
                end

                %skip if this sweep is marked bad
                if ~GoodBad
                    continue;
                end

                %calculate and subtract leak

                smoothleak = 0;
                for n=1:(length(XMin))
                    ilk = Amp(n)*exp(-(Tau(n))*v);
                    ilk(v<XMin(n))=0;
                    ilk(v>XMax(n))=0;
                    smoothleak = smoothleak + ilk;
                end
                try
                    LinearFit = m*v + b;
                    smoothleak = smoothleak + LinearFit;
                end
                try
                    for n=1:(length(AMin));
                        alk = iRaw-smoothleak;
                        alk(v<AMin(n))=0;
                        alk(v>AMax(n))=0;
                        smoothleak = smoothleak + alk;
                    end
                end


                % iLk = m(k)*v + b(k) + Amp1(k)*exp(-tau1(k)*v)+ Amp2(k)*exp(-tau2(k)*v) + Amp3(k)*exp(-tau3(k)*v);
                iRaw = iRaw - smoothleak;
                iRaw = LowpassFilter(DATA.Time, iRaw, FiltHz(k));


                %next calculate the "activity" of this sweep, and decide if it has 1,2,3 channels active

                ScaledTrace = iRaw(I)./Unitary(I);
                if ActivFiltHz
                    ScaledTrace = LowpassFilter(v(I), ScaledTrace, ActivFiltHz);
                end
                for n=1:NumCh
                    %activity at each timepoint is zero if lower than prev level, 1 if higher than current level, and linearly 0 to 1 if between
                    Activ = (ScaledTrace-ScaledNoise-n+1);  %first subtract the floor
                    Activ(Activ<0) = 0;                     %clean up anything that dropped below the floor
                    Activ = Activ./(1-ScaledNoise);       %now scale up the rest
                    Activ(Activ>1 | Activ<0) = 1;           %and clean up again, note, the <0 stuff matters after the noise levels cross
                    TraceActivity(n) =  mean(Activ);
                end
                A = [TraceActivity 0 0 0 0]; %we create the param "A", and eval the user-given code for each level
                if NumCh>=1
                    if ischar(OneCh)
                        YesNo(1) = eval(OneCh);
                    else
                        YesNo(1) = OneCh;
                    end
                end
                if NumCh>=2
                    if ischar(TwoCh)
                        YesNo(2) = eval(TwoCh);
                    else
                        YesNo(2) = TwoCh;
                    end
                end
                if NumCh>=3
                    if ischar(ThreeCh)
                        YesNo(3) = eval(ThreeCh);
                    else
                        YesNo(3) = ThreeCh;
                    end
                end
                if NumCh>=4
                    YesNo(4:NumCh) = 0;
                end
                debugYN(k) = YesNo(1);


                %just add a count of the number of channels

                NumberOfChannels=0;
                for n=1:NumCh
                    if YesNo(n);
                        NumberOfChannels=n;
                    end
                end


                Vmin(k) = -100;
                Vmax(k) = 100; %should adjust code below to remove Vmin and max, they are obsolete w/ the a tool

                nc=NumCh;
                try
                    Mean.i(v>=Vmin(k)&v<=Vmax(k))  =  Mean.i(v>=Vmin(k)&v<=Vmax(k))  +  iRaw(v>=Vmin(k)&v<=Vmax(k))/nc;
                    Mean.n(v>=Vmin(k)&v<=Vmax(k))  =  Mean.n(v>=Vmin(k)&v<=Vmax(k))  +  1;

                catch
                    waitfor(errordlg(['You probably have sweeps with different sampling intervals -- this is not allowed for the same cell . . .sorry ' lasterr]));
                    rethrow(lasterror);
                end

                if ~isempty(SubMean)
                    SubMean(nc).i(v>=Vmin(k)&v<=Vmax(k))  =  SubMean(nc).i(v>=Vmin(k)&v<=Vmax(k))  +  iRaw(v>=Vmin(k)&v<=Vmax(k))/nc;
                    SubMean(nc).n(v>=Vmin(k)&v<=Vmax(k))  =  SubMean(nc).n(v>=Vmin(k)&v<=Vmax(k))  +  1;
                end
            end


            %divide by n to get average, also do the LkFix
            Mean.i = Mean.i./Mean.n - LkFix;
            for n=1:length(SubMean)
                SubMean(n).i = SubMean(n).i./SubMean(n).n - LkFix;
            end

            %(ied addition) put the activity levels in the clipboard to be pasted into excel if needed
            %CopyToClipboard(Activity, {'index' 'run' 'sweep' '1chan'  '2chan'  '3chan'  '4chan'  '# chan'}, []);

            %initialize matrix for copy/paste
            M = zeros(length(v), 7+3*length(SubMean));
            M(:,1) = DATA.Time;
            M(:,2) = v;
            M(:,3) = Unitary;
            M(:,4) = LkFix;
            M(:,5) = Mean.n;   %this will hold the average current
            M(:,6) = Mean.i;   %this will hold the average current
            M(:,7) = Mean.i./Unitary;  %this will hold the Po = AveCurrent/Unitary
            for n=1:length(SubMean)
                M(:,8+3*(n-1)) = SubMean(n).n;   %this will hold the average current
                M(:,9+3*(n-1)) = SubMean(n).i;   %this will hold the average current
                M(:,10+3*(n-1)) = SubMean(n).i./Unitary;  %this will hold the Po = AveCurrent/Unitary
            end

            strColHeaders = {'t' 'v' 'Unitary' 'LkFix' 'n' 'Iave' 'Po'};
            for n=1:length(SubMean)
                strColHeaders = [strColHeaders {[num2str(n) 'n'] [num2str(n) 'Iave'] [num2str(n) 'Po']}];
            end
            N = {'NumCh'; 'g';  'Vs'; 'ZF'; 'ActivFiltHz';  'NL'; 'ActVR1'; 'ActVR2'; 'OneCh'; 'TwoCh'; 'ThreeCh'; 'GoodCell'};
            %make this real numbers
            O ={num2str(NumCh); num2str(g); num2str(Vs); '12'; '2'; '0.1'; '-100'; '45'; 'A(1)>.015 && A(2)<.001'; 'A(2)>.001 && A(3)<.001'; 'A(3)>.001 && A(4)<.001'; '1'};

            xlswrite(xlsFile, strColHeaders, ['FitCell' num2str(CellNum)], 'A30');
            xlswrite(xlsFile, M, ['FitCell' num2str(CellNum)], 'A31');
            xlswrite(xlsFile, N,['FitCell' num2str(CellNum)], 'A10');
            xlswrite(xlsFile, O,['FitCell' num2str(CellNum)], 'B10');

            %ied addition: add a column for # channels determined for each trace
            % NumChanTrace=Activity(:,8);
            % xlswrite(xlsFile, NumChanTrace, ['SwpCell' num2str(CellNum)],'W11');
            close(h);
            % waitfor(helpdlg('Analysis is complete!'));
            set(gcf, 'pointer', 'arrow');

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%     

%% General Button functions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function GoodBad
            global SCSTEPLATE;
            set(gcf, 'pointer', 'watch'); drawnow;
            nSel = get(SCSTEPLATE.Box, 'value');

            for k=1:length(nSel)
                ANALYSIS = load(SCSTEPLATE.AnalysisFile, '-mat');
                S.(SCSTEPLATE.RunSwp{(nSel(k))})= ANALYSIS.(SCSTEPLATE.RunSwp{nSel(k)});
                PrevSelection = S.(SCSTEPLATE.RunSwp{(nSel(k))}).GoodBad;
                S.(SCSTEPLATE.RunSwp{(nSel(k))}).GoodBad = ~PrevSelection;
                
                % BK Edit 08/14/2014
              
                % Update global g/b vector
                if PrevSelection %If good before, update to bad
                    SCSTEPLATE.FitData.GoodBad(nSel(k)) = 0;
                    % Add to list
                    SCSTEPLATE.FitData.BadInd = [SCSTEPLATE.FitData.BadInd; nSel(k)];
                    SCSTEPLATE.FitData.BadInd = unique(SCSTEPLATE.FitData.BadInd);
                else %update to good
                    SCSTEPLATE.FitData.GoodBad(nSel(k)) = 1;
                    %Remove from list
                    if ~isempty(find(SCSTEPLATE.FitData.BadInd == nSel(k)))
                        ind = find(SCSTEPLATE.FitData.BadInd == nSel(k));
                        SCSTEPLATE.FitData.BadInd(ind) = [];
                    end
                end
            end
            save(SCSTEPLATE.AnalysisFile, '-struct', 'S', '-append');
            set(gcf, 'pointer', 'arrow');
            sum(SCSTEPLATE.FitData.GoodBad);
            UpdateGraphics;

        function FinalFit
            global SCSTEPLATE;
            nSel = get(SCSTEPLATE.Box, 'value');

            for k = 1:length(nSel)
                SCSTEPLATE.FitData.FinalFit(nSel(k)) = ~SCSTEPLATE.FitData.FinalFit(nSel(k));    
                %set(SCSTEPLATE.FitToUse.Edit, 'value', ~get(SCSTEPLATE.FitToUse.Edit, 'value'));
            end
%             disp('Fit Changed');
%             disp(SCSTEPLATE.FitData.FinalFit(k));
            UpdateGraphics;
            
            
            function Bad
            global SCSTEPLATE;

            set(gcf, 'pointer', 'watch'); drawnow;
            nSel = get(SCSTEPLATE.Box, 'value');

            for k=1:length(nSel)
                ANALYSIS = load(SCSTEPLATE.AnalysisFile, '-mat');
                S.(SCSTEPLATE.RunSwp{(nSel(k))})= ANALYSIS.(SCSTEPLATE.RunSwp{nSel(k)});
                S.(SCSTEPLATE.RunSwp{(nSel(k))}).GoodBad = 0;
                % BK Edit 08/14/2014
                % Use a global GoodBad vector instead of saving
                SCSTEPLATE.FitData.GoodBad(nSel(k)) = 0;
                % Add to list
                SCSTEPLATE.FitData.BadInd = [SCSTEPLATE.FitData.BadInd; nSel(k)];
                SCSTEPLATE.FitData.BadInd = unique(SCSTEPLATE.FitData.BadInd);

            end
            save(SCSTEPLATE.AnalysisFile, '-struct', 'S', '-append');
            set(gcf, 'pointer', 'arrow');
            UpdateGraphics;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function Good
            global SCSTEPLATE;

            set(gcf, 'pointer', 'watch'); drawnow;
            nSel = get(SCSTEPLATE.Box, 'value');

            for k=1:length(nSel)
                ANALYSIS = load(SCSTEPLATE.AnalysisFile, '-mat');
                S.(SCSTEPLATE.RunSwp{(nSel(k))})= ANALYSIS.(SCSTEPLATE.RunSwp{nSel(k)});
                S.(SCSTEPLATE.RunSwp{(nSel(k))}).GoodBad = 1;
                
                % BK Edit 08/14/2014
                % Use a global GoodBad vector instead of saving
                SCSTEPLATE.FitData.GoodBad(nSel(k)) = 1;
                %Remove from list
                if ~isempty(find(SCSTEPLATE.FitData.BadInd == nSel(k)))
                    ind = find(SCSTEPLATE.FitData.BadInd == nSel(k));
                    SCSTEPLATE.FitData.BadInd(ind) = [];
                end
                
            end
            save(SCSTEPLATE.AnalysisFile, '-struct', 'S', '-append');
            set(gcf, 'pointer', 'arrow');
            
                        
            
            UpdateGraphics;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function Blank
            global SCSTEPLATE;

            set(gcf, 'pointer', 'watch'); drawnow;
            nSel = get(SCSTEPLATE.Box, 'value');

            for k=1:length(nSel)
                ANALYSIS = load(SCSTEPLATE.AnalysisFile, '-mat');
                swANALYSIS = ANALYSIS.(SCSTEPLATE.RunSwp{nSel(k)});
                Blank = swANALYSIS.Blank;
                S.(SCSTEPLATE.RunSwp{(nSel(k))})= ANALYSIS.(SCSTEPLATE.RunSwp{nSel(k)});
                if Blank == 0;
                    S.(SCSTEPLATE.RunSwp{(nSel(k))}).Blank = 1;
                          else
                   S.(SCSTEPLATE.RunSwp{(nSel(k))}).Blank = 0;
                end

            end
            save(SCSTEPLATE.AnalysisFile, '-struct', 'S', '-append');
            set(gcf, 'pointer', 'arrow');
            UpdateGraphics;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function SaveFit
            % Save the current fit
            global SCSTEPLATE;
            clc;
            disp('Saving all fit data and analysis params...');
            set(gcf, 'pointer', 'watch'); drawnow;
            nSel = get(SCSTEPLATE.Box, 'value');
            
            DATA = LoadData(SCSTEPLATE.datafile, SCSTEPLATE.RunSwp{(nSel(1))});
                        
            S.FitData.AutoFit = SCSTEPLATE.FitData.AutoFit;
            S.FitData.ManualFit = SCSTEPLATE.FitData.ManualFit;
            S.FitData.FinalFit = SCSTEPLATE.FitData.FinalFit;
            S.FitData.AutoFitOffset = SCSTEPLATE.FitData.AutoFitOffset;
            S.FitData.Time = SCSTEPLATE.FitData.Time;
            S.FitData.RawData = SCSTEPLATE.FitData.RawData;
            S.FitData.RawLkData = SCSTEPLATE.FitData.RawLkData;
            S.FitData.FamVec = SCSTEPLATE.FitData.FamVec;
            S.FitData.GoodBad = SCSTEPLATE.FitData.GoodBad;
            S.FitData.BadInd = SCSTEPLATE.FitData.BadInd;
            S.FitData.Mean =  SCSTEPLATE.FitData.Mean;
            S.FitData.Variance = SCSTEPLATE.FitData.Variance;
            S.FitData.FamVoltage = SCSTEPLATE.FitData.FamVoltage;
                    
            S.DataAnalysisParams.SwpWind = SCSTEPLATE.DataAnalysisParams.SwpWind;
            S.DataAnalysisParams.TimeWind = SCSTEPLATE.DataAnalysisParams.TimeWind;
            S.DataAnalysisParams.InstruWind = SCSTEPLATE.DataAnalysisParams.InstruWind;
            S.DataAnalysisParams.AmpHistCurrentBin = SCSTEPLATE.DataAnalysisParams.AmpHistCurrentBin;
            S.DataAnalysisParams.BinoFitChRange = SCSTEPLATE.DataAnalysisParams.BinoFitChRange;
            S.DataAnalysisParams.BinoFitStTime = SCSTEPLATE.DataAnalysisParams.BinoFitStTime;
            S.DataAnalysisParams.UnitaryCurrent = SCSTEPLATE.DataAnalysisParams.UnitaryCurrent;
            S.DataAnalysisParams.NumCh = SCSTEPLATE.DataAnalysisParams.NumCh;
     
        
            save(SCSTEPLATE.AnalysisFile, '-struct', 'S', '-append');
            disp('Fit data/analysis params saved');
            UpdateGraphics;
            set(gcf, 'pointer', 'arrow');
            
        function EditParam
            global SCSTEPLATE;
            % Get input from user
            prompt={'Enter Sweep Window Low:',...
                'Enter Sweep Window High:',...
                'Enter Time Window Low:',...
                'Enter Time Window High:',...
                'Enter Instrument Window Low:',...
                'Enter Instrument Window High:',...
                'Enter AmpHist Current Bin Low (pA):',...
                'Enter AmpHist Current Bin High (pA):',...
                'Enter BinoFit Num Channel to Test Low:',...
                'Enter BinoFit Num Channel to Test High:',...
                'Enter BinoFit Start Time Window Low:',...
                'Enter BinoFit Start Time Window High:',...
                'Enter Number of Channels:',...
                'Enter Unitary Current (sep. by spaces):'};
            name='Data Analysis Parameters';
            numlines=1;
            
            % Update default answers
            defaultanswer = {num2str(SCSTEPLATE.DataAnalysisParams.SwpWind(1)), num2str(SCSTEPLATE.DataAnalysisParams.SwpWind(2)), ...
                num2str(SCSTEPLATE.DataAnalysisParams.TimeWind(1)), num2str(SCSTEPLATE.DataAnalysisParams.TimeWind(2)), ...
                num2str(SCSTEPLATE.DataAnalysisParams.InstruWind(1)), num2str(SCSTEPLATE.DataAnalysisParams.InstruWind(2)), ...
                num2str(SCSTEPLATE.DataAnalysisParams.AmpHistCurrentBin(1)), num2str(SCSTEPLATE.DataAnalysisParams.AmpHistCurrentBin(2)), ...
                num2str(SCSTEPLATE.DataAnalysisParams.BinoFitChRange(1)), num2str(SCSTEPLATE.DataAnalysisParams.BinoFitChRange(2)), ...
                num2str(SCSTEPLATE.DataAnalysisParams.BinoFitStTime(1)), num2str(SCSTEPLATE.DataAnalysisParams.BinoFitStTime(2)), ...
                num2str(SCSTEPLATE.DataAnalysisParams.NumCh), num2str(SCSTEPLATE.DataAnalysisParams.UnitaryCurrent)};
            
            % Get user input
            answer = inputdlg(prompt,name,numlines,defaultanswer);
            
            % Save the new input
            SCSTEPLATE.DataAnalysisParams.SwpWind = [str2num(answer{1}) str2num(answer{2})];
            SCSTEPLATE.DataAnalysisParams.TimeWind = [str2num(answer{3}) str2num(answer{4})];
            SCSTEPLATE.DataAnalysisParams.InstruWind = [str2num(answer{5}) str2num(answer{6})];
            SCSTEPLATE.DataAnalysisParams.AmpHistCurrentBin = [str2num(answer{7}) str2num(answer{8})];
            SCSTEPLATE.DataAnalysisParams.BinoFitChRange = [str2num(answer{9}) str2num(answer{10})];
            SCSTEPLATE.DataAnalysisParams.BinoFitStTime = [str2num(answer{11}) str2num(answer{12})];
            SCSTEPLATE.DataAnalysisParams.NumCh = str2num(answer{13});
            SCSTEPLATE.DataAnalysisParams.UnitaryCurrent = str2num(answer{14});
            
            function StepLk

    global SCSTEPLATE;
    set(gcf, 'pointer', 'watch'); drawnow;
    nSel = get(SCSTEPLATE.Box, 'value');
    if length(nSel)>1
         waitfor(errordlg('you may only have one sweep selected for leak selection'));
    else
        DATA = LoadData(SCSTEPLATE.datafile, SCSTEPLATE.RunSwp{nSel});
        if (findstr(DATA(1).StimName, 'Ramp'))
            waitfor(errordlg('leaks are not recorded for ramps'));
        else
            Dstep = DATA(1).StimParams.Dstep;
            t    = DATA(1).Time*1000 - 1000*DATA(1).StimParams.PrePoints/DATA(1).SamplingFreqHz;  %time in ms
            iRaw = DATA(1).AcqWaveform - SCSTEPLATE.swOffset;
            %avgLk  = (mean(DATA(2).AcqWaveform,3) - SCSTEPLATE.lkOffset)*SCSTEPLATE.SF;
            GoodLeak = ones(1,length(DATA(2).AcqWaveform(1,1,:)));
            LkSum = 0;
            for n=1:length(DATA(2).AcqWaveform(1,1,:))
                iLeak(:,n) = (DATA(2).AcqWaveform(1,:,n) - SCSTEPLATE.lkOffset)*SCSTEPLATE.SF;
                cla; hold on;
                plot(t, iRaw,'k-');
                plot(t, iLeak(:,n),'r');
                text(-30, 1, ['leak' num2str(n)]);
                GL = (questdlg('Keep Leak?', 'GoodLeaks', 'Yes', 'No ', 'Yes'));
                if GL=='No ';
                    GoodLeak(n) = 0;
                else
                LkSum = LkSum + iLeak(:,n);
                end
            end
             avgLk =LkSum/sum(GoodLeak); 
            cla; hold on;
            plot(t, iRaw);
            plot(t, avgLk,'k');
            text(.7, .9, 'average leak', 'units', 'normalized', 'fontsize', 18);
            waitforbuttonpress
        end

        axis auto;
        ANALYSIS = load(SCSTEPLATE.AnalysisFile, '-mat');
        S.(SCSTEPLATE.RunSwp{(nSel)})= ANALYSIS.(SCSTEPLATE.RunSwp{nSel});
        S.(SCSTEPLATE.RunSwp{(nSel)}).GoodLeak = GoodLeak;
        save(SCSTEPLATE.AnalysisFile, '-struct', 'S', '-append');
    end
        set(gcf, 'pointer', 'arrow');
        UpdateGraphics;
        
%% Fit Button functions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function Atool

        global SCSTEPLATE;
        n = 1 + length(SCSTEPLATE.AMin);
        addAtool(n);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
    function addAtool(n);
        global SCSTEPLATE;
        set(gcf, 'pointer', 'watch'); drawnow;
        nSel = get(SCSTEPLATE.Box, 'value');

        Message = text(.7, .9,'select X range to zero', 'Units', 'normalized', 'FontSize', 18, 'Color', 'r');
        [xmn ytemp] = ginput(1);
        [xmx ytemp] = ginput(1);
        ANALYSIS = load(SCSTEPLATE.AnalysisFile, '-mat');
        S.(SCSTEPLATE.RunSwp{(nSel)})= ANALYSIS.(SCSTEPLATE.RunSwp{nSel});
        S.(SCSTEPLATE.RunSwp{(nSel)}).AMin(n) = xmn;
        S.(SCSTEPLATE.RunSwp{(nSel)}).AMax(n) = xmx;
        save(SCSTEPLATE.AnalysisFile, '-struct', 'S', '-append');
        set(gcf, 'pointer', 'arrow');      
        delete(Message);
        
        % BK Edit 08/14/2014
        % Update manualfit so atool still works
        
        AMin = S.(SCSTEPLATE.RunSwp{(nSel)}).AMin;
        AMax = S.(SCSTEPLATE.RunSwp{(nSel)}).AMax;
        
        if SCSTEPLATE.FitData.FinalFit(nSel) ~= 1
            %update autofit with proper atooling
            iRaw = SCSTEPLATE.FitData.RawData(:, nSel);
            t = SCSTEPLATE.FitData.Time;
            try 
                for n = 1:(length(AMin))
                    alk = iRaw-SCSTEPLATE.FitData.AutoFit(:, nSel);
                    alk(t<AMin(n))=0;
                    alk(t>AMax(n))=0;
                    SCSTEPLATE.FitData.AutoFit(:, nSel) = SCSTEPLATE.FitData.AutoFit(:, nSel) + alk;
                end
            
                updateManualFitMatrix(nSel, str2num(get(SCSTEPLATE.Amp.Edit, 'string')), str2num(get(SCSTEPLATE.Tau.Edit, 'string')), ...
                    str2num(get(SCSTEPLATE.XMax.Edit, 'string')),  str2num(get(SCSTEPLATE.XMin.Edit, 'string')), ...
                    S.(SCSTEPLATE.RunSwp{(nSel)}).Delay, S.(SCSTEPLATE.RunSwp{(nSel)}).AMin, S.(SCSTEPLATE.RunSwp{(nSel)}).AMax);
            end
        else
            updateManualFitMatrix(nSel, str2num(get(SCSTEPLATE.Amp.Edit, 'string')), str2num(get(SCSTEPLATE.Tau.Edit, 'string')), ...
                str2num(get(SCSTEPLATE.XMax.Edit, 'string')),  str2num(get(SCSTEPLATE.XMin.Edit, 'string')), ...
                S.(SCSTEPLATE.RunSwp{(nSel)}).Delay, S.(SCSTEPLATE.RunSwp{(nSel)}).AMin, S.(SCSTEPLATE.RunSwp{(nSel)}).AMax);

        end

        UpdateGraphics;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
    function AddLinFit
        global SCSTEPLATE;
        Menu_FreezeX;
        Menu_FreezeY;
        
        set(gcf, 'pointer', 'watch'); drawnow;
        nSel = get(SCSTEPLATE.Box, 'value');
        if length(nSel)>1
            waitfor(errordlg('you may only have one sweep selected for leak selection'));
        else

        range = get(gca, 'xLim');
        xLinFit = [range(1):(range(2)-range(1))/100:range(2)];

        Message = text(.7, .9,'select 2 points to fit', 'Units', 'normalized', 'FontSize', 18, 'Color', 'r');
        [x1 y1]=ginput(1);
        [x2 y2]=ginput(1);
        delete(Message);

        Y = [y1 ; y2];
        coef = [ x1  1; x2  1];
        lsoln = coef\Y;
        m = lsoln(1);
        b = lsoln(2);
        FitLine = m*xLinFit + b;

        plot(xLinFit, FitLine, 'r');

        waitforbuttonpress

        set(SCSTEPLATE.m.Edit, 'string', num2str(m));
        set(SCSTEPLATE.b.Edit, 'string', num2str(b));
        ANALYSIS = load(SCSTEPLATE.AnalysisFile, '-mat');
        S.(SCSTEPLATE.RunSwp{(nSel)})= ANALYSIS.(SCSTEPLATE.RunSwp{nSel});
        S.(SCSTEPLATE.RunSwp{(nSel)}).m = m;
        S.(SCSTEPLATE.RunSwp{(nSel)}).b = b;
        save(SCSTEPLATE.AnalysisFile, '-struct', 'S', '-append');
        end
        set(gcf, 'pointer', 'arrow');
        UpdateGraphics;
        
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function AutoExpFit(useLeak, splice)
        global SCSTEPLATE;
        clc;
        if (~exist('useLeak', 'var'))
            useLeak = 0;
        end
        if (~exist('splice', 'var'))
            splice = 0;
        end
        if get(SCSTEPLATE.AutoFitLk, 'value') || useLeak
            disp('Begin autofitting (using leak)...');
        else
            disp('Begin autofitting (using raw data)...');
        end
        tic;
        DATA = LoadData(SCSTEPLATE.datafile, SCSTEPLATE.RunSwp{1});
        nSel = get(SCSTEPLATE.Box, 'value');
        
        %time vector
        t = SCSTEPLATE.FitData.Time;       
               
        %Data Matrx
        iRawMat = SCSTEPLATE.FitData.RawData(:,nSel);
        leakMat = SCSTEPLATE.FitData.RawLkData(:,nSel);
                
        %time constants to fit
        tau = [0.005 0.5 0.1 0.2 0.4 0.8 1.4 2.8 5 10 50 100]; %logspace(-1,1,8);
        
        %Voltage protocol
        Dstep = DATA(1).StimParams.Dstep;
        VStep = DATA(1).StimParams.Vstep;
        input = DATA(1).StimWaveform;
        
        %index of the start of pulse
        idx_start = find( (diff(input) > 0) ) + 1; %need to fix for specific pulse
        
       
        %exact index to fit
        %come back to fix this for more than 1 pulse
        wind = get(SCSTEPLATE.AutoFitAtoolWind.Edit, 'value');
        idx_exact = idx_start + (0:wind);     
        
        %change leakMat's pre pulse to the same as raw data
        leakMat(1:idx_exact(end)-1, :) = iRawMat(1:idx_exact(end)-1, :);
        
        %lamda and number of time to iterate
        lam = get(SCSTEPLATE.Lambda.Edit, 'value');
        num_iter = 500;
        
        %Make the dictionary
        De = MakeExpDict(tau,t,idx_start);
        
        if get(SCSTEPLATE.AutoFitLk, 'value') || useLeak
            
            if splice
                [Efit, S, E, A, De, obj] = FitExpD(iRawMat, tau, t, idx_start, idx_exact, lam, num_iter, De);
                indicator = (S ~= 0);

                %splice the leak and the iRaw together
                combinedData = indicator*ones(length(length(SCSTEPLATE.RunSwp))) .* leakMat + ~(indicator*ones(length(length(SCSTEPLATE.RunSwp)))) .* iRawMat;
                [Efit, S, E, A, De, obj] = FitExpD(combinedData, tau, t, idx_start, idx_exact, lam, num_iter, De);

                Efit_offsetCorrected = Efit;
            else
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                [Efit,S,E,A,De,obj] = FitExpD(leakMat,tau,t,idx_start,idx_exact,lam,num_iter, De);

    %             correct offset due to leak having nonidentical ss to iRaw
                [EfitRaw,SRaw,ERaw,ARaw,DeRaw,objRaw] = FitExpD(iRawMat,tau,t,idx_start,idx_exact,lam,num_iter, De);
%                 offset = mean(EfitRaw(end-10:end,:) - Efit(end-10:end,:));
%                 idx_s = idx_exact(end);
%                 tempV = [zeros(idx_s-1,1);ones(length(t)-idx_s+1,1)];
%                 Efit_offsetCorrected = Efit + tempV*offset;
            Efit_offsetCorrected = Efit;
            end
        else
            [Efit,S,E,A,De,obj] = FitExpD(iRawMat,tau,t,idx_start,idx_exact,lam,num_iter, De);
            % BK thresholding isn't working very well
            % Take out for now and add it back later
%             threshold = get(SCSTEPLATE.AutoFitThres.Edit, 'value');
%             autofit = iRawMat - Efit;
%             idx_s = idx_exact(end);
%             offset = mean(autofit(idx_s:end, :).*(autofit(idx_s:end,:)<threshold));
%             tempV = [zeros(idx_s-1,1);ones(length(t)-idx_s+1,1)];
%             Efit_offsetCorrected = Efit + tempV*offset;
            Efit_offsetCorrected = Efit;
        end 
        
        ftime = toc;
        timePerFit = ftime / length(nSel);
        disp(sprintf('Auto fit finished, time to fit was %.3f sec and %.3f sec per sweep for %d sweep(s).', ftime, timePerFit, length(nSel)));
        
        %Store the exp fit
        SCSTEPLATE.FitData.AutoFit(:, nSel) = Efit_offsetCorrected;
        % Rest offset
        set(SCSTEPLATE.AutoFitOffset.Edit, 'value', 0);
        set(SCSTEPLATE.AutoFitOffset.Edit, 'string', 0);
        SCSTEPLATE.FitData.AutoFitOffset(nSel) = 0;
        UpdateGraphics;

        % change the  fit window to be like the manual fit. 
        
        % MBJ XXXXXXX
        tauMat = zeros(1,length(tau)+2);
        tauMat(1:length(tau)) = 1./tau;
        tauMat(tau==0) = 0;
        
        xMinMat(1:length(tau))= Dstep(1)*ones(size(tau));
        xMinMat(length(tau)+1) = Dstep(1);
        xMinMat(length(tau)+2) = 0;
        
        xMaxMat(1:length(tau))= sum(Dstep)*ones(size(tau));
        xMaxMat(length(tau)+1) = sum(Dstep);
        xMaxMat(length(tau)+2) = Dstep(1);
        DelayMat = xMinMat;
        AmpMat = E;
        Mask = AmpMat>0.5E-2;
        AmpMat = AmpMat(Mask);
        xMaxMat = xMaxMat(Mask);
        xMinMat = xMinMat(Mask);
        tauMat = tauMat(Mask);
        DelayMat = DelayMat(Mask);
        
        bOK = false;
        if isempty(str2num(get(SCSTEPLATE.XMin.Edit, 'string')))
            bOK = true;
        else
             button = questdlg('Overwrite Parameters?','Overwrite?','Yes','No','Yes');
             bOK = strcmp(button,'Yes');
%             bOK = true;
        end
        if bOK
        xmn = t(find(A~=0,1,'first'));
        xmx = t(find(A~=0,1,'last'));        
        ANALYSIS = load(SCSTEPLATE.AnalysisFile, '-mat');
        JK.(SCSTEPLATE.RunSwp{(nSel)})= ANALYSIS.(SCSTEPLATE.RunSwp{nSel});
        n = length(ANALYSIS.(SCSTEPLATE.RunSwp{nSel}).AMin);
        JK.(SCSTEPLATE.RunSwp{(nSel)}).AMin(n+1) = xmn;
        JK.(SCSTEPLATE.RunSwp{(nSel)}).AMax(n+1) = xmx;
        save(SCSTEPLATE.AnalysisFile, '-struct', 'JK', '-append');
        set(gcf, 'pointer', 'arrow');      

        set(SCSTEPLATE.Amp.Edit,  'string',  sprintf('%4.2f\t',AmpMat) );
        set(SCSTEPLATE.Tau.Edit,  'string',  sprintf('%4.3f\t',tauMat));
        set(SCSTEPLATE.XMax.Edit, 'string',  sprintf('%d\t',xMaxMat));
        set(SCSTEPLATE.XMin.Edit, 'string',  sprintf('%d\t',xMinMat));
        set(SCSTEPLATE.Delay.Edit,'string',  sprintf('%d\t',DelayMat));
        Edit_Callback('Tau')
        end
        
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [Efit,S,E,A,De,obj] = FitExpD(X,tau,time,idx_start,idx_exact,lam,num_iter, De)
%[Efit,S,E,A,De,obj] = FitExpD(X,tau,time,idx_start,idx_exact,lam,num_iter)
%
%This function fits exponential signals to data with the possibility that
%there are sparse outliers in the data.  Specifically the function solves
%the problem:
%
% minimize f(A,E,S) with respect to A, E, and S
% subject to A(not(idx_exact))=0, S<=0, E>=0, and S(time<time(idx_start))=0
%
% where f(A,E,S) = 0.5*|X-De*E-S-A|_F^2 + lam*|S|_1
%
%Here X is the data matrix, and De is a dictionary of decaying exponential
%signals that is generated using the time constants supplied in the tau
%parameter.  The other variables are output variables.
%
%Inputs:
%   X - The data matrix (should be t x N) where t is the number of time
%       points and N is the number of traces being fit (each trace is in a 
%       column of X).  Note that because the exponential fit is done
%       assuming non-negative data the baseline of the signals should be
%       non-negative.
%
%   tau - A vector of decay constants to use to construct the exponential
%         fit.  Should be in the same units as the 'time' input vector.
%
%   time - A (t x 1) vector containing the time points when the data was
%          sampled.
%
%   idx_start - The index of the time vector when the exponential signal
%               starts (assumed known).  For example, suppose 
%               time = [0 0.1 0.2 0.3 0.4 ...] and the signal starts at 
%               t=0.2, then idx_start = 3.
%
%   idx_exact - The indecies of the time vector when the algorithm should
%               apply an exact fit.  The is typically to remove artifacts
%               associated with the onset of the exponential and prevent 
%               them from being incorporated into the overall fit.  For
%               example idx_exact = idx_start + (-w:w); would be a typical
%               value to apply an exact fit for w time points in either
%               direction of the signal onset.  If no exact fit is to be
%               used then pass in [] for this parameter.
%
%   lam - Regularization parameter for the optimization problem.  This sets
%         the sensitivity of the algorithm to outliers.  Typically set
%         this to be roughly proportional to the std of the noise.
%
%   num_iter - The number of iterations to perform in the optimization.
%              Future versions will have more principled stopping criteria.
%
%Outputs:
%   Efit - (t x N) Matrix. The exponential fits for each signal.  Each 
%          column contains the exponential fit for the corresponding column
%          of the data matrix.  Efit = De*E+A
%
%   S - (t x N) Matrix.  Estimation of negative outliers (in single channel
%       recordings this would be roughly the channel opening events).
%
%   E - (size(De,2) x N) Matrix. Coefficients used to fit the expnential 
%       signal (De*E is the purely exponential fit).
%
%   A - (t x N) Matrix.  The 'exact fit' coefficients during the idx_exact
%       period.
%
%   De - The Dictionary used in the fit.
%
%   obj - (num_iter x 1) vector.  The value of the objective function at
%         each iteration.
%
%
%Ben Haeffele - Aug 4, 2014



%Make the dictionary
%De = MakeExpDict(tau,time,idx_start);

numE = size(De,2);
[nT,nS] = size(X);

%Allocate space for variables
S_old = zeros(nT,nS);
E_old = zeros(numE,nS);

S_extrap = S_old;
E_extrap = E_old;

obj = zeros(num_iter,1);

t_old = 1;

%Pre-calculate this to slightly speed up the iterations.
DtX = De'*X;

%Lipschitz constant of the square loss term.
L = norm(De,2)^2+1;

%Calculate indices for when S must be = 0
idx_nosig = true(nT,1);
idx_nosig(idx_exact) = false;
idx_nosig(idx_start:end) = false;

%Indices for when S can be non-zero
idx_L1 = true(nT,1);
idx_L1(idx_exact) = false;
idx_L1(1:idx_start-1) = false;

%The main calculation loop
for i=1:num_iter
    %Comment this out if it gets annoying having the iteration number
    %displayed.
    %disp(i)
    
    %Calculate the gradients of the smooth loss term
    DeE = De*E_extrap;
    
    gradE = De'*(DeE+S_extrap)-DtX;
    gradS = S_extrap+DeE-X;
    
    %Apply proximal operators
    E = E_extrap-gradE/L;
    E(E<0) = 0;
    
    S = S_extrap-gradS/L;
    
    S(idx_L1,:) = min(S(idx_L1,:)+lam/L,0);
    
%     indicator = S(idx_L1);
%     indicator = (indicator <= 0); %only the negatives
%     S(idx_L1,:) = indicator.*min(S(idx_L1,:)+lam/L,0) + ~(indicator).*max(S(idx_L1,:)-lam/L,0);
    
%     figure(4);
%     cla;
%     plot(S(idx_L1,:));
    
    S(idx_nosig,:) = 0;
    
    %Calculate the residual
    res = X-De*E-S;
    S(idx_exact,:) = S(idx_exact,:)+res(idx_exact,:);
    res(idx_exact,:) = 0;
    
    %Calculate objective function value for this iteration
    obj(i) = 0.5*norm(X-De*E-S,'fro')^2+lam*sum(abs(S(:)));
    
    %Apply simple extrapolation for the next search point
    t = (1+sqrt(1+4*t_old^2))/2;
    
    E_extrap = E+(t_old-1)/t*(E-E_old);
    S_extrap = S+(t_old-1)/t*(S-S_old);
    
    E_old = E;
    S_old = S;
    t_old = t;

end

%We actually solve the optimization with just S and E and then split out A
%at the end.  Essentially A is just S for the indices in idx_exact and 0
%everywhere else.  During the main optimization S is unregularized at the
%idx_exact indices so it will fit the data exactly.
A = zeros(size(S));
A(idx_exact,:) = S(idx_exact,:);
S = S-A;

Efit = De*E+A;

function [D] = MakeExpDict(tau,time,idx_start)
%[D] = MakeExpDict(tau,time,idx_start)
%
%Creates a dictionary of decaying exponetial signals with a given decay
%constant and start time.
%
%Inputs:
%   tau - A vector of decay constants (n x 1).
%   time - A vector containing the time points to generate (t x 1).
%   idx_start - The index of the time vector where the expenential starts.
%
%Output:
%   D - (t x (n+2)) Matrix containing the decaying exponential signals plus
%   two step functions.  The two step functions are added to the last two
%   columns to help fit any DC offset before/after the start time.
%   Specifically, the i'th (i <= length(tau)) column of D is given by:
%   d(t) = exp(-(t-time(idx_start))/tau(i)).*(t>=time(idx_start));
%
%
% Ben Haeffele - Aug 4, 2014

global SCSTEPLATE;

%Make sure the decay constant vector is a column vector
tau = tau(:);

nT = numel(tau);

%Shift the time points to start at t(idx_start) = 0
t = time-time(idx_start);
t = t(:);

%Make the step function at the start time.
t_step = t>=0;

szTS = sum(t_step);

%Make the decaying exponentials
D(t_step,:) = exp(repmat(-t(t_step),1,nT)./repmat(tau',szTS,1));

%Add step functions to fit any DC offset before/after the voltage clamp
%onset.
D = [D double(t_step(:)) double(not(t_step))];

function AddExpFit

        global SCSTEPLATE;
        nSel = get(SCSTEPLATE.Box, 'value');
        if length(nSel)>1
            waitfor(errordlg('you may only have one sweep selected'));
        else
        n = 1 + length(str2num(get(SCSTEPLATE.Tau.Edit, 'string')));        
        ExpFitMBJ(n);
%         expfitBK(n);
        end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function ExpFit(n)
       global SCSTEPLATE;
        ylim('manual');
        xlim('manual');
        axis on;
        set(gcf, 'pointer', 'watch'); drawnow;
        nSel = get(SCSTEPLATE.Box, 'value');

        DATA = LoadData(SCSTEPLATE.datafile, SCSTEPLATE.RunSwp{(nSel)});
        ANALYSIS = load(SCSTEPLATE.AnalysisFile, '-mat');
        swANALYSIS = ANALYSIS.(SCSTEPLATE.RunSwp{(nSel)});
        xmin = swANALYSIS.XMin;
        xmax = swANALYSIS.XMax;

        Message = text(.7, .9,'select X min', 'Units', 'normalized', 'FontSize', 18, 'Color', 'r');        
        [xmn ytemp] = ginput(1);
        set(Message, 'string','select X max')
%         Message = text(.7, .9,'select X max', 'Units', 'normalized', 'FontSize', 18, 'Color', 'r');
        [xmx ytemp] = ginput(1);
        xmin(n) = xmn;
        xmax(n) = xmx;
        set(SCSTEPLATE.XMin.Edit, 'string', num2str(xmin));
        set(SCSTEPLATE.XMax.Edit, 'string', num2str(xmax));
        delete(Message);                
        
        % downsample t to estimate exp
        SCSTEPLATE.tExpFit = [xmin(n):(xmax(n)-xmin(n))/100:xmax(n)];

        Message = text(.7, .9,'select 2 points for initial fit', 'Units', 'normalized', 'FontSize', 18, 'Color', 'r');
        [x1 y1]=ginput(1);
        [x2 y2]=ginput(1);
        delete(Message);

        y = [log(y1); log(y2)];
        A = [1 -x1; 1 -x2];
        soln = real(A\y);
        tau = soln(2); 
        soln(1);
        Amp = exp(soln(1));
        FitE = Amp*exp(-tau*SCSTEPLATE.tExpFit);

        SCSTEPLATE.CP = [0 0];
        SCSTEPLATE.TauHold = swANALYSIS.Tau;
        SCSTEPLATE.TauHold(n) = tau;
        SCSTEPLATE.AmpHold = swANALYSIS.Amp;
        SCSTEPLATE.AmpHold(n) = Amp;
        SCSTEPLATE.expline = line('xdata',SCSTEPLATE.tExpFit,'ydata',FitE,'color','g');

        Message = text(.7, .9,'drag fit to adjust', 'Units', 'normalized', 'FontSize', 18, 'Color', 'r');
        
        waitforbuttonpress
        set(gcf,'windowbuttonmotionfcn' , ['UpdateExp(' num2str(n) ')']);
        %set(gcf, 'windowbuttondownfcn', ['set(gcf,''windowbuttonmotionfcn'' , ''UpdateExp('  num2str(n)     ')'' )']);
        set(gcf, 'windowbuttonupfcn', 'ExpDone');
        
        waitforbuttonpress;
        axis auto;
        UpdateGraphics;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function ExpDone      
    global SCSTEPLATE;
        nSel = get(SCSTEPLATE.Box, 'value');
        set(gcf, 'windowbuttonupfcn', '');
        set(gcf, 'windowbuttonmotionfcn', '');
        ANALYSIS = load(SCSTEPLATE.AnalysisFile, '-mat');
        S.(SCSTEPLATE.RunSwp{(nSel)})= ANALYSIS.(SCSTEPLATE.RunSwp{nSel});
        S.(SCSTEPLATE.RunSwp{(nSel)}).XMin = str2num(get(SCSTEPLATE.XMin.Edit, 'string'));
        S.(SCSTEPLATE.RunSwp{(nSel)}).XMax = str2num(get(SCSTEPLATE.XMax.Edit, 'string'));
        S.(SCSTEPLATE.RunSwp{(nSel)}).Tau = SCSTEPLATE.TauHold;
        S.(SCSTEPLATE.RunSwp{(nSel)}).Amp = SCSTEPLATE.AmpHold;
        S.(SCSTEPLATE.RunSwp{(nSel)}).Delay = SCSTEPLATE.DelayHold;
        save(SCSTEPLATE.AnalysisFile, '-struct', 'S', '-append');
        
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function UpdateExp(n)
        global SCSTEPLATE;
        hold on;
        ylim('manual');
        xlim('manual');

        CPnew = get(gcf, 'currentpoint');
        CPold = SCSTEPLATE.CP;
        TauOld = SCSTEPLATE.TauHold(n);
        AmpOld = SCSTEPLATE.AmpHold(n);
        if isfield(SCSTEPLATE,'DelayHold')
            DelayTemp = SCSTEPLATE.DelayHold(n);
        else
            DelayTemp = 0;
        end
        
        if CPold(1) == 0;
            CPold = CPnew;
            TauNew = TauOld;
            AmpNew = AmpOld;
        else
            CPdiff = CPnew - CPold;
            if AmpOld > 0
                AmpNew = (1+CPdiff(2)*5)*AmpOld;
            else
                AmpNew = (1-CPdiff(2)*5)*AmpOld;
            end
            TauNew = (1+CPdiff(1)*5)*TauOld;
            yNew = AmpNew*exp(-TauNew*(SCSTEPLATE.tExpFit-DelayTemp));
        end

        try
            set(SCSTEPLATE.expline, 'xdata', SCSTEPLATE.tExpFit, 'ydata', yNew);
        catch
        end

        SCSTEPLATE.CP = CPnew;
        SCSTEPLATE.TauHold(n) = TauNew;
        SCSTEPLATE.AmpHold(n) = AmpNew;     
        if isfield(SCSTEPLATE,'DelayHold')
            SCSTEPLATE.DelayHold(n) = DelayTemp;
            set(SCSTEPLATE.Delay.Edit, 'string', num2str(real(SCSTEPLATE.DelayHold)));
        end
        set(SCSTEPLATE.Tau.Edit, 'string', num2str(SCSTEPLATE.TauHold));
        set(SCSTEPLATE.Amp.Edit, 'string', num2str(real(SCSTEPLATE.AmpHold)));
               


%% UpdateFunctions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function UpdateBox
        global SCSTEPLATE;

        set(gcf, 'pointer', 'watch'); drawnow;
        set(SCSTEPLATE.Box, 'String', SCSTEPLATE.RunSwp);
        UpdateGraphics;
            
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function UpdateGraphics
    global SCSTEPLATE;
    
      if get(SCSTEPLATE.NoUpdate, 'value')
          set(gcf, 'pointer', 'arrow');
      else
          UpdateGraphicsz
      end
          
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function UpdateGraphicsz        
        % New updategraphics function
        % BK 08/13/2014
        % Only completed for step loop
        % Allows for individually toggling between raw data, fits, and leak
        % subtracted. Previous updategraphics function was very slow at
        % plotting data because leak was recomputed everytime. This version
        % will speed it up by storing leak.
        
        global SCSTEPLATE;        
        Lambda = get(SCSTEPLATE.Lambda.Edit, 'value');
        %AutoFitThres = get(SCSTEPLATE.AutoFitThres.Edit, 'value');
        AutoFitOffset =  get(SCSTEPLATE.AutoFitOffset.Edit, 'value');
        
        % Current Protocol indicates which UI to display
        % Changing protocol should trigger change in UI
        % Only step protocol is set up now - may use old SCS for ramp
        % Value of 1 = Famile Step, 2 = Step, 3 = Ramp
        %CurrentProtocol = get(SCSTEPLATE.Protocol, 'value');
        CurrentProtocol = 1;
        % AutoManual indicates whether leak subtracted current should be 
        % from manual or auto fit
        % Value of 1 = use auto fit, 2 = use manual fit
        AutoManual = get(SCSTEPLATE.AutoManual, 'value');
        
        % Get information on which waveforms to plot
        DispAutoFit = get(SCSTEPLATE.DispAutoFit, 'value');
        DispManFit = get(SCSTEPLATE.DispManFit, 'value');
        DispLk = get(SCSTEPLATE.DispLk, 'value');
        DispData = get(SCSTEPLATE.DispData, 'value');
        SmoothLk = get(SCSTEPLATE.SmoothLk, 'value');
        FinalLk = get(SCSTEPLATE.FinalLk, 'value');
        
        % Plot the data
        % Generate the leak subtracted wavform
        LeakSubData = zeros(size(SCSTEPLATE.FitData.RawData));
        if FinalLk
            LeakSubData = ConstructFinalLeakSub;
        else 
            switch AutoManual
                case 1 %use autofit
                    LeakSubData = SCSTEPLATE.FitData.RawData - SCSTEPLATE.FitData.AutoFit;
                case 2 %use manualfit
                    LeakSubData = SCSTEPLATE.FitData.RawData - SCSTEPLATE.FitData.ManualFit;
                otherwise
                    disp('Error determining whether to use auto or manual fit');
            end
        end
        
        nSel = get(SCSTEPLATE.Box, 'value');        
        t = SCSTEPLATE.FitData.Time;
        cla; 
        badColor = [.9 .9 .9];
        fitColor = [0.7 0.7 0.7];
        switch CurrentProtocol 
            case {1,2} %Step family 
                
                % If plot leak
                if DispLk
                    hold on;
                    if length(nSel) > 1
                        h = plot(t, SCSTEPLATE.FitData.RawLkData(:, nSel));
                        set(h, {'color'}, num2cell(jet(length(nSel)), 2));
                    else
                        plot(t, SCSTEPLATE.FitData.RawLkData(:, nSel), 'color', 'g');
                    end
                    hold off;
                end
                
                % If plot autofit
                if DispAutoFit
                    hold on;
                    if length(nSel) > 1
                        h = plot(t, SCSTEPLATE.FitData.AutoFit(:, nSel));
                        set(h, {'color'}, num2cell(jet(length(nSel)), 2));
                    else
                        plot(t, SCSTEPLATE.FitData.RawData(:, nSel), 'color', fitColor);
                        plot(t, SCSTEPLATE.FitData.AutoFit(:, nSel), 'color', 'r');
                    end
                    hold off;
                end
                
                % If plot manualfit
                if DispManFit
                    hold on;
                    if length(nSel) > 1
                        h = plot(t, SCSTEPLATE.FitData.ManualFit(:, nSel));
                        set(h, {'color'}, num2cell(jet(length(nSel)), 2));
                    else
                        plot(t, SCSTEPLATE.FitData.RawData(:, nSel), 'color', fitColor);
                        plot(t, SCSTEPLATE.FitData.ManualFit(:, nSel), 'color', 'm');
                    end
                    hold off
                end
                
                % if plot data
                if DispData && ~SmoothLk
                    hold on;
                    if length(nSel) > 1
                        h = plot(t, SCSTEPLATE.FitData.RawData(:,nSel));
                        set(h, {'color'}, num2cell(jet(length(nSel)), 2));
                    else
                        plot(t, SCSTEPLATE.FitData.RawData(:, nSel), 'color', 'k');
                    end
                    
                    for checkBadInd = 1:length(SCSTEPLATE.FitData.BadInd)
                        if any(nSel == SCSTEPLATE.FitData.BadInd(checkBadInd))
                            plot(t, SCSTEPLATE.FitData.RawData(:, SCSTEPLATE.FitData.BadInd(checkBadInd)), 'color', badColor);
                        end
                    end
                    
                    hold off;
                end
                
                if DispData && SmoothLk
                    hold on;
                    if length(nSel) > 1
                        h = plot(t, LeakSubData(:,nSel));
                        set(h, {'color'}, num2cell(jet(length(nSel)), 2));
                    else
                        plot(t, LeakSubData(:, nSel), 'color', 'k');
                    end
                    
                    for checkBadInd = 1:length(SCSTEPLATE.FitData.BadInd)
                        if any(nSel == SCSTEPLATE.FitData.BadInd(checkBadInd))
                            plot(t, LeakSubData(:, SCSTEPLATE.FitData.BadInd(checkBadInd)), 'color', badColor);
                        end
                    end
                    
                    hold off;
                end
                %draw line for uni current
                set(gca, 'xlim', [ min(t), max(t)]);
                myxlim = get(gca,'xlim');
                %Gv =  str2num(get(SCSTEPLATE.g.Edit, 'string'));
                
            %case 2 %Step
                % Same as case 1
                % Moved it up to be same as case 1
                
            case 3 %Ramp
                % To be finished 
            otherwise
                disp('Error with plotting...');
        end
        
        % Format axis
        % Note: fix this to deal with uni current instead of g
        set(gca, 'xlim', [ min(t), max(t)]);
        myxlim = get(gca,'xlim');
        line(myxlim, [0 0],'color',[0 0 0])
        if ~isempty(SCSTEPLATE.FreezeX)
            set(gca, 'xlim', SCSTEPLATE.FreezeX);
        end
        if ~isempty(SCSTEPLATE.FreezeY)
            set(gca, 'ylim', SCSTEPLATE.FreezeY);
        end
        
        %Update fields with previous data
        nSel = get(SCSTEPLATE.Box, 'value');
        DATA = LoadData(SCSTEPLATE.datafile, SCSTEPLATE.RunSwp{nSel(1)});
        ANALYSIS = load(SCSTEPLATE.AnalysisFile, '-mat');
        swANALYSIS = ANALYSIS.(SCSTEPLATE.RunSwp{nSel(1)});
        AMin = swANALYSIS.AMin;
        AMax = swANALYSIS.AMax;
        CellNum = DATA(1).CellNum;
        VStep = DATA(1).StimParams.Vstep;
        CellNumString = ['Cell',num2str(DATA(1).DBParams.CellNum),''];

        try
            NumCh = ANALYSIS.(CellNumString).NumCh;
            g = ANALYSIS.(CellNumString).g;
            %Vs = ANALYSIS.(CellNumString).Vs;
            Vs = 0;
        catch
            NumCh = 1;
            g = 0;
            Vs = 0;
        end
        XMin = swANALYSIS.XMin;
        XMax = swANALYSIS.XMax;
        Tau = swANALYSIS.Tau;
        Amp = swANALYSIS.Amp;
        if isfield(swANALYSIS,'Delay')
            Delay = swANALYSIS.Delay;
        else
            Delay = zeros(size(Tau));
        end
        
        set(SCSTEPLATE.Lambda.Edit, 'value', str2num(get(SCSTEPLATE.Lambda.Edit, 'string')));
        %set(SCSTEPLATE.AutoFitThres.Edit, 'value', str2num(get(SCSTEPLATE.AutoFitThres.Edit, 'string')));
        set(SCSTEPLATE.AutoFitAtoolWind.Edit, 'value', str2num(get(SCSTEPLATE.AutoFitAtoolWind.Edit, 'string')));
        %set(SCSTEPLATE.AutoFitOffset.Edit, 'value', str2num(get(SCSTEPLATE.AutoFitOffset.Edit, 'string')));
        set(SCSTEPLATE.AutoFitOffset.Edit, 'value', SCSTEPLATE.FitData.AutoFitOffset(nSel(1)));
        set(SCSTEPLATE.AutoFitOffset.Edit, 'string', SCSTEPLATE.FitData.AutoFitOffset(nSel(1)));
        set(SCSTEPLATE.FitToUse.Edit, 'value', SCSTEPLATE.FitData.FinalFit(nSel(1)));
        if get(SCSTEPLATE.FitToUse.Edit, 'value')
            set(SCSTEPLATE.FitToUse.Edit, 'String', 'ManFit');
        else
            set(SCSTEPLATE.FitToUse.Edit, 'String', 'AutoFit');
        end
        
        %set(SCSTEPLATE.CellNum.Edit, 'string', num2str(CellNum));
        set(SCSTEPLATE.VStep.Edit, 'string', num2str(VStep));
        set(SCSTEPLATE.NumCh.Edit, 'string', num2str(NumCh));

        set(SCSTEPLATE.XMin.Edit, 'string', num2str(XMin));
        set(SCSTEPLATE.XMax.Edit, 'string', num2str(XMax));
        set(SCSTEPLATE.Tau.Edit, 'string', num2str(Tau));
        set(SCSTEPLATE.Amp.Edit, 'string', num2str(Amp));
        set(SCSTEPLATE.Delay.Edit, 'string', num2str(Delay));
        
        SCSTEPLATE.AMin = (AMin);
        SCSTEPLATE.AMax = (AMax);
        set(gcf, 'pointer', 'arrow');
               

    function LkSub = ConstructFinalLeakSub
        global SCSTEPLATE;
        AutoFit = SCSTEPLATE.FitData.AutoFit;
        ManFit = SCSTEPLATE.FitData.ManualFit;
        iRaw = SCSTEPLATE.FitData.RawData;
        
        % Indicator has value 0 for autofit, 1 for manual fit
        manualIndicator = SCSTEPLATE.FitData.FinalFit+1>0;
        
        indicMat = ones(length(SCSTEPLATE.FitData.Time),1)*manualIndicator';
        manFitToUse = indicMat .* ManFit;
        
        autoIndicator = ~manualIndicator;
        indicMat =  ones(length(SCSTEPLATE.FitData.Time),1)*autoIndicator';
        autoFitToUse = indicMat .* AutoFit;
        
        FinalFitToUse = manFitToUse + autoFitToUse;
        LkSub = iRaw - FinalFitToUse;
        
    function OUT = Export(noWrite)
        global SCSTEPLATE;
        if (~exist('noWrite', 'var'))
            cancelPreZero = 0;
            noWrite = 0;
        elseif noWrite == 2
            cancelPreZero = 1;
            noWrite = 1;
        else
            cancelPreZero = 0;
            noWrite = 1;    
        end
        VFam = SCSTEPLATE.FitData.FamVoltage; 
        FamVec = SCSTEPLATE.FitData.FamVec;
        t = SCSTEPLATE.FitData.Time;
        tStart = SCSTEPLATE.FitData.tStart;
        
        % Determine bad traces and filter from famvec
        FamVec(SCSTEPLATE.FitData.GoodBad == 0) = -100;
        
        LeakSub = ConstructFinalLeakSub;
        
        % Create vector corresponding to each test voltage
        % Create a matrix with traces from the same Vtest for further
        % analysis
        testVoltageNum = 1;
        for k = 1:length(VFam)
            indicator = (VFam(k) == FamVec);
            indicMat = ones(length(SCSTEPLATE.FitData.Time),1)*indicator';
            SameVLeakSub = LeakSub .* indicMat;
            if ~cancelPreZero
                SameVLeakSub = SameVLeakSub .* (ones(size(SameVLeakSub,2), 1) * (t'>tStart(k)))';
            end
            % Remove zero vectors in samevleaksub
            SameVLeakSub(:, all(~any(SameVLeakSub), 1)) = [];
            %SameVLeakSub = [t, SameVLeakSub];
            if ~isempty(SameVLeakSub)
                OutputString = ['TestVoltage' num2str(testVoltageNum)];
                
                if ~noWrite
                   SwpWindLow = SCSTEPLATE.DataAnalysisParams.SwpWind(1);
                   SwpWindHigh =  SCSTEPLATE.DataAnalysisParams.SwpWind(2);
                   SwpWindHigh = min(SwpWindHigh, size(SameVLeakSub,2));
                   SameVLeakSub = SameVLeakSub(:, SwpWindLow:SwpWindHigh);
                end
                
                OUT.(OutputString) = SameVLeakSub;
                testVoltageNum = testVoltageNum + 1; 
            end
        end
        
        if ~noWrite
            NewAnalysisFName = [SCSTEPLATE.datafile(1:end-4) '_LkSubtracted.mat'];
            OUT.Time = t;
            save(NewAnalysisFName, '-struct', 'OUT');
            clc;
            disp('Finished exporting data.');
        end
        
function ExportMBJV2
        global SCSTEPLATE;
        
        %Read in parameters on the current screen
        UniCurrent = get(SCSTEPLATE.UniCurrent.Edit, 'value');
        Lambda = get(SCSTEPLATE.Lambda.Edit, 'value');
        %AutoFitThres = get(SCSTEPLATE.AutoFitThres.Edit, 'value');
        AutoFitOffset =  get(SCSTEPLATE.AutoFitOffset.Edit, 'value');
        
        % Current Protocol indicates which UI to display
        % Changing protocol should trigger change in UI
        % Only step protocol is set up now - may use old SCS for ramp
        % Value of 1 = Famile Step, 2 = Step, 3 = Ramp
        %CurrentProtocol = get(SCSTEPLATE.Protocol, 'value');
        CurrentProtocol = 1;
        % AutoManual indicates whether leak subtracted current should be 
        % from manual or auto fit
        % Value of 1 = use auto fit, 2 = use manual fit
        AutoManual = get(SCSTEPLATE.AutoManual, 'value');
        
        % Get information on which waveforms to plot
        DispAutoFit = get(SCSTEPLATE.DispAutoFit, 'value');
        DispManFit = get(SCSTEPLATE.DispManFit, 'value');
        DispLk = get(SCSTEPLATE.DispLk, 'value');
        DispData = get(SCSTEPLATE.DispData, 'value');
        SmoothLk = get(SCSTEPLATE.SmoothLk, 'value');
        FinalLk = get(SCSTEPLATE.FinalLk, 'value');
        
        % Plot the data
        % Generate the leak subtracted wavform
        LeakSubData = zeros(size(SCSTEPLATE.FitData.RawData));
        if FinalLk
            LeakSubData = ConstructFinalLeakSub;
        else 
            switch AutoManual
                case 1 %use autofit
                    LeakSubData = SCSTEPLATE.FitData.RawData - SCSTEPLATE.FitData.AutoFit;
                case 2 %use manualfit
                    LeakSubData = SCSTEPLATE.FitData.RawData - SCSTEPLATE.FitData.ManualFit;
                otherwise
                    disp('Error determining whether to use auto or manual fit');
            end
        end
        
        nSel = get(SCSTEPLATE.Box, 'value');        
        t = SCSTEPLATE.FitData.Time;
        
        LeakSubData = LeakSubData(:,nSel(nSel~=SCSTEPLATE.FitData.BadInd));
        DATA.ISub = LeakSubData;
        DATA.t = t;
        NewAnalysisFName = [SCSTEPLATE.datafile(1:end-4) '_LkSubtracted.mat'];
        save(NewAnalysisFName, '-struct', 'DATA')
        disp('done')
        
function ExportMBJ
        global SCSTEPLATE;
        disp('Exporting...');
        TempList = SCSTEPLATE.MBJHack.TempList;
        TempList = sort(TempList);
        % MBJ Hack.  This is a cheesy thing. We will go through each DATA
        % File, which is slow, but we will then look at if the VStep(2) =
        % -50, -30, or -10 and then add the leak subtracted data to a
        % matrix and then save the matrix as a mat file for future
        % manipulations. This will only work for steps ... 
        
        % 3 variable - TempDATA1   TempDATA2   TempDATA3    RunSwpName1, 2 3 for
        % identifying the location of the data. 
        
        % load data and analysis files
        LenData = zeros(length(TempList),1);
        GBAD = zeros(length(TempList),1);
        Categories = zeros(length(TempList),1);
        for k=1:length(TempList)
            DATA = LoadData(SCSTEPLATE.datafile, SCSTEPLATE.RunSwp{TempList(k)});  
            ANALYSIS = load(SCSTEPLATE.AnalysisFile, '-mat');
            swANALYSIS = ANALYSIS.(SCSTEPLATE.RunSwp{TempList(k)});
            GBAD(k) = swANALYSIS.GoodBad;
            LenData(k) = length(DATA(1).StimWaveform);            
            switch DATA(1).StimParams.Vstep(2)
            case -50
                Categories(k) = 1;
                        
            case -30
                Categories(k) = 2;
                        
            case -10
                Categories(k) = 3;                    
                    
            end
        end
        LenOK = (LenData==LenData(1)) & GBAD;
        TempList = TempList(LenOK);
        NewLenData  = LenData(LenOK);
        NewCategories = Categories(LenOK);
        CategCount = [sum(NewCategories==1) sum(NewCategories==2) sum(NewCategories==3)];

        EXPORTDATA = zeros(length(TempList), LenData(1));
        STIMDATA = zeros(length(TempList), LenData(1));
%         for j = 1:length(CategCount)
%            EXPORTDATA(j).ISub = zeros(CategCount(j), LenData(1));
%            EXPORTDATA(j).RunSwp = SCSTEPLATE.RunSwp(TempList(NewCategories==j));
%         end
%         
        
        for k=1:length(TempList)
            clc
            disp([ 'saving trace ' num2str(k) ' / ' num2str(length(TempList)) '.'])
            DATA = LoadData(SCSTEPLATE.datafile, SCSTEPLATE.RunSwp{TempList(k)});
            ANALYSIS = load(SCSTEPLATE.AnalysisFile, '-mat');
            swANALYSIS = ANALYSIS.(SCSTEPLATE.RunSwp{TempList(k)});
            CellNum = DATA(1).CellNum;
            CellNumString = ['Cell',num2str(DATA(1).DBParams.CellNum),''];
            VStep = [];
            XMin = swANALYSIS.XMin;
            XMax = swANALYSIS.XMax;
            Tau = swANALYSIS.Tau;
            Amp = swANALYSIS.Amp;
            if isfield(swANALYSIS,'Delay')
                Delay = swANALYSIS.Delay;
            else
                Delay = zeros(size(Tau));
            end
            
            
            
            swOffset = swANALYSIS.swOffset;
            lkOffset = swANALYSIS.lkOffset;
            
            SF = [];
            GoodBad = swANALYSIS.GoodBad;
            Blank = swANALYSIS.Blank;
            AMin = swANALYSIS.AMin;
            AMax = swANALYSIS.AMax;
            
            SF = DATA(2).StimParams.LeakSF;
            Dstep = DATA(1).StimParams.Dstep;
            VStep = DATA(1).StimParams.Vstep;
            t    = DATA(1).Time*1000 - 1000*DATA(1).StimParams.PrePoints/DATA(1).SamplingFreqHz;  %time in ms
            iRaw = DATA(1).AcqWaveform;
            EndofPulse1 = find(abs(diff(DATA(1).StimWaveform)),1);
            %zero offset:
            if swANALYSIS.swOffset==0
                swOffset = mean(iRaw(EndofPulse1-DATA(1).StimParams.PrePoints+1:EndofPulse1));
            end
            iRaw = iRaw - swOffset;
            
            
            smoothleak = 0;
            try
                for n=1:(length(XMin))
                    ilk = Amp(n)*exp(-(Tau(n))*(t-Delay(n)));
                    %Billy edit 05-29-2014
                                
                    ilk(t < Delay(n)) = 0;
                    ilk(t<XMin(n))=0;
                    ilk(t>XMax(n))=0;
                    smoothleak = smoothleak + ilk;
                end
            end
            for n=1:(length(AMin));
                alk = iRaw-smoothleak;
                alk(t<AMin(n))=0;
                alk(t>AMax(n))=0;
                smoothleak = smoothleak + alk;
            end
            iRaw = iRaw - smoothleak;                        
            EXPORTDATA(k,:)= iRaw;            
            STIMDATA(k,:) = DATA(1).StimWaveform;
        end
        
        for index = 1:3
            OUTPUT(index).ISub = EXPORTDATA(NewCategories==index,:);
            OUTPUT(index).RunSwp = SCSTEPLATE.RunSwp(TempList(NewCategories==index));
            OUTPUT(index).StimWaveform = mean(STIMDATA(NewCategories==index,:),1);            
            OUTPUT(index).t = t;
        end
    NewAnalysisFName = [SCSTEPLATE.datafile(1:end-4) '_LkSubtracted.mat'];
    OUTPUTFILE.DATA = OUTPUT;
    save(NewAnalysisFName, '-struct', 'OUTPUTFILE')
    disp('done')
        
function AddToList
            global SCSTEPLATE;
            
            nSel = get(SCSTEPLATE.Box, 'value');        
            
            TempList = [SCSTEPLATE.MBJHack.TempList nSel];                   
            TempList = [nSel];
            TempList = unique(sort(TempList));
            SCSTEPLATE.MBJHack.TempList = TempList;
            disp('Added to List');
        % load data and analysis files
        
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function AxRect = DrawRectOnAx

        %change mouse pointer to indicate we are starting to draw a rectangle
        set(gcf,'Pointer','fullcross');

        %Use rbbox to draw a rectangle
        waitforbuttonpress;
        set(gcf,'Pointer','crosshair');
        point1 = get(gca,'CurrentPoint');    % button down detected
        rbbox;
        point2 = get(gca,'CurrentPoint');    % button up detected
        point1 = point1(1,1:2);              % extract x and y
        point2 = point2(1,1:2);
        p1 = min(point1,point2);             % calculate locations
        offset = abs(point1-point2);         % and dimensions

        %This is the position of the rectangle on the axes coordinates.
        AxRect = [p1(1) p1(2) offset(1) offset(2)];

        %change mouse pointer to indicate we are done
        set(gcf,'Pointer','arrow');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Load/Save functions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function SaveSwParams
        global SCSTEPLATE;
% careful - this allows all values of sweeps selected to be reset when any change is made 
        set(gcf, 'pointer', 'watch'); drawnow;
        nSel = get(SCSTEPLATE.Box, 'value');
        for k = 1:length(nSel);
        S.(SCSTEPLATE.RunSwp{(nSel(k))}).FiltHz = str2num(get(SCSTEPLATE.FiltHz.Edit, 'string'));
        S.(SCSTEPLATE.RunSwp{(nSel(k))}).Amp = str2num(get(SCSTEPLATE.Amp.Edit, 'string'));
        S.(SCSTEPLATE.RunSwp{(nSel(k))}).Tau = str2num(get(SCSTEPLATE.Tau.Edit, 'string'));
        S.(SCSTEPLATE.RunSwp{(nSel(k))}).XMax = str2num(get(SCSTEPLATE.XMax.Edit, 'string'));
        S.(SCSTEPLATE.RunSwp{(nSel(k))}).XMin = str2num(get(SCSTEPLATE.XMin.Edit, 'string'));
        S.(SCSTEPLATE.RunSwp{(nSel(k))}).m = str2num(get(SCSTEPLATE.m.Edit, 'string'));
        S.(SCSTEPLATE.RunSwp{(nSel(k))}).b = str2num(get(SCSTEPLATE.b.Edit, 'string'));
        S.(SCSTEPLATE.RunSwp{(nSel(k))}).swOffset = SCSTEPLATE.swOffset;
        S.(SCSTEPLATE.RunSwp{(nSel(k))}).lkOffset = SCSTEPLATE.lkOffset;
        S.(SCSTEPLATE.RunSwp{(nSel(k))}).GoodBad = SCSTEPLATE.GoodBad;
        S.(SCSTEPLATE.RunSwp{(nSel(k))}).Blank = SCSTEPLATE.Blank;
        S.(SCSTEPLATE.RunSwp{(nSel(k))}).AMin = SCSTEPLATE.AMin;
        S.(SCSTEPLATE.RunSwp{(nSel(k))}).AMax = SCSTEPLATE.AMax;
        S.(SCSTEPLATE.RunSwp{(nSel(k))}).GoodLeak = SCSTEPLATE.GoodLeak;
        save(SCSTEPLATE.AnalysisFile, '-struct', 'S', '-append');
        end
           
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function newfile
        global SCSTEPLATE;
        fileOK = 0;
        datafilename = [];
        while isempty(datafilename)
            [datafilename,datafilepath] = uigetfile('*.zsd','Select Data File');
            datafile=[datafilepath datafilename];
        end
 
        SCSTEPLATE.RunSwp = who('-file', datafile);
        SCSTEPLATE.datafile = datafile;
        NewMatFile = [datafile(1:end-4) '_analysis.mat'];
        
        if exist(NewMatFile)==0
            fprintf('creating new analysis file:  %s \n', NewMatFile)
            %set some initial values
            for k=1:length(SCSTEPLATE.RunSwp)
                S.(SCSTEPLATE.RunSwp{k}).GoodBad = 1;
                S.(SCSTEPLATE.RunSwp{k}).Blank = 0;
                S.(SCSTEPLATE.RunSwp{k}).Offset = 0;
                S.(SCSTEPLATE.RunSwp{k}).FiltHz = 0;
                S.(SCSTEPLATE.RunSwp{k}).XMin = [];
                S.(SCSTEPLATE.RunSwp{k}).XMax = [];
                S.(SCSTEPLATE.RunSwp{k}).Tau = [];
                S.(SCSTEPLATE.RunSwp{k}).Amp = [];
                S.(SCSTEPLATE.RunSwp{k}).swOffset = 0;
                S.(SCSTEPLATE.RunSwp{k}).lkOffset = 0;
                S.(SCSTEPLATE.RunSwp{k}).m = [];
                S.(SCSTEPLATE.RunSwp{k}).b = [];
                S.(SCSTEPLATE.RunSwp{k}).AMin = [];
                S.(SCSTEPLATE.RunSwp{k}).AMax = [];
                S.(SCSTEPLATE.RunSwp{k}).GoodLeak = [];
            end
            save(NewMatFile , '-struct', 'S');
        end

        SCSTEPLATE.AnalysisFile = NewMatFile;
        
        % BK edit 08/13/2014
        % Precompute the space needed to store all the raw, fit, and leak
        % data. Create a matrix for it.
        % For matrix below, each sweep is stored in a column. So they are
        % txN matrices where t is the number of time points and N is the
        % total number of swps
        % AutoFit = matrix to store autofit waveform
        % ManualFit = matrix to store manualfit waveform
        % 
        % The next two matrix are book keeping matrix with size Nx1
        % Finalfit = vector indicating whether autofit or manualfit will be
        % used for the final fitting
        % AutofitOffset = vector to tune autofit DC offset
        
        % Caution: this assumes that all sweeps have identical protocol in
        % time 
        
        % Load FitData if exists
        ANALYSIS = load(SCSTEPLATE.AnalysisFile);
        if isfield(ANALYSIS, 'FitData')
            SCSTEPLATE.FitData.AutoFit = ANALYSIS.FitData.AutoFit;
            SCSTEPLATE.FitData.ManualFit = ANALYSIS.FitData.ManualFit;
            SCSTEPLATE.FitData.FinalFit = ANALYSIS.FitData.FinalFit; %0 to use autofit, 1 to use manual fit
            SCSTEPLATE.FitData.AutoFitOffset = ANALYSIS.FitData.AutoFitOffset;
            SCSTEPLATE.FitData.Time = ANALYSIS.FitData.Time;  

            SCSTEPLATE.FitData.RawData = ANALYSIS.FitData.RawData;
            SCSTEPLATE.FitData.RawLkData = ANALYSIS.FitData.RawLkData;
            SCSTEPLATE.FitData.FamVec = ANALYSIS.FitData.FamVec;
            SCSTEPLATE.FitData.GoodBad = ANALYSIS.FitData.GoodBad;
            SCSTEPLATE.FitData.BadInd = ANALYSIS.FitData.BadInd;
            SCSTEPLATE.FitData.Mean = ANALYSIS.FitData.Mean;
            SCSTEPLATE.FitData.Variance = ANALYSIS.FitData.Variance;
            SCSTEPLATE.FitData.FamVoltage = ANALYSIS.FitData.FamVoltage;
        else
            %Find out total number of time
            DATA = LoadData(SCSTEPLATE.datafile, SCSTEPLATE.RunSwp{1});
            length_t = length(DATA(1).Time);
            SCSTEPLATE.FitData.AutoFit = zeros(length_t, length(SCSTEPLATE.RunSwp));
            SCSTEPLATE.FitData.ManualFit = zeros(length_t, length(SCSTEPLATE.RunSwp));
            SCSTEPLATE.FitData.FinalFit = zeros(length(SCSTEPLATE.RunSwp), 1); %0 to use autofit, 1 to use manual fit
            SCSTEPLATE.FitData.AutoFitOffset = zeros(length(SCSTEPLATE.RunSwp), 1);
            SCSTEPLATE.FitData.Time = DATA(1).Time*1000 - 1000*DATA(1).StimParams.PrePoints/DATA(1).SamplingFreqHz;  %time in ms
            SCSTEPLATE.FitData.Time = (SCSTEPLATE.FitData.Time)';

            SCSTEPLATE.FitData.RawData = zeros(length_t, length(SCSTEPLATE.RunSwp));
            SCSTEPLATE.FitData.RawLkData = zeros(length_t, length(SCSTEPLATE.RunSwp));
            SCSTEPLATE.FitData.FamVec = zeros(length(SCSTEPLATE.RunSwp), 1);
            SCSTEPLATE.FitData.GoodBad = ones(length(SCSTEPLATE.RunSwp), 1);
            SCSTEPLATE.FitData.BadInd = [];
            SCSTEPLATE.FitData.Mean = [];
            SCSTEPLATE.FitData.Variance = [];
            % For family steps, find out number of Vtest
            VF = DATA(1).StimParams.VF;
            SCSTEPLATE.FitData.FamVoltage = VF;
        end
        
        if isfield(ANALYSIS, 'DataAnalysisParams')
            SCSTEPLATE.DataAnalysisParams.SwpWind = ANALYSIS.DataAnalysisParams.SwpWind;
            SCSTEPLATE.DataAnalysisParams.TimeWind = ANALYSIS.DataAnalysisParams.TimeWind;
            SCSTEPLATE.DataAnalysisParams.InstruWind = ANALYSIS.DataAnalysisParams.InstruWind;
            SCSTEPLATE.DataAnalysisParams.AmpHistCurrentBin = ANALYSIS.DataAnalysisParams.AmpHistCurrentBin;
            SCSTEPLATE.DataAnalysisParams.BinoFitChRange = ANALYSIS.DataAnalysisParams.BinoFitChRange;
            SCSTEPLATE.DataAnalysisParams.BinoFitStTime = ANALYSIS.DataAnalysisParams.BinoFitStTime;
            SCSTEPLATE.DataAnalysisParams.UnitaryCurrent = ANALYSIS.DataAnalysisParams.UnitaryCurrent;
            SCSTEPLATE.DataAnalysisParams.NumCh = ANALYSIS.DataAnalysisParams.NumCh;
        else
            SCSTEPLATE.DataAnalysisParams.SwpWind = [1 200];
            SCSTEPLATE.DataAnalysisParams.TimeWind = [3.2 20];
            SCSTEPLATE.DataAnalysisParams.InstruWind = [2.5 3];
            SCSTEPLATE.DataAnalysisParams.AmpHistCurrentBin = [-10 2];
            SCSTEPLATE.DataAnalysisParams.BinoFitChRange = [1 30];
            SCSTEPLATE.DataAnalysisParams.BinoFitStTime = [3.2 4];
            SCSTEPLATE.DataAnalysisParams.UnitaryCurrent = [-2 -1.7 -1.4];
            SCSTEPLATE.DataAnalysisParams.NumCh = 1;
        end
       
        % Next, create a raw and leak data matrix
        % Fill in iRaw matrix and leak matrix
        for k = 1:length(SCSTEPLATE.RunSwp)
            
            %Obtain data for sweep
            DATA = LoadData(SCSTEPLATE.datafile, SCSTEPLATE.RunSwp{k});
            %ANALYSIS = load(SCSTEPLATE.AnalysisFile, '-mat');
            swANALYSIS = ANALYSIS.(SCSTEPLATE.RunSwp{k});
            GoodLeak = swANALYSIS.GoodLeak;
            swOffset = swANALYSIS.swOffset;
            lkOffset = swANALYSIS.lkOffset;
                
            %Store which voltage pulse it is 
            Vtest = DATA(1).StimParams.Vstep(2);
            SCSTEPLATE.FitData.FamVec(k) = DATA(1).StimParams.Vstep(2);
            
            % Will not work for >1 test pulse
            SCSTEPLATE.FitData.tStart(k) = DATA(1).StimParams.Dstep(1);
            SCSTEPLATE.FitData.GoodBad(k) = swANALYSIS.GoodBad;
            if SCSTEPLATE.FitData.GoodBad(k) == 0
                SCSTEPLATE.FitData.BadInd = [SCSTEPLATE.FitData.BadInd; k];
            end
            
            %Data vector
            iRaw = DATA(1).AcqWaveform;
%             if length(iRaw)>0
%                  iRaw = SCSTEPLATE.FitData.RawLkData(:, 1)*0;
%             end
            
            %Calculate leak vector
            SF = DATA(2).StimParams.LeakSF;
            if isempty(GoodLeak)
                GoodLeak =ones(1,length(DATA(2).AcqWaveform(1,1,:)));
            end
            LkSum = 0;
            
            for n=1:length(GoodLeak);
                try
                    iLeak(:,n) = DATA(2).AcqWaveform(1,:,n);
                catch
%                      iLeak(:,n) = 0*iRaw;
                end
                if GoodLeak(n)==1;
                    LkSum = LkSum + iLeak(:,n);
                end
            end

            if isempty(GoodLeak)
                avgLk = mean(DATA(2).AcqWaveform,3);
            else
                avgLk = LkSum/sum(GoodLeak);
            end

            if swANALYSIS.swOffset==0
                swOffset = mean(iRaw(10:DATA(1).StimParams.PrePoints));
            end
            if swANALYSIS.lkOffset==0
                lkOffset = mean(avgLk(10:DATA(1).StimParams.PrePoints));
            end
            avgLk = avgLk - lkOffset;
            avgLk = avgLk*SF;
            SCSTEPLATE.FitData.RawLkData(:, k) = avgLk;
                        
            iRaw = DATA(1).AcqWaveform - swOffset;
            try
            SCSTEPLATE.FitData.RawData(:,k) = iRaw;
            catch
                size(iRaw)
            end
            % Try to create manual fit if already there
            XMin = swANALYSIS.XMin;
            XMax = swANALYSIS.XMax;
            Tau = swANALYSIS.Tau;
            Amp = swANALYSIS.Amp;
            AMin = swANALYSIS.AMin;
            AMax = swANALYSIS.AMax;
            if isfield(swANALYSIS,'Delay')
                Delay = swANALYSIS.Delay;
            else
                Delay = zeros(size(Tau));
            end
            
            updateManualFitMatrix(k, Amp, Tau, XMax, XMin, Delay, AMin, AMax);
        end
      
        
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function DATA = LoadData(FullPathname, RunSwp);

            Error = [];

            if strcmpi(FullPathname(end-3:end), '.zsd')
                DATA = load(FullPathname, RunSwp, '-mat');
                DATA = DATA.(RunSwp);

                for k=1:length(DATA)
                    DATA(k).LowpassHz = DATA(k).SamplingFreqHz;
                    DATA(k).NB = 0;
                    %DATA(k).RI = DATA(k).StimParams.RI;
                    DATA(k).HoldingValue = DATA(k).StimParams.H;
                    DATA(k).SamplingFreqHz = DATA(k).SamplingFreqHz;
                    DATA(k).CellNum = DATA(k).DBParams.CellNum;
                    DATA(k).XFect = DATA(k).DBParams.XFect;

                    %now initialize these
                    DATA(k).Time           = (0:size(DATA(k).AcqWaveform16,2)-1)/DATA(k).SamplingFreqHz;
                    DATA(k).AcqWaveform    = double(DATA(k).AcqWaveform16);
                    for ch=1:size(DATA(k).AcqWaveform,1)
                        DATA(k).AcqWaveform(ch,:,:)    = DATA(k).AcqWaveform(ch,:,:)/DATA(k).AcqPtsPerUnit(ch);
                    end
                    DATA(k).StimWaveform    = double(DATA(k).StimWaveform16);
                    for ch=1:size(DATA(k).StimWaveform,1)
                        DATA(k).StimWaveform(ch,:,:)    = DATA(k).StimWaveform(ch,:,:)/DATA(k).StimPtsPerUnit(ch);
                    end
                    if findstr(DATA(k).StimName, 'StepRamp')
                       RampPos = DATA(k).StepRampStepLen+1;
                       DATA(k).Time = DATA(k).Time(RampPos:end);
                       DATA(k).AcqWaveform = DATA(k).AcqWaveform(RampPos:end);
                       DATA(k).StimWaveform = DATA(k).StimWaveform(RampPos:end);                       
                    end                    
                end

                % invert reversed data
                % if strcmpi(FullPathname(end-6:end-4), 'inv')
                if (findstr(DATA(1).StimName, 'Ramp'))
                    DATA.AcqWaveform  = -DATA.AcqWaveform;                    
                else
                    for k=1:length(DATA)
                        DATA(k).AcqWaveform = -DATA(k).AcqWaveform;
                    end
                end
                %end

            else


                try
                    %open file
                    datafileID = fopen(FullPathname, 'rb');
                    dirblock = fread(datafileID, 256, 'short');

                    %now load the info from each run - not the data, just the info.
                    infoADRS = dirblock(Run*2+1);
                    fseek(datafileID, infoADRS*512, -1);
                    infoblock = fread(datafileID, 128, 'short');

                    if infoblock(1) ~= 32100
                        disp('DecFile::LoadData Warning - Infoblock is weird');
                    end

                    %first the leak/BlocksPerTrace
                    BlocksPerTrace =  double(infoblock(13+1));    %blocks per trace, inlcuding leak

                    %now some things that we'll assume is the same for each run/channel
                    DATA.SamplingFreqHz =  1e6/double(infoblock(6+1));
                    DATA.LowpassHz      = double(infoblock(21+1));		% lopass filter frequency
                    DATA.HoldingValue   =  double(infoblock(2+1));		% holding potential
                    DATA.RI             = double(infoblock(5+1))/10;
                    DATA.NB             = double(infoblock(13+1));
                    %Gain                =  double(infoblock(7+1))/10;   % gain (mV/pA)
                    StimulusType        =  double(infoblock(18+1));  %0: step, 1:ramp, 2:family, 3:APW Step, 4:APW Family
                    if StimulusType ~= 1
                        disp('Warning, this data is not a ramp!!!!');
                    end

                    %now initialize these
                    DATA.Time           = ((0:256*BlocksPerTrace-13))/DATA.SamplingFreqHz;
                    DATA.AcqWaveform    = zeros(1, 256*BlocksPerTrace-12,  1);
                    DATA.StimWaveform   = zeros(1, 256*BlocksPerTrace-12,  1);

                    %Get dtata for this sweep
                    %     traceADRS = infoADRS + 2 + BlocksPerTrace + 1*BlocksPerTrace*(Swp-1);
                    traceADRS = infoADRS + 2 + BlocksPerTrace + 1*BlocksPerTrace*(Swp-1);
                    fseek(datafileID, 512*traceADRS, -1);
                    dtrace=fread(datafileID, 256*BlocksPerTrace, 'short');

                    %now trim that junk
                    dtrace = dtrace(1:256*BlocksPerTrace-12);  %trim some junk at end, I think????
                    dtrace = double(dtrace)*(10000/2048)/Gain;  %This is the current trace in pico Amps

                    %now save it
                    DATA.AcqWaveform = dtrace';

                    %Type = 'Ramp';
                    Vramp =  double(infoblock(23:24)');  % Family start,stop, (note: increment is 25, but that's not important)
                    DATA.StimWaveform = DATA.Time/DATA(1).Time(end)*(Vramp(2)-Vramp(1)) + Vramp(1);
             
                end
            end
                
                %close file
                try
                    fclose(datafileID);
                catch
                end

                %now throw any error
                if ~isempty(Error)
                    rethrow(Error);
                end

        
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function DATA = LoadDataMRT(FullPathname, Run, Swp, Gain);

Error = [];

%ied addition: open zsd

if strcmpi(FullPathname(end-3:end), '.zsd')
    DATA = load(FullPathname, ['Run' num2str(Run,'%.4d') '_Swp' num2str(Swp,'%.4d')], '-mat');
    DATA = DATA.(['Run' num2str(Run,'%.4d') '_Swp' num2str(Swp,'%.4d')]);
    DATA.LowpassHz = DATA.SamplingFreqHz;
    DATA.NB = 0;
    DATA.RI = DATA.StimParams.RI;
    DATA.HoldingValue = DATA.StimParams.H;
    DATA.SamplingFreqHz = DATA.SamplingFreqHz;
    for k=1:length(DATA)
        %now initialize these
        DATA(k).Time           = (0:size(DATA(k).AcqWaveform16,2)-1)/DATA(k).SamplingFreqHz;
        DATA(k).AcqWaveform    = double(DATA(k).AcqWaveform16);
        for ch=1:size(DATA(k).AcqWaveform,1)
            DATA(k).AcqWaveform(ch,:,:)    = DATA(k).AcqWaveform(ch,:,:)/DATA(k).AcqPtsPerUnit(ch);
        end
        DATA(k).StimWaveform    = double(DATA(k).StimWaveform16);
        for ch=1:size(DATA(k).StimWaveform,1)
            DATA(k).StimWaveform(ch,:,:)    = DATA(k).StimWaveform(ch,:,:)/DATA(k).StimPtsPerUnit(ch);
        end

    end

    % ied addition , invert reversed data

    %if strcmpi(FullPathname(end-6:end-4), 'inv')
    DATA.AcqWaveform  = -DATA.AcqWaveform;
    %end
    %end


else


    try
        %open file
        datafileID = fopen(FullPathname, 'rb');
        dirblock = fread(datafileID, 256, 'short');

        %now load the info from each run - not the data, just the info.
        infoADRS = dirblock(Run*2+1);
        fseek(datafileID, infoADRS*512, -1);
        infoblock = fread(datafileID, 128, 'short');

        if infoblock(1) ~= 32100
            disp('DecFile::LoadData Warning - Infoblock is weird');
        end

        %first the leak/BlocksPerTrace
        BlocksPerTrace =  double(infoblock(13+1));    %blocks per trace, inlcuding leak

        %now some things that we'll assume is the same for each run/channel
        DATA.SamplingFreqHz =  1e6/double(infoblock(6+1));
        DATA.LowpassHz      = double(infoblock(21+1));		% lopass filter frequency
        DATA.HoldingValue   =  double(infoblock(2+1));		% holding potential
        DATA.RI             = double(infoblock(5+1))/10;
        DATA.NB             = double(infoblock(13+1));
        %Gain                =  double(infoblock(7+1))/10;   % gain (mV/pA)
        StimulusType        =  double(infoblock(18+1));  %0: step, 1:ramp, 2:family, 3:APW Step, 4:APW Family
        if StimulusType ~= 1
            disp('Warning, this data is not a ramp!!!!');
        end

        %now initialize these
        DATA.Time           = ((0:256*BlocksPerTrace-13))/DATA.SamplingFreqHz;
        DATA.AcqWaveform    = zeros(1, 256*BlocksPerTrace-12,  1);
        DATA.StimWaveform   = zeros(1, 256*BlocksPerTrace-12,  1);

        %Get dtata for this sweep
        %     traceADRS = infoADRS + 2 + BlocksPerTrace + 1*BlocksPerTrace*(Swp-1);
        traceADRS = infoADRS + 2 + BlocksPerTrace + 1*BlocksPerTrace*(Swp-1);
        fseek(datafileID, 512*traceADRS, -1);
        dtrace=fread(datafileID, 256*BlocksPerTrace, 'short');

        %now trim that junk
        dtrace = dtrace(1:256*BlocksPerTrace-12);  %trim some junk at end, I think????
        dtrace = double(dtrace)*(10000/2048)/Gain;  %This is the current trace in pico Amps

        %now save it
        DATA.AcqWaveform = dtrace';

        %Type = 'Ramp';
        Vramp =  double(infoblock(23:24)');  % Family start,stop, (note: increment is 25, but that's not important)
        DATA.StimWaveform = DATA.Time/DATA(1).Time(end)*(Vramp(2)-Vramp(1)) + Vramp(1);


    catch
        Error = lasterror;
    end
end

%close file
try
    fclose(datafileID);
catch
end
%now throw any error
if ~isempty(Error)
    rethrow(Error);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%       
function setupUnitary
    global SCSTEPLATE;
    sU = figure('units','normalized','position',[0.7 0.55 0.2 0.35],'color',[1 1 1]); 
    if ~(SCSTEPLATE.Unitary.UniSet)
    SCSTEPLATE.Unitary.UniSet = true;
    SCSTEPLATE.Unitary.Voltage = [-90 -30 0 -50]';
    SCSTEPLATE.Unitary.Current = NaN(size(SCSTEPLATE.Unitary.Voltage));
    end
    Cols = {'V(mV)', 'i(pA)'};
    SCSTEPLATE.Unitary.t = uitable('units','normalized','position',[0.05 0.95-0.3 0.9 0.3],'Data',[SCSTEPLATE.Unitary.Voltage SCSTEPLATE.Unitary.Current],'ColumnName',Cols,'ColumnFormat',{'numeric','numeric'},'ColumnEditable',true,'CellEditCallback','SCLate(''UnitaryUpdate'')');
    SCSTEPLATE.Unitary.ax = axes('units','normalized','position',[0.1 0.2 0.8 0.35],'TickDir','out');
    plot(SCSTEPLATE.Unitary.ax, SCSTEPLATE.Unitary.Voltage,SCSTEPLATE.Unitary.Current,'ko',[-90 50],[0 0],'k-','MarkerFaceColor',[1 0 0])
    box off;
    SCSTEPLATE.Unitary.Conductance.Text  = uicontrol('Style', 'text', 'String','g', 'BackgroundColor', [1 1 1],'HorizontalAlignment', 'left','units', 'normalized', 'Position', [0.03 0.03 0.15 0.07]);
    SCSTEPLATE.Unitary.Conductance.Edit  = uicontrol('Style', 'edit', 'String','','BackgroundColor', [1 1 1], 'HorizontalAlignment', 'left','units', 'normalized', 'Position',[0.21 0.03 0.15 0.07],'Callback','SCLate(''UnitaryUpdateFit'')');
    SCSTEPLATE.Unitary.Vrev.Text  = uicontrol('Style', 'text', 'String','Vrev', 'BackgroundColor', [1 1 1],'HorizontalAlignment', 'left','units', 'normalized', 'Position', [0.39 0.03 0.15 0.07]);
    SCSTEPLATE.Unitary.Vrev.Edit = uicontrol('Style', 'edit', 'String','','BackgroundColor', [1 1 1], 'HorizontalAlignment', 'left','units', 'normalized', 'Position',[0.57 0.03 0.15 0.07],'Callback','SCLate(''UnitaryUpdateFit'')');

    MakeButtonGroup('AutoFitI', [0.75 0.03 0.15 0.07]);

    if isfield(SCSTEPLATE.Unitary,'g') 
        set(SCSTEPLATE.Unitary.Conductance.Edit,'string',num2str(SCSTEPLATE.Unitary.g));
    else
        SCSTEPLATE.Unitary.g = str2num(get(SCSTEPLATE.Unitary.Conductance.Edit,'string'));
    end
    if isfield(SCSTEPLATE.Unitary,'Vr')
        set(SCSTEPLATE.Unitary.Vrev.Edit,'string',num2str(SCSTEPLATE.Unitary.Vr));
    else
        SCSTEPLATE.Unitary.Vr = str2num(get(SCSTEPLATE.Unitary.Vrev.Edit,'string'));  
    end
       
    if ~isempty(SCSTEPLATE.Unitary.Vr) && ~isempty(SCSTEPLATE.Unitary.g)
        hold on;
        Vtemp = -90:0.1:50;
        plot(Vtemp, SCSTEPLATE.Unitary.g/1000*(Vtemp-SCSTEPLATE.Unitary.Vr),'k-');
        hold off; 
    end
    set( SCSTEPLATE.Unitary.ax,'TickDir','out')
    
function UnitaryUpdate
    hold off
    global SCSTEPLATE;
    Data = get(SCSTEPLATE.Unitary.t,'Data');
    SCSTEPLATE.Unitary.Voltage = Data(:,1);
    SCSTEPLATE.Unitary.Current = Data(:,2);
    plot(SCSTEPLATE.Unitary.ax, SCSTEPLATE.Unitary.Voltage,SCSTEPLATE.Unitary.Current,'ko',[-90 50],[0 0],'k-','MarkerFaceColor',[1 0 0])
    ylim([min([-0.25;SCSTEPLATE.Unitary.Current]) max([0.25 max(SCSTEPLATE.Unitary.Current)])*1.5])
    xlim([-90 50])
    box off;
    SCSTEPLATE.Unitary.g    = str2num(get(SCSTEPLATE.Unitary.Conductance.Edit,'string'));
    SCSTEPLATE.Unitary.Vr = str2num(get(SCSTEPLATE.Unitary.Vrev.Edit,'string'));  
    hold on;
    Vtemp = -90:0.1:50;
    try
    plot(Vtemp, SCSTEPLATE.Unitary.g/1000*(Vtemp-SCSTEPLATE.Unitary.Vr),'r-');
    hold off; 
    ylim([min([-0.25;SCSTEPLATE.Unitary.Current]) max([0.25 max(SCSTEPLATE.Unitary.Current)])]*1.5)
    set( SCSTEPLATE.Unitary.ax,'TickDir','out')
    end
function AutoFitI
    global SCSTEPLATE;
    Data = get(SCSTEPLATE.Unitary.t,'Data');
    SCSTEPLATE.Unitary.Voltage = Data(:,1);
    SCSTEPLATE.Unitary.Current = Data(:,2);
    Mask = (isnan(SCSTEPLATE.Unitary.Current) |  isnan(SCSTEPLATE.Unitary.Voltage));
    p = polyfit(SCSTEPLATE.Unitary.Voltage(~Mask), SCSTEPLATE.Unitary.Current(~Mask),1);
    SCSTEPLATE.Unitary.g = p(1)*1000;
    SCSTEPLATE.Unitary.Vr = -p(2)/p(1);
    set(SCSTEPLATE.Unitary.Conductance.Edit,'string',SCSTEPLATE.Unitary.g)
    set(SCSTEPLATE.Unitary.Vrev.Edit,'string',SCSTEPLATE.Unitary.Vr)
    SCLate('UnitaryUpdate')
    
function UnitaryUpdateFit
     global SCSTEPLATE
     SCSTEPLATE.Unitary.g  = str2num(get(SCSTEPLATE.Unitary.Conductance.Edit,'string'));
     SCSTEPLATE.Unitary.Vr = str2num(get(SCSTEPLATE.Unitary.Vrev.Edit,'string'));  
     SCLate('UnitaryUpdate')
     
function iAmpHist
        global SCSTEPLATE;        
        % Determine Window to cmpute histogram.
        Pts = ginput(2);
        
        nSel = get(SCSTEPLATE.Box, 'value');
        nSel = nSel(find(SCSTEPLATE.FitData.GoodBad(nSel)));
        Data = SCSTEPLATE.FitData.RawData(:,nSel)-SCSTEPLATE.FitData.ManualFit(:,nSel);
        
        Twindow = Pts(1:2,1)';  
        t = SCSTEPLATE.FitData.Time;
        Mask = (t>Twindow(1))&(t<=Twindow(2));
        tMask = t(Mask);
        DataMask = Data(Mask,:);
        
        ReshapedData = reshape(DataMask,1,[]);
        bins = linspace(floor(min(ReshapedData)),ceil(max(ReshapedData)),50);
        vals = hist(ReshapedData,bins);
        
        figure('units', 'normalized', 'color',[1 1 1],'position',[0.6 0.3 0.3 0.4]); 
        subplot(2,1,1)
        plot(tMask, DataMask)
        set(gca,'TickDir','out')
        xlim([tMask(1) tMask(end)]);
        subplot(2,1,2)
        h = bar(bins,sqrt(vals));
        set(h,'EdgeColor','none','FaceColor',[0 0 0],'Barwidth',1)
        set(gca,'TickDir','out')
        [pks, loc] = findpeaks(sqrt(vals));
        if length(pks)>1
        TempLoc = loc(end-1);
        line([bins(TempLoc); bins(TempLoc)],[0; max(pks)])
        clipboard('copy',bins(TempLoc))
        end
        
function ComputeLateCurrent
        global SCSTEPLATE;        
        nSel = get(SCSTEPLATE.Box, 'value');
        nSel = nSel(find(SCSTEPLATE.FitData.GoodBad(nSel)));
        Data = SCSTEPLATE.FitData.RawData(:,nSel)-SCSTEPLATE.FitData.ManualFit(:,nSel);
        Vtest = SCSTEPLATE.FitData.FamVec(nSel);
        t = SCSTEPLATE.FitData.Time;
        try
            i_x = SCSTEPLATE.Unitary.g/1000.*(Vtest - SCSTEPLATE.Unitary.Vr);
            iMatrix = ones(size(Data,1),1)*i_x';
            iData = round(Data./iMatrix);
            Mask = t>50;
            iDataLate = mean(iData(Mask,:));
            iPeak = max(iData(~Mask,:));
            meanI = mean(Data,2);
            iLatepercent = iDataLate./iPeak*100;
            iLatepercentavg = mean(meanI(Mask))/min(meanI(~Mask))*100;
            
            figure; 
            bins = linspace(-2,2,25);
            [ev, bins] = hist(log(iLatepercent)/log(10),bins);
            bar(bins,ev,'EdgeColor','none','Barwidth',1,'FaceColor',[0.5 0.5 0.5])
            clipboard('copy',sprintf('%5.4f\n',[iLatepercentavg,iLatepercent]));
            
        catch EM
             rethrow(EM)
        end
        
function CopyAverage
        global SCSTEPLATE;        
        nSel = get(SCSTEPLATE.Box, 'value');
        nSel = nSel(find(SCSTEPLATE.FitData.GoodBad(nSel)));
        Data = SCSTEPLATE.FitData.RawData(:,nSel)-SCSTEPLATE.FitData.ManualFit(:,nSel);
        Vtest = SCSTEPLATE.FitData.FamVec(nSel);
        t = SCSTEPLATE.FitData.Time;
        try
            i_x = SCSTEPLATE.Unitary.g/1000.*(Vtest - SCSTEPLATE.Unitary.Vr);
            iMatrix = ones(size(Data,1),1)*i_x';
            iData = round(Data./iMatrix);
            meanI = mean(Data,2);
            clipboard('copy',sprintf('%5.4f\t%5.4f\t%5.4f\n', [t, meanI mean(iData,2)]'));            
        catch EM
             rethrow(EM)
        end        