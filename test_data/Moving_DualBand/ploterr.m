addpath('../')
warning off
T_vn = readtable('VND.csv');
T_spp = readtable('SPP.csv');
T_sba = readtable('SBAS.csv');
T_grd = readtable('GRD.csv');

% Pick start time and end time to reconcile the epoch period
st = datetime([2021 7 1 22 15 33.000]);
ed = datetime([2021 7 1 23 19 27.000]);
L = seconds(ed-st)+1;
t_x = minutes(0):seconds(1):ed - st;

t_grd = T_grd.UTC;
t_grd = datetime(t_grd,'InputFormat','HH:mm:ss.SSS MM/dd/yyyy');

t_vn = T_vn.UTC;
t_vn = datetime(t_vn,'InputFormat','HH:mm:ss.SSS MM/dd/yyyy');

st_ = find(t_vn == st);
ed_ = find(t_vn == ed);
t_vn = t_vn(st_:ed_);
vnx = T_vn.X(st_:ed_);
vny = T_vn.Y(st_:ed_);
vnz = T_vn.Z(st_:ed_);
hor_vn = NaN(L,1);
ecef_vn = NaN(L,1);
ned_err_vn = NaN(3,L);
for i=1:L
    ind = find(abs(t_grd - t_vn(i)) < seconds(0.1));
    if ~isempty(ind)
        grd = [T_grd.X(ind);T_grd.Y(ind);T_grd.Z(ind)];
        llh_grd = [T_grd.Lat(ind);
            T_grd.Lon(ind);
            T_grd.Alt_HAE_(ind)];  %Degree
        lla = ecef2lla([vnx(i),vny(i),vnz(i)]);
        [hor_vn(i),ecef_vn(i),ned_err_vn(:,i)]=compt_err(lla(1),lla(2),lla(3),grd,llh_grd);
    end
end

t_spp = T_spp.UTC;
t_spp = datetime(t_spp,'InputFormat','HH:mm:ss.SSS MM/dd/yyyy');

st_ = find(t_spp == st);
ed_ = find(t_spp == ed);
t_spp = t_spp(st_:ed_);
sppx = T_spp.X(st_:ed_);
sppy = T_spp.Y(st_:ed_);
sppz = T_spp.Z(st_:ed_);
hor_spp = NaN(L,1);
ecef_spp = NaN(L,1);
ned_err_spp = NaN(3,L);
for i=1:L
    ind = find(abs(t_grd - t_spp(i)) < seconds(0.1));
    if ~isempty(ind)
        grd = [T_grd.X(ind);T_grd.Y(ind);T_grd.Z(ind)];
        llh_grd = [T_grd.Lat(ind);
            T_grd.Lon(ind);
            T_grd.Alt_HAE_(ind)];  %Degree
        lla = ecef2lla([sppx(i),sppy(i),sppz(i)]);
        [hor_spp(i),ecef_spp(i),ned_err_spp(:,i)]=...
            compt_err(lla(1),lla(2),lla(3),grd,llh_grd);
    end
end

t_sba = T_sba.UTC;
t_sba = datetime(t_sba,'InputFormat','HH:mm:ss.SSS MM/dd/yyyy');

st_ = find(t_sba == st);
ed_ = find(t_sba == ed);
t_sba = t_sba(st_:ed_);
sbax = T_sba.X(st_:ed_);
sbay = T_sba.Y(st_:ed_);
sbaz = T_sba.Z(st_:ed_);
hor_sba = NaN(L,1);
ecef_sba = NaN(L,1);
ned_err_sba = NaN(3,L);
for i=1:L
    ind = find(abs(t_grd - t_sba(i)) < seconds(0.1));
    if ~isempty(ind)
        grd = [T_grd.X(ind);T_grd.Y(ind);T_grd.Z(ind)];
        llh_grd = [T_grd.Lat(ind);
            T_grd.Lon(ind);
            T_grd.Alt_HAE_(ind)];  %Degree
        lla = ecef2lla([sbax(i),sbay(i),sbaz(i)]);
        [hor_sba(i),ecef_sba(i),ned_err_sba(:,i)]=...
            compt_err(lla(1),lla(2),lla(3),grd,llh_grd);
    end
