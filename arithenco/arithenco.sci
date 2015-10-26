function [code] = arithenco(seq, count)
    
    //CODE = ARITHENCO(SEQ, COUNT) encodes the given sequence (SEQ) using arithmetic coding.
    //COUNT is vector whihc gives information about the source statistics (i.e. frequency of each symbol in the source alphabet)
    //CODE is the binary arithmetic code
    
    //Source Alphabet is assumed to be {1,2,....N} where N is a positive integer
    //Therefore, sequence should be finite and positive 
    //Length of the COUNT should match the length of the source alphabet
    
    //Reference :
        //Sayood, K., Introduction to Data Compression, Morgan Kaufmann, 2000, Chapter 4, Section 4.4.3.
    
    //Input argument check
    
    // Written by POLA LAKSHMI PRIYANKA, FOSSEE, IIT BOMBAY //
    [outa,inpa]=argn(0);
    if(~inpa==2)
    error("comm:arithenco:Wrong number of Input Arguments");
    end
    
    [row_seq,col_seq]=size(seq);
    [row_sta,col_sta]=size(count);
    
    // Check to make sure that sequence is 1D
    if(~(row_seq==1|col_seq==1))
        error("comm:arithenco: Invalid dimensions: Input Sequence should be 1D ");
    end
    
    // Check for source statistics matrix 
    if(~(row_sta==1|col_sta==1))
        error("comm:arithenco: Invalid dimensions: Argument 2 should be 1D ");
    end
    
    if(~isreal(seq) | or(seq<0) )
        error("comm:arithenco: Input sequence should be finite positive integer");
    end
    
    if(~isreal(count) | or(count<0) )
        error("comm:arithenco: Source statistics should be finite positive integer");
    end
    
    //Check if number of elements in source alphabet is equal to dimensions of source statistics matrix
    if max(seq) > length(count)
        error("comm:arithenco:Source alphabet size does not match with source statistics size");
    end
    
    //Check the incoming orientation and adjust if necessary
    
    if (row_seq > 1),
        seq = seq.';
    end
    
    if (row_sta > 1),
        count = count.';
    end
    
    [row_s,col_s]=size(seq);
    [row_c,col_c]=size(count);
    
    //Calculate the cumulative count
    cum_count=[0,cumsum(count)];
    scale3=0;
    total_count=cum_count(length(cum_count));
    
    //Initialization
    m=ceil(log2(total_count)) + 2;
    low=zeros(1,m);
    up=ones(1,m);
    dec_low=0;
    dec_up=2^m-1;
    code_len = length(seq) * ( ceil(log2(length(count))) + 2 ) + m;
    code = zeros(1, code_len);
    code_index = 1;
    
    
    // For each bit in the seq
    
    for k=1:length(seq)
        symbol = seq(k);
        // Compute the lower and upper bounds
        dec_low_new = dec_low + floor( (dec_up-dec_low+1)*cum_count(symbol+1-1)/total_count );
        dec_up = dec_low + floor( (dec_up-dec_low+1)*cum_count(symbol+1)/total_count )-1;
        dec_low = dec_low_new;
        
        for i=1:m
        low(i)=strtod(part(dec2bin(dec_low,m),i))
        end
        for i=1:m
        up(i)=strtod(part(dec2bin(dec_up,m),i))
        end

        //Loop while E1, E2 or E3 condition
        while(isequal(low(1),up(1))) | (isequal(low(2),1) & isequal(up(2),0))
            // Check for E1 or E2 condition
            if isequal(low(1),up(1)) then //E1 or E2 holds
                // Transmit MSB
                b=low(1);
                code(code_index) = b;
                code_index = code_index + 1;
                
                //Left shift
                low=[low(2:m) 0];
                up=[up(2:m) 1];
                while (scale3>0)
                code(code_index) = bitxor(b,1);
                code_index = code_index + 1;
                scale3 = scale3-1;
                end
            end
            if (isequal(low(2),1) & isequal(up(2),0)) then //for E3 
                //left shift
                low=[low(2:m),0];
                up=[up(2:m),1];
                //disp(up,low,"up,low");

                low(1)=bitxor(low(1),1);
                up(1)=bitxor(up(1),1);

                scale3=scale3+1;
            end
        end
        dec_low=0;dec_up=0;
        for i=1:length(low)
        dec_low=dec_low+low(i)*2^(length(low)-i);
        dec_up=dec_up+up(i)*2^(length(up)-i);
        end
    end
    if scale3==0 then
    code(code_index:code_index + m - 1) = low;
    code_index = code_index + m;
    end
    if ~scale3==0 then
    b=low(1);
    code(code_index)=b;
    code_index = code_index + 1;
    
    while (scale3>0)
        code(code_index) = bitxor(b,1);
        code_index = code_index + 1;
        scale3 = scale3-1;
    end
    
    code(code_index:code_index+m-2) = low(2:m);
    code_index = code_index + m - 1;
    end
code = code(1:code_index-1);
endfunction
