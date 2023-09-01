%% Peramalan pasang surut
% Pusat Meteorologi Maritim
%% Instruksi:
% 1. Tekan Ctrl+H ganti nama lokasi sesuai dengan lokasi stasiun AWL lalu pilih replace
% 2. Ubah nama bulan (3 huruf pertama nama bulan) pada baris 20 sesuai bulan data observasi (data AWL)
% 3. Tekan Ctrl+H lalu ganti nama bulan lengkap sesuai data pengamatan, misal "April" diganti "April", sesuai dengan nama bulan di excel data
% 4. Ganti lokasi lintang sesuai lokasi AWL pada baris ke-42.
% 5. Ganti zona waktu pada baris ke-44(sesuaikan dengan lokasi AWL: 1. WIB; 2. WITA; 3. WIT)
% 6. Jangan lupa perhatikan kondisi data pada figure 1, jika ada nilai yang outlier maka 
%    aktifkan script pada baris 54 atau baris 55 dengan cara menghilangkan tanda "%" 
% 7. Ganti nama bulan (3 huruf pertama) yang akan diramalkan pada baris ke-127,151, dan 173-175 
% 8. Untuk menampilkan plot prediksi sesuai waktu yang diinginkan, ubah
%    parameter pada baris ke 154-158 sesuai waktu yang diinginkan, serta
%    pada baris ke 167  ganti nama gambar sesuai waktu yang dimaksud
% 9. Run program dengan cara klik run pada menu editor.
%% Input dan preparasi data Observasi
clear all; clc; close all

% Masukkan nama bulan observasi
nama_bulan = 'Apr'; % jangan lupa ganti di sini 
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


data_awl = importdata('data_awl_Pontianak_April_2021.xlsx',' ');
waktu_awl = data_awl.textdata(:,1); waktu_awl = waktu_awl(2:length(waktu_awl),:);
waterlevel = data_awl.data;  
waterlevel = 5-waterlevel; % kndrai 6, Batham pakai 8,% TnAgug Priok gak diPontianakk ya, nnukan pakai 6, jika datanya tidak terPontianakk, maka ini dinonaktifkan dengan cara tekan ctrl+r di awal baris ini
waterlevel = movmean(waterlevel,20); % Smothing data, menghilangkan sinyal frekuensi tinggi

lintang = 109.337349; % jangan lupa diganti

zona_waktu = 1; % jangan lupa ubah, 1 untuk WIB, 2 untuk WITA, dan 3 untuk WIT

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
       
figure; plot(time_awl, waterlevel(:,1)); title('Pontianak') % untuk melihat bagaimana kondisi datanya
%print('kondisi data awl Pontianak April 2021','-djpeg','-r750')
waterlevel(waterlevel<3.28)=NaN; % pntianak ubah % Ini diaktifkan ketika ada nilai outlier dari grafiknya
%waterlevel(waterlevel>=3.4)=NaN; %clcap 3.2 % Jaypura>3.2, % bnywngi 2.5 % diaktifkan tika ada outlier
% 
figure; plot(time_awl, waterlevel(:,1)) % untuk melihat bagaimana kondisi data setelah diubah (menghilangkan nilai outlier)

% sampling tiap jam
[~,~,~,~,minutes,~]=datevec(time_awl);
idx = find (minutes==0); % kalau tnjng priok pakai menit 1
time_awl = time_awl(idx); waterlevel = waterlevel(idx);

% mengisi data kosong dengan NaN, mengubah waktu dari UTC ke local time
if zona_waktu==1;
time_reference = linspace(datetime(2021,bulan,1,7,0,0,'TimeZone','UTC+7'),datetime(2021,bulan+1,1,6,0,0,'TimeZone','UTC+7'),n_hari*24); %sesuaikan % kalau priok pakai 1
elseif zona_waktu==2;
    time_reference = linspace(datetime(2021,bulan,1,8,0,0,'TimeZone','UTC+8'),datetime(2021,bulan+1,1,7,0,0,'TimeZone','UTC+8'),n_hari*24);
else
    zona_waktu==3;
    time_reference = linspace(datetime(2021,bulan,1,9,0,0,'TimeZone','UTC+9'),datetime(2021,bulan+1,1,8,0,0,'TimeZone','UTC+9'),n_hari*24);
end


