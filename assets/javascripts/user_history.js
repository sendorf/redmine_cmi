$(document).ready(function(){
	// Not allow modify date inputs manually (only with calendar)
	$(document).on('focus','input.hasDatepicker',function(){
		$(this).blur();
	});

	// Show input fields when click on edit icon
	$(document).on('click', '.icon-edit', function(){
		row = $(this).parent().parent();

		$.each($('td.editable',row), function(index,cell){
			span_to_input($('span', this));
		});

		edit_to_save($(this));
	});

	// Save row data when click on save icon
	$(document).on('click', '.icon-save', function(){
		/*
		row = $(this).parent().parent();

		$.ajax({
			url:'/history_user_profile/edit',
			data: {at_present: $('input[name=at_present]').is(':checked'), history_user_profile: {id: $(row).attr('row_id'), user_id: user_id, profile: $('select[name=profile]').val(), created_on: $('input[name=created_on]').val(), finished_on: $('input[name=finished_on]').val()}},
			type: 'POST'
		});

		$.each($('td.editable',row), function(index,cell){
			input_to_span($('input.calendar, select', this));
		});

		save_to_edit($(this));
		*/
		row = $(this).parent().parent();
		//$('#history_user_profile_form').attr('action',$('#history_user_profile_form').attr('action')+'/'+$(row).attr('row_id'));
		$('#history_user_profile_form').attr('action','/history_user_profile/'+$(row).attr('row_id')+'/edit');
		$('#history_user_profile_form').submit();
	});

	// Disable finished_on field when at_present input is checked
	$(document).on('click', 'input[name=at_present]', function(){
		if ($(this).is(':checked')){
			$('input[name="history_user_profile[finished_on]"]', $(this).closest('form')).attr('disabled',true);
			$('input[name="history_user_profile[finished_on]"]', $(this).closest('form')).datepicker('destroy');
		} else {
			$('input[name="history_user_profile[finished_on]"]', $(this).closest('form')).attr('disabled',false);
			$('input[name="history_user_profile[finished_on]"]', $(this).closest('form')).datepicker(datepickerOptions);
		}
	});
});

// Turns a readonly field to input
function span_to_input(span){
	value = $(span).html();
	name = $(span).attr('class');

	switch(name){
		case 'profile':
			select = "<select name='history_user_profile["+name+"]'>";
			$.each(profile_options, function(index,profile){
				if (profile == value){
					select += "<option selected>"+profile+"</option>";
				} else {
					select += "<option>"+profile+"</option>";
				}
			});
			select += "</option>";

			$(span).before($(select));
		break;
		case 'created_on':
			input = $("<input />", {
				'class': 'calendar',
				'name': 'history_user_profile['+name+']',
				'value': value
			});
	
			$(span).before(input);

			$(input).datepicker(datepickerOptions);
		break;
		case 'finished_on':
			if (value == at_present){
				checkbox = "<input type='checkbox' name='at_present' checked/><label>"+at_present+"</label>";
				calendar = "<input class='calendar' name='history_user_profile["+name+"]' disabled />";
			} else {
				checkbox = "<input type='checkbox' name='at_present' /><label>"+at_present+"</label>";
				calendar = "<input class='calendar' name='history_user_profile["+name+"]' value="+value+" />";
			}

			input = $(checkbox+calendar);
	
			$(span).before(input);

			if (value != at_present){
				$('input[name="history_user_profile[finished_on]"]').datepicker(datepickerOptions);
			}
			
		break;
	}

	$(span).remove();
}
/*
function input_to_span(input){
	value = $(input).val();
	sclass = $(input).attr('name');

	if (sclass == 'finished_on' && $('input[name=at_present]').is(':checked')){
		value = at_present;
	}

	span = $("<span />").attr('class',sclass).html(value);

	if ($(input).hasClass('hasDatepicker')){
		$(input).datepicker('destroy');
	}


	td = $(input).parent();
	$(td).html("");
	$(td).append(span);

	

	
}
*/

// Change edit icon with save icon
function edit_to_save(link){
	$(link).attr('class','icon icon-save');

	$('a.icon-edit').hide();
}

/*
function save_to_edit(link){
	$(link).attr('class','icon icon-edit');
}
*/