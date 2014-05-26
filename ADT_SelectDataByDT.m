% 函数ADT_SelectDataByDT，从data数据集中截取指定时间段的数据
% 参数列表：
% 1、data:data数据集，格式见COM_GetData
% 2、begT:开始时间
% 3、endT:结束时间
% 
% 调用举例：data1 = ADT_SelectDataByDT(data,'2000-01-11 09:45:00','2015-12-30
% 09:45:00');

function rst = ADT_SelectDataByDT(data, begT, endT)

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
a = length(data.Close) + 1;
b = 0;

%截取指定时间begT-endT范围内的数据
for i=1:length(data.Close)
    if (data.int_Date(i)>n_Date1)||((data.int_Date(i)==n_Date1)&&(data.int_Time(i)>=n_Time1))
        a = min(a,i);
    end
    if (data.int_Date(i)<n_Date2)||((data.int_Date(i)==n_Date2)&&(data.int_Time(i)<=n_Time2))
        b = max(b,i);
    end
end

%存储至data结构体内返回
rst = struct('Contract',{data.Contract(a:b)},'str_Date',{data.str_Date(a:b)},'str_Time',{data.str_Time(a:b)},'int_Date',{data.int_Date(a:b)},'int_Time',{data.int_Time(a:b)},'Close',{data.Close(a:b)},'Open',{data.Open(a:b)},'High',{data.High(a:b)},'Low',{data.Low(a:b)},'Volume',{data.Volume(a:b)},'Amount',{data.Amount(a:b)},'Buy',{data.Buy(a:b)},'Buy_Vol',{data.Buy_Vol(a:b)},'Sell',{data.Sell(a:b)},'Sell_Vol',{data.Sell_Vol(a:b)},'OI',{data.OI(a:b)});

end