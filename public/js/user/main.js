var options = {
	$AutoPlay: true,
	$SlideDuration: 800, 
	$BulletNavigatorOptions: {
		$Class: $JssorBulletNavigator$,
		$ChanceToShow: 2,
		$AutoCenter: 1,
		$SpacingX: 10
	},
	$ArrowNavigatorOptions: {
		$Class: $JssorArrowNavigator$,
		$ChanceToShow: 2,
		$AutoCenter: 2
	}
};
var jssor_slider = new $JssorSlider$('slider_container', options);

function ScaleSlider() {
	var parentWidth = $('#slider_container').parent().width();
	if (parentWidth) {
		jssor_slider.$SetScaleWidth(parentWidth);
	}
	else
		window.setTimeout(ScaleSlider, 30);
}

ScaleSlider();
if (!navigator.userAgent.match(/(iPhone|iPod|iPad|BlackBerry|IEMobile)/)) {
	$(window).bind('resize', ScaleSlider);
}