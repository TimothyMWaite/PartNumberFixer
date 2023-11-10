table 50102 "Item Option Line"
{
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "OptionName"; Text[50])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Option"."Name";
        }
        field(22; "ItemNo."; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = Item."No.";
        }
        field(33; "PartNo"; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = "Intermediary Part Table".PartNo;
        }
        field(111; "Line No."; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(2; Caption; Text[50])
        {
            DataClassification = ToBeClassified;
        }

        field(3; Required; Boolean)
        {
            DataClassification = ToBeClassified;
        }

        field(4; "Option Designator"; Text[10])
        {
            DataClassification = ToBeClassified;
        }

        field(5; "Designator Order"; Integer)
        {
            DataClassification = ToBeClassified;
        }

        field(6; "Add To Front"; Boolean)
        {
            DataClassification = ToBeClassified;
        }

        field(7; "Price Change"; Decimal)
        {
            DataClassification = ToBeClassified;
        }

        field(8; "AssemblyOptionID"; Guid)
        {
            DataClassification = ToBeClassified;
            TableRelation = "Option Assembly Line".ID;

        }

        field(10; "Is General"; Boolean)
        {
            DataClassification = ToBeClassified;
        }

        field(11; "Port Specific"; Boolean)
        {
            DataClassification = ToBeClassified;
        }

        field(12; "Number of Ports"; Integer)
        {
            DataClassification = ToBeClassified;
        }
    }

    keys
    {
        key(PK; "ItemNo.", "Line No.")
        {
            Clustered = true;
        }
    }
    trigger OnInsert()
    var
        iRec: Record Item;
        IO: Codeunit ItemOptions;
    begin
        iRec := IO.getItemRecord();
        setNos(iRec);
    end;

    procedure setNos(i: Record Item)
    begin
        rec.PartNo := i.PartNo;
        rec."ItemNo." := i."No.";
    end;
}