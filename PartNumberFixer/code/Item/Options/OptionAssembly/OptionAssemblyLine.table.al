table 50121 "Option Assembly Line"
{
    DataClassification = ToBeClassified;

    fields
    {
        field(10; ID; Text[50])
        {
            DataClassification = ToBeClassified;
        }
        field(1; "Option ID"; Integer)
        {
            DataClassification = ToBeClassified;
        }

        field(2; "Line No."; Integer)
        {
            DataClassification = ToBeClassified;
        }
        field(3; No; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(4; Description; Text[255])
        {
            DataClassification = ToBeClassified;
        }
        field(5; UOM; Code[20])
        {
            DataClassification = ToBeClassified;

        }
        field(6; Qty; Integer)
        {
            DataClassification = ToBeClassified;

        }
        field(7; perConnector; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(8; Designator; Text[20])
        {
            DataClassification = ToBeClassified;
        }

        // Additional Fields
    }

    keys
    {
        key(PK; ID)
        {
            Clustered = true;
        }
        key(SK; "Option ID", "Line No.")
        { }
    }

    // You can also define relationships, business logic, triggers, etc.
}
