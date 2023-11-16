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
                    trigger OnValidate()
                    var
                        oRec: Record Option;
                        lRec: Record "Item Option Line";
                    begin
                        // updateLineNo(bxR);
                        // updateItemNo();

                        oRec.Reset();
                        oRec.SetFilter(Name, rec.OptionName);
                        if oRec.FindFirst() then begin
                            rec.OptionID := oRec.Id;
                        end;
                        // if not inserted then begin
                        //     rec.Insert();
                        //     inserted := true;
                        // end else begin
                        lRec.Reset();
                        m();
                        if rec."ItemNo." = '' then begin
                            rec."ItemNo." := iRec."No.";
                        end;
                        updateLID();

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


    trigger OnNewRecord(BelowxRec: Boolean)
    begin

        bxR := BelowxRec;

    end;




    procedure updateItemNo(): Boolean
    begin
        if iRec."No." = '' then begin
            rec."ItemNo." := xRec."ItemNo.";
            exit(true);
        end else begin

            rec."ItemNo." := iRec."No.";

            exit(false);
        end;

    end;

    // procedure updateLineNo(bXRec: Boolean)
    // var

    // begin
    //     if bXRec then begin
    //         rec."Line No." := rec."Line No." + 1;
    //     end else begin
    //         rec."Line No." := 1;
    //     end;
    // end;

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
        iRec := i;
    end;

    procedure updateLID()
    begin
        count += 1;
        if rec."ItemNo." = '' then
            updateItemNo();
        rec.lID := rec."ItemNo." + '-' + format(count);
        save();
    end;

    procedure save()
    var
        lRec: Record "Item Option Line";
    begin
        if lRec.Get(rec."ItemNo." + ' ' + Format(count)) then begin
            rec.Modify(false);

        end else begin
            rec.Insert(false);
        end;
    end;

    var
        iRec: Record Item;
        count: Integer;
        bxR, inserted, initialized : Boolean;
}