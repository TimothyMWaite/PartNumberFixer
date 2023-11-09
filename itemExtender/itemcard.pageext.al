pageextension 50100 ItemExt extends "Item Card"
{
    layout
    {
        addafter("Description")
        {
            field(PartNo; Rec.PartNo)
            {
                ApplicationArea = All;
                Caption = 'My Field';
                Description = 'Custom Field added programatiacally';
                Editable = True;
            }
            field("Myfield"; Rec.Myfield)
            {
                ApplicationArea = All;
                ObsoleteState = Pending;
            }
        }
    }
    // Add changes to page layout here

    // var
    //     MyField: Text;
}