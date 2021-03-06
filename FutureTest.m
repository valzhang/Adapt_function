function varargout = FutureTest(varargin)
% FUTURETEST MATLAB code for FutureTest.fig
%      FUTURETEST, by itself, creates a new FUTURETEST or raises the existing
%      singleton*.
%
%      H = FUTURETEST returns the handle to a new FUTURETEST or the handle to
%      the existing singleton*.
%
%      FUTURETEST('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in FUTURETEST.M with the given input arguments.
%
%      FUTURETEST('Property','Value',...) creates a new FUTURETEST or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before FutureTest_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to FutureTest_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help FutureTest

% Last Modified by GUIDE v2.5 26-May-2014 18:21:34

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @FutureTest_OpeningFcn, ...
                   'gui_OutputFcn',  @FutureTest_OutputFcn, ...
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


% --- Executes just before FutureTest is made visible.
function FutureTest_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to FutureTest (see VARARGIN)

% Choose default command line output for FutureTest
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes FutureTest wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = FutureTest_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%初始化各个控件的值
path = 'code.xls';
[num code] = xlsread(path);
start_date = get(handles.edit1, 'String');
end_date = get(handles.edit2, 'String');
start_date = [start_date ' 09:00:00'];
end_date = [end_date ' 15:15:00'];
cycle = zeros(6,2);
cycle(1,1) = get( handles.checkbox2, 'Value' );
cycle(1,2) = -1;
cycle(2,1) = get( handles.checkbox3, 'Value' );
cycle(2,2) = 1;
cycle(3,1) = get( handles.checkbox4, 'Value' );
cycle(3,2) = 2;
cycle(4,1) = get( handles.checkbox5, 'Value' );
cycle(4,2) = 5;
cycle(5,1) = get( handles.checkbox6, 'Value' );
cycle(5,2) = 15;
cycle(6,1) = get( handles.checkbox7, 'Value' );
cycle(6,2) = 30;
earn_ratio = zeros(6,length(code));
trans_num = zeros(6,length(code));
draw_down = zeros(6,length(code));
max_win = zeros(6,length(code));
max_lose = zeros(6,length(code));
sharp_ratio = zeros(6,length(code));
win_ratio = zeros(6,length(code));
for i = 1:6
    if cycle(i,1) == 1
        for j = 1:length(code)
            strategy = get( handles.popupmenu1, 'Value');
            code(j)
            switch strategy
                case 1
                    try
                        [outStat, dailydetail, monthdetail, allsignal, signalSeries]=XY_30MinBreakOut_2min_New(cell2mat(code(j)), cycle(i,2), start_date, end_date);        
                    catch ME1
 
                    end
                otherwise
            end
            if cell2mat(outStat(5, 2)) > 0
                %设置回测指标显示值
                earn_ratio(i,j) = cell2mat(outStat(4,2));
                trans_num(i,j) = cell2mat(outStat(5,2));
                draw_down(i,j) = 0 - cell2mat(outStat(9,2));    %最大回撤取反
                max_win(i,j) = cell2mat(outStat(13,2));
                max_lose(i,j) = cell2mat(outStat(12,2));
                sharp_ratio(i,j) = cell2mat(outStat(27,2));
                win_ratio(i,j) = cell2mat(outStat(6,2));
            end
        end
    end
end

data = {earn_ratio, trans_num, draw_down, max_win, max_lose, sharp_ratio, win_ratio};
sort_num = get( handles.popupmenu2, 'Value');
sort_data = cell2mat(data(sort_num));

output_data = cell(8,7);
%计算指定指标最高的8个品种K线
for i = 1:8
    max_value = max(max(sort_data));
    [cor_x cor_y] = find(sort_data == max_value);
    for j = 1:7
        tmp_data = cell2mat(data(j));
        output_data(i,j) = {tmp_data(cor_x(1), cor_y(1))};
    end
    sort_data(cor_x(1), cor_y(1)) = -1000;
    
    switch cor_x(1)
        case 1
            k_line(i) = {'Day'};
        case 2
            k_line(i) = {1};
        case 3
            k_line(i) = {2};
        case 4
            k_line(i) = {5};
        case 5
            k_line(i) = {15};
        case 6
            k_line(i) = {30};
    end
    
    k_code(i) = code(cor_y(1));
end

%显示指标最好的8种K线详细回测指标
set( handles.uitable1, 'ColumnName', { 'K线种类', '期货品种', '年化收益率', '交易次数', '最大回撤', '单次交易最大盈利', '单次交易最大亏损', '年化夏普比率', '交易胜率' }, 'Data', [ k_line' k_code' output_data ] );
%set( handles.uitable1, 'ColumnName', '期货品种', 'Data', k_code' );
%set( handles.uitable1, 'ColumnName', '年化收益率', 'Data', output_data(:, 1) );


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


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over text1.
function text1_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to text1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on key press with focus on pushbutton1 and none of its controls.
function pushbutton1_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  structure with the following fields (see UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)

function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double


% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit2_Callback(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit2 as text
%        str2double(get(hObject,'String')) returns contents of edit2 as a double


% --- Executes during object creation, after setting all properties.
function edit2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkbox2.
function checkbox2_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox2


% --- Executes on button press in checkbox3.
function checkbox3_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox3


% --- Executes on button press in checkbox4.
function checkbox4_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox4


% --- Executes on button press in checkbox5.
function checkbox5_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox5


% --- Executes on button press in checkbox6.
function checkbox6_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox6


% --- Executes on button press in checkbox7.
function checkbox7_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox7


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
