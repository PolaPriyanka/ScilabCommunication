A=[1 0 1; 1 1 0; 1 1 1]
p=3
[x,vld] = gflineq(A,[1;0;1],p)
disp(A,'A=')
disp(x,'x=');
if(vld)
    disp('Linear equation has solution x')
else
    disp('Linear equation has no solution and x is empty')
end

disp( pmodulo(A*x,p),'B =')
