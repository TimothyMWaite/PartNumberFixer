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

    procedure setNos(i: Record Item)
    begin
        rec."ItemNo." := i."No.";
    end;
}