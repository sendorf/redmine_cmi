
function draw(){
      
}

function profitability_totals(id, summary){
  table_rows =[];
  $.each(summary, function(index, metric){
    if (index == 'mc_percent'){
      table_rows.push([metric[0], {v: metric[1], f: (metric[1]*100).toFixed(1)+'%'}]);
    } else {
      table_rows.push([metric[0], {v: metric[1], f: format_euro(metric[1])}]);
    }
  });

  var data = google.visualization.arrayToDataTable([
    ['Servicios', '€'],
    ['Total Gastos Internos', summary['internal_expenditure'][1]],
    ['Total Gastos Externos', summary['external_expenditure'][1]],
    ['MC', summary['mc'][1]]
  ]);

  var dataTable = new google.visualization.DataTable();
  dataTable.addColumn('string', 'Concepto');
  dataTable.addColumn('number', 'Cantidad');
  dataTable.addRows(table_rows);

  var formatter = new google.visualization.NumberFormat({
    pattern: '#€'
  });
  formatter.format(data,1);


  var options = {
    title: 'Gastos internos, externos y margen'
  };


  //add_total_row(dataTable);
  var chart = new google.visualization.PieChart(document.getElementById(id));
  var table = new google.visualization.Table(document.getElementById(id+'_table'));

  table.draw(dataTable);
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


function profitability_by_pm(id,projman_mc){
  projman = ['Jefes de proyecto'];
  mcs = ['MC'];
  table_rows = [];

  $.each(projman_mc, function(index, pm){
    projman.push(pm[0]);
    mcs.push(pm[2]);
    table_rows.push([pm[0], {v: pm[1], f: format_euro(pm[1])}, {v: pm[2], f: (pm[2]*100).toFixed(2)+'%'}]);
  });

  var data = google.visualization.arrayToDataTable([projman,mcs]);
  var dataTable = new google.visualization.DataTable();
  dataTable.addColumn('string', 'Jefe de proyecto');
  dataTable.addColumn('number', 'Ingresos');
  dataTable.addColumn('number', 'MC');
  dataTable.addRows(table_rows);

  var formatter = new google.visualization.NumberFormat({
    pattern: '#.#%'
  });

  for (i=1; i<projman.length; i++){
    formatter.format(data,i);
  }

  var options = {
    title: 'Margen por Jefes de proyecto',
    hAxis: {title: 'Jefes de proyecto'},
    vAxis: {title: 'MC', format:'#.#%', gridlines: {count: 11}, viewWindowMode:'explicit', viewWindow:{min:0}}
  };

  var table = new google.visualization.Table(document.getElementById(id+'_table'));
  var chart = new google.visualization.ColumnChart(document.getElementById(id));
  
  table.draw(dataTable);
  chart.draw(data, options);
}


function profitability_by_regions_services(id,reg_serv_data){
  services = [];
  profit_table_rows = [];
  mc_table_rows = [];

  $.each(reg_serv_data, function(reg, serv_data){
    profit_reg_row = [reg];
    mc_reg_row = [reg];
    $.each(serv_data, function(serv, data){
      if ($.inArray(serv,services)==-1){
        services.push(serv);
      }

      profit_reg_row.push({v: data[0], f: format_euro(data[0])});
      mc_reg_row.push({v: data[1], f: (data[1]*100).toFixed(2)+'%'});
    });
    profit_table_rows.push(profit_reg_row);
    mc_table_rows.push(mc_reg_row);
  });

  var profitDataTable = new google.visualization.DataTable();
  var mcDataTable = new google.visualization.DataTable();
  profitDataTable.addColumn('string', 'Comunidad');
  mcDataTable.addColumn('string', 'Comunidad');
  $.each(services, function(i,serv){
    profitDataTable.addColumn('number', serv);
    mcDataTable.addColumn('number', serv);
  });

  profitDataTable.addRows(profit_table_rows);
  mcDataTable.addRows(mc_table_rows);

  var profit_table = new google.visualization.Table(document.getElementById(id+'_profit_table'));
  var mc_table = new google.visualization.Table(document.getElementById(id+'_mc_table'));
  
  profit_table.draw(profitDataTable);
  mc_table.draw(mcDataTable);  
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
      
function profitability_by_regions_services2(id){
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

function profitability_by_pm2(id){
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















/*
// function to add total row
  function add_total_row(data) { // add a total row to the DataTable
    var row_count = data.getNumberOfRows();
    var column_count = data.getNumberOfColumns();
    var new_row = new Array();

    for (col_i = 0; col_i < column_count; col_i++) { // total each column
      var cell_value = 0;
      if (data.getColumnType(col_i) == 'string') { // enter 'Total' on string columns
        new_row[col_i] = 'Total';
      }
      else if (data.getColumnType(col_i) == 'number') {
        // get column pattern
        col_pattern = data.getColumnPattern(col_i);

        if (col_pattern.match('%') != null) { // percent column should not be totaled
          new_row[col_i] = null;
        }
        else { // total column values
          for (row_i = 0; row_i < row_count; row_i++) {
            cell_value = cell_value + data.getValue(row_i, col_i);
          }
          // create rounded value to 2 decimals
          cell_formatted = Math.round(cell_value*100)/100;

          if (col_pattern.match(/\$/i) != null) { // add currency sign if it's in the column's pattern
            new_row[col_i] = {v: cell_value, f: '$' + cell_formatted};
          }
          else { // no currency sign needed
            new_row[col_i] = {v: cell_value, f: '' + cell_formatted};
          }
        }
      }
      else { // boolean, data, datatime, timeofday types should not be totaled
        new_row[col_i] = null;
      }
    }
  }
*/
