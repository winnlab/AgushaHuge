import can from'can/'
import _ from 'lodash'
import 'js/app/admin/lib/viewport'

'use strict';

function computedVal (value) {
	if (typeof value === 'function') {
		value = value();
	}
	return value;
};

can.mustache.registerHelper('is', function () {
	var options = arguments[arguments.length - 1],
		comparator = computedVal(arguments[0]),
		result = true;

	for (var i = 1, ln = arguments.length - 1; i < ln; i += 1) {
		if (comparator !== computedVal(arguments[i])) {
			result = false;
			break;
		}
	}

	return result ? options.fn() : options.inverse();
});


can.mustache.registerHelper('isnt', function (a, b, options) {
	var result = computedVal(a) !== computedVal(b);
	return result ? options.fn() : options.inverse();
});

can.mustache.registerHelper('or', function () {
	var options = arguments[arguments.length - 1],
		result = false;

	for (var i = arguments.length - 1; i--; ) {
		if (computedVal(arguments[i])) {
			result = true;
			break;
		}
	}

	return result ? options.fn() : options.inverse();
});

can.mustache.registerHelper('gt', function (a, b, options) {
	return computedVal(a) > computedVal(b)
		? options.fn()
		: options.inverse();
});

can.mustache.registerHelper('plus', function (a, b) {
	return computedVal(a) + computedVal(b);
});

can.mustache.registerHelper('minus', function (a, b) {
	return computedVal(a) - computedVal(b);
});

can.mustache.registerHelper('indexOfInc', function (array, element) {
	return computedVal(array).indexOf(computedVal(element)) + 1;
});

can.mustache.registerHelper('arrFind', function (array, id, findKey, key) {
	var item;
	id = computedVal(id);
	findKey = computedVal(findKey);
	key = computedVal(key);
	array = computedVal(array);
	if (id) {
		item = _.find(array, function (a) {
			return a.attr(findKey) === id;
		});
		if (item) {
			return item.attr(key);
		}
	}
	return '';
});

can.mustache.registerHelper('getArrayObjValue', function (array, index, key) {
	return array() ? array().attr(index() + '.' + key) : '';
});

can.mustache.registerHelper('sortedBy', function (collection, prop, direction, options) {
	if (arguments.length == 3) {
		options = direction;
		direction = false;
	}
	collection = computedVal(collection);
	if (collection && collection.attr('length') && prop) {
		var sorted = _.sortBy(collection, function (member) {
			return member.attr(prop);
		});

		if (direction && direction == 'desc') {
			sorted.reverse();
		}

		return _.map(sorted, function (member, index) {
			return options.fn(options.scope
				.add({'@index': index})
				.add(member)
			);
		}).join('');
	}
});

can.mustache.registerHelper('getBoxName', function (index, options) {
	var classes = ['bg-light-blue', 'bg-red', 'bg-green', 'bg-yellow', 'bg-maroon', 'bg-purple', 'bg-aqua'];
	index = computedVal(index);
	if (!index && index !== 0) {
		index = ~~(Math.random() * classes.length - 1);
	}
	return classes[index % classes.length];
});

can.mustache.registerHelper('wysihtml5', function (index) {
	return function (el) {
		$(el).wysihtml5();
	};
});