table 50112 "Option Suffix"
{
    DataClassification = ToBeClassified;

    fields
    {

        field(4; "Suffix Designator"; Text[10])
        {
            DataClassification = ToBeClassified;
        }
        field(5; "Suffix Order"; Integer)
        {
            DataClassification = ToBeClassified;
        }
        field(7; Line; Integer)
        {
            DataClassification = ToBeClassified;
        }
        field(9; OptionID; Integer)
        {
            DataClassification = ToBeClassified;
            TableRelation = Option.Id;
        }
        field(10; show; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(11; AssemblyChange; Code[20])
        {
            DataClassification = ToBeClassified;
        }
    }
    keys
    {
        key(PK; "Suffix Designator")
        {
            Clustered = true;
        }
        key(SK; OptionID)
        {

        }
    }
}
