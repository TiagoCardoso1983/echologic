(function($){

	/* Do init stuff. */
	$(document).ready(function () {
	  if ($('#echo_connect_search').length > 0) {
	  	loadAvatarHolders();
		initScrollToProfile();
	  }
	});
	
	
	function loadAvatarHolders(){
		$('#connect_results').delegate('.profile.active .avatar_holder', 'click', function(e){
			e.preventDefault();
			$.scrollTo('body', 400, function() {$('#profile_details_container').animate(toggleParams, 500)});
		    $('.profile').removeClass('active');
		});
	}
	
	function initScrollToProfile() {
		if ($('#profile_details_container').is(":visible")) {
			$.scrollTo('#results_anchor', 400);
		}
	}

})(jQuery);