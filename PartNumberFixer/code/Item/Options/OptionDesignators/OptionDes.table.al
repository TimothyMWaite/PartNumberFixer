table 50112 "Option Designators"
{
    DataClassification = ToBeClassified;

    fields
    {
        field(10; Id; Integer)
        {
            DataClassification = ToBeClassified;
            AutoIncrement = false;
        }

        field(1; "Designator"; Text[10])
        {
            DataClassification = ToBeClassified;
        }
        field(2; "Order"; Integer)
        {
            DataClassification = ToBeClassified;
        }
        field(3; atFront; Boolean)
        {
            DataClassification = ToBeClassified;
        }

        field(5; OptionID; Integer)
        {
            DataClassification = ToBeClassified;
            TableRelation = Option.Id;
        }
        field(6; show; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(7; AssemblyID; Integer)
        {
            DataClassification = ToBeClassified;
        }
        field(8; itemType; Enum ItemTypes)
        {
            DataClassification = ToBeClassified;
            TableRelation = Option."Item Type" where(Id = field(OptionID));
        }
        field(9; PriceChange; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(12; variable; Boolean)
        {
            DataClassification = ToBeClassified;
        }

        // field(10; AssemblyChange; Integer)
        // {
        //     DataClassification = ToBeClassified;
        // }
    }
    keys
    {
        key(PK; Designator)
        {
            Clustered = true;
        }
        key(PK2; Id)
        {

        }
        key(SK; OptionID, Order)
        {

        }
    }
    trigger OnDelete()
    var
        aRec: Record "Option Assembly Line";
    begin
        aRec.Reset();
        aRec.SetFilter("Designator", Designator);
        aRec.SetRange("Option ID", Id);
        if aRec.FindSet() then begin
            repeat
                aRec.Delete();
            until aRec.Next() = 0;
        end;
    end;

    procedure getNewID(): Integer
    var
        spl: Record "Option Designators";
    begin
        if spl.FindLast() then begin
            exit(spl.ID + 1);
        end else begin
            exit(1000);
        end;
    end;
}
