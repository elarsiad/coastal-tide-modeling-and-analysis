%% Verifikasi prediksi pasang surut
%% Instruksi:
% Data yang dibutuhkan: excel data observasi (baris 35) dan excel data prediksi (baris 104) pada waktu yang sama
% 1. Tekan Ctrl+H ganti nama lokasi sesuai dengan lokasi stasiun AWL lalu pilih replace
% 2. Ubah nama bulan (3 huruf pertama nama bulan)yang akan diverifikasi pada baris 17 
% 3. Tekan Ctrl+H lalu ganti nama bulan lengkap yang akan diverifikasi, misal "September" diganti "September", sesuai dengan nama bulan di excel data
% 4. Ganti lokasi lintang sesuai lokasi AWL pada baris ke-32 (lihat lintang di excel Meta Data AWL).
% 5. Ganti zona waktu pada baris ke-33(sesuaikan dengan lokasi AWL: 1. WIB; 2. WITA; 3. WIT)
% 6. Jangan lupa perhatikan kondisi data pada figure 1, jika ada nilai yang outlier maka 
%    aktifkan script pada baris 54 atau baris 55 dengan cara menghilangkan tanda "%" 
% 7. Ganti nama bulan (3 huruf pertama nama bulan) pada baris 104 sesuai dengan 
%    bulan yang akan diverifikasi
% 8. Run program dengan cara klik run pada menu editor.
clear all; clc; close all;

% Masukkan nama bulan yang akan diverifikasi
nama_bulan = 'Sep';
if nama_bulan == 'Jan'; n_hari = 31; bulan = 1;
elseif nama_bulan == 'Feb'; n_hari = 29; bulan = 2;
elseif nama_bulan == 'Mar'; n_hari = 31; bulan = 3;
elseif nama_bulan == 'Apr'; n_hari = 30; bulan = 4;
elseif nama_bulan == 'Mei'; n_hari = 31; bulan = 5;
elseif nama_bulan == 'Jun'; n_hari = 30; bulan = 6;
elseif nama_bulan == 'Jul'; n_hari = 31; bulan = 7;
elseif nama_bulan == 'Agu'; n_hari = 31; bulan = 8;
elseif nama_bulan == 'Sep'; n_hari = 30; bulan = 9;
elseif nama_bulan == 'Okt'; n_hari = 31; bulan = 10;
elseif nama_bulan == 'Nov'; n_hari = 30; bulan = 11;
else nama_bulan == 'Des'; n_hari = 31; bulan = 12;
end

lintang = 1.1647222; % jangan lupa diganti
zona_waktu = 1; % jangan lupa ubah, 1 untuk WIB, 2 untuk WITA, dan 3 untuk WIT
% import data observasi
data_awl = importdata('data_awl_Batam_September_2020.xlsx',' ');
waktu_awl = data_awl.textdata(:,1); waktu_awl = waktu_awl(2:length(waktu_awl),:);
waterlevel = data_awl.data;  
waterlevel = 8-waterlevel; ; %% Batgham pakai 8,Clacap pakai 7;% Tnjung Priok gak dibalik ya
waterlevel = medfilt1(waterlevel,5); 

for i=1:length(waterlevel);
    time_awl(i) = datetime(waktu_awl{i},'InputFormat','yyyy-MM-dd HH:mm:ss','Timezone','UTC');
end
if zona_waktu==1;
    time_awl = datetime(time_awl,'TimeZone','UTC+7');
elseif zona_waktu==2;
        time_awl = datetime(time_awl,'TimeZone','UTC+8');
    else zona_waktu==3;
        time_awl = datetime(time_awl,'TimeZone','UTC+9');
end
figure; plot(time_awl, waterlevel(:,1)); title('Batam') % untuk melihat bagaimana kondisi datanya

%% Menghilangkan outlier pada data observasi (jangan lupa diaktifkan jika ada data outlier)
%waterlevel(waterlevel<=3.48)=NaN; % jangan lupa dicek
%  waterlevel(waterlevel>=10)=NaN; % jangan lupa dicek
waterlevel(waterlevel>=3.6)=NaN; %clcap 3.2 % Jaypura>3.2, % bnywngi 2.5 % diaktifkan tika ada outlier
figure; plot(time_awl, waterlevel(:,1)); title('Batam') % untuk melihat bagaimana kondisi datanya

% sampling tiap jam
[~,~,~,~,minutes,~]=datevec(time_awl);
idx = find (minutes==0); % kalau tnjng priok pakai menit 1
time_awl = time_awl(idx); waterlevel = waterlevel(idx);

% mengisi data kosog dengan NaN, ini cuma untuk WIB, kalau WITA dan WIT, silahkan disesuaikan sama kayak yg di script prediksi
if zona_waktu==1;
time_reference = linspace(datetime(2020,bulan,1,7,0,0,'TimeZone','UTC+7'),datetime(2020,bulan+1,1,6,0,0,'TimeZone','UTC+7'),n_hari*24); %sesuaikan % kalau priok pakai 1
elseif zona_waktu==2;
    time_reference = linspace(datetime(2020,bulan,1,8,0,0,'TimeZone','UTC+8'),datetime(2020,bulan+1,1,7,0,0,'TimeZone','UTC+8'),n_hari*24);