index_awl=ismember(time_reference,time_awl);
index_awl = find(index_awl==1);
waterlevel_fix = NaN(length(time_reference),1); 
waterlevel_fix(index_awl)=waterlevel(:);
waterlevel=waterlevel_fix;
time = time_reference;

%% Harmonic Analysis untuk mendapatkan konstanta pasang surut
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

figure
set(gcf,'position',[100 200 1000 400]);
plot(time,waterlevel-msl,'-black','linewidth',1.5); %hold on; plot(time,polyval(f,datenum(time)),'linewidth',1.5);
title('Data Observasi-MSL Pontianak April');%xlabel('Tanggal'); ylabel('Elevasi(m)'); xlim([min(datenum(time)) max(datenum(time))]); 
%grid on; print('Pasang Surut Pontianak April 2021','-djpeg','-r750')

% yang dibawah ini optional, jika mau nambahin trend pada grafiknya, silahkan
% f=polyfit(datenum(time'),inpaintn(waterlevel-real(1.36)),1);
% figure
% set(gcf,'position',[100 200 1000 400]);
% plot(time,waterlevel-real(1.36),'-black','linewidth',1.5); hold on; plot(time,polyval(f,datenum(time)),'linewidth',1.5);
% title('Pontianak');xlabel('Tanggal'); ylabel('Elevasi(m)'); xlim([min(datenum(time)) max(datenum(time))]); 
% legend('Water Level','Trend Linear','location','southeast'); grid on; print('Pasut Pontianak April 2021','-djpeg','-r750')

% menyimpan konstanta pasut
%save('konstanta_harmonik_Pontianak_April.mat','tidestruc');

%% Melakukan prediksi pasang surut
nama_bulan = 'Mei';
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

t_prediksi = linspace(datetime(2021,bulan,1,0,0,0),datetime(2021,bulan,n_hari,23,0,0),n_hari*24);
t_prediksi = t_prediksi';
prediksi=t_predic(datenum(t_prediksi),tidestruc,'latitude',lintang,'synthesis',1);

% visualisasi hasil sebulan
figure
set(gcf,'position',[100 200 1000 400]);
plot(t_prediksi,prediksi,'-black','linewidth',1.5); title('Pontianak')
%xlabel('Time'); ylabel('Elevasi(m)'); xlim([min(datenum(t_prediksi)) max(datenum(t_prediksi))]); 
grid on; print('Prediksi Pasut Pontianak Mei 2021','-djpeg','-r750')

% visualisasi hasil sesuai waktu yang diinginkan (ubah sesuai waktu yang diinginkan)
tahun = 2021;
tanggal_awal= 26; 
tanggal_akhir = 27;
jam_awal = 0; % 0 - 23
jam_akhir = 23; % 0 - 23

idx_t_awal = find(t_prediksi==datetime(tahun,bulan,tanggal_awal,jam_awal,0,0));
idx_t_akhir = find(t_prediksi==datetime(tahun,bulan,tanggal_akhir,jam_akhir,0,0));

figure
set(gcf,'position',[100 200 1000 400]);
plot(t_prediksi(idx_t_awal:idx_t_akhir),prediksi(idx_t_awal:idx_t_akhir),'-black','linewidth',1.5); title('Pontianak')
xlabel('Time'); ylabel('Elevasi(m)'); %xlim([min(datenum(t_prediksi(idx_t_awal:idx_t_akhir))) max(datenum(t_prediksi(idx_t_awal:idx_t_akhir)))]);
grid on; print('Prediksi Pasut Pontianak tanggal 26 sampai tanggal 27 2021','-djpeg','-r750') % jangan lupa diganti tanggalnya

% export data ke excel
tanggal_excel = linspace(datetime(tahun,bulan,1),datetime(tahun,bulan,n_hari),n_hari)';
prediksi_excel = reshape(round(prediksi,3),24,n_hari)'; 
col_header = {'Tanggal/Jam','0', '1', '2', '3', '4', '5', '6','7','8','9','10','11','12','13','14','15','16','17','18','19','20','21','22','23'};
xlswrite('Prediksi Pasang Surut Mei 2021 Pontianak.xlsx',col_header,'Sheet1','A1');
xlswrite('Prediksi Pasang Surut Mei 2021 Pontianak.xlsx',cellstr(tanggal_excel),'Sheet1','A2');
xlswrite('Prediksi Pasang Surut Mei 2021 Pontianak.xlsx',prediksi_excel,'Sheet1','B2');
%load (konstanta_harmonik_Pontianak_April,'-mat');
