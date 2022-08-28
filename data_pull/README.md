# Pulling data from the Wikipedia API

To gather the data needed to run the `catwiki` app, follow these steps:

1. Input the desired seed nicknames (`seed`), category names (`title`), and max depths (`depth`) in `names.csv`.  A depth of 3 for each midsize category (e.g. Air pollution) is recommended.  Note that category names should be input without the 'Category:' prefix (e.g. 'Air pollution', not 'Category:Air pollution'), and should be exact (e.g. 'Air pollution' not 'air pollution' or 'Air_Pollution').

2. Make a copy of `names.csv` called `additions.csv`.

3. Run `collect.py`.  Expect it to take a while, especially for larger categories.  Monitor the progess bar.  If the `check for errors.` prompt appears, check the generated file `net_errors.txt` for the error log.  If the error is a timeout error\*, just wait for a while then input anything to dismiss the error and restart the code.

4. Run `compress.R` to generate `nets.rds`.

5. Move `nets.rds` into `catwiki/data` directory.  `names.csv` must also be updated in the `catwiki/data` directory.

To append data to existing data, ensure that the existing data is in the `data` directory, then follow these alternate steps 1 and 2.

1.  Ensure that `names.csv` contains all seed nicknames, category names, and max depths.  This includes those for both existing data and data to be added.

2. Make a copy of `names.csv` called `additions.csv`.  Delete entries corresponding to existing data from `additions.csv`.  Only seeds to be added should be in `additions.csv`.

Then, follow the rest of the steps as above.

\* Frequent timeout errors sometimes result from server-side problems.  These might last for days or until the problems on Wikipedia's end are resolved.  This type of error occasionally also shows up as a key error in `cut = pull['query']['pages']`.  Unfortunately, the collection must be restarted in the case of a key error, though such an error should be very rare.