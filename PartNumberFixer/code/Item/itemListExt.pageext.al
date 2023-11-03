pageextension 50110 ItemListExt extends "Item List"
{
    layout
    {
        addBefore("Description")
        {
            field(PartNo; Rec.PartNo)
            {
                ApplicationArea = All;
            }
        }
    }
}
