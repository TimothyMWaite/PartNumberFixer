page 50136 OptionLineList
{
    PageType = List;
    ApplicationArea = All;
    SourceTable = OptionLine;
    layout
    {
        area(Content)
        {
            field("Part Number"; fPN)
            {
                ApplicationArea = all;
                Editable = false;
                Caption = 'Current Part Number:';

            }
            repeater("Options")
            {
                field(line; Rec.line)
                {
                    ApplicationArea = All;
                    Editable = false;

                }
                field(Id; rec.Id)
                {
                    ApplicationArea = All;
                    Visible = false;

                }
                field(SalesHeadID; rec.docID)
                {
                    ApplicationArea = All;
                    Visible = true;
                }
                field(optionId; rec.oID)
                {
                    ApplicationArea = All;

                    Visible = false;
                }
                field(OptionName; rec.oName)
                {
                    ApplicationArea = All;
                    Editable = false;

                }
                //selection fields
                field("Start Selection"; rec.preSelection)
                {
                    ApplicationArea = All;
                    TableRelation = SPList.Designator where(OptionID = field(oID), prefix = const(true));
                    LookupPageId = SPList;
                    Editable = rec.oName <> '';
                    trigger OnAfterLookup(Selected: RecordRef)
                    begin
                        updatePN();
                    end;

                    trigger OnValidate()
                    var

                    begin
                        updatePN();
                        CurrPage.Update(false);
                    end;
                }
                field("End Selection"; rec.sufSelection)
                {
                    ApplicationArea = All;
                    TableRelation = SPList.Designator where(OptionID = field(oID), prefix = const(false));
                    LookupPageId = SPList;
                    Editable = rec.oName <> '';
                    trigger OnAfterLookup(Selected: RecordRef)
                    begin
                        updatePN();
                    end;

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
    actions { }
    trigger OnAfterGetCurrRecord()
    var
        lRec: Record OptionLine;
    begin
        updatePN();
        if lRec.Get(0) then begin
            lRec.Delete();
            CurrPage.Update(false);
        end;
    end;

    trigger OnModifyRecord(): Boolean
    begin
        updatePN();


    end;

    trigger OnClosePage()
    var
        r: Record OptionLine;
    begin
        ClearAll();
        updateAssemblyInfo();
    end;

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    var
        lRec: Record OptionLine;
    begin
        Message('\Do not try to add options here. Go to the Item ' + '\page and add the needed options there! Or talk to Tim.');
        if lRec.Get(0) then begin
            lRec.Delete();
            CurrPage.Update(false);
        end;
        exit(false);
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

    procedure getPN(): Text[200]
    begin
        exit(fPN);
    end;

    procedure resetPN()
    begin
        fPN := iRec.PartNo;
    end;

    procedure setRecs(IOL: Record OptionLine; sl: Record "Sales Line")
    var
        olRec: Record OptionLine;
    begin
        rec := IOL;
        rec.Next();
    end;

    procedure updatePN()
    var
        lRec, ol, li : Record OptionLine;
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
                if lRec.preSelection <> '' then
                    p += lRec.preSelection;
                if lRec.sufSelection <> '' then
                    s += lRec.sufSelection;
                lRec.Modify(false);
            until lRec.Next() = 0;
        end;
        fPN := p + iRec.PartNo + s;

        rec.Modify(false);
        li.Reset();
        li.SetFilter(docID, rec.docID);
        li.SetRange(line, rec.line);
        if ol.FindSet() then begin
            repeat
                if li.Id <> 0 then begin

                    li.pn := fPN;
                    li.Modify(false);
                end;
            until li.Next() = 0;
        end;
        slRec.PartNo := fPN;
        slRec.Modify(false);
        Message('%1, %2', rec.sufassemblyID, rec.preassemblyID);
    end;

    procedure updateAssemblyInfo()
    var
        aRec: Record "Option Assembly Line";
        lRec: Record OptionLine;
        bStr: Text[1];
    begin
        bStr := '';
        aRec.Reset();
        lRec.Reset();
        lRec.SetFilter(docID, rec.docID);
        lRec.SetRange(line, rec.line);
        if lRec.FindSet() then begin
            repeat
                if lRec.preSelection <> '' then begin
                    aRec.Reset();
                    aRec.SetRange("Option ID", lRec.oID);
                    aRec.SetFilter(Designator, lRec.preSelection);
                    if aRec.FindSet() then begin
                        repeat
                            updateAssembly(aRec);
                        until aRec.Next() = 0;
                    end;
                end;
                if lRec.sufSelection <> '' then begin
                    aRec.Reset();
                    aRec.SetRange("Option ID", lRec.oID);
                    aRec.SetFilter(Designator, lRec.sufSelection);
                    if aRec.FindSet() then begin
                        repeat
                            updateAssembly(aRec);
                        until aRec.Next() = 0;
                    end;
                end;
            until lRec.Next() = 0;
        end;

    end;
    procedure updateAssembly(a: Record "Option Assembly Line"): Boolean
    var
    bRec: Record "BOM Component";
        dRec: Record "Assemble-to-Order Link";
    begin
        
        bRec.SetFilter("Parent Item No.", rec.iID);
        
    end;
    var
        iRec: Record Item;
        p, s : text[50];
        slRec: Record "Sales Line";
        shRec: Record "Sales Order Entity Buffer";
        spRec: Record SPList temporary;
        fPN: Text[200];


}
