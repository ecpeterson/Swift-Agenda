
// app/routes/todo.js

var Todo = require('../models/todo.js');
var User = require('../models/user.js');

module.exports = function(app) {
	// CREATE NEW TODO ITEM ====================================================
	app.post('/todo/new', app.isLoggedIn, function(req, res) {
		// assemble new bulb object
		var todo = new Todo();
		todo.ownerId = req.user._id;

		// all other fields come from the request
		todo.text = req.body.text;
		todo.complete_p = req.body.complete_p;
		todo.repeat_p = req.body.repeat_p;
		todo.frequency = req.body.frequency;
		todo.date = req.body.date;
		todo.priority = req.body.priority;

		// create new record in database
		todo.save(function(err) {
			if (err)
				return res.json({ msg : err });

			res.json(todo);
		});
	});

	// EDIT EXISTING TODO ======================================================
	app.put('/todo/:id', app.isLoggedIn, function(req, res) {
		// look up todo object in the database
		Todo.findById(req.params.id, function(err, todo) {
			if (err || !todo)
				return res.json({ msg : err });

			todo.hasAccess(req.user._id, function(ans) {
				if (!ans)
					return res.json({ msg : "Access forbidden." });

				todo.text = req.body.text;
				todo.complete_p = req.body.complete_p;
				todo.repeat_p = req.body.repeat_p;
				todo.frequency = req.body.frequency;
				todo.date = req.body.date;
				todo.priority = red.body.priority;

                return todo.save(function(err) {
                	if (err)
                		return res.json({ msg : err });

                	return res.json(todo);
                });
			});
		});
	});

	// DELETE TODO =============================================================
	app.delete('/todo/:id', app.isLoggedIn, function(req, res) {
		// look up todo object in the database
		Todo.findById(req.params.id, function(err, todo) {
			if (err || !todo)
				return res.json({ msg : err });

			todo.hasAccess(req.user._id, function(ans) {
				if (!ans)
					return res.json({ msg : "Access forbidden." });

				Todo.remove({ _id : req.params.id }, function(err) {
					if (err)
						return res.json({ msg: err });
					return res.json({});
				});
			});
		});
	});

	// LIST TODOS ==============================================================
	app.get('/todo', app.isLoggedIn, function(req, res) {
		function aux(err) {
			if (err) {
				return res.json({ msg : err });
			}

			// look up all items associated with this user
			Todo.find({ ownerId: req.user._id }, function(err, todos) {
				if (err)
					return res.json({ msg : err });

				for (i = 0; i < todos.length; i++) {
					todo = todos[i];
					if ((todo.date < req.body.date) && todo.complete_p)
						return Todo.forward(todo, aux);
				}

				return res.json(todos);
			});
		};

		aux(false);
	});
}
