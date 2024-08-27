pageextension 50122 "Item Lookup Ext" extends "Item Lookup"
{
    layout
    {
        addbefore("No.")
        {
            field(PartNumber; Rec.PartNumber)
            {
                ApplicationArea = all;
            }
        }
        // Add changes to page layout here
    }

    actions
    {
        // Add changes to page actions here
    }

    var
        myInt: Integer;
}