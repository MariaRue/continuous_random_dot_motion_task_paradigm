function varargout = dots_task_gui(varargin)
% DOTS_TASK_GUI MATLAB code for dots_task_gui.fig
%      DOTS_TASK_GUI, by itself, creates a new DOTS_TASK_GUI or raises the existing
%      singleton*.
%
%      H = DOTS_TASK_GUI returns the handle to a new DOTS_TASK_GUI or the handle to
%      the existing singleton*.
%
%      DOTS_TASK_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in DOTS_TASK_GUI.M with the given input arguments.
%
%      DOTS_TASK_GUI('Property','Value',...) creates a new DOTS_TASK_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before dots_task_gui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to dots_task_gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help dots_task_gui

% Last Modified by GUIDE v2.5 27-Jun-2019 09:36:08

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @dots_task_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @dots_task_gui_OutputFcn, ...
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


% --- Executes just before dots_task_gui is made visible.
function dots_task_gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to dots_task_gui (see VARARGIN)

% Choose default command line output for dots_task_gui
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes dots_task_gui wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = dots_task_gui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in params_file_path.
function params_file_path_Callback(hObject, eventdata, handles)
% Open parameters file
[name, path] = uigetfile('*csv', 'Select parameters file');
% Set up fileName variable if a file has been opened
if isequal(name, 0) || isequal(path, 0)
    fileName = '';
else
    fileName = [path name];
end
% Change textbox string to reflect file path + name
set(handles.filePath, 'string', fileName);
setappdata(0, 'fileName', fileName);
% hObject    handle to params_file_path (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in begin_task.
function begin_task_Callback(hObject, eventdata, handles)
% hObject    handle to begin_task (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function trials_number_Callback(hObject, eventdata, handles)
% hObject    handle to trials_number (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of trials_number as text
%        str2double(get(hObject,'String')) returns contents of trials_number as a double


% --- Executes during object creation, after setting all properties.
function trials_number_CreateFcn(hObject, eventdata, handles)
% hObject    handle to trials_number (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in radbut_training.
function radbut_training_Callback(hObject, eventdata, handles)
% hObject    handle to radbut_training (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radbut_training


% --- Executes on button press in radbut_eeg.
function radbut_eeg_Callback(hObject, eventdata, handles)
% hObject    handle to radbut_eeg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radbut_eeg
