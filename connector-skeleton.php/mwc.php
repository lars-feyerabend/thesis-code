<?php
# **Connector Skeleton**
#
# This file provides a skeleton for inclusion in an e-test service
# Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod 
# tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, 
# quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo 
# consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse 
# cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat 
# non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.

# include framework phar
require_once __DIR__.'/silex.phar'; 
$app = new Silex\Application(); 

# `before` – This will get called before processing the request, so it's a good
# place for database setup etc.
$app->before(function() {
  $app['db'] = new PDO('mysql:dbname=mydb');
});


### hello world route
$app->get('/hello/{name}', function($name) use($app) { 
    return 'Hello '.$app->escape($name); 
}); 


### Test Resources



### Attempt Resources



### User Resources



### Item Resources




# let's run this shit
$app->run();