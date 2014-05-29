function [outStat, dailydetail, monthdetail, allsignal, signalSeries]=wang_timing(code, cycle, strBegT, strEndT)

%code='IF00';
%cycle=1;
%strBegT='2011-1-4 9:15:00';
%strEndT=datestr(now,31);

%data
try
    %data = COM_GetData(code, cycle, strBegT, strEndT);
    data = ADT_GetData(code, cycle, strBegT, strEndT);
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
temp0 = ts_act.RemoteCallFunc('geths300index2',{});
[rown coln]=size(temp0);
temp1=[];
if rown > 1
    temp1=[double(cell2mat(temp0(2:length(temp0),1))),...
        double(cell2mat(temp0(2:length(temp0),2))),...
        double(cell2mat(temp0(2:length(temp0),3))),...
        double(cell2mat(temp0(2:length(temp0),4))),...
        double(cell2mat(temp0(2:length(temp0),5)))
           ];
end
cp_day=temp1(:,1);
high_day=temp1(:,2);
low_day=temp1(:,3);
op_day=temp1(:,4);
vol_day=temp1(:,5);

day_filter=wang_flag(op_day,cp_day,high_day,low_day,vol_day);
day_filter=day_filter(1215:end);



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

monthdetail = COM_GetMonthlyReturn(data.Close, signal, data.str_Date, 0.8);
outStat = COM_EvalIFPerf(data1,0.8);
allsignal = data1;
signalSeries = struct('data', {data}, 'signal', {signal});
%xlswrite('dailydetail2.xls',monthdetail);