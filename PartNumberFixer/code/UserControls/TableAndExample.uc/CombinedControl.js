let samplePN = 'LDCBS1X2'; // Global variable for Sample Part Number
var pre, suf;
var cn = '-TNC';
var showCN = false;
function updateSamplePN() {
  // Update samplePN by concatenating active prefixes and suffixes
  // ... (previous code)
  document.getElementById('samplePN').innerText = `Sample Part Number: ${pre}${samplePN}${showCN ? cn : ''}${suf}`;
}
function toggleCN() {
  showCN = !showCN;

  // Update the button appearance based on the state
  const connectorButton = document.getElementById('addConnectorButton');
  connectorButton.classList.toggle('connectorActive', showCN);
  connectorButton.classList.toggle('connectorInactive', !showCN);

  // Now update the sample part number display
  updateSamplePN();
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

    // Container for samplePN
    const sampleContainerDiv = document.createElement('div');
    sampleContainerDiv.style.display = 'flex';
    sampleContainerDiv.style.justifyContent = 'center'; // Center the sample part number
    sampleContainerDiv.style.marginBottom = '10px'; // Add some space below the sample part number container

    // Display for samplePN
    const samplePNDiv = document.createElement('span');
    samplePNDiv.id = 'samplePN';
    samplePNDiv.innerHTML = `Sample Part Number: ${pre}${samplePN}${showCN ? cn : ''}${suf}`;
    sampleContainerDiv.appendChild(samplePNDiv);

    // Append the sample part number container to the controlAddIn
    controlAddIn.appendChild(sampleContainerDiv);

    // Container for buttons
    const buttonsDiv = document.createElement('div');
    buttonsDiv.style.display = 'flex';
    buttonsDiv.style.justifyContent = 'center'; // This will center the buttons in the container
    buttonsDiv.style.gap = '10px'; // This adds space between the buttons

    // Existing Add/Remove Options button
    const optionsButton = document.createElement('button');
    optionsButton.innerHTML = 'Add/Remove Options';
    optionsButton.onclick = openAddOptions;
    buttonsDiv.appendChild(optionsButton);

    // New connector button
    const connectorButton = document.createElement('button');
    connectorButton.id = 'addConnectorButton';
    connectorButton.innerHTML = 'Add Simple Connector';
    connectorButton.classList.add('connectorInactive');
    connectorButton.onclick = toggleCN;
    buttonsDiv.appendChild(connectorButton);

    // Append the button container to the controlAddIn
    controlAddIn.appendChild(buttonsDiv);

    // ... (previous code for tables, if needed)

  } catch (error) {
    console.error("Error in addControl: ", error);
  }
}