end

%%
purple = [0.4940, 0.1840, 0.5560];
blue = [0, 0.4470, 0.7410];
red = [0.6350, 0.0780, 0.1840];
green = [0.4660, 0.6740, 0.1880];
orange = [0.9290, 0.6940, 0.1250];

set(0,'defaultfigurecolor','w')
figure
subplot(321)
plot(t_x,hor_vn,'.','Color',blue)
hold on
plot(t_x,hor_spp,'.','Color',red)
hold on
plot(t_x,hor_sba,'.','Color',green)
legend('SF GNSS VN','DF GNSS OS','F9P SBAS')
legend('location','northwest');
grid on
axis tight
title('(a) Horizontal Error')
xlabel('Epoch')
ylabel('error, meter')

subplot(325)
plot(t_x,ecef_vn,'.','Color',blue)
hold on
plot(t_x,ecef_spp,'.','Color',red)
hold on
plot(t_x,ecef_sba,'.','Color',green)
legend('SF GNSS VN','DF GNSS OS','F9P SBAS')
grid on
axis tight
title('(e) 3D Error')
xlabel('Epoch')
ylabel('error, meter')

subplot(323)
plot(t_x,abs(ned_err_vn(3,:)),'.','Color',blue)
hold on
plot(t_x,abs(ned_err_spp(3,:)),'.','Color',red)
hold on
plot(t_x,abs(ned_err_sba(3,:)),'.','Color',green)
legend('SF GNSS VN','DF GNSS OS','F9P SBAS')
grid on
axis tight
title('(c) Vertical Error')
xlabel('Epoch');
ylabel('error, meter')

subplot(322)
[f,x] = ecdf(hor_vn);
h_vn = semilogx(x,f); hold on;
h_vn.Color = blue;
h_vn.Marker = 'o';
h_vn.LineWidth = 0.2;
h_vn.MarkerIndices = 1:200:L;
ind = find(min(abs(x-1))==abs(x-1));
ind = ind(1);
line([0.01,x(ind)],[f(ind) f(ind)],'linestyle',':','color',blue,'LineWidth',1.5);
scatter(x(ind),f(ind),'filled','k')


[f,x] = ecdf(hor_spp);
h_spp = semilogx(x,f); hold on;
h_spp.Color = red;
h_spp.Marker = 'o';
h_spp.LineWidth = 0.2;
h_spp.MarkerIndices = 1:200:L;
ind = find(min(abs(x-1))==abs(x-1));
ind = ind(1);
line([0.01,x(ind)],[f(ind) f(ind)],'linestyle',':','color',red,'LineWidth',1.5);
scatter(x(ind),f(ind),'filled','k')

[f,x] = ecdf(hor_sba);
h_sba = semilogx(x,f); hold on;
h_sba.Color = green;
h_sba.Marker = '>';
h_sba.LineWidth = 0.2;
h_sba.MarkerIndices = 1:200:L;
ind = find(min(abs(x-1))==abs(x-1));
ind = ind(1);
line([0.01,x(ind)],[f(ind) f(ind)],'linestyle',':','color',green,'LineWidth',1.5);
scatter(x(ind),f(ind),'filled','k')

line([1,1],[f(1) 1],'linestyle',':','color','k','LineWidth',2);
line([1.5,1.5],[f(1) 1],'linestyle',':','color','k','LineWidth',2);
legend([h_vn,h_spp,h_sba],...
    {'SF GNSS VN','DF GNSS OS','F9P SBAS'})
legend('location','best');
title('(b) Cumulative Distribution of Horizontal Error');
xlabel('Accuracy, meter');
ylabel('Cumulative Probability');
xlim([0.01 10]);
set(gca,'xtick',[0.01,0.1,1,1.5,10]);
set(gca,'xticklabel',{'0.01','0.1','1','1.5','10'});
grid on

