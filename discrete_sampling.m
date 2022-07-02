function success = poisson_isi(mean_isi, num_isi, min_isi, max_isi, interval)

%This function generates a list of interstimulus intervals (isi's) based on a poisson distribution 
%and saves to a text file. User provides the desired mean duration of isi, the total
%number of values requested in the list, the minimum and maximum allowable
%isi duration, and the resolution of the distribution in seconds (e.g. 0.5 will 
%generate a list that varies by half-second increments between min_isi and max_isi).

fid = fopen('isi_sequence.txt', 'w+');
success = true;

% exit if file cannot be written
if fid < 0
    success = false;
    return;
end

isi_list = [];
mean_isi = mean_isi/interval;
min_isi = min_isi/interval;
max_isi = max_isi/interval;

% continue randomly sampling from poisson distribution until desired num_isi reached
while length(isi_list) < num_isi
    isi = poissrnd(mean_isi);
    
	% only retain values that meet the min and max criteria
	if isi >= min_isi && isi <= max_isi
        isi_list = [isi_list,isi];
    end
end

isi_list = isi_list*interval;
fprintf(fid,'%.2f\n',isi_list);
fclose(fid);
actual_mean_isi = mean(isi_list)
actual_sum_isi = sum(isi_list)
end