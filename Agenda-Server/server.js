
//
// server.js
//
// toplevel executable
//

// SET UP =====================================================================
var express = require('express'),
    path = require('path'),
    app = express(),
    port = process.env.PORT || 8081,
    ssl_port = process.env.SSL_PORT || 8082,
    mongoose = require('mongoose'),
    passport = require('passport'),
    flash = require('connect-flash'),
    https = require('https'),
    fs = require('fs');

var morgan = require('morgan'),
    cookieParser = require('cookie-parser'),
    bodyParser = require('body-parser'),
    session = require('express-session');

var configDB = require('./config/database.js');
var configPASSPORT = require('./config/passport.js');

// CONFIGURATION ==============================================================

// ssl options
ssl_options = {
  key: fs.readFileSync("config/ssl/my-site-key.pem"),
  cert: fs.readFileSync("config/ssl/chain.pem")
};

// connect to the database
mongoose.connect(configDB.url);

// pass the passport object in for configuration
require('./app/misc/passport')(app, passport);

app.use(morgan('[:date[web]] :remote-addr :method :url :status :response-time ms - :res[content-length]'));  // log a lot
app.use(cookieParser()); // used for auth
app.use(bodyParser.json());   // used to read info from forms
app.use(bodyParser.urlencoded({extended: true}));
app.use(express.static(path.join(__dirname, 'public'))); // permit static files

// secret used by passport
app.use(session({
	secret : configPASSPORT.secret
}));
app.use(passport.initialize());
app.use(passport.session()); // this gives persistent login sessions
app.use(flash()); // "use connect-flash for flash messages stored in session"

// ROUTES =====================================================================

require('./app/routes/login.js')(app, passport);
require('./app/routes/todo.js')(app);

// LAUNCH =====================================================================

app.listen(port);
https.createServer(ssl_options, app).listen(ssl_port);
console.log('Now listening on http port ' + port + ', https port ' + ssl_port + '.');
