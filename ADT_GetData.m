% ����ADT_GetData����"\\192.168.100.109\IF_KLine_New\"�ļ����¶�ȡָ�����ڻ�����
% �����б���
% 1��code:��Լ���룬���д
% 2��cycle:k�����ڣ�ȡֵ��Χ��-1,1,2,5,15,30��������-1��ʾ����
% 3��begT:��ʼʱ��
% 4��endT:����ʱ��
% 
% ���þ�����data = ADT_GetData('AG',1,'2000-01-11 09:45:00','2015-12-30 09:45:00');

function data = ADT_GetData(code, cycle, begT, endT)

%ָ����ȡ�ļ�·��
path = 'E:\testData\main\';

ME = MException('GetData:InvalidInput','Invalid input!');
%ָ����Լ
%
%switch code
%    case 'IF00'
%        path = [path 'main'];
%    case 'IF01'
%        path = [path 'thisMonth'];
%    case 'IF02'
%        path = [path 'nextMonth'];
%    case 'IF03'
%        path = [path 'thisQuarter'];
%    case 'IF04'
%       path = [path 'nextQuarter'];
%    otherwise
%        throw(ME);
%end
path = [path code];

%ָ��k������
switch cycle
    case -1
        path = [path '_day.txt'];
    case 1
        path = [path '_1.txt'];
    case 2
        path = [path '_2.txt'];
    case 5
        path = [path '_5.txt'];
    case 15
        path = [path '_15.txt'];
    case 30
        path = [path '_30.txt'];
    otherwise
        throw(ME);
end

try
    t1 = datevec(begT);
    t2 = datevec(endT);
catch ME1
    throw(ME1);
end

%��ȡ�ļ�����ֵ����ʱ����
[Contract,str_Date,str_Time,int_Date,int_Time,Close,Open,High,Low,Volume,Amount,Buy,Buy_Vol,Sell,Sell_Vol,OI] = textread(path,'%s %s %s %d %d %f %f %f %f %f %f %f %d %f %d %d');

n_Date1 = t1(1)*10000 + t1(2)*100 + t1(3);
n_Time1 = t1(4)*10000 + t1(5)*100 + t1(6);
n_Date2 = t2(1)*10000 + t2(2)*100 + t2(3);
n_Time2 = t2(4)*10000 + t2(5)*100 + t2(6);
a = length(Contract) + 1;
b = 0;

%��ȡָ��ʱ��begT-endT��Χ�ڵ�����
for i=1:length(Contract)
    if (int_Date(i)>n_Date1)||((int_Date(i)==n_Date1)&&(int_Time(i)>=n_Time1))
        a = min(a,i);
    end
    if (int_Date(i)<n_Date2)||((int_Date(i)==n_Date2)&&(int_Time(i)<=n_Time2))
        b = max(b,i);
    end
end

%�洢��data�ṹ���ڷ���
data = struct('Contract',{Contract(a:b)},'str_Date',{str_Date(a:b)},'str_Time',{str_Time(a:b)},'int_Date',{int_Date(a:b)},'int_Time',{int_Time(a:b)},'Close',{Close(a:b)},'Open',{Open(a:b)},'High',{High(a:b)},'Low',{Low(a:b)},'Volume',{Volume(a:b)},'Amount',{Amount(a:b)},'Buy',{Buy(a:b)},'Buy_Vol',{Buy_Vol(a:b)},'Sell',{Sell(a:b)},'Sell_Vol',{Sell_Vol(a:b)},'OI',{OI(a:b)});

end