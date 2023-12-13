page 50136 OptionLineList
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = OptionLine;

    layout
    {
        area(Content)
        {
            repeater("Options")
            {
                field(line; Rec.line)
                {
                    ApplicationArea = All;

                }
                field(Id; rec.Id)
                {
                    ApplicationArea = All;
                    Visible = false;

                }
                field(SalesHeadID; rec.docID)
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field(optionId; rec.oID)
                {
                    ApplicationArea = All;

                    Visible = false;
                }
                field(OptionName; rec.oName)
                {
                    ApplicationArea = All;

                }
                //selection fields
                field("Start Selection"; rec.preSelection)
                {
                    ApplicationArea = All;
                    TableRelation = SPList.Designator where(OptionID = field(oID), prefix = const(true));
                    LookupPageId = SPList;
                    // trigger OnValidate()
                    // var

                    // begin
                    //     updatePN();
                    //     CurrPage.Update(false);
                    // end;
                }
                field("Part Number"; rec.pn)
                {
                    ApplicationArea = all;
                    Editable = false;
                }
                field("End Selection"; rec.sufSelection)
                {
                    ApplicationArea = All;
                    TableRelation = SPList.Designator where(OptionID = field(oID), prefix = const(false));
                    LookupPageId = SPList;
                    // trigger OnValidate()
                    // var

                    // begin
                    //     updatePN();
                    //     CurrPage.Update(false);

                    // end;

                }


            }
        }
    }
    actions { }
    trigger OnAfterGetCurrRecord()
    begin
        // Message('rec: %1', rec);
        updatePN();
    end;

    trigger OnModifyRecord(): Boolean
    begin
        // updatePN();
    end;

    trigger OnClosePage()
    var
        r: Record OptionLine;
    begin
        ClearAll();
    end;

    procedure setSH(s: Record "Sales Order Entity Buffer")
    begin
        shRec := s;
    end;

    procedure setI(i: Record "Sales Line")
    var
        item: Record Item;
    begin
        if item.get(i."No.") then begin
            iRec := item;
        end;
        slRec := i;
    end;

    procedure getPN(): Text[100]
    begin
        exit(fPN);
    end;

    procedure setRecs(IOL: Record OptionLine; sl: Record "Sales Line")
    var
        olRec: Record OptionLine;
    begin
        rec := IOL;
        rec.Next();
    end;

    procedure setRecs(IOL: Record "Item Option Line"; sl: Record "Sales Line")
    var
        olRec: Record OptionLine;
    begin
        olRec.Reset();
        olRec.SetFilter(docID, sl."Document No.");
        olRec.SetRange(iID, sl."No.");
        olRec.SetRange(oID, IOL.OptionID);
        olRec.SetRange(line, sl."Line No.");
        if olRec.FindFirst() then begin
            rec := olRec;
        end else begin

            Rec.Init();
            Rec.Id := rec.getNewID();
            Rec.docID := sl."Document No.";
            Rec.oID := IOL.OptionID;
            Rec.pn := sl.PartNo;
            rec.line := sl."Line No.";
            Rec.oName := IOL.OptionName;
            Rec.iID := sl."No.";
            if Rec.Insert() then begin
                Rec.Next();
            end;
        end;
        rec.Next();
    end;

    procedure updatePN()
    var
        lRec: Record OptionLine;
    begin
        p := '';
        s := '';
        rec.pn := iRec.PartNo;
        lRec.Reset();
        lRec.SetFilter(docId, rec.docID);
        lRec.SetRange(iID, rec.iID);
        lRec.SetRange(line, rec.line);
        lRec.SetCurrentKey(preOrder, sufOrder);

        lRec.SetAscending(preOrder, true);
        lRec.SetAscending(sufOrder, true);
        if lRec.FindSet() then begin
            repeat
                // Message('\Pre: %1, \Suf %2 \preTF: %3', lRec.preSelection, lRec.sufSelection, lRec.pre);
                if lRec.pre then begin
                    p += lRec.preSelection;
                end else begin
                    s += lRec.sufSelection;
                end;

            until lRec.Next() = 0;
        end;
        rec.pn := p + rec.pn + s;
        // Message('\PN: %1' + '\P: %2' +
        // '\S: %3',
        // rec.pn, p, s
        //  );
        rec.Modify();
        lRec.Reset();
        lRec.SetFilter(iID, rec.iID);
        lRec.SetFilter(docId, rec.docID);
        if lRec.FindSet() then begin
            repeat
                lRec.pn := rec.pn;
                lRec.Modify()
            until lRec.Next() = 0;
        end;
    end;

    var
        iRec: Record Item;
        p, s : text[50];
        slRec: Record "Sales Line";
        shRec: Record "Sales Order Entity Buffer";
        spRec: Record SPList temporary;
        fPN: Text[200];


}
