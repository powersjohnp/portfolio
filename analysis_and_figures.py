# This Python script preprocesses and analyzes data from a research task and produces accompanying figures.
# This script was designed to run basic analyses for periodic progress reports for a clinical trial. 

# general setup
import pandas as pd
import math
import numpy as np
from scipy import stats
import matplotlib.pyplot as plt
from numpy.polynomial.polynomial import polyfit
import datetime
import os
import statsmodels.api as sm


# ... CODE OMITTED


# looping through subjects and computing values of interest
for iterator in inputs:

    # read data file as csv with comma or space delimiters
    df = pd.read_csv(iterator[1], sep=',|\s+', engine='python')
    
    
    # ... CODE OMITTED

    
    # extract trials for blocks that will be analyzed, just retain columns 'CORRECT' and 'RT' (7 and 8)
    all1 = df.iloc[128:144, 7:9]
    all2 = df.iloc[144:160, 7:9]
    switch1 = df.iloc[switch1_startrow:switch1_startrow+16, 7:9]
    switch2 = df.iloc[switch2_startrow:switch2_startrow+16, 7:9]
    
    ## the following code computes one of the key task measures: general switch cost
    
    # determine if any blocks still contain 3 or more errors and store this in indicator variables for each block type
    if (all1['CORRECT'] == 0).sum() > 2:
        bad_all1 = 1
    else:
        bad_all1 = 0
    if (all2['CORRECT'] == 0).sum() > 2:
        bad_all2 = 2
    else:
        bad_all2 = 0
	# sum gives us unique codes, 1 means first block of that type was bad, 2 means second was bad, 3 means both were bad
    bad_all = bad_all1 + bad_all2
    if (switch1['CORRECT'] == 0).sum() > 2:
        bad_switch1 = 1
    else:
        bad_switch1 = 0
    if (switch2['CORRECT'] == 0).sum() > 2:
        bad_switch2 = 2
    else:
        bad_switch2 = 0
    bad_switch = bad_switch1 + bad_switch2
    
    # collapse blocks of the same type (ALL or SWITCH) to facilitate true mean calculation later
    # avoids trials being weighted differently if blocks had different #s of trials with correct responses 
    # since trials with incorrect responses are about to be excluded
    if bad_all == 1:
        all_full = all2
    elif bad_all == 2:
        all_full = all1
    else:
        all_full = all1.append(all2, ignore_index=True)
    if bad_switch == 1:
        switch_full = switch2
    elif bad_switch == 2:
        switch_full = switch1
    else:
        switch_full = switch1.append(switch2, ignore_index=True)
    
    # exclude trials with incorrect responses
    all_correct = all_full[all_full['CORRECT'] == 1]
    switch_correct = switch_full[switch_full['CORRECT'] == 1]
    
    # record percentage of trials discarded due to incorrect responses
    all_incorrect = all_full[all_full['CORRECT'] == 0]
    switch_incorrect = switch_full[switch_full['CORRECT'] == 0]
    if bad_all == 1 or bad_all == 2:
        if bad_switch == 1 or bad_switch == 2:
            percent_trials_excluded = (len(all_incorrect) + len(switch_incorrect)) / .32
        else:
            percent_trials_excluded = (len(all_incorrect) + len(switch_incorrect)) / .48
    elif bad_switch == 1 or bad_switch == 2:
        percent_trials_excluded = (len(all_incorrect) + len(switch_incorrect)) / .48
    else:
        percent_trials_excluded = (len(all_incorrect) + len(switch_incorrect)) / .64
    
    # calculate means for each block type
    all_mean = all_correct['RT'].mean()
    switch_mean = switch_correct['RT'].mean()
    
    # match previous work by applying natural log transformation to means
    all_mean_ln = math.log(all_mean)
    switch_mean_ln = math.log(switch_mean)
    
    # calculate general switch cost as difference in log transformed mean reaction times
    gen_switch_cost = switch_mean_ln - all_mean_ln
    
    
    # ... CODE OMITTED FOR OTHER MEASURES
    

    # append a dictionary of results for this subject to a running list
    if bad_all == 3 or bad_switch == 3:
        results.append({'SUBID': iterator[0], 'AGE': iterator[2], 'DEPRESS': iterator[3], 'GEN_SWITCH_COST': 999, 'ALL_MEAN': 999, 
        'SWITCH_MEAN': 999, 'SPEC_SWITCH_COST': 999, 'NON-SWITCH_TRIAL_MEAN': 999, 'SWITCH_TRIAL_MEAN': 999, 'NON-SWITCH_COST': 999, 
        'PERCENT_BAD_TRIALS': 999, 'BAD_ALL': bad_all, 'BAD_SWITCH': bad_switch})
    else:
        results.append({'SUBID': iterator[0], 'AGE': iterator[2], 'DEPRESS': iterator[3], 'GEN_SWITCH_COST': gen_switch_cost, 
        'ALL_MEAN': all_mean, 'SWITCH_MEAN': switch_mean, 'SPEC_SWITCH_COST': spec_switch_cost, 'NON-SWITCH_TRIAL_MEAN': switch_ns_mean, 
        'SWITCH_TRIAL_MEAN': switch_s_mean, 'NON-SWITCH_COST': ns_cost, 'PERCENT_BAD_TRIALS': percent_trials_excluded, 'BAD_ALL': bad_all, 
        'BAD_SWITCH': bad_switch})
        age_real.append(iterator[2])
        depress_real.append(iterator[3])
        gen_switch_cost_real.append(gen_switch_cost)

