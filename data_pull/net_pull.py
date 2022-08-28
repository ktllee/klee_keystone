#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
@author: katie

Functions for setting up a network from a seed Wikipedia category.
"""

# dependencies
import requests     # access API
import pandas as pd     # organize data
from tqdm import tqdm     # progress bar
import time     # time


# find all categories
def allcats(name, depth = -1, monitor = False, prev = None, level = 0):
    ''' takes:
            name - str, an inital category name
            depth (opt) - int, a maximum recursive depth to go to
            monitor (opt) - bool, if true prints level for category delved
            prev (opt) - set, categories to not delve [do not use]
            level (opt) - int, current level of recursion [do not use]
        
        returns: 
            cats - list of all unique category names within a parent category,
            pages - dataframe with pages and associated categories
            net - network of categories
        
        finds all subcategories to a category, recursively
        
        notes: 
            negative depth finds all possible subcategories
            circular connections are accounted for (won't break function)
    '''
    
    ###### checking inputs
    
    # check prev
    if not any((isinstance(prev, list), prev == None)):
        raise TypeError('prev must be a list')
    elif prev == None:
        prev = []
    
        # check name type
        if not isinstance(name, str):
            raise TypeError('name should be a string')
            
        # check name namespace
        if name[:9] != 'Category:':
            raise ValueError('page must be a category')
        
        # check name existence
        url = 'https://en.wikipedia.org/wiki/' + name
        if not requests.head(url).ok:
            raise ValueError('page does not exist')    
    
    # check depth and level
    if not (isinstance(depth, int) and isinstance(level, int)):
        raise TypeError('depth and level must be ints')
        
    # check monitor
    if not isinstance(monitor, bool):
        raise TypeError('monitor must be a bool')
    elif monitor:
        print(f"{level}.", end = '')
    
    # start timer
    if level == 0:
        start = time.time()
    
    ###### finding pages        
    
    # setting query parameters
    s = requests.Session()
    wiki = "https://en.wikipedia.org/w/api.php"
    params = {
        "action": "query",
        "cmtitle": name,
        "cmtype": "page",
        "cmlimit": "max",
        "list": "categorymembers",
        "format": "json"}
    
    # gathering pages
    while True:
        try:
            r = s.get(url = wiki, params = params, timeout = 20)
            pull = r.json()
        except Exception as e:
            print(time.time() - start, name, 'cats\n', e,
                  file = open('net_errors.txt', 'a'))
            input('check for errors.')
        else:
            break
        
    subpages = [x['title'] for x in pull['query']['categorymembers']]
    
    # continue if query limit is reached
    while 'continue' in pull:
        params = {
            "action": "query",
            "continue": pull['continue']['continue'],
            "cmcontinue": pull['continue']['cmcontinue'],
            "cmtitle": name,
            "cmtype": "page",
            "cmlimit": "max",
            "list": "categorymembers",
            "format": "json"}
        
        while True:
            try:
                r = s.get(url = wiki, params = params, timeout = 20)
                pull = r.json()
            except Exception as e:
                print(time.time() - start, name, 'cats\n', e,
                      file = open('net_errors.txt', 'a'))
                input('check for errors.')
            else:
                break
            
        subpages.extend([x['title'] for x in pull['query']['categorymembers']])
    
    # assigning category to pages
    finalpages = pd.DataFrame({'title': subpages})
    finalpages['cat'] = name
    
    # if level is maxed out
    if level == depth:
        return {'cats': [], 'pages': finalpages,
                'catnet': pd.DataFrame(columns = ['to', 'from'])}
        
    ###### finding subcategories
        
    # setting query parameters
    params = {
        "action": "query",
        "cmtitle": name,
        "cmtype": "subcat",
        "cmlimit": "max",
        "list": "categorymembers",
        "format": "json"}
    
    # gathering subcategories
    while True:
        try:
            r = s.get(url = wiki, params = params, timeout = 20)
            pull = r.json()
        except Exception as e:
            print(time.time() - start, name, 'cats\n', e,
                  file = open('net_errors.txt', 'a'))
            input('check for errors.')
        else:
            break
        
    subcats = [x['title'] for x in pull['query']['categorymembers']]
    
    # continue if query limit is reached
    while 'continue' in pull:
        params = {
            "action": "query",
            "continue": pull['continue']['continue'],
            "cmcontinue": pull['continue']['cmcontinue'],
            "cmtitle": name,
            "cmtype": "subcat",
            "cmlimit": "max",
            "list": "categorymembers",
            "format": "json"}
        
        while True:
            try:
                r = s.get(url = wiki, params = params, timeout = 20)
                pull = r.json()
            except Exception as e:
                print(time.time() - start, name, 'cats\n', e,
                      file = open('net_errors.txt', 'a'))
                input('check for errors.')
            else:
                break
        
        subcats.extend([x['title'] for x in pull['query']['categorymembers']])
        
    net = pd.DataFrame({'to': subcats, 'from': name})
    
    ###### recursion
    
    finalcats = subcats.copy()
    
    # recurse
    for cat in subcats:
        if cat not in prev:
            lower = allcats(cat, depth, monitor, subcats + prev, level + 1)
            prev.extend(lower['cats'])
            finalcats.extend(lower['cats'])
            finalpages = pd.concat([finalpages, lower['pages']],
                                   ignore_index = True)
            net = pd.concat([net, lower['catnet']], ignore_index = True)
    
    # condensing final results
    final = {'cats': finalcats,
             'pages': finalpages,
             'catnet': net}
    
    # things to only do for true final result
    if level == 0:
        finalpages = finalpages.groupby('title').agg(','.join).reset_index()
        final = {'pages': finalpages,
                 'catnet': net}
        
        # timing
        elapsed = time.time() - start
        m, s = divmod(elapsed, 60)
        h, m = divmod(m, 60)
        m = round(m)
        h = round(h)
        print(f"category finding took {h}:{m}:{s}")
        
    return final


def datacats(name, depth = -1, monitor = False):
    ''' takes:
            name - str, an inital category name
            depth (opt) - int, a maximum recursive depth to go to
            monitor (opt) - bool, if true prints level for category delved
        
        returns: 
            cats - list of all unique category names within a parent category,
            pages - dataframe with pages and associated categories
            catnet - network of categories
            pagenet - network of pages
        
        finds network of pages for all pages in a category tree to depth
        
        note: negative depth finds all possible subcategories
    '''
    
    ###### pages and categories
    print('finding categories...')
    
    # call cat finding function
    results = allcats(name, depth, monitor)
    pages = results['pages'].title.to_list()
    
    ###### finding page data
    print('\ngathering page data...')
    start = time.time()
    
    # cutting up list of pages and initializing lists
    chunks = [pages[x:(x + 50)] for x in range(0, len(pages), 50)]
    names = []
    assessments = []
    importances = []
    chars = []
    pagefrom = []
    pageto = []
    
    # iterating over chunks
    for chunk in tqdm(chunks):
        
        # setting query parameters
        s = requests.Session()
        wiki = "https://en.wikipedia.org/w/api.php"
        params = {
            "action": "query",
            "titles": '|'.join(chunk),
            "prop": "pageassessments|revisions|categories",
            "palimit": "max",
            "rvslots": "*",
            "rvprop": "content",
            "cllimit": "max",
            "format": "json"}
        
        # calling api
        while True:
            try:
                r = s.get(url = wiki, params = params, timeout = 20)
                pull = r.json()
            except Exception as e:
                print(time.time() - start, name, 'page data\n', e,
                      file = open('net_errors.txt', 'a'))
                input('check for errors.')
            else:
                break
        
        # separating and gathering data
        cut = pull['query']['pages']
        for page in cut:
            
            # title
            names.append(cut[page]['title'])
            
            # page assessments
            pa = 'pageassessments'
            if pa in cut[page]:
                assessment = ''
                importance = ''
                for proj in cut[page][pa]:
                    assessment += (cut[page][pa][proj]['class'] + ',')
                    importance += (cut[page][pa][proj]['importance'] + ',')
                assessments.append(assessment)
                importances.append(importance)
            else:
                assessments.append('')
                importances.append('')
                
            # number of characters
            rev = 'revisions'
            if rev in cut[page]:
                chars.append(len(cut[page][rev][0]['slots']['main']['*']))
            else:
                chars.append('')
                
        # in-group links
        for group in chunks:
            
            # setting query parameters
            s = requests.Session()
            params = {
                "action": "query",
                "titles": '|'.join(chunk),
                "prop": "links",
                "pllimit": "max",
                "pltitles": '|'.join(group),
                "format": "json"}
            
            # gathering links
            while True:
                try:
                    r = s.get(url = wiki, params = params, timeout = 20)
                    pull = r.json()
                except Exception as e:
                    print(time.time() - start, name, 'page links\n', e,
                          file = open('net_errors.txt', 'a'))
                    input('check for errors.')
                else:
                    break
                
            cut = pull['query']['pages']
            for page in cut:
                if 'links' in cut[page]:
                    for link in cut[page]['links']:
                        pagefrom.append(cut[page]['title'])
                        pageto.append(link['title'])
                        
            # monitor
            if monitor:
                print('.', end = '')
    
    ###### condensing final results
     
    pagedata = pd.DataFrame({'title': names,
                             'assess': assessments,
                             'imprtn': importances,
                             'nchar': chars})
    final = pd.merge(results['pages'], pagedata, on = 'title')
    results['pages'] = final
    
    pagenet = pd.DataFrame({'to': pageto, 'from': pagefrom})
    results['pagenet'] = pagenet
    
    elapsed = time.time() - start
    m, s = divmod(elapsed, 60)
    h, m = divmod(m, 60)
    m = round(m)
    h = round(h)
    print(f"\ncollecting data took {h}:{m}:{s}")
    
    return results
    

# helper for saving    
def savenet(item, name):
    item['catnet'].to_csv(f"data/{name}_catedge.csv", index = False)
    item['pages'].to_csv(f"data/{name}_pagnode.csv", index = False)
    item['pagenet'].to_csv(f"data/{name}_pagedge.csv", index = False)
    return