% 函数ADT_GetDataByCode，从"\\192.168.100.109\IF_KLine_New\"文件夹下读取指定的期货数据
% 参数列表：
% 1、code:合约代码，如'IF1306'等
% 2、cycle:k线周期，取值范围（-1,1,2,5,15,30），其中-1表示日线
% 3、begT:开始时间
% 4、endT:结束时间
% 
% 调用举例：data = ADT_GetDataByCode('AG',1,'2000-01-11 09:45:00','2015-12-30');
% 09:45:00');

function data = ADT_GetDataByCode(code, cycle, begT, endT)

readPath = 'E:\KData\main\';

ME = MException('GetData:InvalidInput','Invalid input!');

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
        
%指定k线周期
        if cycle > 0 
            readPath = [readPath code '_' int2str(cycle) '.txt'];
        elseif cycle == -1
            readPath = [readPath code '_day.txt' ];
        else 
            throw(ME1);
        end
            
        %读取文件并赋值给临时变量
        
       [Contract,str_Date,str_Time,int_Date,int_Time,Close,Open,High,Low,Volume,Amount,Buy,Buy_Vol,Sell,Sell_Vol,OI] = textread(readPath,'%s %s %s %d %d %f %f %f %f %f %f %f %d %f %d %n');


        a = length(Contract) + 1;
        b = 0;

        %截取指定时间begT-endT范围内的数据
        for i=1:length(Contract)
            if (int_Date(i)>n_Date1)||((int_Date(i)==n_Date1)&&(int_Time(i)>=n_Time1))
                a = min(a,i);
            end
            if (int_Date(i)<n_Date2)||((int_Date(i)==n_Date2)&&(int_Time(i)<=n_Time2))
                b = max(b,i);
            end
        end

        %存储至data结构体内返回
        data = struct('Contract',{Contract(a:b)},'str_Date',{str_Date(a:b)},'str_Time',{str_Time(a:b)},'int_Date',{int_Date(a:b)},'int_Time',{int_Time(a:b)},'Close',{Close(a:b)},'Open',{Open(a:b)},'High',{High(a:b)},'Low',{Low(a:b)},'Volume',{Volume(a:b)},'Amount',{Amount(a:b)},'Buy',{Buy(a:b)},'Buy_Vol',{Buy_Vol(a:b)},'Sell',{Sell(a:b)},'Sell_Vol',{Sell_Vol(a:b)},'OI',{OI(a:b)});

end