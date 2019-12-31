function [pontos, nomes] = xInfo (existentes, IML)
%%
inc = max(IML)/length(IML);
aux1 = [inc:inc:max(IML)];
nomes = num2cell(aux1);
%%
if size(existentes, 1) > 1
    existentes = existentes' ;
end

pontos = [];%horizontal
row = 0;
for i = unique(IML)
    row = row + 1;
    count = sum(existentes == i);
    %     if count > 0
    for j = 1 : count
        pontos = [pontos, aux1(row)];
    end
    %         row = row + 1;
    %     else
    %         row = row + 1;
    %     end
end
