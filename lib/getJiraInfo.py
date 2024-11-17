import pandas
import os
import shutil
from tabulate import tabulate

#Vitesco Technologies Jira 20
COMPONENT_HEAD = "Component/s"
SPENT_HEAD = "Time Spent"
CONV_FACTOR = 3600
COMPONENT = "FOH02"
COLUMS_TO_DISPLAY = ["Summary","Issue key",SPENT_HEAD]
TAB = "\t\t\t\t\t\t\t\t\t\t\t\t"
colors = {
    'black': '\033[30m',
    'red': '\033[31m',
    'green': '\033[32m',
    'yellow': '\033[33m',
    'blue': '\033[34m',
    'magenta': '\033[35m',
    'cyan': '\033[36m',
    'white': '\033[37m',
    'reset': '\033[0m'
}
def main():#.rename(columns={SPENT_HEAD:f"{SPENT_HEAD}Hrs"},inplace=True)
    pandas.set_option('display.max_colwidth', 50)
    jiraCsv = pandas.read_csv("c:/users/uiv06924/downloads/jira.csv")
    jiraCsv[SPENT_HEAD] = jiraCsv[SPENT_HEAD].apply(lambda x: x / CONV_FACTOR)
    jiraCsvFoh02 = jiraCsv[jiraCsv[COMPONENT_HEAD]==COMPONENT]
    jiraCsvFoh02Filtered = jiraCsvFoh02[COLUMS_TO_DISPLAY]
    timeSpendInSecondsColumn = jiraCsvFoh02[SPENT_HEAD]
    timeSpendInHours = timeSpendInSecondsColumn.sum()
    headers = [f"{colors['yellow']}{header}{colors['reset']}" for header in jiraCsvFoh02Filtered.columns]
    print(tabulate(jiraCsvFoh02Filtered, headers=headers, tablefmt='pretty', stralign='center'))
    print(f"{TAB}{colors['yellow']}TOTAL SPENT HOURS: {colors['green']}{timeSpendInHours}{colors['reset']}")

if __name__ == '__main__':
    main()

