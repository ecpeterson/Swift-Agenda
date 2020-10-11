
// app/routes/login.js

var User = require('../models/user.js');

module.exports = function(app, passport) {
	// CHECK LOGIN STATUS ======================================================
	app.get('/', function(req, res) {
		if (req.user) {
			return res.json({ loggedIn: "true", id: req.user.id });
		} else {
			return res.json({ loggedIn: "false" });
		}
	});

	// LOGIN ===================================================================
	// process the login form
	app.post('/login', passport.authenticate('local-login', {
		successRedirect : '/',
		failureRedirect : '/login',
		failureFlash : true
	}));

	// SIGNUP ==================================================================
	// process the signup form
	//
	// you may be interested in
	//     http://stackoverflow.com/questions/15711127/express-passport-node-js-error-handling
	// which describes more complicated things you can do with callbacks rather
	// than with redirects.
	app.post('/signup', passport.authenticate('local-signup', {
		successRedirect : '/',
		failureRedirect : '/signup',
		failureFlash : true
	}));

	// LOGOUT ==================================================================
	app.get('/logout', function(req, res) {
		req.logout();
		res.redirect('/');
	});
};
