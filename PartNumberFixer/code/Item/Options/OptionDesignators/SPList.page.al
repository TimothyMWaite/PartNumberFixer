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
                    Editable = optionId <> rec.OptionID;
                    trigger OnValidate()
                    var

                    begin
                        // Initialize PrefixString and SuffixString


                        rec.Modify();
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
        PrefixField := '';

        if oRec.Get(oId) then begin
            pre := oRec."Prefix Designator";
            po := oRec."Prefix Order";
        end;

        if sl.FindSet() then begin
            repeat
                if sl.active AND sl.prefix then
                    PrefixField := sl.Designator + PrefixField;
            until sl.Next() = 0;

        end;
        // Message('%1', PrefixField);
        exit(PrefixField);
    end;

    procedure addFromCurrentRec(sRec: Record "Option Suffix")
    var
        sl: Record SPList;
    begin
        if sl.Get(Format(sRec.OptionID) + sRec."Suffix Designator") then begin
            sl.active := sRec.show;
            sl.Modify();
        end;
    end;

    procedure getSufText(oId: Integer): text[500]
    var
        so: Integer;
        sRec: Record "Option Suffix";
        oRec: Record Option;
        sl: Record SPList;
    begin
        SuffixField := '';
        if oRec.Get(oId) then begin
            so := oRec."Suffix Order";
        end;
        if sl.FindSet() then begin
            repeat
                if sl.Designator = '' then begin
                    sl.Delete();
                end;
                if sl.active AND not sl.prefix then
                    SuffixField += sl.Designator;


            until sl.Next() = 0;
        end;
        // Message('%1', SuffixField);
        exit(SuffixField);
    end;

    var
        spRec: Record SPList;
        optionId: Integer;
        TempRec: Record SPList;
        PrefixField, SuffixField : Text[500];
}
