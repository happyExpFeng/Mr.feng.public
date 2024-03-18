clear;
clc;
tic
%%
%�����Ķ��弰���ݵ�¼��
global N n ;
N=20;%�����
n=12;%ʱ����
t=730;%ʱ�ε�Сʱ��
znl=704;%ˮ��������ˮλ
zdl=685;%ˮ����ˮλ
np=double(78);%��֤������mw
nzh=double(300);%300mw=30��w�����װ������
qmax=1000;%ˮ��վ�����������
K=8.5;%����ϵ��
%��ˮ��6-8�£�ˮλ������695m
T=load('tq1.txt');T=T(:,1);
q=load('tq1.txt');q=double(q(:,2));%ʱ�������
zv=double(load('zv1.txt'));
fz=double(zv(:,1));fv=double(zv(:,2));%ˮλ�Ϳ���
zq=load('zq1.txt');
fzx=double(zq(:,1));fqx=double(zq(:,2));%й����������ˮλ��ϵ
zdlv=interp1(fz,fv,zdl,"linear");%��ˮλ��Ӧ������
znlv=interp1(fz,fv,znl,'linear');%������ˮλ��Ӧ����
vjun=(znlv-zdlv)/N;%������ɢ��С��λ
%%
%�������
%��1�׶Σ�4��-3�£�
for i=n
    for j=1:N
        yv(i,j)=zdlv;
        yzz(i,j)=685;%��ĩˮλ
        yv(i-1,j)=zdlv+(j-1)*vjun;%��ʼ����Ӧ�Ŀ��ݣ��½׶�ĩ���ݣ�
        yzz(i-1,j)=interp1(fv,fz,yv(i-1,j),'linear','extrap');%����ĩˮλ
        pv(i,j)=yv(i-1,j)/2.0+zdlv/2.0; %��һ�׶ε�ƽ������
        yz(i,j)=interp1(fv,fz,pv(i,j),'linear','extrap');%��һ�׶�ƽ������ˮλ
        if yzz(i,j)>=704%��ˮλ������������ˮλ��������ˮλ����������
            yzz(i,j)=704;
            yv(i,j)=interp1(fz,fv,yzz(i,j),"linear","extrap");
            pv(i,j)=yv(i,j)/2.0+zdlv/2.0;
            yz(i,j)=interp1(fv,fz,pv(i,j),'linear','extrap');
        end
        Q(i,j)=q(i)+(yv(i-1,j)-zdlv)*100000000/(3600*t);%��һ�׶ο����ڷ��������(��ˮ�����仯+��ˮ)
        pz(i,j)=interp1(fqx,fzx,Q(i,j),"linear","extrap");%����ƽ��ˮλ
        %ˮ��վ�����������1000**��װ������300mw���ж�ˮλ��ϵ
        qs(i,j)=0;
        if Q(i,j)<=1000
            H(i,j)=yz(i,j)-pz(i,j);%ƽ��ˮͷ
            NN(i,j)=K*Q(i,j)*H(i,j);%��վ����
        else
            qs(i,j)=Q(i,j)-1000;%��ˮ
            Q(i,j)=1000;
            H(i,j)=yz(i,j)-pz(i,j);
            NN(i,j)=K*Q(i,j)*H(i,j);
        end
        %װ������300MW
        if NN(i,j)>=300000
            qs(i,j)=(NN(i,j)-300000)/(K*H(i,j))+qs(i,j);
            NN(i,j)=300000;
        end       
    end 
