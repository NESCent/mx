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

function updateGenusList(familyElement, genusList) {
    // find the genus select element
    var genusElement = $(familyElement).siblings(".genus");
    // remove all options from the genus element
    genusElement.find('option').remove();
    for(var genus in genusList) {
      var obj = genusList[genus].taxon_name;
      console.log("name: " + obj.name + " id: " + obj.id);
      // now make a new select option and append it
      var optionElement = $('<option>', {value: obj.id}).text(obj.name);
      genusElement.append(optionElement);
    }
}

function familyChanged(element, familyId) {
  console.log("family changed to " + familyId)
  $.ajax({
    url: "/projects/1/public/search/list_genus.json",
    data: { family_id: familyId }
    }).done(function(data, textStatus, jqXHR) { updateGenusList(element, data)});
}

function addSelectionChangeListeners() {
  $('select#family').bind('change',function() {
    familyChanged(this,this.value);
  });
}

$(document).ready(function() {
  // add button handlers
  addButtonHandlers();
  addSelectionChangeListeners();
});

