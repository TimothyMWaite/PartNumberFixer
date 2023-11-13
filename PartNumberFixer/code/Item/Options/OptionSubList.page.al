page 50115 "Option SubList"
{
    PageType = ListPart;
    SourceTable = "Item Option Line";
    ApplicationArea = All;


    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("ItemNo."; rec."ItemNo.")
                {
                    ApplicationArea = All;
                    Editable = false;
                    TableRelation = Item."No.";
                    Enabled = rec.OptionName <> '';
                }
                field(OptionName; Rec.OptionName)
                {
                    ApplicationArea = All;
                    TableRelation = Option.Name;
                }
                field("Line No."; rec."Line No.")
                {
                    ApplicationArea = All;
                    Visible = false;
                    Enabled = rec.OptionName <> '';
                }
                field(Caption; rec.Caption)
                {
                    ApplicationArea = All;
                    Enabled = rec.OptionName <> '';
                }
                field(Required; rec.Required)
                {
                    ApplicationArea = All;
                    Enabled = rec.OptionName <> '';
                }

                field("Price Change"; rec."Price Change")
                {
                    ApplicationArea = All;
                    Enabled = rec.OptionName <> '';
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            // Your actions go here
        }
    }
    trigger OnOpenPage()
    var
        ItemRec: Record Item;
    begin
        if Rec."ItemNo." <> '' then begin
            if ItemRec.Get(Rec."ItemNo.") then
                iRec := ItemRec;
        end;
    end;

    procedure setItemNum(i: Record Item)
    begin
        rec."ItemNo." := i."No.";
        // Message('Linked Item No through call: %1', i."No.");
        CurrPage.Update();
    end;

    var
        iRec: Record Item;
}