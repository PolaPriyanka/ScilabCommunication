function [isOk, status]  = istrellis(S)

//ISTRELLIS checks if the given input is of trellis structure

// [ISOK, STATUS]  = ISTRELLIS(S) returns [T,''] if the given input is valid trellis structure. Otherwise ISOK is F and STATUS indicates the reason for invalidity

// Fields in trellis structure are 

//     numInputSymbols,  (number of input symbols)
//     numOutputSymbols, (number of output symbols)
//     numStates,        (number of states)
//     nextStates,       (next state matrix)
//     outputs,          (output matrix)

// Properties of the fields are as follows

//   numInputSymbols and numOutputSymbols should be a power of 2 (as data is represented in bits).

//   The 'nextStates' and 'outputs' fields are matrices of size 'numStates' x 'numInputSymbols' .

//   Each element in the 'nextStates' matrix and 'output' matrix is an integer value between zero and (numStates-1).

//   The (r,c) element of the 'nextStates' matrix and 'output' matrix,denotes the next state and output respectively when
//   the starting state is (r-1) and the input bits have decimal representation (c-1).

//   To convert to decimal value, use the first input bit as the most significant bit (MSB).

//   Written by POLA LAKSHMI PRIYANKA, FOSSEE, IIT BOMBAY //

// Check arguments
[out_a,inp_a]=argn(0)

if (inp_a~=1 | out_a>2) then
    error('comm:istrellis:Invalid number of arguments')
end

status = '';

// Check if input is a structure
isOk = isstruct(S);
if ~isOk then
  status = string(('comm:trellis:Input is not a structure'));
  return;
end

// Check for valid field names
names  = fieldnames(S);
numf = size(names, 1);

actual = {'numInputSymbols';'numOutputSymbols';'numStates';'nextStates';'outputs'}

isOk = (numf == 5) & isequal(gsort(names),gsort(actual));
if ~isOk then
  status = string(('comm:trellis:Structure is not of trellis type'));
  return;
end

// Check for number of Input Symbols.
numInputSymbols = S.numInputSymbols;
isOk = isequal(length(numInputSymbols), 1);
if ~isOk then
  status = string(('comm:trellis:Number of input symbols is not scalar'));
  return;
end

power  = log2(numInputSymbols);
isOk = isequal(power, double(int32(power)));
if ~isOk then
  status = string(('comm:trellis:Number of input symbols is not power of 2'));
  return;
end

// Check for number of Output Symbols.
numOutputSymbols = S.numOutputSymbols;
isOk = isequal(length(numOutputSymbols), 1);
if ~isOk then
  status = string(('comm:trellis:Number of output symbols is not scalar'));
  return;
end

power  = log2(numOutputSymbols);
isOk = isequal(power, double(int32(power)));

if ~isOk then
  status = string(('comm:trellis:Number of input symbols is not power of 2'));
  return;
end

//Check Number of states
isOk = isequal(length(S.numStates), 1) & ...
       isequal(S.numStates, double(int32(S.numStates)));
if isOk then
  isOk =  S.numStates > 0;
end

if ~isOk then
  status = string(('comm:trellis:Number of states is not scalar positive integer'));
  return;
end

// Check nextStates
nextStates = S.nextStates;
numStates  = S.numStates;

// Check size of nextStates
s = size(nextStates);
isOk =  ((length(s) == 2) & (s(1) == numStates) & (s(2) == numInputSymbols) & isequal(double(uint32(nextStates)), nextStates));
if ~isOk then
  status = string(('comm:trellis:Next states field matrix size is incorrect'));
  return;
end

//Check values of nextState
isOk = isempty(find(nextStates >= numStates));
if ~isOk then
  status = string(('comm:trellis: Elements in next state must be in between 0 to numStates - 1'));
  return;
end

//  Check outputs
outputs  = S.outputs;

// check size of outputs
s  = size(outputs);
isOk =  ((length(s) == 2) & (s(1) == numStates) & (s(2)== numInputSymbols) );
if ~isOk then
  status = string(('comm:trellis:Outputs field matrix size is incorrect'));
  return;
end


//Check values of output
decOutputs = oct2dec(string(outputs));
isOk = isempty(find(decOutputs >= numOutputSymbols));
if ~isOk then
  status = string(('comm:trellis: Elements in output must be in between 0 to numStates - 1 '));
  return;
end

endfunction
