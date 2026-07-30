clc; clear; close all;
fprintf('  FFT Plot — All Three Stages\n');
FS_IN     = 120e6;
FS_DECIM  =  40e6;
FS_INTERP = 480e6;
Q_SCALE   = 2^15;
raw_in  = load('input_signal.txt');
sig_in  = double(raw_in(:))  / Q_SCALE;
fprintf('  Input signal: %d samples  (Fs=120 MHz)\n', numel(sig_in));
raw_dec = load('decimated_output.txt');
sig_dec = double(raw_dec(:)) / Q_SCALE;
fprintf('  Decimated signal: %d samples  (Fs=40 MHz)\n',  numel(sig_dec));
raw_int = load('interpolated_output.txt');
sig_int = double(raw_int(:)) / Q_SCALE;
fprintf('  Interpolated signal: %d samples  (Fs=480 MHz)\n', numel(sig_int));
[f_in,  m_in]  = compute_fft(sig_in,  FS_IN);
[f_dec, m_dec] = compute_fft(sig_dec, FS_DECIM);
[f_int, m_int] = compute_fft(sig_int, FS_INTERP);
report_peak(f_in,  m_in,  'Input      ');
report_peak(f_dec, m_dec, 'Decimated  ');
report_peak(f_int, m_int, 'Interpolated');
fprintf('\nPlotting...\n');
figure('Name','FFT of All Three Stages','Color','k','Position',[80 60 1300 800]);

plot_one(1, f_in,  m_in,  FS_IN,     'Input Signal',            [0    0.45 0.74]);
plot_one(2, f_dec, m_dec, FS_DECIM,  'After Decimation  /3',    [0.2  0.8  0.2 ]);
plot_one(3, f_int, m_int, FS_INTERP, 'After Interpolation x12', [0.85 0.33 0.10]);

sgtitle('FFT — Input, Decimated, Interpolated Signals','Color','w','FontWeight','bold','FontSize',13);
function [freq_mhz, mag_db] = compute_fft(sig, fs)
    N        = numel(sig);
    win      = hann(N);
    xw       = sig(:) .* win;          
    X        = fft(xw, N);            
    X_one    = X(1 : floor(N/2)+1);   
    mag      = abs(X_one) / (N/2);    
    mag_db   = 20*log10(mag + 1e-12); % dB
    freq_mhz = (0 : floor(N/2)) * fs / N / 1e6;
end

function report_peak(freq_mhz, mag_db, label)
    [~, idx] = max(mag_db);
    fprintf('  %s peak: %.2f MHz  (%.1f dB)\n',label, freq_mhz(idx), mag_db(idx));
end

function plot_one(row, freq_mhz, mag_db, fs_hz, ttl, clr)
    nyquist = fs_hz / 2 / 1e6;
    subplot(3,1,row);
    set(gca,'Color','k','XColor','w','YColor','w','GridColor','w','GridAlpha',0.15);
    hold on; grid on;

    plot(freq_mhz, mag_db, 'Color', clr, 'LineWidth', 1.0);

    xline(1,  '--','1 MHz', 'Color','yellow','LineWidth',1.2,'LabelColor','yellow','FontSize',8);
    xline(15, ':','15 MHz cutoff','Color',[0.7 0.4 1],'LineWidth',1.2,'LabelColor',[0.7 0.4 1],'FontSize',8);
    [~, pi_] = min(abs(freq_mhz - 1.0));
    text(2, mag_db(pi_), sprintf('%.1f dB @ 1 MHz', mag_db(pi_)),'Color','yellow','FontSize',8);

    xlim([0 nyquist]); ylim([-100 5]);
    xlabel(sprintf('Frequency (MHz)   [Nyquist = %.0f MHz]', nyquist),'Color','w','FontSize',9);
    ylabel('Magnitude (dB)','Color','w','FontSize',9);
    title(sprintf('%s   (Fs = %.0f MHz)', ttl, fs_hz/1e6), 'Color','w','FontSize',10,'FontWeight','bold');
    hold off;
end
