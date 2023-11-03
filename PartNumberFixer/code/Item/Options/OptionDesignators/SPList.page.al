page 50125 "SPList"
{
    PageType = List;
    ApplicationArea = All;
    SourceTable = SPList;
    SourceTableView = sorting(Order, OptionID);
    Caption = 'SPTable List';

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                Visible = optionId <> rec.OptionID;
                field(Designator; Rec.Designator)
                {
                    ApplicationArea = All;
                    Editable = false;

                }
                field(Order; Rec.Order)
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field(Active; Rec.active)
                {
                    ApplicationArea = All;
                    trigger OnValidate()
                    var
                        SortedRec: Record SPList;
                        PrefixString: Text[100];
                        SuffixString: Text[100];
                    begin
                        // Initialize PrefixString and SuffixString
                        PrefixString := '';
                        SuffixString := '';

                        // Find all active records for the current option and add them to the temporary table
                        if TempRec.Get(rec.ID) then begin
                            TempRec.active := rec.active;
                            TempRec.Modify()
                        end else begin
                            TempRec.Init();
                            TempRec := rec;
                            if TempRec.Insert() then begin
                                Message('%1', TempRec.Designator);
                            end;
                        end;
                        // Now PrefixString and SuffixString contain the concatenated and sorted designators
                        // You can display these in the UI or pass them to your JavaScript
                    end;

                }
                field(OptionID; Rec.OptionID)
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            // Add custom actions here if needed

        }
    }
    procedure setOptionId(oId: Integer)
    begin
        optionId := oId;
    end;

    procedure getPreText(oId: Integer): text[500]
    var
        pre: text[10];
        po: Integer;
        oRec: Record Option;
        sl: Record SPList;
        added: Boolean;
    begin
        if oRec.Get(oId) then begin
            pre := oRec."Prefix Designator";
            po := oRec."Prefix Order";
        end;

        if sl.FindSet() then begin
            repeat
                if (sl.Order >= po) AND sl.prefix AND not added then begin
                    PrefixField := pre + PrefixField;

                end;
                if sl.active AND (sl.OptionID <> oId) then
                    PrefixField := sl.Designator + PrefixField;



            until sl.Next() = 0;

        end;
        Message('%1', PrefixField);
        exit(PrefixField);
    end;

    procedure getSufText(oId: Integer): text[500]
    var
        so: Integer;
        sRec: Record "Option Suffix";
        oRec: Record Option;
        sl: Record SPList;
    begin
        if oRec.Get(oId) then begin
            so := oRec."Suffix Order";
        end;
        if sl.FindSet() then begin
            repeat

                if (sl.Order >= so) AND not sl.prefix then begin
                    sRec.SetFilter(OptionID, Format(oId));
                    if sRec.FindSet() then begin
                        repeat
                            if sRec.show then
                                SuffixField += sRec."Suffix Designator";

                        until sRec.Next() = 0;
                    end;
                end;
                if sl.active AND (sl.OptionID <> oId) then
                    SuffixField += sl.Designator;


            until sl.Next() = 0;
        end;
        Message('%1', SuffixField);
        exit(SuffixField);
    end;

    var
        spRec: Record SPList;
        optionId: Integer;
        TempRec: Record SPList temporary;
        PrefixField, SuffixField : Text[500];
}
