
function draw(){
      
}

function profitability_totals(id){
  var data = google.visualization.arrayToDataTable([
    ['Servicios', '€'],
    ['Total Gastos Internos', 2413537],
    ['Total Gastos Externos', 1553700],
    ['MC', 1293344]
  ]);

  var formatter = new google.visualization.NumberFormat({
    pattern: '#€'
  });
  formatter.format(data,1);


  var options = {
    title: 'Gastos internos, externos y margen'
  };

  var chart = new google.visualization.PieChart(document.getElementById(id));
  chart.draw(data, options);
}


function profitability_by_services(id,services_mc){
  services = ['Servicios'];
  mcs = ['MC'];
  table_rows = [];

  $.each(services_mc, function(index, service){
    services.push(service[0]);
    mcs.push(service[2]);
    table_rows.push([service[0], {v: service[1], f: format_euro(service[1])}, {v: service[2], f: (service[2]*100).toFixed(2)+'%'}]);
  });

  var data = google.visualization.arrayToDataTable([services,mcs]);
  var dataTable = new google.visualization.DataTable();
  dataTable.addColumn('string', 'Servicio');
  dataTable.addColumn('number', 'Ingresos');
  dataTable.addColumn('number', 'MC');
  dataTable.addRows(table_rows);

  var formatter = new google.visualization.NumberFormat({
    pattern: '#.#%'
  });

  for (i=1; i<services.length; i++){
    formatter.format(data,i);
  }

  var options = {
    title: 'Rentabilidad por servicios',
    hAxis: {title: 'Servicios'},
    vAxis: {title: 'MC', format:'#.#%', gridlines: {count: 11}, viewWindowMode:'explicit', viewWindow:{min:0}}
  };

  var table = new google.visualization.Table(document.getElementById(id+'_table'));
  var chart = new google.visualization.ColumnChart(document.getElementById(id));

  table.draw(dataTable);
  chart.draw(data, options);
}

function profitability_by_regions(id,regions_mc){
  regions = ['Regiones'];
  mcs = ['MC'];
  table_rows = [];

  $.each(regions_mc, function(index, region){
    regions.push(region[0]);
    mcs.push(region[2]);
    table_rows.push([region[0], {v: region[1], f: format_euro(region[1])}, {v: region[2], f: (region[2]*100).toFixed(2)+'%'}]);
  });

  var data = google.visualization.arrayToDataTable([regions,mcs]);
  var dataTable = new google.visualization.DataTable();
  dataTable.addColumn('string', 'Region');
  dataTable.addColumn('number', 'Ingresos');
  dataTable.addColumn('number', 'MC');
  dataTable.addRows(table_rows);

  var formatter = new google.visualization.NumberFormat({
    pattern: '#.#%'
  });

  for (i=1; i<regions.length; i++){
    formatter.format(data,i);
  }

  var options = {
    title: 'Margen por Regiones',
    hAxis: {title: 'Regiones'},
    vAxis: {title: 'MC', format:'#.#%', gridlines: {count: 11}, viewWindowMode:'explicit', viewWindow:{min:0}}
  };

  var table = new google.visualization.Table(document.getElementById(id+'_table'));
  var chart = new google.visualization.ColumnChart(document.getElementById(id));
  
  table.draw(dataTable);
  chart.draw(data, options);
}





function profitability_by_services2(id,services_mc){
  services = ['Servicios'];
  mcs = ['MC'];

  $.each(services_mc, function(service, mc){
    services.push(service);
    mcs.push(mc);
  });

  var data = google.visualization.arrayToDataTable([services,mcs]);
/*  
  var dataTable = new google.visualization.DataTable();
  dataTable.addColumn('string', 'Servicio');
  dataTable.addColumn('number', 'Ingresos');
  dataTable.addColumn('number', 'MC');
  dataTable.addRows([
    ['Mike',  {v: 10000, f: '$10,000'}, true],
    ['Jim',   {v:8000,   f: '$8,000'},  false],
    ['Alice', {v: 12500, f: '$12,500'}, true],
    ['Bob',   {v: 7000,  f: '$7,000'},  true]
  ]);
*/
  var formatter = new google.visualization.NumberFormat({
    pattern: '#.#%'
  });

  for (i=1; i<services.length; i++){
    formatter.format(data,i);
  }

  var options = {
    title: 'Rentabilidad por servicios',
    hAxis: {title: 'Servicios'},
    vAxis: {title: 'MC', format:'#.#%', gridlines: {count: 11}, viewWindowMode:'explicit', viewWindow:{min:0}}
  };

//  var table = new google.visualization.Table(document.getElementById(id+'_table'));
  var chart = new google.visualization.ColumnChart(document.getElementById(id));

//  table.draw(dataTable, {showRowNumber: true});
  chart.draw(data, options);
}

function profitability_by_regions2(id,regions_mc){
  regions = ['Regiones'];
  mcs = ['MC'];

  $.each(regions_mc, function(region, mc){
    regions.push(region);
    mcs.push(mc);
  });

  var data = google.visualization.arrayToDataTable([regions,mcs]);

  var formatter = new google.visualization.NumberFormat({
    pattern: '#.#%'
  });

  for (i=1; i<regions.length; i++){
    formatter.format(data,i);
  }

  var options = {
    title: 'Margen por Regiones',
    hAxis: {title: 'Regiones'},
    vAxis: {title: 'MC', format:'#.#%', gridlines: {count: 11}, viewWindowMode:'explicit', viewWindow:{min:0}}
  };

  var chart = new google.visualization.ColumnChart(document.getElementById(id));

  chart.draw(data, options);
}
      












function profitability_by_pm(id){
  var data = google.visualization.arrayToDataTable([
    ['Servicios', 'BPO', 'Desarrollo', 'Mantenimiento', 'Subcontratación'],
    ['MC', 0.2456, 0.315, 0.26, 0.12]
  ]);

  var formatter = new google.visualization.NumberFormat({
    pattern: '#.#%'
  });
  formatter.format(data,1);
  formatter.format(data,2);
  formatter.format(data,3);
  formatter.format(data,4);


  var options = {
    title: 'Margen por área de producción',
    hAxis: {title: 'Servicios'},
    vAxis: {title: 'MC', format:'#.#%', gridlines: {count: 10}}
  };

  var chart = new google.visualization.ColumnChart(document.getElementById(id));

  chart.draw(data, options);
}

function profitability_by_regions_services(id){
  var data = google.visualization.arrayToDataTable([
    ['Year', 'Sales', 'Expenses'],
    ['2004',  1000,      400],
    ['2005',  1170,      460],
    ['2006',  660,       1120],
    ['2007',  1030,      540]
  ]);

  var options = {
    title: 'Company Performance',
    hAxis: {title: 'Year', titleTextStyle: {color: 'red'}}
  };

  var chart = new google.visualization.ColumnChart(document.getElementById(id));

  chart.draw(data, options);
}






function format_euro(number){
  var numberStr = parseFloat(number).toFixed(2).toString();
  var numFormatDec = numberStr.slice(-2); /*decimal 00*/
  numberStr = numberStr.substring(0, numberStr.length-3); /*cut last 3 strings*/
  var numFormat = new Array;
  while (numberStr.length > 3) {
    numFormat.unshift(numberStr.slice(-3));
    numberStr = numberStr.substring(0, numberStr.length-3);
  }
  numFormat.unshift(numberStr);
  return numFormat.join('.')+','+numFormatDec+' €'; /*format 000.000.000,00 */
}