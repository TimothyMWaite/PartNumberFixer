page 50125 "SPList"
{
    PageType = List;
    ApplicationArea = All;
    SourceTable = "Option Designators";
    // SourceTableTemporary = true;

    Caption = 'Designator List';

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Id; Rec.Id)
                {
                    ApplicationArea = All;
                    Editable = false;
                }
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
                field(Show; Rec.show)
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

    procedure getText(oId: Integer; front: Boolean): text[500]
    var
        pre: text[10];
        po: Integer;
        oRec: Record Option;
        sl: Record "Option Designators";
        added: Boolean;
    begin
        PrefixField := '';
        sl.SetRange(show, true);
        sl.SetFilter(atFront, Format(front));
        if sl.FindSet() then begin
            repeat
                if front then begin
                    PrefixField := sl.Designator + PrefixField;
                end else begin
                    SuffixField += sl.Designator;
                end;
            until sl.Next() = 0;

        end;
        // Message('%1', PrefixField);
        if front then
            exit(PrefixField)
        else
            exit(SuffixField);
    end;


    var

        optionId: Integer;
        PrefixField, SuffixField : Text[500];
}
