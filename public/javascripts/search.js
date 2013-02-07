function addTaxonFilterRow() {
  // User has clicked to add another taxon row
  var lastTaxonFilterRow = $('.taxon-filter-row').last();
  // Create an element
  var el = lastTaxonFilterRow.clone(true);
  // on the clone, change the + to a -
  el.find(".add_taxon").find("i").removeClass("icon-plus-sign").addClass("icon-minus-sign");
  el.find(".add_taxon").unbind('click').bind('click', function() {
    $(this).parents(".taxon-filter-row").remove()
  });
  lastTaxonFilterRow.after(el)
}

function addTraitFilterRow() {
  // User has clicked to add another trait row
  var lastTraitFilterRow = $('.trait-filter-row').last();
  // Create an element
  var el = lastTraitFilterRow.clone(true);
  // on the clone, change the + to a -
  el.find(".add_trait").find("i").removeClass("icon-plus-sign").addClass("icon-minus-sign");
  el.find(".add_trait").unbind('click').bind('click', function() {
    $(this).parents(".trait-filter-row").remove()
  });
  lastTraitFilterRow.after(el)
}

function addButtonHandlers() {
  $('#up').bind('click', function() {
    var available = $('#available').text();
    available++;
    $('#available').text(available);
  });
  $('#down').bind('click',function() {
    var available = $('#available').text();
    available--;
    $('#available').text(available);
  });
  
  $('.add_taxon').bind('click', function() {
    addTaxonFilterRow();
  });
  $('.add_trait').bind('click',function() {
    addTraitFilterRow();
  });
}

$(document).ready(function() {
  // add button handlers
  addButtonHandlers();
});

