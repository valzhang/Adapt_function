% ����ADT_EvalIFPerf
% �����б�:
% 1��data:�������ݣ�cell�����ʽ��
% 2��code:�ڻ�Ʒ�֣��ַ�����ʽ��
% ���þ�����ADT_EvalIFPerf(data,��AG��);
% 
% data���������У���һ��Ϊ���ּ۸񣬵ڶ���Ϊ�������򣬵�����Ϊƽ�ּ۸񣬵�����Ϊ����ʱ�䣬������Ϊƽ��ʱ��

function [outstat] = ADT_EvalIFPerf(data, code)

%�Ȱ��տ���ʱ������;
%data = sortrows(data,4);

readPath = 'E:\nffund\strategy\Adapt_function\';

out = {'begT';'endT';'return';'anu_return';'t_num';
       'earn_ratio';'avg_earn';'avg_lose';'drawdown';'drawdown_begT';
       'drawdown_endT';'maxrtnlose';'maxrtnwin';'long_num';'long_win_num';
       'long_win_ratio';'long_win';'short_num';'short_win_num';'short_win_ratio';
       'short_win';'avg_hold_time';'win_hold_time';'lose_hold_time';'max_win_num';
       'max_lose_num';'sharp_ratio'};
%��ȡ����Ʒ�ֽ���������

fee_readPath = [readPath 'feetio.xls'];
[AllFeetio AllCode] = xlsread(fee_readPath);

index = strmatch( code, AllCode );
feeratio = AllFeetio(index(1), 1) / 100;    %�������ѻ���ɰٷ���
day_ratio = AllFeetio(index(1), 2);

%��ȡ����Ʒ�ֽ��׸ܸ�
lev_readPath = [readPath 'leverage.xls'];
[AllLeverage AllCode] = xlsread(lev_readPath);
leverage = AllLeverage(strmatch( code, AllCode ));
leverage = leverage(1);

%��ȡ����Ʒ�ֽ���ʱ��
if strcmpi(code, 'IF') == 1
    morning_trans_time = 2.25;
    afternoon_trans_time = 2.25;
    noon_gap_time = 1.5;
else
    morning_trans_time = 2.25;
    afternoon_trans_time = 1.5;
    noon_gap_time = 2;
end

%��������������rtn
act = cell2mat(data(:,2));
rtn = (cell2mat(data(:,3)) - cell2mat(data(:,1))).*act;   %ÿһ��λӯ��
rtn = rtn ./(cell2mat(data(:,1)));      %ÿһ��Ǯ��Լ�۸�ӯ��
rtn = rtn * 100;      %ÿһ�ٺ�Լ�۸�ӯ��
%rtn = rtn ./ leverage(1);   %���Ǹܸ˵�������
t_num = length(rtn);

%��������������fee_group
if day_ratio == 1
    begT = datenum(data(:,4));
    endT = datenum(data(:,5));
    day_disc = (fix(endT)-fix(begT)==0);
    fee_group = feeratio - feeratio * day_disc / 2;
else
    fee_group = feeratio * ones(t_num,1);
end

%�������س�����ʼ�س�ʱ�䣬
if t_num>1 
    [drawdown drawdown_begT drawdown_endT] = MDD(cumsum(rtn - fee_group));
else
    if rtn(1)>0
        drawdown = 0;
        drawdown_begT = 1;
        drawdown_endT = 1; 
    else
        drawdown = -1 * rtn(1);
        drawdown_begT = 1;
        drawdown_endT = 1; 
    end
end

longrtn = rtn(act==1);
shortrtn = rtn(act==-1);

%����ֲ�ʱ��
[holdtime day_posi day_long_posi]= hold_time(data, morning_trans_time, afternoon_trans_time, noon_gap_time);

%������������
fee = sum(fee_group);
long_fee = feeratio*length(longrtn);
short_fee = feeratio*length(shortrtn);
if (day_ratio == 1)
    long_fee = long_fee - feeratio * day_long_posi / 2;
    short_fee = short_fee - feeratio * (day_posi - day_long_posi) / 2;
end

%������д���
out(1,2) = data(1,4);
out(2,2) = data(end,4);
out(3,2) = {(sum(rtn) - fee)/leverage};
out(4,2) = {365*((sum(rtn) - fee)/leverage)/(datenum(data(end,4)) - datenum(data(1,4)))};
out(5,2) = {t_num};
out(6,2) = {length(find(rtn>=0))/length(rtn)};
out(7,2) = {mean(rtn(rtn>=0)/leverage)};
out(8,2) = {mean(rtn(rtn<0)/leverage)};
out(9,2) = {drawdown/leverage};
out(10,2) = data(drawdown_begT,4);
out(11,2) = data(drawdown_endT,4);
out(12,2) = {min(rtn)/leverage};
out(13,2) = {max(rtn)/leverage};
out(14,2) = {length(longrtn)};
out(15,2) = {length(find(longrtn>0))};
out(16,2) = {length(find(longrtn>0))/length(longrtn)};
out(17,2) = {(sum(longrtn) - long_fee)/leverage};
out(18,2) = {length(shortrtn)};
out(19,2) = {length(find(shortrtn>0))};
out(20,2) = {length(find(shortrtn>0))/length(shortrtn)};
out(21,2) = {(sum(shortrtn) - short_fee)/leverage};
out(22,2) = {mean(holdtime)};
out(23,2) = {mean(holdtime(rtn>0))};
out(24,2) = {mean(holdtime(rtn<0))};
out(25,2) = {getnum(rtn>0)};
out(26,2) = {getnum(rtn<0)};
out(27,2) = {cell2mat(out(4,2))/(std(rtn)*sqrt(250))};

