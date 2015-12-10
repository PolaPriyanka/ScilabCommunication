eg_1.numInputSymbols = 4;
eg_1.numOutputSymbols = 4;
eg_1.numStates = 3;
eg_1.nextStates = [0 1 2 1;0 1 2 1; 0 1 2 1];
eg_1.outputs = [0 0 1 1;1 1 2 1; 1 0 1 1];
res_t_eg_1=istrellis(eg_1)
res_c_eg_1=iscatastrophic(eg_1)
if (res_c_eg_1) then
    disp('Example 1 is catastrophic')
else
    disp('Example 1 is not catastrophic')
end



eg_2.numInputSymbols = 2;
eg_2.numOutputSymbols = 4;
eg_2.numStates = 2;
eg_2.nextStates = [0 0; 1 1 ]
eg_2.outputs = [0 0; 1 1];
res_t_eg_2=istrellis(eg_2)
res_c_eg_2=iscatastrophic(eg_2)
if (res_c_eg_2) then
    disp('Example 2 is catastrophic')
else
    disp('Example 2 is not catastrophic')
end