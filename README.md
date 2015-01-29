# brown

Render Google Chart on server side. (experimental project) It will receive `GET` request & response with png image. With brown, you can easily embed your chart on modern chat apps. (slack, hipchat ...)

# run

make sure you have `node.js`, `phantomjs`

    $ npm install
    $ phantomjs brown.coffee
    
> If you are a docker guy, use [https://registry.hub.docker.com/u/cmfatih/phantomjs/](https://registry.hub.docker.com/u/cmfatih/phantomjs/) 

for `PieChart`, browse

    http://<YOUR_IP>:9500/chart?cht=p&chs=600x400&chd=50,100,300,20,90&chl=a|b|c|d|e&chtt=memory-usage&chco=1f77b4|ff7f0e|2ca02c|d62728|9467bd&chp=2
    
![](http://chitacan.redribbon.io/chart?cht=p&chs=600x400&chd=50,100,300,20,90&chl=a|b|c|d|e&chtt=pie-chart&chco=1f77b4|ff7f0e|2ca02c|d62728|9467bd&chp=2)

for `LineChart`, browse

    http://<YOUR_IP>:9500/chart?cht=lc&chs=600x400&chd=50,100,300,20,400|10,30,20,90,100&chxl=0:|2001|2002|2003|2004|2005|1:|year|sales|expense&chtt=line-chart
    
![](http://chitacan.redribbon.io/chart?cht=lc&chs=600x400&chd=50,100,300,20,400|10,30,20,90,100&chxl=0:|2001|2002|2003|2004|2005|1:|year|sales|expense&chtt=sales)

# TODO

- [ ] support [MetricsGraphics](http://metricsgraphicsjs.org/) ?
- [ ] support [pie chart features](https://google-developers.appspot.com/chart/image/docs/gallery/pie_charts)
- [x] cache generated charts
