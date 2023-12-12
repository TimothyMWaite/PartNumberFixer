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
            field(PartNum; rec.pn)
            {
                ApplicationArea = All;
                AssistEdit = true;
                TableRelation = "Sales Line".PartNo WHERE("Document No." = field(docID));

            }
            usercontrol(optionPNSelector; optionPNSelector)
            {

            }
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
                    trigger OnValidate()
                    var

                    begin
                        updatePN();
                        CurrPage.Update(false);
                    end;
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
                    trigger OnValidate()
                    var

                    begin
                        updatePN();
                        CurrPage.Update(false);

                    end;

                }


            }
        }
    }
    actions
    {
        area(Creation)
        {

            action(addList)
            {
                ApplicationArea = All;

                trigger OnAction()
                begin
                    CurrPage.optionPNSelector.addControl(jsList);
                end;
            }
        }
    }
    trigger OnOpenPage()
    begin
        Message('JSL: %1', jsList);
        CurrPage.optionPNSelector.addControl(jsList);
        // CurrPage.optionPNSelector.updateValues(jsList);
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

    procedure setList(l: JsonArray)
    begin
        jsList := l;

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

    procedure getOptions(i: Record Item)
    var
        oLRec: Record OptionLine;
        ioRec: Record "Item Option Line";
        sp: Record "SPList";
        oRec: Record "Option";
    begin
        ioRec.Reset();
        ioRec.setFilter("ItemNo.", i."No.");
        if ioRec.FindSet() then begin
            repeat
                sp.Reset();
                sp.SetFilter(OptionID, Format(ioRec.OptionID));
                if sp.FindSet() then begin
                    repeat
                        if sp.prefix then begin

                        end else begin

                        end;
                    until spRec.Next() = 0;
                end;
            until ioRec.Next() = 0;
        end;


    end;

    procedure updatePN()
    var
        lRec: Record OptionLine;
    begin
        p := '';
        s := '';
        rec.pn := iRec.PartNo;
        lRec.Reset();
        lRec.SetFilter(line, Format(rec.line));
        lRec.SetRange(iID, rec.iID);
        lRec.SetRange(docId, rec.docID);
        lRec.SetCurrentKey(preOrder, sufOrder);

        lRec.SetAscending(preOrder, true);
        lRec.SetAscending(sufOrder, true);
        if lRec.FindSet() then begin
            repeat
                if lRec.pre then begin
                    p += lRec.preSelection;
                end else begin
                    s += lRec.sufSelection;
                end;

            until lRec.Next() = 0;
        end;
        rec.pn := p + rec.pn + s;
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
        jsList: JsonArray;

}
enum 50137 SalesLineEnum
{


    Extensible = true;


    // Add more values for each sales line.

    caption = 'Sales Lines';
}