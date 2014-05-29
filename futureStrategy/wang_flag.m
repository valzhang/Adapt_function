function out=wang_flag(OPEN,CLOSE,HIGH,LOW,VOL)

% OPEN=CLOSE;
% OPEN(2:end)=CLOSE(1:end-1);
C=CLOSE;

%1名称：平滑异同移动平均线指标，公开型技术指标
N1=3;N2=5;N3=9;N4=13;
DIFF=EMA(CLOSE,N3)-EMA(CLOSE,N4);
DEA=EMA(DIFF,N2);
ROFAC=(DIFF>DEA);

%2名称：金叉选股指标，VAR2代表做多资金强度，VAR3代表该长期趋势，如果短期做多资金进场，那么看多
VAR2=(100 - ((90 * (HHV(HIGH,14) - CLOSE)) ./ (HHV(HIGH,14) - LLV(LOW,14))));%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
VAR3=(100 - ma(((100 * (HHV(HIGH,6) - CLOSE)) ./ (HHV(HIGH,6) - LLV(LOW,6)))',34));
ROFCPS=(VAR2>=ma(VAR3,6)');
%仿考夫曼线，和考夫曼线具体计算公式不同，但结构一样，网上有下面一样的源代码，公开型技术指标
% DIR1=ABS(CLOSE-ref(CLOSE,5));
% VIR1=ma(ABS(CLOSE-ref(CLOSE,1))',5)*5;
% ER1=DIR1./VIR1';
% CS1=ER1*(0.8-2/8)+2/8;
% CQ1=CS1.*CS1;
% DIR2=ABS(CLOSE-ref(CLOSE,10));
% VIR2=ma(ABS(CLOSE-ref(CLOSE,1))',10)*10;
% ER2=DIR2./VIR2';
% CS2=ER2*(0.8-2/24)+2/24;
% CQ2=CS2.*CS2;


%3 名称：三重指数平滑均线 公开型技术指标
NOFTRIX=12;MOFTRIX=9;
XOFTRIX=EMA(EMA(EMA(CLOSE,NOFTRIX),NOFTRIX),NOFTRIX);
TRIX=(XOFTRIX-REF(XOFTRIX,1))./REF(XOFTRIX,1)*100;
MATRIX=ma(TRIX',MOFTRIX) ;
ROFTRIX=(TRIX>=MATRIX');

%4 名称：顺势指标
NOFCCI=12;
TYP=(HIGH+LOW+CLOSE)/3;
CCI=(TYP-ma(TYP,NOFCCI))./(0.015*AVEDEV(TYP,NOFCCI));
ROFCCI=(CCI>=100);
%5 名称：阿隆指标，有2个子指标，阿隆up和阿隆down。通过计算子价格达到近期最高值和最低值以来所经过的期间数，帮助预测从趋势到震荡，和从震荡到反转的变化
L=LOW;
AROONDOWN=100* (14-((IF(REF(L,1)==LLV(L,14),1,IF(REF(L,2)==LLV(L,14),2,IF(REF(L,3)==... 
LLV(L,14),3,IF(REF(L,4)==LLV(L,14),4,IF(REF(L,5)==LLV(L,14),5,IF(REF(L,6)== ...
LLV(L,14),6,IF(REF(L,7)==LLV(L,14),7,IF(REF(L,8)==LLV(L,14),8,IF(REF(L,9)== ...
LLV(L,14),9,IF(REF(L,10)==LLV(L,14),10,IF(REF(L,11)==LLV(L,14),11,IF(REF(L,12)== ...
LLV(L,14),12,IF(REF(L,13)==LLV(L,14),13,IF(REF(L,14)==LLV(L,14),14,0)))))))))))))))))/14; 
H=HIGH;
AROONUP= ...
100* (14-((IF(REF(H,1)==HHV(H,14),1,IF(REF(H,2)==HHV(H,14),2,IF(REF(H,3)== ...
HHV(H,14),3, IF (REF(H,4 )==HHV(H,14),4 ,IF(REF(H ,5)==HHV(H,14),5 ,IF(REF (H ,6 ) == ...
HHV(H,14),6 ,IF (REF(H,7 )==HHV(H,14),7 ,IF(REF(H ,8)==HHV(H,14),8 ,IF(REF (H ,9 )== ...
HHV(H,14),9 ,IF (REF(H,10)==HHV(H,14),10,IF(REF(H,11)==HHV(H,14),11,IF(REF (H ,12 ) == HHV(H,14),12,IF (REF(H,13)==HHV(H,14),13,IF(REF(H,14)==HHV(H,14),14,0)))))))))))))))))/14;  
ROFAROON=IF(AROONUP>=AROONDOWN,1,0);
%6 名称：振动升降指标 ASI
LC=REF(CLOSE,1);
AA=ABS(HIGH-LC);
BB=ABS(LOW-LC);
CC=ABS(HIGH-REF(LOW,1));
DD=ABS(LC-REF(OPEN,1));
R=IF(AND(AA>BB,AA>CC),AA+BB/2+DD/4,IF(AND(BB>CC,BB>AA),BB+AA/2+DD/4,CC+DD/4));
XOFASI=(CLOSE-LC+(CLOSE-OPEN)/2+LC-REF(OPEN,1));
SI=8*XOFASI./max(R,1).*max(AA,BB);
ASI=cumsum(SI);%sum(si,0): 表示累加的和，表示从开始开始计算的和
MASI=MA(ASI,6);
ROFASI=IF(ASI>=MASI,1,0);

%7 名称:价量趋势指标
NOFPVT=5;
PVTVAL1=(C-REF(C,1))./REF(C,1).*VOL;%今日收盘价 减掉 昨日收盘价 除以昨日收盘价 乘以 当日成交量
PVT=backsum(PVTVAL1,NOFPVT);
ROFPVT=IF(PVT>=MA(PVT,12),1,0);

%8 名称 资金流量控盘力度指标
PJJ=DMA((HIGH+LOW+CLOSE*2)/4,0.9);
JJ=REF(EMA(PJJ,3),1);
QJJ=VOL./((HIGH-LOW)*2-ABS(CLOSE-OPEN));
XVL=IF(CLOSE>OPEN,QJJ.*(HIGH-LOW),IF(CLOSE<OPEN,QJJ.*(HIGH-OPEN+CLOSE-LOW),VOL/2))+IF(CLOSE>OPEN,0-QJJ.*(HIGH-CLOSE+OPEN-LOW),IF(CLOSE<OPEN,0-QJJ.*(HIGH-LOW),0-VOL/2));
HSL=(XVL/20)/1.15;
X1OFZJL=((HSL*0.55+(REF(HSL,1)*0.33))+(REF(HSL,2)*0.22));
GJJ=EMA(X1OFZJL,8);
LLJX=EMA(X1OFZJL,3);
ROFZJL=IF(LLJX>=0,1,0);

%9 名称：4均线
BBI=(ma(CLOSE,N1)+ma(CLOSE,N2)+ma(CLOSE,N3)+ma(CLOSE,N4))/4;
ROFBBI=IF(CLOSE>BBI,1,0);

%10 名称：台湾力道K线指标
EMA13=EMA(C,13);%COLORWHITE; 
X1=(C+L+H)/3; 
X2=EMA(X1,6); 
X3=EMA(X2,5); 
ROFBKCP=IF(AND(X2>X3,C>EMA13),1,0);

PHT=ROFAC+ROFCPS+ROFTRIX+ROFAROON+ROFASI+ROFZJL+ROFPVT+ROFCCI+ROFBKCP+ROFBBI;

GG=IF(AND(AND(AND(PHT==0,REF(PHT,1)==0),C>REF(C,1)),REF(C,1)>REF(C,2)),11,...
    IF(AND(AND(PHT>=8,PHT>REF(PHT,1)),MA(C,20)>MA(C,60)),11,...
     IF(AND(AND(PHT==10,PHT>REF(PHT,1)),MA(C,20)<MA(C,60)),11,...
    IF(AND(AND(PHT==10,REF(PHT,1)==10),AND(REF(PHT,2)==10,C./REF(C,3)<1.01)),-1,...
    IF(cross(MA(C,60),MA(C,20)),-1,...
    IF(AND(AND(PHT==1,PHT<REF(PHT,1)),C>MA(C,60)),-1,...
    IF(AND(AND(PHT<=2,PHT<REF(PHT,1)),AND(C<MA(C,60),C>MA(C,20))),-1,...
    IF(AND(AND(PHT<=3,PHT<REF(PHT,1)),C<MA(C,20)),-1,0))))))));
out=GG;

% O=OPEN;
% GG= IF(AND(AND(PHT>=7,PHT>REF(PHT,1)),(MA(C,20)>REF(MA(C,20),5))),11,...
%     IF(AND(AND(PHT==10,REF(PHT,1)==10),AND(REF(PHT,2)==10,C/REF(O,2)<1.005)),-1,...
%     IF(AND(AND(PHT==10,PHT>=REF(PHT,1)),AND(C>REF(C,1),MA(C,20)>REF(MA(C,20),1))),11,...
%     IF(AND(PHT-REF(PHT,1)>=6 ,PHT<10),11,...
%     IF(PHT-REF(PHT,1)<=-6,-1,...
%     IF(AND(AND(AND(PHT==10,REF(PHT,1)==10),AND(REF(PHT,2)==10,C<O)),MA(C,60)<REF(MA(C,60),1)),-1,...
%     IF(AND(PHT>=9,C/REF(C,1)<0.985),-1,...
%     IF(MA(C,60)>MA(C,20),-1,...
%     IF(AND(AND(PHT==1,PHT<REF(PHT,1)),C>MA(C,60)),-1,...
%     IF(AND(AND(PHT<=2,PHT<REF(PHT,1)),AND(C<MA(C,60),C>MA(C,20))),-1,...
%     IF(AND(AND(PHT<=3,PHT<REF(PHT,1)),C<MA(C,20)),-1,...
%     IF(AND(AND(O>C,REF(O,1)>REF(C,1)),AND(REF(O,2)>REF(C,2),C<REF(C,2))),-1,...
%     0))))))))))));
% out=GG;


flag=0;
for k=1:length(GG)
    if GG(k)==11
        flag=1;
    elseif GG(k)==-1
        flag=-1;
    end
    out(k)=flag;
end

    