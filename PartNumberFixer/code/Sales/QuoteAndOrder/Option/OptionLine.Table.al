table 50135 OptionLine
{
    DataClassification = ToBeClassified;

    fields
    {
        field(1; Id; Integer)
        {
            DataClassification = ToBeClassified;
        }
        field(2; pn; Enum SalesLineEnum)
        {
            DataClassification = ToBeClassified;

        }
        field(3; shID; Integer)
        {
            DataClassification = ToBeClassified;
        }
        field(4; oID; Integer)
        {
            DataClassification = ToBeClassified;
        }
        field(5; oName; Text[50])
        {
            DataClassification = ToBeClassified;
        }
        field(6; selection; text[50])
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
    }

    fieldgroups
    {
        // Add changes to field groups here
    }
    // trigger OnInsert()
    // begin

    // end;

    // trigger OnModify()
    // begin

    // end;

    // trigger OnDelete()
    // begin

    // end;

    // trigger OnRename()
    // begin

    // end;

    procedure getNewID(): Integer
    begin
        if rec.FindLast() then begin
            exit(rec.ID + 1);
        end else begin
            exit(1000);
        end;
    end;
}