%�����¶���ϸ
%mdetail = get_mdetail(data,feeratio);

%�����excel�ļ�
%xlswrite(outreadPath,out,sheetname);
%xlswrite(outreadPath,mdetail,[sheetname '_mdetail']);
outstat = out;
%month = mdetail;
end

function [rst begT endT] = MDD(NAV)

rst = 0;
peak = -99999;
for i = 1:length(NAV)
  if (NAV(i) > peak) 
    peak = NAV(i);
    temp = i + 1;
  else
    %DD(i) = 100.0 * (peak - NAV(i)) / peak;
    DD(i) = peak - NAV(i);
    if (DD(i) > rst)
      rst = DD(i);
      begT = temp;
      endT = i;
    end
  end
end

end

function rst = getnum(x)
rst = 0;
b = 0;
for i=1:length(x)
    if x(i)==0
        b = 0;
    else
        b = x(i) + b;
    end
    if rst<b
        rst = b;
    end
end

end

function [rst day_posi day_long_posi] = hold_time(data, morning_trans_time, afternoon_trans_time, noon_gap_time)

day_posi = 0;
day_long_posi = 0;
for i=1:length(data(:,1))
    temp = datenum(data(i,5)) - datenum(data(i,4));
    rst(i) = floor(temp)*4.5;
    begT = datevec(data(i,4));
    endT = datevec(data(i,5));
    if ((temp - floor(temp)) > 0.5)&&(begT(4)<12)
        %�ֲָ�ҹ�����ҿ�ƽ��ʱ�䶼������
        rst(i) = rst(i) + (temp - floor(temp))*24 - (24 - morning_trans_time - afternoon_trans_time);
    elseif ((temp - floor(temp)) > 0.5)&&(begT(4)>12)&&(endT(4)>12)
        %�ֲָ�ҹ�����ҿ�ƽ��ʱ�䶼������
        rst(i) = rst(i) + (temp - floor(temp))*24 - (24 - morning_trans_time - afternoon_trans_time);
    elseif ((temp - floor(temp)) > 0.5)&&(begT(4)>12)&&(endT(4)<12)
        %�ֲָ�ҹ���������翪�֣�����ƽ��
        rst(i) = rst(i) + (temp - floor(temp))*24 - (24 - morning_trans_time - afternoon_trans_time - noon_gap_time);
    elseif (begT(4)<12)&&(endT(4)>12)
        %���Ͽ�������ƽ��
        rst(i) = rst(i) + (temp - floor(temp))*24 - noon_gap_time;
        day_posi = day_posi + 1;
        if (cell2mat(data(i,2)) > 0)
            day_long_posi = day_long_posi + 1;
        end
    else
        %ͬΪ���翪ƽ�ֻ������翪ƽ��
        rst(i) = rst(i) + (temp - floor(temp))*24;
        day_posi = day_posi + 1;
        if (cell2mat(data(i,2)) > 0)
            day_long_posi = day_long_posi + 1;
        end
    end
end
end

function rst = get_mdetail(data,feeratio)
rst(1,1) = {'begDate'};
rst(1,2) = {'endDate'};
rst(1,3) = {'transaction_num'};
rst(1,4) = {'return'};

act = cell2mat(data(:,2));
rtn = (cell2mat(data(:,3)) - cell2mat(data(:,1))).*act;

if length(data(:,1))==0
    return;
elseif length(data(:,1))==1
    rst(2,1) = data(1,4);
    rst(2,2) = data(1,4);
    rst(2,3) = {1};
    rst(2,4) = {rtn(1) - feeratio}; 
    return;
end

prev = datevec(data(1,4));
begDate = data(1,4);
count = 2;
t_num = 1;
r = rtn(1);

for i=2:length(data(:,1))
    cur = datevec(data(i,4));
    if (cur(1) == prev(1))&&(cur(2) == prev(2))
        t_num = t_num + 1;
        r = r + rtn(i);
    else
        rst(count,1) = begDate;
        rst(count,2) = data(i-1,4);
        rst(count,3) = {t_num};
        rst(count,4) = {r - t_num*feeratio};
        begDate = data(i,4);
        count = count + 1;
        t_num = 1;
        r = rtn(i);
    end
    prev = cur;
end

rst(count,1) = begDate;
rst(count,2) = data(end,4);
rst(count,3) = {t_num};
rst(count,4) = {r - t_num*feeratio};

end