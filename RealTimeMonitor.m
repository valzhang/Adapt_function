function varargout = RealTimeMonitor(varargin)
% REALTIMEMONITOR MATLAB code for RealTimeMonitor.fig
%      REALTIMEMONITOR, by itself, creates a new REALTIMEMONITOR or raises the existing
%      singleton*.
%
%      H = REALTIMEMONITOR returns the handle to a new REALTIMEMONITOR or the handle to
%      the existing singleton*.
%
%      REALTIMEMONITOR('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in REALTIMEMONITOR.M with the given input arguments.
%
%      REALTIMEMONITOR('Property','Value',...) creates a new REALTIMEMONITOR or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before RealTimeMonitor_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to RealTimeMonitor_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help RealTimeMonitor

% Last Modified by GUIDE v2.5 27-May-2014 15:23:51

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @RealTimeMonitor_OpeningFcn, ...
                   'gui_OutputFcn',  @RealTimeMonitor_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before RealTimeMonitor is made visible.
function RealTimeMonitor_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to RealTimeMonitor (see VARARGIN)

% Choose default command line output for RealTimeMonitor
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes RealTimeMonitor wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = RealTimeMonitor_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
global log_string
log_string = {'——','——','——','——','——','——'};
global last_signal
last_signal = zeros(5,1);

% --- Executes on selection change in popupmenu1.
function popupmenu1_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu1


% --- Executes during object creation, after setting all properties.
function popupmenu1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu2.
function popupmenu2_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu2


% --- Executes during object creation, after setting all properties.
function popupmenu2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu3.
function popupmenu3_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu3 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu3


% --- Executes during object creation, after setting all properties.
function popupmenu3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

push_t = timer('TimerFcn', {@timercallback, handles}, 'ExecutionMode', 'fixedRate', 'Period', 30 );
start(push_t);

function timercallback(obj, event, handles)
path = 'code.xls';
[num All_code] = xlsread(path);
code_num = get(handles.popupmenu1, 'Value');
code = All_code(code_num);
k_num = get(handles.popupmenu2, 'Value');
All_Klines = [ -1, 1, 2, 5, 15, 30 ];
cycle = All_Klines(k_num);
strategy = get(handles.popupmenu3, 'Value');
str_name = cell(5,1);
str_name(1) = {'day_timing_20ma_plus_RSI'};
str_name(2) = {'wang_flag'};
str_name(3) = {'wang_timing'};
str_name(4) = {'ZWH_MultiMA'};
str_name(5) = {'ZWH_Reverse_PV'};
simulate_now = now ;
output_signals = cell(5,1);

        output_signals(1) = {0};
        output_signals(2) = {0};
        output_signals(3) = {0};
        output_signals(4) = {0};
        output_signals(5) = {0};

%计算往前推算时间
switch cycle
    case -1
        gap = 60;
    case 1
        gap = 60;
    case 2
        gap = 60;
    case 5
        gap = 60;
    case 15
        gap = 60;
    case 30
        gap = 60; 
end
gap = 58;


switch strategy
    case 4
        %计算显示的K线策略
        [outStat, dailydetail, monthdetail, allsignal, signalSeries]=ZWH_MultiMA(cell2mat(code), cycle, datestr(simulate_now-gap), datestr(simulate_now));
    %    axes(handles.axes1)    
     %   cla(handles.axes1);
     signalSeries.signal(end)
     size(signalSeries.signal)
        ADT_SignalCandle(signalSeries, datestr(simulate_now-gap), datestr(simulate_now));
        if cell2mat(outStat(5, 2)) < 0  %防止没有交易数据
            output_signals(4) = {0};
        else
            output_signals(4) = {signalSeries.signal(end)};
        end

        %计算其他策略
        [outStat, dailydetail, monthdetail, allsignal, signalSeries]=ZWH_Reverse_PV(cell2mat(code), cycle, datestr(simulate_now-gap), datestr(simulate_now));  
        if cell2mat(outStat(5, 2)) < 0  %防止没有交易数据
            output_signals(5) = {0};
        else
            output_signals(5) = {signalSeries.signal(end)};
        end
        
    case 5
        %计算显示的K线策略        
        [outStat, dailydetail, monthdetail, allsignal, signalSeries]=ZWH_Reverse_PV(cell2mat(code), cycle, datestr(simulate_now-gap), datestr(simulate_now));  
        %axes(handles.axes1)    
        %cla(handles.axes1);
        ADT_SignalCandle(signalSeries, datestr(simulate_now-gap), datestr(simulate_now));
        if cell2mat(outStat(5, 2)) < 0  %防止没有交易数据
            output_signals(5) = {0};
        else
            output_signals(5) = {signalSeries.signal(end)};
        end
        
        %计算其他策略        
        [outStat, dailydetail, monthdetail, allsignal, signalSeries]=ZWH_MultiMA(cell2mat(code), cycle, datestr(simulate_now-gap), datestr(simulate_now));
        if cell2mat(outStat(5, 2)) < 0  %防止没有交易数据
            output_signals(4) = {0};
        else
            output_signals(4) = {signalSeries.signal(end)};
        end
end
set( handles.uitable1, 'ColumnName', {'Name', 'Signal'}, 'Data', [str_name, output_signals]);

%处理策略4的实时信号
global log_string
global last_signal
if cell2mat(output_signals(4)) ~= last_signal(4)
    log_string(1:5) = log_string(2:6);
    log_string(6) = {sprintf('%s——Strategy ZWH_MultiMA Signal——%d', datestr(now, 31), cell2mat(output_signals(4)) )};
    last_signal(4) = cell2mat(output_signals(4));
end
%处理策略5的实时信号
if cell2mat(output_signals(5)) ~= last_signal(5)
    log_string(1:5) = log_string(2:6);
    log_string(6) = {sprintf('%s——Strategy ZWH_MultiMA Signal——%d', datestr(now, 31), cell2mat(output_signals(5)) )};
    last_signal(5) = cell2mat(output_signals(5));
end
set( handles.text6, 'String', log_string );         