# convert results from list of dictionaries to a dataframe and save as csv   
results_df = pd.DataFrame(results)
results_df.to_csv(output_data_file, columns=['SUBID', 'AGE', 'DEPRESS', 'GEN_SWITCH_COST', 'ALL_MEAN', 'SWITCH_MEAN', \
                                            'SPEC_SWITCH_COST', 'NON-SWITCH_TRIAL_MEAN', 'SWITCH_TRIAL_MEAN', 'NON-SWITCH_COST', \
                                            'PERCENT_BAD_TRIALS', 'BAD_ALL', 'BAD_SWITCH'], index=False)

## run some analyses

# prepare dataframe of floats
age_real = np.array(age_real).astype(np.float)
depress_real = np.array(depress_real).astype(np.float)
gen_switch_cost_real = np.array(gen_switch_cost_real).astype(np.float)
analysis_df = pd.DataFrame({'age': age_real, 'depress': depress_real, 'gen_switch_cost': gen_switch_cost_real, 
                            'spec_switch_cost': spec_switch_cost_real, 'non_switch_cost': ns_cost_real})

# calculate z scores
analysis_df['gen_abs_z'] = pd.Series(abs(gen_switch_cost_real - np.mean(gen_switch_cost_real)) / np.std(gen_switch_cost_real))

# excluding outliers
analysis_df = analysis_df[analysis_df.gen_abs_z < 3.0]

# evaluating age as a predictor of task measures (simple regression)
slope_gs_a, intercept_gs_a, r_value_gs_a, p_value_gs_a, std_err_gs_a = stats.linregress(analysis_df.age, analysis_df.gen_switch_cost)

# save results to file
f = open(output_analysis_file, 'w')
f.write("Age as a predictor of task measures (simple regression) \n")
f.write('gen_r: ' + str(r_value_gs_a) + ', gen_r_squared: ' + str(r_value_gs_a**2) + ', gen_p: ' + str(p_value_gs_a) + "\n")

# evaluating age and depression status as predictors of task measures (multiple regression)
X_df = pd.DataFrame({'age': age_real, 'depress': depress_real})
X_df = sm.add_constant(X_df)
Y_df_gs = pd.DataFrame({'gen_switch_cost': gen_switch_cost_real})
model_gs = sm.OLS(Y_df_gs, X_df).fit()
results_summary_gs = model_gs.summary().as_text()

# save results to file
f.write("\n")
f.write("Age and depression status as predictors of task measures (multiple regression) \n")
f.write(results_summary_gs + "\n")
f.close()

## generating figures

# general switch cost scatter plot
plt.scatter(analysis_df.age[analysis_df.depress == 0], analysis_df.gen_switch_cost[analysis_df.depress == 0], c = 'b', label = 'Control')
b1, m1 = polyfit(analysis_df.age[analysis_df.depress == 0], analysis_df.gen_switch_cost[analysis_df.depress == 0], 1)
plt.plot(analysis_df.age[analysis_df.depress == 0], b1 + m1 * analysis_df.age[analysis_df.depress == 0], '-', color = 'b', label = '_nolegend_')
plt.scatter(analysis_df.age[analysis_df.depress == 1], analysis_df.gen_switch_cost[analysis_df.depress == 1], c = 'r', label = 'Depressed')
b2, m2 = polyfit(analysis_df.age[analysis_df.depress == 1], analysis_df.gen_switch_cost[analysis_df.depress == 1], 1)
plt.plot(analysis_df.age[analysis_df.depress == 1], b2 + m2 * analysis_df.age[analysis_df.depress == 1], '-', color = 'r', label = '_nolegend_')
plt.legend(loc = 'upper right')
# plt.show()
plt.savefig(output_dir + '/gen_switch_cost_scatter.png', dpi = 200, bbox_inches = 'tight')
plt.close()

# general switch cost histogram
bins = np.linspace(-0.2, 1.2, num = 15)
plt.hist(analysis_df.gen_switch_cost[analysis_df.depress == 0], bins, rwidth = 1, alpha = 0.5, color = 'b', label = 'Control')
plt.hist(analysis_df.gen_switch_cost[analysis_df.depress == 1], bins, rwidth = 1, alpha = 0.5, color = 'r', label = 'Depressed')
plt.legend(loc = 'upper right')
# plt.show()
plt.savefig(output_dir + '/gen_switch_cost_hist.png', dpi = 200, bbox_inches = 'tight')
plt.close()


# ... CODE OMITTED FOR OTHER MEASURES