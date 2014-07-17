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
		year = $('th',row).html();
		data = [];


		$.each($('td.editable',row), function(index,cell){
/*
			$.ajax({
				url:'/history_profiles_cost/edit',
				data: {history_profiles_cost:{year: year, profile: $('input', this).attr('name'), value: $('input', this).val()}},
				type: 'POST'
			});
*/
			data.push({year: year, profile: $('input', this).attr('name'), value: $('input', this).val()});

			input_to_span($('input', this));
		});

		$.ajax({
			url:'/history_profiles_cost/edit_year_costs',
			data: {data: JSON.stringify(data)},
			type: 'POST'
		});

		save_to_edit($(this));
	});
});

function span_to_input(span){
	cost = $(span).html();
	name = $(span).attr('class');
	input = $("<input />", {
		'type': 'text',
		'name': name,
		'value': cost,
		'style': 'width:50px;'
	});
	$(span).before(input);
	$(span).remove();
}

function input_to_span(input){
	cost = $(input).val();

	if ($.isNumeric($(input).val())){
		cost = $(input).val();
	} else {
		cost = "0.0";
	}

	sclass = $(input).attr('name');
	span = $("<span />").attr('class',sclass).html(cost);
	$(input).before(span);
	$(input).remove();
}

function edit_to_save(link){
	$(link).attr('class','icon icon-save');
//	$(link).html('Ok');
}

function save_to_edit(link){
	$(link).attr('class','icon icon-edit');
}