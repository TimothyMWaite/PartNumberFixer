tableextension 50124 AssemblyLine extends "BOM Component"
{
    fields
    {
        field(100; ccID; Guid)
        {
            DataClassification = ToBeClassified;
            TableRelation = Item."Item Category Id";
        }
        field(101; catagory; Code[20])
        {
            DataClassification = ToBeClassified;
            TableRelation = Item."Item Category Id";
        }
        field(102; changedByOptionID; Integer){
            DataClassification = ToBeClassified;
            TableRelation = Option.Id;
        }
    }
}