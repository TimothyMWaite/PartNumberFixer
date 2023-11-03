table 50121 "Option Assembly Line"
{
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Option ID"; Code[20])
        {
            DataClassification = ToBeClassified;
        }

        field(2; "Line No."; Integer)
        {
            DataClassification = ToBeClassified;
        }

        // Additional Fields
    }

    keys
    {
        key(PK; "Option ID", "Line No.")
        {
            Clustered = true;
        }
    }

    // You can also define relationships, business logic, triggers, etc.
}
