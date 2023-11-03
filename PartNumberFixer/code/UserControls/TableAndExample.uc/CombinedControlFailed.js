// // Combined JavaScript for CombinedControl
// // Global object to store row data
// console.log('inScript');
// document.addEventListener('DOMContentLoaded', function () {
//   // Your code here
//   Microsoft.Dynamics.NAV.InvokeExtensibilityMethod('onReady', []);
// });
// var prefixData = {};
// var suffixData = {};
// var basePn = 'LDCBS1X2';
// var connector = '-TNC';
// var samplePartNumber = '';
// var addCon;
// function setAddConnector(v) {  // Renamed function to avoid shadowing
//   addCon = v;
//   SetSamplePartNumber();
// }
// // function updateTable() {
// //   // Update both prefix and suffix tables
// //   ['prefix', 'suffix'].forEach(function (type) {
// //     // Choose the appropriate table and data object
// //     var tableName = type === 'suffix' ? 'suffixTable' : 'prefixTable';
// //     var data = type === 'suffix' ? suffixData : prefixData;

// //     // Get the tbody of the table
// //     var tbody = document.getElementById(tableName).getElementsByTagName('tbody')[0];

// //     // Clear existing rows
// //     tbody.innerHTML = "";

// //     // Populate table with data
// //     Object.keys(data).forEach(function (key) {
// //       var designator = data[key].designator;
// //       var order = data[key].order;
// //       var isActive = data[key].isActive;

// //       // Create a new row and cells
// //       var newRow = document.createElement("tr");
// //       var cell1 = document.createElement("td");
// //       var cell2 = document.createElement("td");
// //       var cell3 = document.createElement("td");

// //       // Populate the cells
// //       cell1.appendChild(document.createTextNode(designator));
// //       cell2.appendChild(document.createTextNode(order));

// //       var checkbox = document.createElement('input');
// //       checkbox.type = 'checkbox';
// //       checkbox.checked = isActive;

// //       checkbox.addEventListener('change', function () {
// //         data[key].isActive = this.checked;
// //       });

// //       cell3.appendChild(checkbox);

// //       // Add the cells to the row
// //       newRow.appendChild(cell1);
// //       newRow.appendChild(cell2);
// //       newRow.appendChild(cell3);

// //       // Add the row to the table body
// //       tbody.appendChild(newRow);
// //     });
// //   });
// // }




// // New Functions for Prefix and Suffix Data Management


// // Function to delete prefix or suffix data
// function deleteData(type, designator) {
//   // Choose the appropriate data object
//   var data = (type === 'prefix') ? prefixData : suffixData;

//   // Create a unique identifier for the data entry
//   var id = type + '_' + designator;

//   // Remove the data from the global object
//   delete data[id];
// }
// // Updated Functions for Sample Part Number Management

// // Updated createTable function to include sample part number display
// function createTable() {
//   console.log('Creating a table');
//   try {

//     // Microsoft.Dynamics.NAV.InvokeExtensibilityMethod('sendMessage', ['Created']);
//     // Get the control add-in element
//     var controlAddIn = document.getElementById("controlAddIn");

//     var samplePartNumberDisplay = document.createElement('div');
//     samplePartNumberDisplay.id = 'samplePartNumberDisplay';
//     controlAddIn.appendChild(samplePartNumberDisplay);
//     // Create the 'Prefix' table and elements
//     var prefixTable = document.createElement("table");
//     prefixTable.id = "prefixTable";
//     var prefixThead = document.createElement("thead");
//     var prefixHeaderRow = document.createElement("tr");
//     var prefixTh1 = document.createElement("th");
//     prefixTh1.appendChild(document.createTextNode("Prefix"));
//     var prefixTh2 = document.createElement("th");
//     prefixTh2.appendChild(document.createTextNode("Order"));
//     var prefixTh3 = document.createElement("th");
//     prefixTh3.appendChild(document.createTextNode("Active"));
//     prefixHeaderRow.appendChild(prefixTh1);
//     prefixHeaderRow.appendChild(prefixTh2);
//     prefixHeaderRow.appendChild(prefixTh3);
//     prefixThead.appendChild(prefixHeaderRow);
//     var prefixTbody = document.createElement("tbody");
//     prefixTable.appendChild(prefixThead);
//     prefixTable.appendChild(prefixTbody);

//     // Create the 'Suffix' table and elements
//     var suffixTable = document.createElement("table");
//     suffixTable.id = "suffixTable";
//     var suffixThead = document.createElement("thead");
//     var suffixHeaderRow = document.createElement("tr");
//     var suffixTh1 = document.createElement("th");
//     suffixTh1.appendChild(document.createTextNode("Suffix"));
//     var suffixTh2 = document.createElement("th");
//     suffixTh2.appendChild(document.createTextNode("Order"));
//     var suffixTh3 = document.createElement("th");
//     suffixTh3.appendChild(document.createTextNode("Active"));
//     suffixHeaderRow.appendChild(suffixTh1);
//     suffixHeaderRow.appendChild(suffixTh2);
//     suffixHeaderRow.appendChild(suffixTh3);
//     suffixThead.appendChild(suffixHeaderRow);
//     var suffixTbody = document.createElement("tbody");
//     suffixTable.appendChild(suffixThead);
//     suffixTable.appendChild(suffixTbody);

