% ����ADT_BuySellSignal����k�߽����źŴ����ÿ�ʽ�������
% �����б�
% 1��price:  ��ǰk�ߵĽ��׼۸�
% 2��signal: �ź����飬-1��ʾ���գ�1��ʾ���࣬0��ʾ��ƽ
% 3��date: ��ǰk�ߵ�����
% 4��time����ǰk�ߵ�ʱ��
%
% ���þ�����rst = ADT_BuySellSignal(price, signal, date, time);

function rst = ADT_BuySellSignal(price,signal,date,time)

count = 1;
rst = cell(1,5);

if signal(1)==1
    rst(count,1)={price(1)};
    rst(count,2)={1};
    rst(count,4)={[char(date(1)) ' ' char(time(1))]};
elseif signal(1)==-1
    rst(count,1)={price(1)};
    rst(count,2)={-1};
    rst(count,4)={[char(date(1)) ' ' char(time(1))]};
end

for i=2:length(signal)
    if signal(i-1)==0
        if signal(i)==1
            rst(count,1)={price(i)};
            rst(count,2)={1};
            rst(count,4)={[char(date(i)) ' ' char(time(i))]};
        elseif signal(i)==-1
            rst(count,1)={price(i)};
            rst(count,2)={-1};
            rst(count,4)={[char(date(i)) ' ' char(time(i))]};
        end
    elseif signal(i-1)==1
        if signal(i)==0
            rst(count,3)={price(i)};
            rst(count,5)={[char(date(i)) ' ' char(time(i))]};
            count = count + 1;
        elseif signal(i)==-1
            rst(count,3)={price(i)};
            rst(count,5)={[char(date(i)) ' ' char(time(i))]};
            count = count + 1;
            rst(count,1)={price(i)};
            rst(count,2)={-1};
            rst(count,4)={[char(date(i)) ' ' char(time(i))]};
        end
    elseif signal(i-1)==-1
        if signal(i)==1
            rst(count,3)={price(i)};
            rst(count,5)={[char(date(i)) ' ' char(time(i))]};
            count = count + 1;
            rst(count,1)={price(i)};
            rst(count,2)={1};
            rst(count,4)={[char(date(i)) ' ' char(time(i))]};
        elseif signal(i)==0
            rst(count,3)={price(i)};
            rst(count,5)={[char(date(i)) ' ' char(time(i))]};
            count = count + 1;
        end
    end
end

if signal(end)~=0
    %rst = rst(1:end-1,:);
    rst(end, 3) = {price(end)};
    rst(end, 5) = {[char(date(end)) ' ' char(time(end))]};
end

end