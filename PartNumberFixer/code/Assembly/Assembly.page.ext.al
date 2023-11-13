pageextension 50125 AssemblyLine extends "Assembly BOM"
{
    layout
    {
        addbefore(Position)
        {
            field("Item Catagory"; Rec.catagory)
            {
                ApplicationArea = all;
                Editable = false;
            }
            field(ccID; Rec.ccID)
            {
                ApplicationArea = all;
                Visible = false;
            }
        }
        modify("No.")
        {
            trigger OnBeforeValidate()
            var
                iRec: Record Item;
            begin
                if iRec.get(rec."No.") then begin
                    rec.catagory := iRec."Item Category Code";
                    rec.ccID := iRec."Item Category ID";
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