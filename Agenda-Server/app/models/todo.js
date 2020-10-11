
// app/models/todo.js

var mongoose = require('mongoose');

// define the schema
var todoSchema = mongoose.Schema({
	ownerId : String,
	text: String,
	complete_p: Boolean,
	repeat_p: String,
	frequency: Number,
	date: Number, // gregorian date as (year * 15 + month) * 35 + day
	priority: Number,
});

// METHODS =====================================================================

todoSchema.methods.hasAccess = function(user_id, callback) {
	return callback(this.ownerId == user_id);
};

var Todo = mongoose.model('Todo', todoSchema);

Todo.forward = function(todo, callback) {
	function del() {
		Todo.remove({ _id : todo._id }, function(err) {
			if (err)
				return callback(err);
			return callback(false);
		});
	}

	// do we need to repeat?
	if (todo.repeat_p == "never") {
		return del();
	}

	// yes, we do.
	var newTodo = new Todo();
	
	newTodo.ownerId = todo.ownerId;
	newTodo.text = todo.text;
	newTodo.complete_p = false;
	newTodo.repeat_p = todo.repeat_p;
	newTodo.frequency = todo.frequency;
	newTodo.priority = todo.priority;

	// IMPORTANT NOTE: MONTHS ARE ZERO-INDEXED IN JS'S DATE
	day = todo.date % 35;
	month = (todo.date - day) / 35 % 15;
	year = (todo.date - day - 35 * month) / (35 * 15);

	if (todo.repeat_p == "daily") {
		day += todo.frequency;
	} else if (todo.repeat_p == "weekly") {
		day += 7 * todo.frequency;
	} else if (todo.repeat_p == "monthly") {
		month += todo.frequency;
	} else if (todo.repeat_p == "yearly") {
		year += todo.frequency;
	} else {
		return callback("Unknown repeat_p value: " + todo.repeat_p);
	}

	// let the Date object do the normalization heavy lifting
	shiftedDate = new Date(year, month - 1, day);
	day = shiftedDate.getDate();
	month = shiftedDate.getMonth() + 1;
	year = shiftedDate.getYear() + 1900;

	newTodo.date = (year * 15 + month) * 35 + day;

	// create new record in database
	newTodo.save(function(err) {
		if (err)
			return callback(err);

		// and continue
		return del();
	});
};

module.exports = Todo;
