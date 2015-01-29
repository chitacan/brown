# brown

server side google chart renderer. (experimental project)

# run

install `node.js`, `phantomjs`

    $ npm install
    $ phantomjs brown.coffee

for `PieChart`, browse

    http://<YOUR_IP>:<PORT>/chart?cht=p&chs=600x400&chd=50,100,300,20,90&chl=a|b|c|d|e&chtt=memory-usage&chco=1f77b4|ff7f0e|2ca02c|d62728|9467bd&chp=2

for `LineChart`, browse

    http://<YOUR_IP>:<PORT>/chart?cht=lc&chs=600x400&chd=50,100,300,20,400|10,30,20,90,100&chxl=0:|2001|2002|2003|2004|2005|1:|year|sales|expense&chtt=memory-usage&chco=1f77b4|ff7f0e|2ca02c|d62728|9467bd

# TODO

- [ ] support [pie chart features](https://google-developers.appspot.com/chart/image/docs/gallery/pie_charts)
- [x] cache generated charts