else
    zona_waktu==3;
    time_reference = linspace(datetime(2020,bulan,1,9,0,0,'TimeZone','UTC+9'),datetime(2020,bulan+1,1,8,0,0,'TimeZone','UTC+9'),n_hari*24);
end
index_awl=ismember(time_reference,time_awl);
index_awl = find(index_awl==1);
waterlevel_fix = NaN(length(time_reference),1); 
waterlevel_fix(index_awl)=waterlevel(:);
waterlevel=waterlevel_fix;
time = time_reference;

%% Nyari msl
echo on
       echo on
       % Load the example.
%        load t_example
      
       % Define inference parameters.
       infername=['P1';'K2'];
       inferfrom=['K1';'S2'];
       infamp=[.33093;.27215];
       infphase=[-7.07;-22.40];
       
       % The call (see t_demo code for details).
       [msl,tidestruc]=t_tide(waterlevel,...
       'interval',1, ...                     % hourly data
       'start',datenum(time(1)),...               % start time is datestr(tuk_time(1))
       'latitude',lintang,...               % Latitude of obs
       'inference',infername,inferfrom,infamp,infphase,...
       'shallow','M10',...                   % Add a shallow-water constituent 
       'error','linear',...                   % coloured boostrap CI
       'synthesis',1);                       % Use SNR=1 for synthesis. 

clear tidestruc
clear index_awl waterlevel_fix
%% Input data prediksi
prediksi=xlsread('Prediksi Pasang Surut Sep 2020 Batam.xlsx'); % jangan lupa ubah di sini, 
prediksi=prediksi(2:end,:); prediksi=prediksi'; prediksi=prediksi(:);

if zona_waktu==1
t_prediksi = linspace(datetime(2020,bulan,1,0,0,0,'TimeZone','UTC+7'),datetime(2020,bulan,n_hari,23,0,0,'TimeZone','UTC+7'),n_hari*24);
elseif zona_waktu==2
    t_prediksi = linspace(datetime(2020,bulan,1,0,0,0,'TimeZone','UTC+8'),datetime(2020,bulan,n_hari,23,0,0,'TimeZone','UTC+8'),n_hari*24);
else zona_waktu==3
    t_prediksi = linspace(datetime(2020,bulan,1,0,0,0,'TimeZone','UTC+9'),datetime(2020,bulan,n_hari,23,0,0,'TimeZone','UTC+9'),n_hari*24);
end

%% Verifikasi
if zona_waktu==1;
    idx_akhir_t = find(time==datetime(2020,bulan,n_hari,23,0,0,'TimeZone','UTC+7'));
elseif zona_waktu==2;
        idx_akhir_t = find(time==datetime(2020,bulan,n_hari,23,0,0,'TimeZone','UTC+8'));
else zona_waktu==3;
        idx_akhir_t = find(time==datetime(2020,bulan,n_hari,23,0,0,'TimeZone','UTC+9'));
end
t_obs=time(1:idx_akhir_t);
waterlevel=waterlevel(1:idx_akhir_t);
index_awl=ismember(t_prediksi,t_obs);
index_awl = find(index_awl==1);
waterlevel_fix = NaN(length(t_prediksi),1); 
waterlevel_fix(index_awl)=waterlevel(:);
waterlevel=waterlevel_fix;

% visualisasi hasil
figure
set(gcf,'position',[100 200 1000 400]);
plot(t_prediksi,prediksi+msl,'-black','linewidth',1.5); title('Batam'); hold on;
plot(t_prediksi,waterlevel,':red','linewidth',1.5)
%xlabel('Time'); ylabel('Elevasi(m)'); xlim([min(datenum(t_prediksi)) max(datenum(t_prediksi))]); 
xlabel('Time'); ylabel('Elevasi(m)'); %xlim([min(datenum(t_prediksi)) max(datenum(t_prediksi))]); 
legend('Prediction','Observation');grid on; 
print('Perbandingan data Prediksi dan Observasi Batam September 2020','-djpeg','-r750')

%% Korelasi dan Error BMKG

korelasi =corr(prediksi,waterlevel, 'rows','complete')
idx_nan_ver = find(isnan(waterlevel));
prediksi(idx_nan_ver)=NaN;

re_BMKG = abs(((prediksi+msl)-waterlevel)./(waterlevel)).*100;   
mre_BMKG = nanmean(re_BMKG);
figure
set(gcf,'position',[100 200 1000 400]);
plot(t_prediksi,re_BMKG,'-black','linewidth',1.5); title('Batam'); hold on;
plot(t_prediksi,mre_BMKG.*(ones(length(t_prediksi),1)),':red','linewidth',1.5)
%xlabel('Time'); ylabel('Error(%)'); xlim([min(datenum(t_prediksi)) max(datenum(t_prediksi))]); 
xlabel('Time'); ylabel('Error(%)'); %xlim([min(datenum(t_prediksi)) max(datenum(t_prediksi))]); 
legend('Relative Error','Mean Relative Error');grid on; ylim([0 30])
print('MRE dan RE September prediksi vs observasi 2020','-djpeg','-r750')



