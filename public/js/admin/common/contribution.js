$(function(){
	var Controller = function(page, items){
		this.page = page || 1;
		this.items = items || __contributions;
		this.limit = 20;
		this.pagesWrapper = '#pager';
		this.itemsWrapper = '.t-itemWrap'

		if(__contributions) {
			delete __contributions
		};

		this.drawPagination();
	};

	Controller.prototype.drawPagination = function() {
		var html = '<li class="t-first"><a href="#">&laquo;</a></li>';
		var pageCount = Math.ceil(this.items.length / this.limit);
		this.pageCount = pageCount;

		for(var i = 1; i <= pageCount; i++) {
			html += '<li class="t-page" data-page="' + i 
				 + '"><a href="#">' + i + '</a></li>';
		}
		html += '<li class="t-last"><a href="#">&raquo;</a></li>';
		$(this.pagesWrapper).html(html);
		$(this.pagesWrapper + ' li.t-page').eq(this.page - 1).addClass('active');

		var self = this;
		$('.t-page').on('click', function(){
			el = $(this);
			if(el.hasClass('.active')) {
				return;
			}

			$('.t-page.active').removeClass('active');
			el.addClass('active');
			self.show(el.data('page'));
		});

		$('.t-first').on('click', function(){
			$('.t-page.active').removeClass('active');
			$('.t-page:first').addClass('active');

			self.show(1);
		});

		$('.t-last').on('click', function(){
			$('.t-page.active').removeClass('active');
			$('.t-page:last').addClass('active');

			self.show(self.pageCount);
		});
	};

	Controller.prototype.loadSingleTemplate = function(item) {
		var r = '<a href="contributions/edit/' + item._id + '">'
			+ '<div class="contributionBox">'
			+ '<div class="cb-body"><img src="/img/' 
			+ (item.background || 'no-photo.png') + '"/></div>'
			+ '<div class="cb-author" title="' + item.authorName + '">'
			+ '<img src="';

		if(item.author) {
			r += '/img/no-photo.png'
		} else {
			r += '/img/user.png'
		}

		r += '"/></div><div class="cb-title">' + item.title
			+ '</div><div class="cb-footer">'
			+ '<span class="glyphicon glyphicon-eye-open">' + item.view_count + '</span>'
			+ '<span class="glyphicon glyphicon-comment">' + item.comment_count + '</span>'
			+ '<span class="glyphicon glyphicon-heart">' + item.like_count + '</span>'
			+ '</div></div></a> ';

		return r;
	};

	Controller.prototype.show = function(page, redrawPagination) {
		this.page = page || this.page;
		var sliced = this.items.slice((this.page - 1) * this.limit, this.limit * this.page);

		var html = '';
		for(var i = 0, len = sliced.length; i < len; i++) {
			html += this.loadSingleTemplate(sliced[i]);
		}

		if(redrawPagination) {
			this.drawPagination();
		}

		$(this.itemsWrapper).html(html);
	};

	Controller.prototype.reloadItems = function(items) {
		this.items = items || this.items;
		this.show(1, true);
	}

	var controller = new Controller;

	controller.show(null, true);

	var chosenOpts = {
		width: '18%',
		no_results_text: 'Ничего не найдено'
	};
	$('.t-years').chosen(chosenOpts);
	$('.t-theme').chosen(chosenOpts);
	$('.t-author').chosen(chosenOpts);
	$('.t-sort').chosen(chosenOpts);
	$('.t-tags').chosen($.extend(chosenOpts, {
		display_selected_options: false,
		width: '84%'
	}));

	$('.chzn').on('change', function(){
		var years = $('.t-years').val(),
			theme = $('.t-theme').val(),
			author = $('.t-author').val(),
			tags = $('.t-tags').val(),
			sortId = $('.t-sort').val(),
			sField = null,
			sVal = -1;

		switch(parseInt(sortId)) {
			case 1:
				sField = 'view_count';
				sVal = -1;
				break;
			case 2:
				sField = 'view_count';
				sVal = 1;
				break;
			case 3:
				sField = 'like_count';
				sVal = -1;
				break;
			case 4:
				sField = 'like_count';
				sVal = 1;
				break;
			case 5:
				sField = 'comment_count';
				sVal = 1;
				break;
			case 6:
				sField = 'comment_count';
				sVal = 1;
				break;
			case 7:
				sField = 'title';
				sVal = -1;
				break;
			case 8:
				sField = 'title';
				sVal = 1;
				break;
		}

		$.post('contributions/sort', {
			years: years,
			theme: theme,
			author: author,
			tags: tags,
			sortField: sField,
			sortValue: sVal
		}, function(response) {
			controller.reloadItems(response);
		});

	});

	$('.t-years').data('chosen').allow_single_deselect = true;
	$('.t-theme').data('chosen').allow_single_deselect = true;
	$('.t-author').data('chosen').allow_single_deselect = true;
	$('.t-sort').data('chosen').allow_single_deselect = true;
});