define([
	'canjs',
    'underscore',
	'lib/viewport',
	'modules/tales/taleConfig'
],
	function (can, _, viewport, taleConfig) {

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

		can.mustache.registerHelper('make3Col', function (index) {
			return (index() + 1) % 3 === 0 ? '<div class="clearfix"></div>' : '';
		});

		/**
		 * TALES HELPERS
		 */

		can.mustache.registerHelper('getReplicaTail', function (options) {
			var hero = options.context,
				heroTop = hero.attr('top'),
				heroLeft = hero.attr('left'),
				sizePrefix = heroTop > taleConfig.firstPlanTop ? 'fg' : 'bg',
				heroSize = taleConfig.heroSize,
				heroWidth = heroSize[sizePrefix + 'Width'],
				heroHeight = heroSize[sizePrefix + 'Height'],
				replicaWidth = heroSize.replWidth,
				replicaHeight = heroSize.replHeight,
				replicaClass = '';

			if ((heroLeft + (heroWidth - replicaWidth) / 2) > hero.attr('replica.left')) {
				replicaClass += 'L';
			} else {
				replicaClass += 'R';
			}

			if ((heroTop + (heroHeight - replicaHeight) / 2) > hero.attr('replica.top')) {
				replicaClass += 'T';
			} else {
				replicaClass += 'B';
			}

			return replicaClass;
		});

		can.mustache.registerHelper('heroPlan', function (options) {
			return options.context.attr('top') > taleConfig.firstPlanTop
				? 'firstPlan'
				: 'secondPlan';
		});

		can.mustache.registerHelper('talePosition', function (size) {
			var left = (viewport.getViewportWidth() - taleConfig.taleSize.width) / 2,
				top = (viewport.getViewportHeight() - taleConfig.taleSize.height) / 2;

			return 'left: ' + left + 'px; top: ' + top + 'px';;
		});

	}
);
