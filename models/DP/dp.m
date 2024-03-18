clear;
clc;
tic
%%
%变量的定义及数据的录入
global N n ;
N=20;%格点数
n=12;%时段数
t=730;%时段的小时数
znl=704;%水库正常蓄水位
zdl=685;%水库死水位
np=double(78);%保证出力，mw
nzh=double(300);%300mw=30万w，最大装机容量
qmax=1000;%水电站最大引用流量
K=8.5;%出力系数
%洪水期6-8月，水位不超过695m
T=load('tq1.txt');T=T(:,1);
q=load('tq1.txt');q=double(q(:,2));%时间和流量
zv=double(load('zv1.txt'));
fz=double(zv(:,1));fv=double(zv(:,2));%水位和库容
zq=load('zq1.txt');
fzx=double(zq(:,1));fqx=double(zq(:,2));%泄流量与下游水位关系
zdlv=interp1(fz,fv,zdl,"linear");%死水位对应死库容
znlv=interp1(fz,fv,znl,'linear');%正常蓄水位对应库容
vjun=(znlv-zdlv)/N;%库容离散最小单位
%%
%计算过程
%第1阶段（4月-3月）
for i=n
    for j=1:N
        yv(i,j)=zdlv;
        yzz(i,j)=685;%月末水位
        yv(i-1,j)=zdlv+(j-1)*vjun;%初始格点对应的库容（下阶段末库容）
        yzz(i-1,j)=interp1(fv,fz,yv(i-1,j),'linear','extrap');%上月末水位
        pv(i,j)=yv(i-1,j)/2.0+zdlv/2.0; %第一阶段的平均库容
        yz(i,j)=interp1(fv,fz,pv(i,j),'linear','extrap');%第一阶段平均上游水位
        if yzz(i,j)>=704%库水位不超过正常蓄水位（假设格点水位过高修正）
            yzz(i,j)=704;
            yv(i,j)=interp1(fz,fv,yzz(i,j),"linear","extrap");
            pv(i,j)=yv(i,j)/2.0+zdlv/2.0;
            yz(i,j)=interp1(fv,fz,pv(i,j),'linear','extrap');
        end
        Q(i,j)=q(i)+(yv(i-1,j)-zdlv)*100000000/(3600*t);%第一阶段可用于发电的流量(库水容量变化+来水)
        pz(i,j)=interp1(fqx,fzx,Q(i,j),"linear","extrap");%下游平均水位
        %水电站最大引用流量1000**，装机容量300mw，判断水位关系
        qs(i,j)=0;
        if Q(i,j)<=1000
            H(i,j)=yz(i,j)-pz(i,j);%平均水头
            NN(i,j)=K*Q(i,j)*H(i,j);%电站出力
        else
            qs(i,j)=Q(i,j)-1000;%弃水
            Q(i,j)=1000;
            H(i,j)=yz(i,j)-pz(i,j);
            NN(i,j)=K*Q(i,j)*H(i,j);
        end
        %装机容量300MW
        if NN(i,j)>=300000
            qs(i,j)=(NN(i,j)-300000)/(K*H(i,j))+qs(i,j);
            NN(i,j)=300000;
        end       
    end 
