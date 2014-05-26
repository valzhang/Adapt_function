function rst = ADT_GetMonthlyReturn(price,signal,date, code)
% ����ADT_GetMonthlyReturn
% �����б�:
% 1��price:�۸����У�cell�����ʽ��
% 2��signal:�ź�����
% 3��date:�۸����ж�Ӧ��ʱ��
% 4��code:�ڻ�����
% ���þ�����ADT_GetMonthlyReturn(price,signal,date, 'AG');
rst(1, 1) = {'month'};
rst(1, 2) = {'transaction_num'};
rst(1, 3) = {'return'};

readPath = 'E:\nffund\strategy\Adapt_function\';

%��ȡ��ͬ�ڻ�����������

fee_readPath = [readPath 'feetio.xls'];
[AllFeetio AllCode] = xlsread(fee_readPath);
index = strmatch( code, AllCode );
feeRatio = AllFeetio(index(1), 1) / 100;    %�������ѻ���ɰٷ���

%��ȡ����Ʒ�ֽ��׸ܸ�
lev_readPath = [readPath 'leverage.xls'];
[AllLeverage AllCode] = xlsread(lev_readPath);
leverage = AllLeverage(strmatch( code, AllCode ));
leverage = leverage(1);


count = 2;
monthstr = '2000/01';
month_trans_num = 0;
monthreturn = 0;

for i=2:length(signal)
    signalmonth = cell2mat(date(i));
    if length(signalmonth) <= 0
        continue;
    end
    signalmonth = signalmonth(1:7);
    if strcmpi(signalmonth,monthstr) == 0
        if strcmpi(monthstr,'2000/01') == 0 
            rst(count, 1) = {monthstr};
            rst(count, 2) = {month_trans_num};
            if isnan(monthreturn) == 1
                monthreturn = 0;
            end
            rst(count, 3) = {monthreturn};
            count = count + 1;
        end;

        monthstr = cell2mat(date(i));
        monthstr = monthstr(1:7);
        month_trans_num = 0;
        monthreturn = signal(i-1)*(price(i)-price(i-1))*100/price(i-1); %��100Ϊ��λ��������
        
    else
        monthreturn = monthreturn + signal(i-1)*(price(i)-price(i-1))*100/price(i-1);   %��100Ϊ��λ��������
    end
    if signal(i) ~= signal(i-1) 
        if signal(i-1) ~= 0
            month_trans_num = month_trans_num + 1;
        end
        if signal(i-1) == 0 || signal(i)==0 
            monthreturn = monthreturn - feeRatio/2;
        else
            monthreturn = monthreturn - feeRatio;
        end
    end
end
    rst(count, 1) = {monthstr};
    rst(count, 2) = {month_trans_num};
    if isnan(monthreturn) == 1
        monthreturn = 0;
    end
    rst(count, 3) = {monthreturn/leverage}; 
    
end