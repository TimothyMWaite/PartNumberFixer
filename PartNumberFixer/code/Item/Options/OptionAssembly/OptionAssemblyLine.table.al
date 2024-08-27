table 50121 "Option Assembly Line"
{
    DataClassification = ToBeClassified;

    fields
    {
        field(10; ID; Integer)
        {
            DataClassification = ToBeClassified;
        }
        field(1; "Option ID"; Integer)
        {
            DataClassification = ToBeClassified;
        }

        field(2; "DesID"; Integer)
        {
            DataClassification = ToBeClassified;
        }
        field(11; "Part No"; text[200])
        {
            DataClassification = ToBeClassified;
        }
        field(3; No; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(4; Description; Text[255])
        {
            DataClassification = ToBeClassified;
        }
        field(5; "Qty"; Integer)
        {
            DataClassification = ToBeClassified;

        }
        field(6; "Per Port"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(7; Designator; Text[20])
        {
            DataClassification = ToBeClassified;
        }
        field(9; replacesPartType; Enum partTypes)
        {
            DataClassification = ToBeClassified;
        }
        field(12; replacePart; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        // field(11; replacePart; Boolean)
        // {
        //     DataClassification = ToBeClassified;
        // }
        // field(9; replaceType; code[20])
        // {
        //     DataClassification = ToBeClassified;
        // }

        // Additional Fields
    }

    keys
    {
        key(PK; ID)
        {
            Clustered = true;
        }
        key(SK; "Option ID", DesID)
        { }
        // key(Items; No, "Part No", Description)
        // {
        //     Unique = true;
        // }
    }
    // trigger OnInsert()
    // begin
    //     if rec.Qty = 0 then begin
    //         error('Quantity cannot be zero');
    //     end;

    // end;

    // trigger OnModify()
    // begin
    //     if rec.Qty = 0 then begin
    //         error('Quantity cannot be zero setting quantity to 1');
    //         rec.Qty := 1;
    //         rec.Modify(false);
    //     end;
    // end;

    procedure getNewID(): Integer
    var
        r: Record "Option Assembly Line";
    begin
        if r.FindLast() then begin
            exit(r.ID + 1);
        end else begin
            exit(1000);
        end;
    end;
    // You can also define relationships, business logic, triggers, etc.
}
