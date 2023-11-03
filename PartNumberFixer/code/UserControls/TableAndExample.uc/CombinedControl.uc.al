
controladdin CombinedControl
{
    // Combined Scripts and StyleSheets paths
    Scripts = 'code\UserControls\TableAndExample.uc\CombinedControl.js';
    StyleSheets = 'code\UserControls\TableAndExample.uc\Combined.css';
    // StartupScript = 'code\UserControls\TableAndExample.uc\startup.js';
    MinimumWidth = 300;
    HorizontalStretch = true;
    VerticalStretch = true;

    // Additional procedures or methods can be added here
    // procedure AddData(type: Text; designator: Text; order: Integer; active: Boolean; current: Boolean);
    // procedure DeleteData(type: Text; designator: Text);
    // procedure UpdateData(type: Text; oldDesignator: Text; newDesignator: Text; newOrder: Integer; newActive: Boolean; current: Boolean);
    // procedure CreateTable();
    procedure addControl();
    procedure updateValues(p: Text[500]; s: Text[500]);
    // procedure SetSamplePartNumber();
    event openAddOptions();
}
