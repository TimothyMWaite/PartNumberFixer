var jsList = {};
function updateValues(l) {
  jsList = l;
}
function addControl(l) {
  console.log('inAddControl');
  jsList = l;
  // Find the container where you want to add the dropdown (div with id 'controlAddIn')
  var container = document.querySelector('#controlAddIn');

  // Create a select element for the dropdown
  var select = document.createElement('select');

  // Loop through the items in jsList and add options to the dropdown
  for (var i = 0; i < jsList.length; i++) {
    var item = jsList[i];
    if (item.PartNo != "" && item.PartNo != null) {

      var option = document.createElement('option');
      option.value = item.LineNo; // Set the value for the option
      option.text = item.PartNo;  // Set the text for the option
      select.appendChild(option); // Add the option to the select element
    }
  }

  // Add an event listener to handle selection changes
  select.addEventListener('change', function () {
    // Get the selected value
    var selectedValue = select.value;
    // You can perform actions based on the selected value here
    console.log('Selected Value: ' + selectedValue);
  });

  // Add the select element to the container
  container.appendChild(select);
}