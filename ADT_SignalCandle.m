function ADT_SignalCandle(signals, begT, endT)
% �������ź���ͼ����ʾ����������Ϊ��ɫ������Ϊ��ɫ��
% 1��signals��Ϊ���Է��صĵ�5���������Ҫ����������
%               GetData�õ������ݺͷ������ݺ�õ���Signal����        
% 2��begT: ��ʼʱ��
% 3��endT������ʱ��
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
    a = length(signals.data.High);
    b = 1;

    %��ȡָ��ʱ��begT-endT��Χ�ڵ�����
    for i=1:length(signals.data.High)
        if (signals.data.int_Date(i)>n_Date1)||((signals.data.int_Date(i)==n_Date1)&&(signals.data.int_Time(i)>=n_Time1))
            a = min(a,i);
        end
        if (signals.data.int_Date(i)<n_Date2)||((signals.data.int_Date(i)==n_Date2)&&(signals.data.int_Time(i)<=n_Time2))
            b = max(b,i);
        end
    end
    
    high=signals.data.High(a:b);
    low = signals.data.Low(a:b);
    close = signals.data.Close(a:b);
    open = signals.data.Open(a:b);
    dates = signals.data.str_Date(a:b);
    signal = signals.signal(a:b);
    
    COM_FtCandle(high, low, close, open, signal, dates);
end