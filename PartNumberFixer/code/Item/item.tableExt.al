tableextension 50101 itemTableExt extends Item
{
    fields
    {
        field(10001; PartNumber; Text[100])
        {
            DataClassification = ToBeClassified;

        }
        field(10002; ports; Integer)
        {
            DataClassification = ToBeClassified;
            BlankZero = true;

        }
        field(10003; opts; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(7; "Item Type"; Enum "ItemTypes")
        {
            DataClassification = ToBeClassified;
            Caption = 'Item Type';

        }
        field(13; "PartType"; Enum "PartTypes")
        {
            DataClassification = ToBeClassified;
            Caption = 'Part Type';
        }
        field(50122; showOnDocument; Boolean)
        {
            DataClassification = ToBeClassified;
            Caption = 'Show On Assembly Line in Sales Document';
        }
        field(50123; nestedOpts; Boolean)
        {
            DataClassification = ToBeClassified;
            Caption = 'Apply Options to Assembly Parts?';
        }
    }
    fieldgroups
    {
        addlast(DropDown; PartNumber)
        {

        }
    }
    var
        OldPartNo: Text[100];

    trigger OnAfterInsert()
    var
        IntermediaryPartRec: Record "Intermediary Part Table";
    begin
        if not IntermediaryPartRec.Get("PartNumber") then begin
            IntermediaryPartRec.Init();
            IntermediaryPartRec."PartNumber" := "PartNumber";
            IntermediaryPartRec."Item ID" := "No.";
            IntermediaryPartRec."Item Description" := Description;
            IntermediaryPartRec.Insert();
        end;
    end;

    trigger OnBeforeModify()
    begin
        OldPartNo := PartNumber;
    end;

    trigger OnAfterModify()
    var
        IntermediaryPartRec: Record "Intermediary Part Table";
    begin
        if IntermediaryPartRec.Get(OldPartNo) then begin
            IntermediaryPartRec."Item ID" := "No.";
            IntermediaryPartRec."Item Description" := Description;
            IntermediaryPartRec.Modify();
        end else begin
            IntermediaryPartRec.Init();
            IntermediaryPartRec."PartNumber" := "PartNumber";
            IntermediaryPartRec."Item Description" := Description;
            IntermediaryPartRec."Item ID" := "No.";
            IntermediaryPartRec.Insert();
        end;
    end;

    // Optionally, you can also handle deletes
    trigger OnAfterDelete()
    var
        IntermediaryPartRec: Record "Intermediary Part Table";
    begin
        if IntermediaryPartRec.Get(OldPartNo) then begin
            IntermediaryPartRec.Delete();
        end;
    end;
}