end
%%
%第2-n阶段
for i=n-1:-1:1 %i阶段
    for j=1:N  %遍历前一阶段产生的N个值
        for k=1:N  %这一阶段产生N个值
            yvn(j,k)=(yv(i,j)+(k-1)*vjun);%+n过程量
            if i==1
                yvn(j,k)=zdlv;
            end
            yzzn(j,k)=interp1(fv,fz,yvn(j,k),'linear','extrap');%库末水位
            pvn(j,k)=yv(i,k)*0.5+yvn(j,k)*0.5;                         
            yzn(j,k)=interp1(fv,fz,pvn(j,k),'linear','extrap');%上游平均水位
            if T(i)<=8&&T(i)>=6%汛期水位限制,水位<695m
                if yzzn(j,k)>695
                    yzzn(j,k)=695;
                    yvn(j,k)=interp1(fz,fv,yzzn(j,k),"linear","extrap");
                    pvn(j,k)=yvn(j,k)/2.0+yv(i,k)/2.0;
                    yzn(j,k)=interp1(fv,fz,pvn(j,k),'linear','extrap');%上游平均水位
                end
            end
            if yzzn(j,k)>=704%库水位不超过正常蓄水位
                yzzn(j,k)=704;
                yvn(j,k)=interp1(fz,fv,yzzn(j,k),"linear","extrap");
                pvn(j,k)=yvn(j,k)/2.0+yv(i,k)/2.0;
                yzn(j,k)=interp1(fv,fz,pvn(j,k),'linear','extrap');%上游平均水位
            end
            Qn(j,k)=q(i)+(yvn(j,k)-yv(i,j))*100000000/(3600*730);
            pzn(j,k)=interp1(fqx,fzx,Qn(j,k),"linear","extrap");%下游平均水位
            %水电站最大引用流量1000**，装机容量300mw，判断水位关系
            qsn(j,k)=0;
            if Qn(j,k)<=1000
                Hn(j,k)=yzn(j,k)-pzn(j,k);%平均水头
                NNn(j,k)=K*Qn(j,k)*Hn(j,k);%电站出力
            end
            if NNn(j,k)>=300000
                Hn(j,k)=yzn(j,k)-interp1(fqx,fzx,Qn(j,k),"linear","extrap");
                qsn(j,k)=Qn(j,k)-300000/(Hn(j,k)*K);
                NNn(j,k)=300000;
            end
            %如果产生弃水，返回计算让弃水变成最小
            if qsn(j,k)>0
                yvn(j,k)=yv(i,j)-(k-1)*vjun;%向下找末库容，调用第一阶段的计算值重算
                yzzn(j,k)=interp1(fv,fz,yvn(j,k),'linear','extrap');%库末水位
                pvn(j,k)=yvn(j,k)/2.0+yv(i,k)/2.0;
                yzn(j,k)=interp1(fv,fz,pvn(j,k),'linear','extrap');%上游平均水位
                if T(i)<=8+1&&T(i)>=6+1%汛期水位限制,水位<695m
                    if yzzn(j,k)>695
                        yzzn(j,k)=695;
                        yvn(j,k)=interp1(fz,fv,yzzn(j,k),"linear","extrap");
                        pvn(j,k)=yvn(j,k)/2.0+yv(i+1,k)/2.0;
                        yzn(j,k)=interp1(fv,fz,pvn(j,k),'linear','extrap');%上游平均水位
                    end
                end
                if yzzn(j,k)<=685
                    yzzn(j,k)=685;
                    yvn(j,k)=interp1(fz,fv,yzzn(j,k),"linear","extrap");
                    pvn(j,k)=yvn(j,k)/2.0+yv(i+1,k)/2.0;
                    yzn(j,k)=interp1(fv,fz,pvn(j,k),'linear','extrap');%上游平均水位
                end
                Qn(j,k)=q(i)+(yvn(j,k)-yv(i,j))*100000000/(3600*24*30.4);
                pzn(j,k)=interp1(fqx,fzx,Qn(j,k),"linear","extrap");%下游平均水位
                %水电站最大引用流量1000**，装机容量300mw，判断水位关系
                if Qn(j,k)<=1000
                    Hn(j,k)=yzn(j,k)-pzn(j,k);%平均水头
                    NNn(j,k)=K*Qn(j,k)*Hn(j,k);%电站出力
                    qsn(j,k)=0;
                else
                    qsn(j,k)=Qn(j,k)-1000;%弃水
                    Qn(j,k)=1000;
                    Hn(j,k)=yzn(j,k)-pzn(j,k);
                    NNn(j,k)=K*Qn(j,k)*Hn(j,k);
                end
                if NNn(j,k)>=300000
                    Hn(j,k)=yzn(j,k)-interp1(fqx,fzx,Qn(j,k),"linear","extrap");
                    qsn(j,k)=Qn(j,k)-300000/(Hn(j,k)*K);
                    NNn(j,k)=300000;
                end
            end
        end
        %局部择优，目标出力最大，同行最大
         [~,ind]=max(NNn(j,:),[],2);
         NN(i,j)=NNn(j,ind);
         Q(i,j)=Qn(j,ind);%发电流量
         qs(i,j)=qsn(j,ind);%弃水
         H(i,j)=Hn(j,ind);%上下水头
         yz(i,j)=yzn(j,ind);%上游平均水位
         if i-1==0
             yzz(12,j)=685;
         else
             yv(i-1,j)=yvn(j,ind);%末库容
             yzz(i-1,j)=yzzn(j,ind);%末库水位
         end
         if qsn(j,k)>0
             for m=ind:N
                 if NNn(j,ind)==NNn(j,m)
                     [~,f]=min(qsn(j,ind:m),[],2);
                     Q(i,j)=Qn(j,f);%发电流量
                     qs(i,j)=qsn(j,f);%弃水
                     if i-1==0
                         yzz(12,j)=685;
                     else
                         yzz(i-1,j)=yzzn(j,f);%末库水位
                     end
                 end
             end
         end
    end
end
%%
%全局择优
A=sum(NN,1);
[maxnum ind]=max(A,[],2);
zN=NN(:,ind);
zyzz=yzz(:,ind);
zQ=Q(:,ind);
zqs=qs(:,ind);
zH=H(:,ind);
zyz=yz(:,ind);
SN=sum(zN);
%%
%写库
xlswrite( '动态规划.xlsx', T,'sheet1','A2');
xlswrite( '动态规划.xlsx', q,'sheet1','B2');
xlswrite( '动态规划.xlsx', zyzz,'sheet1','C2');
xlswrite( '动态规划.xlsx', zQ,'sheet1','D2');
xlswrite( '动态规划.xlsx', zqs,'sheet1','E2');
xlswrite( '动态规划.xlsx', zN,'sheet1','F2');
xlswrite( '动态规划.xlsx', zH,'sheet1','G2');
xlswrite( '动态规划.xlsx', zyz,'sheet1','H2');
xlswrite( '动态规划.xlsx', SN,'sheet1','I2');
toc;
ctime=toc;
xlswrite( '动态规划.xlsx', ctime,'sheet1','J2');


