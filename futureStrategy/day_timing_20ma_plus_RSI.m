function [outStat, dailydetail, monthdetail, allsignal, signalSeries]=day_timing_20ma_plus_RSI(ifcode, cycle, strBegT, strEndT)

ifcode='IF00';
cycle=1;
strBegT='2011-1-4 9:15:00';
strEndT=datestr(now,31);

%data
try
    data = COM_GetData(ifcode, cycle, strBegT, strEndT);
catch ME
    throw(ME);
end
cp = data.Close;
high=data.High;
low=data.Low;
int_date = unique(data.int_Date);
%flag
ts_act=actxserver('TSExpert.CoExec');
set(0,'FormatSpacing','compact');
temp0 = ts_act.RemoteCallFunc('geths300index',{});
[rown coln]=size(temp0);
temp1=[];
if rown > 1
    temp1=[double(cell2mat(temp0(2:length(temp0))))
           ];
end
cp_day=temp1;

ma_cp_day=ma(temp1,20);
rsi_cp_day=RSI(temp1',35);
day_filter=zeros(length(temp1),1);
for k=2:length(temp1)
    if cp_day(k)>ma_cp_day(k)+0.00001
        day_filter(k)=1;
    elseif cp_day(k)<ma_cp_day(k)-0.00001
        day_filter(k)=-1;
    else
        day_filter(k)=day_filter(k-1);
    end
    if rsi_cp_day(k)>70 && day_filter(k)==1
        day_filter(k)=0;
    elseif rsi_cp_day(k)<30 && day_filter(k)==-1
        day_filter(k)=0;
    end
end
    
    
day_filter=day_filter(1215:end);
rsi2=rsi_cp_day(1215:end);
cri_day=0.005;
signal=[];
flag_stop=zeros(length(int_date),1);
for k=1:length(int_date)
        cp2=cp((k-1)*270+1:k*270);
        flag=zeros(270,1);
        flag(1)=day_filter(k);
        for i=2:270
            up_stop=cp2(i)/cp2(1);
            down_loss=cp2(i)/cp2(1);
                if day_filter(k)==1
                    if  up_stop<=1-cri_day
                        flag(i)=0;
                        flag_stop(k)=1;
                        break;
                    else
                        flag(i)=day_filter(k);
                    end
                end
                if day_filter(k)==-1
                    if down_loss>=1+cri_day
                        flag(i)=0;
                        flag_stop(k)=1;
                        break;
                    else
                        flag(i)=-1;
                    end
                end
        end
        signal=[signal;flag];
end
%flag_stop 也需要输出

%相关统计，统一da格式，不用做修改
data1 = COM_BuySellSignal(data.Close, signal, data.str_Date, data.str_Time);
dailydetail = COM_GetDailyReturn(data.Close, signal, data.str_Date, 0.8);
%全部输出
dailydetail{1,5}='是否止损';
for i=2:length(dailydetail)
    dailydetail{i,5}=num2str(flag_stop(i-1));
end

dailydetail{1,6}='当天信号';
for i=2:length(dailydetail)
    dailydetail{i,6}=num2str(day_filter(i-1));
end

dailydetail{1,7}='明天信号';
for i=2:length(dailydetail)
    dailydetail{i,7}=num2str(day_filter(i));
end

dailydetail{1,8}='35天RSI值（以30 70作为阀值）';
for i=2:length(dailydetail)
    dailydetail{i,8}=num2str(rsi2(i));
end

monthdetail = COM_GetMonthlyReturn(data.Close, signal, data.str_Date, 0.8);
outStat = COM_EvalIFPerf(data1,0.8);
allsignal = data1;
signalSeries = struct('data', {data}, 'signal', {signal});
%xlswrite('dailydetail2.xls',monthdetail);