table 50102 "Item Option Line"
{
    DataClassification = ToBeClassified;

    fields
    {
        field(11; LineID; Text[220])
        {
            DataClassification = ToBeClassified;
        }
        field(1; "OptionName"; Text[200])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Option"."Name";
            trigger OnValidate()
            var
                oRec: Record Option;
            begin
                oRec.Reset();
                oRec.SetFilter(Name, rec.OptionName);
                if oRec.FindFirst() then begin
                    rec.OptionID := oRec.Id;
                    rec.Modify(false);
                end;
            end;
        }
        field(5; "OptionID"; Integer)
        {
            DataClassification = ToBeClassified;
            TableRelation = "Option".Id;
            trigger OnValidate()
            var
                oRec: Record Option;

            begin
                if oRec.get(rec.OptionID) then begin
                    rec.OptionName := oRec.Name;
                    rec.Modify(false);
                end;
                setID();
            end;
        }
        field(22; "ItemNo."; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = Item."No.";
        }
        field(111; "Line No."; Integer)
        {
            DataClassification = ToBeClassified;
            AutoIncrement = true;
        }
        field(2; Caption; Text[200])
        {
            DataClassification = ToBeClassified;
        }

        field(3; Required; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(7; "Price Change"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
    }

    keys
    {
        key(PK; "ItemNo.", "Line No.")
        {
            Clustered = true;
        }
    }
    trigger OnInsert()
    var
        iRec: Record Item;
        IO: Codeunit ItemOptions;
    begin
        iRec := IO.getItemRecord();
        setNos(iRec);
    end;

    procedure setID()
    begin
        rec.LineID := Format(rec.OptionID) + rec."ItemNo." + Format("Line No.");
        rec.Modify();
    end;

    procedure setNos(i: Record Item)
    begin
        rec."ItemNo." := i."No.";
    end;
}