subplot(324)
[f,x] = ecdf(abs(ned_err_vn(3,:)));
h_vn = semilogx(x,f); hold on;
h_vn.Color = blue;
h_vn.Marker = 'o';
h_vn.LineWidth = 0.2;
h_vn.MarkerIndices = 1:200:L;

[f,x] = ecdf(abs(ned_err_spp(3,:)));
h_spp = semilogx(x,f); hold on;
h_spp.Color = red;
h_spp.Marker = 'o';
h_spp.LineWidth = 0.2;
h_spp.MarkerIndices = 1:200:L;
ind = find(min(abs(x-3))==abs(x-3));
ind = ind(1);
line([0.01,x(ind)],[f(ind) f(ind)],'linestyle',':','color',red,'LineWidth',1.5);
scatter(x(ind),f(ind),'filled','k')

[f,x] = ecdf(abs(ned_err_sba(3,:)));
h_sba = semilogx(x,f); hold on;
h_sba.Color = green;
h_sba.Marker = '>';
h_sba.LineWidth = 0.2;
h_sba.MarkerIndices = 1:200:L;

line([3,3],[f(1) 1],'linestyle',':','color','k','LineWidth',2);
legend([h_vn,h_spp,h_sba],...
    {'SF GNSS VN','DF GNSS OS','F9P SBAS'})
legend('location','best');
title('(d) Cumulative Distribution of Vertical Error');
xlabel('Accuracy, meter');
ylabel('Cumulative Probability');
xlim([0.01 10]);
set(gca,'xtick',[0.01,0.1,1,3,10]);
set(gca,'xticklabel',{'0.01','0.1','1','3','10'});
grid on

subplot(326)
[f,x] = ecdf(ecef_vn);
h_vn = semilogx(x,f); hold on;
h_vn.Color = blue;
h_vn.Marker = 'o';
h_vn.LineWidth = 0.2;
h_vn.MarkerIndices = 1:200:L;

[f,x] = ecdf(ecef_spp);
h_spp = semilogx(x,f); hold on;
h_spp.Color = red;
h_spp.Marker = 'o';
h_spp.LineWidth = 0.2;
h_spp.MarkerIndices = 1:200:L;
ind = find(min(abs(x-3))==abs(x-3));
ind = ind(1);
line([0.01,x(ind)],[f(ind) f(ind)],'linestyle',':','color',red,'LineWidth',1.5);
scatter(x(ind),f(ind),'filled','k')

[f,x] = ecdf(ecef_sba);
h_sba = semilogx(x,f); hold on;
h_sba.Color = green;
h_sba.Marker = '>';
h_sba.LineWidth = 0.2;
h_sba.MarkerIndices = 1:200:L;

line([3,3],[f(1) 1],'linestyle',':','color','k','LineWidth',2);
legend([h_vn,h_spp,h_sba],...
    {'SF GNSS VN','DF GNSS OS','F9P SBAS'})
legend('location','best');
title('(f) Cumulative Distribution of 3D Error');
xlabel('Accuracy, meter');
ylabel('Cumulative Probability');
xlim([0.01 10]);
set(gca,'xtick',[0.01,0.1,1,3,10]);
set(gca,'xticklabel',{'0.01','0.1','1','3','10'});
grid on

%%

T = hor_vn;
per = length(find(T<=1.0))/length(T)

T = hor_spp;
per = length(find(T<=1.0))/length(T)

T = hor_sba;
per = length(find(T<=1.0))/length(T)

T = hor_vn;
per = length(find(T<=1.5))/length(T)

T = hor_spp;
per = length(find(T<=1.5))/length(T)

T = hor_sba;
per = length(find(T<=1.5))/length(T)

T = ecef_vn;
per = length(find(T<=3.0))/length(T)

T = ecef_spp;
per = length(find(T<=3.0))/length(T)

T = ecef_sba;
per = length(find(T<=3.0))/length(T)

T = abs(ned_err_vn(3,:));
per = length(find(T<=3.0))/length(T)

T = abs(ned_err_spp(3,:));
per = length(find(T<=3.0))/length(T)

T = abs(ned_err_sba(3,:));
per = length(find(T<=3.0))/length(T)