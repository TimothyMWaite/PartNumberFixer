table 50124 SPList
{

    fields
    {
        field(1; ID; Code[50])
        {
            DataClassification = ToBeClassified;
        }
        field(2; Designator; Text[10])
        {
            DataClassification = ToBeClassified;
        }
        field(3; active; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(4; OptionID; Integer)
        {
            DataClassification = ToBeClassified;
        }
        field(5; prefix; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(6; Order; Integer)
        {
            DataClassification = ToBeClassified;
        }
    }

    keys
    {
        key(PK; ID)
        {
            Clustered = true;
        }
        key(SK; Order, OptionID)
        {

        }
    }
    procedure getActive(): Record SPList
    var
        SPList, s : Record SPList temporary;
    begin
        s.SetRange(active);
        if s.FindSet() then begin
            repeat
                SPList.Init();
                SPList := s;
                SPList.Insert();
            until Next() = 0;
        end;
        SPList.Reset();
        exit(SPList);
    end;
}