exports.setupRoutes = function (server, pre, post) {
  server.get(null, '/your/:param/:id', pre, function(req, res, next) {
    res.send(200, {
      id: req.uriParams.id,
      message: 'You sent ' + req.uriParams.param,
      sent: req.params
    });
    return next();
  }, post);
}