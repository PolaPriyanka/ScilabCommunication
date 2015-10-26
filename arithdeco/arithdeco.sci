function [seq] = arithdeco(code, count, len)
    
    //SEQ = ARITHDECO(CODE, COUNT, LEN) decodes the given received seq (CODE) to message using arithmetic coding.
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
    if(~inpa==3)
    error("comm:arithenco:Wrong number of Input Arguments");
    end
    
    [row_code,col_code]=size(code);
    [row_sta,col_sta]=size(count);
    
    // Check to make sure that sequence is 1D
    if(~(row_code==1|col_code==1))
        error("comm:arithenco: Invalid dimensions: Input Arithmetic Encoded Sequence should be 1D ");
    end
    
    // Check for source statistics matrix 
    if(~(row_sta==1|col_sta==1))
        error("comm:arithenco: Invalid dimensions: Argument 2 should be 1D ");
    end
    
    if(~isreal(code) | or(code<0) )
        error("comm:arithenco: Input sequence should be finite positive integer");
    end
    
    if(~isreal(count) | or(count<0) )
        error("comm:arithenco: Source statistics should be finite positive integer");
    end
    
    if(~isreal(len) | or(len<=0) | ~isscalar(len))
        error("comm:arithenco: length should be finite positive integer and scalar");
    end
    
   //Check the incoming orientation and adjust if necessary
    if (row_code > 1),
        code = code.';
    end
    
    if (row_sta > 1),
        count = count.';
    end
    
    // Check if the given code is binary
    for i=1:length(code)
    if (~(code(i)==1 | code(i)==0 ))
        error("comm:arithenco:Input Arithmetic Encoded Sequence is not binary");
    end
    end
    
    [row_s,col_s]=size(code);
    [row_c,col_c]=size(count);
    
    //Calculate the cumulative count
    cum_count=[0,cumsum(count)];
    total_count=cum_count(length(cum_count));
    
    //Initialization
    m=ceil(log2(total_count)) + 2;
    low=zeros(1,m);
    up=ones(1,m);
    dec_low=0;
    dec_up=2^m-1;
    seq= zeros(1,len);
    seq_index=1;
    k=m;
    tag=code(1:m);
    dec_tag=0;
    value=0;
    for i=1:length(tag)
        dec_tag=dec_tag+tag(i)*2^(length(tag)-i);
    end
    
    //loop till you decode entire seq
    while (seq_index <= len)

        // Compute value
        value =floor( ((dec_tag-dec_low+1)*total_count-1)/(dec_up-dec_low+1) );
        
        //Decode the symbol and update it
        c=find(cum_count <= value)
        ptr=c(length(c))
        
        seq(seq_index)=ptr;
        seq_index=seq_index+1;
        
        //Compute lower and upper bounds
        dec_low_new = dec_low + floor( (dec_up-dec_low+1)*cum_count(ptr)/total_count );
        dec_up = dec_low + floor( (dec_up-dec_low+1)*cum_count(ptr+1)/total_count )-1;
        dec_low = dec_low_new;
        
        for i=1:m
        low(i)=strtod(part(dec2bin(dec_low,m),i))
        end
        for i=1:m
        up(i)=strtod(part(dec2bin(dec_up,m),i))
        end

        //Loop while E1, E2 or E3 condition
        while(isequal(low(1),up(1))) | (isequal(low(2),1) & isequal(up(2),0))
        
        if (k==length(code)) then
            break;
        end
        
        k=k+1;
            if isequal(low(1),up(1)) then //E1 or E2 holds
                
                //Left shift
                low=[low(2:m) 0];
                up=[up(2:m) 1];
                tag=[tag(2:m) code(k)];
                
            elseif (isequal(low(2),1) & isequal(up(2),0)) then //for E3 
                
                //left shift
                low=[low(2:m),0];
                up=[up(2:m),1];
                tag=[tag(2:m) code(k)];
                
                low(1)=bitxor(low(1),1);
                up(1)=bitxor(up(1),1);
                tag(1)=bitxor(tag(1),1);
                
            end
        end
        dec_low=0;dec_up=0;dec_tag=0;
        for i=1:length(low)
        dec_low=dec_low+low(i)*2^(length(low)-i);
        dec_up=dec_up+up(i)*2^(length(up)-i);
        dec_tag=dec_tag+tag(i)*2^(length(tag)-i);
        end
    end
    
endfunction
