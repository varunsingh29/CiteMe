import requests
from bs4 import BeautifulSoup
with open('urls.txt') as inp:
    for line in inp:
        print(line)
        source = requests.get(line)
        soup = BeautifulSoup(source.content,'html.parser')
        text = soup.get_text()
        print (text)
