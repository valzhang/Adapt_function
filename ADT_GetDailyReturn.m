function rst = ADT_GetDailyReturn(price,signal,date, code)
% 函数ADT_GetDailyReturn
% 参数列表:
% 1、price:价格序列（cell矩阵格式）
% 2、signal:信号序列
% 3、date:价格序列对应的时间
% 4、code:期货代码
% 调用举例：ADT_GetDailyReturn(price,signal,date, 'AG');
rst(1, 1) = {'date'};
rst(1, 2) = {'transaction_num'};
rst(1, 3) = {'return'};
rst(1, 4) = {'drawdown'};

readPath = 'E:\nffund\strategy\Adapt_function\';

%读取不同期货品种交易手续费
fee_readPath = [readPath 'feetio.xls'];
[AllFeetio AllCode] = xlsread(fee_readPath);
index = strmatch( code, AllCode );
feeRatio = AllFeetio(index(1), 1) / 100;    %将手续费换算成百分制
day_ratio = AllFeetio(index(1), 2);

%读取各个品种交易杠杆
lev_readPath = [readPath 'leverage.xls'];
[AllLeverage AllCode] = xlsread(lev_readPath);
leverage = AllLeverage(strmatch( code, AllCode ));
leverage = leverage(1);

count = 2;
daystr = '2000/01/01';
day_trans_num = 0;
dayreturn = 0;
peak = 0;
cumreturn = 0;
last_date_num = 0;

for i=2:length(signal)
    if strcmpi(cell2mat(date(i)),daystr) == 0
        if strcmpi(daystr,'2000/01/01') == 0 
            rst(count, 1) = {daystr};
            rst(count, 2) = {day_trans_num};
            rst(count, 3) = {dayreturn};
            cumreturn = cumreturn + dayreturn;
            if peak<cumreturn 
                peak = cumreturn;
            end
            rst(count, 4) = {cumreturn-peak};
            %rst(count, 5) = {peak};
            count = count + 1;
        end;

        daystr = cell2mat(date(i));
        day_trans_num = 0;
        dayreturn = signal(i-1)*(price(i)-price(i-1))*100/price(i-1);   %以100为单位计算收益
    else
        dayreturn = dayreturn + signal(i-1)*(price(i)-price(i-1))*100/price(i-1);   %以100为单位计算收益
    end
    if signal(i) ~= signal(i-1) 
        if signal(i-1) ~= 0
            day_trans_num = day_trans_num + 1;
        end
        if day_ratio == 0 || last_date_num ~= fix(datenum(date(i)))  %如果不是减免手续费的期货品种或者是隔天交易
            if signal(i-1) == 0 || signal(i)==0 
                dayreturn = dayreturn - feeRatio/2;
            else
                dayreturn = dayreturn - feeRatio;
            end
        else
            %是当天交易的减免手续费品种，只计算开仓手续费
            if signal(i) ~= 0
                dayreturn = dayreturn - feeRatio/2;
            end
        end
        last_date_num = fix(datenum(date(i)));
    end
end
    rst(count, 1) = {daystr};
    rst(count, 2) = {day_trans_num};
    rst(count, 3) = {dayreturn/leverage};   %加上杠杆
    cumreturn = cumreturn + dayreturn;      
    if peak<cumreturn 
        peak = cumreturn;
    end
    rst(count, 4) = {cumreturn-peak};
    %cell2mat(rst(2:length(rst), 3))
    %price
    %rst(count, 5) = {peak};
end