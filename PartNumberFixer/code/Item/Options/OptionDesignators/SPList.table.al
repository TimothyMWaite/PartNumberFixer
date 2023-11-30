table 50124 SPList
{

    fields
    {
        field(1; ID; Integer)
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
    fieldgroups
    {
        fieldgroup(DropDown; Designator)
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

    procedure getNewID(): Integer
    begin
        rec.Reset();
        if rec.FindLast() then begin
            exit(rec.ID + 1);
        end else begin
            exit(1000);
        end;
    end;
}