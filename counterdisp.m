function counterdisp(i)
if i>1; 
    for j=0:log10(i-1); fprintf('\b'); 
    end; 
end;
fprintf('%d', i);
end
