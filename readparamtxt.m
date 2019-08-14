function [p] = readparamtxt(param_file, par2num)

% PURPOSE: this function reads in parameters from a .csv file (param_file)
% which contains the different parameters of the task we may wish to change

% expID = mac or 7ts
% expday = year,month,day
% exparea = LIP,FEF or none for training
% subid = subject ID e.g. test17
% subgender = f or m
% subage = subject age
% srcwidth = width of display screen in mm
% srcheight = height of display sreen in mm
% subdist = subject distance to screen in mm
% rdk     = dot diameter in visual degrees
% fix    =  fix dot diamter in visual degrees
% trg    =  target diamter in visual degrees

% param and values need be separated by a comma

T = readtable(param_file, 'ReadVariableNames', true, 'Delimiter', ','); % read in file

% Convert certain parameters to numbers, if requested
if ~isempty(par2num)
    % Find parameters
    i = find(ismember(T.param, par2num));
    % And convert
    T.values(i) = cellfun(@str2num,  T.values(i),  ...
    'UniformOutput',  false);
end % string 2 numb

C = [T.param, num2cell(T.values)]'; % transform to cell array

p = struct(C{:}); % transform cell array to struct with param names as field names

end