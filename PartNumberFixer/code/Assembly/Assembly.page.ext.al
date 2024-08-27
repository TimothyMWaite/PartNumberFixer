pageextension 50125 AssemblyLine extends "Assembly BOM"
{
    layout
    {
        addafter("No.")
        {
            field(PartType; rec.PartType)
            {
                ApplicationArea = All;
                Visible = True;
            }
            field(showOnDocument; rec.showOnDocument)
            {
                ApplicationArea = All;
                Caption = 'Show On Assembly Line in Sales Document';
                TableRelation = Item.showOnDocument where("No." = field("No."));
            }
        }
        modify("No.")
        {
            trigger OnBeforeValidate()
            var
                iRec: Record Item;
            begin
                if iRec.get(rec."No.") then begin
                    rec.PartType := iRec.PartType;
                end;
            end;
        }
    }

    actions
    {
        // Add changes to page actions here
    }

    var
        myInt: Integer;
}