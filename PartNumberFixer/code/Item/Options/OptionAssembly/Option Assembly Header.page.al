table 50120 "Option Assembly Header"
{
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Option ID"; Code[20])
        {
            DataClassification = ToBeClassified;
        }

        // Additional Fields
    }

    keys
    {
        key(PK; "Option ID")
        {
            Clustered = true;
        }
    }

    // You can also define relationships, business logic, triggers, etc.
}
