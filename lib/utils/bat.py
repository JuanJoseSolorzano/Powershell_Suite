import os
import sys
import shutil
import pandas
from pygments import highlight
from pygments.lexers import get_lexer_for_filename,get_lexer_by_name
from pygments.formatters import TerminalFormatter,Terminal256Formatter
from pygments.style import Style
from pygments.token import Token
from pygments.lexers import PythonLexer

#Colors:
RED = "\033[31m"
GREEN = "\033[32m"
YELLOW = "\033[33m"
BLUE = "\033[34m"
MAGENTA = "\033[35m"
CYAN = "\033[36m"
GRAYB = "\033[48;5;236m"
RESET = "\033[0m"  # Reset to default color

COLUMNS,_ = shutil.get_terminal_size()
LINE=COLUMNS*"-"
TITLE="%s{0}\n\t%s  FILE: {1}%s\n%s{2}".format(LINE,"{0}",LINE)%(MAGENTA,YELLOW,RESET,MAGENTA)

class MyStyle(Style):
    background_color = "#2e2e2e"  # Dark gray background
    default_style = ""
    
    styles = {
        Token.Comment:'italic #75715e',
        Token.Keyword:'bold #66d9ef',
        Token.Name:'#f8f8f2',
        Token.String:'#e6db74',
        Token.Number:'#ae81ff',
        Token.Operator:'#f92672',
        Token.Function:'#e6db74',
    }

def preview(file:str,lines_per_page=35,lforced=None)->None:
    try:
        file = file.replace('.\\','')
        is_file = True
        # get the highlighted format
        lexer=None
        if not os.path.isfile(file):
            is_file = False
            line = file
        if lforced:
            lexer = get_lexer_by_name(lforced)
        else:
            if is_file:
                lexer = get_lexer_for_filename(file)
                print(TITLE.format(file))
        if not is_file:
            if not lexer:
                lexer = PythonLexer()
            highlighted_line = highlight(line,lexer,Terminal256Formatter(style=MyStyle))
            print(highlighted_line)
            return
        with open(file,'r',encoding='utf-8') as file:
            line_buffer=[]
            for line_number, line in enumerate(file, start=1):
                highlighted_line = highlight(line,lexer,Terminal256Formatter(style=MyStyle))
                line_buffer.append(f"{MAGENTA}{line_number:>4}: {highlighted_line}")
                if len(line_buffer) >= lines_per_page:
                    print("".join(line_buffer), end='')
                    line_buffer.clear()
            if line_buffer:
                print("".join(line_buffer), end='')
            print(f"{RED}<EOF>")
    except Exception as e:
        print(f"Error: {str(e)}")

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python bat.py <filename>")
        sys.exit(1)
    # Pass the filename to the preview function
    file = sys.argv[1]
    l = sys.argv[2] if len(sys.argv) > 2 else None
    preview(file,lforced=l)
    print(f"{MAGENTA}{LINE}")
    print(f"\n{RESET}")
