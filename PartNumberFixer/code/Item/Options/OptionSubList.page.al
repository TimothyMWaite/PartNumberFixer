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
                    DrillDown = true;
                    trigger OnValidate()
                    var
                        oRec: Record Option;
                    begin
                        oRec.Reset();
                        oRec.SetFilter(Name, rec.OptionName);
                        if oRec.FindFirst() then begin
                            rec.OptionID := oRec.Id;
                            if not rec.Insert(false) then
                                rec.Modify(false);
                        end;
                    end;
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
    trigger OnInit()
    begin
        m('Init');
    end;

    trigger OnInsertRecord(BelowxRex: Boolean): Boolean
    var
    begin
        m('Insert');
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        m('new')
    end;

    trigger OnModifyRecord(): Boolean
    begin
        m('Mod');
    end;
    // trigger OnOpenPage()
    // var
    //     ItemRec: Record Item;
    // begin

    //     if Rec."ItemNo." <> '' then begin
    //         if ItemRec.Get(Rec."ItemNo.") then
    //             iRec := ItemRec;
    //     end;
    // end;

    // trigger OnNewRecord(BelowxRec: Boolean)
    // begin
    //     if BelowxRec then begin
    //         rec."Line No." := rec."Line No." + 1;
    //         if (rec."ItemNo." = '') AND (xRec."ItemNo." <> '') then begin
    //             rec."ItemNo." := xRec."ItemNo.";
    //         end;
    //         setID();
    //     end else begin
    //         rec."Line No." := 1;
    //         setID();
    //     end;
    // end;

    procedure setItemNum(i: Record Item)
    begin
        rec."ItemNo." := i."No.";
        // Message('Linked Item No through call: %1', i."No.");
        CurrPage.Update();
    end;

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
            ItemOptionLine.OptionName,
            ItemOptionLine.OptionID,
            ItemOptionLine."ItemNo.",
            ItemOptionLine."Line No.",
            ItemOptionLine.Caption,
            ItemOptionLine.Required,
            ItemOptionLine."Price Change"
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

    var
        iRec: Record Item;
}