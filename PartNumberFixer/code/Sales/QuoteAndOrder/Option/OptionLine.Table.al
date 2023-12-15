table 50135 OptionLine
{
    DataClassification = ToBeClassified;

    fields
    {
        field(1; Id; Integer)
        {
            DataClassification = ToBeClassified;
        }
        field(2; pn; Text[200])
        {
            DataClassification = ToBeClassified;

        }
        field(3; docID; code[20])
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
        field(6; preSelection; text[50])
        {
            DataClassification = ToBeClassified;
        }
        field(7; sufSelection; text[50])
        {
            DataClassification = ToBeClassified;
        }
        field(8; pre; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(9; iID; code[20])
        {
            DataClassification = ToBeClassified;
            
        }
        field(10; preOrder; Integer)
        {
            DataClassification = ToBeClassified;
            TableRelation = Option."Prefix Order" WHERE(Id = field(oID));
        }
        field(11; sufOrder; Integer)
        {
            DataClassification = ToBeClassified;
            TableRelation = Option."Suffix Order" WHERE(Id = field(oID));
        }
        field(12; line; Integer)
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



    procedure isPreEmpty(): Boolean
    begin
        exit(rec.preSelection = '');
    end;

    procedure isSufEmpty(): Boolean
    begin
        exit(rec.sufSelection = '');
    end;

    procedure convertOption(o: Record Option)
    begin
        oRec := o;
        oID := o.Id;
        oName := o.Name;
        if Id = 0 then
            Id := getNewID();


    end;

    var
        oRec: Record Option;
        p, s : text[50];
}
