tableextension 50124 AssemblyLine extends "BOM Component"
{
    fields
    {
        field(100; PartNo; Text[200])
        {
            DataClassification = ToBeClassified;
        }
        field(101; catagory; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = Item."Item Category Id";
        }
        field(102; changedByOptionID; Integer)
        {
            DataClassification = ToBeClassified;
            TableRelation = Option.Id;
        }

        field(103; PartType; Enum PartTypes)
        {
            DataClassification = ToBeClassified;
        }
        field(104; showOnDocument; Boolean)
        {
            DataClassification = ToBeClassified;
        }
    }
    trigger OnBeforeInsert()
    var
        iRec: Record Item;
    begin
        if iRec.get(rec."No.") then begin
            rec.PartType := iRec.PartType;
        end;

    end;

    trigger OnBeforeModify()
    var
        iRec: Record Item;
    begin
        if iRec.get(rec."No.") then begin
            rec.PartType := iRec.PartType;
        end;

    end;
}