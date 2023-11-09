tableextension 50101 ItemTableExt extends Item
{
    fields
    {
        field(10001; PartNo; Text[100])
        {
            DataClassification = CustomerContent;
        }
        field(10002; "Myfield"; Text[100])
        {
            DataClassification = CustomerContent;
            ObsoleteState = Pending;
        }

    }

    // var
    //   myInt: Integer;
}