end
%%
%��2-n�׶�
for i=n-1:-1:1 %i�׶�
    for j=1:N  %����ǰһ�׶β�����N��ֵ
        for k=1:N  %��һ�׶β���N��ֵ
            yvn(j,k)=(yv(i,j)+(k-1)*vjun);%+n������
            if i==1
                yvn(j,k)=zdlv;
            end
            yzzn(j,k)=interp1(fv,fz,yvn(j,k),'linear','extrap');%��ĩˮλ
            pvn(j,k)=yv(i,k)*0.5+yvn(j,k)*0.5;                         
            yzn(j,k)=interp1(fv,fz,pvn(j,k),'linear','extrap');%����ƽ��ˮλ
            if T(i)<=8&&T(i)>=6%Ѵ��ˮλ����,ˮλ<695m
                if yzzn(j,k)>695
                    yzzn(j,k)=695;
                    yvn(j,k)=interp1(fz,fv,yzzn(j,k),"linear","extrap");
                    pvn(j,k)=yvn(j,k)/2.0+yv(i,k)/2.0;
                    yzn(j,k)=interp1(fv,fz,pvn(j,k),'linear','extrap');%����ƽ��ˮλ
                end
            end
            if yzzn(j,k)>=704%��ˮλ������������ˮλ
                yzzn(j,k)=704;
                yvn(j,k)=interp1(fz,fv,yzzn(j,k),"linear","extrap");
                pvn(j,k)=yvn(j,k)/2.0+yv(i,k)/2.0;
                yzn(j,k)=interp1(fv,fz,pvn(j,k),'linear','extrap');%����ƽ��ˮλ
            end
            Qn(j,k)=q(i)+(yvn(j,k)-yv(i,j))*100000000/(3600*730);
            pzn(j,k)=interp1(fqx,fzx,Qn(j,k),"linear","extrap");%����ƽ��ˮλ
            %ˮ��վ�����������1000**��װ������300mw���ж�ˮλ��ϵ
            qsn(j,k)=0;
            if Qn(j,k)<=1000
                Hn(j,k)=yzn(j,k)-pzn(j,k);%ƽ��ˮͷ
                NNn(j,k)=K*Qn(j,k)*Hn(j,k);%��վ����
            end
            if NNn(j,k)>=300000
                Hn(j,k)=yzn(j,k)-interp1(fqx,fzx,Qn(j,k),"linear","extrap");
                qsn(j,k)=Qn(j,k)-300000/(Hn(j,k)*K);
                NNn(j,k)=300000;
            end
            %���������ˮ�����ؼ�������ˮ�����С
            if qsn(j,k)>0
                yvn(j,k)=yv(i,j)-(k-1)*vjun;%������ĩ���ݣ����õ�һ�׶εļ���ֵ����
                yzzn(j,k)=interp1(fv,fz,yvn(j,k),'linear','extrap');%��ĩˮλ
                pvn(j,k)=yvn(j,k)/2.0+yv(i,k)/2.0;
                yzn(j,k)=interp1(fv,fz,pvn(j,k),'linear','extrap');%����ƽ��ˮλ
                if T(i)<=8+1&&T(i)>=6+1%Ѵ��ˮλ����,ˮλ<695m
                    if yzzn(j,k)>695
                        yzzn(j,k)=695;
                        yvn(j,k)=interp1(fz,fv,yzzn(j,k),"linear","extrap");
                        pvn(j,k)=yvn(j,k)/2.0+yv(i+1,k)/2.0;
                        yzn(j,k)=interp1(fv,fz,pvn(j,k),'linear','extrap');%����ƽ��ˮλ
                    end
                end
                if yzzn(j,k)<=685
                    yzzn(j,k)=685;
                    yvn(j,k)=interp1(fz,fv,yzzn(j,k),"linear","extrap");
                    pvn(j,k)=yvn(j,k)/2.0+yv(i+1,k)/2.0;
                    yzn(j,k)=interp1(fv,fz,pvn(j,k),'linear','extrap');%����ƽ��ˮλ
                end
                Qn(j,k)=q(i)+(yvn(j,k)-yv(i,j))*100000000/(3600*24*30.4);
                pzn(j,k)=interp1(fqx,fzx,Qn(j,k),"linear","extrap");%����ƽ��ˮλ
                %ˮ��վ�����������1000**��װ������300mw���ж�ˮλ��ϵ
                if Qn(j,k)<=1000
                    Hn(j,k)=yzn(j,k)-pzn(j,k);%ƽ��ˮͷ
                    NNn(j,k)=K*Qn(j,k)*Hn(j,k);%��վ����
                    qsn(j,k)=0;
                else
                    qsn(j,k)=Qn(j,k)-1000;%��ˮ
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
        %�ֲ����ţ�Ŀ��������ͬ�����
         [~,ind]=max(NNn(j,:),[],2);
         NN(i,j)=NNn(j,ind);
         Q(i,j)=Qn(j,ind);%��������
         qs(i,j)=qsn(j,ind);%��ˮ
         H(i,j)=Hn(j,ind);%����ˮͷ
         yz(i,j)=yzn(j,ind);%����ƽ��ˮλ
         if i-1==0
             yzz(12,j)=685;
         else
             yv(i-1,j)=yvn(j,ind);%ĩ����
             yzz(i-1,j)=yzzn(j,ind);%ĩ��ˮλ
         end
         if qsn(j,k)>0
             for m=ind:N
                 if NNn(j,ind)==NNn(j,m)
                     [~,f]=min(qsn(j,ind:m),[],2);
                     Q(i,j)=Qn(j,f);%��������
                     qs(i,j)=qsn(j,f);%��ˮ
                     if i-1==0
                         yzz(12,j)=685;
                     else
                         yzz(i-1,j)=yzzn(j,f);%ĩ��ˮλ
                     end
                 end
             end
         end
    end
end
%%
%ȫ������
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
%д��
xlswrite( '��̬�滮.xlsx', T,'sheet1','A2');
xlswrite( '��̬�滮.xlsx', q,'sheet1','B2');
xlswrite( '��̬�滮.xlsx', zyzz,'sheet1','C2');
xlswrite( '��̬�滮.xlsx', zQ,'sheet1','D2');
xlswrite( '��̬�滮.xlsx', zqs,'sheet1','E2');
xlswrite( '��̬�滮.xlsx', zN,'sheet1','F2');
xlswrite( '��̬�滮.xlsx', zH,'sheet1','G2');
xlswrite( '��̬�滮.xlsx', zyz,'sheet1','H2');
xlswrite( '��̬�滮.xlsx', SN,'sheet1','I2');
toc;
ctime=toc;
xlswrite( '��̬�滮.xlsx', ctime,'sheet1','J2');


