function [p] = readparamtxt(param_file, par2num)

% this function reads in parameters from a text file params.txt - This
% contains a table with different parameters we might want to change


% expID = mac or 7ts
% expday = year,month,day
% exparea = LIP,FEF or none for training
% subid = e.g. test17
% subgender = f or m
% subage = subject age
% srcwidth = width of display screen in mm
% srcheight = height of display sreen in mm
% subdist = subject distance to screen in mm
% rdk     = dot diameter in visual degrees
% fix    =  fix dot diamter in visual degrees
% trg    =  target diamter in visual degrees

% param and values need be separated by a comma

[N,T,R] = xlsread(param_file); % read in file

num_rows = size(R,1);
values = cell(num_rows,1);
 
  % Convert certain parameters to numbers, if requested
 for i = 1 : num_rows
     
  
     if isnan(N(i,1))
         values{i} = T(i,2);
         
     else
    values{i} = N(i,~isnan(N(i,:)));
  
     end
    
  end % string 2 numb
C = [T(:,1), values]'; % transform to cell array

p = struct(C{:}); % transform cell array to struct with param names as field names


end