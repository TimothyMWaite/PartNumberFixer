tableextension 50105 SalesLineExt extends "Sales Line"
{
    fields
    {
        field(50104; PartNo; Text[200])
        {

            DataClassification = ToBeClassified;
        }
        // Add changes to table fields here
    }
    fieldgroups
    {
        addlast(DropDown; "Line No.") { }
    }
}