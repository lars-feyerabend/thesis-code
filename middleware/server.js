var cluster = require('cluster');

cluster('worker')
  .use(cluster.logger('logs'))
  .use(cluster.pidfiles('pids'))
  .use(cluster.cli())
  .listen(3000);