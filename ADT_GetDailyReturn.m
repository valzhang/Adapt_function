function rst = ADT_GetDailyReturn(price,signal,date, code)
% ����ADT_GetDailyReturn
% �����б�:
% 1��price:�۸����У�cell�����ʽ��
% 2��signal:�ź�����
% 3��date:�۸����ж�Ӧ��ʱ��
% 4��code:�ڻ�����
% ���þ�����ADT_GetDailyReturn(price,signal,date, 'AG');
rst(1, 1) = {'date'};
rst(1, 2) = {'transaction_num'};
rst(1, 3) = {'return'};
rst(1, 4) = {'drawdown'};

readPath = 'E:\nffund\strategy\Adapt_function\';

%��ȡ��ͬ�ڻ�Ʒ�ֽ���������
fee_readPath = [readPath 'feetio.xls'];
[AllFeetio AllCode] = xlsread(fee_readPath);
index = strmatch( code, AllCode );
feeRatio = AllFeetio(index(1), 1) / 100;    %�������ѻ���ɰٷ���
day_ratio = AllFeetio(index(1), 2);

%��ȡ����Ʒ�ֽ��׸ܸ�
lev_readPath = [readPath 'leverage.xls'];
[AllLeverage AllCode] = xlsread(lev_readPath);
leverage = AllLeverage(strmatch( code, AllCode ));
leverage = leverage(1);

count = 2;
daystr = '2000/01/01';
day_trans_num = 0;
dayreturn = 0;
peak = 0;
cumreturn = 0;
last_date_num = 0;

for i=2:length(signal)
    if strcmpi(cell2mat(date(i)),daystr) == 0
        if strcmpi(daystr,'2000/01/01') == 0 
            rst(count, 1) = {daystr};
            rst(count, 2) = {day_trans_num};
            rst(count, 3) = {dayreturn};
            cumreturn = cumreturn + dayreturn;
            if peak<cumreturn 
                peak = cumreturn;
            end
            rst(count, 4) = {cumreturn-peak};
            %rst(count, 5) = {peak};
            count = count + 1;
        end;

        daystr = cell2mat(date(i));
        day_trans_num = 0;
        dayreturn = signal(i-1)*(price(i)-price(i-1))*100/price(i-1);   %��100Ϊ��λ��������
    else
        dayreturn = dayreturn + signal(i-1)*(price(i)-price(i-1))*100/price(i-1);   %��100Ϊ��λ��������
    end
    if signal(i) ~= signal(i-1) 
        if signal(i-1) ~= 0
            day_trans_num = day_trans_num + 1;
        end
        if day_ratio == 0 || last_date_num ~= fix(datenum(date(i)))  %������Ǽ��������ѵ��ڻ�Ʒ�ֻ����Ǹ��콻��
            if signal(i-1) == 0 || signal(i)==0 
                dayreturn = dayreturn - feeRatio/2;
            else
                dayreturn = dayreturn - feeRatio;
            end
        else
            %�ǵ��콻�׵ļ���������Ʒ�֣�ֻ���㿪��������
            if signal(i) ~= 0
                dayreturn = dayreturn - feeRatio/2;
            end
        end
        last_date_num = fix(datenum(date(i)));
    end
end
    rst(count, 1) = {daystr};
    rst(count, 2) = {day_trans_num};
    rst(count, 3) = {dayreturn/leverage};   %���ϸܸ�
    cumreturn = cumreturn + dayreturn;      
    if peak<cumreturn 
        peak = cumreturn;
    end
    rst(count, 4) = {cumreturn-peak};
    %cell2mat(rst(2:length(rst), 3))
    %price
    %rst(count, 5) = {peak};
end