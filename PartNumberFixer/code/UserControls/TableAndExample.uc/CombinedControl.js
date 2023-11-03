let samplePN = 'LDCBS1X2'; // Global variable for Sample Part Number
var pre, suf;
function updateSamplePN() {
  // Update samplePN by concatenating active prefixes and suffixes
  // ... (previous code)
  document.getElementById('samplePN').innerText = `Sample Part Number: ${pre}${samplePN}${suf}`;
}

function openAddOptions() {
  // Your logic for opening the modal goes here
  Microsoft.Dynamics.NAV.InvokeExtensibilityMethod('openAddOptions', []);
}
function updateValues(p, s) {
  pre = p;
  suf = s;
  updateSamplePN();
}
function addControl() {
  console.log('Adding Custom Control');
  try {
    const controlAddIn = document.getElementById("controlAddIn");
    if (!controlAddIn) {
      console.log('Control AddIn not found.');
      return;
    }

    // Container for samplePN and button
    const containerDiv = document.createElement('div');
    containerDiv.style.display = 'flex';
    containerDiv.style.justifyContent = 'space-between';

    // Display for samplePN
    const samplePNDiv = document.createElement('span');
    samplePNDiv.id = 'samplePN';
    samplePNDiv.innerHTML = `Sample Part Number: ${samplePN}`;
    containerDiv.appendChild(samplePNDiv);

    // Button to Add/Remove Options
    const optionsButton = document.createElement('button');
    optionsButton.innerHTML = 'Add/Remove Options';
    optionsButton.onclick = openAddOptions;
    containerDiv.appendChild(optionsButton);

    controlAddIn.appendChild(containerDiv);

    // ... (previous code for tables, if needed)

  } catch (error) {
    console.error("Error in addControl: ", error);
  }
}
