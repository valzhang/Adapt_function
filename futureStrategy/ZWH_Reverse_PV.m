function [outStat, dailydetail, monthdetail, allsignal, signalSeries]=ZWH_Reverse_PV(code, cycle, strBegT, strEndT)
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
int_date = data.int_Date;
vol = data.Volume;

%参数
backshort = 4;
backlong = 16;
pRatio = 1.8;
vRatio = 1.5;
priceChange = 10;
holdBarNum = 5;
pStopLoss = 6;

t_bar = 0;
t_price = 0;
t_signal = 0;

todayBarNum = 0;
beginBarNum = 20;
endBarNum = 250;

dateIndex = 0;
for i=1:length(cp)
    
    if int_date(i) ~= dateIndex 
        dateIndex = int_date(i);
        todayBarNum = 1;
        t_price = 0;
        t_signal = 0;
    else
        todayBarNum = todayBarNum + 1;
    end
    
    if todayBarNum<beginBarNum || todayBarNum>endBarNum 
        signal(i)=0;
    else
        signal(i) = signal(i-1);
        
         %判断是否要平仓
        if t_signal==-1 && cp(i)-t_price>pStopLoss 
            signal(i)=0;
            t_bar = 0;
            t_signal = 0;
            t_price = 0;
        end
        
        if t_signal==1 && cp(i)-t_price<-1*pStopLoss 
            signal(i)=0;
            t_bar = 0;
            t_signal = 0;
            t_price = 0;
        end
         
        if i - t_bar >= holdBarNum
            if t_signal==-1 && ( min(cp(i-holdBarNum+1:i)) >= cp(i-holdBarNum) || cp(i) - min(cp(i-holdBarNum+1:i))>=priceChange/2)
                signal(i)=0;
                t_bar = 0;
                t_signal = 0;
                t_price = 0;
            end
                
            if t_signal==1 && ( max(cp(i-holdBarNum+1:i)) <= cp(i-holdBarNum) || cp(i) - max(cp(i-holdBarNum+1:i))<=priceChange/2*(-1))
                 signal(i)=0;
                 t_bar = 0;
                 t_signal = 0;
                 t_price = 0;
            end
        end
        
   
        
        
        condition1 = ( cp(i) - cp(i-backshort) )*( cp(i) - cp(i-backlong) ) > 0 ;
        condition2 = (abs( cp(i-1) - cp(i-backshort) )/( backshort - 1) - abs( cp(i-1) - cp( i - backlong))/(backlong - 1) > pRatio);
        condition3 = (mean( vol(i-backshort+1:i))/mean( vol(i-backlong+1:i)) > vRatio);
        
        if ( condition1 && condition2 && condition3)
            %做多
            if cp(i)>cp(i-1) && cp(i-1) - cp(i-backshort) < priceChange * -1 
                signal(i) = 1;
                t_bar = i;
                t_signal = 1;
                t_price = cp(i);
            end
            %做空
            if cp(i)<cp(i-1) && cp(i-1) - cp(i-backshort) > priceChange
                signal(i) = -1;
                t_bar = i;
                t_signal = -1;
                t_price = cp(i);
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
% signalSeries(:,1)=data.int_Date;
% signalSeries(:,2)=data.Open;
% signalSeries(:,3)=data.High;
% signalSeries(:,4)=data.Low;
% signalSeries(:,5)=data.Close;
% signalSeries(:,6)=signal;
end