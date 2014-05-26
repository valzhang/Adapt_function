function ADT_SignalCandle(signals, begT, endT)
% 将交易信号在图上显示出来，买入为红色，卖出为绿色。
% 1、signals：为策略返回的第5个结果，主要包括两部分
%               GetData得到的数据和分析数据后得到的Signal序列        
% 2、begT: 开始时间
% 3、endT：结束时间
    try
        t1 = datevec(begT);
        t2 = datevec(endT);
    catch ME1
        throw(ME1);
    end
    
    n_Date1 = t1(1)*10000 + t1(2)*100 + t1(3);
    n_Time1 = t1(4)*10000 + t1(5)*100 + t1(6);
    n_Date2 = t2(1)*10000 + t2(2)*100 + t2(3);
    n_Time2 = t2(4)*10000 + t2(5)*100 + t2(6);
    a = length(signals.data.High);
    b = 1;

    %截取指定时间begT-endT范围内的数据
    for i=1:length(signals.data.High)
        if (signals.data.int_Date(i)>n_Date1)||((signals.data.int_Date(i)==n_Date1)&&(signals.data.int_Time(i)>=n_Time1))
            a = min(a,i);
        end
        if (signals.data.int_Date(i)<n_Date2)||((signals.data.int_Date(i)==n_Date2)&&(signals.data.int_Time(i)<=n_Time2))
            b = max(b,i);
        end
    end
    
    high=signals.data.High(a:b);
    low = signals.data.Low(a:b);
    close = signals.data.Close(a:b);
    open = signals.data.Open(a:b);
    dates = signals.data.str_Date(a:b);
    signal = signals.signal(a:b);
    
    COM_FtCandle(high, low, close, open, signal, dates);
end