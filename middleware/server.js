var argv = require('optimist')
    .usage('Run middleware server.\nUsage: node(mon) $0')
    .boolean('c')
    .alias('c', 'cluster')
    .describe('c', 'Run in cluster mode')
    .alias('p', 'port')
    .describe('p', 'Port')
    .default('p', 3000)
    .argv
;

if (argv.c) {
  var cluster = require('cluster');

  cluster('worker')
    .use(cluster.logger('logs'))
    .use(cluster.pidfiles('pids'))
    .use(cluster.cli())
    .listen(argv.port);  
} else {
  var worker = require('./worker');
  worker.listen(argv.p);
}
