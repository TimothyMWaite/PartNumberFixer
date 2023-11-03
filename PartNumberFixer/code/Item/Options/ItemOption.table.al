table 50105 "Item Option Header"
{
    DataClassification = ToBeClassified;

    fields
    {
        field(2; "ItemNo."; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = Item."No.";
        }
        field(3; "PartNo"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Intermediary Part Table".PartNo;
        }


        // ... other general fields that are not line-specific
    }

    keys
    {
        key(PK; "ItemNo.")
        {
            Clustered = true;
        }
    }

    // ... other triggers, relationships, etc.
}
