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
            // AutoIncrement = true;
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
        field(8; lID; Text[50])
        {
            DataClassification = ToBeClassified;
        }
    }

    keys
    {
        key(PK; "Line No.")
        {
            Clustered = true;

        }
        key(SK; "ItemNo.")
        {
        }
    }


    trigger OnInsert()
    begin


        // Concatenate ItemNo and LineNo to form lID

        lID := "ItemNo." + '-' + Format("Line No.");
        // Modify is not needed here as this is an OnInsert trigger
    end;
}