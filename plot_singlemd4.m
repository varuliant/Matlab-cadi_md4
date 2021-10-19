function plot_singlemd4(fname)
% harusnya dengan path folder
fname='0J071045.MD4';
    fid = fopen(fname,'r');
    timestamp   = fread(fid,25,'schar'); timestamp = char(timestamp');
    filetype    = fread(fid,1,'schar'); filetype = char(filetype);
    num_freq    = fread(fid,1,'uint16');
    dop_len     = fread(fid,1,'uint8');
    min_hgt     = fread(fid,1,'uint16');
    max_hgt     = fread(fid,1,'uint16');
    ppsec       = fread(fid,1,'uint8');
    npulsavg    = fread(fid,1,'uint8');
    base_thres  = fread(fid,1,'uint16');
    noise_thres = fread(fid,1,'uint16');
    min_ndop    = fread(fid,1,'uint8');
    igcadence   = fread(fid,1,'uint16');
    gain_ctrl   = fread(fid,1,'schar'); %gain_ctrl = char(gain_ctrl);
    sig_process = fread(fid,1,'uint8');
    num_rcvr    = fread(fid,1,'uint8');
    sblank      = fread(fid,11,'schar'); sblank = char(sblank');
    
    freqlist = fread(fid,num_freq,'float32');
    
    time_min = fread(fid,1,'uint8');
    time_sec = fread(fid,1,'uint8');

    timehr = str2num(timestamp(12:13)) + ...    % Float Local Time (Hours)
             str2num(timestamp(15:16))/60 + ... % 
             str2num(timestamp(18:19))/3600;    %
    
    flag=1; ipt=1; ifreq=0; dh=3.0;
    
    while flag==1 && ifreq<num_freq
          gainflag=fread(fid,1,'uint8');
          if gainflag==255 % <----- end of frequencies, stop reading data
             flag=0;
          elseif gainflag>200 % <-- frequency marker, increment frequency
             noiseflag = fread(fid,1,'uint8');
             noise     = fread(fid,1,'uint16');
             ifreq=ifreq+1;
          else % <-- height marker, read all data point at current frequency
             hnum = gainflag; %fread(fid,1,'uint8')--> membuat error VITAL
             tnum = fread(fid,1,'uint8');
             if tnum > 128    % Modifikasi mulai disini
                 tnum=tnum-128;
                 hnum=hnum+200;
             end              % Modifikasi stop disini
             for l=1:tnum 
%                
                 dnum = fread(fid,1,'uint8');
                 i1_bytes(l) = fread(fid,1,'uint8');    
                 q1_bytes(l) = fread(fid,1,'uint8');
                 i2_bytes(l) = fread(fid,1,'uint8');  % karena 2 receiver    
                 q2_bytes(l) = fread(fid,1,'uint8');  % karena 2 receiver    
                 powr = (sqrt(i1_bytes(l)^2+q1_bytes(l)^2))+ (sqrt(i2_bytes(l)^2+q2_bytes(l)^2));
                 phase1=atand(i1_bytes(l)/q1_bytes(l));
                 phase2=atand(i2_bytes(l)/q2_bytes(l));
                 f=freqlist(ifreq)/1.0e6;
                 h=hnum*dh;
                 i1=i1_bytes(l);
                 q1=q1_bytes(l);
                 
                 % tambahan agar bisa dibuat dengan plot contour
                 array_h(ifreq,l)=hnum*3; % array index frekuensi (ketinggian)
                 array_pwr(ifreq,l)=powr; % array frekuensi (ketinggian)
                 array_phase1(ifreq,l)=phase1;
                 array_phase2(ifreq,l)=phase2;
                 
                 if powr>0
                    p=powr;
                    %p=log10(powr);  % Filter visualisasi graph
                 
                    if f>=1.0 && p>1
                       x(ipt)=f;
                       y(ipt)=h;
                       z(ipt)=p;
                       inphase1(ipt)=i1;
                       qudrature1(ipt)=q1;
                       intensity(ipt)=powr;
                       ipt=ipt+1;
                    end                               
                end
            end
        end
    end
    %
	fclose(fid);
    figure
    plot(x,y,'.b','MarkerSize',1);
    title([timestamp(9:10),'-',timestamp(5:7),'-',timestamp(21:24),' ',timestamp(12:19),' LT']);
    xlabel('Frequency (MHz)'); ylabel('Virtual Height (km)');
    xlim([1 15]); ylim([80 1020]);
    drawnow;  

end