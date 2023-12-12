table 50102 "Item Option Line"
{
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "OptionName"; Text[200])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Option"."Name";
        }
        field(5; "OptionID"; Integer)
        {
            DataClassification = ToBeClassified;
            TableRelation = "Option".Id;
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
        field(8; lID; Integer)
        {
            DataClassification = ToBeClassified;
        }
        field(11; pre; Boolean)
        {
            DataClassification = ToBeClassified;
        }
    }

    keys
    {
        key(PK; "lID")
        {
            Clustered = true;

        }
        key(SK; "ItemNo.")
        {
        }
    }
    trigger OnInsert()
    var
        lRec: Record "Item Option Line";
    begin
        if lRec.FindLast() then begin
            lID := lRec.lID + 1;

        end else begin
            lID := 100;
        end;
    end;

    procedure convertOption(o: Record Option)
    begin
        oRec := o;
        OptionID := o.Id;
        OptionName := o.Name;
        Caption := o.Caption;
        lID := getNewID();
        "Price Change" := o."Price Change";

    end;

    procedure getNewID(): Integer
    begin
        if rec.FindLast() then begin
            exit(rec.lID + 1);
        end else begin
            exit(1000);
        end;
        ;
    end;

    var
        oRec: Record Option;
}