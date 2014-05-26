% 函数ADT_BuySellSignal，将k线交易信号处理成每笔交易数据
% 参数列表：
% 1、price:  当前k线的交易价格
% 2、signal: 信号数组，-1表示看空，1表示看多，0表示看平
% 3、date: 当前k线的日期
% 4、time：当前k线的时间
%
% 调用举例：rst = ADT_BuySellSignal(price, signal, date, time);

function rst = ADT_BuySellSignal(price,signal,date,time)

count = 1;
rst = cell(1,5);

if signal(1)==1
    rst(count,1)={price(1)};
    rst(count,2)={1};
    rst(count,4)={[char(date(1)) ' ' char(time(1))]};
elseif signal(1)==-1
    rst(count,1)={price(1)};
    rst(count,2)={-1};
    rst(count,4)={[char(date(1)) ' ' char(time(1))]};
end

for i=2:length(signal)
    if signal(i-1)==0
        if signal(i)==1
            rst(count,1)={price(i)};
            rst(count,2)={1};
            rst(count,4)={[char(date(i)) ' ' char(time(i))]};
        elseif signal(i)==-1
            rst(count,1)={price(i)};
            rst(count,2)={-1};
            rst(count,4)={[char(date(i)) ' ' char(time(i))]};
        end
    elseif signal(i-1)==1
        if signal(i)==0
            rst(count,3)={price(i)};
            rst(count,5)={[char(date(i)) ' ' char(time(i))]};
            count = count + 1;
        elseif signal(i)==-1
            rst(count,3)={price(i)};
            rst(count,5)={[char(date(i)) ' ' char(time(i))]};
            count = count + 1;
            rst(count,1)={price(i)};
            rst(count,2)={-1};
            rst(count,4)={[char(date(i)) ' ' char(time(i))]};
        end
    elseif signal(i-1)==-1
        if signal(i)==1
            rst(count,3)={price(i)};
            rst(count,5)={[char(date(i)) ' ' char(time(i))]};
            count = count + 1;
            rst(count,1)={price(i)};
            rst(count,2)={1};
            rst(count,4)={[char(date(i)) ' ' char(time(i))]};
        elseif signal(i)==0
            rst(count,3)={price(i)};
            rst(count,5)={[char(date(i)) ' ' char(time(i))]};
            count = count + 1;
        end
    end
end

if signal(end)~=0
    %rst = rst(1:end-1,:);
    rst(end, 3) = {price(end)};
    rst(end, 5) = {[char(date(end)) ' ' char(time(end))]};
end

end