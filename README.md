# Classifying Wikipedia

Boston University KHC keystone project by Katie Lee, c/o 2022.  Advised by Professor Dan Sussman.

https://ktllee.shinyapps.io/catwiki/


## Organization

### Data Collection
- `README.md` contains directions for collecting data to use with the catwiki app.
- `names.csv` and `additions.csv` allow for input of categories to be pulled.
- `net_pull.py` contains functions for pulling data from Wikipedia's API.
- `collect.py` carries out collection of data from input categories.
- `compress.R` condenses the necessary data.
- `data` (ignored) is a directory for storage of the generated `.csv` files.

### App
The Shiny app in the directory `catwiki` is mostly organized as standard for Shiny apps.  The files `global.R`, `ui.R`, and `server.R` define the app.  The other directories are as follows:

- `data` (ignored) contains the generated `.rds` file from `data_pull` as well as the key of category names in `names.csv`.
- `helpers` contains helper functions needed in the server function.
- `panels` contains pieces of functions needed by the UI function.
- `text` contains `.txt` files necessary for larger sections of text in the UI function.
- `www` contains static files.


## Dependencies

### Python

- requests
- pandas (alias: pd)
- tqdm
- time

### R

- shiny
- shinythemes
- tidyverse
- DT
- igraph
- visNetwork
