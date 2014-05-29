function [outStat, dailydetail, monthdetail, allsignal, signalSeries]=ZWH_MultiMA(code, cycle, strBegT, strEndT)
%快速反转，考察价格和交易量的变化

%读取数据
try
    %data = COM_GetData(code, cycle, strBegT, strEndT);
    data = ADT_GetData(code, cycle, strBegT, strEndT);
catch ME
    throw(ME);
end

%编写策略, 分析时间序列
cp = data.Close;
int_time = data.int_Time;
int_date = data.int_Date;


%参数
pctStopLoss = 0.01;
ma_Len1 = 5;
ma_Len2 = 30;
ma_Len3 = 60;
ma_Len4 = 120;
ma_Len5 = 200;
stop_price = 0;
todayBarNum = 0;
today_Tran_Num = 0;
signal = 0;
dateIndex = 0;
for i=1:length(cp)
    if int_date(i) ~= dateIndex 
        today_Tran_Num = 0;
        dateIndex = int_date(i);
        todayBarNum = 1;
    else
        todayBarNum = todayBarNum + 1;
    end

    if i>1
        signal(i) = signal(i-1);
    else
        signal(i) = 0;
    end
    
    if i>ma_Len5
        ma1 = mean(cp(i-ma_Len1+1:i));
        ma2 = mean(cp(i-ma_Len2+1:i));
        ma3 = mean(cp(i-ma_Len3+1:i));
        ma4 = mean(cp(i-ma_Len4+1:i));
        ma5 = mean(cp(i-ma_Len5+1:i));
        
        bsignal(i) = ma1>ma2 && ma3<ma4 && ma4<ma5;
        ssignal(i) = ma1<ma2 && ma3>ma4 && ma4>ma5;
        
        if bsignal(i) && bsignal(i-1) && bsignal(i-2) 
            if ~(signal(i)==1)
                signal(i)=0;
                if today_Tran_Num<2
                    signal(i) = 1;
                    today_Tran_Num = today_Tran_Num + 1;
                    stop_price = cp(i)*(1-pctStopLoss);
                end
            end
        end
        
        if ssignal(i) && ssignal(i-1) && ssignal(i-2) 
            
            if ~(signal(i)==-1) 
                signal(i) = 0;
                if today_Tran_Num<2 
                    signal(i) = -1;
                    today_Tran_Num = today_Tran_Num + 1;
                    stop_price = cp(i)*(1+pctStopLoss);
                end;
            end;
        end
    else
        bsignal(i) = false;
        ssignal(i) = false;
    end
    
    if signal(i)==1 && cp(i)<stop_price - 0.2
        signal(i) = 0;
        if ma3<ma4 && ma4<ma5 
            if today_Tran_Num<2 
                signal(i) = -1;
                today_Tran_Num = today_Tran_Num + 1;
                stop_price = cp(i)*(1+pctStopLoss);
            end
        end
    end
    
    if signal(i)==-1 && cp(i)>stop_price + 0.2
        signal(i) = 0;
        if ma3>ma4 && ma4>ma5 
            if today_Tran_Num<2 
                signal(i) = 1;
                today_Tran_Num = today_Tran_Num + 1;
                stop_price = cp(i)*(1-pctStopLoss);
            end
        end
    end
end
if length(data.int_Date) > 0 && sum(abs(signal)) > 0
    %相关统计，统一格式，不用做修改
    %data1 = COM_BuySellSignal(data.Close, signal, data.str_Date, data.str_Time);
    data1 = ADT_BuySellSignal(data.Close, signal, data.str_Date, data.str_Time);
    %dailydetail = COM_GetDailyReturn(data.Close, signal, data.str_Date, 0.8);
    dailydetail = ADT_GetDailyReturn(data.Close, signal, data.str_Date, code);
    %monthdetail = COM_GetMonthlyReturn(data.Close, signal, data.str_Date, 0.8);
    monthdetail = ADT_GetMonthlyReturn(data.Close, signal, data.str_Date, code);
    %outStat = COM_EvalIFPerf(data1,0.8);
    outStat = ADT_EvalIFPerf(data1,code);
    allsignal = data1;
    signalSeries = struct('data', {data}, 'signal', {signal});
else
    outStat(5,2) = {-1};
    dailydetail = -1;
    monthdetail = -1;
    allsignal = -1;
    signalSeries = struct('data', {data}, 'signal', {signal});
    
end
