(function($) {

  $.fn.statementForm = function(currentSettings) {

    $.fn.statementForm.defaults = {
      'animation_speed': 500,
      'taggableClass' : 'taggable'
    };

    // Merging settings with defaults
    var settings = $.extend({}, $.fn.statementForm.defaults, currentSettings);

    return this.each(function() {
	    // Creating and binding the statement form API
	    var elem = $(this), statementFormApi = elem.data('statementFormApi');
	    if (statementFormApi) {
	      statementFormApi.reinitialise();
	    } else {
	      statementFormApi = new StatementForm(elem);
	      elem.data('statementFormApi', statementFormApi);
	    }
		});


    /******************************/
    /* The statement form handler */
    /******************************/

    function StatementForm(form) {
			var title = form.find('.statement_title input');
			var type = form.attr('id').match(/[^new_]\w+/)[0];
			var text;
			var language_combo;
			var chosenLanguage = form.find('select.language_combo');
			var statementLinked = form.find('input.statement_id');
			var auto_complete_button;
      var linking_messages;
			
			initialise();

			function initialise() {

				loadRTEEditor();

        // New Statement Form Helpers
        if (form.hasClass('new')) {
					language_combo = form.find('.statement_language select');
          loadDefaultText();
          initFormCancelButton();
					initAutoCompleteTitle();
					handleContentChange();
					unlinkStatement();
        }

        // Taggable Form Helpers
        if (form.hasClass(settings['taggableClass'])) {
          form.taggable();
        }
			}

			/*
       * Loads the Rich Text Editor for the statement text.
       */
      function loadRTEEditor() {
				textArea = form.find('textarea.rte_doc, textarea.rte_tr_doc');
				if (!isMobileDevice()) {
					var defaultText = textArea.data('default');
					var url = 'http://' + window.location.host + '/stylesheets/';
					
					textArea.rte({
						css: ['jquery.rte.css'],
						base_url: url,
						frame_class: 'wysiwyg',
						controls_rte: rte_toolbar,
						controls_html: html_toolbar
					});
					form.find('.focus').focus();
					
					// The default placeholder text
					form.find('iframe').attr('data-default', defaultText);
					
					text = $(form.find('iframe.rte_doc').contents().get(0)).find('body');
				} else {
          text = textArea;					
				}
      }


			/*
       * Loads the form's default texts for title, text and tags.
       */
			function loadDefaultText() {
        if (!form.hasClass('new')) {return;}

        form.placeholder();

      }
      
			/*
       * Handles Cancel Button click on new statement forms.
       */
      function initFormCancelButton() {
        var cancelButton = form.find('.buttons a.cancel');
        if ($.fragment().sids) {
          var sids = $.fragment().sids;
          var new_sids = sids.split(",");
          var path = "/" + new_sids[new_sids.length-1];
          new_sids.pop();
					
					var bids = $.fragment().bids;
					var bids = bids ? bids.split(',') : [];
					var current_bids = $('#breadcrumbs').data('breadcrumbApi').getBreadcrumbStack(null);

					var i = -1;
					$.map(bids, function(a, index){
						if($.inArray(a, current_bids) == -1) {
							i = index;
							return false;
						}
					});
					
					var bids_to_load = i > -1 ? bids.splice(i, bids.length) : [];
					
          cancelButton.addClass("ajax");
          cancelButton.attr('href', $.queryString(cancelButton.attr('href').replace(/\/\d+/, path), {
            "sids": new_sids.join(","),
            "bids": bids_to_load.join(','),
						"origin": $.fragment().origin
          }));
        }
      }

      /**********************/
      /* Statement Linking  */
      /**********************/

      /*
       * updates the auto complete button with css classes and a new label
       */
      function toggleAutoCompleteButton(to_add, to_remove) {
				auto_complete_button.addClass(to_add).removeClass(to_remove).text(linking_messages[to_add]);
			}
			
			
			/*
       * turns the auto complete button green and with the label 'linked'
       */
			function activateAutoCompleteButton() {
				toggleAutoCompleteButton('on','off');
			}
			
			/*
       * turns the auto complete button grey and with the label 'link'
       */
			function deactivateAutoCompleteButton() {
				toggleAutoCompleteButton('off','on');
			}

      /*
       * initializes the whole title auto completion behaviour
       */
      function initAutoCompleteTitle() {

        // gets the auto complete button				
				auto_complete_button = form.find('.header .auto_complete')
				
				// loads the labels 
				linking_messages = {
					'on' : auto_complete_button.attr('linking_on'),
					'off': auto_complete_button.attr('linking_off')
				}
				
				auto_complete_button.removeAttr('linking_on').removeAttr('linking_off');
				
				
				// initializes the autocompletion plugin 
				var auto_complete_api = title.autocompletes('../../statements/auto_complete_for_statement_title',
							                    {
															   	minChars: 100,
																	selectFirst: false,
																	multipleSeparator: "",
																	extraParams: {
																		code: function(){ return chosenLanguage.val(); },
																	  type: type
																	}
												        });
		    
				// handles the selection of an auto completion results entry
				title.result(function(evt, data, formatted) {
					if (data) {
				  	linkStatement(data[1]);
				  }
				});

        // what happens when i click the auto completion button
        auto_complete_button.bind('click', function(){
          if ($(this).hasClass('on')) {
            // TODO: Right now, nothing happens. But wouldn't it be better to just unlink the statement? 
            // (the visual elements (text, tags...) would remain, just the statement id reference would be lost.
            // this way, we could unlink a wrongly unlinked statement and link it again
            // unlinkStatement();
          }
          else 
          if ($(this).hasClass('off')) {
            title.search();
          }
          
        });
				
			}
			
			
			/*
       * given a statement Id, gets the statement remotely and fills the form with the given data
       */
			function linkStatement(statementId) {
				
				var path = '../../statements/link_statement/' + statementId;
				path = $.queryString(path, {
					"code" : chosenLanguage.val()
				});
				$.getJSON(path, function(data) {
					var statementText = data['text'];
					var statementTags = data['tags'];
					var statementState = data['editorial_state'];

          // disable language combo
          language_combo.attr('disabled', true);
				
				  // fill in summary text	
					if(text && text.is('textarea')) {
						text.val(statementText);
					} else {
						text.empty().text(statementText).click().blur();
					}
					
					// fill in tags
					if (form.hasClass(settings['taggableClass'])) {
				  	form.data('taggableApi').addTags(statementTags);
				  }
					
					// check right editorial state
					$('input:radio[value=' + statementState + ']').attr('checked', true);
					
										
					// activate auto complete button
					activateAutoCompleteButton();
					
					form.addClass('linked');
					
					//TODO: Not working when text is inside the iframe!!!
					if (!isMobileDevice()) {
				  	text.addClass('linked');
				  }
					
					// link statement Id
          statementLinked.val(statementId);

				});
			}
			
			/*
       * unlink the previously linked statement (delete statement Id field and deactivate auto completion button
       */
			function unlinkStatement()
			{
				statementLinked.val('');
        deactivateAutoCompleteButton();
				form.removeClass('linked');
				
				// disable language combo
        language_combo.removeAttr('disabled');
				
				//TODO: Not working when text is inside the iframe!!!
				if (!isMobileDevice()) {
          text.removeClass('linked');
        }
			}
		
			
			/*
       * handles the event of writing new content in one of the fields (in the case, has to unlink a previously unlinked statement)
       */
			function handleContentChange() {
				// title
				title.bind('change', function(){
					if (statementLinked.val()) {
              unlinkStatement();
            }
				});
				
				// text
				if (text && text.is('textarea')) {
		      text.bind('change', function(){
						if (statementLinked.val()) {
							unlinkStatement();
						}
					});
				} else {
					text.bind('DOMSubtreeModified', function(){
						if (statementLinked.val() && text && text.html().length > 0) {
							unlinkStatement();
						}
					});
				}
			}

			// Public API functions
			$.extend(this,
      {
        reinitialise: function()
        {
          initialise();
        }
			});

		}

  };

})(jQuery);