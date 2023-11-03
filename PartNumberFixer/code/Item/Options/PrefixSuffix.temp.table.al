table 50107 TempPrefixSuffix
{
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Designator"; Text[10])
        {
            DataClassification = ToBeClassified;
        }

        field(2; "Order"; Integer)
        {
            DataClassification = ToBeClassified;
        }
        field(3; active; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(4; afterPn; Boolean)
        {

        }
        field(5; optionID; Integer)
        {
            DataClassification = ToBeClassified;
        }
    }

    keys
    {
        key(PK; "Designator")
        {
            Clustered = true;
        }

        key("OrderKey"; "Order")
        {
        }
    }
}
