function [outStat, dailydetail, monthdetail, allsignal, signalSeries]=XY_OpenGap_New(code, cycle, strBegT, strEndT)
%���̼۸����ղ��ԣ����۸�����ǰ�յͼۻ����ǰ�ո߼ۣ������۸�ת����
%���ֺ�̶�����ֹ�𣬸���ֹӮ��



code = 'A';
cycle = 1;
strBegT = '2010-04-14';
strEndT = '2010-05-14';

%��ȡ����
try
    data = ADT_GetData(code, cycle, strBegT, strEndT);
    daydata = ADT_GetData(code, -1, strBegT, strEndT);
catch ME
    throw(ME);
end

%% ���Բ���
PctStopLoss = 0.4;
PctTrailing = 2;
PctBreakEven = 1;
CloseTime = 145500;


%��д����, ����ʱ������
cp = data.Close;
hp = data.High;
lp = data.Low;
op = data.Open;
ContrID = data.Contract;
int_date = data.int_Date;
int_time = data.int_Time;
dayDate = daydata.str_Date;


vFlag = false;
todayOp = 0;
t_price=0;
t_act=0;
int_DayDate = 0;
dayIndex = 0; 
dayBegIndex = 0 ;
dayEndIndex = 0;
signal(1) = 0;

for i=1:length(cp)
    if int_date(i) ~= int_DayDate
        dayIndex = dayIndex + 1;
        int_DayDate = int_date(i);
        
        if dayIndex-1 >= 1
            dayBegIndex = dayIndex - 1;
            dayEndIndex = dayIndex - 1;
            preDayData = ADT_GetDataByCode(ContrID{i}(1:(length(ContrID{i})-4)), -1, dayDate{dayBegIndex}, [dayDate{dayEndIndex} ' 15:00:00']);
            predayhp = preDayData.High;
            predaylp = preDayData.Low;
        end   
        todayOp = op(i);
        vFlag = false;
    end
    
    if int_time(i) > CloseTime  
        signal(i)=0;
    elseif i>1 
            signal(i) = signal(i-1);
    end

    %ֹ��
    if t_act == 1 && cp(i) < t_stoploss
        signal(i)=0;
        t_act = 0;
    end
    if t_act == -1 && cp(i) > t_stoploss
        signal(i)=0;
        t_act = 0;
    end

    %����ֹ��۸���ӯ��ƽ��
 
    if t_act ==1 && cp(i) >= t_breakeven
        t_stoploss = t_price;
    end

    if t_act ==-1 && cp(i) <= t_breakeven
        t_stoploss = t_price;
    end

    %�ƶ�ֹӯ
    if t_act ==1
        MarkHigh = max(hp(i), MarkHigh);
        if MarkHigh - lp(i) > MarkHigh*PctTrailing/100
            signal(i) = 0;
            t_act = 0;
        end
    end
    if t_act == -1
        MarkLow = min(lp(i), MarkLow);
        if hp(i) - MarkLow > MarkLow*PctTrailing/100
            signal(i) = 0;
            t_act = 0;
        end
    end
  
    % �����ź�    
    if ~vFlag && dayIndex - 1 >=1   
        if todayOp < predaylp && hp(i) > predaylp
            signal(i) = 1;
            t_price = cp(i);
            t_stoploss = t_price * (1-PctStopLoss/100);
            t_breakeven = t_price *(1+PctBreakEven/100);
            t_act = 1;
            MarkHigh = cp(i);
            vFlag = true;
        end

        if  todayOp > predayhp && lp(i) < predayhp
            signal(i) = -1;
            t_price = cp(i);
            t_stoploss = t_price * (1+PctStopLoss/100);
            t_breakeven = t_price *(1-PctBreakEven/100);
            t_act = -1;
            MarkLow = cp(i);
            vFlag = true;
        end
    end 
end

%���ͳ�ƣ�ͳһ��ʽ���������޸�

data1 = ADT_BuySellSignal(data.Close, signal, data.str_Date, data.str_Time);
%data1 = ADT_BuySellSignal(data.Close, signal, strDate, strTime);
dailydetail = ADT_GetDailyReturn(data.Close, signal, data.str_Date, code);
%dailydetail = ADT_GetDailyReturn(data.Close, signal, strDate, 0.8);
monthdetail = ADT_GetMonthlyReturn(data.Close, signal, data.str_Date, code);
%monthdetail = ADT_GetMonthlyReturn(data.Close, signal, strDate, 0.8);
outStat = ADT_EvalIFPerf(data1, code);
allsignal = data1;
signalSeries = struct('data', {data}, 'signal', {signal});
end