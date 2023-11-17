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
                field("LID"; rec.lID)
                {
                    ApplicationArea = All;

                }
                field("Line No."; rec."Line No.")
                {
                    ApplicationArea = All;
                    Visible = true;

                    Enabled = rec.OptionName <> '';
                }
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
                    Lookup = true;
                    LookupPageId = OptionList;
                    DrillDown = true;

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
            action(viewRec)
            {
                trigger OnAction()
                var
                begin
                    m();
                end;

            }
        }
    }








    procedure m()
    var
        ItemOptionLine: Record "Item Option Line";
    begin
        ItemOptionLine := Rec; // Assuming Rec is a record of "Item Option Line"
        Message(
            '\Option Name: %2' +
            '\Option ID: %3' +
            '\Item No.: %4' +
            '\Line No.: %5' +
            '\Caption: %6' +
            '\Required: %7' +
            '\Price Change: %8',
            '\LID: %9',
            ItemOptionLine.OptionName,
            ItemOptionLine.OptionID,
            ItemOptionLine."ItemNo.",
            ItemOptionLine."Line No.",
            ItemOptionLine.Caption,
            ItemOptionLine.Required,
            ItemOptionLine."Price Change",
            ItemOptionLine.lID
        );
    end;

    procedure m(t: Text)
    var
        ItemOptionLine: Record "Item Option Line";
    begin
        ItemOptionLine := Rec; // Assuming Rec is a record of "Item Option Line"
        Message(
            '%1 ' +
            '\Option Name: %2' +
            '\Option ID: %3' +
            '\Item No.: %4' +
            '\Line No.: %5' +
            '\Caption: %6' +
            '\Required: %7' +
            '\Price Change: %8',
            t,
            ItemOptionLine.OptionName,
            ItemOptionLine.OptionID,
            ItemOptionLine."ItemNo.",
            ItemOptionLine."Line No.",
            ItemOptionLine.Caption,
            ItemOptionLine.Required,
            ItemOptionLine."Price Change"
        );
    end;

    procedure setItem(i: Record Item)
    begin
        if not initialized then begin
            rec.init();
            initialized := true;
        end;
        iRec := i;
        rec."ItemNo." := i."No.";
    end;

    trigger OnAfterGetCurrRecord()
    begin
        if rec."ItemNo." = '' then begin
            if iRec."No." = '' then begin
            rec."ItemNo." := xRec."ItemNo.";

            end;
            rec."ItemNo." := iRec."No.";
        end;
    end;

    var
        iRec: Record Item;
        count: Integer;
        bxR, inserted, initialized : Boolean;
}