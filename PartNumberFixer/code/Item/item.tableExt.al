tableextension 50101 itemTableExt extends Item
{
    fields
    {
        field(10001; PartNo; Text[100])
        {
            DataClassification = ToBeClassified;

        }
    }
    var
        OldPartNo: Text[100];

    trigger OnAfterInsert()
    var
        IntermediaryPartRec: Record "Intermediary Part Table";
    begin
        if not IntermediaryPartRec.Get("PartNo") then begin
            IntermediaryPartRec.Init();
            IntermediaryPartRec."PartNo" := "PartNo";
            IntermediaryPartRec."Item ID" := "No.";
            IntermediaryPartRec."Item Description" := Description;
            IntermediaryPartRec.Insert();
        end;
    end;

    trigger OnBeforeModify()
    begin
        OldPartNo := PartNo;
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
            IntermediaryPartRec."PartNo" := "PartNo";
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