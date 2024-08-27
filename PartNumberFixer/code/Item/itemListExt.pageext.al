pageextension 50110 ItemListExt extends "Item List"
{
    layout
    {
        addBefore("Description")
        {
            field(PartNumber; Rec.PartNumber)
            {
                ApplicationArea = All;
            }
        }
    }
}
