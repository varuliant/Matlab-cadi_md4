% SUB RUTIN UNTUK MEMERIKSA file md4 terbaru dalam suub folder yang siudah
% diperoleh
function md4file_terbaru(new_subdir)
isi_sub = dir(new_subdir);
namafile = {isi_sub.name};
[~,idF] = sort([isi_sub.datenum]);
sort_isi_sub=isi_sub(idF);
file_md4 = {sort_isi_sub.name};
id_m=length(file_md4) -2; %jika mau simulasi manual
new_md4file=char(file_md4{1,id_m})

plot_singlemd4(new_md4file)  % error karena perlu path directori full
% atau bisa saja kita abaikan dan panggil disini???

end