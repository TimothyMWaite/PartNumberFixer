table 50101 "Intermediary Part Table"
{
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "PartNumber"; Text[100])
        {
            DataClassification = ToBeClassified;
        }

        field(2; "Item ID"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(3; "Item Description"; Text[100])
        {
            DataClassification = ToBeClassified;
        }

        // Add other fields as needed
    }

    keys
    {
        key(PK; PartNumber)
        {
            Clustered = true;
        }
        key(SK; "Item Description")
        {

        }
    }

    // ... other table elements like field groups, etc.
}
