page 50115 "Option SubList"
{
    PageType = ListPart;
    SourceTable = "Item Option Line";
    ApplicationArea = All;
    MultipleNewLines = false;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("LID"; rec.lID)
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Line No."; rec."Line No.")
                {
                    ApplicationArea = All;
                    Visible = false;


                    Enabled = rec.OptionName <> '';
                }
                field("ItemNo."; rec."ItemNo.")
                {
                    ApplicationArea = All;
                    Visible = false;
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
                    DrillDownPageId = "Option SubList";

                    trigger OnDrillDown()
                    var
                        oRec: Record Option;
                        oPage: Page OptionList;
                    begin
                        oPage.Editable := false;
                        if oPage.RunModal = Action::OK then begin
                            updateOptionVals(oPage.getRec());
                        end;

                        if rec."ItemNo." = '' then begin
                            updateINo();
                        end;
                        // rec.Modify();
                    end;

                    trigger OnValidate()
                    var
                        oRec: Record Option;
                    begin
                        oRec.SetFilter(Name, rec.OptionName);
                        if oRec.FindFirst() then
                            updateOptionVals(oRec);
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
            action("New Option")
            {
                trigger OnAction()
                var
                    oldRec, oRec : Record Option;
                    oPage: Page "Options Card";
                    oCrud: Codeunit OptionCRUD;
                begin




                    // oPage.initialize();
                    oPage.Run();
                    // if oPage.RunModal = Action::OK then begin

                    updateOptionVals(oPage.getRec());
                    // end;
                end;

            }
            action(viewTable)
            {
                trigger OnAction()
                var
                    IOPage: Page "Option SubList";
                begin
                    if IOPage.RunModal = Action::OK then begin


                    end;
                end;

            }
        }
    }



    procedure updateOptionVals(o: Record Option)
    begin
        if o.Id <> 0 then begin
            if rec.OptionID <> o.Id then
                rec.OptionID := o.Id;
            rec.Caption := o.Caption;
            rec."Price Change" := o."Price Change";
            rec.Required := o.Required;
        end;
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

    procedure m(t: Text; x: Boolean)
    var
        ItemOptionLine: Record "Item Option Line";
    begin
        if x then begin

            ItemOptionLine := xRec; // Assuming Rec is a record of "Item Option Line"
        end else begin
            ItemOptionLine := Rec; // Assuming Rec is a record of "Item Option Line"

        end;

        Message(
            '%1 ' +
            '\Option Name: %2' +
            '\Option ID: %3' +
            '\Item No.: %4' +
            '\Line No.: %5' +
            '\Caption: %6' +
            '\Required: %7' +
            '\Price Change: %8' +
            '\LID: %9',
            t,
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

    procedure setItem(i: Record Item)
    begin
        iRec := i;
    end;

    trigger OnOpenPage()
    var
        lRec: Record "Item Option Line";
    begin
        if rec.lID = 0 then begin

            if lRec.FindLast() then begin
                rec.lID := lRec.lID + 1;
            end else begin
                rec.lID := 100;
            end;
            updateINo();
            // rec.Insert(false);
        end;
    end;

    procedure updateINo()
    begin
        if iRec."No." <> '' then begin
            rec."ItemNo." := iRec."No."
        end;

    end;

    trigger OnAfterGetRecord()
    begin
        if rec."ItemNo." <> iRec."No." then begin
            updateINo();
            // if rec.lID <> 0 then begin
            //     rec.Modify();
            // end;
        end;

    end;

    trigger OnNewRecord(bxrec: Boolean)
    var
    begin
        updateINo();
        // m('newRec');
        // m('newXRec', true);
    end;

    var
        iRec: Record Item;
        count: Integer;
        bxR, inserted, initialized : Boolean;
}