//     // Append both tables to the control add-in
//     controlAddIn.appendChild(prefixTable);
//     controlAddIn.appendChild(suffixTable);
//     // Create the sample part number display
//   } catch (error) {
//     console.log(error);
//   }

// }

// // Updated SetSamplePartNumber function
// function SetSamplePartNumber() {
//   var displayField = document.getElementById('samplePartNumberDisplay');

//   samplePartNumber = basePn;
//   if (addCon) {
//     samplePartNumber += connector;
//   }
//   // Construct the sample part number based on prefixData and suffixData
//   Object.keys(prefixData).sort((a, b) => prefixData[a].order - prefixData[b].order)
//     .forEach(key => {
//       if (prefixData[key].active) {
//         samplePartNumber = prefixData[key].designator + samplePartNumber;
//       }
//     });

//   Object.keys(suffixData).sort((a, b) => suffixData[a].order - suffixData[b].order)
//     .forEach(key => {
//       if (suffixData[key].active) {
//         samplePartNumber += suffixData[key].designator;
//       }
//     });

//   if (displayField) {
//     displayField.innerHTML = samplePartNumber;
//   }
//   // updateTable();

// }

// // Update addData and deleteData to call SetSamplePartNumber at the end
// function addData(type, designator, order, active, current = false) {
//   // Choose the appropriate data object
//   var data = (type === 'prefix') ? prefixData : suffixData;

//   // Create a unique identifier for the data entry
//   var id = type + '_' + designator;

//   // Add the data to the global object
//   data[id] = {
//     'designator': designator,
//     'order': order,
//     'active': active,
//     'current': current
//   };
//   // updateTable();
//   SetSamplePartNumber();  // Call at the end
// }
// // Function to update 'current' prefix or suffix data
// function updateData(type, oldDesignator, newDesignator, newOrder, newActive, current = true) {
//   // Choose the appropriate data object
//   var data = (type === 'prefix') ? prefixData : suffixData;

//   // Create a unique identifier for the old data entry
//   var oldId = type + '_' + oldDesignator;

//   // Create a unique identifier for the new data entry
//   var newId = type + '_' + newDesignator;

//   // Check if the old entry exists and is marked as 'current'
//   if (data.hasOwnProperty(oldId) && data[oldId].current === true) {
//     // Remove the old data from the global object
//     delete data[oldId];

//     // Add the new data to the global object
//     data[newId] = {
//       'designator': newDesignator,
//       'order': newOrder,
//       'active': newActive,
//       'current': current
//     };
//   }

//   // Call SetSamplePartNumber at the end
//   SetSamplePartNumber();
// }
// // Listener for the 'active' checkbox
// // document.addEventListener('DOMContentLoaded', function () {
// //   var activeCheckbox = document.getElementById('activeCheckbox');
// //   if (activeCheckbox) {
// //     activeCheckbox.addEventListener('change', function () {
// //       // Get the designator from the table or some other source
// //       var designator = 'some_designator';

// //       // Update the corresponding data entry
// //       var id = 'prefix_' + designator;
// //       if (prefixData.hasOwnProperty(id)) {
// //         prefixData[id]['active'] = this.checked;
// //         SetSamplePartNumber();
// //       }

// //       id = 'suffix_' + designator;
// //       if (suffixData.hasOwnProperty(id)) {
// //         suffixData[id]['active'] = this.checked;
// //         SetSamplePartNumber();

// //       }
// //     });
// //   }
// // });

function createTable() {
  console.log('Creating a table');

  try {
    const controlAddIn = document.getElementById("controlAddIn");
    if (!controlAddIn) {
      console.log('Control AddIn not found.');
      return;
    }

    const createTableElement = (id, headers) => {
      const table = document.createElement("table");
      table.id = id;
      const thead = document.createElement("thead");
      const headerRow = document.createElement("tr");

      headers.forEach(header => {
        const th = document.createElement("th");
        th.appendChild(document.createTextNode(header));
        headerRow.appendChild(th);
      });

      thead.appendChild(headerRow);
      table.appendChild(thead);
      table.appendChild(document.createElement("tbody"));

      return table;
    };

    const samplePartNumberDisplay = document.createElement('div');
    samplePartNumberDisplay.id = 'samplePartNumberDisplay';
    controlAddIn.appendChild(samplePartNumberDisplay);

    const prefixTable = createTableElement("prefixTable", ["Prefix", "Order", "Active"]);
    const suffixTable = createTableElement("suffixTable", ["Suffix", "Order", "Active"]);

    controlAddIn.appendChild(prefixTable);
    controlAddIn.appendChild(suffixTable);

  } catch (error) {
    console.error("Error in createTable: ", error);
  }
}