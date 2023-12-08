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