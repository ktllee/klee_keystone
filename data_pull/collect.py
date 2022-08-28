#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
@author: katie

Run to collect data.
"""

from net_pull import *

# read data from additions
names = pd.read_csv('additions.csv')

# convert to lists for easier access
seeds = names.seed.tolist()
titles = names.title.tolist()
depths = names.depth.tolist()

# append prefix
titles = ['Category:' + x for x in titles]

# collecting data
for i in range(len(seeds)):
    
    # access and organize data from API
    results = datacats(titles[i], depth = depths[i])
    
    # save to data folder in directory
    savenet(results, seeds[i])
    
    # rest between categories to prevent overloading API
    time.sleep(120)