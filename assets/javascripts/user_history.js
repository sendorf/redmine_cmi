$(document).ready(function(){
	$(document).on('click', '.icon-edit', function(){
		row = $(this).parent().parent();

		$.each($('td.editable',row), function(index,cell){
			span_to_input($('span', this));
		});

		edit_to_save($(this));
	});

	$(document).on('click', '.icon-save', function(){
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
	});

	$(document).on('click', 'input[name=at_present]', function(){
		if ($(this).is(':checked')){
			$('input[name=finished_on]').attr('disabled',true);
			$('input[name=finished_on]').datepicker('destroy');
		} else {
			$('input[name=finished_on]').attr('disabled',false);
			$('input[name=finished_on]').datepicker(datepickerOptions);
		}
	});
});

function span_to_input(span){
	value = $(span).html();
	name = $(span).attr('class');

	switch(name){
		case 'profile':
			select = "<select name='"+name+"'>";
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
				'name': name,
				'value': value
			});
	
			$(span).before(input);

			$(input).datepicker(datepickerOptions);
		break;
		case 'finished_on':
			if (value == at_present){
				checkbox = "<input type='checkbox' name='at_present' checked/><label for='at_present'>"+at_present+"</label>";
				calendar = "<input class='calendar' name='"+name+"' disabled />";
			} else {
				checkbox = "<input type='checkbox' name='at_present' /><label for='at_present'>"+at_present+"</label>";
				calendar = "<input class='calendar' name='"+name+"' value="+value+" />";
			}

			input = $(checkbox+calendar);
	
			$(span).before(input);

			if (value != at_present){
				$('input[name=finished_on]').datepicker(datepickerOptions);
			}
			
		break;
	}

	$(span).remove();
}

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


function edit_to_save(link){
	$(link).attr('class','icon icon-save');
}

function save_to_edit(link){
	$(link).attr('class','icon icon-edit');
}