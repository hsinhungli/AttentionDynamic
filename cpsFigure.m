function h = cpsFigure(width,height,num,name)
%cpsFigure(widthscale, heightscale)
if exist('num','var') && ~isempty(num);
    h = figure(num);
else
    h = figure;
end
if exist('name','var')
    set(gcf,'Name',name);
end

%set(h,'DefaultAxesLooseInset',[0,0,0,0]);
Position = get(h,'Position');
Position(3) = width*Position(3);
Position(4) = height*Position(4);
set(h,'Position', Position,'color','w',...
    'PaperUnits','inches','PaperPosition',[0 0 width height]*4);
%set(h,'DefaultTextFontSize',20)
%h=fig('units','inches','width',7,'height',2,'font','Helvetica','fontsize',16)
%set(h,'DefaultAxesLooseInset',[0,0,0,0]);
