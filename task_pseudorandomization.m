% This MATLAB script generates a pseudorandom trial order for a participant
% in an experimental task with a very complex design.
% This randomization is important for avoiding any biases in the data due to 
% the particular way in which trials/conditions were sequenced in the task.
 
% 4 groups of negative pictures are use as the stimuli in this task, along with 
% some neutral pictures (as a control).
% The groups of negative picture stimuli have been matched for valence,
% arousal, and reappraisability. 
% The 4 groups of negative picture stimuli are randomly assigned
% to 4 condition combinations: self-look, self-change, other-look, and other-change.
% The neutral picture stimuli are only assigned to the self-look and other-look
% condition combinations. 
% The sequences are saved into 2 text files, 1 that will be referenced for blocks of
% trials associated with the "self" condition, and another for blocks associated with the
% "other" condition. 
% But first the trials are arranged into randomly shuffled miniblocks. 
% Each miniblock is constructed to contain 1 neutral picture (always look condition), 
% and 2 negative pictures (1 look condition and 1 change condition). 
% This miniblock structure ensures that no more than 2 trials with the same combination 
% of picture type and condition will ever appear consecutively.

% reseed the random number generator
rng shuffle;

% open the lists of negative and neutral picture stimuli
neg1_stim_fid = fopen('neg1.txt');
neg2_stim_fid = fopen('neg2.txt');
neg3_stim_fid = fopen('neg3.txt');
neg4_stim_fid = fopen('neg4.txt');
neu_stim_fid = fopen('neu.txt');

% read the lists of stimuli into cell arrays
neg1_stim = textscan(neg1_stim_fid, '%s');
neg2_stim = textscan(neg2_stim_fid, '%s');
neg3_stim = textscan(neg3_stim_fid, '%s');
neg4_stim = textscan(neg4_stim_fid, '%s');
neu_stim = textscan(neu_stim_fid, '%s');

% close the stimuli list files
fclose(neg1_stim_fid);
fclose(neg2_stim_fid);
fclose(neg3_stim_fid);
fclose(neg4_stim_fid);
fclose(neu_stim_fid);

% convert cells arrays into regular string arrays
neg1_stim_str = string(neg1_stim{1});
neg2_stim_str = string(neg2_stim{1});
neg3_stim_str = string(neg3_stim{1});
neg4_stim_str = string(neg4_stim{1});
neu_stim_str = string(neu_stim{1});

% randomly shuffle the order of stimuli in each list
neg1_order = randperm(24);
neg2_order = randperm(24);
neg3_order = randperm(24);
neg4_order = randperm(24);
neu_order = randperm(48);
neg1_stim_str = neg1_stim_str(neg1_order);
neg2_stim_str = neg2_stim_str(neg2_order);
neg3_stim_str = neg3_stim_str(neg3_order);
neg4_stim_str = neg4_stim_str(neg4_order);
neu_stim_str = neu_stim_str(neu_order);

% randomly assign the negative stimuli groups to the 
% self-look, self-change, other-look, and other-change conditions
neg_group_order = randperm(4);
neg_cell = {neg1_stim_str, neg2_stim_str, neg3_stim_str, neg4_stim_str};
stim_list_self = [neg_cell{neg_group_order(1)}; neg_cell{neg_group_order(2)}; neu_stim_str(1:24)];
stim_list_other = [neg_cell{neg_group_order(3)}; neg_cell{neg_group_order(4)}; neu_stim_str(25:48)];

% create lists for picture type (negative or neutral) 
% and cue (look or change) with categorical values of 1 and 2
neg_type_list = ones(48,1);
neu_type_list = 2*ones(24,1);
type_list = [neg_type_list; neu_type_list];
change_list = ones(24,1);
look_list = 2*ones(48,1);
cue_list = [change_list; look_list];

% group trials into miniblocks, each containing 2 negative pictures and 1 neutral picture
% the same order is applied to all the various lists (i.e., also those that store the other conditions)
reorder_for_miniblocks = zeros(72,1);
for i = 1:24
    reorder_for_miniblocks((3*(i-1)+1):(3*(i-1)+3)) = [i, i+24, i+48];
end
stim_list_self = stim_list_self(reorder_for_miniblocks);
stim_list_other = stim_list_other(reorder_for_miniblocks);
type_list_self = type_list(reorder_for_miniblocks);
type_list_other = type_list(reorder_for_miniblocks); 
cue_list_self = cue_list(reorder_for_miniblocks);
cue_list_other = cue_list(reorder_for_miniblocks);

% shuffle the order of trials within each miniblock
% again applying the same shuffling to all the lists
for mb = 1:24
    shuffle_mbs = randperm(3);
    miniblock = stim_list_self((3*(mb-1)+1):(3*(mb-1)+3));
    miniblock = miniblock(shuffle_mbs);
    stim_list_self((3*(mb-1)+1):(3*(mb-1)+3)) = miniblock;
    miniblock = type_list_self((3*(mb-1)+1):(3*(mb-1)+3));
    miniblock = miniblock(shuffle_mbs);
    type_list_self((3*(mb-1)+1):(3*(mb-1)+3)) = miniblock;
    miniblock = cue_list_self((3*(mb-1)+1):(3*(mb-1)+3));
    miniblock = miniblock(shuffle_mbs);
    cue_list_self((3*(mb-1)+1):(3*(mb-1)+3)) = miniblock;
    shuffle_mbo = randperm(3);
    miniblock = stim_list_other((3*(mb-1)+1):(3*(mb-1)+3));
    miniblock = miniblock(shuffle_mbo);
    stim_list_other((3*(mb-1)+1):(3*(mb-1)+3)) = miniblock;
    miniblock = type_list_other((3*(mb-1)+1):(3*(mb-1)+3));
    miniblock = miniblock(shuffle_mbo);
    type_list_other((3*(mb-1)+1):(3*(mb-1)+3)) = miniblock;
    miniblock = cue_list_other((3*(mb-1)+1):(3*(mb-1)+3));
    miniblock = miniblock(shuffle_mbo);
    cue_list_other((3*(mb-1)+1):(3*(mb-1)+3)) = miniblock;
end

% write the trial order info to text files so they can be referenced 
% during the experimental task
self_fid = fopen('self_order.txt', 'wt');
other_fid = fopen('other_order.txt', 'wt');
for i = 1:72
    fprintf(self_fid, '%s %i %i\n', ...
        stim_list_self(i), ...
        type_list_self(i), ...
        cue_list_self(i));
    fprintf(other_fid, '%s %i %i\n', ...
        stim_list_other(i), ...
        type_list_other(i), ...
        cue_list_other(i));
end
fclose(self_fid);
fclose(other_fid);
