% for running outside of the function for troublesohoting
% fname = '/groups/hackathon/data/guest7/dennisdat.bin';
% fid         = fopen(fname, 'r');
% buff = fread(fid, [64 1e5], '*int16');

function buff_c =rmArtifacts(buff)
    %loop that, for each tetrode, takes adjacent samples then abs and plots as
    %one big plot

    for i = 1:length(buff(:,1))
        for j = 1:length(buff(1,1:end-1))
            x(i,j)=abs(buff(i,j)-buff(i,j+1));
        end
        toplot = sum(x,1);
    end

    %after running this on a subset of data it looks like somwhere around 1.7e4

    windowsize=500;
    b=(1/windowsize)*ones(1,windowsize);
    a=1;

    toplot = toplot > 2e4;

    y=filter(b,a,toplot);

    %%
    tp_bad = find(y>0);
    tp_good = find(y==0);

    %%un comment this for normal use
%     buff_c = single(buff);
% 
%     for ich = 1:size(buff,1)
%         buff_c(ich, tp_bad) = interp1(tp_good, buff_c(ich, tp_good), tp_bad);
%     end
    
    %%comment this for normal use
    buff_c = buff(:,tp_good);
    
    
%     %%
%     ich = ich+1;
%     plot(buff_c(ich, :))
%     hold on
%     plot(buff(ich, :))
%     hold off
%     %%
%     nch = size(buff,1);
%     for j = 1:nch
%         plot(single(buff(j,:)) + 1e5*j)
%         hold on
%     end
end